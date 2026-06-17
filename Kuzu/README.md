# Kuzu 实验脚本说明

本文档只描述当前 Kuzu 目录下脚本的真实行为。用于正式对比实验时，推荐使用 baseline/optimization 两个入口；旧的 workload wrapper 只用于语法检查、单查询调试或历史兼容。

所有示例默认从文档仓库根目录执行：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
```

## 当前入口

| 脚本 | 用途 | 查询目录 |
| --- | --- | --- |
| `Kuzu/run-kuzu-baseline.py` | 正式 baseline benchmark 入口 | `Kuzu/queries/baseline/<dataset>` |
| `Kuzu/run-kuzu-optimization.py` | 正式 optimization benchmark 入口；每个优化查询先运行对应 materialization | `Kuzu/queries/optimized/<dataset>` |
| `Kuzu/run-kuzu-workload.py` | legacy/smoke 入口；等价于直接调用 `Kuzu/scripts/run-workload.py` | `Kuzu/queries/baseline/<dataset>` |
| `Kuzu/scripts/run-*.sh` | legacy/smoke workload wrapper | `Kuzu/queries/baseline/<dataset>` |

`run-kuzu-optimization.py` 的“建索引”不是 Kuzu 原生 `CREATE INDEX`。它会运行 `Kuzu/queries/index/<dataset>/<query>/index.cypher`，把 NeuG index/setup 模板的结果物化到 Kuzu 的属性或辅助关系表里，然后再运行 optimized 查询。

## Workload 映射

| Workload | 数据库目录 | baseline 查询目录 | optimized 查询目录 | index/materialization 目录 |
| --- | --- | --- | --- | --- |
| `ic-sf1` | `/mnt/data/imported_data/kuzu/ic-sf1` | `Kuzu/queries/baseline/ldbc-ic` | `Kuzu/queries/optimized/ldbc-ic` | `Kuzu/queries/index/ldbc-ic` |
| `bi-sf1` | `/mnt/data/imported_data/kuzu/bi-sf1` | `Kuzu/queries/baseline/ldbc-bi` | `Kuzu/queries/optimized/ldbc-bi` | `Kuzu/queries/index/ldbc-bi` |
| `lsqb-sf1` | `/mnt/data/imported_data/kuzu/lsqb/sf1` | `Kuzu/queries/baseline/lsqb` | `Kuzu/queries/optimized/lsqb` | `Kuzu/queries/index/lsqb` |
| `finbench-sf1` | `/mnt/data/imported_data/kuzu/finbench` | `Kuzu/queries/baseline/finbench` | 未整理 | 未整理 |
| `graphdblp` | `/mnt/data/imported_data/kuzu/graphdblp` | legacy runner 使用 `NeuG/queries/graphdblp/distinct` | 未整理 | 未整理 |

当前 `run-kuzu-baseline.py` 和 `run-kuzu-optimization.py` 只接受 `Kuzu/scripts/run-benchmark.py` 的 `DATASET_DIRS` 中已有映射的 workload：`ic-sf1`、`bi-sf1`、`lsqb-sf1`、`finbench-sf1`。GraphDBLP 目前只通过 legacy/smoke runner 记录。

## Benchmark 计时口径

`Kuzu/run-kuzu-baseline.py` 和 `Kuzu/run-kuzu-optimization.py` 使用同一套 benchmark 逻辑：

1. 每次脚本进程只打开一次 Kuzu database，并创建一个 connection。
2. 所有 workload 的 Kuzu connection 都使用 `num_threads=1`；运行 banner 会打印 `threads=1`。
3. 打开数据库和创建 connection 的时间不计入查询时间。
4. 对每个 query、每个 sample round，先执行完整 warmup phase，再执行 performance phase。
5. 默认 `--warmup-count 1`，含义是每个 selected sample round 的每个参数行先 warmup 一次。
6. 默认 `--performance-count 3`，含义是做 3 个 performance iteration；每个 iteration 都跑完整参数集。
7. summary 先对一个 iteration 内所有参数行求平均，再对该 round 的多个 iteration 平均值求平均。
8. warmup、index/materialization setup 不进入 summary 的 query-time 统计。

以 `--sample-rounds 1-3 --param-count 10 --performance-count 3` 为例，单个查询的顺序是：

```text
round 1: warmup#1 row 1..10
round 1: performance#1 row 1..10
round 1: performance#2 row 1..10
round 1: performance#3 row 1..10
round 2: warmup#1 row 1..10
round 2: performance#1 row 1..10
...
```

optimization 模式在每个 optimized query 前额外运行一次对应的 `queries/index/.../index.cypher`。如果没有对应 index 文件，会打印 `index_setup SKIP no matching index/materialization script`，然后直接执行 optimized query。

## 常用命令

Baseline：

```bash
Kuzu/run-kuzu-baseline.py \
  --workload ic-sf1 \
  --query ic1 \
  --sample-rounds 1-3 \
  --param-count 10 \
  --mode execute
```

Optimization：

```bash
Kuzu/run-kuzu-optimization.py \
  --workload lsqb-sf1 \
  --query q1 \
  --sample-rounds 1-3 \
  --param-count 10 \
  --mode execute
