# PGVIEW Docker 环境

这个目录提供 PGVIEW 的 Docker 环境。推荐优先使用 Docker，而不是直接在宿主机上混装 Java、Maven、Python、PostgreSQL、Neo4j、LogicBlox。

当前机器实际验证成功的是 fallback 路线：

```text
PGVIEW 编译 -> WORD CSV -> PostgreSQL snapshot
PGVIEW 编译 -> WORD Neo4j CSV -> PGVIEW Neo4j 4.4 import -> /mnt 数据落盘
PGVIEW Neo4j 查询验证 -> word + n4 + mv/vv
PGVIEW 编译 -> WORD Neo4j CSV -> Neo4j 2025 dump
```

## 文件说明

- `Dockerfile`: 标准 PGVIEW 工具镜像，适合 Docker Hub 可用的机器。
- `docker-compose.yml`: 标准 compose，包含 PGVIEW 工具容器和 PostgreSQL 14。
- `Dockerfile.local-graphscope`: 当前机器可用的 all-in-one PostgreSQL fallback 镜像。
- `Dockerfile.neo4j2025-local`: 当前机器可用的 Neo4j 2025 fallback 镜像，额外安装 Java 21。
- `scripts/verify_word_pg.sh`: 标准 compose 中的 PostgreSQL 验证脚本。
- `scripts/verify_word_pg_allinone.sh`: all-in-one PostgreSQL fallback 验证脚本。
- `scripts/verify_word_neo4j2025.sh`: Neo4j 2025 fallback 验证脚本。

## 先准备 WordNet

```bash
mkdir -p /tmp/nltk_data/corpora
wget -O /tmp/nltk_data/corpora/wordnet.zip \
  https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/wordnet.zip
```

## 推荐路线 1：PostgreSQL fallback

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs/pg-view/docker
docker build -f Dockerfile.local-graphscope -t pgview-experiment:local-graphscope .
```

```bash
docker run --rm \
  -v /root/workspace/pg-view:/workspace/pg-view \
  -v /root/.m2:/root/.m2 \
  -v /tmp/nltk_data:/usr/local/share/nltk_data \
  -v "$(pwd)":/workspace/pg-view-docker:ro \
  pgview-experiment:local-graphscope \
  bash /workspace/pg-view-docker/scripts/verify_word_pg_allinone.sh
```

成功产物：

```text
/root/workspace/pg-view/experiment/dataset/snapshots/postgres/word.sql
```

## 推荐路线 2：PGVIEW 原生 Neo4j 4.4 导入到 /mnt

这条路线会在 Docker 中运行 PGVIEW 自己的 `mvn exec:java@graphprepn4`，并把 Neo4j 数据写到：

```text
/mnt/data/imported_data/pg-view/neo4j
```

准备配置：

```bash
cat > /tmp/pgview-graphview-neo4j.conf <<'EOF'
[default]

[logicblox]
ip = 127.0.0.1
port = 5518
adminport = 5519
lb_bin_dir = ~/tools/logicblox/bin

[postgres]
ip = 127.0.0.1
port = 5432
username = postgres
password = postgres@
pg_dir =

[neo4j]
embedded = true
dbdir = ../../mnt/data/imported_data/pg-view/neo4j/runtime44
neo4j.dir = ~/tools/neo4j-community-4.1.11
ip = 127.0.0.1
port = 7687
EOF
```

构建镜像：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs/pg-view/docker
docker build -f Dockerfile.local-graphscope -t pgview-experiment:local-graphscope .
```

准备目录：

```bash
mkdir -p /mnt/data/imported_data/pg-view/neo4j/snapshots/word
mkdir -p /root/workspace/pg-view/experiment/dataset/snapshots/neo4j/word
```

重复执行时，如果旧 target dump 已存在，先备份：

```bash
if [ -e /root/workspace/pg-view/experiment/dataset/targets/neo4j/word ]; then
  mv /root/workspace/pg-view/experiment/dataset/targets/neo4j/word \
    /root/workspace/pg-view/experiment/dataset/targets/neo4j/word.bak-$(date -u +%Y%m%dT%H%M%SZ)
fi
```

