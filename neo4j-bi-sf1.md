# Neo4j LDBC SNB BI SF1 实验流程

本文档记录如何在一台新机器上，从 `ldbc_snb_bi` 仓库重新完成 Neo4j 5.20.0 的下载/启动、BI SF1 数据导入、BI 查询执行和平均执行时间统计。

## 1. 新机器前置依赖

需要安装：

```text
Docker
Python 3
pip
Git
```

确认 Docker 可用：

```bash
docker ps
```

安装 Python 依赖。这里的 `neo4j==5.20.0` 是 Neo4j Python driver 版本，用于 benchmark 连接 Neo4j server；数据库本体仍由 Docker 镜像 `neo4j:5.20.0` 提供。

```bash
python3 -m pip install --user neo4j==5.20.0 python-dateutil
```

如果机器有多个 Python 环境，也可以在运行脚本时用 `--python` 指定。

## 2. 克隆项目

```bash
git clone https://github.com/Johns325/ldbc_snb_bi.git
cd ldbc_snb_bi
```

确认脚本存在：

```bash
ls neo4j/scripts/run-bi-sf1-local.sh
```

## 3. 准备数据和参数

默认数据路径 （请修改为当前的数据路径）：

```text
~/workspace/dataset/ldbc/data/bi/bi-sf1-composite-projected-fk/graphs/csv/bi/composite-projected-fk/initial_snapshot
```

默认参数路径（请修改为当前的参数路径）：

```text
~/workspace/dataset/ldbc/parameters/bi_parameters/bi-parameters-sf1
```

注意数据集必须是：

```text
composite-projected-fk
```

不要使用：

```text
composite-merged-fk
```

因为当前 Neo4j 导入脚本需要每种关系有独立目录，例如：

```text
Post_hasCreator_Person
Comment_replyOf_Post
Person_knows_Person
```

## 4. 一键导入并执行查询

在仓库根目录执行：

```bash
neo4j/scripts/run-bi-sf1-local.sh \
  --queries 3 \
  --parameter-count 10 \
  --worker-threads 1 \
  --http-port 17474 \
  --bolt-port 17687

```

该命令会完成：

1. 检查数据目录和参数目录。
2. 如果 CSV 带表头，生成无表头副本到 `neo4j/local/prepared-csv/...`。
3. 生成与 CSV 列顺序匹配的 Neo4j typed headers 到 `neo4j/local/prepared-headers/...`。
4. 使用 Docker 镜像 `neo4j:5.20.0` 导入数据。
5. 启动容器 `snb-bi-neo4j`。
6. 创建索引。
7. 执行指定 BI 查询。
8. 统计每个 query variant 的平均执行时间，单位为毫秒。

## 6. 只执行查询，不重新导入

如果数据已经导入完成，只重新跑查询：

```bash
neo4j/scripts/run-bi-sf1-local.sh \
  --queries 3 \
  --skip-load \
  --parameter-count 10 \
  --http-port 17474 \
  --bolt-port 17687
```

如果需要设置 Neo4j worker thread 为 1，需要让容器重新启动后配置才生效：

```bash
neo4j/scripts/stop.sh

neo4j/scripts/run-bi-sf1-local.sh \
  --queries 3 \
  --skip-load \
  --worker-threads 1 \
  --parameter-count 10 \
  --http-port 17474 \
  --bolt-port 17687
```

## 7. 常用参数

`--queries`

指定查询。可以写 `19`、`15,19`、`15a,19b` 等。对于带 a/b variant 的查询，写 `19` 会展开为 `19a` 和 `19b`。

```bash
--queries 15,19
```

`--parameter-count`

每个 query variant 执行多少组参数。

```bash
--parameter-count 10
```

`--worker-threads`

设置 Neo4j 容器启动时的 worker thread 数。对应 Neo4j 配置：

```text
server.threads.worker_count
```

Docker 环境变量形式：

```text
NEO4J_server_threads_worker__count=1
```

`--skip-load`

不重新导入数据，只启动/复用已有 Neo4j 容器并执行查询。

`--python`

指定 benchmark 使用的 Python：

