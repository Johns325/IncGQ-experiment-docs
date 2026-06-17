#!/usr/bin/env python3
"""Run NeuG workload query sets through the local NeuG build.

This runner opens already imported IncGQ/NeuG databases under /mnt/data/imported_data/incgq
and executes Cypher query files through the Python API built from
/root/workspace/neug. It is intended as the local NeuG build baseline runner.
"""

from __future__ import annotations

import argparse
import csv
import ctypes
import datetime as dt
import importlib
import importlib.metadata
import json
import multiprocessing as mp
import os
import re
import sys
import time
from dataclasses import dataclass, field, replace
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
NEUG_DOC_ROOT = REPO_ROOT / "NeuG"
QUERY_ROOT = NEUG_DOC_ROOT / "queries"
QUERY_SET_DIRS = {
    "baseline": "baseline",
    "optimization": "optimization",
}
DATASET_DIRS = {
    "ic-sf1": "ldbc-ic",
    "bi-sf1": "ldbc-bi",
    "lsqb-sf1": "lsqb",
    "finbench-sf1": "finbench",
    "graphdblp": "graphdblp",
}
LOCAL_NEUG_ROOT = Path("/root/workspace/neug")
LOCAL_NEUG_BUILD = LOCAL_NEUG_ROOT / "build"
LOCAL_NEUG_PYTHON = LOCAL_NEUG_ROOT / "tools" / "python_bind"
LOCAL_NEUG_BUILD_PYTHON = LOCAL_NEUG_BUILD / "tools" / "python_bind"
LOCAL_NEUG_LIB_DIRS = [
    LOCAL_NEUG_BUILD / "src",
    LOCAL_NEUG_BUILD_PYTHON,
]
LOCAL_NEUG_SENTINEL = "INCGQ_NEUG_LOCAL_BUILD_ACTIVE"


def ensure_local_neug_runtime() -> None:
    missing = [
        path
        for path in [
            LOCAL_NEUG_PYTHON / "neug" / "__init__.py",
            LOCAL_NEUG_BUILD_PYTHON / "neug_py_bind.cpython-310-x86_64-linux-gnu.so",
            LOCAL_NEUG_BUILD / "src" / "libneug.so",
        ]
        if not path.exists()
    ]
    if missing:
        missing_text = "\n".join(str(path) for path in missing)
        raise RuntimeError(f"local NeuG build is incomplete; missing:\n{missing_text}")

    python_entries = [str(LOCAL_NEUG_PYTHON), str(LOCAL_NEUG_BUILD_PYTHON)]
    lib_entries = [str(path) for path in LOCAL_NEUG_LIB_DIRS]

    if os.environ.get(LOCAL_NEUG_SENTINEL) != "1":
        env = os.environ
        env[LOCAL_NEUG_SENTINEL] = "1"
        existing_pythonpath = env.get("PYTHONPATH", "")
        env["PYTHONPATH"] = os.pathsep.join(
            python_entries + ([existing_pythonpath] if existing_pythonpath else [])
        )
        existing_ld = env.get("LD_LIBRARY_PATH", "")
        env["LD_LIBRARY_PATH"] = os.pathsep.join(
            lib_entries + ([existing_ld] if existing_ld else [])
        )
        if "DEBUG" in env and env["DEBUG"] not in {"1", "true", "ON"}:
            env.pop("DEBUG", None)
        os.execv(sys.executable, [sys.executable, *sys.argv])

    for entry in reversed(python_entries):
        if entry not in sys.path:
            sys.path.insert(0, entry)
    for lib_dir in LOCAL_NEUG_LIB_DIRS:
        lib_path = lib_dir / "libneug.so"
        if lib_path.exists():
            ctypes.CDLL(str(lib_path), mode=ctypes.RTLD_GLOBAL)


ensure_local_neug_runtime()

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
DEFAULT_RESULTS_ROOT = Path("/mnt/data/results/neug")
RUN_TIMESTAMP_FORMAT = "%Y%m%d-%H%M%S"


@dataclass(frozen=True)
class Workload:
    name: str
    db_dir: Path
    query_dir: Path
    description: str
    default_mode: str = "validate"
    supports_execute: bool = True
    threads: int = 1
    skip_names: set[str] = field(default_factory=set)


