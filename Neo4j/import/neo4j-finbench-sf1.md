# Neo4j FinBench SF1 导入流程

本文记录当前机器实测通过的 FinBench SF1 snapshot 导入 Neo4j 5.20.0 流程。

本次已经成功把 FinBench SF1 snapshot 数据导入到：

```text
/mnt/data/imported_data/neo4j/finbench/sf1/data/databases/neo4j
/mnt/data/imported_data/neo4j/finbench/sf1/data/transactions/neo4j
```

原始数据来源：

```text
/mnt/data/datasets/finbench/sf1.tar.gz
```

按要求，本次没有修改 `/mnt/data/datasets/finbench/sf1`。脚本从 tarball 新解压了一份到：

```text
/mnt/data/imported_data/neo4j/finbench/sf1/raw/sf1
```

## 1. 导入脚本

新增脚本：

```text
/root/workspace/IncGQ/IncGQ-experiment-docs/scripts/import_neo4j_finbench.py
```

该脚本不绑定 SF1，可用于同结构的其它 FinBench scale factor。脚本会：

1. 从 tarball 新解压，或读取已有 snapshot 目录。
2. 在目标目录下生成 Neo4j typed header 和转换后的 CSV 副本。
3. 用 `neo4j-admin database import full` 离线导入。
4. 可选执行 raw CSV 与 prepared CSV 行数验证。
5. 可选执行 `neo4j-admin database info/check`。
6. 可选删除 prepared CSV/header 副本，避免留下修改后的 CSV。

## 2. 关键映射

FinBench snapshot CSV 不是 Neo4j typed header，不能直接交给 `neo4j-admin`。

为兼容当前仓库的 `Neo4j/queries/finbench/*.cypher`，导入脚本做了这些映射：

| CSV 字段 | Neo4j 属性 |
| --- | --- |
| `personId`, `companyId`, `accountId`, `loanId`, `mediumId` | `id` |
| `personName`, `companyName` | `name` |
| `accoutType` | `type` |
| 关系 CSV 中的 `createTime` | `timestamp` |
| `mediumType` | `type` |

注意：

1. FinBench 里部分 ID 大于 Neo4j `--id-type=INTEGER` 可接受范围。本脚本使用 `--id-type=STRING` 作为 Neo4j 内部导入 ID，同时额外保留节点属性 `id:LONG`，因此查询仍可用数值 ID。
2. `createTime/timestamp/birthday` 当前按 `STRING` 导入，不按 Neo4j temporal 类型导入。当前查询直接做 `$start_time < edge.timestamp < $end_time`，因此参数也应使用相同格式的字符串时间。
3. `invest` 边保留 `ratio`，同时增加 `amount=ratio` 别名属性，用于兼容当前 `tcr-11.cypher` 中的 `e.amount`/`inv.amount` 访问。

Neo4j 关系类型采用当前查询使用的小写类型：

| CSV 文件 | Neo4j 关系类型 |
| --- | --- |
| `PersonOwnAccount.csv`, `CompanyOwnAccount.csv` | `own` |
| `PersonApplyLoan.csv`, `CompanyApplyLoan.csv` | `apply` |
| `PersonGuaranteePerson.csv`, `CompanyGuaranteeCompany.csv` | `guarantee` |
| `PersonInvestCompany.csv`, `CompanyInvestCompany.csv` | `invest` |
| `AccountTransferAccount.csv` | `transfer` |
| `AccountWithdrawAccount.csv` | `withdraw` |
| `AccountRepayLoan.csv` | `repay` |
| `LoanDepositAccount.csv` | `deposit` |
| `MediumSignInAccount.csv` | `signIn` |

## 3. 导入命令

本次复用了已下载的 Neo4j 5.20.0 和 Java 17 JRE：

```bash
export FINBENCH_ARCHIVE=/mnt/data/datasets/finbench/sf1.tar.gz
export NEO4J_FINBENCH_TARGET=/mnt/data/imported_data/neo4j/finbench/sf1
export NEO4J_HOME=/mnt/data/imported_data/neo4j/bi-sf1/tools/neo4j-community-5.20.0
export JAVA_HOME_17=/mnt/data/imported_data/neo4j/bi-sf1/tools/jdk-17.0.19+10-jre
```

