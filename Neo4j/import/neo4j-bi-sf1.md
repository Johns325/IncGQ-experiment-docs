# Neo4j LDBC SNB BI SF1 实验流程

## 1. 已验证导入流程

本文只保留当前机器实测可执行的 BI SF1 导入流程。此前文档中的旧自动化脚本在当前
`/root/workspace/ldbc_snb_bi` 仓库中不存在，不能按旧命令执行。

本次已经成功把 BI SF1 数据导入到：

```text
/mnt/data/imported_data/neo4j/bi-sf1/data/databases/neo4j
/mnt/data/imported_data/neo4j/bi-sf1/data/transactions/neo4j
```

实际输入 CSV：

```text
/mnt/data/datasets/ldbc_snb_bi/bi-sf1-composite-projected-fk/graphs/csv/bi/composite-projected-fk/initial_snapshot
```

### 1.1 当前数据不能直接使用仓库自带 import.sh

当前 `/root/workspace/ldbc_snb_bi/neo4j/scripts/import.sh` 真实存在，但不能直接导入这份 CSV：

1. 当前 CSV 是带表头的 partitioned CSV。
2. 仓库 README 要求导入 CSV 无表头。
3. 仓库自带 `neo4j/headers/...` 与当前 CSV 列顺序不一致。
4. 本机没有 `neo4j-admin` 命令。
5. Docker Hub 拉取 `neo4j:5.20.0` 时出现连接重置。

因此本次使用 Neo4j 官方 tarball + 独立 Java 17 JRE，并新增脚本：

```text
/root/workspace/IncGQ/IncGQ-experiment-docs/scripts/import_neo4j_bi_partitioned.py
```

### 1.2 准备 Neo4j 5.20 和 Java 17

```bash
export LDBC_BI_DATA_DIR=/mnt/data/datasets/ldbc_snb_bi/bi-sf1-composite-projected-fk/graphs/csv/bi/composite-projected-fk/initial_snapshot
export NEO4J_BI_TARGET=/mnt/data/imported_data/neo4j/bi-sf1

mkdir -p "$NEO4J_BI_TARGET/tools"

curl -L --fail --retry 10 --retry-all-errors --retry-delay 3 -C - \
  -o "$NEO4J_BI_TARGET/tools/neo4j-community-5.20.0-unix.tar.gz" \
  https://dist.neo4j.org/neo4j-community-5.20.0-unix.tar.gz

curl -L --fail --retry 10 --retry-all-errors --retry-delay 3 -C - \
  -o "$NEO4J_BI_TARGET/tools/OpenJDK17U-jre_x64_linux_hotspot_17.0.19_10.tar.gz" \
  'https://api.adoptium.net/v3/binary/latest/17/ga/linux/x64/jre/hotspot/normal/eclipse'

tar -xzf "$NEO4J_BI_TARGET/tools/neo4j-community-5.20.0-unix.tar.gz" -C "$NEO4J_BI_TARGET/tools"
tar -xzf "$NEO4J_BI_TARGET/tools/OpenJDK17U-jre_x64_linux_hotspot_17.0.19_10.tar.gz" -C "$NEO4J_BI_TARGET/tools"
```

验证：

```bash
JAVA_HOME="$NEO4J_BI_TARGET/tools/jdk-17.0.19+10-jre" \
  "$NEO4J_BI_TARGET/tools/neo4j-community-5.20.0/bin/neo4j-admin" --version
```

期望输出：

```text
5.20.0
```

### 1.3 导入命令

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_bi_partitioned.py \
  --data-dir "$LDBC_BI_DATA_DIR" \
  --target-dir "$NEO4J_BI_TARGET" \
  --neo4j-home "$NEO4J_BI_TARGET/tools/neo4j-community-5.20.0" \
  --java-home "$NEO4J_BI_TARGET/tools/jdk-17.0.19+10-jre" \
  --heap-size 8G \
  --check
```

脚本会：

1. 在 `$NEO4J_BI_TARGET/prepared-csv/initial_snapshot` 生成无表头 CSV 副本。
2. 在 `$NEO4J_BI_TARGET/prepared-headers` 生成与当前 CSV 列顺序匹配的 Neo4j typed headers。
3. 把 `Place.type` 导成 `City/Country/Continent` 等标签。
4. 把 `Organisation.type` 导成 `Company/University` 标签。
5. 把 `Comment` 和 `Post` 同时导入 `Message` 标签。
6. 把 `Person.language` 属性重命名为查询脚本使用的 `speaks:STRING[]`。
7. 执行 `neo4j-admin database import full`，数据库名使用默认 `neo4j`。
8. 执行离线 `neo4j-admin database info neo4j` 和 `neo4j-admin database check neo4j`。

### 1.4 本次导入结果

```text
IMPORT DONE in 34s 708ms.
Imported:
  2997352 nodes
  17196776 relationships
  35076475 properties