WORKLOADS = {
    "ic-sf1": Workload(
        name="ic-sf1",
        db_dir=Path("/mnt/data/imported_data/incgq/ic-sf1"),
        query_dir=QUERY_ROOT / "ldbc-ic",
        description="LDBC SNB Interactive SF1",
    ),
    "bi-sf1": Workload(
        name="bi-sf1",
        db_dir=Path("/mnt/data/imported_data/incgq/bi-sf1"),
        query_dir=QUERY_ROOT / "ldbc-bi",
        description="LDBC SNB BI SF1",
        skip_names={
            "setup_add_bi15_weight.cypher",
            "setup_add_case1_fwd.cypher",
            "setup_add_case1_rev.cypher",
            "setup_add_case2_fwd.cypher",
            "setup_add_case2_rev.cypher",
            "setup_add_comment_like_count.cypher",
            "setup_add_comment_reply_count.cypher",
            "setup_add_comment_root_forum_id.cypher",
            "setup_add_comment_root_post_id.cypher",
            "setup_add_country_name.cypher",
            "setup_add_like_count.cypher",
            "setup_add_post_like_count.cypher",
            "setup_add_post_reply_count.cypher",
            "setup_add_post_root_forum_id.cypher",
            "setup_drop_bi15_weight.cypher",
            "setup_drop_comment_root_forum_id.cypher",
            "setup_drop_comment_root_post_id.cypher",
            "setup_drop_post_root_forum_id.cypher",
            "setup_drop_post_root_post_id.cypher",
            "setup_drop_root_post.cypher",
            "setup_fill_bi15_weight.cypher",
            "setup_fill_case1_fwd.cypher",
            "setup_fill_case1_rev.cypher",
            "setup_fill_case2_fwd.cypher",
            "setup_fill_case2_rev.cypher",
            "setup_fill_comment_like_count.cypher",
            "setup_fill_comment_reply_count.cypher",
            "setup_fill_comment_root_post_id.cypher",
            "setup_fill_country_name.cypher",
            "setup_fill_direct_comment_root_post_id.cypher",
            "setup_fill_like_count.cypher",
            "setup_fill_post_like_count.cypher",
            "setup_fill_post_reply_count.cypher",
            "setup_fill_post_root_post_id.cypher",
            "setup_fill_root_post.cypher",
            "setup_propagate_comment_root_post_id.cypher",
            "setup_reset_comment_root_post_id.cypher",
        },
    ),
    "lsqb-sf1": Workload(
        name="lsqb-sf1",
        db_dir=Path("/mnt/data/imported_data/incgq/lsqb-sf1"),
        query_dir=QUERY_ROOT / "lsqb",
        description="LSQB SF1",
    ),
    "finbench-sf1": Workload(
        name="finbench-sf1",
        db_dir=Path("/mnt/data/imported_data/incgq/finbench-sf1"),
        query_dir=QUERY_ROOT / "finbench" / "finbench-adapted-queries",
        description="FinBench SF1",
    ),
    "graphdblp": Workload(
        name="graphdblp",
        db_dir=Path("/mnt/data/imported_data/incgq/graphdblp/neug-graphdblp-core-db"),
        query_dir=QUERY_ROOT / "graphdblp" / "distinct",
        description="GraphDBLP distinct generated queries",
    ),
}

BI_TEMPLATE_KEYS = {
    "bi3/": ("country", "tagClass"),
    "bi5/": ("tag",),
    "bi6/": ("tag",),
    "bi11/": ("country", "__country_y", "country"),
    "bi13/": ("country", "endDate", "endDate", "endDate", "endDate"),
    "bi14a/": ("country1", "country2"),
    "bi15a/baseline.cypher": ("person1Id", "person2Id"),
    "bi15a/incgq.cypher": ("person1Id", "person1Id", "person2Id"),
    "bi17/": ("tag", "delta"),
    "bi19a/shortest_path.cypher": ("city1Id", "city2Id"),
}
BI_TEMPLATE_DEFAULTS = {
    "__country_y": "India",
    "__startDate": "2010-01-01",
}
IC_TEMPLATE_KEYS = {
    "ic1/": ("personId", "firstName"),
    "ic3/": (
        "personId",
        "personId",
        "countryXName",
        "countryYName",
        "startDate",
        "endDate",
        "countryXName",
        "countryYName",
        "countryXName",
        "countryYName",
    ),
    "ic5/": ("personId", "personId", "minDate", "minDate"),
    "ic12/": ("personId", "tagClassName"),
    "ic14/": ("person1Id", "person2Id"),
}


