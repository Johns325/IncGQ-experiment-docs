# Neo4j LDBC SNB BI SF1 实验流程

本文档说明如何从 `ldbc_snb_bi` 仓库完成 Neo4j 5.20.0 的 BI SF1 数据导入、查询执行和平均执行时间统计。文档不假设固定用户名、工作目录或数据目录；先设置变量，再执行命令。

## 1. 路径约定

按实际机器设置：

```bash
export WORK_ROOT=/path/to/workspace
export LDBC_SNB_BI_HOME="$WORK_ROOT/ldbc_snb_bi"
export LDBC_BI_DATA_DIR=/path/to/ldbc/bi-sf1-composite-projected-fk/graphs/csv/bi/composite-projected-fk/initial_snapshot
export LDBC_BI_PARAMETER_DIR=/path/to/ldbc/bi-parameters-sf1
export PYTHON_BIN=python3
export NEO4J_HTTP_PORT=17474
export NEO4J_BOLT_PORT=17687
```

含义：

```text
WORK_ROOT              任意工作目录根路径
LDBC_SNB_BI_HOME       ldbc_snb_bi 仓库路径
LDBC_BI_DATA_DIR       BI SF1 initial_snapshot 数据目录
LDBC_BI_PARAMETER_DIR  BI SF1 参数 CSV 目录
PYTHON_BIN             benchmark 使用的 Python
NEO4J_HTTP_PORT        Neo4j Browser 暴露到 host 的端口
NEO4J_BOLT_PORT        benchmark 连接 Neo4j 的 Bolt 端口
```

## 2. 前置依赖

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

安装 Python 依赖。`neo4j==5.20.0` 是 Neo4j Python driver 版本，用于 benchmark 连接 Neo4j server；数据库本体由 Docker 镜像 `neo4j:5.20.0` 提供。

```bash
"$PYTHON_BIN" -m pip install --user neo4j==5.20.0 python-dateutil
```

## 3. 克隆项目

```bash
mkdir -p "$WORK_ROOT"
cd "$WORK_ROOT"
git clone https://github.com/Johns325/ldbc_snb_bi.git
cd "$LDBC_SNB_BI_HOME"
```

确认脚本存在：

```bash
ls neo4j/scripts/run-bi-sf1-local.sh
```

## 4. 准备数据和参数

数据目录必须是 `composite-projected-fk` 的 `initial_snapshot`，例如目录结构应包含：

```text
$LDBC_BI_DATA_DIR/dynamic/Post_hasCreator_Person
$LDBC_BI_DATA_DIR/dynamic/Comment_replyOf_Post
$LDBC_BI_DATA_DIR/dynamic/Person_knows_Person
```

不要使用 `composite-merged-fk`。当前 Neo4j 导入脚本需要每种关系有独立目录。

检查数据和参数：

```bash
test -d "$LDBC_BI_DATA_DIR"
test -d "$LDBC_BI_PARAMETER_DIR"
ls "$LDBC_BI_PARAMETER_DIR" | head
```

## 5. 导入并执行查询

在仓库根目录执行：

```bash
cd "$LDBC_SNB_BI_HOME"

neo4j/scripts/run-bi-sf1-local.sh \
  --data-dir "$LDBC_BI_DATA_DIR" \
  --parameters-dir "$LDBC_BI_PARAMETER_DIR" \
  --queries 3 \
  --parameter-count 10 \
  --worker-threads 1 \
  --http-port "$NEO4J_HTTP_PORT" \
  --bolt-port "$NEO4J_BOLT_PORT" \
  --python "$PYTHON_BIN"
```

该命令会完成：

1. 检查数据目录和参数目录。
2. 如果 CSV 带表头，生成无表头副本到 `neo4j/local/prepared-csv/...`。
3. 生成与 CSV 列顺序匹配的 Neo4j typed headers 到 `neo4j/local/prepared-headers/...`。
4. 使用 Docker 镜像 `neo4j:5.20.0` 导入数据。
5. 启动 Neo4j 容器。
6. 创建索引。
7. 执行指定 BI 查询。
8. 统计每个 query variant 的平均执行时间，单位为毫秒。

## 6. 只执行查询，不重新导入

如果数据已经导入完成，只重新跑查询：

