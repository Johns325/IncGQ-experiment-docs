# Neo4j IC SF1 workload

Database:

```text
/mnt/data/imported_data/neo4j/ic-sf1
```

Benchmark query directories:

```text
baseline:     Neo4j/queries/baseline/ldbc-ic
optimized:    Neo4j/queries/optimized/ldbc-ic
materialized: Neo4j/queries/index/ldbc-ic
```

Formal benchmark examples:

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
Neo4j/run-neo4j-baseline.py --workload ic-sf1 --query ic1 --mode execute --param-count 1
Neo4j/run-neo4j-optimization.py --workload ic-sf1 --query ic1 --mode execute --param-count 1
```

Optimized IC coverage matches Kuzu: `ic1`, `ic3`, `ic5`, `ic12`, and `ic14`.
