# Neo4j BI SF1 workload

Database:

```text
/mnt/data/imported_data/neo4j/bi-sf1
```

Benchmark query directories:

```text
baseline:     Neo4j/queries/baseline/ldbc-bi
optimized:    Neo4j/queries/optimized/ldbc-bi
materialized: Neo4j/queries/index/ldbc-bi
```

Formal benchmark examples:

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
Neo4j/run-neo4j-baseline.py --workload bi-sf1 --query bi13 --mode execute --param-count 1
Neo4j/run-neo4j-optimization.py --workload bi-sf1 --query bi13 --mode execute --param-count 1
```

Optimized BI coverage matches Kuzu: `bi3`, `bi5`, `bi6`, `bi11`, `bi13`, `bi14`, and `bi17`. BI15 and BI19 are intentionally not in the optimized query set.
