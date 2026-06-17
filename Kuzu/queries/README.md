# Kuzu query directories

The Kuzu query tree is split by benchmark role:

```text
Kuzu/queries/baseline/<dataset>/...
Kuzu/queries/index/<dataset>/<query>/index.cypher
Kuzu/queries/optimized/<dataset>/<query>/...
```

Dataset directory names used by the benchmark runner:

| Workload | Dataset directory |
| --- | --- |
| `ic-sf1` | `ldbc-ic` |
| `bi-sf1` | `ldbc-bi` |
| `lsqb-sf1` | `lsqb` |
| `finbench-sf1` | `finbench` |

`Kuzu/run-kuzu-baseline.py` reads only `queries/baseline/<dataset>`. `Kuzu/run-kuzu-optimization.py` reads `queries/optimized/<dataset>` and, before each optimized query, tries to run `queries/index/<dataset>/<query>/index.cypher`.

## Schema conventions

Kuzu uses the imported table names, not the Neo4j labels:

- LDBC IC/BI node labels are uppercase: `PERSON`, `POST`, `COMMENT`, `FORUM`, `PLACE`, `ORGANISATION`, `TAG`, `TAGCLASS`.
- LDBC IC/BI relationship names are compact uppercase: `KNOWS`, `HASCREATOR`, `HASTAG`, `REPLYOF`, `ISLOCATEDIN`, and similar names.
- `City` and `Country` are represented by `PLACE` rows plus a `type` property.
- `Company` and `University` are represented by `ORGANISATION` rows plus a `type` property.
- `Message` is not a Kuzu table in the LDBC imports. Queries use `POST`, `COMMENT`, or explicit `POST:COMMENT`/label-splitting rewrites.
- Epoch-millis date parameters are converted to Python `datetime.datetime` values before being passed to Kuzu for `TIMESTAMP` columns.

## Current optimized coverage

Optimized query directories currently exist for:

```text
ldbc-ic: ic1, ic3, ic5, ic12, ic14
ldbc-bi: bi3, bi5, bi6, bi11, bi13, bi14, bi17
lsqb:    q1, q2, q3, q4, q7
```

Index/materialization directories currently exist for:

```text
ldbc-ic: ic1, ic3, ic5, ic12, ic14
ldbc-bi: bi3, bi5, bi6, bi11, bi13, bi14, bi15, bi17, bi19
lsqb:    q1, q2, q3, q4, q7
```

BI15 and BI19 have materialization scripts, but optimized BI15/BI19 query rewrites are intentionally not part of the current optimized query set.

LSQB q1, q3, q4, and q7 have optimized-query directories for runner coverage, but they are baseline-equivalent fallbacks. Their NeuG-style `Person.countryId`, `q4_msg_cnt`, and `q7_like_cnt`/`q7_reply_count` property materializations are disabled because this Kuzu build segfaults when updating derived properties on the imported LSQB SF1 database.

## Validation notes

Do not treat old copied Neo4j files as automatically verified. A query is considered part of the current benchmark only if it is under `baseline`, `optimized`, or `index` and can be resolved by the corresponding Kuzu runner.

Workload-specific notes live in:

```text
Kuzu/workloads/ic-sf1.md
Kuzu/workloads/bi-sf1.md
Kuzu/workloads/lsqb-sf1.md
Kuzu/workloads/finbench-sf1.md
Kuzu/workloads/graphdblp.md
```
