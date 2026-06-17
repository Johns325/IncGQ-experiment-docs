# Kuzu/IncGQ LDBC BI 与 IC 实验流程

本文档说明如何编译 Kuzu LDBC BI/LSQB 数据、运行 BI/LSQB 查询，以及运行 LDBC SNB IC benchmark 查询。文档中的路径均使用变量表示，按实际机器替换即可。

## 1. 路径约定

先在 shell 中设置这些变量，后续命令都基于它们：

```bash
export KUZU_HOME=/path/to/kuzu
export KUZU_HOME=`pwd`
export DATA_ROOT=/path/to/datasets
export BUILD_DIR="$KUZU_HOME/build/release"
export SERIALIZED_DIR="$DATA_ROOT/serialized"
export THREADS=10
export SCRATCH_DIR=/path/to/scratch
```

含义：

```text
KUZU_HOME      Kuzu/IncGQ 仓库根目录
DATA_ROOT      数据集根目录
BUILD_DIR      Release 构建目录
SERIALIZED_DIR Kuzu 序列化数据库输出目录
THREADS        编译和查询使用的线程数
SCRATCH_DIR    临时验证、日志和中间结果目录，可改到任意可写目录
```

## 2. 编译项目

进入仓库：

```bash
cd "$KUZU_HOME"
```

如果编译器是 GCC 12+ 或 Clang 16+，通常可以直接编译：

```bash
cmake -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_PYTHON=TRUE \
  -DBUILD_SHELL=TRUE \
  -DBUILD_BENCHMARK=TRUE \
  .

cmake --build "$BUILD_DIR" --target _kuzu --config Release --parallel "$THREADS"
cmake --build "$BUILD_DIR" --target kuzu_shell --config Release --parallel "$THREADS"
cmake --build "$BUILD_DIR" --target kuzu_benchmark --config Release --parallel "$THREADS"
```

如果使用 GCC 11，`third_party/simsimd` 可能在 AVX512-FP16 路径上报错，例如：

```text
attribute 'avx512fp16' argument 'target' is unknown
unknown type name '__m512h'
```

这时关闭 Sapphire/Turin 动态分发路径：

```bash
cmake -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_PYTHON=TRUE \
  -DBUILD_SHELL=TRUE \
  -DBUILD_BENCHMARK=TRUE \
  -DCMAKE_C_FLAGS="-DSIMSIMD_TARGET_SAPPHIRE=0 -DSIMSIMD_TARGET_TURIN=0" \
  .

cmake --build "$BUILD_DIR" --target _kuzu --config Release --parallel "$THREADS"
cmake --build "$BUILD_DIR" --target kuzu_shell --config Release --parallel "$THREADS"
cmake --build "$BUILD_DIR" --target kuzu_benchmark --config Release --parallel "$THREADS"
```

编译完成后应有：

```text
$KUZU_HOME/tools/python_api/build/kuzu/_kuzu*.so
$BUILD_DIR/tools/shell/kuzu
$BUILD_DIR/tools/benchmark/kuzu_benchmark
```

验证 Python API：

```bash
cd "$KUZU_HOME"
python3 -c "import sys; sys.path.insert(0, 'tools/python_api/build'); import kuzu; print(kuzu.__version__)"
```

验证 shell：

```bash
mkdir -p "$SCRATCH_DIR"
printf 'RETURN 1;\n' | "$BUILD_DIR/tools/shell/kuzu" "$SCRATCH_DIR/kuzu-smoke-db" -p "$SCRATCH_DIR"
```

## 3. BI/LSQB 数据目录要求

`benchmark/lsqb/benchmark_runner.py` 跑的是 BI/LSQB 风格的 1-9 号查询：

```text
benchmark/lsqb/queries/q1.cypher
...
benchmark/lsqb/queries/q9.cypher
```

该 runner 要求 CSV 是扁平目录，一张点表或边表一个 CSV，例如：

```text
Company.csv
Person.csv
Post.csv
Person_knows_Person.csv
Post_hasCreator_Person.csv
```

