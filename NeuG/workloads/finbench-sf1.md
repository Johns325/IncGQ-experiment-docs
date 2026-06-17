# NeuG FinBench SF1 workload

- Database: `/mnt/data/imported_data/incgq/finbench-sf1`
- Query directory: `/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/queries/finbench/finbench-adapted-queries`
- Query files: 36
- Runner: `/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-finbench-sf1.sh`

## Run

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-finbench-sf1.sh \
  --timeout 60 \
  --fetch-rows 5
```

Quick smoke run:

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-finbench-sf1.sh \
  --limit 1 \
  --timeout 20 \
  --fetch-rows 1
```

## Read And Write Queries

FinBench contains read queries (`tcr-*`, `tsr-*`) and transaction/write queries
(`tw-*`). The default run opens the database read-only and skips write queries.

To execute write queries, use a copied database and run:

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-finbench-sf1.sh \
  --mode execute \
  --allow-writes \
  --db-dir /path/to/copied/finbench-sf1 \
  --timeout 60
```

The runner injects fixed smoke-test parameters for `$id`, `$start_time`,
`$end_time`, thresholds, account IDs, and write-query values.

## Verified Locally

On 2026-06-12:

```text
tcr-1.cypher: OK, 0.428s, zero rows
```
