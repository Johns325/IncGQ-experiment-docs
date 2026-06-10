# Neo4j 导入 DBLP/GraphDBLP 核心图

本文档说明如何在 Neo4j 5.20 下，从 DBLP 官方 `dblp.xml.gz` 自建一个 GraphDBLP-like 的核心图。GraphDBLP 原 dump 下载链路不可用，因此本文档不再包含 dump 导入路线。

自建路线可以复现 DBLP 的核心图结构：作者、论文、venue、关键词，以及 authored、contains、contributed_to 关系。GraphDBLP dump 中基于 word embedding 或统计计算得到的增强数据不会凭空生成，具体差异见第 9 节。

## 1. 路径约定

按实际机器设置：

```bash
export WORK_ROOT=/home/glaucus/workspace/IncGQ
export GRAPH_DBLP_HOME="$WORK_ROOT/GraphDBLP"
export DOCS_HOME="$WORK_ROOT/IncGQ-experiment-docs"
export DBLP_RAW_DIR="$WORK_ROOT/dblp-raw"
export DBLP_CSV_DIR="$WORK_ROOT/dblp-neo4j-csv"
export NEO4J_HOME="$WORK_ROOT/ldbc_snb_bi/neo4j/local/neo4j-community-5.20.0"
export GRAPHDBLP_DATABASE=graphdblp_core
```

含义：

```text
WORK_ROOT           IncGQ 工作目录
GRAPH_DBLP_HOME    GraphDBLP 仓库路径，用于读取 keywords.csv
DOCS_HOME          IncGQ-experiment-docs 仓库路径
DBLP_RAW_DIR       DBLP 原始 XML 下载目录
DBLP_CSV_DIR       转换后 Neo4j CSV 输出目录
NEO4J_HOME         Neo4j Community Edition 5.20.0 安装目录
GRAPHDBLP_DATABASE 导入后的 Neo4j 数据库名
```

## 2. 前置依赖

需要准备：

```text
Neo4j Community Edition 5.20.0
Java 17
Python 3
Python package: lxml
wget 或 curl
```

确认 Neo4j 可用：

```bash
"$NEO4J_HOME/bin/neo4j" version
"$NEO4J_HOME/bin/neo4j-admin" help
```

安装 Python 依赖：

```bash
python3 -m pip install --user lxml
```

## 3. 下载 DBLP XML

DBLP 官方 XML 入口：

```text
https://dblp.org/xml/dblp.xml.gz
https://dblp.org/xml/dblp.dtd
https://dblp.org/xml/dblp.xml.gz.md5
```

截至 2026-06-10，DBLP XML 索引显示 `dblp.xml.gz` 约 1.0G，最近更新时间为 2026-06-09。实际导入时还会生成较大的 CSV 和 Neo4j store，建议预留几十 GB 磁盘空间。

下载：

```bash
mkdir -p "$DBLP_RAW_DIR"
cd "$DBLP_RAW_DIR"

wget https://dblp.org/xml/dblp.xml.gz
wget https://dblp.org/xml/dblp.dtd
wget https://dblp.org/xml/dblp.xml.gz.md5
```

校验：

```bash
md5sum -c dblp.xml.gz.md5
```

如果网络环境不允许直接下载，可以先在其他机器下载这三个文件，再拷贝到 `$DBLP_RAW_DIR`。

## 4. 生成 Neo4j CSV

转换脚本位于：

```text
$DOCS_HOME/scripts/prepare_dblp_for_neo4j_import.py
```

执行转换：

```bash
python3 "$DOCS_HOME/scripts/prepare_dblp_for_neo4j_import.py" \
  --xml "$DBLP_RAW_DIR/dblp.xml.gz" \
  --keywords "$GRAPH_DBLP_HOME/keywords.csv" \
  --out-dir "$DBLP_CSV_DIR"
```

脚本会流式解析 DBLP XML，并生成：

```text
$DBLP_CSV_DIR/authors.csv
$DBLP_CSV_DIR/publications.csv
$DBLP_CSV_DIR/venues.csv
$DBLP_CSV_DIR/keywords.csv
$DBLP_CSV_DIR/authored.csv
$DBLP_CSV_DIR/contains.csv
$DBLP_CSV_DIR/contributed_to.csv
$DBLP_CSV_DIR/neo4j-admin-import-graphdblp-core.sh
```

可以先跑小规模 smoke test：

```bash
python3 "$DOCS_HOME/scripts/prepare_dblp_for_neo4j_import.py" \
  --xml "$DBLP_RAW_DIR/dblp.xml.gz" \
  --keywords "$GRAPH_DBLP_HOME/keywords.csv" \
  --out-dir "$DBLP_CSV_DIR-smoke" \
  --limit 10000
```

本机已用迷你 DBLP XML 样例验证脚本可运行，样例输出包括：

```text
publications: 2
authors: 3
venues: 2
keywords: 2
authored: 4
contains: 2
contributed_to: 4
```

## 5. 导入 Neo4j 5.20

`neo4j-admin database import full` 要求目标数据库不存在或为空。导入前停止 Neo4j：

```bash
"$NEO4J_HOME/bin/neo4j" stop
```

执行脚本自动生成的导入命令：

```bash
export NEO4J_HOME="$NEO4J_HOME"
export GRAPHDBLP_DATABASE=graphdblp_core

bash "$DBLP_CSV_DIR/neo4j-admin-import-graphdblp-core.sh"
```

等价的完整命令：

