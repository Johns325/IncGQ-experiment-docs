# GDB_Views_VLDB2025 从零搭建与实验运行手册

更新时间：2026-06-12
适用仓库：`GDB_Views_VLDB2025`
代码仓库：`https://github.com/DISLMcGill/GDB_Views_VLDB2025.git`

本文整理 G-View 的实验环境搭建、LDBC 数据导入、编译和运行方式。本文不假设固定用户名、工作目录或数据目录。

## 0. 路线选择

本文提供两条平级路线：

- **方案 A：Docker 搭建与测试（推荐）**。Java/JDK、Neo4j jar 运行环境都在容器里完成，不会改变宿主机 Java 版本，也不会往宿主机安装 JDK。数据和代码目录通过 volume 挂载给容器使用。
- **方案 B：本机搭建**。直接在宿主机安装 JDK 17+ 并运行 `java` / `javac`。适合已经有干净 Java 环境的机器。

推荐优先使用 Docker。已验证：本机已有镜像 `pgview-experiment:neo4j2025-local`，基于它构建 `gview-jdk17` 后，可以成功编译当前 G-View `master`。编译产物在 `build/classes`，主要类包括：

```text
main.Main
main.Neo4jGraphConnector
main.Neo4jDriverConnector
```

编译只有 Neo4j API deprecated / unchecked warnings，没有 error。

本机已通过 Docker 完整走通 SF1 数据导入和 smoke test：

```text
IC SF1 store: /mnt/data/imported_data/G-view/neo4j-dbs/ldbc_ic_sf1
BI SF1 store: /mnt/data/imported_data/G-view/neo4j-dbs/ldbc_bi_sf1
```

IC 和 BI 需要区分。IC 数据是 flat `static/` + `dynamic/` CSV，可使用 `prepare_ldbc_for_neo4j_admin_import.py`。BI 数据是 partitioned `initial_snapshot/static|dynamic/<table>/part-*.csv` 格式，需要使用 G-View 专用脚本 `scripts/import_gview_bi_partitioned.py`；不能套用 IC 的 flat CSV 转换脚本。

不要下载 Neo4j tarball。Neo4j 旧版下载链接可能返回 403，而且作者仓库的 `lib2/` 已包含 Neo4j 5.3.0 的命令行和导入工具。两条路线都直接使用：

```bash
java -cp "lib2/*" org.neo4j.cli.AdminTool database import full ...
```

这样版本与项目 embedded Neo4j jar 一致，也避免下载 Neo4j 发行包失败。

## 1. 共同准备

### 1.1 路径变量

按实际机器设置：

```bash
export WORK_ROOT=/root/workspace
export DATA_ROOT=/mnt/data/datasets
export DOCS_HOME="$WORK_ROOT/IncGQ/IncGQ-experiment-docs"
export GDB_VIEW_HOME="$WORK_ROOT/GDB_Views_VLDB2025"
export SCRATCH_DIR=/tmp/scratch
export GVIEW_DB_ROOT=/mnt/data/imported_data/G-view/neo4j-dbs
export LDBC_IC_ROOT=/mnt/data/datasets/ldbc_snb_ic
export LDBC_BI_ROOT=/mnt/data/datasets/ldbc_snb_bi
export DB_HOME="$GVIEW_DB_ROOT/ldbc_ic_sf1"
```

含义：

```text
WORK_ROOT      任意工作目录根路径
DATA_ROOT      LDBC 数据集根路径
DOCS_HOME      IncGQ-experiment-docs 仓库路径
GDB_VIEW_HOME  GDB_Views_VLDB2025 作者仓库路径
SCRATCH_DIR    临时验证和中间产物目录
GVIEW_DB_ROOT  G-View 使用的 Neo4j store 根路径
LDBC_IC_ROOT   LDBC SNB IC CSV 根路径
LDBC_BI_ROOT   LDBC SNB BI CSV 根路径
DB_HOME        当前实验使用的 Neo4j DBMS home
```

### 1.2 准备仓库

这份文档和辅助脚本属于 `IncGQ-experiment-docs`，不要把辅助脚本写进作者的 `GDB_Views_VLDB2025` 仓库。

确认文档仓库转换脚本：

```bash
ls "$DOCS_HOME/scripts/prepare_ldbc_for_neo4j_admin_import.py" \
   "$DOCS_HOME/scripts/import_gview_bi_partitioned.py"
```

如果还没有作者仓库：

```bash
cd "$WORK_ROOT"
git clone https://github.com/DISLMcGill/GDB_Views_VLDB2025.git
cd "$GDB_VIEW_HOME"
git rev-parse HEAD
```

当前查询到的 `master` commit 为：

```text
66f00e58affc2ecdbefe059083301dbc162f49a9
```

确认作者仓库关键 jar 存在：

```bash
ls "$GDB_VIEW_HOME/lib2/neo4j-command-line-5.3.0.jar" \
   "$GDB_VIEW_HOME/lib2/neo4j-import-tool-5.3.0.jar" \
   "$GDB_VIEW_HOME/lib2/neo4j-5.3.0.jar" \
   "$GDB_VIEW_HOME/lib2/apoc-5.3.0-core.jar"
```

