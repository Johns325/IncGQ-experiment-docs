# Neo4j baseline / optimization benchmark runner

This runner mirrors `Kuzu/scripts/run-benchmark.py`.

Entry points:

- `../run-neo4j-baseline.py`: runs `Neo4j/queries/baseline/<dataset>`.
- `../run-neo4j-optimization.py`: runs `Neo4j/queries/index/<dataset>/<query>/index.cypher` first, then `Neo4j/queries/optimized/<dataset>`.

Timing semantics:

1. Start Neo4j once and create one Bolt driver/session before measured phases.
2. For each query and sample round, run all warmup parameter rows first.
3. Then run `--performance-count` full parameter-set iterations; default is 3.
4. Summary averages parameter rows per performance iteration, then averages those iteration means.
5. Startup, driver/session creation, and index/materialization setup are excluded from summary timing.

Outputs match Kuzu:

```text
/mnt/data/results/neo4j/baseline/<workload>/baseline-<timestamp>-results.csv
/mnt/data/results/neo4j/baseline/<workload>/baseline-<timestamp>-summary.csv
/mnt/data/results/neo4j/baseline/<workload>/baseline-<timestamp>-summary-wide.csv
```

The optimization path is the same with `optimization` in place of `baseline`.

LSQB uses a larger generated Neo4j memory configuration than the default workload (`heap=12G`, `pagecache=8G`, `dbms.memory.transaction.total.max=10G`). LSQB q7 materialization is written with `CALL { ... } IN TRANSACTIONS OF 10000 ROWS` so the derived `q7_like_cnt` and `q7_reply_count` properties are filled in batches instead of one large transaction.
