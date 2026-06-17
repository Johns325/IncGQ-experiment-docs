# Neo4j materializations for NeuG/Kuzu-aligned optimization

These scripts align with `Kuzu/queries/index`. They are not native Neo4j schema indexes; they materialize derived properties or helper relationships used by `Neo4j/queries/optimized`.

`Neo4j/run-neo4j-optimization.py` runs the matching `queries/index/<dataset>/<query>/index.cypher` once before each optimized query. Setup time is recorded in the detail CSV as `phase=index_setup` and excluded from summary timing.
