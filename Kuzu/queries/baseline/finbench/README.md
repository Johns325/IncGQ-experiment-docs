# FinBench Kuzu query validation status

This directory was copied from `Neo4j/queries/finbench` and adapted for Kuzu 0.10.0 against:

`/mnt/data/imported_data/kuzu/finbench`

The imported Kuzu schema does not use the short Neo4j relationship names. Important mappings:

| Neo4j relationship | Kuzu relationship |
| --- | --- |
| `own` | `PersonOwnAccount` or `CompanyOwnAccount` |
| `transfer` | `AccountTransferAccount` |
| `withdraw` | `AccountWithdrawAccount` |
| `deposit` | `LoanDepositAccount` |
| `repay` | `AccountRepayLoan` |
| `signIn` | `MediumSignInAccount` |
| `apply` | `PersonApplyLoan` or `CompanyApplyLoan` |
| `invest` | `PersonInvestCompany` or `CompanyInvestCompany` |
| `guarantee` | `PersonGuaranteePerson` or `CompanyGuaranteeCompany` |

Time parameters such as `$start_time`, `$end_time`, and `$currentTime` should be passed as Python `datetime.datetime` values through the Kuzu Python API.

## Executed read queries

The following read queries were executed on the real imported Kuzu database with existing ids and a wide 2020-2030 timestamp window:

| Query | Status | Validation result |
| --- | --- | --- |
| `tsr-1.cypher` | OK | 1 row, 0.121s |
| `tsr-2.cypher` | OK | 1 row, 0.559s |
| `tsr-3.cypher` | OK | 1 row, 0.145s |
| `tsr-4.cypher` | OK | 3 rows, 0.066s |
| `tsr-5.cypher` | OK | 8 rows, 0.071s |
| `tsr-6.cypher` | OK | 1 row, 0.085s |
| `tsr-7.cypher` | OK | 1 row, 0.134s |
| `tcr-4.cypher` | OK | 1 default row for the validation params, 0.108s |
| `tcr-6.cypher` | OK | 0 rows, 0.343s |
| `tcr-7.cypher` | OK | 1 row, 0.121s |
| `tcr-9.cypher` | OK | 1 row, 0.218s |
| `tcr-10.cypher` | OK | 1 row, 0.124s |
| `tcr-13.cypher` | OK | 0 rows, 0.177s |

Notes:

- `tcr-10` replaces Neo4j GDS `gds.similarity.jaccard` with explicit intersection/union counting.
- `tcr-4` was rewritten with `OPTIONAL MATCH`/`coalesce` to preserve the Neo4j default row behavior when no matching transfer pattern exists.
- Numeric rounding uses Kuzu's two-argument form: `round(value, 3)`.

## Executed write queries

The `tw-*` queries were not executed on `/mnt/data/imported_data/kuzu/finbench`. To avoid mutating the imported database, the database was copied to a temporary `/tmp/kuzu-finbench-tw-*` directory and all write queries were executed there.

All 15 write queries executed successfully on the temporary copy:

`tw-1`, `tw-2`, `tw-3`, `tw-4`, `tw-5`, `tw-6`, `tw-7`, `tw-8`, `tw-9`, `tw-10`, `tw-11`, `tw-12`, `tw-13`, `tw-14`, `tw-15`.

One source-query issue was corrected during adaptation:

- `tw-6.cypher` originally matched `(c:Company ...)` but created the loan from undefined variable `(p)`. The Kuzu version uses `(c)`.

## Additional FinBench fixes

The following queries were fixed and executed on `/mnt/data/imported_data/kuzu/finbench` with the first row from their default parameter files:

| Query | Status | Validation result |
| --- | --- | --- |
| `tcr-1.cypher` | OK | execute row 1, 0.86s |
| `tcr-2.cypher` | OK | execute row 1, 5.05s |
| `tcr-5.cypher` | OK | execute row 1, 40.79s |
| `tcr-6.cypher` | OK | execute row 1, 0.45s |
| `tcr-7.cypher` | OK | execute row 1, 0.28s |
| `tcr-8.cypher` | OK | execute row 1, 6.52s |
| `tcr-11.cypher` | OK | execute row 1, 0.99s |
| `tcr-12.cypher` | OK | execute row 1, 0.50s |
| `tsr-8.cypher` | OK | execute row 1, 0.49s |

Notes on the rewrites:

- `tcr-1` and `tcr-5` manually unroll 1/2/3-hop `AccountTransferAccount` paths because Kuzu 0.10 cannot use `relationships(path)` to inspect recursive edge properties.
- `tcr-2` uses `EXISTS` checks for ordered 1/2/3-hop reverse-transfer reachability and aggregates each reachable account's loans once. This avoids Kuzu's lack of post-`UNION` aggregation.
- `tcr-8` uses a runnable 2-hop truncation. The full 3-hop `transfer|withdraw` expansion timed out on SF1 in Kuzu 0.10 even after splitting relationship alternatives; the original query already carried a truncation TODO.
- `tcr-11` uses the imported `ratio` property on `PersonInvestCompany` and `CompanyInvestCompany`; the Neo4j query's `apoc.coll.sum`/`amount` formula cannot bind against this Kuzu schema because investment edges store `ratio`, not `amount`.
- `tcr-12` manually unrolls 1/2/3-hop `PersonGuaranteePerson` paths and aggregates loan amounts after each hop.
- `tsr-8` returns `p2Id` as an empty list because this Kuzu FinBench import has no `workIn` relationship table.

Final validation command used:

```bash
for q in tcr-1 tcr-2 tcr-5 tcr-6 tcr-7 tcr-8 tcr-11 tcr-12 tsr-8; do
  Kuzu/scripts/run-finbench-sf1.sh --query "$q" --mode execute --param-count 1 --timeout 60 --fetch-rows 3 --out "/tmp/kuzu-$q-execute-final.csv"
done
```
