# Neo4j LDBC SNB IC SF1 导入流程

本文记录如何把 LDBC SNB Interactive Complex SF1 的 `CsvComposite-StringDateFormatter`
数据导入 Neo4j 5.20.0。

本次已验证的 archive：

```text
/mnt/data/datasets/ldbc_snb_ic/social_network-sf1-CsvComposite-StringDateFormatter.tar.zst
```

导入目标：

```text
/mnt/data/imported_data/neo4j/ic-sf1
```

导入后的数据库位于：

```text
/mnt/data/imported_data/neo4j/ic-sf1/data/databases/neo4j
/mnt/data/imported_data/neo4j/ic-sf1/data/transactions/neo4j
```

## 1. 关键修正点

此前没有 Neo4j IC SF1 导入文档。本次实测后补充本文档和导入脚本：

```text
/root/workspace/IncGQ/IncGQ-experiment-docs/scripts/import_neo4j_ic_sf1.py
```

注意不要直接套用 BI SF1 的导入规则：

1. IC archive 是 flat composite 结构，一张表一个 CSV，例如 `dynamic/person_0_0.csv`。
2. CSV 带表头，需要生成无表头 prepared CSV。
3. `queries/ldbc-ic` 中的 Cypher 把 `birthday/creationDate/joinDate` 当 epoch millis 数值使用，因此这些列必须导入为 `LONG`，不能导入为 Neo4j `DATETIME/DATE`。
4. 原始 `place.type` 和 `organisation.type` 是小写，例如 `country/company`，需要转换为查询使用的 `Country/Company` 标签。
5. `Person.language` 需要导入为 `speaks:STRING[]`，以匹配 IC 查询中的 `friend.speaks`。
6. archive 中的 `updateStream_0_0_person.csv` 和 `updateStream_0_0_forum.csv` 是更新流，不属于初始图导入。

## 2. 解压一份新的 raw 数据

按要求不要复用其他已展开目录。本次新解压到：

```bash
export IC_ARCHIVE=/mnt/data/datasets/ldbc_snb_ic/social_network-sf1-CsvComposite-StringDateFormatter.tar.zst
export NEO4J_IC_TARGET=/mnt/data/imported_data/neo4j/ic-sf1
export NEO4J_IC_RAW="$NEO4J_IC_TARGET/raw/social_network-sf1-CsvComposite-StringDateFormatter"

mkdir -p "$NEO4J_IC_TARGET/raw"
tar --use-compress-program=zstd -xf "$IC_ARCHIVE" -C "$NEO4J_IC_TARGET/raw"
```

解压后本次统计：

```text
1.1G raw
33 CSV files
```

其中初始图导入使用 31 个 CSV：8 类节点、23 类关系。

## 3. Neo4j 5.20 和 Java 17

本次复用了 BI SF1 导入时下载的工具链：

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

如果该工具链不存在，可参考 `Neo4j/neo4j-bi-sf1.md` 中的 Neo4j 5.20.0 tarball 和 Java 17 JRE 下载步骤。

## 4. 导入

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_ic_sf1.py \
  --input-dir "$NEO4J_IC_RAW" \
  --target-dir "$NEO4J_IC_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --heap-size 8G \
  --check
```

脚本会生成：

```text
$NEO4J_IC_TARGET/prepared-csv
$NEO4J_IC_TARGET/prepared-headers
$NEO4J_IC_TARGET/conf/neo4j.conf
$NEO4J_IC_TARGET/data
$NEO4J_IC_TARGET/logs
$NEO4J_IC_TARGET/import.report
```

本次 prepared 目录大小：

```text
712M  prepared-csv
136K  prepared-headers
```

## 5. 本次导入结果

`neo4j-admin database import full` 输出：

```text
IMPORT DONE in 24s 298ms.
Imported:
  3181724 nodes
  17256038 relationships
  23000900 properties
