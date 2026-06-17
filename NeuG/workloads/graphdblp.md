# NeuG GraphDBLP workload

- Database root: `/mnt/data/imported_data/incgq/graphdblp/neug-graphdblp-core-db`
- Parent directory: `/mnt/data/imported_data/incgq/graphdblp`
- Query directory: `/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/queries/graphdblp/distinct`
- Query files: 1591
- Runner: `/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-graphdblp.sh`

## Run

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-graphdblp.sh \
  --timeout 60 \
  --fetch-rows 1
```

Quick bounded run:

```bash
bash /root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/scripts/run-graphdblp.sh \
  --limit 1 \
  --timeout 20 \
  --fetch-rows 1
```

## Important Path Note

The usable GraphDBLP database is not the parent directory
`/mnt/data/imported_data/incgq/graphdblp`. The actual NeuG database with
`graph.yaml`, `checkpoint`, and `runtime` is:

```text
/mnt/data/imported_data/incgq/graphdblp/neug-graphdblp-core-db
```

The parent directory also contains NeuG-looking subdirectories, but opening the
parent produced an empty schema and query binding failures.

## Current Local Status

On 2026-06-12, the runner used the corrected nested database root, but opening
the database failed before query execution:

```text
query_dense_16_1.cypher: ERROR, child exited with code 6
underlying NeuG log: Failed to mmap vertex_table_publication.col_1.data, Cannot allocate memory
```

This indicates a local resource or mmap limit issue for the current machine, not
a query-directory mismatch. The schema in `neug-graphdblp-core-db/graph.yaml`
uses the same lower-case labels and relationships as the distinct query files:
`author`, `publication`, `venue`, `keyword`, `authored`, `contains`, and
`contributed_to`.
