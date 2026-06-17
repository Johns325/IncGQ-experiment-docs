#!/usr/bin/env python3
from pathlib import Path


ROOT = Path("/root/workspace/IncGQ/IncGQ-experiment-docs/Kuzu")


RUN_BENCHMARK = r'''#!/usr/bin/env python3
"""Run Kuzu baseline or optimization workloads with fixed benchmark semantics.

Benchmark semantics:

* baseline: run queries from ``queries/baseline/<dataset>``.
* optimization: first run the corresponding materialization script from
  ``queries/index/<dataset>/<query>/index.cypher`` if it exists, then run the
  query from ``queries/optimized/<dataset>``.
* Warmup: each selected parameter row is executed once by default and is not
  included in the summary.
* Performance: each selected parameter row is executed three times by default.
  For each performance iteration, the runner averages over the selected
  parameter rows; then it averages those per-iteration means.

The script intentionally records index/materialization setup time separately and
does not add it into the measured query time.
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import importlib.util
import json
import multiprocessing as mp
import re
import sys
import time
from dataclasses import replace
from pathlib import Path
from typing import Any


THIS_DIR = Path(__file__).resolve().parent
KUZU_ROOT = THIS_DIR.parent
REPO_ROOT = KUZU_ROOT.parent
QUERY_ROOT = KUZU_ROOT / "queries"
RUN_WORKLOAD = THIS_DIR / "run-workload.py"
RUN_TIMESTAMP_FORMAT = "%Y%m%d-%H%M%S"
QUERY_SET_DIRS = {
    "baseline": "baseline",
    "optimization": "optimized",
}
DATASET_DIRS = {
    "ic-sf1": "ldbc-ic",
    "bi-sf1": "ldbc-bi",
    "lsqb-sf1": "lsqb",
    "finbench-sf1": "finbench",
}


def load_run_workload_module():
    spec = importlib.util.spec_from_file_location("kuzu_run_workload_shared", RUN_WORKLOAD)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {RUN_WORKLOAD}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


rw = load_run_workload_module()


def strip_semicolon_statements(text: str) -> list[str]:
    stripped = rw.strip_query(text)
    if not stripped:
        return []
    statements: list[str] = []
    current: list[str] = []
    in_single = False
    in_double = False
    escape = False
    for char in stripped:
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


def dataset_dir_for(workload_name: str) -> str:
    try:
        return DATASET_DIRS[workload_name]
    except KeyError as exc:
        raise ValueError(f"no query directory mapping for workload {workload_name}") from exc


def workload_for_query_set(workload_name: str, query_set: str):
    base = rw.WORKLOADS[workload_name]
    dataset_dir = dataset_dir_for(workload_name)
    query_dir = QUERY_ROOT / QUERY_SET_DIRS[query_set] / dataset_dir
    return replace(base, query_dir=query_dir)


def index_root_for(workload_name: str) -> Path:
    return QUERY_ROOT / "index" / dataset_dir_for(workload_name)


def index_setup_path(workload, query_path: Path) -> Path | None:
    rel = rw.rel_path(workload, query_path)
    first = Path(rel).parts[0] if Path(rel).parts else ""
    if not first:
        return None
    candidate = index_root_for(workload.name) / first / "index.cypher"
    return candidate if candidate.exists() else None


def run_materialization(conn: object, setup_path: Path, fetch_rows: int) -> dict[str, Any]:
    statements = strip_semicolon_statements(setup_path.read_text(encoding="utf-8"))
    rel = str(setup_path.relative_to(QUERY_ROOT)) if setup_path.is_relative_to(QUERY_ROOT) else str(setup_path)
    if not statements:
        return {"query": rel, "phase": "index_setup", "status": "SKIP", "reason": "empty setup"}
    started = time.monotonic()
    statement_results = []
    try:
        for idx, statement in enumerate(statements, start=1):
            statement_started = time.monotonic()
            raw_result = conn.execute(statement, {})
            rows, result = rw.materialize_kuzu_result(raw_result, fetch_rows)
            statement_results.append(
                {
                    "statement": idx,
                    "seconds": round(time.monotonic() - statement_started, 6),
                    "compile_ms": result.get_compiling_time(),
                    "execute_ms": result.get_execution_time(),
                    "rows": rows,
                }
            )
        return {
            "query": rel,
            "phase": "index_setup",
            "status": "OK",
            "seconds": round(time.monotonic() - started, 6),
            "mode": "INDEX_SETUP",
            "statement_count": len(statements),
            "setup_details": statement_results,
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
            "completed_statements": len(statement_results),
        }


def resolve_queries(workload, args: argparse.Namespace) -> tuple[list[Path], int]:
    if args.query and args.queries:
        raise ValueError("use either --query or --queries, not both")
    if args.queries:
        query_names = [item.strip() for item in args.queries.split(",") if item.strip()]
        if not query_names:
            raise ValueError("--queries did not contain any query name")
        return [rw.resolve_one_query(workload, query_name) for query_name in query_names], 1
    if args.query:
        return [rw.resolve_one_query(workload, args.query)], 1
    if args.start_at < 1:
        raise ValueError("--start-at must be >= 1")
    queries = rw.queries_for(workload, args.include_setup)[args.start_at - 1 :]
    if args.limit:
        queries = queries[: args.limit]
    return queries, args.start_at


def selected_param_count(workload, rel: str, args: argparse.Namespace, sample_round: int) -> int:
    sampled_count = None
    if args.params_file is None and args.params_dir is None:
        sampled_count = rw.sampled_param_count_for_query(workload, rel, args.sampled_params_dir, sample_round)
    if args.param_count is None:
        row_count = sampled_count - args.param_row + 1 if sampled_count is not None else 1
    else:
        row_count = args.param_count
    if row_count < 1:
        raise ValueError(f"no parameter rows selected for round {sample_round}")
    return row_count


def csv_query_set_out(work_dir: Path, query_set: str, workload_name: str, run_timestamp: str) -> Path:
    return work_dir / query_set / workload_name / f"{query_set}-{run_timestamp}-results.csv"


def append_setup_csv_fields(results: list[dict[str, Any]]) -> None:
    for result in results:
        if result.get("phase") == "index_setup":
            result.setdefault("sample_round", "")
            result.setdefault("iteration", "")
            result.setdefault("param_row", "")
            result.setdefault("display_params", {})


def validate_args(args: argparse.Namespace) -> None:
    if args.param_row < 1:
        raise ValueError("--param-row must be >= 1")
    if args.param_count is not None and args.param_count < 1:
        raise ValueError("--param-count must be >= 1")
    if args.sample_round < 1:
        raise ValueError("--sample-round must be >= 1")
    if args.warmup_count < 0:
        raise ValueError("--warmup-count must be >= 0")
    if args.performance_count < 1:
        raise ValueError("--performance-count must be >= 1")
    if args.fetch_rows < 0:
        raise ValueError("--fetch-rows must be >= 0")
    if args.params_file is not None:
        args.params_file = rw.resolve_params_file_arg(args.params_file)
        if not args.params_file.exists():
            raise ValueError(f"--params-file does not exist: {args.params_file}")
    if args.params_dir is not None and not args.params_dir.exists():
        raise ValueError(f"--params-dir does not exist: {args.params_dir}")
    if args.sampled_params_dir is not None and not args.sampled_params_dir.exists():
        raise ValueError(f"--sampled-params-dir does not exist: {args.sampled_params_dir}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--query-set", choices=sorted(QUERY_SET_DIRS), required=True)
    parser.add_argument("--workload", choices=sorted(rw.WORKLOADS), required=True)
    parser.add_argument("--mode", choices=["explain", "execute"], default="execute")
    parser.add_argument("--timeout", type=int, default=None, help="accepted for CLI compatibility; persistent benchmark runs ignore it")
    parser.add_argument("--work-dir", type=Path, default=rw.DEFAULT_RESULTS_ROOT)
    parser.add_argument("--db-dir", type=Path, default=None, help="override the workload Kuzu database directory")
    parser.add_argument("--out", type=Path, default=None)
    parser.add_argument("--include-setup", action="store_true")
    parser.add_argument("--query", default=None)
    parser.add_argument("--queries", default=None)
    parser.add_argument("--params-file", type=Path, default=None)
    parser.add_argument("--params-dir", type=Path, default=None)
    parser.add_argument("--sampled-params-dir", type=Path, default=None)
    parser.add_argument("--sample-round", type=int, default=1)
    parser.add_argument("--sample-rounds", default=None)
    parser.add_argument("--param-row", type=int, default=1)
    parser.add_argument("--param-count", type=int, default=None)
    parser.add_argument("--warmup-count", type=int, default=1)
    parser.add_argument("--performance-count", type=int, default=3)
    parser.add_argument("--skip-index-setup", action="store_true", help="optimization only: do not run queries/index materialization scripts")
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--start-at", type=int, default=1)
    parser.add_argument("--fetch-rows", type=int, default=0)
    args = parser.parse_args()

    try:
        validate_args(args)
        sample_rounds = rw.parse_sample_rounds(args.sample_rounds, args.sample_round)
        workload = workload_for_query_set(args.workload, args.query_set)
        if args.db_dir is not None:
            workload = replace(workload, db_dir=args.db_dir)
        if not workload.db_dir.exists():
            raise ValueError(f"database directory does not exist: {workload.db_dir}")
        if workload.query_dir is None or not workload.query_dir.exists():
            raise ValueError(f"query directory does not exist: {workload.query_dir}")
        if args.query_set == "optimization" and index_root_for(workload.name).exists() is False and not args.skip_index_setup:
            raise ValueError(f"index/materialization directory does not exist: {index_root_for(workload.name)}")
        queries, start_index = resolve_queries(workload, args)
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 2

    run_timestamp = dt.datetime.now().strftime(RUN_TIMESTAMP_FORMAT)
    out = args.out or csv_query_set_out(args.work_dir, args.query_set, workload.name, run_timestamp)
    out.parent.mkdir(parents=True, exist_ok=True)

    print(
        f"== {args.query_set} {workload.name}: {len(queries)} query file(s), rounds={sample_rounds}, "
        f"warmup={args.warmup_count}, performance={args.performance_count}, mode={args.mode}, threads={workload.threads} ==",
        flush=True,
    )
    if args.query_set == "optimization" and not args.skip_index_setup:
        print("== optimization will run materialization scripts from queries/index before each query ==", flush=True)

    results: list[dict[str, Any]] = []
    import kuzu

    db = kuzu.Database(str(workload.db_dir), read_only=False)
    conn = kuzu.Connection(db, num_threads=workload.threads)
    try:
        for idx, query_path in enumerate(queries, start_index):
            rel = rw.rel_path(workload, query_path)
            print(f"[{idx}] {rel}", flush=True)

            if args.query_set == "optimization" and not args.skip_index_setup:
                setup_path = index_setup_path(workload, query_path)
                if setup_path is not None:
                    setup_result = run_materialization(conn, setup_path, args.fetch_rows)
                    results.append(setup_result)
                    print(
                        f"  index_setup {setup_path.relative_to(QUERY_ROOT)} "
                        f"{setup_result['status']} {setup_result.get('seconds', '')}",
                        flush=True,
                    )
                    if setup_result.get("status") != "OK":
                        print(f"  index_setup error: {setup_result.get('error', '')}", flush=True)
                        continue
                else:
                    print("  index_setup SKIP no matching index/materialization script", flush=True)

            phases = [("warmup", args.warmup_count), ("performance", args.performance_count)]
            for sample_round in sample_rounds:
                try:
                    row_count = selected_param_count(workload, rel, args, sample_round)
                except Exception as exc:
                    result = {
                        "query": rel,
                        "sample_round": sample_round,
                        "status": "FAIL",
                        "error": f"parameter selection error: {type(exc).__name__}: {exc}",
                    }
                    results.append(result)
                    print(f"  round={sample_round} FAIL {exc}", flush=True)
                    continue

                print(f"  round={sample_round} params={row_count}", flush=True)
                round_iteration_averages: list[float] = []
                for phase, iteration_count in phases:
                    for iteration in range(1, iteration_count + 1):
                        iteration_seconds: list[float] = []
                        for param_row in range(args.param_row, args.param_row + row_count):
                            result = rw.run_query_persistent(
                                conn,
                                workload,
                                query_path,
                                args.mode,
                                False,
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
                            if result.get("status") == "OK" and isinstance(result.get("seconds"), int | float):
                                iteration_seconds.append(float(result["seconds"]))
                            results.append(result)
                            print(
                                f"    {phase}#{iteration} round={sample_round} row={param_row} "
                                f"{result['status']} {result.get('seconds', '')} {result.get('mode', '')}",
                                flush=True,
                            )
                        if phase == "performance" and iteration_seconds:
                            avg = rw.mean(iteration_seconds)
                            round_iteration_averages.append(avg)
                            print(f"    performance#{iteration} round={sample_round} avg = {avg:.6f}s", flush=True)
                if round_iteration_averages:
                    print(
                        f"  round={sample_round} avg = {rw.mean(round_iteration_averages):.6f}s "
                        f"from {len(round_iteration_averages)} performance iteration(s)",
                        flush=True,
                    )
    finally:
        del conn
        del db

    append_setup_csv_fields(results)
    summary_out = rw.default_summary_path(out)
    wide_summary_out = rw.default_wide_summary_path(summary_out)
    summary_rows = rw.build_summary_rows(results)
    wide_fieldnames, wide_rows = rw.build_wide_summary_rows(summary_rows)
    rw.write_csv_results(out, results)
    rw.write_summary_results(summary_out, summary_rows)
    rw.write_wide_summary_results(wide_summary_out, wide_fieldnames, wide_rows)
    ok = sum(1 for item in results if item.get("status") == "OK")
    skipped = sum(1 for item in results if item.get("status") == "SKIP")
    failed = [item for item in results if item.get("status") not in {"OK", "SKIP"}]
    rw.print_wide_summary(wide_fieldnames, wide_rows)
    print(f"wrote {out}")
    print(f"wrote {summary_out}")
    print(f"wrote {wide_summary_out}")
    print(f"summary: ok={ok} skipped={skipped} failed_or_timeout={len(failed)}")
    return 1 if failed else 0


if __name__ == "__main__":
    mp.set_start_method("fork")
    raise SystemExit(main())
'''


