# Kuzu baseline / optimization benchmark runner

This file documents the current benchmark implementation in `Kuzu/scripts/run-benchmark.py`.

## Entry points

- `../run-kuzu-baseline.py` injects `--query-set baseline` and runs `Kuzu/queries/baseline/<dataset>`.
- `../run-kuzu-optimization.py` injects `--query-set optimization`, runs the matching materialization script from `Kuzu/queries/index/<dataset>/<query>/index.cypher` when it exists, then runs `Kuzu/queries/optimized/<dataset>`.

The materialization step is not a native Kuzu index build. It fills derived properties or auxiliary relationship tables so optimized Cypher can read precomputed values.

`run-benchmark.py` handles Kuzu conditional DDL defensively: `ALTER TABLE ... ADD IF NOT EXISTS ...` is checked against a schema snapshot collected before opening the write connection, and `DROP IF EXISTS` is not sent to Kuzu. This avoids known crashes in the current Kuzu build's conditional-DDL paths. After writing CSV and summary files the runner exits with `os._exit(...)` to avoid a Kuzu Python/C++ connection-destruction segfault observed after write-mode openings.

Supported benchmark workloads are `ic-sf1`, `bi-sf1`, `lsqb-sf1`, and `finbench-sf1`. GraphDBLP is only wired through the legacy smoke runner.

All benchmark connections use `kuzu.Connection(db, num_threads=1)`. The run banner prints `threads=1`.

## Timing semantics

For every selected query and sample round, the loop order is phase-first:

```text
warmup#1 row 1..N
performance#1 row 1..N
performance#2 row 1..N
performance#3 row 1..N
```

Defaults are `--warmup-count 1` and `--performance-count 3`.

The runner opens the database once per process before the query loop. Database open time and connection creation time are not measured. Each row timing covers only the Kuzu API execute call plus result materialization performed by the runner.

Summary semantics:

1. Warmup rows are excluded.
2. `index_setup` rows are excluded.
3. Each performance iteration averages the selected parameter rows.
4. The round summary averages those per-iteration means.

## Output

Each run writes three CSV files:

```text
/mnt/data/results/kuzu/<baseline-or-optimization>/<workload>/<query-set>-<timestamp>-results.csv
/mnt/data/results/kuzu/<baseline-or-optimization>/<workload>/<query-set>-<timestamp>-summary.csv
/mnt/data/results/kuzu/<baseline-or-optimization>/<workload>/<query-set>-<timestamp>-summary-wide.csv
```

`summary-wide.csv` has one row per query and one time column per sample round:

```text
query|t1|t2|t3
ic1|0.123456|0.234567|0.345678
```

The same wide table is printed at the end of the run.

## Examples

Run baseline IC1:

```bash
Kuzu/run-kuzu-baseline.py --workload ic-sf1 --query ic1 --mode execute
```

Run optimized LSQB q1 with materialization:

```bash
Kuzu/run-kuzu-optimization.py --workload lsqb-sf1 --query q1 --mode execute
```

Run a non-destructive optimization smoke test against a copied database:

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

Use `--skip-index-setup` only for syntax checking optimized queries. It does not represent the real optimization workflow.

LSQB q1, q3, q4, and q7 are documented fallbacks: their index setup files are no-op note queries because updating the NeuG-style materialized properties segfaults on the current Kuzu LSQB SF1 database. The optimized q1/q3/q4/q7 queries preserve baseline semantics rather than using those unsafe materializations.
