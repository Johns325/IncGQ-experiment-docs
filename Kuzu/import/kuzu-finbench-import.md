# FinBench SF1 导入 Kuzu

本文档记录已验证过的 FinBench SF1 snapshot 导入 Kuzu 流程。验证环境中 `kuzu` Python 包版本为 `0.10.0`。

目标库目录：

```bash
/mnt/data/imported_data/kuzu/finbench
```

导入脚本：

```bash
scripts/import_ldbc_to_kuzu.py
```

该脚本现在支持 `ic`、`bi`、`lsqb`、`graphdblp`、`finbench`。

## 数据源

用户给出的已解压 CSV 目录是：

```bash
/mnt/data/datasets/finbench/sf1
```

本次导入没有直接使用该目录，而是按要求从压缩包重新解压临时副本：

```bash
/mnt/data/datasets/finbench/sf1.tar.gz
```

导入使用的是解压后 `sf1/snapshot` 下的 CSV，不使用 `raw` 或 `incremental` 目录。

Schema 和 import 映射来自：

```bash
tests/resources/finbench/configs/graph-finbench.yaml
tests/resources/finbench/configs/import-finbench-sf1.yaml
```

## 已验证导入命令

```bash
python3 scripts/import_ldbc_to_kuzu.py finbench
```

如果目标目录已有半成品或旧库，使用：

```bash
python3 scripts/import_ldbc_to_kuzu.py finbench --overwrite
```

脚本默认使用 `/tmp/kuzu_import_finbench_*` 作为临时工作目录。它会在临时 `sf1/snapshot/_kuzu_normalized` 下生成 Kuzu 专用 CSV；导入成功或失败后会删除临时目录。

## 脚本做了哪些处理

1. 从 `sf1.tar.gz` 解压一份新的临时副本。
2. 按 `graph-finbench.yaml` 创建 5 个 Kuzu node table 和 13 个 rel table。
3. 按 `import-finbench-sf1.yaml` 的 `column_mappings`、`source_vertex_mappings`、`destination_vertex_mappings` 生成临时 `_kuzu_normalized` CSV。
4. 对每个输入 CSV 执行 `COPY ... (HEADER=true, DELIM='|', FROM='...', TO='...')`。
5. 导入完成后逐表执行 count 校验。

## 已纠正的点

- FinBench SF1 应使用 `sf1/snapshot` 目录。`raw` 是多分片原始数据，`incremental` 是增量操作文件，都不是本次 Kuzu snapshot 导入输入。
- Kuzu 0.10.0 可以直接解析 FinBench 的 `false`/`true` bool 和 `2020-01-01 00:06:01.273` timestamp 格式。
- `AccountTransferAccount.orderNum` 在 schema 中是 `INT64`，但 CSV 中存在前导零，例如 `001420001959935`。Kuzu 0.10.0 不接受带前导零的整数文本，因此脚本只在临时 `_kuzu_normalized` CSV 中去掉整数列前导零；原始 CSV 不修改。
- 已扫描 snapshot CSV，未发现未转义 `|` 导致的错列问题。

## 本次校验结果

逐表 count 校验：

```text
vertex Person: expected=77671 actual=77671
vertex Company: expected=38857 actual=38857
vertex Account: expected=204771 actual=204771
vertex Loan: expected=137811 actual=137811
vertex Medium: expected=96972 actual=96972
edge PersonOwnAccount: expected=136526 actual=136526
edge CompanyOwnAccount: expected=68245 actual=68245
edge PersonApplyLoan: expected=92078 actual=92078
edge CompanyApplyLoan: expected=45733 actual=45733
edge PersonGuaranteePerson: expected=37883 actual=37883
edge CompanyGuaranteeCompany: expected=18839 actual=18839
edge PersonInvestCompany: expected=137839 actual=137839
edge CompanyInvestCompany: expected=68041 actual=68041
edge AccountTransferAccount: expected=794180 actual=794180
edge AccountWithdrawAccount: expected=907482 actual=907482
edge AccountRepayLoan: expected=263972 actual=263972
edge LoanDepositAccount: expected=272417 actual=272417
edge MediumSignInAccount: expected=258056 actual=258056
```

额外 read-only 查询确认：

```text
MATCH (p:Person) RETURN count(p); 77671
MATCH (a:Account) RETURN count(a); 204771
MATCH ()-[r:AccountTransferAccount]->() RETURN count(r); 794180
MATCH ()-[r:AccountWithdrawAccount]->() RETURN count(r); 907482
```

导入后库大小：

```text
338M /mnt/data/imported_data/kuzu/finbench
```
