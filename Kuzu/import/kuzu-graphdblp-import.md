# GraphDBLP Core 导入 Kuzu

本文档记录已验证过的 GraphDBLP core 导入 Kuzu 流程。验证环境中 `kuzu` Python 包版本为 `0.10.0`。

目标库目录：

```bash
/mnt/data/imported_data/kuzu/graphdblp
```

导入脚本：

```bash
scripts/import_ldbc_to_kuzu.py
```

该脚本现在支持 `ic`、`bi`、`lsqb`、`graphdblp`。

## 数据源和转换产物

GraphDBLP 比 LDBC/LSQB 特殊：用户给出的目录不是可直接导入的图 CSV，而是原始 DBLP XML 和关键词表：

```bash
/mnt/data/datasets/graphdblp/dblp.xml.gz
/mnt/data/datasets/graphdblp/dblp.dtd
/mnt/data/datasets/graphdblp/dblp.xml.gz.md5
/mnt/data/datasets/graphdblp/keywords.csv
```

本机已经有之前完成过的 GraphDBLP core 转换产物：

```bash
/mnt/data/datasets/lsqb/dblp-neug-csv
/mnt/data/datasets/lsqb/dblp-neug-pipe-csv
```

Kuzu 本次导入使用的是 pipe 分隔的转换产物：

```bash
/mnt/data/datasets/lsqb/dblp-neug-pipe-csv
```

原因：原始 DBLP XML 需要先解析为 GraphDBLP core 图 CSV；逗号 CSV 中标题、venue 等字段可能包含逗号，已转换的 pipe CSV 更适合当前 Kuzu/NeuG 共用的导入路径。

原始 XML 校验已确认：

```text
dblp.xml.gz: OK
```

## Schema 和映射

使用已有 GraphDBLP core 配置：

```bash
tests/resources/graphdblp/configs/graph-graphdblp-core.yaml
tests/resources/graphdblp/configs/import-graphdblp-core.yaml
```

Schema 包含 4 个点表：

```text
author
publication
venue
keyword
```

包含 3 个边表：

```text
authored
contains
contributed_to
```

## 已验证导入命令

```bash
python3 scripts/import_ldbc_to_kuzu.py graphdblp
```

如果目标目录已有半成品或旧库，使用：

```bash
python3 scripts/import_ldbc_to_kuzu.py graphdblp --overwrite
```

脚本默认使用 `/tmp/kuzu_import_graphdblp_*` 作为临时工作目录。它会把已有 pipe CSV 以只读方式挂到临时目录，并在临时 `_kuzu_normalized` 下生成 Kuzu 专用 CSV；导入成功或失败后会删除临时目录。

## 已纠正的点

- `/mnt/data/datasets/graphdblp` 不是直接可 COPY 的图 CSV 目录；它是 DBLP XML、DTD、MD5 和关键词表所在目录。
- 本次没有重新从 XML 解析，因为已有转换产物 `/mnt/data/datasets/lsqb/dblp-neug-pipe-csv` 已存在且完整。若该目录不存在，应先按 [GraphDBLP 导入 NeuG 指南](graphdblp-import-jcloud.md) 从 XML 生成 core CSV。
- `publication.year` 有空值。小样本验证 Kuzu 0.10.0 默认会把空整数列导成 NULL，因此不需要把原 CSV 改写成特殊哨兵值。
- 不修改 `/mnt/data/datasets/graphdblp` 或 `/mnt/data/datasets/lsqb/dblp-neug-pipe-csv`。所有 Kuzu 表头规范化都发生在临时 `_kuzu_normalized` 目录。
- GraphDBLP 数据量较大，临时规范化阶段会先写出约 6.3G 的临时 CSV，因此不会像 LSQB 那样很快开始打印 DDL/COPY 输出。

## 本次校验结果

逐表 count 校验：

```text
vertex author: expected=4229058 actual=4229058
vertex publication: expected=12690688 actual=12690688
vertex venue: expected=24471 actual=24471
vertex keyword: expected=1173 actual=1173
edge authored: expected=33543471 actual=33543471
edge contains: expected=16508186 actual=16508186
edge contributed_to: expected=17106111 actual=17106111
```

额外 read-only 查询确认：

```text
MATCH (a:author) RETURN count(a); 4229058
MATCH (p:publication) RETURN count(p); 12690688
MATCH ()-[r:authored]->() RETURN count(r); 33543471
MATCH ()-[r:contains]->() RETURN count(r); 16508186
```

导入后库大小：

```text
5.4G /mnt/data/imported_data/kuzu/graphdblp
```