def strip_query(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    lines = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith(":param") or stripped.startswith(":params"):
            continue
        lines.append(line.rstrip())
    query = "\n".join(lines).strip()
    while query.endswith(";"):
        query = query[:-1].rstrip()
    return query


def queries_for(workload: Workload, include_setup: bool) -> list[Path]:
    files = sorted(workload.query_dir.rglob("*.cypher"))
    if not include_setup:
        files = [path for path in files if path.name not in workload.skip_names]
    return files


def dataset_dir_for(workload_name: str) -> str:
    try:
        return DATASET_DIRS[workload_name]
    except KeyError as exc:
        raise ValueError(f"no query directory mapping for workload {workload_name}") from exc


def workload_for_query_set(workload: Workload, query_set: str) -> Workload:
    if query_set == "baseline" and workload.name in {"finbench-sf1", "graphdblp"}:
        return replace(workload, skip_names=workload.skip_names | {"baseline_weight.cypher"})
    dataset_dir = dataset_dir_for(workload.name)
    query_dir = QUERY_ROOT / QUERY_SET_DIRS[query_set] / dataset_dir
    return replace(workload, query_dir=query_dir, skip_names=workload.skip_names | {"baseline_weight.cypher"})


def index_root_for(workload_name: str) -> Path:
    return QUERY_ROOT / "index" / dataset_dir_for(workload_name)


def index_setup_path(workload: Workload, query_path: Path) -> Path | None:
    rel = rel_path(workload, query_path)
    first = Path(rel).parts[0] if Path(rel).parts else ""
    if not first:
        return None
    candidate = index_root_for(workload.name) / first / "index.cypher"
    return candidate if candidate.exists() else None


def unique_query_match(workload: Workload, matches: list[Path], query: str) -> Path:
    if len(matches) == 1:
        return matches[0]
    if len(matches) > 1:
        rels = "\n".join(str(path.relative_to(workload.query_dir)) for path in matches[:20])
        raise ValueError(f"--query matched multiple files for '{query}', use a more specific path:\n{rels}")
    raise FileNotFoundError(f"--query not found under {workload.query_dir}: {query}")


def resolve_one_query(workload: Workload, query: str) -> Path:
    query_path = Path(query)
    if not query_path.is_absolute():
        candidate = workload.query_dir / query_path
        if candidate.exists():
            if candidate.is_dir():
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
    return bool(re.search(r"(^|\n)\s*(CREATE|MERGE|DELETE|DETACH\s+DELETE|SET|DROP|COPY|FILL)\b", query, flags=re.I))


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
            "endDate": dt.datetime(2012, 1, 1),
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
        match = re.match(r"bi(\d+)", rel)
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
            15: "bi-15a-without-date.csv" if "without-date" in rel else "bi-15a.csv",
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
        suffix = "-without-date" if "without-date" in rel else ""
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


def choose_full_params(
    workload: Workload,
    rel: str,
    params_file: Path | None,
    params_dir: Path | None,
    sampled_params_dir: Path | None,
    sample_round: int,
    row_number: int,
) -> tuple[dict[str, object], dict[str, object]]:
    if params_file is not None:
        return params_from_file(workload, rel, params_file, row_number)
    if params_dir is None:
        sampled_dir = resolve_sampled_params_dir(workload, sampled_params_dir)
        if sampled_dir is not None and sampled_dir.exists():
            sampled_file = sampled_parameter_file_from_dir(workload, rel, sampled_dir)
            if sampled_file is not None:
                return sampled_params_from_file(workload, rel, sampled_file, sample_round, row_number)
    directory = params_dir or DEFAULT_PARAM_DIRS.get(workload.name)
    auto_file = parameter_file_from_dir(workload, rel, directory) if directory and directory.exists() else None
    if auto_file is not None:
        return params_from_file(workload, rel, auto_file, row_number)
    params = default_params_for(workload.name)
    return params, dict(params)


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
    params, display = choose_full_params(
        workload,
        rel,
        params_file,
        params_dir,
        sampled_params_dir,
        sample_round,
        row_number,
    )
    if "{}" in query:
        return {}, {**display, **params}
    return params_used_by(query, params), params_used_by(query, display)


def rel_path(workload: Workload, path: Path) -> str:
    try:
        return str(path.relative_to(workload.query_dir))
    except ValueError:
        return str(path)


def bi_template_keys_for(rel: str) -> tuple[str, ...] | None:
    for prefix, keys in BI_TEMPLATE_KEYS.items():
        if rel.startswith(prefix):
            return keys
    return None


def render_bi_value(value: object) -> str:
    if isinstance(value, dt.datetime):
        return value.date().isoformat()
    if isinstance(value, dt.date):
        return value.isoformat()
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value)


def fill_bi_template(rel: str, query: str, display_params: dict[str, object]) -> str:
    placeholders = query.count("{}")
    if placeholders == 0:
        return query
    keys = bi_template_keys_for(rel)
    if keys is None or len(keys) != placeholders:
        values = [value for key, value in display_params.items() if not key.startswith("_")]
        if len(values) != placeholders:
            raise ValueError(f"no BI template mapping for {rel}: placeholders={placeholders}")
    else:
        values = []
        defaults = {**default_params_for("bi-sf1"), **BI_TEMPLATE_DEFAULTS}
        for key in keys:
            if key in display_params:
                values.append(display_params[key])
            elif key in defaults:
                values.append(defaults[key])
            else:
                raise ValueError(f"BI template value '{key}' missing for {rel}")
    rendered = query
    for value in values:
        rendered = rendered.replace("{}", render_bi_value(value), 1)
    return rendered


