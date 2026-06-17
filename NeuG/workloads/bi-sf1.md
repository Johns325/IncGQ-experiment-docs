# NeuG BI SF1 workload

- Database: `/mnt/data/imported_data/incgq/bi-sf1`
- Query directory: `/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/queries/ldbc-bi`
- Query files: 60
- Runner: `/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-bi-sf1.sh`

## Run

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-bi-sf1.sh \
  --timeout 60 \
  --fetch-rows 5
```

Quick smoke run:

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-bi-sf1.sh \
  --limit 1 \
  --timeout 20 \
  --fetch-rows 1
```

## Query Templates And Setup Files

Several BI query files contain literal `{}` placeholders instead of `$param`
parameters. The runner fills these with fixed smoke-test values. It replaces
only the literal `{}` tokens, so Cypher map syntax such as `{name: ...}` is not
treated as a Python format field.

The BI directory also includes setup/drop/fill files. The default run excludes
known setup files and skips write queries unless `--allow-writes` is set. Use
`--include-setup --mode execute --allow-writes` only on a database copy when you
intend to modify the database.

## Verified Locally

On 2026-06-12:

```text
bi11/query.cypher: OK, 10.304s, first row [847]
```
