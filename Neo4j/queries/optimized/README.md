# Neo4j optimized queries

This directory intentionally mirrors the optimized Kuzu coverage:

```text
ldbc-ic: ic1, ic3, ic5, ic12, ic14
ldbc-bi: bi3, bi5, bi6, bi11, bi13, bi14, bi17
lsqb:    q1, q2, q3, q4, q7
```

Each query assumes the matching materialization under `../index` has already run. Use `Neo4j/run-neo4j-optimization.py` to run setup and query execution with the same timing semantics as Kuzu.

BI15 and BI19 are not included in this optimized set, matching the current Kuzu optimized query set.
