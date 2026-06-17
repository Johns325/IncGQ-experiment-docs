# Kuzu GraphDBLP workload

GraphDBLP is currently wired only through the legacy smoke runner, not through `Kuzu/run-kuzu-baseline.py` or `Kuzu/run-kuzu-optimization.py`.

Legacy wrapper:

```bash
/root/workspace/IncGQ/IncGQ-experiment-docs/Kuzu/scripts/run-graphdblp.sh
```

Database:

```text
/mnt/data/imported_data/kuzu/graphdblp
```

Query directory:

```text
/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/queries/graphdblp/distinct
```

The legacy runner uses the deduplicated GraphDBLP query set produced under `NeuG/queries/graphdblp/distinct`.

Examples:

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
Kuzu/scripts/run-graphdblp.sh --query query_dense_16_1.cypher --mode explain --timeout 30
Kuzu/scripts/run-graphdblp.sh --mode explain --start-at 1 --limit 10 --timeout 30
```

`execute` mode is disabled for GraphDBLP in the legacy Kuzu runner; use `--mode explain`.

Validation note from the previous local check:

```text
query_dense_16_1.cypher --mode explain --timeout 30: TIMEOUT
```

That result confirmed the wrapper resolved the query set and wrote CSV, but the selected query did not finish planning within 30 seconds on that Kuzu setup.