```bash
"$NEO4J_HOME/bin/neo4j-admin" database import full \
  --overwrite-destination=true \
  --id-type=string \
  --nodes=author="$DBLP_CSV_DIR/authors.csv" \
  --nodes=publication="$DBLP_CSV_DIR/publications.csv" \
  --nodes=venue="$DBLP_CSV_DIR/venues.csv" \
  --nodes=keyword="$DBLP_CSV_DIR/keywords.csv" \
  --relationships=authored="$DBLP_CSV_DIR/authored.csv" \
  --relationships=contains="$DBLP_CSV_DIR/contains.csv" \
  --relationships=contributed_to="$DBLP_CSV_DIR/contributed_to.csv" \
  "$GRAPHDBLP_DATABASE"
```

`--overwrite-destination=true` 会覆盖 Neo4j data 目录下同名数据库。为了不影响 LDBC SNB 已导入的 `neo4j` 数据库，建议使用单独数据库名 `graphdblp_core`，或者复制一份独立 Neo4j 5.20 安装目录做测试。

## 6. 配置并启动 Neo4j

打开配置文件：

```bash
vim "$NEO4J_HOME/conf/neo4j.conf"
```

设置默认数据库：

```properties
initial.dbms.default_database=graphdblp_core
```

本地实验可以关闭认证：

```properties
dbms.security.auth_enabled=false
```

建议给 DBLP 图稍微多一些内存。下面只是示例，按机器内存调整：

```properties
server.memory.heap.initial_size=4G
server.memory.heap.max_size=8G
server.memory.pagecache.size=8G
```

如果当前机器遇到 inotify watch 数量不足，日志里出现 `User limit of inotify watches reached`，测试实例可以临时关闭文件 watcher：

```properties
db.filewatcher.enabled=false
```

启动：

```bash
"$NEO4J_HOME/bin/neo4j" start
```

查看日志：

```bash
tail -f "$NEO4J_HOME/logs/neo4j.log"
```

看到 Neo4j started 后，打开：

```text
http://localhost:7474/browser/
```

## 7. 导入验证

查看节点规模：

```cypher
MATCH (n)
RETURN labels(n) AS labels, count(*) AS count
ORDER BY count DESC;
```

查看关系规模：

```cypher
MATCH ()-[r]->()
RETURN type(r) AS rel_type, count(*) AS count
ORDER BY count DESC;
```

测试关键词到作者查询：

```cypher
MATCH (k:keyword)<-[:contains]-(p:publication)-[:authored]->(a:author)
WHERE k.key = 'data_mining'
RETURN k.key AS keyword, a.name AS author, count(DISTINCT p) AS publications
ORDER BY publications DESC
LIMIT 10;
```

测试作者 venue：

```cypher
MATCH (a:author)-[:contributed_to]->(v:venue)
WHERE a.name = 'Alice Smith'
RETURN a.name, collect(v.name)[0..20] AS venues;
```

## 8. 图模型

自建路线生成的核心结构：

```text
节点：
author, publication, venue, keyword

关系：
publication-[:authored]->author
publication-[:contains]->keyword
author-[:contributed_to]->venue
```

CSV 字段概要：

```text
author:
  id, name

publication:
  id, key, title, year, type, venue

venue:
  id, name, type

keyword:
  id, key

authored:
  publication -> author, author_order

contains:
  publication -> keyword

contributed_to:
  author -> venue
```

## 9. 与原 GraphDBLP dump 的差异

GraphDBLP 原始 README 说明其 dump 基于 DBLP 2016 年 12 月快照，并包含 word-embedding 和统计计算得到的增强信息。当前自建路线使用 DBLP 官方当前 XML，因此数据版本会更新，但不会自动生成以下增强内容：

```text
keyword_sim 节点
keyword-[:similar_to {score}]->keyword_sim
venue-[:similarity {jaccard_percent/value}]->venue
author-[:has_research_topic {score, relevance}]->keyword
```

这些增强关系需要额外实现 NLP/embedding、venue 共现相似度、作者主题权重计算。当前 GraphDBLP 仓库没有提供对应的原始构建脚本，因此本文档不伪造这些分数。

对应影响：

```text
可以直接支持：
- 基于 author/publication/venue 的图查询
- publication-title keyword 匹配后的关键词查询
- author -> venue 的贡献关系查询
- authored/contains/contributed_to 上的路径查询

需要额外实现后才能支持：
- GraphDBLP Q1/Q2 中依赖 has_research_topic.score/relevance 的排序
- GraphDBLP Q3 中依赖 venue similarity 的社区/聚类查询
- keyword_sim 和 similar_to 相关查询
```

## 10. 常见问题

`lxml` 安装失败：

先确认 Python 和 pip 可用。如果机器不能联网安装 Python 包，可以在有网络的机器上构建 wheel 后离线安装。

XML 解析报 DTD 或实体错误：

确认 `dblp.dtd` 和 `dblp.xml.gz` 在同一目录。DBLP XML 依赖 DTD 中定义的实体，缺少 DTD 可能导致解析失败。

Neo4j Browser 打开后没有数据：

检查 `initial.dbms.default_database=graphdblp_core`，确认导入目录是 `$NEO4J_HOME/data/databases/graphdblp_core`，并查看 `logs/neo4j.log` 是否启动了同一个数据库。

查询运行很慢：

DBLP 是百万级 publication、作者和关系图。提高 heap/page cache，并优先用 `LIMIT 10` 的查询做 smoke test。路径查询和大范围聚合查询可能需要较长时间。

