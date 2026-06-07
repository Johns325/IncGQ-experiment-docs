# GDB_Views_VLDB2025 从零搭建与实验运行手册

更新时间：2026-06-07
适用仓库：`GDB_Views_VLDB2025`
目标：在一台没有安装 Neo4j、没有现成数据库的新服务器上，使用仓库自带依赖导入数据并运行实验。

## 0. 关键结论

不要下载 Neo4j tarball。Neo4j 旧版下载链接可能返回 403，而且作者 GDB_VIEW 仓库的 `lib2/` 已经包含 Neo4j 5.3.0 的命令行和导入工具。本文主流程直接使用：

```bash
java -cp "lib2/*" org.neo4j.cli.AdminTool database import full ...
```

这样版本与项目 embedded Neo4j jar 一致，也避免下载 Neo4j 发行包失败。

## 1. 安装系统依赖

Ubuntu/Debian：

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk python3 rsync unzip
java -version
javac -version
```

说明：项目 README 说测试过 Java 19.0.2。本次实际验证 OpenJDK 17.0.19 可以编译和运行 Neo4j 5.3.0 AdminTool。

## 2. 准备文档仓库和 GDB_VIEW 作者仓库

这份文档和辅助脚本属于 `IncGQ-experiment-docs`，不要把辅助脚本写进作者的 `GDB_Views_VLDB2025` 仓库。新机器上建议目录如下：

```text
~/workspace/IncGQ-experiment-docs/
~/workspace/IncGQ/GDB_Views_VLDB2025/
```

先进入已经克隆好的文档仓库，并设置变量：

```bash
cd ~/workspace/IncGQ-experiment-docs
export DOCS_HOME=$PWD
```

确认文档仓库自带转换脚本：

```bash
ls "$DOCS_HOME/scripts/prepare_ldbc_for_neo4j_admin_import.py"
```

然后进入作者的 GDB_VIEW 仓库，并设置变量：

```bash
cd ~/workspace/IncGQ/GDB_Views_VLDB2025
export GDB_VIEW_HOME=$PWD
```

确认作者仓库关键 jar 存在：

```bash
ls "$GDB_VIEW_HOME/lib2/neo4j-command-line-5.3.0.jar" \
   "$GDB_VIEW_HOME/lib2/neo4j-import-tool-5.3.0.jar" \
   "$GDB_VIEW_HOME/lib2/neo4j-5.3.0.jar" \
   "$GDB_VIEW_HOME/lib2/apoc-5.3.0-core.jar"
```

验证作者仓库自带 Neo4j AdminTool：

```bash
mkdir -p /tmp/incgq-neo4j-admin-check/{conf,data,logs,plugins,import}

NEO4J_HOME=/tmp/incgq-neo4j-admin-check \
NEO4J_CONF=/tmp/incgq-neo4j-admin-check/conf \
java -cp "$GDB_VIEW_HOME/lib2/*" org.neo4j.cli.AdminTool database import full --help
```

成功时会输出 `USAGE neo4j-admin database import full ...`。

## 3. 准备 Neo4j home

项目使用 embedded Neo4j，不连接外部 Neo4j 服务。需要准备一个本地 DBMS home 目录：

```bash
export DB_HOME=~/neo4j-dbs/ldbc_sf01
mkdir -p "$DB_HOME"/{conf,data,logs,plugins,import}

cat > "$DB_HOME/conf/neo4j.conf" <<'CONF'
server.default_listen_address=127.0.0.1
server.bolt.enabled=false
server.http.enabled=false
dbms.security.auth_enabled=false
CONF
```

不要同时用外部 Neo4j server 和本项目打开同一个 `DB_HOME`。

## 4. 准备并转换 LDBC CSV 数据

仓库不包含 LDBC 原始 CSV。这里采用现有 Neo4j BI 导入文档中的同类做法：数据文件去掉原始表头，Neo4j import header 单独放在 `headers/` 目录，并在导入参数里写成 `header.csv,data.csv`。

先准备目录：

```bash
cd "$GDB_VIEW_HOME"
export DB_HOME=~/neo4j-dbs/ldbc_sf01

mkdir -p "$DB_HOME/import_raw" "$DB_HOME/import" "$DB_HOME/headers"
rsync -aP /path/to/ldbc/csv/ "$DB_HOME/import_raw/"
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

这里第一列是 Neo4j import 内部 ID，第二列保留为节点属性 `id:long`，因为实验查询会用 `person.id`、`forum.id` 等属性。

## 5. 导入 LDBC 到 Neo4j store

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

## 6. 配置项目使用该数据库

回到仓库根目录：

```bash
cd "$GDB_VIEW_HOME"
```

编辑 `test/config`：

