# NeuG IC SF1 workload

- Database: `/mnt/data/imported_data/incgq/ic-sf1`
- Query directory: `/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/queries/ldbc-ic`
- Query files: 14
- Runner: `/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-ic-sf1.sh`

## Run

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-ic-sf1.sh \
  --timeout 60 \
  --fetch-rows 5
```

Quick smoke run:

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-ic-sf1.sh \
  --limit 1 \
  --timeout 20 \
  --fetch-rows 1
```

## Parameters

The IC query files use `$personId`, `$firstName`, date, country, and tag
parameters. The runner injects fixed smoke-test values in
`scripts/run-workload.py`. Replace those values in the runner if benchmark-grade
substitution parameters are required.

## Verified Locally

On 2026-06-12:

```text
ic1/interactive-complex-1.cypher: OK, 7.220s
```