编译：

```bash
docker run --rm \
  -w /workspace/pg-view \
  -v /root/workspace/pg-view:/workspace/pg-view \
  -v /root/.m2:/root/.m2 \
  -v /mnt/data/imported_data/pg-view/neo4j:/mnt/data/imported_data/pg-view/neo4j \
  -v /tmp/pgview-graphview-neo4j.conf:/workspace/pg-view/graphview.conf:ro \
  -v /tmp/pgview-graphview-neo4j.conf:/workspace/pg-view/conf/graphview.conf:ro \
  pgview-experiment:local-graphscope \
  mvn compile
```

导入：

```bash
docker run --rm \
  -w /workspace/pg-view \
  -v /root/workspace/pg-view:/workspace/pg-view \
  -v /root/.m2:/root/.m2 \
  -v /mnt/data/imported_data/pg-view/neo4j:/mnt/data/imported_data/pg-view/neo4j \
  -v /tmp/pgview-graphview-neo4j.conf:/workspace/pg-view/graphview.conf:ro \
  -v /tmp/pgview-graphview-neo4j.conf:/workspace/pg-view/conf/graphview.conf:ro \
  pgview-experiment:local-graphscope \
  mvn exec:java@graphprepn4
```

同步 dump：

```bash
cp /root/workspace/pg-view/experiment/dataset/targets/neo4j/word \
  /mnt/data/imported_data/pg-view/neo4j/snapshots/word/neo4j.db

cp /root/workspace/pg-view/experiment/dataset/targets/neo4j/word \
  /root/workspace/pg-view/experiment/dataset/snapshots/neo4j/word/neo4j.db
```

成功产物：

```text
/mnt/data/imported_data/pg-view/neo4j/runtime44
/mnt/data/imported_data/pg-view/neo4j/snapshots/word/neo4j.db
/root/workspace/pg-view/experiment/dataset/snapshots/neo4j/word/neo4j.db
```

当前机器实测：

```text
mvn compile: success
Neo4j importer: 4.4.0
imported nodes: 471,943
imported relationships: 822,248
imported properties: 5,176,764
runtime size: about 351 MB
dump size: about 16 MB
```

### 查询验证

准备查询配置：

```bash
cat > /tmp/pgview-graphview-neo4j-mounted.conf <<'EOF'
[default]

[logicblox]
ip = 127.0.0.1
port = 5518
adminport = 5519
lb_bin_dir = ~/tools/logicblox/bin

[postgres]
ip = 127.0.0.1
port = 5432
username = postgres
password = postgres@
pg_dir =

[neo4j]
embedded = true
dbdir = imported_neo4j/runtime44
neo4j.dir = ~/tools/neo4j-community-4.1.11
ip = 127.0.0.1
port = 7687
EOF
```

已验证成功：

```bash
docker run --rm \
  -w /workspace/pg-view/experiment \
  -v /root/workspace/pg-view:/workspace/pg-view \
  -v /root/.m2:/root/.m2 \
  -v /mnt/data/imported_data/pg-view/neo4j:/workspace/pg-view/imported_neo4j \
  -v /tmp/pgview-graphview-neo4j-mounted.conf:/workspace/pg-view/conf/graphview.conf:ro \
  pgview-experiment:local-graphscope \
  bash ./run.sh -i 1 -p n4 -v mv -d word

docker run --rm \
  -w /workspace/pg-view/experiment \
  -v /root/workspace/pg-view:/workspace/pg-view \
  -v /root/.m2:/root/.m2 \
  -v /mnt/data/imported_data/pg-view/neo4j:/workspace/pg-view/imported_neo4j \
  -v /tmp/pgview-graphview-neo4j-mounted.conf:/workspace/pg-view/conf/graphview.conf:ro \
  pgview-experiment:local-graphscope \
  bash ./run.sh -i 1 -p n4 -v vv -d word
```

实测结果：