### 1.3 仓库使用的数据集

作者仓库 README 明确说明测试覆盖两类图：

- `LDBC`：仓库提供 `test/LDBC/` 查询目录，包括 `universal_queries/`、从 LDBC benchmark 改写的 `BI_IC/` seeded queries，以及 `example_queries/`。`test/config` 中出现 `ldbc_sf01`、`ldbc_sf1`、`ldbc_sf10` 三个数据库配置项。
- `StackOverFlow`：仓库提供 `test/stackOverFlow/` 查询目录，查询中使用 `User`、`Post`、`Tag` 节点，以及 `POSTED`、`PARENT_OF`、`HAS_TAG` 等关系。

仓库没有包含原始数据文件。本机 LDBC IC CSV 位于 `/mnt/data/datasets/ldbc_snb_ic`，LDBC BI CSV 位于 `/mnt/data/datasets/ldbc_snb_bi`。当前已经导入 IC SF1 和 BI SF1；SF30 数据存在但体量更大，导入前需要确认磁盘和运行时间。StackOverflow 的原始数据来源、规模和转换流程没有在作者仓库中看到，需要另行确认，不能在实验记录中硬写。

### 1.4 准备 Neo4j DB_HOME

项目使用 embedded Neo4j，不连接外部 Neo4j 服务。每个 scale factor 建议使用独立 `DB_HOME`。

```bash
mkdir -p "$DB_HOME"/{conf,data,logs,plugins,import}

cat > "$DB_HOME/conf/neo4j.conf" <<'CONF'
server.default_listen_address=127.0.0.1
server.bolt.enabled=false
server.http.enabled=false
dbms.security.auth_enabled=false
CONF
```

不要同时用外部 Neo4j server 和本项目打开同一个 `DB_HOME`。

### 1.5 准备并转换 LDBC IC CSV 数据

仓库不包含 LDBC 原始 CSV。IC 数据是 `static/` 和 `dynamic/` 分开的 flat CSV。这里采用 header 和 data 分离的 Neo4j admin import 形式：数据文件去掉原始表头，Neo4j import header 单独放在 `headers/` 目录，并在导入参数里写成 `header.csv,data.csv`。

```bash
export DB_HOME="$GVIEW_DB_ROOT/ldbc_ic_sf1"
export LDBC_IC_DATA="$LDBC_IC_ROOT/social_network-sf1-CsvComposite-StringDateFormatter"

mkdir -p "$DB_HOME"/{conf,data,logs,plugins,import,import_raw,headers}

find "$LDBC_IC_DATA/static" "$LDBC_IC_DATA/dynamic" \
  -maxdepth 1 -type f -name '*.csv' ! -name 'updateStream*' \
  -exec ln -sf {} "$DB_HOME/import_raw/" \;
```

至少应能看到这些原始文件名，具体以你的数据集为准：

```bash
ls "$DB_HOME/import_raw/person_0_0.csv" \
   "$DB_HOME/import_raw/post_0_0.csv" \
   "$DB_HOME/import_raw/comment_0_0.csv" \
   "$DB_HOME/import_raw/person_knows_person_0_0.csv"
```

LDBC 原始 CSV 的关系表头通常类似 `Organisation.id|Place.id`，Neo4j 不认识。运行转换脚本：

```bash
python3 "$DOCS_HOME/scripts/prepare_ldbc_for_neo4j_admin_import.py" \
  "$DB_HOME/import_raw" \
  "$DB_HOME/import" \
  "$DB_HOME/headers"
```

如果希望数据转换也在 Docker 中执行，可使用 `gview-jdk17` 中的 `python3`，避免依赖宿主机 Python：

```bash
docker run --rm \
  -v "$DOCS_HOME:/workspace/IncGQ-experiment-docs" \
  -v /mnt/data:/mnt/data \
  gview-jdk17 \
  python3 /workspace/IncGQ-experiment-docs/scripts/prepare_ldbc_for_neo4j_admin_import.py \
    "$DB_HOME/import_raw" \
    "$DB_HOME/import" \
    "$DB_HOME/headers"
```

转换结果：

- `$DB_HOME/import/`：无表头 CSV 数据文件。
- `$DB_HOME/headers/`：Neo4j admin import 使用的 header 文件。

检查关系 header 和数据：

```bash
head -n 1 "$DB_HOME/headers/organisation_isLocatedIn_place_0_0.csv"
head -n 1 "$DB_HOME/import/organisation_isLocatedIn_place_0_0.csv"
```

应类似：

```text
:START_ID(Organisation)|:END_ID(Place)
1|10
```

检查节点 header 和数据：

```bash
head -n 1 "$DB_HOME/headers/person_0_0.csv"
head -n 1 "$DB_HOME/import/person_0_0.csv"
```

应类似：

```text
:ID(Person)|id:long|...
1|1|...
```

这里第一列是 Neo4j import 内部 ID，第二列保留为节点属性 `id:long`，因为实验查询会用 `person.id`、`forum.id` 等属性。转换脚本还会把 `creationDate`、`deletionDate`、`birthday`、`joinDate` 这类 LDBC ISO/date 字符串转换为 epoch milliseconds，因为 GDB_VIEW 查询里按毫秒整数比较这些字段。