```

对复制出来的数据库做 optimization smoke test：

```bash
cp -a /mnt/data/imported_data/kuzu/lsqb/sf1 /tmp/kuzu-lsqb-smoke
Kuzu/run-kuzu-optimization.py \
  --workload lsqb-sf1 \
  --db-dir /tmp/kuzu-lsqb-smoke \
  --query q1 \
  --param-count 1 \
  --warmup-count 1 \
  --performance-count 1 \
  --mode execute \
  --out /tmp/kuzu-lsqb-smoke-results.csv
```

跳过 optimization 的 materialization 只适合检查 optimized 查询语法，不代表真实 optimization benchmark：

```bash
Kuzu/run-kuzu-optimization.py \
  --workload lsqb-sf1 \
  --query q1 \
  --skip-index-setup \
  --mode explain
```

## 参数选择

`--query` 和 `--queries` 二选一。`--query` 支持短名、相对路径或绝对 `.cypher` 文件路径，例如：

```text
ic1
bi13
q1
tcr-1
tcr-1.cypher
ldbc-bi/bi13/bi-13.cypher
```

参数来源顺序：

1. 显式 `--params-file`。
2. 显式 `--params-dir`。
3. sampled 参数目录，默认 `/mnt/data/sampled_parameters` 下对应 workload 子目录。
4. 原始参数目录。
5. runner 内置 sanity 参数。

默认 sampled 参数目录：

```text
ic-sf1:       /mnt/data/sampled_parameters/ldbc_snb_ic/sf1
bi-sf1:       /mnt/data/sampled_parameters/ldbc_snb_bi/sf1
finbench-sf1: /mnt/data/sampled_parameters/finbench/sf1
```

`--sample-rounds` 支持 `3`、`1,3,5`、`1-3`。如果不指定 `--param-count`，sampled 参数模式下会跑该 round 里的所有参数；非 sampled 参数模式下默认只跑 1 行。

Kuzu 会拒绝未使用参数，所以 runner 会把参数 map 过滤为查询文本中实际出现的 `$param`。

## 输出文件

正式 benchmark 默认写三个文件：

```text
/mnt/data/results/kuzu/baseline/<workload>/baseline-<timestamp>-results.csv
/mnt/data/results/kuzu/baseline/<workload>/baseline-<timestamp>-summary.csv
/mnt/data/results/kuzu/baseline/<workload>/baseline-<timestamp>-summary-wide.csv

/mnt/data/results/kuzu/optimization/<workload>/optimization-<timestamp>-results.csv
/mnt/data/results/kuzu/optimization/<workload>/optimization-<timestamp>-summary.csv
/mnt/data/results/kuzu/optimization/<workload>/optimization-<timestamp>-summary-wide.csv
```

`--out PATH` 可以指定 detail results CSV；summary 和 wide summary 会根据该路径自动派生。

Detail CSV 字段：

```text
query,sample_round,phase,iteration,parameter_index,parameters,results,time_seconds,setup_time_seconds
```

Summary CSV 使用 `|` 分隔：

```text
query|sample_round|performance_iterations|param_count|avg_time_seconds
ic1|1|3|10|0.123456
ic1|2|3|10|0.234567
```

Wide summary CSV 也使用 `|` 分隔，每个 sample round 一列：

```text
query|t1|t2|t3
ic1|0.123456|0.234567|0.345678
```

脚本结束时也会在终端打印同样的 wide summary。

## Legacy/smoke runner

`Kuzu/run-kuzu-workload.py` 和 `Kuzu/scripts/run-*.sh` 是旧入口，仍可用于快速 explain/execute 单个 baseline 查询。它们的默认 `--runner` 是 `isolated`，会为每个参数行启动子进程，因此计时包含子进程启动和打开数据库开销；这不是当前推荐的 benchmark 口径。

需要和正式 benchmark 更接近时，可以显式使用：

```bash
Kuzu/run-kuzu-workload.py \
  --workload ic-sf1 \
  --query ic1 \
  --runner persistent \
  --warmup-count 1 \
  --performance-count 3 \
  --param-count 10 \
  --mode execute
```

legacy runner 支持 `--allow-writes`；FinBench `tw-*` 在没有 `--allow-writes` 时即使 `--mode execute` 也只做 `EXPLAIN`。GraphDBLP 在 legacy runner 中只支持 `explain`，不支持 `execute`。

## 注意事项

- 不要同时运行两个指向同一个 Kuzu 数据库目录的写入型 runner；Kuzu 会使用 database lock。
- optimization materialization 会修改目标数据库。正式跑 canonical database 前，先确认这些物化结果是你想保留的；调试时优先用 `--db-dir` 指向 `/tmp` 下的数据库副本。
- `--timeout` 只对 legacy `--runner isolated` 有效；正式 benchmark runner 接受该参数只是为了 CLI 兼容，会忽略它。
- `--fetch-rows 0` 表示 materialize 所有返回行到 results 字段；大结果集建议设置一个小的 `--fetch-rows`。
- `scripts/benchmark-runner.md` 是正式 benchmark runner 的短说明；`workloads/*.md` 保留各 workload 的 schema/query 备注。
