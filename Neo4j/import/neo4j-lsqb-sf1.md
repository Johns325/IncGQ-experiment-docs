l# Neo4j LSQB SF1 导入流程

本文记录如何把 LSQB SF1 `projected-fk` CSV 导入 Neo4j 5.20.0。

本次已验证的输入：

```text
/mnt/data/datasets/lsqb/social-network-sf1-projected-fk.tar.zst
/mnt/data/datasets/lsqb/social-network-sf1-projected-fk
```

按要求，本次没有复用已有展开目录，而是新解压到：

```text
/mnt/data/imported_data/neo4j/lsqb/sf1/raw/social-network-sf1-projected-fk
```

导入后的数据库位于：

```text
/mnt/data/imported_data/neo4j/lsqb/sf1/data/databases/neo4j
/mnt/data/imported_data/neo4j/lsqb/sf1/data/transactions/neo4j
```

## 1. 关键确认

LSQB SF1 CSV 已经带 Neo4j admin import typed header，例如：

```text
Person.csv: id:ID(Person)
Person_knows_Person.csv: :START_ID(Person)|:END_ID(Person)
```

因此本次不需要修改 CSV，也不需要生成 prepared CSV。导入直接读取新解压出的 raw CSV。

注意：

1. 没有修改 `/mnt/data/datasets/lsqb/social-network-sf1-projected-fk` 原始目录。
2. 没有生成需要删除的临时 modified CSV。
3. `Neo4j/queries/lsqb/schema.cypher` 使用的是 `CREATE NODE TABLE/REL TABLE` 风格，不是 Neo4j 可执行 DDL；Neo4j 导入不能按该文件执行，只能把它作为 schema 参考。
4. LSQB 查询中使用 `message:Message`，所以导入时 `Post.csv` 使用 `Message:Post` labels，`Comment.csv` 使用 `Message:Comment` labels。

## 2. 新解压 raw CSV

```bash
export LSQB_ARCHIVE=/mnt/data/datasets/lsqb/social-network-sf1-projected-fk.tar.zst
export NEO4J_LSQB_TARGET=/mnt/data/imported_data/neo4j/lsqb/sf1
export NEO4J_LSQB_RAW="$NEO4J_LSQB_TARGET/raw/social-network-sf1-projected-fk"

mkdir -p "$NEO4J_LSQB_TARGET/raw"
tar --use-compress-program=zstd -xf "$LSQB_ARCHIVE" -C "$NEO4J_LSQB_TARGET/raw"
```

本次大小：

```text
65M   social-network-sf1-projected-fk.tar.zst
562M  raw/social-network-sf1-projected-fk
```

## 3. Neo4j 5.20 和 Java 17

本次复用了 BI/IC 导入时下载的工具链：

```bash
export NEO4J_HOME=/mnt/data/imported_data/neo4j/bi-sf1/tools/neo4j-community-5.20.0
export JAVA_HOME_17=/mnt/data/imported_data/neo4j/bi-sf1/tools/jdk-17.0.19+10-jre
```

检查：

```bash
JAVA_HOME="$JAVA_HOME_17" "$NEO4J_HOME/bin/neo4j-admin" --version
```

期望输出：

```text
5.20.0
```

## 4. 导入

使用本文档仓库中的脚本：

```text
/root/workspace/IncGQ/IncGQ-experiment-docs/scripts/import_neo4j_lsqb_sf1.py
```

执行：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_lsqb_sf1.py \
  --input-dir "$NEO4J_LSQB_RAW" \
  --target-dir "$NEO4J_LSQB_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --heap-size 8G \
  --check \
  --validate-counts
```

脚本会生成：

```text
$NEO4J_LSQB_TARGET/conf/neo4j.conf
$NEO4J_LSQB_TARGET/data
$NEO4J_LSQB_TARGET/logs
$NEO4J_LSQB_TARGET/import.report
```

## 5. 本次导入结果

`neo4j-admin database import full` 输出：

```text
IMPORT DONE in 24s 62ms.
Imported:
  3955790 nodes
  22196676 relationships
  3955790 properties
Peak memory usage: 1.069GiB
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

一致性检查：