### 1.6 配置 G-View 使用数据库

编辑作者仓库中的 `test/config`。当前已验证的 SF1 配置建议写成：

```text
ldbc_sf01=/mnt/data/imported_data/G-view/neo4j-dbs/ldbc_ic_sf1
ldbc_sf1=/mnt/data/imported_data/G-view/neo4j-dbs/ldbc_bi_sf1
ldbc_sf10=/mnt/data/imported_data/G-view/neo4j-dbs/ldbc_ic_sf1
```

当前 `master` 已确认 `src/main/Main.java` 默认写死：

```java
String dbName = "ldbc_sf01";
```

因此默认 smoke test 会打开 `ldbc_sf01`，也就是上面的 IC SF1 store。如果要默认测试 BI store，有两种做法：临时把 `ldbc_sf01` 指向 `/mnt/data/imported_data/G-view/neo4j-dbs/ldbc_bi_sf1`，或修改 `Main.java` 中的 `dbName`。不要在 `test/config` 中写 `~`，除非程序明确支持 shell 展开。

### 1.7 修复计时输出路径

当前 `master` 已确认 `src/main/Main.java` 把计时结果写到作者机器的绝对路径：

```java
new FileWriter("/home/db/yzheng57/GDB_Views_Path/test/time.txt")
```

本地运行前先检查：

```bash
cd "$GDB_VIEW_HOME"
rg -n 'FileWriter\("/' src/main/Main.java
```

如果命中，应把它改成相对路径或可配置路径。当前验证时使用的改法是把这一行替换为：

```java
new FileWriter("./test/time.txt")
```

确认已经修复：

```bash
rg -n 'GDB_Views_Path/test/time.txt|./test/time.txt' src/main/Main.java
```

应该只看到 `./test/time.txt`。

## 2. 方案 A：Docker 搭建与测试（推荐）

Docker 方案只要求宿主机有 Docker 和可访问的数据目录。JDK、编译器和 Java 运行环境都在容器中，不会影响宿主机 Java 版本。

### 2.1 构建 Docker 编译镜像

本机已验证可以基于已有镜像 `pgview-experiment:neo4j2025-local` 构建 `gview-jdk17`：

```bash
docker build -t gview-jdk17 - <<'DOCKER'
FROM pgview-experiment:neo4j2025-local
RUN apt-get update \
 && apt-get install -y --no-install-recommends openjdk-17-jdk-headless \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace/GDB_Views_VLDB2025
DOCKER
```

验证镜像：

```bash
docker run --rm gview-jdk17 javac -version
```

期望至少为：

```text
javac 17.x
```

如果换机器没有 `pgview-experiment:neo4j2025-local`，可使用任意包含 JDK 17+ 的镜像替代，关键是保证容器内 `javac -version` 至少为 17。

### 2.2 验证 Neo4j AdminTool

为保证容器内路径和宿主机路径一致，挂载作者仓库到固定容器路径：

```bash
docker run --rm \
  -v "$GDB_VIEW_HOME:/workspace/GDB_Views_VLDB2025" \
  -v "$SCRATCH_DIR:$SCRATCH_DIR" \
  -w /workspace/GDB_Views_VLDB2025 \
  -e SCRATCH_DIR="$SCRATCH_DIR" \
  gview-jdk17 \
  bash -lc '
    mkdir -p "$SCRATCH_DIR/neo4j-admin-check"/{conf,data,logs,plugins,import}
    NEO4J_HOME="$SCRATCH_DIR/neo4j-admin-check" \
    NEO4J_CONF="$SCRATCH_DIR/neo4j-admin-check/conf" \
    java -cp "lib2/*" org.neo4j.cli.AdminTool database import full --help
  '
```

成功时会输出 `USAGE neo4j-admin database import full ...`。

### 2.3 Docker 导入 LDBC IC SF1 到 Neo4j store

导入命令必须在 `DB_HOME` 下执行，因为 `import/*.csv` 和 `headers/*.csv` 都是相对路径。为了让容器内也能看到同一个绝对 `DB_HOME`，把 `/mnt/data` 挂载到容器内相同路径：

