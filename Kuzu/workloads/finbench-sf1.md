# Kuzu FinBench SF1 workload

Database:

```text
/mnt/data/imported_data/kuzu/finbench
```

Benchmark query directory:

```text
baseline: Kuzu/queries/baseline/finbench
```

FinBench optimized/index query sets have not been organized for the current Kuzu benchmark runner.

Formal baseline example:

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
Kuzu/run-kuzu-baseline.py --workload finbench-sf1 --query tcr-10 --mode execute --param-count 1
```

Legacy smoke wrapper:

```bash
Kuzu/scripts/run-finbench-sf1.sh --query tcr-10 --mode execute --param-count 1
```

The `tw-*` write queries are protected in the legacy runner: in `execute` mode it still uses `EXPLAIN` unless `--allow-writes` is set. Use `--allow-writes` only on a disposable copy of the database.

Time parameters such as `start_time`, `end_time`, and `currentTime` are passed as Python `datetime.datetime` values through the Kuzu Python API. The CSV `parameters` field keeps the original parameter-file values for traceability.

Query-specific compatibility notes are documented in `Kuzu/queries/baseline/finbench/README.md`.
