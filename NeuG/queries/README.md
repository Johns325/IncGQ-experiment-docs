# NeuG query layout

This directory keeps the original legacy query directories and adds a normalized
layout for benchmark runners:

- `baseline/<dataset>/<query>/...`: baseline query text.
- `index/<dataset>/<query>/index.cypher`: NeuG index/materialization setup.
- `optimization/<dataset>/<query>/...`: query text used after the index setup.

The normalized IC/BI/LSQB files are copied from
`/root/workspace/neug/examples/cpp/query_templates`.

Important conventions:

- Some NeuG optimized cases use the same Cypher text as baseline; the index is
  what enables NeuG's rewrite. Those queries appear in both `baseline` and
  `optimization`.
- LSQB `q5`, `q6`, `q8`, and `q9` have no `index.cypher` in the template source,
  so they are baseline-only in the normalized layout.
- BI15 and BI19 keep `baseline_weight.cypher` beside the baseline query because
  the C++ benchmark uses it as a baseline prequery. It is not the measured query
  itself.
- The existing `finbench` and `graphdblp` query directories are intentionally
  left unchanged.
