# Neo4j LSQB SF1 workload

Database:

```text
/mnt/data/imported_data/neo4j/lsqb/sf1
```

Benchmark query directories:

```text
baseline:     Neo4j/queries/baseline/lsqb
optimized:    Neo4j/queries/optimized/lsqb
materialized: Neo4j/queries/index/lsqb
```

Formal benchmark examples:

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
Neo4j/run-neo4j-baseline.py --workload lsqb-sf1 --query q1 --mode execute --fetch-rows 5
Neo4j/run-neo4j-optimization.py --workload lsqb-sf1 --query q1 --mode execute --fetch-rows 5
```

Optimized LSQB coverage matches Kuzu: `q1`, `q2`, `q3`, `q4`, and `q7`.
