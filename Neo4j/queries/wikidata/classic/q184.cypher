// q184; freq=1; rpq=<304>/(<1341>)*; readable=<P304>/(<P1341>)*
MATCH (s)-[:P304]->(m231_0_0)
MATCH (m231_0_0)-[:P1341*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
