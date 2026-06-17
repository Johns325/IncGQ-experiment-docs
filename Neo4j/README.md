# Neo4j 实验脚本说明

本文档只描述当前 Neo4j 目录下脚本的真实行为。正式 benchmark 入口和 Kuzu 对齐：baseline 与 optimization 分开。

所有命令默认从文档仓库根目录执行：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
```

## 当前入口

| 脚本 | 用途 | 查询目录 |
| --- | --- | --- |
| `Neo4j/run-neo4j-baseline.py` | 正式 baseline benchmark 入口 | `Neo4j/queries/baseline/<dataset>` |
| `Neo4j/run-neo4j-optimization.py` | 正式 optimization benchmark 入口；每个优化查询先运行对应 materialization | `Neo4j/queries/optimized/<dataset>` |
| `Neo4j/run-neo4j-workload.py` | legacy/smoke 入口 | `Neo4j/queries/baseline/<dataset>` |

`run-neo4j-optimization.py` 的“建索引”不是 Neo4j 原生 schema index。它运行 `Neo4j/queries/index/<dataset>/<query>/index.cypher`，把 NeuG/Kuzu 对齐的派生值物化为节点属性、关系属性或辅助关系，然后运行 optimized 查询。

## Workload 映射

| Workload | 数据库目录 | baseline 查询目录 | optimized 查询目录 | index/materialization 目录 |
| --- | --- | --- | --- | --- |
| `ic-sf1` | `/mnt/data/imported_data/neo4j/ic-sf1` | `Neo4j/queries/baseline/ldbc-ic` | `Neo4j/queries/optimized/ldbc-ic` | `Neo4j/queries/index/ldbc-ic` |
| `bi-sf1` | `/mnt/data/imported_data/neo4j/bi-sf1` | `Neo4j/queries/baseline/ldbc-bi` | `Neo4j/queries/optimized/ldbc-bi` | `Neo4j/queries/index/ldbc-bi` |
| `lsqb-sf1` | `/mnt/data/imported_data/neo4j/lsqb/sf1` | `Neo4j/queries/baseline/lsqb` | `Neo4j/queries/optimized/lsqb` | `Neo4j/queries/index/lsqb` |
| `finbench-sf1` | `/mnt/data/imported_data/neo4j/finbench/sf1` | `Neo4j/queries/baseline/finbench` | 未整理 | 未整理 |

## Benchmark 计时口径

`Neo4j/run-neo4j-baseline.py` 和 `Neo4j/run-neo4j-optimization.py` 与 Kuzu 的 benchmark 口径一致：

1. 每次脚本只启动一次 Neo4j server，并创建一个 Bolt driver/session。
2. Neo4j server 启动、driver/session 创建时间不计入查询时间。
3. 对每个 query、每个 sample round，先执行完整 warmup phase，再执行 performance phase。
4. 默认 `--warmup-count 1`，即每个 selected sample round 的每个参数行 warmup 一次。
5. 默认 `--performance-count 3`，即做 3 个 performance iteration；每个 iteration 都跑完整参数集。
6. summary 先对一个 iteration 内所有参数行求平均，再对该 round 的多个 iteration 平均值求平均。
7. warmup 和 index/materialization setup 不进入 summary 的 query-time 统计。

以 `--sample-rounds 1-3 --param-count 10 --performance-count 3` 为例，单个查询顺序是：

```text
round 1: warmup#1 row 1..10
round 1: performance#1 row 1..10
round 1: performance#2 row 1..10
round 1: performance#3 row 1..10
round 2: warmup#1 row 1..10
round 2: performance#1 row 1..10
...
```

## 常用命令

Baseline：

```bash
Neo4j/run-neo4j-baseline.py \
  --workload ic-sf1 \
  --query ic1 \
  --sample-rounds 1-3 \
  --param-count 10 \
  --mode execute
```

Optimization：

```bash
Neo4j/run-neo4j-optimization.py \
  --workload lsqb-sf1 \
  --query q1 \
  --sample-rounds 1-3 \
  --param-count 10 \
  --mode execute
```

跳过 materialization 只适合检查 optimized 查询语法，不代表真实 optimization benchmark：

```bash
Neo4j/run-neo4j-optimization.py \
  --workload lsqb-sf1 \
  --query q1 \
  --skip-index-setup \
  --mode explain
```

## 输出文件

正式 benchmark 默认写三个文件：

```text
/mnt/data/results/neo4j/baseline/<workload>/baseline-<timestamp>-results.csv
/mnt/data/results/neo4j/baseline/<workload>/baseline-<timestamp>-summary.csv
/mnt/data/results/neo4j/baseline/<workload>/baseline-<timestamp>-summary-wide.csv
```

optimization 路径同理，把 `baseline` 换成 `optimization`。

Detail CSV 字段与 Kuzu 对齐：

```text
query,sample_round,phase,iteration,parameter_index,parameters,results,time_seconds,setup_time_seconds
```

Summary CSV 使用 `|` 分隔：

```text
query|sample_round|performance_iterations|param_count|avg_time_seconds
```

Wide summary CSV 使用 `|` 分隔，每个 sample round 一列：

```text
query|t1|t2|t3
ic1|0.123456|0.234567|0.345678
```

脚本结束时也会在终端打印同样的 wide summary。
