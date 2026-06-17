#!/usr/bin/env python3
import argparse
import json
import os
import re
import shutil
import socket
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path


QUERY_ROOT = Path("/root/workspace/IncGQ/IncGQ-experiment-docs/Neo4j/queries")
NEO4J_HOME = Path("/mnt/data/imported_data/neo4j/bi-sf1/tools/neo4j-community-5.20.0")
JAVA_HOME = Path("/mnt/data/imported_data/neo4j/bi-sf1/tools/jdk-17.0.19+10-jre")


@dataclass
class Dataset:
    name: str
    db_dir: Path
    query_dir: Path
    bolt_port: int
    heap: str = "4G"


DATASETS = {
    "lsqb": Dataset(
        "lsqb",
        Path("/mnt/data/imported_data/neo4j/lsqb/sf1"),
        QUERY_ROOT / "lsqb",
        17687,
    ),
    "ic": Dataset(
        "ic",
        Path("/mnt/data/imported_data/neo4j/ic-sf1"),
        QUERY_ROOT / "ldbc-ic",
        17688,
    ),
    "bi": Dataset(
        "bi",
        Path("/mnt/data/imported_data/neo4j/bi-sf1"),
        QUERY_ROOT / "ldbc-bi",
        17689,
        "6G",
    ),
    "finbench": Dataset(
        "finbench",
        Path("/mnt/data/imported_data/neo4j/finbench/sf1"),
        QUERY_ROOT / "finbench",
        17690,
    ),
}


def env_for(conf_dir: Path, heap: str) -> dict[str, str]:
    env = os.environ.copy()
    env["JAVA_HOME"] = str(JAVA_HOME)
    env["NEO4J_CONF"] = str(conf_dir)
    env["HEAP_SIZE"] = heap
    return env


