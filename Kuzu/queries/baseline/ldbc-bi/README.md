# Kuzu LDBC BI baseline queries

These queries target `/mnt/data/imported_data/kuzu/bi-sf1` through the current Kuzu schema.

They are run by:

```bash
Kuzu/run-kuzu-baseline.py --workload bi-sf1 --query bi13 --mode execute
```

Important schema adaptations:

- `Message` is written as `POST:COMMENT` or split into explicit `POST` and `COMMENT` branches.
- `Country`/`City` are `PLACE` rows filtered by `type`.
- `Company`/`University` are `ORGANISATION` rows filtered by `type`.
- Relationship names are imported uppercase names such as `HASCREATOR`, `HASTAG`, `REPLYOF`, `CONTAINEROF`, `ISLOCATEDIN`, `ISPARTOF`, and `KNOWS`.
- Neo4j-only constructs such as APOC/GDS calls are either manually rewritten or left as comment-only unsupported files.

`setup.cypher` files under BI15/BI19 are skipped by default when selecting all baseline queries. The formal optimization workflow does not use these baseline setup files; it uses `Kuzu/queries/index/.../index.cypher` through `run-kuzu-optimization.py`.

BI20 remains unsupported/skipped because the original relies on weighted Dijkstra over a projected graph.