执行导入：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_finbench.py \
  --archive "$FINBENCH_ARCHIVE" \
  --extract-dir "$NEO4J_FINBENCH_TARGET/raw" \
  --overwrite-extract \
  --target-dir "$NEO4J_FINBENCH_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --heap-size 8G \
  --validate-counts \
  --check \
  --cleanup-prepared
```

`--cleanup-prepared` 会在导入和检查结束后删除：

```text
/mnt/data/imported_data/neo4j/finbench/sf1/prepared-csv
/mnt/data/imported_data/neo4j/finbench/sf1/prepared-headers
```

因此导入时需要的修改版 CSV 只作为目标目录下的临时副本存在，不会影响原始 CSV。

## 4. 本次导入结果

Neo4j import 输出：

```text
IMPORT DONE in 12s 527ms.
Imported:
  556082 nodes
  3101291 relationships
  13807900 properties
Peak memory usage: 1.038GiB
```

离线检查结果：

```text
Store needs recovery: false
neo4j-admin database check neo4j: exit code 0
```

目标目录大小：

```text
1.9G  /mnt/data/imported_data/neo4j/finbench/sf1/raw
729M  /mnt/data/imported_data/neo4j/finbench/sf1/data
0     /mnt/data/imported_data/neo4j/finbench/sf1/import.report
```

本次没有启动 Neo4j server，也没有执行 FinBench 查询套件；这里只验证了离线导入、store info 和 consistency check。

## 5. 点数和边数

### 5.1 点 label 计数

| Label | Count |
| --- | ---: |
| Account | 204771 |
| Company | 38857 |
| Loan | 137811 |
| Medium | 96972 |
| Person | 77671 |

点总数：

```text
556082
```

### 5.2 关系 type 计数

| Type | Count |
| --- | ---: |
| apply | 137811 |
| deposit | 272417 |
| guarantee | 56722 |
| invest | 205880 |
| own | 204771 |
| repay | 263972 |
| signIn | 258056 |
| transfer | 794180 |
| withdraw | 907482 |

关系总数：

```text
3101291
```

## 6. CSV 行数验证

本次验证已经通过。验证口径：

1. raw CSV 使用 Python CSV parser 读取，扣除 header row 后作为原始数据行数。
2. prepared CSV 是无表头导入副本，行数直接等于导入输入行数。
3. 若任一表 `raw_data_rows != prepared_rows`，脚本返回非 0。

逐表验证结果：

| CSV | raw_data_rows | prepared_rows |
| --- | ---: | ---: |
| Person.csv | 77671 | 77671 |
| Company.csv | 38857 | 38857 |
| Account.csv | 204771 | 204771 |
| Loan.csv | 137811 | 137811 |
| Medium.csv | 96972 | 96972 |
| PersonOwnAccount.csv | 136526 | 136526 |
| CompanyOwnAccount.csv | 68245 | 68245 |
| PersonApplyLoan.csv | 92078 | 92078 |
| CompanyApplyLoan.csv | 45733 | 45733 |
| PersonGuaranteePerson.csv | 37883 | 37883 |
| CompanyGuaranteeCompany.csv | 18839 | 18839 |
| PersonInvestCompany.csv | 137839 | 137839 |
| CompanyInvestCompany.csv | 68041 | 68041 |
| AccountTransferAccount.csv | 794180 | 794180 |
| AccountWithdrawAccount.csv | 907482 | 907482 |
| AccountRepayLoan.csv | 263972 | 263972 |
| LoanDepositAccount.csv | 272417 | 272417 |
| MediumSignInAccount.csv | 258056 | 258056 |

关键输出：

```text
Node input total: 556082
Relationship input total: 3101291
Count validation passed.
```

如果导入后已经用 `--cleanup-prepared` 删除了 prepared CSV，想单独重新验证，可重新生成 prepared 副本并跳过导入：

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_finbench.py \
  --data-dir "$NEO4J_FINBENCH_TARGET/raw/sf1/snapshot" \
  --target-dir "$NEO4J_FINBENCH_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --skip-import \
  --validate-counts \
  --cleanup-prepared
```

## 7. 只重新检查数据库

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs

python3 scripts/import_neo4j_finbench.py \
  --data-dir "$NEO4J_FINBENCH_TARGET/raw/sf1/snapshot" \
  --target-dir "$NEO4J_FINBENCH_TARGET" \
  --neo4j-home "$NEO4J_HOME" \
  --java-home "$JAVA_HOME_17" \
  --skip-prepare \
  --skip-import \
  --check
```