BASELINE_WRAPPER = r'''#!/usr/bin/env python3
"""Run Kuzu baseline benchmark queries."""

from __future__ import annotations

import runpy
import sys
from pathlib import Path


SCRIPT = Path(__file__).resolve().parent / "scripts" / "run-benchmark.py"
sys.argv = [str(SCRIPT), "--query-set", "baseline", *sys.argv[1:]]
runpy.run_path(str(SCRIPT), run_name="__main__")
'''


OPTIMIZATION_WRAPPER = r'''#!/usr/bin/env python3
"""Run Kuzu optimized benchmark queries after materializing Neug index results."""

from __future__ import annotations

import runpy
import sys
from pathlib import Path


SCRIPT = Path(__file__).resolve().parent / "scripts" / "run-benchmark.py"
sys.argv = [str(SCRIPT), "--query-set", "optimization", *sys.argv[1:]]
runpy.run_path(str(SCRIPT), run_name="__main__")
'''


BENCHMARK_DOC = r'''# Kuzu baseline / optimization benchmark runner

This directory provides two benchmark entry points:

- `../run-kuzu-baseline.py`: runs queries from `Kuzu/queries/baseline/<dataset>`.
- `../run-kuzu-optimization.py`: runs queries from `Kuzu/queries/optimized/<dataset>` after first running the matching materialization script from `Kuzu/queries/index/<dataset>/<query>/index.cypher`.

The "index" step is not a native Kuzu index build. It materializes NeuG index results into Kuzu node/relationship tables so that optimized Cypher queries can read pre-filled properties or relationship tables.

All benchmark entry points open Kuzu connections with `num_threads=1`. The run banner prints `threads=1` so this is visible in command output.

## Timing semantics

Default timing is:

1. For each selected sample round and parameter row, run one warmup execution.
2. For each selected sample round, run three performance iterations.
3. Inside each performance iteration, run all selected parameter rows and average their times.
4. The summary averages those per-iteration averages.

Warmup executions are recorded in the raw result CSV but are excluded from the summary. Optimization materialization time is recorded as `phase=index_setup` in the raw result CSV and is also excluded from query-time summary statistics.

## Output

Each run writes three CSV files:

```text
/mnt/data/results/kuzu/<baseline-or-optimization>/<workload>/<query-set>-<timestamp>-results.csv
/mnt/data/results/kuzu/<baseline-or-optimization>/<workload>/<query-set>-<timestamp>-summary.csv
/mnt/data/results/kuzu/<baseline-or-optimization>/<workload>/<query-set>-<timestamp>-summary-wide.csv
```

The wide summary has one row per query and one time column per sample round:

```text
query|t1|t2|t3
ic1|0.123456|0.234567|0.345678
```

The same wide table is printed at the end of the run.

## Examples

Run baseline IC1 with default warmup=1 and performance=3:

```bash
Kuzu/run-kuzu-baseline.py --workload ic-sf1 --query ic1 --mode execute
```

Run optimized LSQB q1, including its materialization step:

```bash
Kuzu/run-kuzu-optimization.py --workload lsqb-sf1 --query q1 --mode execute
```

Run a non-destructive smoke test against a copied database:

```bash
cp -a /mnt/data/imported_data/kuzu/lsqb/sf1 /tmp/kuzu-lsqb-smoke
Kuzu/run-kuzu-optimization.py \
  --workload lsqb-sf1 \
  --db-dir /tmp/kuzu-lsqb-smoke \
  --query q1 \
  --mode execute \
  --warmup-count 1 \
  --performance-count 1 \
  --param-count 1 \
  --out /tmp/kuzu-lsqb-smoke-results.csv
```

Use `--skip-index-setup` only for syntax checking optimized queries; it does not benchmark the real optimization workflow.
'''


FILES = {
    "scripts/run-benchmark.py": RUN_BENCHMARK,
    "scripts/benchmark-runner.md": BENCHMARK_DOC,
    "run-kuzu-baseline.py": BASELINE_WRAPPER,
    "run-kuzu-optimization.py": OPTIMIZATION_WRAPPER,
}


def main() -> None:
    for relative, content in FILES.items():
        path = ROOT / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        path.chmod(0o755)
        print(path)


if __name__ == "__main__":
    main()
