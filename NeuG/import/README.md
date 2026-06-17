# NeuG Workload 数据导入

本文档说明如何把 LDBC SNB IC、LDBC SNB BI、FinBench 和 LSQB 的 SF1 CSV 数据导入为 NeuG/IncGQ 本地数据库。

统一导入入口：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG

python3 scripts/import-workload.py --help
```

导入脚本使用本目录下随仓库保存的 graph/import YAML，并调用 NeuG build 里的 `bulk_loader`。默认路径是：

```text
/root/workspace/neug/build/tools/utils/bulk_loader
```

## 1. 前置条件

先确认 NeuG 已经编译出 `bulk_loader`：

```bash
test -x /root/workspace/neug/build/tools/utils/bulk_loader
```

如果这个文件不存在，需要先回到 NeuG 仓库完成编译。

如果你的 NeuG 仓库或 build 目录不在默认位置，可以显式指定：

```bash
python3 scripts/import-workload.py \
  --workload ic-sf1 \
  --bulk-loader /path/to/neug/build/tools/utils/bulk_loader
```

导入脚本依赖 Python 的 `yaml` 包：

```bash
python3 -c "import yaml"
```

如果缺失，需要在当前 Python 环境安装 `PyYAML`。

## 2. 默认数据源和目标库

脚本默认导入这些 workload：

| Workload | 数据集 | 默认 CSV 数据目录 | 默认目标库目录 |
| --- | --- | --- | --- |
| `ic-sf1` | LDBC SNB Interactive SF1 | `/mnt/data/datasets/ldbc_snb_ic/social_network-sf1-CsvComposite-StringDateFormatter` | `/mnt/data/imported_data/incgq/ic-sf1` |
| `bi-sf1` | LDBC SNB BI SF1 | `/mnt/data/datasets/ldbc_snb_bi/bi-sf1-composite-projected-fk/graphs/csv/bi/composite-projected-fk/initial_snapshot` | `/mnt/data/imported_data/incgq/bi-sf1` |
| `finbench-sf1` | FinBench SF1 snapshot | `/mnt/data/datasets/finbench/sf1/snapshot` | `/mnt/data/imported_data/incgq/finbench-sf1` |
| `lsqb-sf1` | LSQB SF1 | `/mnt/data/datasets/lsqb/social-network-sf1-projected-fk` | `/mnt/data/imported_data/incgq/lsqb-sf1` |

Schema 和 import mapping 已复制到本目录，其他用户只看这个 repo 就能知道导入配置：

```text
NeuG/import/configs/ldbc/graph.yaml
NeuG/import/configs/ldbc/import.yaml
NeuG/import/configs/ldbc/graph-bi.yaml
NeuG/import/configs/ldbc/import-bi-sf1.yaml
NeuG/import/configs/finbench/graph-finbench.yaml
NeuG/import/configs/finbench/import-finbench-sf1.yaml
NeuG/import/configs/lsqb/graph-lsqb.yaml
NeuG/import/configs/lsqb/import-lsqb.yaml
```

这些文件是导入脚本的默认配置源。脚本运行时会把 import yaml 临时复制到 `/tmp/neug-local-import-configs`，并把其中的 `loading_config.data_source.location` 改成上表中的默认 CSV 数据目录。

## 3. 单独导入

### LDBC SNB IC

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG

python3 scripts/import-workload.py \
  --workload ic-sf1 \
  --overwrite \
  -p 8
```

导入完成后目标库位于：

```text
/mnt/data/imported_data/incgq/ic-sf1
```

### LDBC SNB BI

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG

python3 scripts/import-workload.py \
  --workload bi-sf1 \
  --overwrite \
  -p 8
```

导入完成后目标库位于：

```text
/mnt/data/imported_data/incgq/bi-sf1
```

### FinBench

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG

python3 scripts/import-workload.py \
  --workload finbench-sf1 \
  --overwrite \
  -p 8
```

导入完成后目标库位于：

```text
/mnt/data/imported_data/incgq/finbench-sf1
```

