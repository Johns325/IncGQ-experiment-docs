#!/usr/bin/env python3
"""Run or validate local Neo4j workload query sets.

This runner starts Neo4j against an already imported database directory, runs the
selected workload's Cypher files, writes a JSON result file, and stops Neo4j.
It is intended for local correctness/smoke runs, not as an official benchmark
harness.
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import json
import os
import re
import shutil
import socket
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
NEO4J_ROOT = REPO_ROOT / "Neo4j"
QUERY_ROOT = NEO4J_ROOT / "queries"
GRAPHDBLP_QUERY_DIR = REPO_ROOT / "NeuG" / "queries" / "graphdblp" / "distinct"
DEFAULT_NEO4J_HOME = Path("/mnt/data/imported_data/neo4j/bi-sf1/tools/neo4j-community-5.20.0")
DEFAULT_JAVA_HOME = Path("/mnt/data/imported_data/neo4j/bi-sf1/tools/jdk-17.0.19+10-jre")
DEFAULT_PLUGIN_DIRS = [Path("/mnt/data/imported_data/neo4j/_plugins")]
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
DEFAULT_RESULTS_ROOT = Path("/mnt/data/results/neo4j")
RUN_TIMESTAMP_FORMAT = "%Y%m%d-%H%M%S"


@dataclass(frozen=True)
class Workload:
    name: str
    db_dir: Path
    query_dir: Path
    bolt_port: int
    heap: str = "4G"
    pagecache: str = "4G"
    tx_memory: str = "3G"
    default_mode: str = "explain"
    supports_execute: bool = True
    description: str = ""
    skip_names: set[str] = field(default_factory=set)


WORKLOADS = {
    "ic-sf1": Workload(
        name="ic-sf1",
        db_dir=Path("/mnt/data/imported_data/neo4j/ic-sf1"),
        query_dir=QUERY_ROOT / "baseline" / "ldbc-ic",
        bolt_port=17688,
        description="LDBC SNB Interactive SF1",
    ),
    "bi-sf1": Workload(
        name="bi-sf1",
        db_dir=Path("/mnt/data/imported_data/neo4j/bi-sf1"),
        query_dir=QUERY_ROOT / "baseline" / "ldbc-bi",
        bolt_port=17689,
        heap="24G",
        pagecache="12G",
        tx_memory="20G",
        description="LDBC SNB BI SF1",
        skip_names={"setup.cypher", "bi-19-create-graph.cypher", "bi-19-drop-graph.cypher", "bi-20-create-graph.cypher", "bi-20-drop-graph.cypher"},
    ),
    "lsqb-sf1": Workload(
        name="lsqb-sf1",
        db_dir=Path("/mnt/data/imported_data/neo4j/lsqb/sf1"),
        query_dir=QUERY_ROOT / "baseline" / "lsqb",
        bolt_port=17687,
        heap="12G",
        pagecache="8G",
        tx_memory="10G",
        description="LSQB SF1",
        skip_names={"schema.cypher"},
    ),
    "finbench-sf1": Workload(
        name="finbench-sf1",
        db_dir=Path("/mnt/data/imported_data/neo4j/finbench/sf1"),
        query_dir=QUERY_ROOT / "baseline" / "finbench",
        bolt_port=17690,
        description="FinBench SF1",
    ),
    "graphdblp": Workload(
        name="graphdblp",
        db_dir=Path("/mnt/data/imported_data/neo4j/graphdblp"),
        query_dir=GRAPHDBLP_QUERY_DIR,
        bolt_port=17691,
        heap="8G",
        pagecache="6G",
        tx_memory="6G",
        supports_execute=False,
        description="GraphDBLP distinct query workload",
    ),
}


def env_for(conf_dir: Path, java_home: Path, heap: str) -> dict[str, str]:
    env = os.environ.copy()
    env["JAVA_HOME"] = str(java_home)
    env["NEO4J_CONF"] = str(conf_dir)
    env["HEAP_SIZE"] = heap
    return env


def prepare_plugins(workload: Workload, work_dir: Path, neo4j_home: Path, extra_plugin_dirs: list[Path]) -> Path:
    plugin_dir = work_dir / workload.name / "plugins"
    plugin_dir.mkdir(parents=True, exist_ok=True)
    for existing in plugin_dir.glob("*.jar"):
        existing.unlink()

    source_dirs = [neo4j_home / "plugins", neo4j_home / "labs", *DEFAULT_PLUGIN_DIRS, *extra_plugin_dirs]
    copied: set[str] = set()
    for source_dir in source_dirs:
        if not source_dir.exists():
            continue
        for jar in sorted(source_dir.glob("*.jar")):
            target = plugin_dir / jar.name
            if target.name in copied:
                continue
            shutil.copy2(jar, target)
            copied.add(target.name)
    return plugin_dir


def write_conf(workload: Workload, work_dir: Path, plugin_dir: Path) -> Path:
    conf_dir = work_dir / workload.name / "conf"
    logs_dir = work_dir / workload.name / "logs"
    run_dir = work_dir / workload.name / "run"
    conf_dir.mkdir(parents=True, exist_ok=True)
    logs_dir.mkdir(parents=True, exist_ok=True)
    run_dir.mkdir(parents=True, exist_ok=True)
    (conf_dir / "neo4j.conf").write_text(
        "\n".join(
            [
                f"server.directories.data={workload.db_dir / 'data'}",
                f"server.directories.logs={logs_dir}",
                f"server.directories.run={run_dir}",
                f"server.directories.plugins={plugin_dir}",
                f"server.memory.heap.initial_size={workload.heap}",
                f"server.memory.heap.max_size={workload.heap}",
                f"server.memory.pagecache.size={workload.pagecache}",
                f"dbms.memory.transaction.total.max={workload.tx_memory}",
                "server.default_listen_address=127.0.0.1",
                f"server.bolt.listen_address=127.0.0.1:{workload.bolt_port}",
                "server.http.enabled=false",
                "dbms.security.auth_enabled=false",
                "dbms.security.procedures.allowlist=apoc.*,gds.*",
                "dbms.security.procedures.unrestricted=apoc.*,gds.*",
                "db.filewatcher.enabled=false",
                "initial.dbms.default_database=neo4j",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return conf_dir


def port_open(port: int) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.settimeout(0.5)
        return sock.connect_ex(("127.0.0.1", port)) == 0


def cypher_shell(
    workload: Workload,
    query: str,
    neo4j_home: Path,
    java_home: Path,
    params: str = "",
    timeout: int | None = None,
) -> subprocess.CompletedProcess:
    cmd = [
        str(neo4j_home / "bin" / "cypher-shell"),
        "--non-interactive",
        "--format",
        "plain",
        "-a",
        f"bolt://127.0.0.1:{workload.bolt_port}",
        "-d",
        "neo4j",
    ]
    if params:
        cmd.extend(["-P", params])
    cmd.append(query)
    return subprocess.run(
        cmd,
        env={**os.environ, "JAVA_HOME": str(java_home)},
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=timeout,
    )


def start_neo4j(workload: Workload, work_dir: Path, neo4j_home: Path, java_home: Path, plugin_dir: Path) -> tuple[subprocess.Popen, Path]:
    conf_dir = write_conf(workload, work_dir, plugin_dir)
    process = subprocess.Popen(
        [str(neo4j_home / "bin" / "neo4j"), "console"],
        env=env_for(conf_dir, java_home, workload.heap),
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    deadline = time.time() + 180
    output: list[str] = []
    while time.time() < deadline:
        if process.poll() is not None:
            if process.stdout:
                output.extend(process.stdout.readlines())
            raise RuntimeError(f"Neo4j exited while starting {workload.name}:\n{''.join(output[-100:])}")
        if port_open(workload.bolt_port):
            probe = cypher_shell(workload, "RETURN 1 AS ok", neo4j_home, java_home, timeout=15)
            if probe.returncode == 0:
                return process, conf_dir
        time.sleep(1)
    stop_process(process)
    raise RuntimeError(f"Timed out waiting for Neo4j {workload.name} on port {workload.bolt_port}")


def stop_process(process: subprocess.Popen) -> None:
    if process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=30)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=10)


def strip_shell_directives(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    lines = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("//") or stripped.startswith(":param") or stripped.startswith(":params"):
            continue
        lines.append(line.rstrip())
    query = "\n".join(lines).strip()
    while query.endswith(";"):
        query = query[:-1].rstrip()
    return query


def queries_for(workload: Workload, include_setup: bool, skip_plugin_queries: bool) -> list[Path]:
    files = sorted(workload.query_dir.rglob("*.cypher"))
    if not include_setup:
        files = [path for path in files if path.name not in workload.skip_names]
    if skip_plugin_queries:
        kept = []
        for path in files:
            text = path.read_text(encoding="utf-8")
            if "gds." in text or "apoc." in text:
                continue
            kept.append(path)
        files = kept
    return files


def active_plugins(plugin_dir: Path) -> set[str]:
    jars = [path.name.lower() for path in plugin_dir.glob("*.jar")] if plugin_dir.exists() else []
    plugins = set()
    if any("apoc" in name for name in jars):
        plugins.add("apoc")
    if any("graph-data-science" in name or re.search(r"\bgds\b", name) for name in jars):
        plugins.add("gds")
    return plugins


def required_plugins(query: str) -> set[str]:
    needed = set()
    if re.search(r"\bapoc\.", query):
        needed.add("apoc")
    if re.search(r"\bgds\.", query):
        needed.add("gds")
    return needed


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


def param_map(workload_name: str) -> str:
    if workload_name == "ic-sf1":
        return (
            "{personId: 0, person1Id: 0, person2Id: 1, firstName: 'Alice', "
            "countryName: 'China', countryXName: 'China', countryYName: 'India', "
            "tagClassName: 'Thing', tagName: 'music', month: 1, workFromYear: 2010, "
            "startDate: 1262304000000, endDate: 1893456000000, minDate: 1262304000000, maxDate: 1893456000000}"
        )
    if workload_name == "bi-sf1":
        return (
            "{datetime: datetime('2012-01-01T00:00:00.000'), date: datetime('2012-06-01T00:00:00.000'), "
            "startDate: datetime('2010-01-01T00:00:00.000'), endDate: datetime('2030-01-01T00:00:00.000'), "
            "dateA: datetime('2011-01-01T00:00:00.000'), dateB: datetime('2013-01-01T00:00:00.000'), "
            "country: 'China', country1: 'China', country2: 'India', tagClass: 'Thing', tag: 'music', "
            "languages: ['en'], lengthThreshold: 100, personId: 0, person1Id: 0, person2Id: 1, "
            "city1Id: 0, city2Id: 1, minPathDistance: 1, maxPathDistance: 3, maxKnowsLimit: 10, "
            "tagA: 'music', tagB: 'sports', delta: 1, company: 'Acme'}"
        )
    if workload_name == "finbench-sf1":
        return (
            "{id: 4750735206678266224, id1: 4750735206678266224, id2: 4751298156630269469, "
            "personId: 33065, personName: 'Verify Person', "
            "companyId: 0, companyName: 'Verify Company', accountId: 0, accountBlocked: false, "
            "accountType: 'card', srcId: 4750735206678266224, dstId: 4751298156630269469, "
            "mediumId: 0, mediumBlocked: false, loanId: 0, "
            "pid1: 33065, pid2: 20022, currentTime: '2020-01-01 00:00:00.000', amount: 1.0, amt: 1.0, "
            "threshold: 0.0, threshold1: 0.0, threshold2: 0.0, lowerbound: 0.0, upperbound: 1000000000.0, "
            "start_time: '2020-01-01 00:00:00.000', end_time: '2030-01-01 00:00:00.000'}"
        )
    return "{}"


def param_override(workload: Workload, rel: str, default_params: str) -> str:
    if workload.name != "finbench-sf1":
        return default_params
    overrides = {
        "tcr-9.cypher": (
            "{id: 4908924693345483908, start_time: '2020-01-01 00:00:00.000', "
            "end_time: '2030-01-01 00:00:00.000', threshold: 0.0, lowerbound: 0.0, upperbound: 1000000000.0}"
        ),
        "tcr-12.cypher": "{id: 33065, start_time: '2020-01-01 00:00:00.000', end_time: '2030-01-01 00:00:00.000'}",
        "tsr-3.cypher": (
            "{id: 4750735206678266224, start_time: '2020-01-01 00:00:00.000', "
            "end_time: '2030-01-01 00:00:00.000', threshold: 0.0}"
        ),
    }
    return overrides.get(rel, default_params)


def cypher_quote(value: str) -> str:
    return "'" + value.replace("\\", "\\\\").replace("'", "\\'") + "'"


def cypher_literal(value: object, value_type: str | None = None) -> str:
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int | float):
        return str(value)
    text = str(value).strip()
    type_name = (value_type or "").upper()
    if text == "":
        return "null"
    if type_name in {"ID", "INT", "LONG"}:
        return str(int(text))
    if type_name in {"FLOAT", "DOUBLE"}:
        return str(float(text))
    if type_name == "DATE":
        return f"datetime({cypher_quote(text + 'T00:00:00.000Z')})"
    if type_name == "DATETIME":
        return f"datetime({cypher_quote(text)})"
    if type_name == "STRING[]":
        return "[" + ", ".join(cypher_quote(item) for item in text.split(";") if item != "") + "]"
    if re.fullmatch(r"-?\d+", text):
        return str(int(text))
    if re.fullmatch(r"-?\d+\.\d+", text):
        return str(float(text))
    return cypher_quote(text)


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


def params_to_cypher(params: dict[str, str]) -> str:
    items = [f"{key}: {value}" for key, value in params.items()]
    return "{" + ", ".join(items) + "}"


def parse_typed_pipe_row(header: list[str], data_row: list[str]) -> tuple[dict[str, str], dict[str, object]]:
    params: dict[str, str] = {}
    display: dict[str, object] = {}
    for spec, value in zip(header, data_row):
        if ":" in spec:
            name, type_name = spec.split(":", 1)
        else:
            name, type_name = spec, None
        key = name.strip()
        kind = type_name.strip() if type_name else None
        params[key] = cypher_literal(value, kind)
        display[key] = display_value(value, kind)
    return params, display


def parse_typed_pipe_params(path: Path, row_number: int) -> tuple[dict[str, str], dict[str, object]]:
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


def parse_ic_row(header: list[str], data_row: list[str]) -> tuple[dict[str, str], dict[str, object]]:
    raw = {name: value for name, value in zip(header, data_row)}
    params = {name: cypher_literal(value) for name, value in raw.items() if name != "durationDays"}
    display = {name: display_value(value) for name, value in raw.items() if name != "durationDays"}
    if "startDate" in raw and "durationDays" in raw:
        end_millis = int(raw["startDate"]) + int(raw["durationDays"]) * 24 * 60 * 60 * 1000
        params["endDate"] = str(end_millis)
        display["endDate"] = end_millis
    return params, display


def parse_ic_params(path: Path, row_number: int) -> tuple[dict[str, str], dict[str, object]]:
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


def parse_finbench_row(query_number: int, data_row: list[str]) -> tuple[dict[str, str], dict[str, object]]:
    columns = FINBENCH_PARAM_COLUMNS.get(query_number)
    if columns is None:
        raise ValueError(f"no FinBench parameter mapping for query {query_number}")
    params: dict[str, str] = {}
    display: dict[str, object] = {}
    for name, value in zip(columns, data_row):
        if name.startswith("_"):
            continue
        params[name] = cypher_literal(value)
        display[name] = display_value(value)
    if query_number == 9:
        params.setdefault("lowerbound", "0.0")
        params.setdefault("upperbound", "1000000000.0")
        display.setdefault("lowerbound", 0.0)
        display.setdefault("upperbound", 1000000000.0)
    return params, display


def parse_finbench_params(path: Path, query_number: int, row_number: int) -> tuple[dict[str, str], dict[str, object]]:
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
            15: "bi-15a-without-date.csv" if "without-date" in rel else "bi-15a.csv",
            16: "bi-16a.csv",
            19: "bi-19a.csv",
            20: "bi-20a.csv",
        }
        name = specific.get(number, f"bi-{number}.csv")
        candidate = params_dir / name
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
    default_params: str,
) -> tuple[str, dict[str, object]]:
    number = query_number_from_rel(workload, rel)
    data_row = sampled_row(path, round_number, row_number)
    if workload.name == "ic-sf1":
        parsed, display = parse_ic_row(original_parameter_header(workload, rel), data_row)
    elif workload.name == "bi-sf1":
        parsed, display = parse_typed_pipe_row(original_parameter_header(workload, rel), data_row)
    elif workload.name == "finbench-sf1":
        if number is None:
            raise ValueError(f"cannot infer FinBench query number from {rel}")
        parsed, display = parse_finbench_row(number, data_row)
        if number in {9}:
            base = default_params.strip()
            merged = {}
            merged_display: dict[str, object] = {}
            if base.startswith("{") and base.endswith("}"):
                for key in ("lowerbound", "upperbound"):
                    match = re.search(rf"\b{key}\s*:\s*([^,}}]+)", base)
                    if match:
                        merged[key] = match.group(1).strip()
                        merged_display[key] = display_value(match.group(1).strip())
            merged.update(parsed)
            merged_display.update(display)
            parsed = merged
            display = merged_display
    else:
        parsed = {}
        display = {}
    display = {"_sampled_file": str(path), "_sample_round": round_number, **display}
    return params_to_cypher(parsed), display


def params_from_file(workload: Workload, rel: str, path: Path, row_number: int, default_params: str) -> tuple[str, dict[str, object]]:
    number = query_number_from_rel(workload, rel)
    if workload.name == "ic-sf1":
        parsed, display = parse_ic_params(path, row_number)
    elif workload.name == "bi-sf1":
        parsed, display = parse_typed_pipe_params(path, row_number)
    elif workload.name == "finbench-sf1":
        if number is None:
            raise ValueError(f"cannot infer FinBench query number from {rel}")
        parsed, display = parse_finbench_params(path, number, row_number)
        if number in {9}:
            base = default_params.strip()
            merged = {}
            merged_display: dict[str, object] = {}
            if base.startswith("{") and base.endswith("}"):
                # Keep only fallback values that file formats do not provide.
                for key in ("lowerbound", "upperbound"):
                    match = re.search(rf"\b{key}\s*:\s*([^,}}]+)", base)
                    if match:
                        merged[key] = match.group(1).strip()
                        merged_display[key] = display_value(match.group(1).strip())
            merged.update(parsed)
            merged_display.update(display)
            parsed = merged
            display = merged_display
    else:
        parsed = {}
        display = {}
    return params_to_cypher(parsed), display


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


def fallback_display_params(default_params: str) -> dict[str, object]:
    if default_params.strip() == "{}":
        return {}
    return {"_cypher": default_params}


def choose_params(
    workload: Workload,
    rel: str,
    default_params: str,
    params_file: Path | None,
    params_dir: Path | None,
    sampled_params_dir: Path | None,
    sample_round: int,
    row_number: int,
) -> tuple[str, dict[str, object]]:
    if params_file is not None:
        return params_from_file(workload, rel, params_file, row_number, default_params)
    if params_dir is None:
        sampled_dir = resolve_sampled_params_dir(workload, sampled_params_dir)
        if sampled_dir is not None and sampled_dir.exists():
            sampled_file = sampled_parameter_file_from_dir(workload, rel, sampled_dir)
            if sampled_file is not None:
                return sampled_params_from_file(workload, rel, sampled_file, sample_round, row_number, default_params)
    directory = params_dir or DEFAULT_PARAM_DIRS.get(workload.name)
    if directory is not None and directory.exists():
        auto_file = parameter_file_from_dir(workload, rel, directory)
        if auto_file is not None:
            return params_from_file(workload, rel, auto_file, row_number, default_params)
    return default_params, fallback_display_params(default_params)


def rel_path(workload: Workload, path: Path) -> str:
    try:
        return str(path.relative_to(workload.query_dir))
    except ValueError:
        return str(path)


def runnable_query(workload: Workload, query: str, mode: str, rel: str, allow_writes: bool) -> tuple[str, str]:
    is_finbench_write = workload.name == "finbench-sf1" and rel.startswith("tw-")
    if workload.name == "graphdblp":
        if mode == "execute":
            raise ValueError("graphdblp execution is intentionally disabled; use --mode explain")
        return "CYPHER connectComponentsPlanner=greedy EXPLAIN\n" + query, "EXPLAIN_GREEDY"
    if mode == "explain" or (is_finbench_write and not allow_writes):
        return "EXPLAIN\n" + query, "EXPLAIN_ONLY"
    return query, "EXECUTE"


def json_safe(value: object) -> object:
    if isinstance(value, (dt.datetime, dt.date)):
        return value.isoformat()
    if isinstance(value, dict):
        return {str(key): json_safe(item) for key, item in value.items()}
    if isinstance(value, (list, tuple)):
        return [json_safe(item) for item in value]
    try:
        json.dumps(value)
        return value
    except TypeError:
        return str(value)


def driver_param_value(key: str, value: object) -> object:
    if isinstance(value, str) and key in {
        "datetime",
        "date",
        "startDate",
        "endDate",
        "dateA",
        "dateB",
        "minDate",
        "maxDate",
        "start_time",
        "end_time",
        "currentTime",
    }:
        text = value.strip()
        if re.fullmatch(r"-?\d+", text):
            return int(text)
        normalized = text.replace("Z", "+00:00")
        if re.fullmatch(r"\d{4}-\d{2}-\d{2}$", normalized):
            return dt.datetime.combine(dt.date.fromisoformat(normalized), dt.time())
        if " " in normalized and "T" not in normalized:
            normalized = normalized.replace(" ", "T", 1)
        try:
            parsed = dt.datetime.fromisoformat(normalized)
            if parsed.tzinfo is not None:
                parsed = parsed.astimezone(dt.timezone.utc).replace(tzinfo=None)
            return parsed
        except ValueError:
            return value
    return value


def driver_params_for(query: str, display_params: dict[str, object]) -> dict[str, object]:
    names = set(re.findall(r"\$([A-Za-z_][A-Za-z0-9_]*)", query))
    return {
        key: driver_param_value(key, value)
        for key, value in display_params.items()
        if key in names and not key.startswith("_")
    }


def precompute_files_for(workload: Workload, query_path: Path, mode: str) -> list[Path]:
    if workload.name != "bi-sf1" or mode != "execute":
        return []
    rel = rel_path(workload, query_path)
    if rel == "bi19/bi-19.cypher":
        return [
            workload.query_dir / "bi19" / "bi-19-drop-graph.cypher",
            workload.query_dir / "bi19" / "bi-19-create-graph.cypher",
        ]
    if rel == "bi20/bi-20.cypher":
        return [
            workload.query_dir / "bi20" / "bi-20-drop-graph.cypher",
            workload.query_dir / "bi20" / "bi-20-create-graph.cypher",
        ]
    return []


def run_precomputations_for_query(
    workload: Workload,
    query_path: Path,
    mode: str,
    neo4j_home: Path,
    java_home: Path,
    timeout: int | None,
) -> dict | None:
    files = precompute_files_for(workload, query_path, mode)
    if not files:
        return None
    rel = rel_path(workload, query_path)
    for precompute_file in files:
        query = strip_shell_directives(precompute_file.read_text(encoding="utf-8"))
        start = time.monotonic()
        try:
            proc = cypher_shell(workload, query, neo4j_home, java_home, params="{}", timeout=timeout)
            elapsed = time.monotonic() - start
        except subprocess.TimeoutExpired as exc:
            return {
                "query": rel,
                "param_row": "",
                "status": "TIMEOUT",
                "seconds": timeout,
                "stderr": f"precompute timeout in {precompute_file.name}: {exc}",
            }
        if proc.returncode != 0:
            return {
                "query": rel,
                "param_row": "",
                "status": "FAIL",
                "seconds": round(elapsed, 6),
                "stderr": f"precompute failed in {precompute_file.name}: {proc.stderr[-4000:]}",
            }
    return None


def run_query(
    workload: Workload,
    path: Path,
    mode: str,
    allow_writes: bool,
    timeout: int | None,
    neo4j_home: Path,
    java_home: Path,
    plugin_dir: Path,
    params_file: Path | None,
    params_dir: Path | None = None,
    sampled_params_dir: Path | None = None,
    sample_round: int = 1,
    param_row: int = 1,
) -> dict:
    query = strip_shell_directives(path.read_text(encoding="utf-8"))
    rel = rel_path(workload, path)
    if not query:
        return {"query": rel, "param_row": param_row, "status": "SKIP", "reason": "empty query"}
    default_params = param_map(workload.name)
    params = param_override(workload, rel, default_params)
    try:
        params, display_params = choose_params(workload, rel, params, params_file, params_dir, sampled_params_dir, sample_round, param_row)
    except Exception as exc:
        return {"query": rel, "param_row": param_row, "status": "FAIL", "stderr": f"parameter error: {type(exc).__name__}: {exc}"}
    needed_plugins = required_plugins(query)
    missing_plugins = sorted(needed_plugins - active_plugins(plugin_dir))
    if missing_plugins:
        return {
            "query": rel,
            "param_row": param_row,
            "params": params,
            "display_params": display_params,
            "status": "SKIP",
            "reason": f"requires unavailable Neo4j plugin(s): {', '.join(missing_plugins)}",
        }
    try:
        runnable, run_mode = runnable_query(workload, query, mode, rel, allow_writes)
    except ValueError as exc:
        return {"query": rel, "param_row": param_row, "status": "SKIP", "reason": str(exc)}
    start = time.monotonic()
    try:
        proc = cypher_shell(workload, runnable, neo4j_home, java_home, params=params, timeout=timeout)
        elapsed = time.monotonic() - start
    except subprocess.TimeoutExpired as exc:
        return {
            "query": rel,
            "param_row": param_row,
            "params": params,
            "display_params": display_params,
            "status": "TIMEOUT",
            "seconds": timeout,
            "stderr": str(exc),
            "mode": run_mode,
        }
    return {
        "query": rel,
        "param_row": param_row,
        "params": params,
        "display_params": display_params,
        "status": "OK" if proc.returncode == 0 else "FAIL",
        "seconds": round(elapsed, 6),
        "stdout": proc.stdout,
        "stderr": proc.stderr[-4000:],
        "mode": run_mode,
    }


def run_query_persistent(
    session: object,
    workload: Workload,
    path: Path,
    mode: str,
    allow_writes: bool,
    plugin_dir: Path,
    fetch_rows: int = 0,
    params_file: Path | None = None,
    params_dir: Path | None = None,
    sampled_params_dir: Path | None = None,
    sample_round: int = 1,
    param_row: int = 1,
) -> dict:
    query = strip_shell_directives(path.read_text(encoding="utf-8"))
    rel = rel_path(workload, path)
    if not query:
        return {"query": rel, "param_row": param_row, "status": "SKIP", "reason": "empty query"}
    default_params = param_map(workload.name)
    params = param_override(workload, rel, default_params)
    try:
        params, display_params = choose_params(workload, rel, params, params_file, params_dir, sampled_params_dir, sample_round, param_row)
    except Exception as exc:
        return {"query": rel, "param_row": param_row, "status": "FAIL", "stderr": f"parameter error: {type(exc).__name__}: {exc}"}
    needed_plugins = required_plugins(query)
    missing_plugins = sorted(needed_plugins - active_plugins(plugin_dir))
    if missing_plugins:
        return {
            "query": rel,
            "param_row": param_row,
            "params": params,
            "display_params": display_params,
            "status": "SKIP",
            "reason": f"requires unavailable Neo4j plugin(s): {', '.join(missing_plugins)}",
        }
    try:
        runnable, run_mode = runnable_query(workload, query, mode, rel, allow_writes)
    except ValueError as exc:
        return {"query": rel, "param_row": param_row, "status": "SKIP", "reason": str(exc)}
    driver_params = driver_params_for(query, display_params)
    start = time.monotonic()
    try:
        result = session.run(runnable, driver_params)
        rows = []
        for record in result:
            if fetch_rows == 0 or len(rows) < fetch_rows:
                rows.append(json_safe(record.data()))
        summary = result.consume()
        elapsed = time.monotonic() - start
        return {
            "query": rel,
            "param_row": param_row,
            "params": params,
            "display_params": display_params,
            "status": "OK",
            "seconds": round(elapsed, 6),
            "rows": rows,
            "stderr": "",
            "mode": run_mode,
            "neo4j_result_available_after_ms": summary.result_available_after,
            "neo4j_result_consumed_after_ms": summary.result_consumed_after,
        }
    except Exception as exc:
        elapsed = time.monotonic() - start
        return {
            "query": rel,
            "param_row": param_row,
            "params": params,
            "display_params": display_params,
            "status": "FAIL",
            "seconds": round(elapsed, 6),
            "stderr": f"{type(exc).__name__}: {exc}",
            "mode": run_mode,
        }


def split_top_level(text: str, delimiter: str = ",") -> list[str]:
    parts: list[str] = []
    start = 0
    depth = 0
    quote: str | None = None
    escape = False
    pairs = {"[": "]", "{": "}", "(": ")"}
    closers = set(pairs.values())
    for idx, char in enumerate(text):
        if escape:
            escape = False
            continue
        if char == "\\":
            escape = True
            continue
        if quote is not None:
            if char == quote:
                quote = None
            continue
        if char in {"'", '"'}:
            quote = char
            continue
        if char in pairs:
            depth += 1
            continue
        if char in closers and depth > 0:
            depth -= 1
            continue
        if char == delimiter and depth == 0:
            parts.append(text[start:idx].strip())
            start = idx + 1
    parts.append(text[start:].strip())
    return parts


def parse_scalar(text: str) -> object:
    value = text.strip()
    if value == "":
        return ""
    if value.lower() == "null":
        return None
    if value.lower() == "true":
        return True
    if value.lower() == "false":
        return False
    if (value.startswith("[") and value.endswith("]")) or (value.startswith("{") and value.endswith("}")):
        try:
            return json.loads(value)
        except json.JSONDecodeError:
            if value.startswith("[") and value.endswith("]"):
                inner = value[1:-1].strip()
                if inner == "":
                    return []
                return [parse_scalar(item) for item in split_top_level(inner)]
    if re.fullmatch(r"-?\d+", value):
        return int(value)
    if re.fullmatch(r"-?\d+\.\d+(?:[eE][+-]?\d+)?", value) or re.fullmatch(r"-?\d+[eE][+-]?\d+", value):
        return float(value)
    if (value.startswith('"') and value.endswith('"')) or (value.startswith("'") and value.endswith("'")):
        return value[1:-1]
    return value


def parse_plain_stdout(stdout: str) -> list[dict[str, object]]:
    lines = [line.rstrip("\r") for line in stdout.splitlines() if line.strip()]
    if not lines:
        return []
    # Neo4j cypher-shell --format plain commonly prints a header line followed
    # by data rows. Comma-formatted rows can contain list/map values such as
    # [1, 2, 3], so comma splitting must happen only at top level.
    if any(line.startswith("+") or line.startswith("|") for line in lines[:3]):
        return [{"raw": stdout}]
    delimiter = "\t" if "\t" in lines[0] else ","
    if delimiter == "\t":
        reader = csv.reader(lines, delimiter=delimiter)
        rows = list(reader)
        if not rows:
            return []
        header = [cell.strip() for cell in rows[0]]
        data_rows = rows[1:]
    elif len(lines) >= 2 and "," not in lines[0]:
        header = [lines[0].strip()]
        data_rows = [[line] for line in lines[1:]]
    else:
        header = split_top_level(lines[0])
        data_rows = [split_top_level(line) for line in lines[1:]]
    return [
        {key: parse_scalar(value) for key, value in zip(header, row)}
        for row in data_rows
    ]


def csv_query_name(query: str) -> str:
    parts = Path(query).parts
    if len(parts) >= 2 and re.fullmatch(r"(?:ic|bi)\d+", parts[0]):
        return parts[0]
    if len(parts) >= 2 and re.fullmatch(r"q\d+", parts[0]):
        return parts[0]
    name = Path(query).name
    return name[:-7] if name.endswith(".cypher") else query


def result_cell(result: dict) -> str:
    status = result.get("status", "")
    if status == "OK":
        if "rows" in result:
            return json.dumps(result.get("rows", []), ensure_ascii=False)
        return json.dumps(parse_plain_stdout(result.get("stdout", "")), ensure_ascii=False)
    if status == "SKIP":
        return json.dumps([{"status": "SKIP", "message": result.get("reason", "")}], ensure_ascii=False)
    if status == "TIMEOUT":
        return json.dumps([{"status": "TIMEOUT", "message": result.get("stderr", "")}], ensure_ascii=False)
    if result.get("stderr"):
        return json.dumps([{"status": status, "message": result.get("stderr", "")}], ensure_ascii=False)
    return json.dumps([{"status": status}], ensure_ascii=False)


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


def write_csv_results(path: Path, results: list[dict]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["query", "sample_round", "phase", "iteration", "parameter_index", "parameters", "results", "time_seconds", "setup_time_seconds"],
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
                    "parameters": json.dumps(result.get("display_params", {}), ensure_ascii=False),
                    "results": result_cell(result),
                    "time_seconds": result.get("seconds", ""),
                    "setup_time_seconds": result.get("setup_seconds", ""),
                }
            )


def mean(values: list[float]) -> float:
    return sum(values) / len(values)


def default_summary_path(out: Path) -> Path:
    suffix = out.suffix or ".csv"
    if out.stem.endswith("-results"):
        return out.with_name(f"{out.stem.removesuffix('-results')}-summary{suffix}")
    return out.with_name(f"{out.stem}-summary{suffix}")


def default_results_path(workload_name: str, mode: str, run_timestamp: str) -> Path:
    return DEFAULT_RESULTS_ROOT / workload_name / f"{mode}-{run_timestamp}-results.csv"


def build_summary_rows(results: list[dict]) -> list[dict[str, object]]:
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

    rows: list[dict[str, object]] = []
    round_groups: dict[tuple[str, int], list[float]] = {}
    round_param_counts: dict[tuple[str, int], int] = {}
    for (query, sample_round, iteration), values in sorted(iteration_groups.items()):
        avg = mean(values)
        round_groups.setdefault((query, sample_round), []).append(avg)
        round_param_counts[(query, sample_round)] = max(
            round_param_counts.get((query, sample_round), 0),
            iteration_param_counts[(query, sample_round, iteration)],
        )

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


def write_summary_results(path: Path, rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["query", "sample_round", "performance_iterations", "param_count", "avg_time_seconds"],
            delimiter="|",
        )
        writer.writeheader()
        writer.writerows(rows)


def default_wide_summary_path(summary_out: Path) -> Path:
    suffix = summary_out.suffix or ".csv"
    if summary_out.stem.endswith("-summary"):
        return summary_out.with_name(f"{summary_out.stem.removesuffix('-summary')}-summary-wide{suffix}")
    return summary_out.with_name(f"{summary_out.stem}-wide{suffix}")


def build_wide_summary_rows(rows: list[dict[str, object]]) -> tuple[list[str], list[dict[str, object]]]:
    rounds = sorted({int(row["sample_round"]) for row in rows})
    fieldnames = ["query", *[f"t{round_number}" for round_number in rounds]]
    grouped: dict[str, dict[str, object]] = {}
    for row in rows:
        query = str(row["query"])
        grouped.setdefault(query, {"query": query})
        grouped[query][f"t{int(row['sample_round'])}"] = row["avg_time_seconds"]
    return fieldnames, [grouped[query] for query in sorted(grouped)]


def write_wide_summary_results(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter="|")
        writer.writeheader()
        writer.writerows(rows)


def print_wide_summary(fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    if not rows:
        return
    widths = {field: max(len(field), *(len(str(row.get(field, ""))) for row in rows)) for field in fieldnames}
    print("wide summary:")
    print(" ".join(field.ljust(widths[field]) for field in fieldnames))
    for row in rows:
        print(" ".join(str(row.get(field, "")).ljust(widths[field]) for field in fieldnames))

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--workload", choices=sorted(WORKLOADS), required=True)
    parser.add_argument("--mode", choices=["explain", "execute"], default=None)
    parser.add_argument("--runner", choices=["isolated", "persistent"], default="isolated", help="isolated runs each parameter through cypher-shell; persistent reuses one Bolt driver session")
    parser.add_argument("--timeout", type=int, default=None, help="optional per-query timeout in seconds; omitted means no query timeout")
    parser.add_argument("--work-dir", type=Path, default=Path("/tmp/neo4j-workload-runner"))
    parser.add_argument("--out", type=Path, default=None)
    parser.add_argument("--neo4j-home", type=Path, default=DEFAULT_NEO4J_HOME)
    parser.add_argument("--java-home", type=Path, default=DEFAULT_JAVA_HOME)
    parser.add_argument("--plugin-dir", type=Path, action="append", default=[], help="additional directory containing Neo4j plugin jars; can be repeated")
    parser.add_argument("--include-setup", action="store_true", help="include setup/drop Cypher files normally skipped")
    parser.add_argument("--skip-plugin-queries", action="store_true", help="skip queries containing gds. or apoc.")
    parser.add_argument("--allow-writes", action="store_true", help="execute FinBench tw-* write queries instead of EXPLAIN")
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
    args = parser.parse_args()

    workload = WORKLOADS[args.workload]
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
    sampled_round_requested = args.sample_rounds is not None or args.sample_round != 1 or args.sampled_params_dir is not None
    warmup_count = args.warmup_count if args.warmup_count is not None else (1 if (args.runner == "persistent" or args.warmup or sampled_round_requested) else 0)
    if warmup_count < 0:
        print("--warmup-count must be >= 0", file=sys.stderr)
        return 2
    if args.performance_count < 1:
        print("--performance-count must be >= 1", file=sys.stderr)
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
    for plugin_dir in args.plugin_dir:
        if not plugin_dir.exists():
            print(f"--plugin-dir does not exist: {plugin_dir}", file=sys.stderr)
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
            queries = queries_for(workload, args.include_setup, args.skip_plugin_queries)
            if args.start_at < 1:
                print("--start-at must be >= 1", file=sys.stderr)
                return 2
            start_index = args.start_at
            queries = queries[args.start_at - 1 :]
            if args.limit:
                queries = queries[: args.limit]
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 2

    run_timestamp = dt.datetime.now().strftime(RUN_TIMESTAMP_FORMAT)
    out = args.out or default_results_path(workload.name, mode, run_timestamp)
    args.work_dir.mkdir(parents=True, exist_ok=True)
    out.parent.mkdir(parents=True, exist_ok=True)

    process = None
    driver = None
    session = None
    results = []
    try:
        plugin_dir = prepare_plugins(workload, args.work_dir, args.neo4j_home, args.plugin_dir)
        print(f"== plugins: {plugin_dir} ({', '.join(sorted(active_plugins(plugin_dir))) or 'none'}) ==", flush=True)
        print(f"== starting {workload.name} on bolt {workload.bolt_port} ==", flush=True)
        process, _conf_dir = start_neo4j(workload, args.work_dir, args.neo4j_home, args.java_home, plugin_dir)
        if args.runner == "persistent":
            from neo4j import GraphDatabase

            driver = GraphDatabase.driver(f"bolt://127.0.0.1:{workload.bolt_port}", auth=None)
            session = driver.session(database="neo4j")
        print(
            f"== running {len(queries)} query files x rounds {sample_rounds} "
            f"x {warmup_count} warmup + {args.performance_count} performance iteration(s) "
            f"in {mode} mode with {args.runner} runner ==",
            flush=True,
        )
        for idx, query_path in enumerate(queries, start_index):
            rel = rel_path(workload, query_path)
            print(f"[{idx}] {rel}", flush=True)
            query_text = strip_shell_directives(query_path.read_text(encoding="utf-8"))
            missing_for_query = sorted(required_plugins(query_text) - active_plugins(plugin_dir))
            precompute_error = None
            if not missing_for_query:
                precompute_error = run_precomputations_for_query(
                    workload,
                    query_path,
                    mode,
                    args.neo4j_home,
                    args.java_home,
                    args.timeout,
                )
            if precompute_error is not None:
                print(f"  precompute {precompute_error['status']} {precompute_error.get('seconds', '')}", flush=True)
                results.append(precompute_error)
                continue
            phases = [("warmup", warmup_count), ("performance", args.performance_count)]
            for sample_round in sample_rounds:
                sampled_count = None
                if args.params_file is None and args.params_dir is None:
                    try:
                        sampled_count = sampled_param_count_for_query(
                            workload,
                            rel,
                            args.sampled_params_dir,
                            sample_round,
                        )
                    except Exception as exc:
                        results.append(
                            {
                                "query": rel,
                                "sample_round": sample_round,
                                "status": "FAIL",
                                "stderr": f"sampled parameter error: {type(exc).__name__}: {exc}",
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
                            "stderr": f"no parameter rows selected for round {sample_round}",
                        }
                    )
                    print(f"  round={sample_round} FAIL no parameter rows selected", flush=True)
                    continue
                print(f"  round={sample_round} params={row_count}", flush=True)
                round_iteration_averages: list[float] = []
                for phase, iteration_count in phases:
                    for iteration in range(1, iteration_count + 1):
                        iteration_seconds = []
                        for param_row in range(args.param_row, args.param_row + row_count):
                            if args.runner == "persistent":
                                assert session is not None
                                result = run_query_persistent(
                                    session,
                                    workload,
                                    query_path,
                                    mode,
                                    args.allow_writes,
                                    plugin_dir,
                                    0,
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
                                    args.neo4j_home,
                                    args.java_home,
                                    plugin_dir,
                                    0,
                                    args.params_file,
                                    args.params_dir,
                                    args.sampled_params_dir,
                                    sample_round,
                                    param_row,
                                )
                            result["phase"] = phase
                            result["iteration"] = iteration
                            result["sample_round"] = sample_round
                            if result.get("status") == "OK" and isinstance(result.get("seconds"), int | float):
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
    except Exception as exc:
        results.append({"query": "__workload__", "status": "ERROR", "stderr": str(exc)})
        print(f"ERROR: {exc}", file=sys.stderr)
    finally:
        if session is not None:
            session.close()
        if driver is not None:
            driver.close()
        if process:
            stop_process(process)

    summary_out = default_summary_path(out)
    wide_summary_out = default_wide_summary_path(summary_out)
    summary_rows = build_summary_rows(results)
    wide_fieldnames, wide_rows = build_wide_summary_rows(summary_rows)
    write_csv_results(out, results)
    write_summary_results(summary_out, summary_rows)
    write_wide_summary_results(wide_summary_out, wide_fieldnames, wide_rows)
    ok = sum(1 for item in results if item.get("status") == "OK")
    failed = [item for item in results if item.get("status") not in {"OK", "SKIP"}]
    skipped = sum(1 for item in results if item.get("status") == "SKIP")
    print_wide_summary(wide_fieldnames, wide_rows)
    print(f"wrote {out}")
    print(f"wrote {summary_out}")
    print(f"wrote {wide_summary_out}")
    print(f"summary: ok={ok} skipped={skipped} failed_or_timeout={len(failed)}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
