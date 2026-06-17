# PGVIEW 编译与数据导入说明

本文基于仓库 `/root/workspace/pg-view` 整理，目标是让用户知道如何编译 PGVIEW，以及如何把实验数据转换并导入到 LogicBlox、PostgreSQL、Neo4j 的实验 snapshot 中。

## 结论先说

我已在当前机器实际执行过编译。第一次 `mvn compile` 失败，原因是项目依赖的 `com.microsoft:z3:4.8.7` 不在 Maven Central，需要先把 Z3 发布包里的 `com.microsoft.z3.jar` 安装到本地 Maven 仓库。补齐 Z3 后再次执行 `mvn compile`，编译成功。

当前机器没有完成数据导入验证，原因如下：

- `psql` 和 `pg_dump` 存在，但本机 PostgreSQL 5432 没有响应。
- `lb` 不在 `PATH`，`/root/tools/logicblox/bin` 也不存在。
- `/root/tools/neo4j-community-4.1.11/bin` 不存在。
- `experiment/dataset` 目录不存在，当前没有已下载的数据源。
- Python 环境缺 `nltk`。

所以下面的“数据导入”部分是根据仓库脚本和配置整理出的可靠流程，但不是我在这台机器上跑通的导入结果。

## 1. 编译前置条件

仓库是 Maven Java 项目，`pom.xml` 中配置了：

- Java source/target: 11
- Maven artifact: `edu.upenn.cis.db:graph-trans:0.0.1-SNAPSHOT`
- ANTLR4 grammar 生成
- 主入口包括 `mvn exec:java@console`、`mvn exec:java@exp` 等
- 本地依赖 `com.microsoft:z3:4.8.7`

当前机器实际情况：

```bash
java -version
```

结果是 OpenJDK 11.0.31。

当前 `PATH` 中没有 `mvn`，但可用 Maven 位于：

```bash
/root/Downloads/apache-maven-3.9.12/bin/mvn
```

如果用户机器上已经安装了 Maven，可以直接使用 `mvn`。

## 2. 安装 Z3 本地 Maven 依赖

项目 `pom.xml` 依赖：

```xml
<dependency>
  <groupId>com.microsoft</groupId>
  <artifactId>z3</artifactId>
  <version>4.8.7</version>
</dependency>
```

这个 artifact 不在 Maven Central，需要手工安装。可按 README 中的 Z3 版本执行：

```bash
cd /tmp
wget -O z3-4.8.7-x64-ubuntu-16.04.zip \
  https://github.com/Z3Prover/z3/releases/download/z3-4.8.7/z3-4.8.7-x64-ubuntu-16.04.zip
unzip -q z3-4.8.7-x64-ubuntu-16.04.zip -d /tmp
```

如果 Maven 在 `PATH` 中：

```bash
mvn install:install-file \
  -Dfile=/tmp/z3-4.8.7-x64-ubuntu-16.04/bin/com.microsoft.z3.jar \
  -DgroupId=com.microsoft \
  -DartifactId=z3 \
  -Dversion=4.8.7 \
  -Dpackaging=jar \
  -DgeneratePom=true
```

当前机器上我实际使用的是：

```bash
/root/Downloads/apache-maven-3.9.12/bin/mvn install:install-file \
  -Dfile=/tmp/z3-4.8.7-x64-ubuntu-16.04/bin/com.microsoft.z3.jar \
  -DgroupId=com.microsoft \
  -DartifactId=z3 \
  -Dversion=4.8.7 \
  -Dpackaging=jar \
  -DgeneratePom=true
```

该步骤已成功，安装位置是：

```text
/root/.m2/repository/com/microsoft/z3/4.8.7/z3-4.8.7.jar
```

## 3. 编译 PGVIEW

进入仓库根目录：

```bash
cd /root/workspace/pg-view
```

如果 `mvn` 在 `PATH` 中：

```bash
mvn compile
```

当前机器上我实际执行的是：

```bash
/root/Downloads/apache-maven-3.9.12/bin/mvn compile
```

实际结果：

- `antlr4:4.8:antlr4` 处理了 `src/main/antlr4` 下的两个 grammar。
- Maven 编译了 110 个 Java 源文件到 `target/classes`。
- 最终结果为 `BUILD SUCCESS`。
- 成功时间：2026-06-11T01:40:30Z。
- Maven 报了一个非致命 warning：`pom.xml` 里 `maven-surefire-plugin` 重复声明。
- Java 编译报了非致命提示：有 deprecated API 和 unchecked/unsafe operations。

如果想启动交互式 PGVIEW console，README 给出的命令是：

```bash
mvn exec:java@console
```

当前我只验证了 `mvn compile`，没有验证 console 运行。

## 4. 数据准备总流程

实验数据脚本都在：

```bash
/root/workspace/pg-view/experiment
```

整体流程是两步：