```bash
docker run --rm \
  -v "$GDB_VIEW_HOME:/workspace/GDB_Views_VLDB2025" \
  -v /mnt/data:/mnt/data \
  -w "$DB_HOME" \
  -e DB_HOME="$DB_HOME" \
  gview-jdk17 \
  bash -lc '
    NEO4J_HOME="$DB_HOME" \
    NEO4J_CONF="$DB_HOME/conf" \
    java -cp "/workspace/GDB_Views_VLDB2025/lib2/*" org.neo4j.cli.AdminTool database import full \
      --overwrite-destination=true \
      --skip-bad-relationships=true \
      --skip-duplicate-nodes=true \
      --bad-tolerance=1000000000 \
      --id-type=INTEGER \
      --nodes=Place="headers/place_0_0.csv,import/place_0_0.csv" \
      --nodes=Organisation="headers/organisation_0_0.csv,import/organisation_0_0.csv" \
      --nodes=TagClass="headers/tagclass_0_0.csv,import/tagclass_0_0.csv" \
      --nodes=Tag="headers/tag_0_0.csv,import/tag_0_0.csv" \
      --nodes=Comment:Message="headers/comment_0_0.csv,import/comment_0_0.csv" \
      --nodes=Forum="headers/forum_0_0.csv,import/forum_0_0.csv" \
      --nodes=Person="headers/person_0_0.csv,import/person_0_0.csv" \
      --nodes=Post:Message="headers/post_0_0.csv,import/post_0_0.csv" \
      --relationships=IS_PART_OF="headers/place_isPartOf_place_0_0.csv,import/place_isPartOf_place_0_0.csv" \
      --relationships=IS_SUBCLASS_OF="headers/tagclass_isSubclassOf_tagclass_0_0.csv,import/tagclass_isSubclassOf_tagclass_0_0.csv" \
      --relationships=IS_LOCATED_IN="headers/organisation_isLocatedIn_place_0_0.csv,import/organisation_isLocatedIn_place_0_0.csv" \
      --relationships=HAS_TYPE="headers/tag_hasType_tagclass_0_0.csv,import/tag_hasType_tagclass_0_0.csv" \
      --relationships=HAS_CREATOR="headers/comment_hasCreator_person_0_0.csv,import/comment_hasCreator_person_0_0.csv" \
      --relationships=IS_LOCATED_IN="headers/comment_isLocatedIn_place_0_0.csv,import/comment_isLocatedIn_place_0_0.csv" \
      --relationships=REPLY_OF="headers/comment_replyOf_comment_0_0.csv,import/comment_replyOf_comment_0_0.csv" \
      --relationships=REPLY_OF="headers/comment_replyOf_post_0_0.csv,import/comment_replyOf_post_0_0.csv" \
      --relationships=CONTAINER_OF="headers/forum_containerOf_post_0_0.csv,import/forum_containerOf_post_0_0.csv" \
      --relationships=HAS_MEMBER="headers/forum_hasMember_person_0_0.csv,import/forum_hasMember_person_0_0.csv" \
      --relationships=HAS_MODERATOR="headers/forum_hasModerator_person_0_0.csv,import/forum_hasModerator_person_0_0.csv" \
      --relationships=HAS_TAG="headers/forum_hasTag_tag_0_0.csv,import/forum_hasTag_tag_0_0.csv" \
      --relationships=HAS_INTEREST="headers/person_hasInterest_tag_0_0.csv,import/person_hasInterest_tag_0_0.csv" \
      --relationships=IS_LOCATED_IN="headers/person_isLocatedIn_place_0_0.csv,import/person_isLocatedIn_place_0_0.csv" \
      --relationships=KNOWS="headers/person_knows_person_0_0.csv,import/person_knows_person_0_0.csv" \
      --relationships=LIKES="headers/person_likes_comment_0_0.csv,import/person_likes_comment_0_0.csv" \
      --relationships=LIKES="headers/person_likes_post_0_0.csv,import/person_likes_post_0_0.csv" \
      --relationships=HAS_CREATOR="headers/post_hasCreator_person_0_0.csv,import/post_hasCreator_person_0_0.csv" \
      --relationships=HAS_TAG="headers/comment_hasTag_tag_0_0.csv,import/comment_hasTag_tag_0_0.csv" \
      --relationships=HAS_TAG="headers/post_hasTag_tag_0_0.csv,import/post_hasTag_tag_0_0.csv" \
      --relationships=IS_LOCATED_IN="headers/post_isLocatedIn_place_0_0.csv,import/post_isLocatedIn_place_0_0.csv" \
      --relationships=STUDY_AT="headers/person_studyAt_organisation_0_0.csv,import/person_studyAt_organisation_0_0.csv" \
      --relationships=WORK_AT="headers/person_workAt_organisation_0_0.csv,import/person_workAt_organisation_0_0.csv" \
      --delimiter="|" \
      neo4j
  '
```

成功后应看到 `IMPORT DONE`，并且存在：

```bash
ls "$DB_HOME/data/databases/neo4j"
ls "$DB_HOME/data/transactions/neo4j"
```

本机已实跑完成，IC SF1 导入结果为：

```text
DB_HOME=/mnt/data/imported_data/G-view/neo4j-dbs/ldbc_ic_sf1
Imported 3181724 nodes, 17256038 relationships, 23010315 properties
Store size: 2.1G
```

### 2.3.1 Docker 导入 LDBC BI SF1 到 Neo4j store

BI CSV 不是 IC 的 flat CSV 格式，而是 partitioned `initial_snapshot/static|dynamic/<table>/part-*.csv`。G-View 查询需要节点 `id` 属性和 epoch milliseconds 时间字段，所以这里使用文档仓库新增的 G-View 专用脚本：

```bash
export DB_HOME="$GVIEW_DB_ROOT/ldbc_bi_sf1"
export LDBC_BI_DATA="$LDBC_BI_ROOT/bi-sf1-composite-projected-fk/graphs/csv/bi/composite-projected-fk/initial_snapshot"

mkdir -p "$DB_HOME"

docker run --rm \
  -v "$DOCS_HOME:/docs" \
  -v "$GDB_VIEW_HOME:/workspace/GDB_Views_VLDB2025" \
  -v /mnt/data:/mnt/data \
  gview-jdk17 \
  python3 /docs/scripts/import_gview_bi_partitioned.py \
    --data-dir "$LDBC_BI_DATA" \
    --target-dir "$DB_HOME" \
    --gdb-view-home /workspace/GDB_Views_VLDB2025
```