```text
neo4j-admin database check neo4j
```

返回退出码 `0`。`import.report` 为空，没有坏行记录。

导入后目录大小：

```text
961M  /mnt/data/imported_data/neo4j/lsqb/sf1/data
```

## 6. 点边类型统计

统计基于新解压 raw CSV 的数据行数。原始 CSV 有表头，所以数据行数按 `raw_lines - 1` 计算。

节点按 Neo4j label 统计。注意 `Post` 和 `Comment` 同时也是 `Message`，所以 label 计数不能直接求和当作总节点数。

| Label | Count |
|---|---:|
| City | 1343 |
| Comment | 2580332 |
| Company | 1575 |
| Continent | 6 |
| Country | 111 |
| Forum | 109617 |
| Message | 3809607 |
| Person | 11000 |
| Post | 1229275 |
| Tag | 16080 |
| TagClass | 71 |
| University | 6380 |

关系按 Neo4j relationship type 统计：

| Relationship type | Count |
|---|---:|
| CONTAINER_OF | 1229275 |
| HAS_CREATOR | 3809607 |
| HAS_INTEREST | 255596 |
| HAS_MEMBER | 3268415 |
| HAS_MODERATOR | 109617 |
| HAS_TAG | 4317735 |
| HAS_TYPE | 16080 |
| IS_LOCATED_IN | 3828562 |
| IS_PART_OF | 1454 |
| IS_SUBCLASS_OF | 70 |
| KNOWS | 226293 |
| LIKES | 2521160 |
| REPLY_OF | 2580332 |
| STUDY_AT | 8880 |
| WORK_AT | 23600 |

## 7. 可选：验证统计是否和 CSV 行数一致

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_lsqb_sf1.py \
  --input-dir "$NEO4J_LSQB_RAW" \
  --target-dir "$NEO4J_LSQB_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --skip-import \
  --validate-counts
```

本次验证已经通过。输出中的关键汇总为：

```text
Node input total: 3955790
Relationship input total: 22196676
Count validation passed.
```

## 8. 只重新检查

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_lsqb_sf1.py \
  --input-dir "$NEO4J_LSQB_RAW" \
  --target-dir "$NEO4J_LSQB_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --skip-import \
  --check
```

## 9. Schema 映射

节点：

```text
Company          Company.csv
University       University.csv
Continent        Continent.csv
Country          Country.csv
City             City.csv
Tag              Tag.csv
TagClass         TagClass.csv
Forum            Forum.csv
Message:Comment  Comment.csv
Message:Post     Post.csv
Person           Person.csv
```

关系：

```text
IS_PART_OF      City_isPartOf_Country.csv
IS_PART_OF      Country_isPartOf_Continent.csv
HAS_CREATOR     Comment_hasCreator_Person.csv
HAS_CREATOR     Post_hasCreator_Person.csv
HAS_TAG         Comment_hasTag_Tag.csv
HAS_TAG         Forum_hasTag_Tag.csv
HAS_TAG         Post_hasTag_Tag.csv
IS_LOCATED_IN   Comment_isLocatedIn_Country.csv
IS_LOCATED_IN   Company_isLocatedIn_Country.csv
IS_LOCATED_IN   University_isLocatedIn_City.csv
IS_LOCATED_IN   Person_isLocatedIn_City.csv
IS_LOCATED_IN   Post_isLocatedIn_Country.csv
REPLY_OF        Comment_replyOf_Comment.csv
REPLY_OF        Comment_replyOf_Post.csv
CONTAINER_OF    Forum_containerOf_Post.csv
HAS_MEMBER      Forum_hasMember_Person.csv
HAS_MODERATOR   Forum_hasModerator_Person.csv
HAS_INTEREST    Person_hasInterest_Tag.csv
KNOWS           Person_knows_Person.csv
LIKES           Person_likes_Comment.csv
LIKES           Person_likes_Post.csv
STUDY_AT        Person_studyAt_University.csv
WORK_AT         Person_workAt_Company.csv
IS_SUBCLASS_OF  TagClass_isSubclassOf_TagClass.csv
HAS_TYPE        Tag_hasType_TagClass.csv
```