Peak memory usage: 1.062GiB
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
1.4G  /mnt/data/imported_data/neo4j/ic-sf1/data
```

## 6. 点边类型统计

统计基于本次实际导入使用的 prepared CSV。`import.report` 为空且离线一致性检查通过，因此这些行数与导入结果一致。

节点按 Neo4j label 统计。注意 label 会重叠：例如 `Post` 同时也是 `Message`，`Country/City/Continent` 同时也是 `Place`，`Company/University` 同时也是 `Organisation`，所以 label 计数不能直接求和当作总节点数。

| Label | Count |
|---|---:|
| City | 1343 |
| Comment | 2052169 |
| Company | 1575 |
| Continent | 6 |
| Country | 111 |
| Forum | 90492 |
| Message | 3055774 |
| Organisation | 7955 |
| Person | 9892 |
| Place | 1460 |
| Post | 1003605 |
| Tag | 16080 |
| TagClass | 71 |
| University | 6380 |

关系按 Neo4j relationship type 统计：

| Relationship type | Count |
|---|---:|
| CONTAINER_OF | 1003605 |
| HAS_CREATOR | 3055774 |
| HAS_INTEREST | 229166 |
| HAS_MEMBER | 1611869 |
| HAS_MODERATOR | 90492 |
| HAS_TAG | 3721417 |
| HAS_TYPE | 16080 |
| IS_LOCATED_IN | 3073621 |
| IS_PART_OF | 1454 |
| IS_SUBCLASS_OF | 70 |
| KNOWS | 180623 |
| LIKES | 2190095 |
| REPLY_OF | 2052169 |
| STUDY_AT | 7949 |
| WORK_AT | 21654 |

## 7. 可选：验证统计是否和 CSV 行数一致

可以用 `--validate-counts` 验证每个原始 CSV 的数据行数是否等于 prepared CSV 行数，并重新打印 label/type 汇总：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_ic_sf1.py \
  --input-dir "$NEO4J_IC_RAW" \
  --target-dir "$NEO4J_IC_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --skip-prepare \
  --skip-import \
  --validate-counts
```

本次验证已经通过。输出中的关键汇总为：

```text
Node input total: 3181724
Relationship input total: 17256038
Count validation passed.
```

验证口径：

1. 原始 CSV 有表头，所以原始数据行数按 `raw_lines - 1` 计算。
2. prepared CSV 已去表头，所以 prepared 行数直接等于导入行数。
3. 若任一表 `raw_data_rows != prepared_rows`，脚本会返回非 0。

## 8. 只重新检查

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_ic_sf1.py \
  --input-dir "$NEO4J_IC_RAW" \
  --target-dir "$NEO4J_IC_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --skip-prepare \
  --skip-import \
  --check
```

## 9. Schema 映射

节点：

```text
Place          static/place_0_0.csv
Organisation   static/organisation_0_0.csv
TagClass       static/tagclass_0_0.csv
Tag            static/tag_0_0.csv
Person         dynamic/person_0_0.csv
Forum          dynamic/forum_0_0.csv
Message:Post   dynamic/post_0_0.csv
Message:Comment dynamic/comment_0_0.csv
```

关系：

```text
IS_PART_OF      static/place_isPartOf_place_0_0.csv
IS_SUBCLASS_OF  static/tagclass_isSubclassOf_tagclass_0_0.csv
IS_LOCATED_IN   static/organisation_isLocatedIn_place_0_0.csv
HAS_TYPE        static/tag_hasType_tagclass_0_0.csv
IS_LOCATED_IN   dynamic/person_isLocatedIn_place_0_0.csv
HAS_INTEREST    dynamic/person_hasInterest_tag_0_0.csv
WORK_AT         dynamic/person_workAt_organisation_0_0.csv
STUDY_AT        dynamic/person_studyAt_organisation_0_0.csv
KNOWS           dynamic/person_knows_person_0_0.csv
CONTAINER_OF    dynamic/forum_containerOf_post_0_0.csv
HAS_MEMBER      dynamic/forum_hasMember_person_0_0.csv
HAS_MODERATOR   dynamic/forum_hasModerator_person_0_0.csv
HAS_TAG         dynamic/forum_hasTag_tag_0_0.csv
LIKES           dynamic/person_likes_post_0_0.csv
LIKES           dynamic/person_likes_comment_0_0.csv
HAS_CREATOR     dynamic/post_hasCreator_person_0_0.csv
HAS_TAG         dynamic/post_hasTag_tag_0_0.csv
IS_LOCATED_IN   dynamic/post_isLocatedIn_place_0_0.csv
HAS_CREATOR     dynamic/comment_hasCreator_person_0_0.csv
HAS_TAG         dynamic/comment_hasTag_tag_0_0.csv
IS_LOCATED_IN   dynamic/comment_isLocatedIn_place_0_0.csv
REPLY_OF        dynamic/comment_replyOf_post_0_0.csv
REPLY_OF        dynamic/comment_replyOf_comment_0_0.csv
```
