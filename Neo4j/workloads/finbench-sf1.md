# Neo4j FinBench SF1 workload

Database:

```text
/mnt/data/imported_data/neo4j/finbench/sf1
```

Benchmark query directory:

```text
baseline: Neo4j/queries/baseline/finbench
```

FinBench optimized/index query sets are not organized for the current Neo4j/Kuzu-aligned benchmark runner.

Formal baseline example:

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
Neo4j/run-neo4j-baseline.py --workload finbench-sf1 --query tcr-10 --mode execute --param-count 1
```

Legacy smoke wrapper:

```bash
Neo4j/scripts/run-finbench-sf1.sh --query tcr-10 --mode execute --param-count 1
```

The legacy runner protects `tw-*` write queries unless `--allow-writes` is set.
