# Kuzu optimized queries using NeuG materializations

These queries are manual Kuzu rewrites of NeuG-optimizable templates. They assume the matching materialization script under `../index` has already run on the target database.

`Kuzu/run-kuzu-optimization.py` performs that setup automatically for each optimized query unless `--skip-index-setup` is passed.

Current optimized coverage:

```text
ldbc-ic: ic1, ic3, ic5, ic12, ic14
ldbc-bi: bi3, bi5, bi6, bi11, bi13, bi14, bi17
lsqb:    q1, q2, q3, q4, q7
```

BI15 and BI19 are not included in the optimized query set for the current benchmark batch. Their materialization scripts remain under `queries/index/ldbc-bi` for future work.

IC1 is included as a runnable baseline-equivalent query. The NeuG setup materializes scalar university fields on `PERSON`, but the IC1 result returns a list of universities, so the optimized query keeps the list-producing match instead of replacing it with scalar fields that may not be equivalent for people with multiple `STUDYAT` edges.

LSQB q1, q3, q4, and q7 are also included as runnable baseline-equivalent fallbacks. The NeuG-style materializations store derived properties such as `Person.countryId`, `Post.q4_msg_cnt`, and `Post.q7_like_cnt`, but the current Kuzu build crashes when updating those derived properties on the imported LSQB SF1 database. Their `queries/index/lsqb/{q1,q3,q4,q7}/index.cypher` files are therefore no-op note queries, and their optimized queries keep baseline semantics so optimization runs do not segfault.
