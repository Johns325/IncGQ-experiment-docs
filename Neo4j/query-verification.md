# Neo4j Query Verification

验证时间：2026-06-11

验证范围：

```text
/root/workspace/IncGQ/IncGQ-experiment-docs/Neo4j/queries
/mnt/data/imported_data/neo4j
```

使用 Neo4j 5.20.0 + Java 17，临时服务只绑定 `127.0.0.1`。验证后服务已停止。

## 1. 数据库与查询集对应关系

| Query set | Database directory | Status |
| --- | --- | --- |
| `ldbc-bi` | `/mnt/data/imported_data/neo4j/bi-sf1` | 已验证 |
| `ldbc-ic` | `/mnt/data/imported_data/neo4j/ic-sf1` | 已验证 |
| `lsqb` | `/mnt/data/imported_data/neo4j/lsqb/sf1` | 已验证 |
| `finbench` | `/mnt/data/imported_data/neo4j/finbench/sf1` | 已验证 |
| `wikidata` | 未找到对应 Neo4j 数据库 | 未验证 |

`graphdblp` 数据库已导入，但 `Neo4j/queries` 下没有 `graphdblp` 查询集。

## 2. 验证脚本

新增脚本：

```text
scripts/verify_neo4j_queries.py
```

结果文件：

```text
/tmp/neo4j-query-verify/lsqb-results.json
/tmp/neo4j-query-verify/ic-results.json
/tmp/neo4j-query-verify/bi-results.json
/tmp/neo4j-query-verify/finbench-results.json
/tmp/neo4j-query-verify/finbench-results-after-fix.json
/tmp/neo4j-query-verify/explain-results.json
/tmp/neo4j-query-verify/finbench-explain-results.json
/tmp/neo4j-query-verify/finbench-sampled-retry.json
/tmp/neo4j-query-verify/finbench-tcr12-retry.json
```

## 3. 汇总

| Query set | Execute result | EXPLAIN result | Notes |
| --- | --- | --- | --- |
| LSQB | 6 OK, 3 TIMEOUT | 9 OK | `q3/q6/q9` 可规划，但 45s 内未跑完 |
| LDBC IC | 12 OK, 2 TIMEOUT | 14 OK | `ic10/ic2` 可规划，但 45s 内未跑完 |
| LDBC BI | 15 OK, 1 TIMEOUT, 7 FAIL | 16 OK, 7 FAIL | 失败项均为缺 APOC/GDS 插件 |
| FinBench | 19 read OK, 15 write EXPLAIN OK, 2 FAIL | 34 OK, 2 FAIL | 修复后复跑结果见 `finbench-results-after-fix.json`；失败项为缺 GDS/APOC；写查询未实际改库 |

## 4. LSQB

实际执行成功：

```text
q1, q2, q4, q5, q7, q8
```

执行超时但 EXPLAIN 成功：

```text
q3, q6, q9
```

结论：LSQB 查询文本和 schema 匹配；超时项是执行代价问题，不是语法或导入 schema 错误。

## 5. LDBC IC

实际执行成功：

```text
ic1, ic3, ic4, ic5, ic6, ic7, ic8, ic9, ic11, ic12, ic13, ic14
```

执行超时但 EXPLAIN 成功：

```text
ic2, ic10
```

结论：IC 查询文本和 schema 匹配；超时项是执行代价问题。

## 6. LDBC BI

实际执行成功：

```text
bi1, bi2, bi3, bi4, bi5, bi6, bi7, bi8, bi9,
bi11, bi12, bi13, bi16, bi17, bi18
```

执行超时但 EXPLAIN 成功：

```text
bi14
```

失败项：

| Query | Reason |
| --- | --- |
| `bi10` | 缺 APOC：`apoc.path.subgraphNodes` |
| `bi15/bi-15.cypher` | 缺 GDS：`gds.graph.drop` |
| `bi15/bi-15-without-date.cypher` | 缺 GDS：`gds.graph.drop` |
| `bi19/bi-19.cypher` | 缺 GDS：`gds.shortestPath.dijkstra.stream` |
| `bi19/bi-19-without-precomputation.cypher` | 缺 GDS：`gds.graph.drop` |
| `bi20/bi-20.cypher` | 缺 GDS：`gds.shortestPath.dijkstra.stream` |
| `bi20/bi-20-without-precomputation.cypher` | 缺 GDS：`gds.shortestPath.dijkstra.stream` |

结论：BI 非插件查询可运行。APOC/GDS 查询需要安装对应 Neo4j 插件后再验证。

## 7. FinBench

实际执行成功的读查询：

```text
tcr-1, tcr-2, tcr-3, tcr-4, tcr-5, tcr-6, tcr-7,
tcr-8, tcr-9, tcr-12, tcr-13,
tsr-1, tsr-2, tsr-3, tsr-4, tsr-5, tsr-6, tsr-7, tsr-8
```

写查询只做 EXPLAIN，未改库：

```text
tw-1, tw-2, tw-3, tw-4, tw-5, tw-6, tw-7, tw-8, tw-9,
tw-10, tw-11, tw-12, tw-13, tw-14, tw-15
```

失败项：

| Query | Reason |
| --- | --- |
| `tcr-10` | 缺 GDS：`gds.similarity.jaccard` |
| `tcr-11` | 缺 APOC：`apoc.coll.sum` |

本次修复的 FinBench 查询：

| Query | Fix |
| --- | --- |
| `tcr-12` | `relationships(p)` 改为 `relationships(path)` |
| `tw-3` | `CREATE` 改为有方向的 `(src)-[:transfer]->(dst)` |
| `tw-4` | `CREATE` 改为有方向的 `(src)-[:withdraw]->(dst)` |

补充说明：

第一轮中 `tcr-7/tcr-9/tsr-3` 使用占位参数时出现除零。随后从数据库抽取满足 pattern 的真实账号 ID 后，三条均实际执行成功。

## 8. 未验证项

`Neo4j/queries/wikidata` 下有查询文件，但 `/mnt/data/imported_data/neo4j` 下没有发现 Wikidata Neo4j 数据库，因此本次没有验证。

## 9. 复跑命令

实际执行：

```bash
python3 scripts/verify_neo4j_queries.py \
  --datasets lsqb ic bi finbench \
  --timeout 60 \
  --out /tmp/neo4j-query-verify/all-results.json
```

只做 EXPLAIN：

```bash
python3 scripts/verify_neo4j_queries.py \
  --datasets lsqb ic bi finbench \
  --mode explain \
  --timeout 30 \
  --out /tmp/neo4j-query-verify/all-explain-results.json
```
