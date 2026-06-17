# Kuzu BI SF1 workload

Database:

```text
/mnt/data/imported_data/kuzu/bi-sf1
```

Benchmark query directories:

```text
baseline:     Kuzu/queries/baseline/ldbc-bi
optimized:    Kuzu/queries/optimized/ldbc-bi
materialized: Kuzu/queries/index/ldbc-bi
```

Formal benchmark examples:

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
Kuzu/run-kuzu-baseline.py --workload bi-sf1 --query bi13 --mode execute --param-count 1
Kuzu/run-kuzu-optimization.py --workload bi-sf1 --query bi13 --mode execute --param-count 1
```

Legacy smoke wrapper:

```bash
Kuzu/scripts/run-bi-sf1.sh --query bi13 --mode explain --param-count 1
```

Kuzu adaptation rules:

- `Message` is represented with `POST`/`COMMENT` tables or `POST:COMMENT` syntax where Kuzu accepts it.
- `Country` and `City` are `PLACE` rows filtered by `type`.
- `Company` and `University` are `ORGANISATION` rows filtered by `type`.
- Relationship names use imported uppercase names such as `HASCREATOR`, `HASTAG`, `REPLYOF`, `CONTAINEROF`, `HASMEMBER`, `HASMODERATOR`, `HASINTEREST`, `ISLOCATEDIN`, `ISPARTOF`, `HASTYPE`, and `KNOWS`.

Optimized BI coverage currently includes `bi3`, `bi5`, `bi6`, `bi11`, `bi13`, `bi14`, and `bi17`. BI15 and BI19 have materialization scripts under `queries/index/ldbc-bi`, but optimized BI15/BI19 query rewrites are not part of the current optimized benchmark set.

BI20 remains unsupported/skipped because the original requires weighted Dijkstra over a projected graph.
