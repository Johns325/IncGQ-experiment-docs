# LSQB SF1 导入 Kuzu

本文档记录已验证过的 LSQB SF1 导入 Kuzu 流程。验证环境中 `kuzu` Python 包版本为 `0.10.0`。

目标库目录：

```bash
/mnt/data/imported_data/kuzu/lsqb/sf1
```

导入脚本：

```bash
scripts/import_ldbc_to_kuzu.py
```

该脚本现在支持 `ic`、`bi`、`lsqb` 三种数据集。

## 数据源

脚本默认从压缩包重新解压临时副本，不直接修改现有 CSV 目录：

```bash
/mnt/data/datasets/lsqb/social-network-sf1-projected-fk.tar.zst
```

现有已解压 CSV 目录仅用于对照：

```bash
/mnt/data/datasets/lsqb/social-network-sf1-projected-fk
```

Schema 和 import 映射来自：

```bash
tests/resources/lsqb/configs/graph-lsqb.yaml
tests/resources/lsqb/configs/import-lsqb-jcloud.yaml
```

## 已验证导入命令

```bash
python3 scripts/import_ldbc_to_kuzu.py lsqb
```

如果目标目录已有半成品或旧库，使用：

```bash
python3 scripts/import_ldbc_to_kuzu.py lsqb --overwrite
```

脚本默认使用 `/tmp/kuzu_import_lsqb_*` 作为临时工作目录，导入成功或失败后会删除该目录。

## 脚本做了哪些处理

1. 从 `social-network-sf1-projected-fk.tar.zst` 解压一份新的临时副本。
2. 按 `graph-lsqb.yaml` 创建 11 个 Kuzu node table 和 25 个 rel table。
3. LSQB CSV 是 Neo4j 风格表头，例如 `id:ID(Person)` 和 `:START_ID(Person)|:END_ID(Tag)`。脚本按 `import-lsqb-jcloud.yaml` 中的 `column_mappings`、`source_vertex_mappings`、`destination_vertex_mappings` 生成临时 `_kuzu_normalized` CSV。
4. 对每个输入 CSV 执行 `COPY ... (HEADER=true, DELIM='|', FROM='...', TO='...')`。
5. 导入完成后逐表执行 count 校验。

## 已纠正的文档/脚本点

- LSQB 不能走 LDBC IC 的预处理逻辑。IC 才需要生成 `HASCREATOR.creationDate` 临时文件；LSQB 没有 `dynamic/post_0_0.csv` 这类路径。
- LSQB 不能只按 schema 属性名查找源 CSV 列。源 CSV 表头是 `id:ID(...)` / `:START_ID(...)` / `:END_ID(...)`，必须按 import yaml 的列索引映射到 Kuzu 表列。
- 原始 CSV 和现有已解压目录不需要修改。所有 Kuzu 专用表头规范化只发生在临时 `_kuzu_normalized` 目录。

## 本次校验结果

```text
vertex Company: expected=1575 actual=1575
vertex University: expected=6380 actual=6380
vertex Continent: expected=6 actual=6
vertex Country: expected=111 actual=111
vertex City: expected=1343 actual=1343
vertex Tag: expected=16080 actual=16080
vertex TagClass: expected=71 actual=71
vertex Forum: expected=109617 actual=109617
vertex Comment: expected=2580332 actual=2580332
vertex Post: expected=1229275 actual=1229275
vertex Person: expected=11000 actual=11000
edge City_isPartOf_Country: expected=1343 actual=1343
edge Comment_hasCreator_Person: expected=2580332 actual=2580332
edge Comment_hasTag_Tag: expected=3148317 actual=3148317
edge Comment_isLocatedIn_Country: expected=2580332 actual=2580332
edge Comment_replyOf_Comment: expected=1305740 actual=1305740
edge Comment_replyOf_Post: expected=1274592 actual=1274592
edge Company_isLocatedIn_Country: expected=1575 actual=1575
edge Country_isPartOf_Continent: expected=111 actual=111
edge Forum_containerOf_Post: expected=1229275 actual=1229275
edge Forum_hasMember_Person: expected=3268415 actual=3268415
edge Forum_hasModerator_Person: expected=109617 actual=109617
edge Forum_hasTag_Tag: expected=354213 actual=354213
edge Person_hasInterest_Tag: expected=255596 actual=255596
edge Person_isLocatedIn_City: expected=11000 actual=11000
edge Person_knows_Person: expected=226293 actual=226293
edge Person_likes_Comment: expected=1668015 actual=1668015
edge Person_likes_Post: expected=853145 actual=853145
edge Person_studyAt_University: expected=8880 actual=8880
edge Person_workAt_Company: expected=23600 actual=23600
edge Post_hasCreator_Person: expected=1229275 actual=1229275
edge Post_hasTag_Tag: expected=815205 actual=815205
edge Post_isLocatedIn_Country: expected=1229275 actual=1229275
edge TagClass_isSubclassOf_TagClass: expected=70 actual=70
edge Tag_hasType_TagClass: expected=16080 actual=16080
edge University_isLocatedIn_City: expected=6380 actual=6380
```

额外 read-only 查询确认：

```text
MATCH (p:Person) RETURN count(p); 11000
MATCH ()-[r:Person_knows_Person]->() RETURN count(r); 226293
MATCH ()-[r:Forum_hasMember_Person]->() RETURN count(r); 3268415
```

导入后库大小：

```text
486M /mnt/data/imported_data/kuzu/lsqb/sf1
```
