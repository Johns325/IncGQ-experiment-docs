# NeuG Workload Runner

This directory contains the NeuG baseline runner. It executes the workload
queries through the local NeuG build under `/root/workspace/neug`. 
The runner sets `PYTHONPATH` and `LD_LIBRARY_PATH` itself, then re-execs the
Python process so `import neug` resolves to:

```text
/root/workspace/neug/tools/python_bind/neug
/root/workspace/neug/build/tools/python_bind/neug_py_bind*.so
```

The databases under `/mnt/data/imported_data/incgq` should be created with the
same local build format, for example with
`/root/workspace/neug/build/tools/utils/bulk_loader`.

## Import

Use the local NeuG build to create databases:

```bash
python3 /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/import-workload.py --all --overwrite
```

Or import one workload:

```bash
python3 /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/import-workload.py --workload ic-sf1 --overwrite
python3 /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/import-workload.py --workload bi-sf1 --overwrite
python3 /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/import-workload.py --workload lsqb-sf1 --overwrite
python3 /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/import-workload.py --workload finbench-sf1 --overwrite
```



## Entry Points

Use the explicit benchmark entry points:

```bash
python3 /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/run-neug-baseline.py --workload ic-sf1 --query ic1 --sample-round 1 --performance-count 5
python3 /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/run-neug-optimization.py --workload ic-sf1 --query ic1 --sample-round 1 --performance-count 5
```

`run-neug-baseline.py` reads `NeuG/queries/baseline/...` where available.
`run-neug-optimization.py` reads `NeuG/queries/optimization/...`; before each
optimized query it clears existing NeuG indexes, executes the matching
`NeuG/queries/index/<dataset>/<query>/index.cypher`, then runs warmup and
performance iterations using the same open database connection.

Example with multiple IC queries:

```bash
python3 /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/run-neug-baseline.py \
  --workload ic-sf1 \
  --queries ic1,ic3,ic5,ic12,ic14 \
  --sample-round 3 \
  --param-count 10 \
  --performance-count 5 \
  --mode execute
```

Every continued shell line must end with `\`. If the `--queries` line is
missing the trailing `\`, the shell will execute `--sample-round` as a separate
command.

The older workload wrappers still work:

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-ic-sf1.sh --query ic1
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-bi-sf1.sh --query bi3
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-finbench-sf1.sh --query tcr-1.cypher
```

## Workloads

| Workload | Database | Queries |
| --- | --- | --- |
| `ic-sf1` | `/mnt/data/imported_data/incgq/ic-sf1` | `NeuG/queries/baseline/ldbc-ic`, `NeuG/queries/optimization/ldbc-ic` |
| `bi-sf1` | `/mnt/data/imported_data/incgq/bi-sf1` | `NeuG/queries/baseline/ldbc-bi`, `NeuG/queries/optimization/ldbc-bi` |
| `finbench-sf1` | `/mnt/data/imported_data/incgq/finbench-sf1` | `NeuG/queries/finbench/finbench-adapted-queries` |
| `lsqb-sf1` | `/mnt/data/imported_data/incgq/lsqb-sf1` | `NeuG/queries/baseline/lsqb`, `NeuG/queries/optimization/lsqb` |
| `graphdblp` | `/mnt/data/imported_data/incgq/graphdblp/neug-graphdblp-core-db` | `NeuG/queries/graphdblp/distinct` |

## Parameter Sampling

By default, BI, IC, and FinBench read sampled parameters from:

```text
/mnt/data/sampled_parameters/ldbc_snb_bi/sf1
/mnt/data/sampled_parameters/ldbc_snb_ic/sf1
/mnt/data/sampled_parameters/finbench/sf1
```

Each sampled file uses this format:

```text
--round 1--
param row
param row
--round 2--
param row
```

Useful options:

```bash
--query QUERY              run one query
--queries A,B,C            run several queries
--runner persistent        only supported runner; open one DB connection and reuse it
--sample-round 3           run one sampled round
--sample-rounds 1,3,5      run selected sampled rounds
--sample-rounds 1-3        run a round range
--param-count N            run N rows from each round; default is all rows in the sampled round
--warmup-count N           run N warmup iterations over every selected parameter row; default is 1
--performance-count K      run K measured iterations; default is 3
--result-group baseline    result subdirectory under /mnt/data/results/neug
--sampled-params-dir PATH  override sampled parameter directory or root
--params-dir PATH          use original per-query parameter files
--params-file PATH         force one parameter file for selected queries
```

The default warmup count is `1`, meaning each selected parameter row is warmed
up once. With `--param-count 10`, the default warmup phase executes 10 queries.
Use `--warmup-count 0` to disable warmup.

## Timing Semantics

The runner opens the NeuG database once, reuses one connection, runs warmup,
and records the Python API `execute()` call for measured performance rows. This
still uses the Cypher files under `NeuG/queries`.

Example:

```bash
python3 /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/run-neug-workload.py \
  --workload bi-sf1 \
  --queries bi3 \
  --sample-rounds 1 \
  --param-count 3 \
  --performance-count 1 \
  --mode execute
```

For one query and one round:

1. Warmup runs each selected parameter row once per warmup iteration.
2. Each performance iteration runs the query over all selected parameter rows.
3. The runner prints `performance#K round=R avg = ...s` for each performance
   iteration.
4. The runner then prints `round=R avg = ...s`, which is the average of the
   performance-iteration averages.

## Output

Detail CSV defaults to:

```text
/mnt/data/results/neug/<baseline-or-optimization>/<workload>/<mode>-<timestamp>-results.csv
```

Summary CSV is written beside it:

```text
/mnt/data/results/neug/<baseline-or-optimization>/<workload>/<mode>-<timestamp>-summary.csv
```

The summary file is pipe-delimited:

```text
query|sample_round|performance_iterations|param_count|avg_time_seconds
```

A wide summary is also written beside it:

```text
/mnt/data/results/neug/<baseline-or-optimization>/<workload>/<mode>-<timestamp>-summary-wide.csv
```

Passing `--out` still overrides the full result path explicitly.

The wide summary has one row per query and one time column per sample round:

```text
query|t1|t2|t3
ic1|0.123456|0.234567|0.345678
```

The same wide table is printed at the end of the run.

## Notes

`validate` is the default mode. NeuG's Python API does not expose a confirmed
parse-only or explain-only path here, so `validate` executes read queries and
skips write queries unless `--allow-writes` is used.

The runner opens the database once at the beginning and exits immediately if
that open fails. `--timeout` is ignored because the runner no longer starts a
child process for each parameter row.
