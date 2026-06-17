# Neo4j GraphDBLP 导入流程

本文记录当前机器实测通过的 GraphDBLP/DBLP core 图导入 Neo4j 5.20.0 流程。

本次已经成功导入到：

```text
/mnt/data/imported_data/neo4j/graphdblp/data/databases/neo4j
/mnt/data/imported_data/neo4j/graphdblp/data/transactions/neo4j
```

## 1. 数据来源纠正

用户给出的数据目录是：

```text
/mnt/data/datasets/graphdblp
```

该目录不是已经生成好的 Neo4j CSV 图数据，而是：

```text
dblp.xml.gz
dblp.xml.gz.md5
dblp.dtd
keywords.csv
```

因此本流程不是“直接导入 CSV”，而是：

1. 复制一份 `dblp.xml.gz/dblp.dtd/keywords.csv` 到目标目录的 `raw/`。
2. 从 DBLP XML 流式生成 Neo4j typed CSV。
3. 使用 `neo4j-admin database import full` 离线导入。
4. 导入和检查成功后删除中间 CSV。

本流程构建的是 GraphDBLP-like core 图：`author/publication/venue/keyword` 以及 `authored/contains/contributed_to`。它不会生成原 GraphDBLP dump 中基于 embedding 或统计计算得到的增强关系。

## 2. 脚本

已有 XML 转 CSV 脚本：

```text
/root/workspace/IncGQ/IncGQ-experiment-docs/scripts/prepare_dblp_for_neo4j_import.py
```

新增 wrapper 脚本：

```text
/root/workspace/IncGQ/IncGQ-experiment-docs/scripts/import_neo4j_graphdblp.py
```

注意：`prepare_dblp_for_neo4j_import.py` 会生成一个 `neo4j-admin-import-graphdblp-core.sh`，本次流程不使用该脚本；它按普通 `NEO4J_HOME` 数据目录导入，不符合本次指定的目标目录。

## 3. 准备 raw copy

```bash
export GRAPHDBLP_SOURCE=/mnt/data/datasets/graphdblp
export GRAPHDBLP_TARGET=/mnt/data/imported_data/neo4j/graphdblp

mkdir -p "$GRAPHDBLP_TARGET/raw"

cp -a \
  "$GRAPHDBLP_SOURCE/dblp.xml.gz" \
  "$GRAPHDBLP_SOURCE/dblp.dtd" \
  "$GRAPHDBLP_SOURCE/dblp.xml.gz.md5" \
  "$GRAPHDBLP_SOURCE/keywords.csv" \
  "$GRAPHDBLP_TARGET/raw/"
```

校验 raw copy：

```bash
cd "$GRAPHDBLP_TARGET/raw"
gzip -t dblp.xml.gz
md5sum -c dblp.xml.gz.md5
```

本次校验结果：

```text
dblp.xml.gz: OK
gzip test: ok
```

## 4. 全量导入命令

本次复用已下载的 Neo4j 5.20.0 和 Java 17 JRE：

```bash
export GRAPHDBLP_TARGET=/mnt/data/imported_data/neo4j/graphdblp
export NEO4J_HOME=/mnt/data/imported_data/neo4j/bi-sf1/tools/neo4j-community-5.20.0
export JAVA_HOME_17=/mnt/data/imported_data/neo4j/bi-sf1/tools/jdk-17.0.19+10-jre
```

执行全量转换、验证、导入、检查，并在成功后删除中间 CSV：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_graphdblp.py \
  --xml "$GRAPHDBLP_TARGET/raw/dblp.xml.gz" \
  --keywords "$GRAPHDBLP_TARGET/raw/keywords.csv" \
  --csv-dir "$GRAPHDBLP_TARGET/csv" \
  --target-dir "$GRAPHDBLP_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --heap-size 16G \
  --validate-counts \
  --check \
  --cleanup-csv