### LSQB

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG

python3 scripts/import-workload.py \
  --workload lsqb-sf1 \
  --overwrite \
  -p 8
```

导入完成后目标库位于：

```text
/mnt/data/imported_data/incgq/lsqb-sf1
```

## 4. 一次导入多个 workload

导入指定多个 workload：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG

python3 scripts/import-workload.py \
  --workload ic-sf1 \
  --workload bi-sf1 \
  --workload finbench-sf1 \
  --workload lsqb-sf1 \
  --overwrite \
  -p 8
```

导入脚本支持 `--all`，等价于导入当前脚本支持的全部 workload：

```bash
python3 scripts/import-workload.py --all --overwrite -p 8
```

## 5. 参数说明

常用参数：

| 参数 | 含义 |
| --- | --- |
| `--workload NAME` | 选择一个 workload。可重复传入多次。 |
| `--all` | 导入脚本支持的全部 workload。 |
| `--overwrite` | 如果目标库目录已存在且非空，先删除旧目录再重新导入。 |
| `--bulk-loader PATH` | 指定 NeuG `bulk_loader` 二进制路径。默认是 `/root/workspace/neug/build/tools/utils/bulk_loader`。 |
| `-p, --parallelism N` | 传给 `bulk_loader -p` 的并行度。默认是 `4`。 |
| `--build-csr-in-mem` | 构建 CSR 时使用内存模式。脚本默认开启。 |
| `--no-build-csr-in-mem` | 关闭内存 CSR 构建。 |
| `--use-mmap-vector` | 额外传给 `bulk_loader` 的 mmap vector 选项。 |

如果目标目录已有半成品或旧库，但没有传 `--overwrite`，脚本会停止并提示：

```text
<db_dir> exists and is not empty; pass --overwrite to replace it
```

## 6. 脚本实际执行的 bulk_loader 形式

每个 workload 最终都会执行类似下面的命令：

```bash
/root/workspace/neug/build/tools/utils/bulk_loader \
  -g <graph-config.yaml> \
  -l /tmp/neug-local-import-configs/import-<workload>.yaml \
  -d /mnt/data/imported_data/incgq/<workload> \
  -p <parallelism> \
  --build-csr-in-mem
```

导入前脚本会做 preflight：

1. 检查 `bulk_loader` 是否存在。
2. 检查 graph config、import config、CSV 数据目录是否存在。
3. 读取 import mapping，确认所有输入 CSV 文件都能在数据目录下找到。

## 7. 导入后运行 workload

导入完成后可以直接使用 NeuG workload runner。例如 LSQB 不需要参数：

```bash
python3 run-neug-workload.py \
  --workload lsqb-sf1 \
  --mode execute \
  --performance-count 5
```

LDBC IC 使用 sampled 参数时：

```bash
python3 run-neug-workload.py \
  --workload ic-sf1 \
  --queries ic1,ic3,ic5,ic12,ic14 \
  --sample-round 3 \
  --param-count 10 \
  --performance-count 5 \
  --mode execute
```

结果默认写到：

```text
/mnt/data/results/neug/<workload>/<mode>-<timestamp>-results.csv
/mnt/data/results/neug/<workload>/<mode>-<timestamp>-summary.csv
```

## 8. 常见问题

### missing required paths

如果报：

```text
missing required paths:
...
```

说明 `bulk_loader`、配置文件或默认数据目录不存在。先确认第 2 节表格中的 CSV 数据目录已经准备好，且 NeuG 已经编译。

### missing input files

如果报：

```text
<workload> has N missing input files:
...
```

说明数据目录存在，但目录结构和 import yaml 不匹配。常见原因是传入了压缩包的上一级目录、未解压目录，或使用了另一个 benchmark 的 CSV layout。

### 目标目录已有内容

重新导入时加 `--overwrite`。注意该选项会删除目标库目录，例如：

```text
/mnt/data/imported_data/incgq/ic-sf1
```

确认目标目录不是手工保存的重要结果后再使用。