```bash
--python /home/<user>/miniconda3/bin/python3
```

`--memory`

设置 Neo4j heap max 和 page cache：

```bash
--memory 20G
```

`--http-port` 和 `--bolt-port`

如果机器上已有服务占用了 Neo4j 默认端口 `7474` 或 `7687`，可以换 host 端口：

```bash
--http-port 17474 --bolt-port 17687
```

其中 `--http-port` 是 Neo4j Browser 端口，`--bolt-port` 是 benchmark 连接 Neo4j 的端口。

## 8. BI15 和 BI19 的特殊规则

BI15 默认使用 without-date 版本：

```text
neo4j/queries/bi-15-without-date.cypher
```

如果参数目录中存在：

```text
bi-15a-without-date.csv
bi-15b-without-date.csv
```

脚本会自动使用这些参数文件。

BI19 默认使用 without-precomputation 版本：

```text
neo4j/queries/bi-19-without-precomputation.cypher
```

该版本不会依赖预先创建的 `bi19` GDS graph，而是在每个参数执行时临时创建图并在执行后 drop。

## 9. 输出文件

输出目录：

```text
neo4j/output/output-sf1/
```

重要文件：

```text
query-summary.csv
timings.csv
bi19a-without-precomputation-results.csv
bi19b-without-precomputation-results.csv
bi15a-without-date-results.csv
bi15b-without-date-results.csv
```

`query-summary.csv` 字段：

```text
query|count|total_ms|avg_ms|min_ms|max_ms
```

示例：

```text
19a-without-precomputation|10|1200.321|120.032|95.100|180.455
```

## 10. 常见问题

### Docker 报 volume path invalid

如果看到类似：

```text
includes invalid characters for a local volume name
```

说明传给 Docker 的路径不是绝对路径。当前 `run-bi-sf1-local.sh` 已经会自动把路径转成绝对路径；如果手动调用底层脚本，请使用绝对路径。

### 7474 或 7687 端口被占用

如果看到：

```text
failed to bind host port for 0.0.0.0:7474
address already in use
```

说明机器上已经有服务占用了 Neo4j 默认 HTTP 端口。可以改用其他 host 端口：

```bash
neo4j/scripts/run-bi-sf1-local.sh \
  --queries 3 \
  --parameter-count 10 \
  --worker-threads 1 \
  --http-port 17474 \
  --bolt-port 17687
```

如果数据已经导入成功，只是容器启动时端口冲突失败，可以避免重新导入：

```bash
neo4j/scripts/run-bi-sf1-local.sh \
  --queries 3 \
  --skip-load \
  --parameter-count 10 \
  --worker-threads 1 \
  --http-port 17474 \
  --bolt-port 17687
```

### Import failed: Error in input data

常见原因是 CSV 带表头但导入 header 不匹配。当前一键脚本会自动：

1. 去掉 CSV 数据文件表头。
2. 生成匹配列顺序的 typed headers。

如果之前生成过错误的 prepared CSV，可以删除对应目录后重跑：

```bash
rm -rf neo4j/local/prepared-csv
rm -rf neo4j/local/prepared-headers
```

### Python 找不到 neo4j 或 dateutil

安装依赖：

```bash
python3 -m pip install --user neo4j==5.20.0 python-dateutil
```

或者指定已有依赖的 Python：

```bash
neo4j/scripts/run-bi-sf1-local.sh \
  --queries 19 \
  --skip-load \
  --python /home/<user>/miniconda3/bin/python3
```

### Q19 GDS warning

如果看到 `gds.graph.project.cypher` deprecation warning，可以先忽略。它是 GDS 的弃用提醒，不影响实验执行。

## 11. 最小复现实验命令

首次导入并跑 BI19，每个 variant 10 个参数，单 worker thread：

```bash
neo4j/scripts/run-bi-sf1-local.sh \
  --queries 19 \
  --parameter-count 10 \
  --worker-threads 1
```

之后复跑查询：

```bash
neo4j/scripts/run-bi-sf1-local.sh \
  --queries 19 \
  --skip-load \
  --parameter-count 10
```
