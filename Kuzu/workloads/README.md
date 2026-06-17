# Kuzu workload notes

The recommended benchmark entry points are documented in `Kuzu/README.md`:

```text
Kuzu/run-kuzu-baseline.py
Kuzu/run-kuzu-optimization.py
```

This directory keeps workload-specific notes plus documentation for the legacy smoke wrappers in `Kuzu/scripts/run-*.sh`.

## Legacy wrapper mapping

| Workload | Wrapper | Database | Query directory |
| --- | --- | --- | --- |
| `ic-sf1` | `Kuzu/scripts/run-ic-sf1.sh` | `/mnt/data/imported_data/kuzu/ic-sf1` | `Kuzu/queries/baseline/ldbc-ic` |
| `bi-sf1` | `Kuzu/scripts/run-bi-sf1.sh` | `/mnt/data/imported_data/kuzu/bi-sf1` | `Kuzu/queries/baseline/ldbc-bi` |
| `lsqb-sf1` | `Kuzu/scripts/run-lsqb-sf1.sh` | `/mnt/data/imported_data/kuzu/lsqb/sf1` | `Kuzu/queries/baseline/lsqb` |
| `finbench-sf1` | `Kuzu/scripts/run-finbench-sf1.sh` | `/mnt/data/imported_data/kuzu/finbench` | `Kuzu/queries/baseline/finbench` |
| `graphdblp` | `Kuzu/scripts/run-graphdblp.sh` | `/mnt/data/imported_data/kuzu/graphdblp` | `NeuG/queries/graphdblp/distinct` |

The wrappers call `Kuzu/scripts/run-workload.py`. Its default runner is `isolated`, so it is useful for smoke checks but not the current benchmark timing method. Use `--runner persistent` if you need one database open inside the legacy runner.

## Examples

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
Kuzu/scripts/run-ic-sf1.sh --query ic1 --mode execute --param-count 1
Kuzu/scripts/run-bi-sf1.sh --query bi11 --mode explain --param-count 1
Kuzu/scripts/run-lsqb-sf1.sh --query q1 --mode execute --fetch-rows 5
Kuzu/scripts/run-finbench-sf1.sh --query tcr-10 --mode execute --param-count 1
```

GraphDBLP execute mode is disabled in the legacy runner:

```bash
Kuzu/scripts/run-graphdblp.sh --query query_dense_16_1.cypher --mode explain --timeout 30
```

## Legacy output

The legacy runner writes the same three CSV files as the benchmark helper functions:

```text
/mnt/data/results/kuzu/<workload>/<mode>-<timestamp>-results.csv
/mnt/data/results/kuzu/<workload>/<mode>-<timestamp>-summary.csv
/mnt/data/results/kuzu/<workload>/<mode>-<timestamp>-summary-wide.csv
```

Detail CSV fields:

```text
query,sample_round,phase,iteration,parameter_index,parameters,results,time_seconds,setup_time_seconds
```

## Options specific to legacy runner

| Option | Meaning |
| --- | --- |
| `--runner isolated|persistent` | `isolated` opens a child process per parameter row; `persistent` opens one Kuzu connection and reuses it. |
| `--allow-writes` | Execute write queries instead of protecting them with `EXPLAIN`. Use only on disposable database copies. |
| `--timeout N` | Per-query timeout for `--runner isolated`; ignored by persistent and by the formal benchmark runner. |

Other common options such as `--query`, `--queries`, `--sample-rounds`, `--param-row`, `--param-count`, `--warmup-count`, `--performance-count`, `--fetch-rows`, and `--out` have the same meaning as in `Kuzu/README.md`.

## Caveats

- Kuzu rejects unused query parameters, so the runner filters the parameter map to only names referenced by each query.
- FinBench `tw-*` write queries are protected unless `--allow-writes` is set.
- Some Kuzu query planning steps are slow; use targeted `--query` and small `--param-count` values for smoke checks.
