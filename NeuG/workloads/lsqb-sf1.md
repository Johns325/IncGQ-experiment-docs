# NeuG LSQB SF1 workload

- Database: `/mnt/data/imported_data/incgq/lsqb-sf1`
- Query directory: `/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/queries/lsqb`
- Query files: 9
- Runner: `/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-lsqb-sf1.sh`

## Run

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-lsqb-sf1.sh \
  --timeout 300 \
  --fetch-rows 5
```

Quick bounded run:

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-lsqb-sf1.sh \
  --limit 1 \
  --timeout 30 \
  --fetch-rows 1
```

## Current Local Status

On 2026-06-12, the database opened successfully, but these bounded smoke checks
did not finish within the selected timeout:

```text
q1/query.cypher: TIMEOUT at 5s
q9/query.cypher: TIMEOUT at 20s
```

Use a larger `--timeout` for full execution. The current runner has no separate
parse-only mode because the verified NeuG Python API executes the query.