```

`--cleanup-csv` 会在导入和检查成功后删除：

```text
/mnt/data/imported_data/neo4j/graphdblp/csv
```

本次确认该目录已删除，最终目标目录只保留：

```text
conf/
data/
logs/
raw/
import.report
```

## 5. 本次导入结果

XML 转 CSV 结果：

```text
publications: 12,690,688
authors: 4,229,058
venues: 24,471
keywords: 1,173
authored: 33,543,471
contains: 16,508,186
contributed_to: 17,106,111
```

Neo4j import 输出：

```text
IMPORT DONE in 5m 53s 790ms.
Imported:
  16945390 nodes
  67157768 relationships
  109975176 properties
Peak memory usage: 1.190GiB
```

离线检查结果：

```text
Store needs recovery: false
neo4j-admin database check neo4j: exit code 0
```

目标目录大小：

```text
1.1G  /mnt/data/imported_data/neo4j/graphdblp/raw
8.0G  /mnt/data/imported_data/neo4j/graphdblp/data
0     /mnt/data/imported_data/neo4j/graphdblp/import.report
```

本次没有启动 Neo4j server，也没有执行查询套件；这里只验证了离线导入、store info 和 consistency check。

## 6. 点数和边数

### 6.1 点 label 计数

| Label | Count |
| --- | ---: |
| author | 4,229,058 |
| keyword | 1,173 |
| publication | 12,690,688 |
| venue | 24,471 |

点总数：

```text
16,945,390
```

### 6.2 关系 type 计数

| Type | Count |
| --- | ---: |
| authored | 33,543,471 |
| contains | 16,508,186 |
| contributed_to | 17,106,111 |

关系总数：

```text
67,157,768
```

## 7. CSV 行数验证

本次验证已经通过。验证口径：

1. Neo4j CSV 是脚本从 XML 生成的 typed CSV。
2. 每个 CSV 的数据行数按 `total_rows - 1 header` 计算。
3. CSV 行数汇总等于 Neo4j import 输出中的 node/relationship 总数。

逐表验证结果：

| CSV | Rows |
| --- | ---: |
| authors.csv | 4,229,058 |
| publications.csv | 12,690,688 |
| venues.csv | 24,471 |
| keywords.csv | 1,173 |
| authored.csv | 33,543,471 |
| contains.csv | 16,508,186 |
| contributed_to.csv | 17,106,111 |

关键输出：

```text
Node input total: 16945390
Relationship input total: 67157768
Count validation passed.
```

如果已经用 `--cleanup-csv` 删除了中间 CSV，想重新验证计数，需要重新从 XML 生成 CSV，再跳过导入：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_graphdblp.py \
  --xml "$GRAPHDBLP_TARGET/raw/dblp.xml.gz" \
  --keywords "$GRAPHDBLP_TARGET/raw/keywords.csv" \
  --csv-dir "$GRAPHDBLP_TARGET/csv" \
  --target-dir "$GRAPHDBLP_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --skip-import \
  --validate-counts \
  --cleanup-csv
```

## 8. 只重新检查数据库

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_graphdblp.py \
  --xml "$GRAPHDBLP_TARGET/raw/dblp.xml.gz" \
  --csv-dir "$GRAPHDBLP_TARGET/csv" \
  --target-dir "$GRAPHDBLP_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --skip-prepare \
  --skip-import \
  --check
```

## 9. 图模型

节点：

```text
author(id, name)
publication(id, key, title, year, type, venue)
venue(id, name, type)
keyword(id, key)
```

关系：

```text
publication-[:authored {author_order}]->author
publication-[:contains]->keyword
author-[:contributed_to]->venue
```

## 10. 与原 GraphDBLP dump 的差异

GraphDBLP 原始 README 说明其 dump 基于 DBLP 2016 年 12 月快照，并包含 word embedding 和统计计算得到的增强信息。当前流程使用本机的 DBLP XML 快照：

```text
/mnt/data/datasets/graphdblp/dblp.xml.gz
```

该文件时间戳为 2026-06-09，规模和原 GraphDBLP dump 不同。

当前流程不会生成以下增强内容：

```text
keyword_sim 节点
keyword-[:similar_to {score}]->keyword_sim
venue-[:similarity {jaccard_percent/value}]->venue
author-[:has_research_topic {score, relevance}]->keyword
```

这些增强关系需要额外实现 NLP/embedding、venue 共现相似度、作者主题权重计算。本文档不把这些未生成的数据写成已导入内容。