```bash
cd "$LDBC_SNB_BI_HOME"

neo4j/scripts/run-bi-sf1-local.sh \
  --data-dir "$LDBC_BI_DATA_DIR" \
  --parameters-dir "$LDBC_BI_PARAMETER_DIR" \
  --queries 3 \
  --skip-load \
  --parameter-count 10 \
  --http-port "$NEO4J_HTTP_PORT" \
  --bolt-port "$NEO4J_BOLT_PORT" \
  --python "$PYTHON_BIN"
```

如果要修改 Neo4j worker thread，需要先停掉容器再重新启动：

```bash
neo4j/scripts/stop.sh

neo4j/scripts/run-bi-sf1-local.sh \
  --data-dir "$LDBC_BI_DATA_DIR" \
  --parameters-dir "$LDBC_BI_PARAMETER_DIR" \
  --queries 3 \
  --skip-load \
  --worker-threads 1 \
  --parameter-count 10 \
  --http-port "$NEO4J_HTTP_PORT" \
  --bolt-port "$NEO4J_BOLT_PORT" \
  --python "$PYTHON_BIN"
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

设置 Neo4j 容器启动时的 worker thread 数，对应 Neo4j 配置：

```text
server.threads.worker_count
```

`--skip-load`

不重新导入数据，只启动或复用已有 Neo4j 容器并执行查询。

`--python`

指定 benchmark 使用的 Python：

```bash
--python "$PYTHON_BIN"
```

`--memory`

设置 Neo4j heap max 和 page cache：

```bash
--memory 20G
```

`--http-port` 和 `--bolt-port`

如果机器上已有服务占用了 Neo4j 默认端口 `7474` 或 `7687`，可以换 host 端口：

```bash
--http-port "$NEO4J_HTTP_PORT" --bolt-port "$NEO4J_BOLT_PORT"
```

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

默认输出目录：

```text
$LDBC_SNB_BI_HOME/neo4j/output/output-sf1/
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

## 10. 常见问题

### Docker 报 volume path invalid

如果看到类似：

```text
includes invalid characters for a local volume name
```

说明传给 Docker 的路径不是绝对路径。使用本文的变量时，建议把 `LDBC_BI_DATA_DIR` 和 `LDBC_BI_PARAMETER_DIR` 都设为绝对路径。

### 7474 或 7687 端口被占用

如果看到：

```text
failed to bind host port for 0.0.0.0:7474
address already in use
```

换 host 端口：

```bash
export NEO4J_HTTP_PORT=17474
export NEO4J_BOLT_PORT=17687
```

如果数据已经导入成功，只是容器启动时端口冲突失败，可以加 `--skip-load` 避免重新导入。

### Import failed: Error in input data

常见原因是 CSV 带表头但导入 header 不匹配。脚本会自动生成 prepared CSV 和 typed headers；如果之前生成过错误的 prepared CSV，可以删除后重跑：

```bash
rm -rf "$LDBC_SNB_BI_HOME/neo4j/local/prepared-csv"
rm -rf "$LDBC_SNB_BI_HOME/neo4j/local/prepared-headers"
```

### Python 找不到 neo4j 或 dateutil

安装依赖：

```bash
"$PYTHON_BIN" -m pip install --user neo4j==5.20.0 python-dateutil
```

或者把 `PYTHON_BIN` 指向已有依赖的 Python。

### Q19 GDS warning

如果看到 `gds.graph.project.cypher` deprecation warning，可以先忽略。它是 GDS 的弃用提醒，不影响实验执行。

## 11. 最小复现实验命令

首次导入并跑 BI19，每个 variant 10 个参数，单 worker thread：

```bash
cd "$LDBC_SNB_BI_HOME"

neo4j/scripts/run-bi-sf1-local.sh \
  --data-dir "$LDBC_BI_DATA_DIR" \
  --parameters-dir "$LDBC_BI_PARAMETER_DIR" \
  --queries 19 \
  --parameter-count 10 \
  --worker-threads 1 \
  --http-port "$NEO4J_HTTP_PORT" \
  --bolt-port "$NEO4J_BOLT_PORT" \
  --python "$PYTHON_BIN"
```

之后复跑查询：

```bash
neo4j/scripts/run-bi-sf1-local.sh \
  --data-dir "$LDBC_BI_DATA_DIR" \
  --parameters-dir "$LDBC_BI_PARAMETER_DIR" \
  --queries 19 \
  --skip-load \
  --parameter-count 10 \
  --http-port "$NEO4J_HTTP_PORT" \
  --bolt-port "$NEO4J_BOLT_PORT" \
  --python "$PYTHON_BIN"
```
