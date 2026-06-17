# LDBC SNB IC/BI SF1 导入 Kuzu

本文档记录已验证过的 Kuzu 导入流程。验证环境中 `kuzu` Python 包版本为 `0.10.0`，目标库目录为：

- IC: `/mnt/data/imported_data/kuzu/ic-sf1`
- BI: `/mnt/data/imported_data/kuzu/bi-sf1`

导入脚本位于：

```bash
scripts/import_ldbc_to_kuzu.py
```

## 数据源

脚本默认从压缩包重新解压一份临时副本，不直接修改现有 CSV 目录：

- IC archive: `/mnt/data/datasets/ldbc_snb_ic/social_network-sf1-CsvComposite-StringDateFormatter.tar.zst`
- BI archive: `/mnt/data/datasets/ldbc_snb_bi/bi-sf1-composite-projected-fk.tar.zst`

现有已解压目录只用于对照：

- IC: `/mnt/data/datasets/ldbc_snb_ic/social_network-sf1-CsvComposite-StringDateFormatter`
- BI: `/mnt/data/datasets/ldbc_snb_bi/bi-sf1-composite-projected-fk/graphs/csv/bi/composite-projected-fk/initial_snapshot`

## 已验证导入命令

```bash
python3 scripts/import_ldbc_to_kuzu.py ic --overwrite
python3 scripts/import_ldbc_to_kuzu.py bi --overwrite
```

如果目标目录为空，可以省略 `--overwrite`。脚本默认使用 `/tmp/kuzu_ldbc_<dataset>_*` 作为临时工作目录，导入成功或失败后会删除该目录。

## 脚本做了哪些处理

1. 从 `.tar.zst` 重新解压一份临时数据。
2. BI 的 `initial_snapshot` 文件在压缩包中是 `.csv.gz`，脚本只解压 snapshot 下的这些文件。
3. IC 原始 `HASCREATOR` 边没有 `creationDate` 列，脚本在临时副本中生成 `*.creation_date.csv`，不修改原目录。
4. BI 压缩包中的列顺序和现有已解压目录不同，例如 Person 是 `creationDate|id|...`。脚本在临时 `_kuzu_normalized` 目录里按 Kuzu DDL 需要的顺序生成 CSV。
5. 按 `tests/resources/ldbc/configs/graph.yaml` 和 `graph-bi.yaml` 建 Kuzu node/rel table。
6. 对每个输入 CSV 执行 `COPY`。
7. 导入完成后，对所有点表和边表执行 count 校验。

## Kuzu 0.10.0 需要注意的点

- 多端点关系表 COPY 时必须显式指定端点，例如：

```cypher
COPY HASCREATOR FROM '/path/comment_hasCreator.csv'
  (HEADER=true, DELIM='|', FROM='COMMENT', TO='PERSON');
```

- Kuzu 会根据文件扩展名判断输入类型。临时生成文件必须以 `.csv` 结尾，不能用 `.csv.creation_date` 这种后缀。
- Kuzu 的 `COPY` 按表 schema 的列顺序读取 CSV。BI 压缩包里的列顺序需要临时重排，不能直接按现有已解压目录的表头写文档。
- IC 的 `.rod` 排序文件是 NeuG loader 的性能优化，不是 Kuzu 导入必需项。Kuzu 导入使用原始 `post_0_0.csv` 和 `comment_0_0.csv`。

## 本次校验结果

IC:

```text
vertex PLACE: expected=1460 actual=1460
vertex PERSON: expected=9892 actual=9892
vertex COMMENT: expected=2052169 actual=2052169
vertex POST: expected=1003605 actual=1003605
vertex FORUM: expected=90492 actual=90492
vertex ORGANISATION: expected=7955 actual=7955
vertex TAGCLASS: expected=71 actual=71
vertex TAG: expected=16080 actual=16080
edge HASCREATOR: expected=3055774 actual=3055774
edge HASTAG: expected=3721417 actual=3721417
edge REPLYOF: expected=2052169 actual=2052169
edge CONTAINEROF: expected=1003605 actual=1003605
edge HASMEMBER: expected=1611869 actual=1611869
edge HASMODERATOR: expected=90492 actual=90492
edge HASINTEREST: expected=229166 actual=229166
edge ISLOCATEDIN: expected=3073621 actual=3073621
edge KNOWS: expected=180623 actual=180623
edge LIKES: expected=2190095 actual=2190095
edge WORKAT: expected=21654 actual=21654
edge ISPARTOF: expected=1454 actual=1454
edge HASTYPE: expected=16080 actual=16080
edge ISSUBCLASSOF: expected=70 actual=70
edge STUDYAT: expected=7949 actual=7949
```

BI:

```text
vertex PLACE: expected=1460 actual=1460
vertex PERSON: expected=10295 actual=10295
vertex COMMENT: expected=1739438 actual=1739438
vertex POST: expected=1121226 actual=1121226
vertex FORUM: expected=100827 actual=100827
vertex ORGANISATION: expected=7955 actual=7955
vertex TAGCLASS: expected=71 actual=71
vertex TAG: expected=16080 actual=16080
edge HASCREATOR: expected=2860664 actual=2860664
edge HASTAG: expected=3256648 actual=3256648
edge REPLYOF: expected=1739438 actual=1739438
edge CONTAINEROF: expected=1121226 actual=1121226
edge HASMEMBER: expected=2909768 actual=2909768
edge HASMODERATOR: expected=100827 actual=100827
edge HASINTEREST: expected=238052 actual=238052
edge ISLOCATEDIN: expected=2870959 actual=2870959
edge ORGANISATION_ISLOCATEDIN: expected=7955 actual=7955
edge KNOWS: expected=173014 actual=173014
edge LIKES: expected=1870268 actual=1870268
edge WORKAT: expected=22044 actual=22044
edge ISPARTOF: expected=1454 actual=1454
edge HASTYPE: expected=16080 actual=16080
edge ISSUBCLASSOF: expected=70 actual=70
edge STUDYAT: expected=8309 actual=8309
```

额外 read-only 查询确认：

```text
ic PERSON 9892 KNOWS 180623
bi PERSON 10295 KNOWS 173014
```