def write_conf(dataset: Dataset, work_dir: Path) -> Path:
    conf_dir = work_dir / dataset.name / "conf"
    logs_dir = work_dir / dataset.name / "logs"
    run_dir = work_dir / dataset.name / "run"
    conf_dir.mkdir(parents=True, exist_ok=True)
    logs_dir.mkdir(parents=True, exist_ok=True)
    run_dir.mkdir(parents=True, exist_ok=True)
    (conf_dir / "neo4j.conf").write_text(
        "\n".join(
            [
                f"server.directories.data={dataset.db_dir / 'data'}",
                f"server.directories.logs={logs_dir}",
                f"server.directories.run={run_dir}",
                "server.default_listen_address=127.0.0.1",
                f"server.bolt.listen_address=127.0.0.1:{dataset.bolt_port}",
                "server.http.enabled=false",
                "dbms.security.auth_enabled=false",
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


def cypher_shell(dataset: Dataset, query: str, params: str = "", timeout: int = 60) -> subprocess.CompletedProcess:
    cmd = [
        str(NEO4J_HOME / "bin" / "cypher-shell"),
        "--non-interactive",
        "--format",
        "plain",
        "-a",
        f"bolt://127.0.0.1:{dataset.bolt_port}",
        "-d",
        "neo4j",
    ]
    if params:
        cmd.extend(["-P", params])
    cmd.append(query)
    return subprocess.run(
        cmd,
        env={**os.environ, "JAVA_HOME": str(JAVA_HOME)},
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=timeout,
    )


def start_neo4j(dataset: Dataset, work_dir: Path) -> tuple[subprocess.Popen, Path]:
    conf_dir = write_conf(dataset, work_dir)
    process = subprocess.Popen(
        [str(NEO4J_HOME / "bin" / "neo4j"), "console"],
        env=env_for(conf_dir, dataset.heap),
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    deadline = time.time() + 120
    output = []
    while time.time() < deadline:
        if process.poll() is not None:
            if process.stdout:
                output.extend(process.stdout.readlines())
            raise RuntimeError(f"Neo4j exited while starting {dataset.name}:\n{''.join(output[-80:])}")
        if port_open(dataset.bolt_port):
            probe = cypher_shell(dataset, "RETURN 1 AS ok", timeout=15)
            if probe.returncode == 0:
                return process, conf_dir
        time.sleep(1)
    stop_process(process)
    raise RuntimeError(f"Timed out waiting for Neo4j {dataset.name} on port {dataset.bolt_port}")


def stop_process(process: subprocess.Popen) -> None:
    if process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=30)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=10)


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    lines = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("//") or stripped.startswith(":param") or stripped.startswith(":params"):
            continue
        lines.append(line)
    return "\n".join(lines).strip()


def queries_for(dataset: Dataset) -> list[Path]:
    files = sorted(dataset.query_dir.rglob("*.cypher"))
    if dataset.name == "lsqb":
        files = [path for path in files if path.name != "schema.cypher"]
    if dataset.name == "bi":
        # The GDS-backed files require an installed Neo4j Graph Data Science plugin.
        files = [
            path
            for path in files
            if not path.name.endswith("-create-graph.cypher")
            and not path.name.endswith("-drop-graph.cypher")
        ]
    return files


def param_map(dataset: str) -> str:
    if dataset == "ic":
        return (
            "{personId: 0, person1Id: 0, person2Id: 1, firstName: 'Alice', "
            "countryName: 'China', countryXName: 'China', countryYName: 'India', "
            "tagClassName: 'Thing', tagName: 'music', month: 1, workFromYear: 2010, "
            "startDate: 1262304000000, endDate: 1893456000000, minDate: 1262304000000, maxDate: 1893456000000}"
        )
    if dataset == "bi":
        return (
            "{datetime: datetime('2012-01-01T00:00:00.000'), date: datetime('2012-06-01T00:00:00.000'), "
            "startDate: datetime('2010-01-01T00:00:00.000'), endDate: datetime('2030-01-01T00:00:00.000'), "
            "dateA: datetime('2011-01-01T00:00:00.000'), dateB: datetime('2013-01-01T00:00:00.000'), "
            "country: 'China', country1: 'China', country2: 'India', tagClass: 'Thing', tag: 'music', "
            "languages: ['en'], lengthThreshold: 100, personId: 0, person1Id: 0, person2Id: 1, "
            "city1Id: 0, city2Id: 1, minPathDistance: 1, maxPathDistance: 3, maxKnowsLimit: 10, "
            "tagA: 'music', tagB: 'sports', delta: 1, company: 'Acme'}"
        )
    if dataset == "finbench":
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


def query_param_override(dataset: Dataset, rel: str, default_params: str) -> str:
    if dataset.name != "finbench":
        return default_params
    overrides = {
        "finbench/tcr-9.cypher": (
            "{id: 4908924693345483908, start_time: '2020-01-01 00:00:00.000', "
            "end_time: '2030-01-01 00:00:00.000', threshold: 0.0, lowerbound: 0.0, upperbound: 1000000000.0}"
        ),
        "finbench/tcr-12.cypher": (
            "{id: 33065, start_time: '2020-01-01 00:00:00.000', end_time: '2030-01-01 00:00:00.000'}"
        ),
        "finbench/tsr-3.cypher": (
            "{id: 4750735206678266224, start_time: '2020-01-01 00:00:00.000', "
            "end_time: '2030-01-01 00:00:00.000', threshold: 0.0}"
        ),
    }
    return overrides.get(rel, default_params)


def run_query(dataset: Dataset, path: Path, mode: str, timeout: int) -> dict:
    query = strip_comments(path.read_text(encoding="utf-8"))
    if not query:
        return {"query": str(path), "status": "SKIP", "reason": "empty query"}

    rel = str(path.relative_to(QUERY_ROOT))
    params = query_param_override(dataset, rel, param_map(dataset.name))
    is_write = dataset.name == "finbench" and "/tw-" in rel
    if mode == "explain":
        runnable = "EXPLAIN\n" + query
        timeout = min(timeout, 30)
    elif is_write:
        # Validate the write query can be planned without changing the imported database.
        runnable = "EXPLAIN\n" + query
        timeout = min(timeout, 30)
    else:
        runnable = query

    start = time.monotonic()
    try:
        proc = cypher_shell(dataset, runnable, params=params, timeout=timeout)
        elapsed = time.monotonic() - start
    except subprocess.TimeoutExpired as exc:
        return {"query": rel, "status": "TIMEOUT", "seconds": timeout, "stderr": str(exc)}

    status = "OK" if proc.returncode == 0 else "FAIL"
    return {
        "query": rel,
        "status": status,
        "seconds": round(elapsed, 3),
        "stdout": proc.stdout[-2000:],
        "stderr": proc.stderr[-4000:],
        "write_mode": "EXPLAIN_ONLY" if is_write or mode == "explain" else "EXECUTE",
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--datasets", nargs="+", choices=sorted(DATASETS), default=sorted(DATASETS))
    parser.add_argument("--mode", choices=["execute", "explain"], default="execute")
    parser.add_argument("--timeout", type=int, default=60)
    parser.add_argument("--work-dir", type=Path, default=Path("/tmp/neo4j-query-verify"))
    parser.add_argument("--out", type=Path, default=Path("/tmp/neo4j-query-verify/results.json"))
    args = parser.parse_args()

    args.work_dir.mkdir(parents=True, exist_ok=True)
    results = {}
    for name in args.datasets:
        dataset = DATASETS[name]
        print(f"== starting {name} ==", flush=True)
        process = None
        dataset_results = []
        try:
            process, _conf_dir = start_neo4j(dataset, args.work_dir)
            for query in queries_for(dataset):
                rel = query.relative_to(QUERY_ROOT)
                print(f"running {rel}", flush=True)
                result = run_query(dataset, query, args.mode, args.timeout)
                print(f"  {result['status']} {result.get('seconds', '')}", flush=True)
                dataset_results.append(result)
        except Exception as exc:
            dataset_results.append({"query": "__dataset__", "status": "ERROR", "stderr": str(exc)})
        finally:
            if process:
                stop_process(process)
        results[name] = dataset_results

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(results, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"wrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