def ic_template_keys_for(rel: str) -> tuple[str, ...] | None:
    for prefix, keys in IC_TEMPLATE_KEYS.items():
        if rel.startswith(prefix):
            return keys
    return None


def render_template_value(value: object) -> str:
    if isinstance(value, dt.datetime):
        return value.strftime("%Y-%m-%d %H:%M:%S")
    if isinstance(value, dt.date):
        return value.isoformat()
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value)


def fill_ic_template(rel: str, query: str, display_params: dict[str, object]) -> str:
    placeholders = query.count("{}")
    if placeholders == 0:
        return query
    keys = ic_template_keys_for(rel)
    if keys is None or len(keys) != placeholders:
        raise ValueError(f"no IC template mapping for {rel}: placeholders={placeholders}")
    rendered = query
    for key in keys:
        if key not in display_params:
            raise ValueError(f"IC template value '{key}' missing for {rel}")
        rendered = rendered.replace("{}", render_template_value(display_params[key]), 1)
    return rendered


def fill_template(workload: Workload, rel: str, query: str, display_params: dict[str, object]) -> str:
    if workload.name == "bi-sf1":
        return fill_bi_template(rel, query, display_params)
    if workload.name == "ic-sf1":
        return fill_ic_template(rel, query, display_params)
    if "{}" in query:
        raise ValueError(f"no template mapping for {workload.name} {rel}: placeholders={query.count('{}')}")
    return query


def make_runnable(
    workload: Workload,
    query: str,
    mode: str,
    rel: str,
    allow_writes: bool,
) -> tuple[str, str, bool, str]:
    write_query = is_write_query(workload, rel, query)
    if write_query and not allow_writes:
        raise ValueError("write query requires --allow-writes")
    if mode == "validate" and write_query:
        raise ValueError("validate mode skips write query")
    access_mode = "update" if write_query else "read"
    return query, "EXECUTE", not allow_writes, access_mode


def prepare_query_run(
    workload: Workload,
    path: Path,
    mode: str,
    allow_writes: bool,
    params_file: Path | None,
    params_dir: Path | None,
    sampled_params_dir: Path | None,
    sample_round: int,
    param_row: int,
) -> tuple[dict[str, Any] | None, dict[str, Any] | None]:
    query = strip_query(path.read_text(encoding="utf-8"))
    rel = rel_path(workload, path)
    if not query:
        return None, {"query": rel, "param_row": param_row, "status": "SKIP", "reason": "empty query"}
    try:
        params, display_params = choose_params(workload, rel, query, params_file, params_dir, sampled_params_dir, sample_round, param_row)
        query = fill_template(workload, rel, query, display_params)
        runnable, run_mode, read_only, access_mode = make_runnable(workload, query, mode, rel, allow_writes)
    except Exception as exc:
        return None, {"query": rel, "param_row": param_row, "status": "FAIL", "error": f"{type(exc).__name__}: {exc}"}
    return (
        {
            "query": rel,
            "param_row": param_row,
            "display_params": display_params,
            "runnable": runnable,
            "mode": run_mode,
            "read_only": read_only,
            "access_mode": access_mode,
            "params": params,
        },
        None,
    )


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


def local_neug_version(neug_module: object) -> str | None:
    module_version = getattr(neug_module, "__version__", None)
    return str(module_version) if module_version is not None else None


def normalize_neug_debug_env() -> None:
    debug_value = os.environ.get("DEBUG")
    if debug_value is not None and debug_value not in {"1", "true", "ON"}:
        os.environ.pop("DEBUG", None)


def import_local_neug(required_version: str | None) -> object:
    normalize_neug_debug_env()
    try:
        neug_module = importlib.import_module("neug")
    except ModuleNotFoundError as exc:
        raise RuntimeError(
            "local NeuG Python API is not importable; build /root/workspace/neug "
            "with Python bindings before running this baseline"
        ) from exc
    module_path = Path(getattr(neug_module, "__file__", "")).resolve()
    if LOCAL_NEUG_PYTHON not in (module_path, *module_path.parents):
        raise RuntimeError(
            f"refusing to use non-local NeuG module: {module_path}; "
            f"expected under {LOCAL_NEUG_PYTHON}"
        )
    discovered = local_neug_version(neug_module)
    if required_version and discovered and discovered != required_version:
        raise RuntimeError(f"local NeuG version is {discovered}, expected {required_version}")
    return neug_module