这个脚本会生成：

```text
$DB_HOME/prepared-csv/initial_snapshot/...
$DB_HOME/prepared-headers/...
$DB_HOME/data/databases/neo4j
$DB_HOME/data/transactions/neo4j
```

本机已实跑完成，BI SF1 导入结果为：

```text
DB_HOME=/mnt/data/imported_data/G-view/neo4j-dbs/ldbc_bi_sf1
Imported 2997352 nodes, 17196776 relationships, 35076475 properties
Store size: 2.7G
```

如果只想重新生成 BI 转换 CSV，不执行 Neo4j import，可加 `--skip-import`；如果转换产物已存在、只想重跑 import，可加 `--skip-prepare`。

### 2.4 Docker 编译

```bash
docker run --rm \
  -v "$GDB_VIEW_HOME:/workspace/GDB_Views_VLDB2025" \
  -w /workspace/GDB_Views_VLDB2025 \
  gview-jdk17 \
  bash -lc '
    mkdir -p build/classes &&
    javac -version &&
    javac -d build/classes \
      -sourcepath src \
      -cp ".:lib2/apoc-5.3.0-core.jar:./lib2/*" \
      src/main/Main.java src/main/Neo4jDriverConnector.java
  '
```

成功时应看到 `javac 17.x`，最后只有 warning、没有 error。已验证生成：

```bash
ls "$GDB_VIEW_HOME/build/classes/main/Main.class" \
   "$GDB_VIEW_HOME/build/classes/main/Neo4jGraphConnector.class" \
   "$GDB_VIEW_HOME/build/classes/main/Neo4jDriverConnector.class"
```

### 2.5 Docker smoke test

```bash
docker run --rm -it \
  -v "$GDB_VIEW_HOME:/workspace/GDB_Views_VLDB2025" \
  -v /mnt/data:/mnt/data \
  -w /workspace/GDB_Views_VLDB2025 \
  gview-jdk17 \
  java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" main.Main
```

看到提示符后输入：

```text
quit
```

本机已用 `/mnt/data/imported_data/G-view/neo4j-dbs/ldbc_ic_sf1` 实跑 smoke test，输出包含：

```text
neo4j graph connector set-up done.
0
>>
```

输入 `quit` 后进程退出码为 0，说明 classpath、`test/config`、Neo4j home 基本可用。

### 2.6 Docker 运行实验

已验证 G-View 查询可以在 Docker 中运行。短查询 smoke test 使用两条命令：先创建 view，再用 `WITH VIEWS ... LOCAL` 使用 view。

IC SF1 验证查询：

```text
CREATE VIEW AS VSMOKE_IC MATCH (f:Forum)-[:CONTAINER_OF]->(po:Post) WHERE po.length > 115 AND po.browserUsed = "Opera" RETURN COLLECTSET(po)
WITH VIEWS VSMOKE_IC LOCAL MATCH (n:Post) RETURN n
```

在 `/mnt/data/imported_data/G-view/neo4j-dbs/ldbc_ic_sf1` 上已验证：创建 view 返回 `2515` nodes，使用 view 返回 `2515` elements。

BI SF1 验证查询：

```text
CREATE VIEW AS VSMOKE_BI MATCH (f:Forum)-[:CONTAINER_OF]->(po:Post) WHERE po.length > 115 AND po.browserUsed = "Opera" RETURN COLLECTSET(po)
WITH VIEWS VSMOKE_BI LOCAL MATCH (n:Post) RETURN n
```

把 `test/config` 中 `ldbc_sf01` 临时指到 `/mnt/data/imported_data/G-view/neo4j-dbs/ldbc_bi_sf1` 后已验证：创建 view 返回 `2217` nodes，使用 view 返回 `2217` elements。验证后应把 `ldbc_sf01` 改回 IC store，除非后续实验明确要默认跑 BI。

完整 workload 可能运行时间较长。`test/LDBC/example_queries/V_nodeSet.txt` 前半段已验证能创建和使用 view，但后半段包含较重查询，120 秒 smoke timeout 内没有跑完；正式实验应单独预留时间运行。

最小 baseline：

```bash
docker run --rm \
  -v "$GDB_VIEW_HOME:/workspace/GDB_Views_VLDB2025" \
  -v /mnt/data:/mnt/data \
  -w /workspace/GDB_Views_VLDB2025 \
  gview-jdk17 \
  java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" \
    main.Main ./test/temporary_baseline.txt
```

LDBC universal query 示例：

```bash
docker run --rm \
  -v "$GDB_VIEW_HOME:/workspace/GDB_Views_VLDB2025" \
  -v /mnt/data:/mnt/data \
  -w /workspace/GDB_Views_VLDB2025 \
  gview-jdk17 \
  java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" \
    main.Main ./test/LDBC/universal_queries/view_creation.txt
```

保存日志示例：