Peak memory usage: 1.060GiB
```

离线元信息：

```text
Database name:                neo4j
Database in use:              false
Store format version:         record-aligned-1.1
Store format introduced in:   5.0.0
Last committed transaction id:2
Store needs recovery:         false
```

离线一致性检查 `neo4j-admin database check neo4j` 返回退出码 `0`。

导入后目录大小：

```text
1.9G  /mnt/data/imported_data/neo4j/bi-sf1/data
```

### 1.5 点边类型统计

统计基于本次实际导入使用的 prepared CSV。`import.report` 为空且离线一致性检查通过，因此这些行数与导入结果一致。

节点按 Neo4j label 统计。注意 label 会重叠：例如 `Post` 同时也是 `Message`，`Country/City/Continent` 同时也是 `Place`，`Company/University` 同时也是 `Organisation`，所以 label 计数不能直接求和当作总节点数。

| Label | Count |
|---|---:|
| City | 1343 |
| Comment | 1739438 |
| Company | 1575 |
| Continent | 6 |
| Country | 111 |
| Forum | 100827 |
| Message | 2860664 |
| Organisation | 7955 |
| Person | 10295 |
| Place | 1460 |
| Post | 1121226 |
| Tag | 16080 |
| TagClass | 71 |
| University | 6380 |

关系按 Neo4j relationship type 统计：

| Relationship type | Count |
|---|---:|
| CONTAINER_OF | 1121226 |
| HAS_CREATOR | 2860664 |
| HAS_INTEREST | 238052 |
| HAS_MEMBER | 2909768 |
| HAS_MODERATOR | 100827 |
| HAS_TAG | 3256648 |
| HAS_TYPE | 16080 |
| IS_LOCATED_IN | 2878914 |
| IS_PART_OF | 1454 |
| IS_SUBCLASS_OF | 70 |
| KNOWS | 173014 |
| LIKES | 1870268 |
| REPLY_OF | 1739438 |
| STUDY_AT | 8309 |
| WORK_AT | 22044 |

### 1.6 可选：验证统计是否和 CSV 行数一致

可以用 `--validate-counts` 验证每个原始 CSV 目录的数据行数是否等于 prepared CSV 行数，并重新打印 label/type 汇总：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_bi_partitioned.py \
  --data-dir "$LDBC_BI_DATA_DIR" \
  --target-dir "$NEO4J_BI_TARGET" \
  --neo4j-home "$NEO4J_BI_TARGET/tools/neo4j-community-5.20.0" \
  --java-home "$NEO4J_BI_TARGET/tools/jdk-17.0.19+10-jre" \
  --skip-prepare \
  --skip-import \
  --validate-counts
```

本次验证已经通过。输出中的关键汇总为：

```text
Node input total: 2997352
Relationship input total: 17196776
Count validation passed.
```

验证口径：

1. 原始 CSV 每个 part 文件都有表头，所以原始数据行数按 `raw_lines - 1` 计算。
2. prepared CSV 已去表头，所以 prepared 行数直接等于导入行数。
3. 若任一表 `raw_data_rows != prepared_rows`，脚本会返回非 0。

### 1.7 只重新检查

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_bi_partitioned.py \
  --data-dir "$LDBC_BI_DATA_DIR" \
  --target-dir "$NEO4J_BI_TARGET" \
  --neo4j-home "$NEO4J_BI_TARGET/tools/neo4j-community-5.20.0" \
  --java-home "$NEO4J_BI_TARGET/tools/jdk-17.0.19+10-jre" \
  --skip-prepare \
  --skip-import \
  --check
```

### 1.8 查询参数

当前机器没有找到旧文档假设的 `bi-parameters-sf1` 目录。`/root/workspace/ldbc_snb_bi`
中存在 `parameters/parameters-sf30` 和 `paramgen`，但这不是 SF1 参数目录。
因此本次只完成数据导入；运行 BI benchmark 查询前还需要准备 SF1 参数文件。