def database_class(neug_module: object) -> object:
    cls = getattr(neug_module, "Database", None)
    if cls is not None:
        return cls
    database_module = importlib.import_module("neug.database")
    cls = getattr(database_module, "Database", None)
    if cls is None:
        raise RuntimeError("local NeuG Python API does not expose a Database class")
    return cls


def open_neug_database(neug_module: object, db_dir: str, read_only: bool, threads: int) -> tuple[object, object]:
    cls = database_class(neug_module)
    constructors = [
        ((db_dir,), {"mode": "read-only" if read_only else "read-write", "max_thread_num": threads, "checkpoint_on_close": False}),
        ((db_dir,), {"mode": "r" if read_only else "w"}),
        ((db_dir,), {}),
    ]
    errors: list[str] = []
    for args, kwargs in constructors:
        try:
            db = cls(*args, **kwargs)
            break
        except TypeError as exc:
            errors.append(str(exc))
    else:
        raise RuntimeError("cannot open NeuG Database with known Python API signatures: " + " | ".join(errors[:3]))

    connect = getattr(db, "connect", None)
    if callable(connect):
        conn = connect()
    else:
        conn = db
    return db, conn


def execute_neug(conn: object, query: str, params: dict[str, Any], access_mode: str) -> object:
    execute = getattr(conn, "execute", None)
    if not callable(execute):
        raise RuntimeError("NeuG connection object does not expose execute()")
    attempts = [
        ((query,), {"access_mode": access_mode, "parameters": params}),
        ((query,), {"parameters": params, "access_mode": access_mode}),
        ((query, access_mode, params), {}),
        ((query, params), {}),
        ((query,), {"params": params}),
        ((query,), {}),
    ]
    errors: list[str] = []
    for args, kwargs in attempts:
        try:
            return execute(*args, **kwargs)
        except TypeError as exc:
            errors.append(str(exc))
    raise RuntimeError("cannot execute query with known NeuG Python API signatures: " + " | ".join(errors[:3]))


def close_if_possible(obj: object) -> None:
    close = getattr(obj, "close", None)
    if callable(close):
        close()


def materialize_rows(result: object, fetch_rows: int) -> list[object]:
    rows: list[object] = []
    if result is None:
        return rows
    if isinstance(result, list) and result and not hasattr(result, "has_next"):
        for item in result[: fetch_rows or None]:
            rows.append(json_safe(item))
        return rows
    if hasattr(result, "get_column_names") and hasattr(result, "has_next") and hasattr(result, "get_next"):
        columns = list(result.get_column_names())
        while result.has_next() and (fetch_rows == 0 or len(rows) < fetch_rows):
            row = result.get_next()
            if isinstance(row, dict):
                rows.append(json_safe(row))
            elif columns:
                rows.append({column: json_safe(value) for column, value in zip(columns, row)})
            else:
                rows.append({"row": json_safe(row)})
        return rows
    try:
        iterator = iter(result)
    except TypeError:
        return [{"value": json_safe(result)}]
    for row in iterator:
        if fetch_rows and len(rows) >= fetch_rows:
            break
        rows.append(json_safe(row))
    return rows


def split_cypher_statements(text: str) -> list[str]:
    lines = []
    for line in re.sub(r"/\*.*?\*/", "", text, flags=re.S).splitlines():
        stripped = line.strip()
        if stripped.startswith(":param") or stripped.startswith(":params"):
            continue
        lines.append(line.rstrip())
    cleaned = "\n".join(lines).strip()
    statements: list[str] = []
    current: list[str] = []
    in_single = False
    in_double = False
    escape = False
    for char in cleaned:
        current.append(char)
        if escape:
            escape = False
            continue
        if char == "\\":
            escape = True
            continue
        if char == "'" and not in_double:
            in_single = not in_single
        elif char == '"' and not in_single:
            in_double = not in_double
        elif char == ";" and not in_single and not in_double:
            statement = "".join(current).strip()
            statement = statement[:-1].strip()
            if statement:
                statements.append(statement)
            current = []
    tail = "".join(current).strip()
    if tail:
        statements.append(tail)
    return statements


KNOWN_FILL_INDEX_DROPS = [
    "CALL drop_index('KNOWS', 'fill_KNOWS_bi14_case1_d36ebed024fa') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_bi14_case2_4b5bacb138d0') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_bi14_case1_7e241fb05bd7') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_bi14_case2_2a155885fa41') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_bi14_case1_fwd_c5ed84904cee') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_bi14_case1_rev_0bae6c1010ea') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_bi14_case2_fwd_5542f9a09a21') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_bi14_case2_rev_be7162f2fa6a') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_bi15_weight_beb42a3b6150') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_weight_bi19_a920a32161c7') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_weight_bi19_a920a32161c7_1') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_weight_bi19_a920a32161c7_2') RETURN *",
    "CALL drop_index('KNOWS', 'fill_KNOWS_weight_bi19_a920a32161c7_3') RETURN *",
]