```bash
mkdir -p "$GDB_VIEW_HOME/logs"

docker run --rm \
  -v "$GDB_VIEW_HOME:/workspace/GDB_Views_VLDB2025" \
  -v /mnt/data:/mnt/data \
  -w /workspace/GDB_Views_VLDB2025 \
  gview-jdk17 \
  java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" \
    main.Main ./test/LDBC/universal_queries/view_creation.txt \
  > "$GDB_VIEW_HOME/logs/view_creation_$(date +%Y%m%d_%H%M%S).log" 2>&1
```

## 3. 方案 B：本机搭建

本机方案会在宿主机安装 JDK 17+。如果机器上已有其它 Java 工作负载，建议优先使用 Docker 方案。

### 3.1 安装系统依赖

Ubuntu/Debian：

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk python3 rsync unzip
java -version
javac -version
```

说明：项目 README 说测试过 Java 19.0.2。OpenJDK 17 也可用于编译和运行 Neo4j 5.3.0 AdminTool。宿主机 Java 11 编译会失败，典型错误是 Neo4j annotation processor 的 `class file version 61.0` 不兼容。

### 3.2 本机验证 Neo4j AdminTool

```bash
cd "$GDB_VIEW_HOME"
mkdir -p "$SCRATCH_DIR/neo4j-admin-check"/{conf,data,logs,plugins,import}

