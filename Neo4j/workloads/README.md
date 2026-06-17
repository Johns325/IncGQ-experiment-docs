# Neo4j workload notes

The recommended benchmark entry points are documented in `Neo4j/README.md`:

```text
Neo4j/run-neo4j-baseline.py
Neo4j/run-neo4j-optimization.py
```

This directory keeps workload-specific notes plus documentation for the legacy smoke wrappers in `Neo4j/scripts/run-*.sh`.

## Legacy wrapper mapping

| Workload | Wrapper | Database | Query directory |
| --- | --- | --- | --- |
| `ic-sf1` | `Neo4j/scripts/run-ic-sf1.sh` | `/mnt/data/imported_data/neo4j/ic-sf1` | `Neo4j/queries/baseline/ldbc-ic` |
| `bi-sf1` | `Neo4j/scripts/run-bi-sf1.sh` | `/mnt/data/imported_data/neo4j/bi-sf1` | `Neo4j/queries/baseline/ldbc-bi` |
| `lsqb-sf1` | `Neo4j/scripts/run-lsqb-sf1.sh` | `/mnt/data/imported_data/neo4j/lsqb/sf1` | `Neo4j/queries/baseline/lsqb` |
| `finbench-sf1` | `Neo4j/scripts/run-finbench-sf1.sh` | `/mnt/data/imported_data/neo4j/finbench/sf1` | `Neo4j/queries/baseline/finbench` |
| `graphdblp` | `Neo4j/scripts/run-graphdblp.sh` | `/mnt/data/imported_data/neo4j/graphdblp` | `NeuG/queries/graphdblp/distinct` |

The wrappers call `Neo4j/scripts/run-workload.py`. Its default runner is `isolated`, so it is useful for smoke checks but not the current benchmark timing method. Use `--runner persistent` only when intentionally using the legacy runner with one Bolt session.

Formal benchmark output matches Kuzu:

```text
/mnt/data/results/neo4j/<baseline-or-optimization>/<workload>/<query-set>-<timestamp>-results.csv
/mnt/data/results/neo4j/<baseline-or-optimization>/<workload>/<query-set>-<timestamp>-summary.csv
/mnt/data/results/neo4j/<baseline-or-optimization>/<workload>/<query-set>-<timestamp>-summary-wide.csv
```

Detail CSV fields:

```text
query,sample_round,phase,iteration,parameter_index,parameters,results,time_seconds,setup_time_seconds
```