def _index_name_pair(row: object) -> tuple[str, str] | None:
    if isinstance(row, dict):
        values = list(row.values())
    elif isinstance(row, (list, tuple)):
        values = list(row)
    else:
        return None
    if len(values) < 2:
        return None
    table_name = str(values[0]) if values[0] is not None else ""
    index_name = str(values[1]) if values[1] is not None else ""
    if not table_name or not index_name:
        return None
    return table_name, index_name


def drop_all_indexes(conn: object) -> dict[str, Any]:
    dropped = 0
    errors: list[str] = []
    try:
        rows = materialize_rows(execute_neug(conn, "CALL show_indexes() RETURN *", {}, "update"), 0)
    except Exception as exc:
        rows = []
        errors.append(f"show_indexes: {type(exc).__name__}: {exc}")
    for row in rows:
        pair = _index_name_pair(row)
        if pair is None:
            continue
        table_name, index_name = pair
        try:
            materialize_rows(
                execute_neug(conn, f"CALL drop_index('{table_name}', '{index_name}') RETURN *", {}, "update"),
                0,
            )
            dropped += 1
        except Exception as exc:
            errors.append(f"drop_index({table_name}, {index_name}): {type(exc).__name__}: {exc}")
    if errors:
        for statement in KNOWN_FILL_INDEX_DROPS:
            try:
                materialize_rows(execute_neug(conn, statement, {}, "update"), 0)
            except Exception:
                pass
    return {"dropped": dropped, "errors": errors}


def run_index_setup(conn: object, setup_path: Path, fetch_rows: int) -> dict[str, Any]:
    statements = split_cypher_statements(setup_path.read_text(encoding="utf-8"))
    rel = str(setup_path.relative_to(QUERY_ROOT)) if setup_path.is_relative_to(QUERY_ROOT) else str(setup_path)
    started = time.monotonic()
    if not statements:
        return {"query": rel, "phase": "index_setup", "status": "SKIP", "reason": "empty setup"}
    completed = 0
    try:
        for statement in statements:
            rows = materialize_rows(execute_neug(conn, statement, {}, "update"), fetch_rows)
            completed += 1
        return {
            "query": rel,
            "phase": "index_setup",
            "status": "OK",
            "seconds": round(time.monotonic() - started, 6),
            "mode": "INDEX_SETUP",
            "statement_count": len(statements),
        }
    except Exception as exc:
        return {
            "query": rel,
            "phase": "index_setup",
            "status": "FAIL",
            "seconds": round(time.monotonic() - started, 6),
            "mode": "INDEX_SETUP",
            "error": f"{type(exc).__name__}: {exc}",
            "statement_count": len(statements),
            "completed_statements": completed,
        }


def _child_run(
    db_dir: str,
    query: str,
    params: dict[str, Any],
    threads: int,
    read_only: bool,
    access_mode: str,
    fetch_rows: int,
    required_version: str | None,
    queue: mp.Queue,
) -> None:
    db = None
    conn = None
    try:
        neug_module = import_local_neug(required_version)
        db, conn = open_neug_database(neug_module, db_dir, read_only, threads)
        raw_result = execute_neug(conn, query, params, access_mode)
        rows = materialize_rows(raw_result, fetch_rows)
        queue.put({"status": "OK", "rows": rows})
    except Exception as exc:
        queue.put({"status": "FAIL", "error": f"{type(exc).__name__}: {exc}"})
    finally:
        if conn is not None:
            close_if_possible(conn)
        if db is not None and db is not conn:
            close_if_possible(db)


def _child_preflight(
    db_dir: str,
    threads: int,
    required_version: str | None,
    queue: mp.Queue,
) -> None:
    db = None
    conn = None
    try:
        neug_module = import_local_neug(required_version)
        db, conn = open_neug_database(neug_module, db_dir, True, threads)
        queue.put({"status": "OK"})
    except Exception as exc:
        queue.put({"status": "FAIL", "error": f"{type(exc).__name__}: {exc}"})
    finally:
        if conn is not None:
            close_if_possible(conn)
        if db is not None and db is not conn:
            close_if_possible(db)