NEO4J_HOME="$SCRATCH_DIR/neo4j-admin-check" \
NEO4J_CONF="$SCRATCH_DIR/neo4j-admin-check/conf" \
java -cp "$GDB_VIEW_HOME/lib2/*" org.neo4j.cli.AdminTool database import full --help
```

成功时会输出 `USAGE neo4j-admin database import full ...`。

### 3.3 本机导入 LDBC 到 Neo4j store

导入必须在 `DB_HOME` 下执行，因为 `import/*.csv` 和 `headers/*.csv` 都是相对路径：

```bash
cd "$DB_HOME"

NEO4J_HOME="$DB_HOME" \
NEO4J_CONF="$DB_HOME/conf" \
java -cp "$GDB_VIEW_HOME/lib2/*" org.neo4j.cli.AdminTool database import full \
  --overwrite-destination=true \
  --skip-bad-relationships=true \
  --skip-duplicate-nodes=true \
  --bad-tolerance=1000000000 \
  --id-type=INTEGER \
  --nodes=Place="headers/place_0_0.csv,import/place_0_0.csv" \
  --nodes=Organisation="headers/organisation_0_0.csv,import/organisation_0_0.csv" \
  --nodes=TagClass="headers/tagclass_0_0.csv,import/tagclass_0_0.csv" \
  --nodes=Tag="headers/tag_0_0.csv,import/tag_0_0.csv" \
  --nodes=Comment:Message="headers/comment_0_0.csv,import/comment_0_0.csv" \
  --nodes=Forum="headers/forum_0_0.csv,import/forum_0_0.csv" \
  --nodes=Person="headers/person_0_0.csv,import/person_0_0.csv" \
  --nodes=Post:Message="headers/post_0_0.csv,import/post_0_0.csv" \
  --relationships=IS_PART_OF="headers/place_isPartOf_place_0_0.csv,import/place_isPartOf_place_0_0.csv" \
  --relationships=IS_SUBCLASS_OF="headers/tagclass_isSubclassOf_tagclass_0_0.csv,import/tagclass_isSubclassOf_tagclass_0_0.csv" \
  --relationships=IS_LOCATED_IN="headers/organisation_isLocatedIn_place_0_0.csv,import/organisation_isLocatedIn_place_0_0.csv" \
  --relationships=HAS_TYPE="headers/tag_hasType_tagclass_0_0.csv,import/tag_hasType_tagclass_0_0.csv" \
  --relationships=HAS_CREATOR="headers/comment_hasCreator_person_0_0.csv,import/comment_hasCreator_person_0_0.csv" \
  --relationships=IS_LOCATED_IN="headers/comment_isLocatedIn_place_0_0.csv,import/comment_isLocatedIn_place_0_0.csv" \
  --relationships=REPLY_OF="headers/comment_replyOf_comment_0_0.csv,import/comment_replyOf_comment_0_0.csv" \
  --relationships=REPLY_OF="headers/comment_replyOf_post_0_0.csv,import/comment_replyOf_post_0_0.csv" \
  --relationships=CONTAINER_OF="headers/forum_containerOf_post_0_0.csv,import/forum_containerOf_post_0_0.csv" \
  --relationships=HAS_MEMBER="headers/forum_hasMember_person_0_0.csv,import/forum_hasMember_person_0_0.csv" \
  --relationships=HAS_MODERATOR="headers/forum_hasModerator_person_0_0.csv,import/forum_hasModerator_person_0_0.csv" \
  --relationships=HAS_TAG="headers/forum_hasTag_tag_0_0.csv,import/forum_hasTag_tag_0_0.csv" \
  --relationships=HAS_INTEREST="headers/person_hasInterest_tag_0_0.csv,import/person_hasInterest_tag_0_0.csv" \
  --relationships=IS_LOCATED_IN="headers/person_isLocatedIn_place_0_0.csv,import/person_isLocatedIn_place_0_0.csv" \
  --relationships=KNOWS="headers/person_knows_person_0_0.csv,import/person_knows_person_0_0.csv" \
  --relationships=LIKES="headers/person_likes_comment_0_0.csv,import/person_likes_comment_0_0.csv" \
  --relationships=LIKES="headers/person_likes_post_0_0.csv,import/person_likes_post_0_0.csv" \
  --relationships=HAS_CREATOR="headers/post_hasCreator_person_0_0.csv,import/post_hasCreator_person_0_0.csv" \
  --relationships=HAS_TAG="headers/comment_hasTag_tag_0_0.csv,import/comment_hasTag_tag_0_0.csv" \
  --relationships=HAS_TAG="headers/post_hasTag_tag_0_0.csv,import/post_hasTag_tag_0_0.csv" \
  --relationships=IS_LOCATED_IN="headers/post_isLocatedIn_place_0_0.csv,import/post_isLocatedIn_place_0_0.csv" \
  --relationships=STUDY_AT="headers/person_studyAt_organisation_0_0.csv,import/person_studyAt_organisation_0_0.csv" \
  --relationships=WORK_AT="headers/person_workAt_organisation_0_0.csv,import/person_workAt_organisation_0_0.csv" \
  --delimiter='|' \
  neo4j
```

成功后应看到 `IMPORT DONE`，并且存在：

```bash
ls "$DB_HOME/data/databases/neo4j"
ls "$DB_HOME/data/transactions/neo4j"
```

### 3.4 本机编译

推荐编译到独立目录，避免覆盖仓库里已有的 `.class`：

```bash
cd "$GDB_VIEW_HOME"
mkdir -p build/classes

javac -d build/classes \
  -sourcepath src \
  -cp ".:lib2/apoc-5.3.0-core.jar:./lib2/*" \
  src/main/Main.java src/main/Neo4jDriverConnector.java
```

OpenJDK 17 下应能编译通过；如出现 warning，先确认没有 error。

### 3.5 本机 smoke test

```bash
cd "$GDB_VIEW_HOME"
java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" main.Main
```

看到提示符后输入：

```text
quit
```

### 3.6 本机运行实验

最小 baseline：

```bash
java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" \
  main.Main ./test/temporary_baseline.txt
```

LDBC 查询：

```bash
java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" main.Main ./test/LDBC/universal_queries/view_creation.txt
java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" main.Main ./test/LDBC/universal_queries/local_basic_test.txt
java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" main.Main ./test/LDBC/universal_queries/local_complex_test.txt
java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" main.Main ./test/LDBC/universal_queries/global_test.txt
java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" main.Main ./test/LDBC/universal_queries/partial_access_experiment.txt
```

## 4. 验证清单

| 检查项 | 命令或证据 | 通过标准 |
| --- | --- | --- |
| 作者仓库 jar | `ls "$GDB_VIEW_HOME/lib2/neo4j-command-line-5.3.0.jar"` | 文件存在 |
| Docker 编译镜像 | `docker run --rm gview-jdk17 javac -version` | 已验证 `javac 17.0.19` |
| AdminTool | `org.neo4j.cli.AdminTool database import full --help` | 输出 help |
| LDBC IC CSV 转换 | `head -n 1 "$GVIEW_DB_ROOT/ldbc_ic_sf1/headers/person_0_0.csv"` | 含 `:ID(Person)` 和 `id:long` |
| LDBC IC 关系 header | `head -n 1 "$GVIEW_DB_ROOT/ldbc_ic_sf1/headers/person_knows_person_0_0.csv"` | 含 `:START_ID(Person)` 和 `:END_ID(Person)` |
| IC SF1 Neo4j store | `/mnt/data/imported_data/G-view/neo4j-dbs/ldbc_ic_sf1` | 已验证 `3181724` nodes、`17256038` relationships，store 可读 |
| BI SF1 Neo4j store | `/mnt/data/imported_data/G-view/neo4j-dbs/ldbc_bi_sf1` | 已验证 `2997352` nodes、`17196776` relationships，store 可读 |
| `test/config` | 查看 `ldbc_sf01=...` | `ldbc_sf01` 指向 IC SF1，`ldbc_sf1` 指向 BI SF1 |
| 计时路径 | `rg -n 'FileWriter\("/' src/main/Main.java` | 无作者机器绝对路径 |
| Docker 编译产物 | `test -f build/classes/main/Main.class` | 已验证生成 `Main.class`、`Neo4jGraphConnector.class`、`Neo4jDriverConnector.class` |
| Docker smoke test | `printf 'quit\n' | docker run ... main.Main` | 已验证输出 `neo4j graph connector set-up done.` 并退出 0 |
| IC 查询 smoke test | `CREATE VIEW AS VSMOKE_IC ...` + `WITH VIEWS VSMOKE_IC ...` | 已验证创建 view 返回 `2515` nodes，使用 view 返回 `2515` elements |
| BI 查询 smoke test | `CREATE VIEW AS VSMOKE_BI ...` + `WITH VIEWS VSMOKE_BI ...` | 已验证创建 view 返回 `2217` nodes，使用 view 返回 `2217` elements |

## 5. 常见错误

### 5.1 Neo4j 下载 403

不需要下载 Neo4j。使用仓库自带 AdminTool：

```bash
java -cp "lib2/*" org.neo4j.cli.AdminTool database import full --help
```

Docker 里对应：

```bash
docker run --rm \
  -v "$GDB_VIEW_HOME:/workspace/GDB_Views_VLDB2025" \
  -w /workspace/GDB_Views_VLDB2025 \
  gview-jdk17 \
  java -cp "lib2/*" org.neo4j.cli.AdminTool database import full --help
```

### 5.2 `Required environment variable NEO4J_HOME is not set`

运行 AdminTool 时必须显式设置：

```bash
NEO4J_HOME="$DB_HOME" \
NEO4J_CONF="$DB_HOME/conf" \
java -cp "$GDB_VIEW_HOME/lib2/*" org.neo4j.cli.AdminTool ...
```

### 5.3 `Invalid nodes file ... import/... doesn't exist`

导入命令要在 `DB_HOME` 下执行，因为 `import/person_0_0.csv` 是相对执行导入命令时的工作目录解析的。

本机：

```bash
cd "$DB_HOME"
```

Docker：

```bash
docker run ... -w "$DB_HOME" ...
```

并且要保证 `/mnt/data` 挂载到容器内相同路径：

```bash
-v /mnt/data:/mnt/data
```

### 5.4 `HeaderException: Missing header of type START_ID`

说明你把 LDBC 原始 CSV 直接传给了导入命令。先运行转换脚本：

```bash
python3 "$DOCS_HOME/scripts/prepare_ldbc_for_neo4j_admin_import.py" \
  "$DB_HOME/import_raw" \
  "$DB_HOME/import" \
  "$DB_HOME/headers"
```

然后确认关系文件第一行包含 `:START_ID(...)` 和 `:END_ID(...)`：

```bash
head -n 1 "$DB_HOME/headers/organisation_isLocatedIn_place_0_0.csv"
```

### 5.5 `Not an integer: "2011-...+0000"`

说明你使用的是旧转换结果，时间字段还没有从 ISO 字符串转换成 epoch milliseconds。重新运行最新版转换脚本：

```bash
rm -rf "$DB_HOME/import" "$DB_HOME/headers"
mkdir -p "$DB_HOME/import" "$DB_HOME/headers"
python3 "$DOCS_HOME/scripts/prepare_ldbc_for_neo4j_admin_import.py" \
  "$DB_HOME/import_raw" \
  "$DB_HOME/import" \
  "$DB_HOME/headers"
```

如果前一次导入已经失败，Neo4j 会留下不一致 store。重新导入前删除目标库目录：

```bash
rm -rf "$DB_HOME/data/databases/neo4j" "$DB_HOME/data/transactions/neo4j"
```

然后再执行导入命令。

### 5.6 BI 数据套用了 IC 转换脚本

IC 和 BI 的 CSV 目录结构不同。IC 是 flat `static/` + `dynamic/` 文件；BI 是 partitioned `initial_snapshot/static|dynamic/<table>/part-*.csv`。BI SF1 应使用：

```bash
python3 "$DOCS_HOME/scripts/import_gview_bi_partitioned.py" \
  --data-dir "$LDBC_BI_ROOT/bi-sf1-composite-projected-fk/graphs/csv/bi/composite-projected-fk/initial_snapshot" \
  --target-dir "$GVIEW_DB_ROOT/ldbc_bi_sf1" \
  --gdb-view-home "$GDB_VIEW_HOME"
```

不要直接套用 IC 的 `prepare_ldbc_for_neo4j_admin_import.py`。另外，G-View 查询按毫秒整数比较时间字段，所以 BI 导入时也要转换为 epoch milliseconds，不能保留 Neo4j `DATE` / `DATETIME` 类型。

### 5.7 `FileNotFoundException` 指向某个绝对路径

修复 `src/main/Main.java`，把计时输出路径改成 `./test/time.txt`。

### 5.8 交互模式空行导致 `QueryParser.enterRoot` NPE

作者仓库当前交互模式不会处理空输入。如果在 `>>` 后直接回车，可能报：

```text
java.lang.NullPointerException: Cannot invoke "org.antlr.v4.runtime.tree.ParseTree.getText()"
```

这不是 Docker 或 Neo4j store 导入失败。验证环境时不要直接输入空行，可以直接输入 `quit`，或使用非交互命令：

```bash
printf 'quit\n' | java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" main.Main
```

当前临时验证仓库 `/tmp/GDB_Views_VLDB2025` 已加入空行防御并重新编译；如果重新 clone 作者仓库，需要再次加这个防御或避免空输入。

### 5.9 store lock

不要同时用外部 Neo4j server、Docker 容器和本机 Java 进程打开同一个 `DB_HOME`。

### 5.10 Docker Hub 拉取失败

本机曾尝试拉取 `eclipse-temurin:17-jdk`，遇到 Docker Hub 连接重置。因此当前推荐流程使用本机已有镜像 `pgview-experiment:neo4j2025-local`，再构建 `gview-jdk17`。如果换机器没有该镜像，可使用任意包含 JDK 17+ 的镜像替代。
