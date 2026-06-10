# MV4PG 环境与编译手册

更新时间：2026-06-09
适用仓库：`MV4PG`
目标：在任意 Linux 机器上准备 MV4PG 的编译环境，并说明本地已验证的编译结果和当前阻塞点。更详细的源码级步骤见作者仓库内的 `BUILD.md`。

## 0. 关键结论

MV4PG 包含三类需要准备的组件：

- `neo4j_test/CypherRewrite`：Neo4j 实验前使用的 C++ Cypher 改写工具。
- `tugraph_test/tugraph_db_without_views`：不带视图能力的 TuGraph 版本。
- `tugraph_test/tugraph_db_with_views`：带视图能力的 TuGraph 版本。

本地验证结论：

- `neo4j_test/CypherRewrite` 已在本机完整编译通过。
- 两份 TuGraph 源码的 CMake 配置路径已验证并修正过依赖查找问题。
- 当前 Ubuntu 22.04 + Boost 1.74 环境下，TuGraph 实际编译会失败，因为源码引用了 Boost.Geometry 已移除/未随发行版提供的 WKB 扩展头文件。
- 可移植构建优先使用 TuGraph 官方 CentOS 8 编译镜像，或准备包含旧 WKB 扩展头的 Boost 兼容环境。

## 1. 路径约定

在新机器上先设置这些变量：

```bash
export WORK_ROOT=/path/to/workspace
export MV4PG_HOME="$WORK_ROOT/IncGQ/MV4PG"
export SCRATCH_DIR=/path/to/scratch
export JOBS=2
```

含义：

```text
WORK_ROOT   工作区根目录
MV4PG_HOME  MV4PG 作者仓库路径
SCRATCH_DIR 临时构建、验证和日志目录
JOBS        编译并行度；内存较小时建议从 2 开始
```

进入源码仓库：

```bash
cd "$MV4PG_HOME"
```

## 2. 推荐方式：Docker 编译 TuGraph

TuGraph 部分依赖静态库和旧 Boost.Geometry 扩展头。为了避免不同 Linux 发行版之间的库路径和 Boost 版本差异，推荐使用 TuGraph 编译镜像：

```bash
docker pull tugraph/tugraph-compile-centos8
docker run --rm -it \
  --name mv4pg-build \
  -v "$MV4PG_HOME":/workspace/MV4PG \
  -w /workspace/MV4PG \
  tugraph/tugraph-compile-centos8 \
  bash
```

进入容器后编译：

```bash
export JOBS=${JOBS:-$(nproc)}

cmake -S neo4j_test/CypherRewrite -B neo4j_test/CypherRewrite/build
cmake --build neo4j_test/CypherRewrite/build -j"$JOBS"

cmake -S tugraph_test/tugraph_db_without_views \
  -B tugraph_test/tugraph_db_without_views/build \
  -DOURSYSTEM=centos \
  -DCMAKE_BUILD_TYPE=Release
cmake --build tugraph_test/tugraph_db_without_views/build -j"$JOBS"

cmake -S tugraph_test/tugraph_db_with_views \
  -B tugraph_test/tugraph_db_with_views/build \
  -DOURSYSTEM=centos \
  -DCMAKE_BUILD_TYPE=Release
cmake --build tugraph_test/tugraph_db_with_views/build -j"$JOBS"
```

主要产物：

```text
tugraph_test/tugraph_db_without_views/build/output/lgraph_server
tugraph_test/tugraph_db_without_views/build/output/lgraph_import
tugraph_test/tugraph_db_with_views/build/output/lgraph_server
tugraph_test/tugraph_db_with_views/build/output/lgraph_import
neo4j_test/CypherRewrite/build/CypherRewrite
```

## 3. 本机编译 CypherRewrite

如果只需要先验证 Neo4j 改写工具，可在本机直接编译：

```bash
cd "$MV4PG_HOME"
cmake -S neo4j_test/CypherRewrite -B "$SCRATCH_DIR/mv4pg-cypher-build"
cmake --build "$SCRATCH_DIR/mv4pg-cypher-build" -j"$JOBS"
```

本地已验证通过的环境：

```text
Ubuntu 22.04
GCC 11.4.0
CMake 3.22.1
```

## 4. 本机编译 TuGraph 的依赖

如果不使用 Docker，需要准备 Linux x86_64 C++ 编译环境和 TuGraph 依赖。

Ubuntu/Debian 参考：

```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  cmake \
  openjdk-11-jre \
  python3 \
  python3-dev \
  python3-pip \
  libssl-dev \
  libboost-all-dev \
  libjemalloc-dev \
  libgflags-dev \
  libgoogle-glog-dev \
  libleveldb-dev \
  libsnappy-dev \
  zlib1g-dev \
  libreadline-dev \
  uuid-dev \
  libaio-dev
```

TuGraph 内部的 geax-front-end 还需要 ANTLR4 4.13.0 generator jar 和 C++ runtime 静态库：

```text
$THIRD_PARTY/bin/antlr4-4.13.0-complete.jar
$THIRD_PARTY/include/antlr4-runtime/antlr4-runtime.h
$THIRD_PARTY/lib/libantlr4-runtime.a
```

如果依赖安装在自定义目录，配置 TuGraph 时传入：

```bash
-DCMAKE_PREFIX_PATH="$THIRD_PARTY" \
-DGFLAGS_ROOT_DIR="$THIRD_PARTY" \
-DGEAX_THIRD_PARTY_DIR="$THIRD_PARTY" \
-DTUGRAPH_THIRD_PARTY_DIR="$THIRD_PARTY"
```

## 5. 当前已知阻塞点

Ubuntu 22.04 默认 Boost 1.74 不包含 MV4PG 当前 TuGraph 源码引用的这些头文件：

```text
boost/geometry/extensions/gis/io/wkb/write_wkb.hpp
boost/geometry/extensions/gis/io/wkb/read_wkb.hpp
boost/geometry/extensions/gis/io/wkb/utility.hpp
```

本地编译两份 TuGraph 源码时会因此失败。处理方式：

- 优先使用第 2 节的 TuGraph CentOS 8 编译镜像。
- 或准备包含上述 Boost.Geometry WKB 扩展头的旧版/兼容 Boost，并确保 CMake 使用该 Boost。
- 或在源码层迁移到当前 Boost.Geometry 支持的 WKB 读写实现；这属于代码适配，不只是环境配置。

## 6. Neo4j 运行方式

MV4PG 的 Neo4j 实验不从仓库源码编译 Neo4j，而是运行脚本时通过 Docker 准备 Neo4j 服务。编译阶段只需要先生成 `neo4j_test/CypherRewrite/build/CypherRewrite`。

如果要继续执行完整实验脚本，请先确认：

```bash
docker --version
python3 -m pip show neo4j
```

Python 依赖可安装：

```bash
python3 -m pip install neo4j TuGraphClient
```

## 7. 关联文档

- MV4PG 源码仓库详细编译文档：`$MV4PG_HOME/BUILD.md`
- GDB_VIEW 环境与实验文档：`GDB_Views_VLDB2025_environment_and_experiments.md`
- Kuzu/IncGQ LDBC BI 与 IC 实验文档：`kuzu-ldbc-bi-ic.md`