```text
ldbc_sf01=/home/<user>/neo4j-dbs/ldbc_sf01
ldbc_sf1=/home/<user>/neo4j-dbs/ldbc_sf1
ldbc_sf10=/home/<user>/neo4j-dbs/ldbc_sf10
```

`src/main/Main.java` 默认写死：

```java
String dbName = "ldbc_sf01";
```

所以至少要保证 `ldbc_sf01` 指向刚导入的 `DB_HOME`。

## 7. 修复计时输出路径

作者 GitHub 仓库中的 `src/main/Main.java` 可能仍然写着作者机器路径：

```java
myWriter = new FileWriter("/home/db/yzheng57/GDB_Views_Path/test/time.txt");
```

新机器上必须把它改成相对路径。执行：

```bash
cd "$GDB_VIEW_HOME"
python3 - <<'PY'
from pathlib import Path
p = Path('src/main/Main.java')
s = p.read_text()
s = s.replace('/home/db/yzheng57/GDB_Views_Path/test/time.txt', './test/time.txt')
p.write_text(s)
PY
```

确认已经修复：

```bash
rg -n 'GDB_Views_Path/test/time.txt|./test/time.txt' src/main/Main.java
```

应该只看到 `./test/time.txt`。

## 8. 编译

推荐编译到独立目录，避免覆盖仓库里已有的 `.class`：

```bash
cd "$GDB_VIEW_HOME"
mkdir -p build/classes

javac -d build/classes \
  -sourcepath src \
  -cp ".:lib2/apoc-5.3.0-core.jar:./lib2/*" \
  src/main/Main.java src/main/Neo4jDriverConnector.java
```

本次验证：OpenJDK 17.0.19 下编译通过，有 8 个 warning，无 error。

## 9. 启动 smoke test

先只测试 embedded Neo4j 能不能打开 `DB_HOME`：

```bash
java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" main.Main
```

看到提示符后输入：

```text
quit
```

如果能正常退出，说明 classpath、`test/config`、Neo4j home 基本可用。

## 10. 运行实验

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

保存日志示例：

```bash
mkdir -p logs
java -cp "lib2/apoc-5.3.0-core.jar:lib2/*:build/classes" \
  main.Main ./test/LDBC/universal_queries/view_creation.txt \
  > logs/view_creation_$(date +%Y%m%d_%H%M%S).log 2>&1
```

## 11. 已验证内容

本次在当前机器上实际验证过：

```bash
java -cp "lib2/*" org.neo4j.cli.AdminTool database import full --help
```

可以输出帮助信息。

也验证过转换脚本能把 LDBC 风格表头转换成 header/data 分离格式。例如关系文件会生成：

```text
headers/organisation_isLocatedIn_place_0_0.csv:
:START_ID(Organisation)|:END_ID(Place)|creationDate:long

import/organisation_isLocatedIn_place_0_0.csv:
1|1|100
```

还验证过 Neo4j AdminTool 能用这种形式导入：

```bash
--nodes=Place="headers/place_0_0.csv,import/place_0_0.csv" \
--nodes=Organisation="headers/organisation_0_0.csv,import/organisation_0_0.csv" \
--relationships=IS_LOCATED_IN="headers/organisation_isLocatedIn_place_0_0.csv,import/organisation_isLocatedIn_place_0_0.csv"
```

最小导入输出 `IMPORT DONE`，导入 2 个节点、1 条关系。

编译也验证过：

```bash
javac -d /tmp/incgq-build-classes \
  -sourcepath src \
  -cp ".:lib2/apoc-5.3.0-core.jar:./lib2/*" \
  src/main/Main.java src/main/Neo4jDriverConnector.java
```

编译成功。

## 12. 常见错误

### 12.1 Neo4j 下载 403

不需要下载 Neo4j。使用仓库自带 AdminTool：

```bash
java -cp "lib2/*" org.neo4j.cli.AdminTool database import full --help
```

### 12.2 `Required environment variable NEO4J_HOME is not set`

运行 AdminTool 时必须显式设置：

```bash
NEO4J_HOME="$DB_HOME" NEO4J_CONF="$DB_HOME/conf" java -cp "$GDB_VIEW_HOME/lib2/*" org.neo4j.cli.AdminTool ...
```

### 12.3 `Invalid nodes file ... import/... doesn't exist`

导入命令要在 `DB_HOME` 下执行：

```bash
cd "$DB_HOME"
```

因为 `import/person_0_0.csv` 是相对当前工作目录解析的。

### 12.4 `HeaderException: Missing header of type START_ID`

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

### 12.5 `FileNotFoundException: /home/db/yzheng57/.../time.txt`

修复 `src/main/Main.java`，把计时输出路径改成 `./test/time.txt`。

### 12.6 store lock

不要同时用外部 Neo4j server 和本项目打开同一个 `DB_HOME`。