def preflight_database(workload: Workload, timeout: int | None, required_version: str | None) -> dict[str, Any]:
    queue: mp.Queue = mp.Queue(maxsize=1)
    process = mp.Process(
        target=_child_preflight,
        args=(str(workload.db_dir), workload.threads, required_version, queue),
    )
    process.start()
    process.join(timeout)
    if timeout is not None and process.is_alive():
        process.terminate()
        process.join(10)
        if process.is_alive():
            process.kill()
            process.join(10)
        return {"status": "TIMEOUT", "error": f"database preflight timed out after {timeout}s"}
    if queue.empty():
        return {"status": "ERROR", "error": f"database preflight child exited with code {process.exitcode}"}
    return queue.get()


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
    required_version: str | None,
) -> dict[str, Any]:
    prepared, early_result = prepare_query_run(
        workload,
        path,
        mode,
        allow_writes,
        params_file,
        params_dir,
        sampled_params_dir,
        sample_round,
        param_row,
    )
    if early_result is not None:
        return early_result
    assert prepared is not None

    queue: mp.Queue = mp.Queue(maxsize=1)
    process = mp.Process(
        target=_child_run,
        args=(
            str(workload.db_dir),
            prepared["runnable"],
            prepared["params"],
            workload.threads,
            prepared["read_only"],
            prepared["access_mode"],
            fetch_rows,
            required_version,
            queue,
        ),
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
            "query": prepared["query"],
            "param_row": param_row,
            "display_params": prepared["display_params"],
            "status": "TIMEOUT",
            "seconds": timeout,
            "mode": prepared["mode"],
        }
    if queue.empty():
        return {
            "query": prepared["query"],
            "param_row": param_row,
            "display_params": prepared["display_params"],
            "status": "ERROR",
            "seconds": elapsed,
            "mode": prepared["mode"],
            "error": f"child exited with code {process.exitcode}",
        }
    payload = queue.get()
    payload.update(
        {
            "query": prepared["query"],
            "param_row": param_row,
            "display_params": prepared["display_params"],
            "seconds": elapsed,
            "mode": prepared["mode"],
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
    prepared, early_result = prepare_query_run(
        workload,
        path,
        mode,
        allow_writes,
        params_file,
        params_dir,
        sampled_params_dir,
        sample_round,
        param_row,
    )
    if early_result is not None:
        return early_result
    assert prepared is not None
    start = time.monotonic()
    try:
        raw_result = execute_neug(conn, prepared["runnable"], prepared["params"], prepared["access_mode"])
        rows = materialize_rows(raw_result, fetch_rows)
        elapsed = round(time.monotonic() - start, 6)
        return {
            "status": "OK",
            "rows": rows,
            "query": prepared["query"],
            "param_row": param_row,
            "display_params": prepared["display_params"],
            "seconds": elapsed,
            "mode": prepared["mode"],
        }
    except Exception as exc:
        elapsed = round(time.monotonic() - start, 6)
        return {
            "status": "FAIL",
            "error": f"{type(exc).__name__}: {exc}",
            "query": prepared["query"],
            "param_row": param_row,
            "display_params": prepared["display_params"],
            "seconds": elapsed,
            "mode": prepared["mode"],
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


def default_results_path(work_dir: Path, result_group: str, workload_name: str, mode: str, run_timestamp: str) -> Path:
    return work_dir / result_group / workload_name / f"{mode}-{run_timestamp}-results.csv"


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
            fieldnames=["query", "sample_round", "phase", "iteration", "parameter_index", "parameters", "results", "time_seconds"],
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
    parser.add_argument("--query-set", choices=["baseline", "optimization"], default="baseline")
    parser.add_argument("--workload", choices=sorted(WORKLOADS), required=True)
    parser.add_argument("--mode", choices=["validate", "execute"], default=None)
    parser.add_argument("--runner", choices=["persistent"], default="persistent", help="persistent benchmark runner; opens one NeuG database connection and reuses it for all warmup/performance executions")
    parser.add_argument("--timeout", type=int, default=None, help="optional per-query timeout in seconds; omitted means no query timeout")
    parser.add_argument("--work-dir", type=Path, default=DEFAULT_RESULTS_ROOT)
    parser.add_argument("--result-group", choices=["baseline", "optimization"], default=None, help="result subdirectory under --work-dir; defaults to --query-set")
    parser.add_argument("--out", type=Path, default=None)
    parser.add_argument("--include-setup", action="store_true", help="include setup/drop Cypher files normally skipped")
    parser.add_argument("--allow-writes", action="store_true", help="execute write queries and open the database read-write")
    parser.add_argument("--db-dir", type=Path, default=None, help="override the workload database directory")
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
    parser.add_argument("--performance-count", type=int, default=3, help="number of measured performance iterations to run")
    parser.add_argument("--limit", type=int, default=0, help="run only the first N selected query files")
    parser.add_argument("--start-at", type=int, default=1, help="1-based index into the selected query list")
    parser.add_argument("--fetch-rows", type=int, default=0, help="maximum rows to materialize in the CSV results field; 0 means all rows")
    parser.add_argument("--require-version", default="0.1.1", help="expected local NeuG build Python API version; set empty string to disable the check")
    args = parser.parse_args()

    workload = workload_for_query_set(WORKLOADS[args.workload], args.query_set)
    result_group = args.result_group or args.query_set
    if args.db_dir is not None:
        workload = replace(workload, db_dir=args.db_dir)
    mode = args.mode or workload.default_mode
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
    warmup_count = args.warmup_count if args.warmup_count is not None else 1
    if warmup_count < 0:
        print("--warmup-count must be >= 0", file=sys.stderr)
        return 2
    if args.performance_count < 1:
        print("--performance-count must be >= 1", file=sys.stderr)
        return 2
    if args.fetch_rows < 0:
        print("--fetch-rows must be >= 0", file=sys.stderr)
        return 2
    if args.timeout is not None:
        print("--timeout is ignored; this runner opens the database once and does not use per-row child processes", file=sys.stderr)
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
    if not workload.query_dir.exists():
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

    required_version = args.require_version or None
    run_timestamp = dt.datetime.now().strftime(RUN_TIMESTAMP_FORMAT)
    out = args.out or default_results_path(args.work_dir, result_group, workload.name, mode, run_timestamp)
    args.work_dir.mkdir(parents=True, exist_ok=True)
    out.parent.mkdir(parents=True, exist_ok=True)

    results: list[dict[str, Any]] = []
    print(
        f"== running {args.query_set} {workload.name}: {len(queries)} query files x rounds {sample_rounds} "
        f"x {warmup_count} warmup + {args.performance_count} performance iteration(s) "
        f"in {mode} mode with persistent runner ==",
        flush=True,
    )
    persistent_db = None
    persistent_conn = None
    try:
        try:
            neug_module = import_local_neug(required_version)
            persistent_db, persistent_conn = open_neug_database(
                neug_module,
                str(workload.db_dir),
                not (args.allow_writes or args.query_set == "optimization"),
                workload.threads,
            )
        except Exception as exc:
            print(
                f"database open failed for {workload.name} at {workload.db_dir}: "
                f"{type(exc).__name__}: {exc}",
                file=sys.stderr,
            )
            return 1
        for idx, query_path in enumerate(queries, start_index):
            rel = rel_path(workload, query_path)
            print(f"[{idx}] {rel}", flush=True)
            if args.query_set == "optimization":
                assert persistent_conn is not None
                drop_started = time.monotonic()
                drop_info = drop_all_indexes(persistent_conn)
                drop_result = {
                    "query": rel,
                    "phase": "index_clear",
                    "status": "OK",
                    "seconds": round(time.monotonic() - drop_started, 6),
                    "mode": "INDEX_CLEAR",
                    "display_params": {"dropped": drop_info["dropped"], "errors": drop_info["errors"]},
                }
                results.append(drop_result)
                print(
                    f"  index_clear OK {drop_result['seconds']}s "
                    f"dropped={drop_info['dropped']} errors={len(drop_info['errors'])}",
                    flush=True,
                )
                setup_path = index_setup_path(workload, query_path)
                if setup_path is None:
                    result = {
                        "query": rel,
                        "phase": "index_setup",
                        "status": "FAIL",
                        "error": "missing matching index.cypher",
                    }
                    results.append(result)
                    print("  index_setup FAIL missing matching index.cypher", flush=True)
                    continue
                setup_result = run_index_setup(persistent_conn, setup_path, args.fetch_rows)
                results.append(setup_result)
                print(
                    f"  index_setup {setup_path.relative_to(QUERY_ROOT)} "
                    f"{setup_result['status']} {setup_result.get('seconds', '')}",
                    flush=True,
                )
                if setup_result.get("status") != "OK":
                    print(f"  index_setup error: {setup_result.get('error', '')}", flush=True)
                    continue
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
                assert persistent_conn is not None
                phases = [("warmup", warmup_count), ("performance", args.performance_count)]
                for phase, iteration_count in phases:
                    for iteration in range(1, iteration_count + 1):
                        iteration_seconds: list[float] = []
                        for param_row in range(args.param_row, args.param_row + row_count):
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
                            result["sample_round"] = sample_round
                            result["phase"] = phase
                            result["iteration"] = iteration
                            if phase == "performance" and result.get("status") == "OK" and isinstance(result.get("seconds"), int | float):
                                iteration_seconds.append(float(result["seconds"]))
                            print(
                                f"    {phase}#{iteration} round={sample_round} row={param_row} "
                                f"{result['status']} {result.get('seconds', '')} {result.get('mode', '')}",
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
            close_if_possible(persistent_conn)
        if persistent_db is not None and persistent_db is not persistent_conn:
            close_if_possible(persistent_db)

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
