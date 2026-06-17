# Neo4j GraphDBLP Workload

Script:

```bash
/root/workspace/IncGQ/IncGQ-experiment-docs/Neo4j/scripts/run-graphdblp.sh
```

Database:

```text
/mnt/data/imported_data/neo4j/graphdblp
```

Queries:

```text
/root/workspace/IncGQ/IncGQ-experiment-docs/NeuG/queries/graphdblp/distinct
```

Recommended batch smoke run:

```bash
cd /root/workspace/IncGQ/IncGQ-experiment-docs
Neo4j/scripts/run-graphdblp.sh --mode explain --limit 200 --timeout 60
```

Continue from a later query:

```bash
Neo4j/scripts/run-graphdblp.sh --mode explain --start-at 201 --limit 100 --timeout 60
```

The runner intentionally disables `execute` mode for GraphDBLP. These are subgraph-counting patterns over a large DBLP graph, and full `RETURN count(*)` execution can be extremely expensive.

The GraphDBLP queries use Neo4j 5 relationship-union syntax:

```cypher
[r:authored|contains|contributed_to]
```

The old generated form `[r:authored|:contains|:contributed_to]` is invalid in Neo4j 5 and has been corrected in the generated and distinct query files.

The runner prefixes GraphDBLP checks with:

```cypher
CYPHER connectComponentsPlanner=greedy EXPLAIN
```

Even with this option, larger dense queries such as some `dense_16` patterns can hit planner timeouts. Treat planner timeout as a performance/planner limitation, not as a Cypher syntax error.