设实际扁平 CSV 目录为：

```bash
export LSQB_CSV_FLAT_DIR="$DATA_ROOT/lsqb/social-network-sf1-projected-fk"
```

`benchmark/lsqb/benchmark_runner.py` 内部按下面的规则找数据：

```text
$CSV_DIR/lsqb-datasets/social-network-sf<SCALE_FACTOR>-projected-fk
```

因此需要准备兼容目录。以 SF1 为例：

```bash
export CSV_DIR="$DATA_ROOT/lsqb"
mkdir -p "$CSV_DIR/lsqb-datasets"
ln -sfn "$LSQB_CSV_FLAT_DIR" "$CSV_DIR/lsqb-datasets/social-network-sf1-projected-fk"
```

如果数据来自 LDBC BI datagen 的原始 `initial_snapshot` 输出，例如：

```text
initial_snapshot/dynamic/Person/part-*.csv
initial_snapshot/static/Place/part-*.csv
```

需要先合并/转换成“一表一个 CSV”的扁平目录，再交给当前 Kuzu LSQB runner。不要直接把 `initial_snapshot` 目录传给 `benchmark/lsqb/serializer.py`。

## 4. 导入 BI/LSQB 数据并运行查询

设置环境变量：

```bash
cd "$KUZU_HOME"

mkdir -p "$SERIALIZED_DIR"

export CSV_DIR="$DATA_ROOT/lsqb"
export SERIALIZED_DIR="$SERIALIZED_DIR"
export SCALE_FACTOR=1
export NUM_THREADS="$THREADS"
```

运行导入和 q1-q9：

```bash
python3 benchmark/lsqb/benchmark_runner.py
```

脚本流程：

1. 调用 `benchmark/lsqb/serializer.py`。
2. 创建 schema 并 COPY CSV。
3. 序列化数据库到 `$SERIALIZED_DIR/lsqb-sf1-serialized/db.kuzu`。
4. 运行 `benchmark/lsqb/queries/q1.cypher` 到 `q9.cypher`。
5. 写出结果到 benchmark runner 的结果目录和 `lsqb.log`。如需改结果目录，需要调整脚本中的 `benchmark_result_dir`。

如果 `$SERIALIZED_DIR/lsqb-sf1-serialized/version.txt` 与正在使用的 Kuzu 版本一致，脚本会跳过重新导入，直接运行查询。

## 5. 只导入 BI/LSQB 数据

如果只想导入，不跑 q1-q9：

```bash
cd "$KUZU_HOME"

python3 benchmark/lsqb/serializer.py \
  lsqb-sf1-ku \
  "$LSQB_CSV_FLAT_DIR" \
  "$SERIALIZED_DIR/lsqb-sf1-serialized"
```

导入后用 Python API 手动跑某条查询：

```bash
cd "$KUZU_HOME"

python3 - <<'PY'
import os
import sys

sys.path.insert(0, "tools/python_api/build")
import kuzu

serialized_dir = os.environ["SERIALIZED_DIR"]
threads = int(os.environ.get("THREADS", "1"))

db = kuzu.Database(f"{serialized_dir}/lsqb-sf1-serialized/db.kuzu")
conn = kuzu.Connection(db, num_threads=threads)

query = open("benchmark/lsqb/queries/q1.cypher", encoding="utf-8").read()
res = conn.execute(query)

while res.has_next():
    print(res.get_next())

print("compile_ms =", res.get_compiling_time())
print("execute_ms =", res.get_execution_time())
PY
```

## 6. IC 查询入口

仓库中的 LDBC SNB IC 查询不在 `benchmark/lsqb`，而是在通用 benchmark 目录下：

```text
benchmark/queries/ldbc-sf100/ldbc_snb_ic/q35.benchmark
benchmark/queries/ldbc-sf100/ldbc_snb_ic/q36.benchmark
```

同目录还有 Interactive Short：