1. 把原始数据源转换成 PGVIEW 统一 CSV：

```text
experiment/dataset/targets/<dataset>/node.csv
experiment/dataset/targets/<dataset>/edge.csv
```

2. 把这些 CSV 导入到后端，生成 snapshot：

```text
experiment/dataset/snapshots/logicblox/<dataset>
experiment/dataset/snapshots/postgres/<dataset>.sql
experiment/dataset/snapshots/neo4j/<dataset>/neo4j.db
```

支持的数据集名：

```text
soc, word, prov, oag, lsqb
```

支持的导入平台参数：

```text
lb  = LogicBlox
pg  = PostgreSQL
n4  = Neo4j
```

## 5. 准备 Python 依赖

数据转换脚本依赖 Python 包：

```bash
cd /root/workspace/pg-view/experiment
pip install numpy pandas nltk
```

`word` 数据集还需要 NLTK WordNet 数据。仓库有脚本：

```bash
./install_nltk.py
```

也可以在 Python 中执行：

```python
import nltk
nltk.download("wordnet")
```

## 6. 放置原始数据源

所有路径都以 `experiment` 目录为当前目录。

### SOC

需要文件：

```text
dataset/sources/soc/soc-twitter-follows.mtx
```

来源：`https://nrvis.com/download/data/soc/soc-twitter-follows.zip`

### WORD

不需要手工下载 CSV 源文件。脚本从 NLTK WordNet 生成：

```text
dataset/targets/word/node.csv
dataset/targets/word/edge.csv
```

### PROV

需要解压后的文件：

```text
dataset/sources/prov/enwiki-20080103.wikipedia_talk
```

来源：`https://snap.stanford.edu/data/bigdata/wikipedia08/enwiki-20080103.wikipedia_talk.bz2`

### OAG

脚本读取：

```text
dataset/sources/oag/node.csv
dataset/sources/oag/edge.csv
```

README 中给出的来源是一个 Google Drive 压缩包。

### LSQB

脚本读取：

```text
dataset/sources/lsqb/*.csv
```

README 中说明从 `social-network-sf0.3-projected-fk.tar.zst` 解压得到。

## 7. 生成统一 CSV

进入 `experiment` 目录：

```bash
cd /root/workspace/pg-view/experiment
```

生成单个数据集，例如 `word`：

```bash
python3 ./prep_dataset_sources.py word
```

一次生成多个数据集：

```bash
python3 ./prep_dataset_sources.py soc word prov oag lsqb
```

每个数据集会生成：

```text
dataset/targets/<dataset>/node.csv
dataset/targets/<dataset>/edge.csv
```

其中 `node.csv` 的列是：

```text
nid,label
```

`edge.csv` 的列是：

```text
eid,from,to,label
```

脚本随后还会调用 `datasetlib/neo4j_prep.py`，生成 Neo4j import 专用文件：

```text
dataset/targets/<dataset>/neo4j/node/node.csv
dataset/targets/<dataset>/neo4j/edge/edge.csv
```

## 8. 生成后端 snapshot

进入 `experiment` 目录：

```bash
cd /root/workspace/pg-view/experiment
```

只生成 PostgreSQL snapshot：

```bash
./prep_db_snapshots.sh -p pg -d word
```

为多个后端和多个数据集生成 snapshot：

```bash
./prep_db_snapshots.sh -p lb pg n4 -d soc oag word prov lsqb
```

注意：该命令要求 `dataset/targets/<dataset>/node.csv` 和 `edge.csv` 已存在。

### PostgreSQL 导入逻辑

脚本 `prep_db_snapshots.sh` 中的 PostgreSQL 分支会：

1. 创建临时数据库 `temp_dataset`。
2. 执行 `datasetlib/prep_includes/postgres_snapshot_pre.sql` 建表。
3. 用 `\COPY` 导入：

```text
N_g(_0, _1) <= node.csv
E_g(_0, _1, _2, _3) <= edge.csv
```

4. 执行 `postgres_snapshot_post.sql` 建索引。
5. 用 `pg_dump` 导出：

```text
dataset/snapshots/postgres/<dataset>.sql
```

6. 删除临时数据库 `temp_dataset`。

脚本里写死了：

```text
PGPASSWORD=postgres@
psql -U postgres
```

所以 PostgreSQL 用户、密码和本机认证方式要匹配。README 推荐把 postgres 用户密码设置为 `postgres@`，并把 PostgreSQL 的 `pg_hba.conf` 中 postgres 本地认证改成 `md5`。

### LogicBlox 导入逻辑

脚本读取 `../conf/graphview.conf` 中：

```text
[logicblox]
lb_bin_dir = ~/tools/logicblox/bin
```

导入流程是：

