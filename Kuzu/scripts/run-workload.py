#!/usr/bin/env python3
"""Run or validate local Kuzu workload query sets.

The runner opens already imported Kuzu databases under /mnt/data/imported_data/kuzu
and runs Cypher query files through the Kuzu Python API. It is intended for
local correctness/smoke runs, not as an official benchmark harness.
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import json
import multiprocessing as mp
import re
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
KUZU_ROOT = REPO_ROOT / "Kuzu"
QUERY_ROOT = KUZU_ROOT / "queries"
GRAPHDBLP_QUERY_DIR = REPO_ROOT / "NeuG" / "queries" / "graphdblp" / "distinct"
DEFAULT_PARAM_DIRS = {
    "ic-sf1": Path("/mnt/data/parameters/ldbc_snb_ic/substitution_parameters-sf1"),
    "bi-sf1": Path("/mnt/data/parameters/ldbc_snb_bi/parameters-sf1"),
    "finbench-sf1": Path("/mnt/data/parameters/finbench/sf1_read_params"),
}
SAMPLED_PARAM_SUBDIRS = {
    "ic-sf1": Path("ldbc_snb_ic/sf1"),
    "bi-sf1": Path("ldbc_snb_bi/sf1"),
    "finbench-sf1": Path("finbench/sf1"),
}
DEFAULT_SAMPLED_PARAM_ROOT = Path("/mnt/data/sampled_parameters")
DEFAULT_SAMPLED_PARAM_DIRS = {
    workload_name: DEFAULT_SAMPLED_PARAM_ROOT / subdir
    for workload_name, subdir in SAMPLED_PARAM_SUBDIRS.items()
}
DEFAULT_RESULTS_ROOT = Path("/mnt/data/results/kuzu")
RUN_TIMESTAMP_FORMAT = "%Y%m%d-%H%M%S"


@dataclass(frozen=True)
class Workload:
    name: str
    db_dir: Path
    query_dir: Path | None
    description: str
    default_mode: str = "explain"
    supports_execute: bool = True
    configured: bool = True
    threads: int = 1
    skip_names: set[str] = field(default_factory=set)


WORKLOADS = {
    "ic-sf1": Workload(
        name="ic-sf1",
        db_dir=Path("/mnt/data/imported_data/kuzu/ic-sf1"),
        query_dir=QUERY_ROOT / "baseline" / "ldbc-ic",
        description="LDBC SNB Interactive SF1",
    ),
    "bi-sf1": Workload(
        name="bi-sf1",
        db_dir=Path("/mnt/data/imported_data/kuzu/bi-sf1"),
        query_dir=QUERY_ROOT / "baseline" / "ldbc-bi",
        description="LDBC SNB BI SF1",
        skip_names={"setup.cypher", "bi-19-create-graph.cypher", "bi-19-drop-graph.cypher", "bi-20-create-graph.cypher", "bi-20-drop-graph.cypher"},
    ),
    "lsqb-sf1": Workload(
        name="lsqb-sf1",
        db_dir=Path("/mnt/data/imported_data/kuzu/lsqb/sf1"),
        query_dir=QUERY_ROOT / "baseline" / "lsqb",
        description="LSQB SF1",
        skip_names={"schema.cypher"},
    ),
    "finbench-sf1": Workload(
        name="finbench-sf1",
        db_dir=Path("/mnt/data/imported_data/kuzu/finbench"),
        query_dir=QUERY_ROOT / "baseline" / "finbench",
        description="FinBench SF1",
    ),
    "graphdblp": Workload(
        name="graphdblp",
        db_dir=Path("/mnt/data/imported_data/kuzu/graphdblp"),
        query_dir=GRAPHDBLP_QUERY_DIR,
        description="GraphDBLP distinct query workload",
        supports_execute=False,
    ),
}


def strip_query(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    lines = []
    for line in text.splitlines():
        if "//" in line:
            line = line.split("//", 1)[0]
        stripped = line.strip()
        if stripped.startswith(":param") or stripped.startswith(":params"):
            continue
        lines.append(line.rstrip())
    query = "\n".join(lines).strip()
    while query.endswith(";"):
        query = query[:-1].rstrip()
    return query


def queries_for(workload: Workload, include_setup: bool) -> list[Path]:
    assert workload.query_dir is not None
    files = sorted(workload.query_dir.rglob("*.cypher"))
    if not include_setup:
        files = [path for path in files if path.name not in workload.skip_names]
    return files


def unique_query_match(workload: Workload, matches: list[Path], query: str) -> Path:
    assert workload.query_dir is not None
    if len(matches) == 1:
        return matches[0]
    if len(matches) > 1:
        rels = "\n".join(str(path.relative_to(workload.query_dir)) for path in matches[:20])
        raise ValueError(f"--query matched multiple files for '{query}', use a more specific path:\n{rels}")
    raise FileNotFoundError(f"--query not found under {workload.query_dir}: {query}")


SETUP_QUERY_FILES = {
    "bi15/bi-15.cypher",
    "bi19/bi-19.cypher",
}


def setup_query_path(workload: Workload, query_path: Path) -> Path | None:
    rel = rel_path(workload, query_path)
    if workload.name == "bi-sf1" and rel in SETUP_QUERY_FILES:
        return query_path.with_name("setup.cypher")
    return None


def resolve_one_query(workload: Workload, query: str) -> Path:
    assert workload.query_dir is not None
    query_path = Path(query)
    if not query_path.is_absolute():
        candidate = workload.query_dir / query_path
        if candidate.exists():
            if candidate.is_dir():
                if workload.name == "bi-sf1" and re.fullmatch(r"bi\d+", candidate.name):
                    number = candidate.name[2:]
                    bi_query = candidate / f"bi-{number}.cypher"
                    if bi_query.exists():
                        return bi_query
                matches = sorted(
                    path for path in candidate.rglob("*.cypher")
                    if path.name not in workload.skip_names
                )
                return unique_query_match(workload, matches, query)
            return candidate
        if query_path.suffix == "":
            candidate_with_suffix = workload.query_dir / f"{query}.cypher"
            if candidate_with_suffix.exists():
                return candidate_with_suffix
        matches = sorted(workload.query_dir.rglob(query))
        if not matches:
            matches = sorted(path for path in workload.query_dir.rglob("*.cypher") if path.name == query)
        if not matches and query_path.suffix == "":
            matches = sorted(path for path in workload.query_dir.rglob("*.cypher") if path.name == f"{query}.cypher")
        return unique_query_match(workload, matches, query)
    if not query_path.exists():
        raise FileNotFoundError(f"--query file does not exist: {query_path}")
    if query_path.suffix != ".cypher":
        raise ValueError(f"--query must point to a .cypher file: {query_path}")
    return query_path


def is_write_query(workload: Workload, rel: str, query: str) -> bool:
    if workload.name == "finbench-sf1" and rel.startswith("tw-"):
        return True
    return bool(re.search(r"(^|\n)\s*(CREATE|MERGE|DELETE|SET|DROP|COPY)\b", query, flags=re.I))


def epoch_millis_to_datetime(value: str | int | float) -> dt.datetime:
    millis = int(value)
    return dt.datetime.fromtimestamp(millis / 1000, tz=dt.timezone.utc).replace(tzinfo=None)


def parse_datetime_value(value: str) -> dt.datetime:
    text = str(value).strip()
    if re.fullmatch(r"-?\d+", text):
        return epoch_millis_to_datetime(text)
    normalized = text.replace("Z", "+00:00")
    if re.fullmatch(r"\d{4}-\d{2}-\d{2}$", normalized):
        return dt.datetime.combine(dt.date.fromisoformat(normalized), dt.time())
    if " " in normalized and "T" not in normalized:
        normalized = normalized.replace(" ", "T", 1)
    parsed = dt.datetime.fromisoformat(normalized)
    if parsed.tzinfo is not None:
        parsed = parsed.astimezone(dt.timezone.utc).replace(tzinfo=None)
    return parsed


def coerce_value(value: object, value_type: str | None = None, key: str | None = None) -> object:
    if value is None:
        return None
    if isinstance(value, (bool, int, float, dt.datetime, dt.date)):
        return value
    text = str(value).strip()
    type_name = (value_type or "").upper()
    if text == "":
        return None
    if type_name in {"ID", "INT", "LONG"}:
        return int(text)
    if type_name in {"FLOAT", "DOUBLE"}:
        return float(text)
    if type_name == "STRING[]":
        return [item for item in text.split(";") if item != ""]
    if type_name in {"DATE", "DATETIME"}:
        return parse_datetime_value(text)
    if key in {"startDate", "endDate", "minDate", "maxDate", "date", "dateA", "dateB", "datetime"} and re.fullmatch(r"-?\d+", text):
        return epoch_millis_to_datetime(text)
    if key in {"start_time", "end_time", "currentTime"}:
        return parse_datetime_value(text)
    if re.fullmatch(r"-?\d+", text):
        return int(text)
    if re.fullmatch(r"-?\d+\.\d+", text):
        return float(text)
    return text


def display_value(value: str, value_type: str | None = None) -> object:
    text = str(value).strip()
    type_name = (value_type or "").upper()
    if text == "":
        return None
    if type_name in {"ID", "INT", "LONG"}:
        return int(text)
    if type_name in {"FLOAT", "DOUBLE"}:
        return float(text)
    if type_name == "STRING[]":
        return [item for item in text.split(";") if item != ""]
    if type_name in {"DATE", "DATETIME", "STRING"}:
        return text
    if re.fullmatch(r"-?\d+", text):
        return int(text)
    if re.fullmatch(r"-?\d+\.\d+", text):
        return float(text)
    return text


def default_params_for(workload_name: str) -> dict[str, object]:
    if workload_name == "ic-sf1":
        return {
            "personId": 4398046511333,
            "person1Id": 4398046511333,
            "person2Id": 21990232557716,
            "firstName": "Jose",
            "countryName": "China",
            "countryXName": "China",
            "countryYName": "India",
            "tagClassName": "Thing",
            "tagName": "music",
            "month": 1,
            "workFromYear": 2010,
            "startDate": dt.datetime(2010, 1, 1),
            "endDate": dt.datetime(2030, 1, 1),
            "minDate": dt.datetime(2010, 1, 1),
            "maxDate": dt.datetime(2030, 1, 1),
        }
    if workload_name == "bi-sf1":
        return {
            "datetime": dt.datetime(2012, 1, 1),
            "date": dt.datetime(2012, 6, 1),
            "startDate": dt.datetime(2010, 1, 1),
            "endDate": dt.datetime(2030, 1, 1),
            "dateA": dt.datetime(2011, 1, 1),
            "dateB": dt.datetime(2013, 1, 1),
            "country": "China",
            "country1": "China",
            "country2": "India",
            "tagClass": "Thing",
            "tag": "music",
            "languages": ["en"],
            "lengthThreshold": 100,
            "personId": 4398046511333,
            "person1Id": 4398046511333,
            "person2Id": 21990232557716,
            "city1Id": 669,
            "city2Id": 648,
            "minPathDistance": 1,
            "maxPathDistance": 3,
            "maxKnowsLimit": 10,
            "tagA": "music",
            "tagB": "sports",
            "delta": 1,
            "company": "Falcon_Air",
        }
    if workload_name == "finbench-sf1":
        now = dt.datetime(2020, 1, 1)
        return {
            "id": 4750735206678266224,
            "id1": 4750735206678266224,
            "id2": 4751298156630269469,
            "personId": 33065,
            "personName": "Verify Person",
            "companyId": 0,
            "companyName": "Verify Company",
            "accountId": 0,
            "accountBlocked": False,
            "accountType": "card",
            "srcId": 4750735206678266224,
            "dstId": 4751298156630269469,
            "mediumId": 0,
            "mediumBlocked": False,
            "loanId": 0,
            "pid1": 33065,
            "pid2": 20022,
            "currentTime": now,
            "amount": 1.0,
            "amt": 1.0,
            "threshold": 0.0,
            "threshold1": 0.0,
            "threshold2": 0.0,
            "lowerbound": 0.0,
            "upperbound": 1_000_000_000.0,
            "start_time": now,
            "end_time": dt.datetime(2030, 1, 1),
        }
    return {}


def parse_typed_pipe_row(header: list[str], data_row: list[str]) -> tuple[dict[str, object], dict[str, object]]:
    params: dict[str, object] = {}
    display: dict[str, object] = {}
    for spec, value in zip(header, data_row):
        if ":" in spec:
            name, type_name = spec.split(":", 1)
        else:
            name, type_name = spec, None
        key = name.strip()
        kind = type_name.strip() if type_name else None
        params[key] = coerce_value(value, kind, key)
        display[key] = display_value(value, kind)
    return params, display


def parse_typed_pipe_params(path: Path, row_number: int) -> tuple[dict[str, object], dict[str, object]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.reader(handle, delimiter="|")
        header = next(reader)
        data_row = None
        for idx, row in enumerate(reader, start=1):
            if idx == row_number:
                data_row = row
                break
    if data_row is None:
        raise ValueError(f"parameter row {row_number} not found in {path}")
    return parse_typed_pipe_row(header, data_row)


def parse_ic_row(header: list[str], data_row: list[str]) -> tuple[dict[str, object], dict[str, object]]:
    raw = {name: value for name, value in zip(header, data_row)}
    params = {name: coerce_value(value, key=name) for name, value in raw.items() if name != "durationDays"}
    display = {name: display_value(value) for name, value in raw.items() if name != "durationDays"}
    if "startDate" in raw and "durationDays" in raw:
        end_millis = int(raw["startDate"]) + int(raw["durationDays"]) * 24 * 60 * 60 * 1000
        params["endDate"] = epoch_millis_to_datetime(end_millis)
        display["endDate"] = end_millis
    return params, display


def parse_ic_params(path: Path, row_number: int) -> tuple[dict[str, object], dict[str, object]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.reader(handle, delimiter="|")
        header = next(reader)
        data_row = None
        for idx, row in enumerate(reader, start=1):
            if idx == row_number:
                data_row = row
                break
    if data_row is None:
        raise ValueError(f"parameter row {row_number} not found in {path}")
    return parse_ic_row(header, data_row)


FINBENCH_PARAM_COLUMNS = {
    1: ["id", "start_time", "end_time", "_limit", "_order"],
    2: ["id", "start_time", "end_time", "_limit", "_order"],
    3: ["id1", "id2", "start_time", "end_time"],
    4: ["id1", "id2", "start_time", "end_time"],
    5: ["id", "start_time", "end_time", "_limit", "_order"],
    6: ["id", "threshold1", "threshold2", "start_time", "end_time", "_limit", "_order"],
    7: ["id", "threshold", "start_time", "end_time", "_limit", "_order"],
    8: ["id", "threshold", "start_time", "end_time", "_limit", "_order"],
    9: ["id", "threshold", "start_time", "end_time", "_limit", "_order"],
    10: ["id1", "id2", "start_time", "end_time"],
    11: ["id", "start_time", "end_time", "_limit", "_order"],
    12: ["id", "start_time", "end_time", "_limit", "_order"],
}


def parse_finbench_row(query_number: int, data_row: list[str]) -> tuple[dict[str, object], dict[str, object]]:
    columns = FINBENCH_PARAM_COLUMNS.get(query_number)
    if columns is None:
        raise ValueError(f"no FinBench parameter mapping for query {query_number}")
    params: dict[str, object] = {}
    display: dict[str, object] = {}
    for name, value in zip(columns, data_row):
        if name.startswith("_"):
            continue
        params[name] = coerce_value(value, key=name)
        display[name] = display_value(value)
    if query_number == 9:
        params.setdefault("lowerbound", 0.0)
        params.setdefault("upperbound", 1_000_000_000.0)
        display.setdefault("lowerbound", 0.0)
        display.setdefault("upperbound", 1_000_000_000.0)
    return params, display


def parse_finbench_params(path: Path, query_number: int, row_number: int) -> tuple[dict[str, object], dict[str, object]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.reader(handle, delimiter="|")
        rows_seen = 0
        data_row = None
        for row in reader:
            if not row or row[0] == "...":
                continue
            rows_seen += 1
            if rows_seen == row_number:
                data_row = row
                break
    if data_row is None:
        raise ValueError(f"parameter row {row_number} not found in {path}")
    return parse_finbench_row(query_number, data_row)


def query_number_from_rel(workload: Workload, rel: str) -> int | None:
    if workload.name == "ic-sf1":
        match = re.match(r"ic(\d+)/", rel)
    elif workload.name == "bi-sf1":
        match = re.match(r"bi(\d+)/", rel)
    elif workload.name == "finbench-sf1":
        match = re.match(r"(?:tcr|tsr)-(\d+)\.cypher$", rel)
    else:
        match = None
    return int(match.group(1)) if match else None


def parameter_file_from_dir(workload: Workload, rel: str, params_dir: Path) -> Path | None:
    number = query_number_from_rel(workload, rel)
    if number is None:
        return None
    if workload.name == "ic-sf1":
        candidate = params_dir / f"interactive_{number}_param.txt"
        return candidate if candidate.exists() else None
    if workload.name == "bi-sf1":
        specific = {
            2: "bi-2a.csv",
            8: "bi-8a.csv",
            10: "bi-10a.csv",
            14: "bi-14a.csv",
            15: "bi-15a-without-date.csv" if rel.startswith("bi15/") or "without-date" in rel else "bi-15a.csv",
            16: "bi-16a.csv",
            19: "bi-19a.csv",
            20: "bi-20a.csv",
        }
        candidate = params_dir / specific.get(number, f"bi-{number}.csv")
        return candidate if candidate.exists() else None
    if workload.name == "finbench-sf1" and rel.startswith("tcr-"):
        candidate = params_dir / f"complex_{number}_param.csv"
        return candidate if candidate.exists() else None
    return None


def resolve_sampled_params_dir(workload: Workload, sampled_params_dir: Path | None) -> Path | None:
    if workload.name not in DEFAULT_SAMPLED_PARAM_DIRS:
        return None
    if sampled_params_dir is None:
        return DEFAULT_SAMPLED_PARAM_DIRS[workload.name]
    subdir = SAMPLED_PARAM_SUBDIRS.get(workload.name)
    if subdir is not None and (sampled_params_dir / subdir).exists():
        return sampled_params_dir / subdir
    return sampled_params_dir


def sampled_parameter_file_from_dir(workload: Workload, rel: str, sampled_params_dir: Path) -> Path | None:
    number = query_number_from_rel(workload, rel)
    if number is None:
        return None
    if workload.name == "ic-sf1":
        candidate = sampled_params_dir / f"ic{number}.txt"
        return candidate if candidate.exists() else None
    if workload.name == "bi-sf1":
        suffix = "-without-date" if rel.startswith("bi15/") or "without-date" in rel else ""
        candidate = sampled_params_dir / f"bi{number}{suffix}.txt"
        return candidate if candidate.exists() else None
    if workload.name == "finbench-sf1" and rel.startswith("tcr-"):
        candidate = sampled_params_dir / f"complex{number}.txt"
        return candidate if candidate.exists() else None
    return None


def sampled_rows_for_round(path: Path, round_number: int) -> list[str]:
    rows: list[str] = []
    active = False
    saw_round_marker = False
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        text = line.strip()
        if not text:
            continue
        match = re.fullmatch(r"--round\s+(\d+)--", text)
        if match:
            saw_round_marker = True
            active = int(match.group(1)) == round_number
            continue
        if saw_round_marker:
            if active:
                rows.append(line)
        elif round_number == 1 and text != "...":
            rows.append(line)
    if not rows:
        raise ValueError(f"round {round_number} not found or empty in {path}")
    return rows


def original_parameter_header(workload: Workload, rel: str) -> list[str]:
    directory = DEFAULT_PARAM_DIRS.get(workload.name)
    if directory is None:
        raise ValueError(f"no default parameter directory for {workload.name}")
    path = parameter_file_from_dir(workload, rel, directory)
    if path is None:
        raise ValueError(f"cannot find original parameter header for {workload.name} {rel}")
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return next(csv.reader(handle, delimiter="|"))


def sampled_row(path: Path, round_number: int, row_number: int) -> list[str]:
    rows = sampled_rows_for_round(path, round_number)
    if row_number < 1 or row_number > len(rows):
        raise ValueError(f"parameter row {row_number} not found in round {round_number} of {path}")
    return next(csv.reader([rows[row_number - 1]], delimiter="|"))


def sampled_param_count_for_query(workload: Workload, rel: str, sampled_params_dir: Path | None, sample_round: int) -> int | None:
    sampled_dir = resolve_sampled_params_dir(workload, sampled_params_dir)
    if sampled_dir is None or not sampled_dir.exists():
        return None
    sampled_file = sampled_parameter_file_from_dir(workload, rel, sampled_dir)
    if sampled_file is None:
        return None
    return len(sampled_rows_for_round(sampled_file, sample_round))


def sampled_params_from_file(
    workload: Workload,
    rel: str,
    path: Path,
    round_number: int,
    row_number: int,
) -> tuple[dict[str, object], dict[str, object]]:
    number = query_number_from_rel(workload, rel)
    data_row = sampled_row(path, round_number, row_number)
    if workload.name == "ic-sf1":
        params, display = parse_ic_row(original_parameter_header(workload, rel), data_row)
    elif workload.name == "bi-sf1":
        params, display = parse_typed_pipe_row(original_parameter_header(workload, rel), data_row)
    elif workload.name == "finbench-sf1":
        if number is None:
            raise ValueError(f"cannot infer FinBench query number from {rel}")
        params, display = parse_finbench_row(number, data_row)
    else:
        params, display = {}, {}
    display = {"_sampled_file": str(path), "_sample_round": round_number, **display}
    return params, display


def params_from_file(workload: Workload, rel: str, path: Path, row_number: int) -> tuple[dict[str, object], dict[str, object]]:
    number = query_number_from_rel(workload, rel)
    if workload.name == "ic-sf1":
        return parse_ic_params(path, row_number)
    if workload.name == "bi-sf1":
        return parse_typed_pipe_params(path, row_number)
    if workload.name == "finbench-sf1":
        if number is None:
            raise ValueError(f"cannot infer FinBench query number from {rel}")
        return parse_finbench_params(path, number, row_number)
    return {}, {}


def resolve_params_file_arg(path: Path) -> Path:
    if path.exists():
        return path
    match = re.fullmatch(r"bi(\d+)([ab])?(\-without-date)?\.csv", path.name)
    if match:
        number, suffix, without_date = match.groups()
        candidate = path.with_name(f"bi-{number}{suffix or ''}{without_date or ''}.csv")
        if candidate.exists():
            return candidate
    return path


def params_used_by(query: str, params: dict[str, object]) -> dict[str, object]:
    names = set(re.findall(r"\$([A-Za-z_][A-Za-z0-9_]*)", query))
    return {key: value for key, value in params.items() if key in names}


def choose_params(
    workload: Workload,
    rel: str,
    query: str,
    params_file: Path | None,
    params_dir: Path | None,
    sampled_params_dir: Path | None,
    sample_round: int,
    row_number: int,
) -> tuple[dict[str, object], dict[str, object]]:
    if params_file is not None:
        params, display = params_from_file(workload, rel, params_file, row_number)
    else:
        if params_dir is None:
            sampled_dir = resolve_sampled_params_dir(workload, sampled_params_dir)
            if sampled_dir is not None and sampled_dir.exists():
                sampled_file = sampled_parameter_file_from_dir(workload, rel, sampled_dir)
                if sampled_file is not None:
                    params, display = sampled_params_from_file(workload, rel, sampled_file, sample_round, row_number)
                    return params_used_by(query, params), params_used_by(query, display)
        directory = params_dir or DEFAULT_PARAM_DIRS.get(workload.name)
        auto_file = parameter_file_from_dir(workload, rel, directory) if directory and directory.exists() else None
        if auto_file is not None:
            params, display = params_from_file(workload, rel, auto_file, row_number)
        else:
            params = default_params_for(workload.name)
            display = dict(params)
    return params_used_by(query, params), params_used_by(query, display)


def rel_path(workload: Workload, path: Path) -> str:
    if workload.query_dir is None:
        return str(path)
    try:
        return str(path.relative_to(workload.query_dir))
    except ValueError:
        return str(path)


def make_runnable(workload: Workload, query: str, mode: str, rel: str, allow_writes: bool) -> tuple[str, str, bool]:
    write_query = is_write_query(workload, rel, query)
    if workload.name == "graphdblp":
        if mode == "execute":
            raise ValueError("graphdblp execution is intentionally disabled; use --mode explain")
        return "EXPLAIN " + query, "EXPLAIN_ONLY", True
    if mode == "explain" or (write_query and not allow_writes):
        return "EXPLAIN " + query, "EXPLAIN_ONLY", not write_query
    return query, "EXECUTE", not allow_writes


def json_safe(value: object) -> object:
    if isinstance(value, (dt.datetime, dt.date)):
        return value.isoformat()
    if isinstance(value, dict):
        return {str(key): json_safe(item) for key, item in value.items()}
    if isinstance(value, (list, tuple)):
        return [json_safe(item) for item in value]
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="replace")
    try:
        json.dumps(value)
        return value
    except TypeError:
        return str(value)


def materialize_kuzu_result(raw_result: object, fetch_rows: int) -> tuple[list[object], object]:
    result = raw_result[-1] if isinstance(raw_result, list) else raw_result
    columns = list(result.get_column_names())
    rows = []
    while result.has_next() and (fetch_rows == 0 or len(rows) < fetch_rows):
        row = result.get_next()
        if isinstance(row, dict):
            rows.append(json_safe(row))
        elif columns:
            rows.append({column: json_safe(value) for column, value in zip(columns, row)})
        else:
            rows.append({"row": json_safe(row)})
    return rows, result


def _child_run(db_dir: str, query: str, params: dict[str, Any], threads: int, read_only: bool, fetch_rows: int, queue: mp.Queue) -> None:
    try:
        import kuzu

        db = kuzu.Database(db_dir, read_only=read_only)
        conn = kuzu.Connection(db, num_threads=threads)
        raw_result = conn.execute(query, params)
        rows, result = materialize_kuzu_result(raw_result, fetch_rows)
        queue.put(
            {
                "status": "OK",
                "rows": rows,
                "compile_ms": result.get_compiling_time(),
                "execute_ms": result.get_execution_time(),
            }
        )
    except Exception as exc:
        queue.put({"status": "FAIL", "error": f"{type(exc).__name__}: {exc}"})


def run_setup_query(
    workload: Workload,
    setup_path: Path,
    timeout: int | None,
) -> dict[str, Any]:
    query = strip_query(setup_path.read_text(encoding="utf-8"))
    rel = rel_path(workload, setup_path)
    if not query:
        return {"query": rel, "status": "SKIP", "reason": "empty query"}

    queue: mp.Queue = mp.Queue(maxsize=1)
    process = mp.Process(
        target=_child_run,
        args=(str(workload.db_dir), query, {}, workload.threads, False, 0, queue),
    )
    start = time.monotonic()
    process.start()
    process.join(timeout)
    elapsed = round(time.monotonic() - start, 6)
    if timeout is not None and process.is_alive():
        process.terminate()
        process.join(10)
        if process.is_alive():
            process.kill()
            process.join(10)
        return {
            "query": rel,
            "status": "TIMEOUT",
            "seconds": timeout,
            "mode": "SETUP",
            "error": "setup query timeout",
        }
    if queue.empty():
        return {
            "query": rel,
            "status": "ERROR",
            "seconds": elapsed,
            "mode": "SETUP",
            "error": f"setup child exited with code {process.exitcode}",
        }
    payload = queue.get()
    payload.update({"query": rel, "seconds": elapsed, "mode": "SETUP"})
    return payload


def run_setup_query_persistent(conn: object, workload: Workload, setup_path: Path, fetch_rows: int) -> dict[str, Any]:
    query = strip_query(setup_path.read_text(encoding="utf-8"))
    rel = rel_path(workload, setup_path)
    if not query:
        return {"query": rel, "status": "SKIP", "reason": "empty query"}
    start = time.monotonic()
    try:
        raw_result = conn.execute(query, {})
        rows, result = materialize_kuzu_result(raw_result, fetch_rows)
        elapsed = round(time.monotonic() - start, 6)
        return {
            "query": rel,
            "status": "OK",
            "rows": rows,
            "seconds": elapsed,
            "mode": "SETUP",
            "compile_ms": result.get_compiling_time(),
            "execute_ms": result.get_execution_time(),
        }
    except Exception as exc:
        elapsed = round(time.monotonic() - start, 6)
        return {
            "query": rel,
            "status": "FAIL",
            "seconds": elapsed,
            "mode": "SETUP",
            "error": f"{type(exc).__name__}: {exc}",
        }


def add_setup_seconds(result: dict[str, Any], setup_seconds: float) -> None:
    result["setup_seconds"] = setup_seconds
    seconds = result.get("seconds")
    if result.get("status") == "OK" and isinstance(seconds, int | float):
        result["query_seconds"] = seconds
        result["seconds"] = round(float(seconds) + setup_seconds, 6)


def run_query(
    workload: Workload,
    path: Path,
    mode: str,
    allow_writes: bool,
    timeout: int | None,
    fetch_rows: int,
    params_file: Path | None,
    params_dir: Path | None,
    sampled_params_dir: Path | None,
    sample_round: int,
    param_row: int,
) -> dict[str, Any]:
    query = strip_query(path.read_text(encoding="utf-8"))
    rel = rel_path(workload, path)
    if not query:
        return {"query": rel, "param_row": param_row, "status": "SKIP", "reason": "empty query"}
    try:
        params, display_params = choose_params(workload, rel, query, params_file, params_dir, sampled_params_dir, sample_round, param_row)
        runnable, run_mode, read_only = make_runnable(workload, query, mode, rel, allow_writes)
    except Exception as exc:
        return {"query": rel, "param_row": param_row, "status": "FAIL", "error": f"{type(exc).__name__}: {exc}"}

    queue: mp.Queue = mp.Queue(maxsize=1)
    process = mp.Process(
        target=_child_run,
        args=(str(workload.db_dir), runnable, params, workload.threads, read_only, fetch_rows, queue),
    )
    start = time.monotonic()
    process.start()
    process.join(timeout)
    elapsed = round(time.monotonic() - start, 6)
    if timeout is not None and process.is_alive():
        process.terminate()
        process.join(10)
        if process.is_alive():
            process.kill()
            process.join(10)
        return {
            "query": rel,
            "param_row": param_row,
            "display_params": display_params,
            "status": "TIMEOUT",
            "seconds": timeout,
            "mode": run_mode,
        }
    if queue.empty():
        return {
            "query": rel,
            "param_row": param_row,
            "display_params": display_params,
            "status": "ERROR",
            "seconds": elapsed,
            "mode": run_mode,
            "error": f"child exited with code {process.exitcode}",
        }
    payload = queue.get()
    payload.update(
        {
            "query": rel,
            "param_row": param_row,
            "display_params": display_params,
            "seconds": elapsed,
            "mode": run_mode,
        }
    )
    return payload


def run_query_persistent(
    conn: object,
    workload: Workload,
    path: Path,
    mode: str,
    allow_writes: bool,
    fetch_rows: int,
    params_file: Path | None,
    params_dir: Path | None,
    sampled_params_dir: Path | None,
    sample_round: int,
    param_row: int,
) -> dict[str, Any]:
    query = strip_query(path.read_text(encoding="utf-8"))
    rel = rel_path(workload, path)
    if not query:
        return {"query": rel, "param_row": param_row, "status": "SKIP", "reason": "empty query"}
    try:
        params, display_params = choose_params(workload, rel, query, params_file, params_dir, sampled_params_dir, sample_round, param_row)
        runnable, run_mode, _read_only = make_runnable(workload, query, mode, rel, allow_writes)
    except Exception as exc:
        return {"query": rel, "param_row": param_row, "status": "FAIL", "error": f"{type(exc).__name__}: {exc}"}
    start = time.monotonic()
    try:
        raw_result = conn.execute(runnable, params)
        rows, result = materialize_kuzu_result(raw_result, fetch_rows)
        elapsed = round(time.monotonic() - start, 6)
        return {
            "query": rel,
            "param_row": param_row,
            "display_params": display_params,
            "status": "OK",
            "rows": rows,
            "seconds": elapsed,
            "mode": run_mode,
            "compile_ms": result.get_compiling_time(),
            "execute_ms": result.get_execution_time(),
        }
    except Exception as exc:
        elapsed = round(time.monotonic() - start, 6)
        return {
            "query": rel,
            "param_row": param_row,
            "display_params": display_params,
            "status": "FAIL",
            "seconds": elapsed,
            "mode": run_mode,
            "error": f"{type(exc).__name__}: {exc}",
        }


def csv_query_name(query: str) -> str:
    parts = Path(query).parts
    if len(parts) >= 2 and re.fullmatch(r"(?:ic|bi)\d+", parts[0]):
        return parts[0]
    if len(parts) >= 2 and re.fullmatch(r"q\d+", parts[0]):
        return parts[0]
    name = Path(query).name
    return name[:-7] if name.endswith(".cypher") else query


def parse_sample_rounds(text: str | None, fallback_round: int) -> list[int]:
    if text is None or text.strip() == "":
        return [fallback_round]
    rounds: list[int] = []
    for part in text.split(","):
        token = part.strip()
        if not token:
            continue
        if "-" in token:
            start_text, end_text = token.split("-", 1)
            start = int(start_text)
            end = int(end_text)
            if start > end:
                raise ValueError(f"invalid round range: {token}")
            rounds.extend(range(start, end + 1))
        else:
            rounds.append(int(token))
    if not rounds:
        raise ValueError("--sample-rounds did not contain any round number")
    if any(round_number < 1 for round_number in rounds):
        raise ValueError("sample rounds must be >= 1")
    return list(dict.fromkeys(rounds))


def mean(values: list[float]) -> float:
    return sum(values) / len(values)


def default_summary_path(out: Path) -> Path:
    suffix = out.suffix or ".csv"
    if out.stem.endswith("-results"):
        return out.with_name(f"{out.stem.removesuffix('-results')}-summary{suffix}")
    return out.with_name(f"{out.stem}-summary{suffix}")


def default_wide_summary_path(summary_out: Path) -> Path:
    suffix = summary_out.suffix or ".csv"
    if summary_out.stem.endswith("-summary"):
        return summary_out.with_name(f"{summary_out.stem.removesuffix('-summary')}-summary-wide{suffix}")
    return summary_out.with_name(f"{summary_out.stem}-wide{suffix}")


def default_results_path(work_dir: Path, workload_name: str, mode: str, run_timestamp: str) -> Path:
    return work_dir / workload_name / f"{mode}-{run_timestamp}-results.csv"


def result_cell(result: dict[str, Any]) -> str:
    status = result.get("status", "")
    if status == "OK":
        return json.dumps(result.get("rows", []), ensure_ascii=False)
    if status == "SKIP":
        return json.dumps([{"status": "SKIP", "message": result.get("reason", "")}], ensure_ascii=False)
    if status == "TIMEOUT":
        return json.dumps([{"status": "TIMEOUT", "message": "query timeout"}], ensure_ascii=False)
    return json.dumps([{"status": status, "message": result.get("error", "")}], ensure_ascii=False)


def write_csv_results(path: Path, results: list[dict[str, Any]]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "query",
                "sample_round",
                "phase",
                "iteration",
                "parameter_index",
                "parameters",
                "results",
                "time_seconds",
                "setup_time_seconds",
            ],
            quotechar="'",
            doublequote=False,
            escapechar="\\",
        )
        writer.writeheader()
        for result in results:
            writer.writerow(
                {
                    "query": csv_query_name(result.get("query", "")),
                    "sample_round": result.get("sample_round", ""),
                    "phase": result.get("phase", ""),
                    "iteration": result.get("iteration", ""),
                    "parameter_index": result.get("param_row", ""),
                    "parameters": json.dumps(json_safe(result.get("display_params", {})), ensure_ascii=False),
                    "results": result_cell(result),
                    "time_seconds": result.get("seconds", ""),
                    "setup_time_seconds": result.get("setup_seconds", ""),
                }
            )


def build_summary_rows(results: list[dict[str, Any]]) -> list[dict[str, Any]]:
    iteration_groups: dict[tuple[str, int, int], list[float]] = {}
    iteration_param_counts: dict[tuple[str, int, int], int] = {}
    for result in results:
        if result.get("status") != "OK" or result.get("phase") != "performance":
            continue
        seconds = result.get("seconds")
        if not isinstance(seconds, int | float):
            continue
        key = (
            csv_query_name(result.get("query", "")),
            int(result.get("sample_round", 1)),
            int(result.get("iteration", 1)),
        )
        iteration_groups.setdefault(key, []).append(float(seconds))
        iteration_param_counts[key] = iteration_param_counts.get(key, 0) + 1

    round_groups: dict[tuple[str, int], list[float]] = {}
    round_param_counts: dict[tuple[str, int], int] = {}
    for (query, sample_round, iteration), values in sorted(iteration_groups.items()):
        avg = mean(values)
        round_groups.setdefault((query, sample_round), []).append(avg)
        round_param_counts[(query, sample_round)] = max(
            round_param_counts.get((query, sample_round), 0),
            iteration_param_counts[(query, sample_round, iteration)],
        )

    rows = []
    for (query, sample_round), values in sorted(round_groups.items()):
        rows.append(
            {
                "query": query,
                "sample_round": sample_round,
                "performance_iterations": len(values),
                "param_count": round_param_counts.get((query, sample_round), ""),
                "avg_time_seconds": round(mean(values), 6),
            }
        )
    return rows


def write_summary_results(path: Path, rows: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["query", "sample_round", "performance_iterations", "param_count", "avg_time_seconds"],
            delimiter="|",
        )
        writer.writeheader()
        writer.writerows(rows)


def build_wide_summary_rows(rows: list[dict[str, Any]]) -> tuple[list[str], list[dict[str, Any]]]:
    rounds = sorted({int(row["sample_round"]) for row in rows})
    fieldnames = ["query", *[f"t{round_number}" for round_number in rounds]]
    grouped: dict[str, dict[str, Any]] = {}
    for row in rows:
        query = str(row["query"])
        grouped.setdefault(query, {"query": query})
        grouped[query][f"t{int(row['sample_round'])}"] = row["avg_time_seconds"]
    return fieldnames, [grouped[query] for query in sorted(grouped)]


def write_wide_summary_results(path: Path, fieldnames: list[str], rows: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter="|")
        writer.writeheader()
        writer.writerows(rows)


def print_wide_summary(fieldnames: list[str], rows: list[dict[str, Any]]) -> None:
    if not rows:
        return
    widths = {
        field: max(len(field), *(len(str(row.get(field, ""))) for row in rows))
        for field in fieldnames
    }
    print("wide summary:")
    print(" ".join(field.ljust(widths[field]) for field in fieldnames))
    for row in rows:
        print(" ".join(str(row.get(field, "")).ljust(widths[field]) for field in fieldnames))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--workload", choices=sorted(WORKLOADS), required=True)
    parser.add_argument("--mode", choices=["explain", "execute"], default=None)
    parser.add_argument("--runner", choices=["isolated", "persistent"], default="isolated", help="isolated runs each parameter in a child process; persistent opens one Kuzu connection and reuses it")
    parser.add_argument("--timeout", type=int, default=None, help="optional per-query timeout in seconds; omitted means no query timeout")
    parser.add_argument("--work-dir", type=Path, default=DEFAULT_RESULTS_ROOT)
    parser.add_argument("--out", type=Path, default=None)
    parser.add_argument("--include-setup", action="store_true", help="include setup/drop Cypher files normally skipped")
    parser.add_argument("--allow-writes", action="store_true", help="execute write queries instead of EXPLAIN")
    parser.add_argument("--query", default=None, help="run exactly one query file; accepts a relative path, absolute path, or unique file name")
    parser.add_argument("--queries", default=None, help="run multiple query files, comma-separated; each item uses the same syntax as --query")
    parser.add_argument("--params-file", type=Path, default=None, help="read parameters for every selected query from this file")
    parser.add_argument("--params-dir", type=Path, default=None, help="read per-query parameter files from this directory")
    parser.add_argument("--sampled-params-dir", type=Path, default=None, help="read sampled round parameter files from this directory or from /mnt/data/sampled_parameters by default")
    parser.add_argument("--sample-round", type=int, default=1, help="1-based round number to read from sampled parameter files")
    parser.add_argument("--sample-rounds", default=None, help="sampled rounds to run, for example 3, 1,3,5, or 1-3; defaults to --sample-round")
    parser.add_argument("--param-row", type=int, default=1, help="1-based first data row to read from a parameter file")
    parser.add_argument("--param-count", type=int, default=None, help="number of consecutive parameter rows to run; defaults to all rows in a sampled round, or 1 for legacy parameter files")
    parser.add_argument("--warmup", action="store_true", help="run one warmup iteration before performance runs; use --warmup-count to set the exact count")
    parser.add_argument("--warmup-count", type=int, default=None, help="number of warmup iterations to run before measured performance iterations")
    parser.add_argument("--performance-count", type=int, default=1, help="number of measured performance iterations to run")
    parser.add_argument("--limit", type=int, default=0, help="run only the first N selected query files")
    parser.add_argument("--start-at", type=int, default=1, help="1-based index into the selected query list")
    parser.add_argument("--fetch-rows", type=int, default=0, help="maximum rows to materialize in the CSV results field; 0 means all rows")
    args = parser.parse_args()

    workload = WORKLOADS[args.workload]
    mode = args.mode or workload.default_mode
    if not workload.configured:
        print(f"workload is not configured: {workload.description}", file=sys.stderr)
        return 2
    if mode == "execute" and not workload.supports_execute:
        print(f"{workload.name} does not support execute mode in this runner", file=sys.stderr)
        return 2
    if args.param_row < 1:
        print("--param-row must be >= 1", file=sys.stderr)
        return 2
    if args.param_count is not None and args.param_count < 1:
        print("--param-count must be >= 1", file=sys.stderr)
        return 2
    if args.sample_round < 1:
        print("--sample-round must be >= 1", file=sys.stderr)
        return 2
    try:
        sample_rounds = parse_sample_rounds(args.sample_rounds, args.sample_round)
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 2
    sampled_round_requested = args.sample_rounds is not None or args.sample_round != 1 or args.sampled_params_dir is not None
    warmup_count = args.warmup_count if args.warmup_count is not None else (1 if (args.runner == "persistent" or args.warmup or sampled_round_requested) else 0)
    if warmup_count < 0:
        print("--warmup-count must be >= 0", file=sys.stderr)
        return 2
    if args.performance_count < 1:
        print("--performance-count must be >= 1", file=sys.stderr)
        return 2
    if args.fetch_rows < 0:
        print("--fetch-rows must be >= 0", file=sys.stderr)
        return 2
    if args.runner == "persistent" and args.timeout is not None:
        print("--timeout is only supported by --runner isolated; ignoring it for persistent benchmark timing", file=sys.stderr)
    if args.params_file is not None:
        args.params_file = resolve_params_file_arg(args.params_file)
    if args.params_file is not None and not args.params_file.exists():
        print(f"--params-file does not exist: {args.params_file}", file=sys.stderr)
        return 2
    if args.params_dir is not None and not args.params_dir.exists():
        print(f"--params-dir does not exist: {args.params_dir}", file=sys.stderr)
        return 2
    if args.sampled_params_dir is not None and not args.sampled_params_dir.exists():
        print(f"--sampled-params-dir does not exist: {args.sampled_params_dir}", file=sys.stderr)
        return 2
    if not workload.db_dir.exists():
        print(f"database directory does not exist: {workload.db_dir}", file=sys.stderr)
        return 2
    if workload.query_dir is None or not workload.query_dir.exists():
        print(f"query directory does not exist: {workload.query_dir}", file=sys.stderr)
        return 2

    try:
        if args.query and args.queries:
            print("use either --query or --queries, not both", file=sys.stderr)
            return 2
        if args.queries:
            query_names = [item.strip() for item in args.queries.split(",") if item.strip()]
            if not query_names:
                print("--queries did not contain any query name", file=sys.stderr)
                return 2
            queries = [resolve_one_query(workload, query_name) for query_name in query_names]
            start_index = 1
        elif args.query:
            queries = [resolve_one_query(workload, args.query)]
            start_index = 1
        else:
            if args.start_at < 1:
                print("--start-at must be >= 1", file=sys.stderr)
                return 2
            queries = queries_for(workload, args.include_setup)
            start_index = args.start_at
            queries = queries[args.start_at - 1 :]
            if args.limit:
                queries = queries[: args.limit]
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 2

    run_timestamp = dt.datetime.now().strftime(RUN_TIMESTAMP_FORMAT)
    out = args.out or default_results_path(args.work_dir, workload.name, mode, run_timestamp)
    args.work_dir.mkdir(parents=True, exist_ok=True)
    out.parent.mkdir(parents=True, exist_ok=True)

    results: list[dict[str, Any]] = []
    print(
        f"== running {workload.name}: {len(queries)} query files x rounds {sample_rounds} "
        f"x {warmup_count} warmup + {args.performance_count} performance iteration(s) "
        f"in {mode} mode with {args.runner} runner, threads={workload.threads} ==",
        flush=True,
    )
    persistent_db = None
    persistent_conn = None
    try:
        if args.runner == "persistent":
            import kuzu

            opens_for_setup = any(setup_query_path(workload, query_path) is not None for query_path in queries) if mode == "execute" else False
            persistent_db = kuzu.Database(str(workload.db_dir), read_only=not (args.allow_writes or opens_for_setup))
            persistent_conn = kuzu.Connection(persistent_db, num_threads=workload.threads)
        for idx, query_path in enumerate(queries, start_index):
            rel = rel_path(workload, query_path)
            print(f"[{idx}] {rel}", flush=True)
            setup_seconds = 0.0
            setup_path = setup_query_path(workload, query_path) if mode == "execute" else None
            needs_setup = setup_path is not None
            if needs_setup:
                if not setup_path.exists():
                    results.append(
                        {
                            "query": rel,
                            "status": "FAIL",
                            "error": f"setup file not found: {setup_path}",
                        }
                    )
                    print(f"  setup FAIL missing {setup_path}", flush=True)
                    continue
                if args.runner == "persistent":
                    assert persistent_conn is not None
                    setup_result = run_setup_query_persistent(persistent_conn, workload, setup_path, args.fetch_rows)
                else:
                    setup_result = run_setup_query(workload, setup_path, args.timeout)
                setup_result["phase"] = "setup"
                results.append(setup_result)
                if setup_result.get("status") != "OK":
                    print(
                        f"  setup {setup_result['status']} {setup_result.get('seconds', '')} "
                        f"{setup_result.get('error', '')}",
                        flush=True,
                    )
                    continue
                setup_seconds = float(setup_result.get("seconds", 0.0))
                print(f"  setup OK {setup_seconds:.6f}s", flush=True)
            phases = [("warmup", warmup_count), ("performance", args.performance_count)]
            for sample_round in sample_rounds:
                sampled_count = None
                if args.params_file is None and args.params_dir is None:
                    try:
                        sampled_count = sampled_param_count_for_query(workload, rel, args.sampled_params_dir, sample_round)
                    except Exception as exc:
                        results.append(
                            {
                                "query": rel,
                                "sample_round": sample_round,
                                "status": "FAIL",
                                "error": f"sampled parameter error: {type(exc).__name__}: {exc}",
                            }
                        )
                        print(f"  round={sample_round} FAIL sampled parameter error: {exc}", flush=True)
                        continue
                if args.param_count is None:
                    row_count = sampled_count - args.param_row + 1 if sampled_count is not None else 1
                else:
                    row_count = args.param_count
                if row_count < 1:
                    results.append(
                        {
                            "query": rel,
                            "sample_round": sample_round,
                            "status": "FAIL",
                            "error": f"no parameter rows selected for round {sample_round}",
                        }
                    )
                    print(f"  round={sample_round} FAIL no parameter rows selected", flush=True)
                    continue
                print(f"  round={sample_round} params={row_count}", flush=True)
                round_iteration_averages: list[float] = []
                for phase, iteration_count in phases:
                    for iteration in range(1, iteration_count + 1):
                        iteration_seconds: list[float] = []
                        for param_row in range(args.param_row, args.param_row + row_count):
                            if args.runner == "persistent":
                                assert persistent_conn is not None
                                result = run_query_persistent(
                                    persistent_conn,
                                    workload,
                                    query_path,
                                    mode,
                                    args.allow_writes,
                                    args.fetch_rows,
                                    args.params_file,
                                    args.params_dir,
                                    args.sampled_params_dir,
                                    sample_round,
                                    param_row,
                                )
                            else:
                                result = run_query(
                                    workload,
                                    query_path,
                                    mode,
                                    args.allow_writes,
                                    args.timeout,
                                    args.fetch_rows,
                                    args.params_file,
                                    args.params_dir,
                                    args.sampled_params_dir,
                                    sample_round,
                                    param_row,
                                )
                            result["sample_round"] = sample_round
                            result["phase"] = phase
                            result["iteration"] = iteration
                            if needs_setup:
                                add_setup_seconds(result, setup_seconds)
                            if result.get("status") == "OK" and isinstance(result.get("seconds"), int | float):
                                iteration_seconds.append(float(result["seconds"]))
                            print(
                                f"    {phase}#{iteration} round={sample_round} row={param_row} "
                                f"{result['status']} {result.get('seconds', '')} {result.get('mode', '')}"
                                f"{' setup=' + format(setup_seconds, '.6f') if needs_setup else ''}",
                                flush=True,
                            )
                            results.append(result)
                        if phase == "performance" and iteration_seconds:
                            iteration_average = mean(iteration_seconds)
                            round_iteration_averages.append(iteration_average)
                            print(
                                f"    performance#{iteration} round={sample_round} avg = {iteration_average:.6f}s",
                                flush=True,
                            )
                if round_iteration_averages:
                    print(
                        f"  round={sample_round} avg = {mean(round_iteration_averages):.6f}s "
                        f"from {len(round_iteration_averages)} performance iteration(s)",
                        flush=True,
                    )
    finally:
        if persistent_conn is not None:
            del persistent_conn
        if persistent_db is not None:
            del persistent_db

    summary_out = default_summary_path(out)
    wide_summary_out = default_wide_summary_path(summary_out)
    summary_rows = build_summary_rows(results)
    wide_fieldnames, wide_rows = build_wide_summary_rows(summary_rows)
    write_csv_results(out, results)
    write_summary_results(summary_out, summary_rows)
    write_wide_summary_results(wide_summary_out, wide_fieldnames, wide_rows)
    ok = sum(1 for item in results if item.get("status") == "OK")
    skipped = sum(1 for item in results if item.get("status") == "SKIP")
    failed = [item for item in results if item.get("status") not in {"OK", "SKIP"}]
    print_wide_summary(wide_fieldnames, wide_rows)
    print(f"wrote {out}")
    print(f"wrote {summary_out}")
    print(f"wrote {wide_summary_out}")
    print(f"summary: ok={ok} skipped={skipped} failed_or_timeout={len(failed)}")
    return 1 if failed else 0


if __name__ == "__main__":
    mp.set_start_method("fork")
    raise SystemExit(main())