```text
word + n4 + mv: success, word_v1_q1 count 0, word_v1_q2 count 0
word + n4 + vv: success, word_v1_q1 count 0, word_v1_q2 count 0
word + n4 + hv: not passed; hybrid view construction did not finish within several minutes
word + n4 + ssr: skipped by PGVIEW code
```

因此，当前不能写成 “所有 Neo4j 查询路线都成功”。准确结论是：Docker 编译、WORD Neo4j 导入到 `/mnt`、`mv/vv` 查询路线已验证成功；`hv` 仍需继续排查。

## 推荐路线 3：Neo4j 2025 fallback

当前机器已有：

```text
/root/Downloads/neo4j-community-2025.12.1
```

构建：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs/pg-view/docker
docker build -f Dockerfile.neo4j2025-local -t pgview-experiment:neo4j2025-local .
```

运行：

```bash
docker run --rm \
  -v /root/workspace/pg-view:/workspace/pg-view \
  -v /root/.m2:/root/.m2 \
  -v /tmp/nltk_data:/usr/local/share/nltk_data \
  -v /root/Downloads/neo4j-community-2025.12.1:/opt/neo4j:ro \
  -v "$(pwd)":/workspace/pg-view-docker:ro \
  pgview-experiment:neo4j2025-local \
  bash /workspace/pg-view-docker/scripts/verify_word_neo4j2025.sh
```

成功产物：

```text
/root/workspace/pg-view/experiment/dataset/snapshots/neo4j2025/word/neo4j.dump
```

脚本会把 `/opt/neo4j` 复制到容器内 `/tmp/neo4j-work` 后再导入，不会修改宿主机 Neo4j 下载目录。

## 可联网机器的标准 compose

如果 Docker Hub 可用，可以使用：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs/pg-view/docker
docker compose up -d --build
docker compose exec pgview mvn compile
docker compose exec pgview bash /workspace/pg-view-docker/scripts/verify_word_pg.sh
```

当前机器没有走通这条路线，原因是拉取 `postgres:14` 和 `maven:*` 时 Docker Hub 连接不稳定。

## 当前验证结果

文档重排后，已在 2026-06-12 按本 README 中的 Docker 命令重新执行验证，结果如下。

PostgreSQL fallback 已实际验证：

```text
mvn compile: success
WORD CSV: 471,943 nodes, 822,248 edges
PostgreSQL snapshot: /root/workspace/pg-view/experiment/dataset/snapshots/postgres/word.sql
size: about 23 MB
```

Neo4j 2025 fallback 已实际验证：

```text
mvn compile: success
Neo4j version: 2025.12.1
imported nodes: 471,943
imported relationships: 822,248
imported properties: 5,176,764
dump: /root/workspace/pg-view/experiment/dataset/snapshots/neo4j2025/word/neo4j.dump
size: about 16 MB
```

PGVIEW 原生 Neo4j 4.4 Docker 导入已实际验证：

```text
mvn compile: success
Neo4j importer: 4.4.0
imported nodes: 471,943
imported relationships: 822,248
imported properties: 5,176,764
runtime: /mnt/data/imported_data/pg-view/neo4j/runtime44
runtime size: about 351 MB
dump: /mnt/data/imported_data/pg-view/neo4j/snapshots/word/neo4j.db
dump size: about 16 MB
pg-view query snapshot: /root/workspace/pg-view/experiment/dataset/snapshots/neo4j/word/neo4j.db
```

PGVIEW Neo4j 查询已实际验证：

```text
word + n4 + mv: success, word_v1_q1 count 0, word_v1_q2 count 0
word + n4 + vv: success, word_v1_q1 count 0, word_v1_q2 count 0
word + n4 + hv: not passed; APOC hybrid view construction did not finish
word + n4 + ssr: skipped by PGVIEW code
```

未验证成功：

```text
LogicBlox: missing lb / LogicBlox 4.41.0
Neo4j n4 + hv query route: did not complete in this run
Original Neo4j 4.1.11 standalone route: missing neo4j-community-4.1.11
Standard docker compose on current machine: Docker Hub pull failed
```