```text
benchmark/queries/ldbc-sf100/ldbc_snb_is/q32.benchmark
benchmark/queries/ldbc-sf100/ldbc_snb_is/q33.benchmark
benchmark/queries/ldbc-sf100/ldbc_snb_is/q34.benchmark
```

通用 runner 是：

```text
benchmark/benchmark_runner.py
```

它要求 LDBC CSV 目录为：

```text
$CSV_DIR/ldbc-100/csv
```

其中 CSV 文件名需要匹配 `benchmark/serialize.cypher`，例如：

```text
person_0_0.csv
forum_0_0.csv
post_0_0.csv
comment_0_0.csv
person_knows_person_0_0.csv
post_hasCreator_person_0_0.csv
```

## 7. 导入 IC 数据并运行查询

设置路径：

```bash
cd "$KUZU_HOME"

mkdir -p "$SERIALIZED_DIR"

export CSV_DIR="$DATA_ROOT/ldbc"
export SERIALIZED_DIR="$SERIALIZED_DIR"
export DRY_RUN=true
```

`DRY_RUN=true` 很重要：不设置时脚本会要求 `JWT_TOKEN` 和 benchmark server URL，并尝试上传结果。

运行 LDBC SF100 benchmark：

```bash
python3 benchmark/benchmark_runner.py --dataset ldbc-sf100 --thread "$THREADS"
```

该脚本会：

1. 调用 `benchmark/serializer.py`，使用 `$BUILD_DIR/tools/shell/kuzu` 导入 CSV。
2. 序列化数据库到 `$SERIALIZED_DIR/ldbc-sf100-serialized/db.kz`。
3. 调用 `$BUILD_DIR/tools/benchmark/kuzu_benchmark`。
4. 扫描并运行 `benchmark/queries/ldbc-sf100` 下的所有 benchmark group，包括 `ldbc_snb_ic` 和 `ldbc_snb_is`。
5. 将查询日志写到 benchmark runner 的日志目录。如需改位置，需要调整脚本中的对应变量。

如果只想跑 IC group，可以直接调用 benchmark 二进制：

```bash
"$BUILD_DIR/tools/benchmark/kuzu_benchmark" \
  --dataset="$SERIALIZED_DIR/ldbc-sf100-serialized/db.kz" \
  --benchmark="$KUZU_HOME/benchmark/queries/ldbc-sf100/ldbc_snb_ic" \
  --warmup=1 \
  --run=5 \
  --out="$SCRATCH_DIR/benchmark_logs/ldbc_snb_ic" \
  --thread="$THREADS" \
  --profile
```

## 8. 常见问题

### GCC 11 编译 simsimd 失败

使用第 2 节的 `-DCMAKE_C_FLAGS`：

```text
-DSIMSIMD_TARGET_SAPPHIRE=0 -DSIMSIMD_TARGET_TURIN=0
```

也可以改用 GCC 12+ 或 Clang 16+。

### shell 报 history file 无法打开

如果看到：

```text
failed to open the history file: ~/.kuzu/history.txt
```

给 shell 指定可写 history 目录：

```bash
"$BUILD_DIR/tools/shell/kuzu" <db-path> -p "$SCRATCH_DIR"
```

### 不要并行构建同一个 build 目录的多个 CMake 目标

不要同时开两个命令分别构建 `kuzu_shell` 和 `kuzu_benchmark`。它们会写同一个 build 目录下的静态库，可能出现 `ranlib` 竞争。

正确做法是串行目标、每个目标内部多线程：

```bash
cmake --build "$BUILD_DIR" --target kuzu_shell --parallel "$THREADS"
cmake --build "$BUILD_DIR" --target kuzu_benchmark --parallel "$THREADS"
```

或者直接构建默认目标：

```bash
cmake --build "$BUILD_DIR" --parallel "$THREADS"
```

## 9. 本次验证备注

本次验证使用 GCC 11.4.0，因此采用了 `SIMSIMD_TARGET_SAPPHIRE=0` 和 `SIMSIMD_TARGET_TURIN=0`。已验证 Python API、shell、benchmark 二进制均可成功编译，shell 可执行 `RETURN 1;`。
