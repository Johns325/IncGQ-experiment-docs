# Wikidata RPQ queries for Neo4j

Source workload: `/home/glaucus/workspace/dataset/wikidata/queries.txt`.

This directory contains the subset of the Wikidata RPQ workload that can be represented as Neo4j Cypher queries using relationship types named `P<id>` such as `P12`, `P196`, and `P412`.

Files:

- `classic/unbounded_classic.cypher`: all classic-Cypher translations in one file.
- `classic/q001.cypher` ... `classic/q204.cypher`: the same classic translations split one query per file.
- `union/unbounded_union.cypher`: all `UNION`-based translations in one file.
- `union/q001.cypher` ... `union/q025.cypher`: the same `UNION` translations split one query per file.
- `meta/unbounded_all_unique.tsv`: all unique unbounded RPQ queries with frequency and category.
- `meta/unbounded_complex_needs_rpq.txt`: unbounded RPQ queries not translated to classic executable Cypher because they require repeating path fragments or nested regular operators.
- `meta/query_labels_P.txt`: property labels appearing in the query workload, formatted as `P<id>`.

Summary:

- total workload queries: 1930
- unbounded query occurrences: 1637
- unique unbounded queries: 244
- classic Cypher unique queries: 204
- UNION Cypher unique queries: 25
- complex RPQ not translated: 15

Each generated query returns reachable endpoint IDs:

```cypher
RETURN DISTINCT id(s) AS src, id(t) AS dst;
```

Note: Neo4j variable-length path semantics can differ from automaton-based RPQ evaluation on cyclic graphs, especially when repeated relationships are involved.