1. `lb create <dataset> --overwrite`
2. `lb addblock <dataset> --name schema01 -f datasetlib/prep_includes/block.logic`
3. 根据 `datasetlib/prep_includes/exec.logic` 和当前 CSV 目录生成 `temp.logic`
4. `lb exec <dataset> -f temp.logic`
5. `lb export-workspace <dataset> dataset/snapshots/logicblox/<dataset>`
6. `lb delete <dataset>`

运行前需要启动 LogicBlox 服务，例如 README 中的：

```bash
source ~/tools/logicblox/etc/profile.d/logicblox.sh
source ~/tools/logicblox/etc/bash_completion.d/logicblox.sh
export LB_MEM=12G
lb services start
```

### Neo4j 导入逻辑

脚本读取 `../conf/graphview.conf` 中：

```text
[neo4j]
neo4j.dir = ~/tools/neo4j-community-4.1.11
```

它会调用：

```text
<neo4j.dir>/bin/neo4j-admin
```

重要风险：脚本会删除 standalone Neo4j 目录下的数据库：

```text
<neo4j.dir>/data/databases/neo4j
<neo4j.dir>/data/transactions/neo4j
```

然后执行 `neo4j-admin import`，再 dump 到：

```text
dataset/snapshots/neo4j/<dataset>/neo4j.db
```

不要把该脚本指向有重要数据的 Neo4j 实例目录。

## 9. 关于 `experiment/setup.sh`

仓库提供了：

```bash
cd /root/workspace/pg-view/experiment
./setup.sh
```

但这个脚本内部大量写死了：

```text
~/src/pg-view/experiment/...
```

如果源码不在 `~/src/pg-view`，直接运行 `setup.sh` 会把数据下载/写入到另一个位置，甚至失败。当前仓库路径是 `/root/workspace/pg-view`，所以更稳妥的做法是按本文第 6 到第 8 节手工执行，或者先把仓库放到 `~/src/pg-view`。

## 10. 常见问题

### `mvn compile` 找不到 Z3

错误类似：

```text
Could not find artifact com.microsoft:z3:jar:4.8.7 in central
```

按第 2 节安装 Z3 jar 到本地 Maven 仓库后重试。

### `mvn` 命令不存在

安装 Maven，或者使用当前机器上的：

```bash
/root/Downloads/apache-maven-3.9.12/bin/mvn
```

### PostgreSQL 导入失败

检查：

```bash
pg_isready
psql -X -U postgres -c 'SELECT version()'
```

并确认：

- PostgreSQL 服务已启动。
- 用户是 `postgres`。
- 密码是 `postgres@`，或者同步修改脚本。
- 本地认证允许密码登录。

### LogicBlox 导入失败

检查：

- `conf/graphview.conf` 的 `logicblox.lb_bin_dir` 是否正确。
- `lb services start` 是否已执行。
- `LB_MEM` 是否按机器内存合理设置。

### Neo4j 导入失败

检查：

- `conf/graphview.conf` 的 `neo4j.dir` 是否指向 standalone Neo4j 目录。
- `<neo4j.dir>/bin/neo4j-admin` 是否存在。
- 目标 Neo4j 数据库目录是否可以被安全删除。

## 11. Docker 最小闭环验证更新

后续已在 `/root/workspace/IncGQ/IncGQ-experiment-docs/pg-view/docker` 增加 Docker 环境文件，并完成一个最小闭环验证：

```text
PGVIEW 编译 -> WORD 数据集 CSV 生成 -> PostgreSQL snapshot
```

当前机器到 Docker Hub 不稳定，官方 compose 路线在拉取 `postgres:14` 时失败，错误为 Docker Hub 连接 reset；直接访问 `dockerproxy.com` mirror 也超时，腾讯云和网易 mirror DNS 解析失败。因此本次实际验证使用 fallback 镜像：

```text
pgview-experiment:local-graphscope
```

该 fallback 基于当前机器已有的 `registry.cn-hongkong.aliyuncs.com/graphscope/interactive:latest` 镜像构建，并挂载宿主机 `/root/.m2` 复用已安装的 `com.microsoft:z3:4.8.7`。

实际验证结果：

- fallback 镜像构建成功。
- 容器内 `mvn compile` 成功，独立编译耗时 12.525 秒。
- all-in-one 验证脚本中再次编译成功，耗时 11.100 秒。
- `nltk.downloader` 下载 WordNet 超过 180 秒超时；改为宿主机直接下载 `wordnet.zip` 并挂载到容器。
- `python3 ./prep_dataset_sources.py word` 成功，生成 471,943 个节点、822,248 条边。
- `./prep_db_snapshots.sh -p pg -d word` 成功，PostgreSQL `COPY` 导入 471,943 行节点和 822,248 行边。
- PostgreSQL snapshot 已生成：

```text
/root/workspace/pg-view/experiment/dataset/snapshots/postgres/word.sql
```

文件大小约 23 MB。
