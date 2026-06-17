# GraphDBLP distinct Cypher queries

This directory contains generated GraphDBLP Cypher queries deduplicated by executable Cypher text. Full-line comment rows, for example source and vertices metadata comments, are ignored when computing duplicates. The copied file is the first representative in deterministic filename order.

manifest.tsv records the representative file, how many generated files collapsed into it, and the original source file names.

## Neo4j validation notes

Validated on 2026-06-11 against `/mnt/data/imported_data/neo4j/graphdblp` with Neo4j 5.20.0.

The generated relationship-type union syntax was corrected for Neo4j 5. Use:

```cypher
[r:authored|contains|contributed_to]
```

Do not use the old form with a colon before every alternative, for example `[r:authored|:contains|:contributed_to]`; Neo4j 5 rejects that syntax when the relationship is bound to a variable.

Planning/execution caveat:

- `dense_4`: 14/14 distinct queries passed `CYPHER connectComponentsPlanner=greedy EXPLAIN`.
- `dense_8`: 179/179 distinct queries passed `CYPHER connectComponentsPlanner=greedy EXPLAIN`.
- `dense_16`: initial batch reached 11 queries; 9 passed, while `query_dense_16_3.cypher` and `query_dense_16_7.cypher` hit client transaction timeout during planning. Default planner also times out on complex dense_16 patterns.

These files are syntactically corrected for Neo4j 5, but the full distinct workload is not confirmed as practical to execute end-to-end on Neo4j. The larger dense queries are subgraph-counting patterns and may spend a long time in planning or execution. Use `CYPHER connectComponentsPlanner=greedy` when validating or running this workload, and treat planner/execution timeouts separately from syntax failures.

