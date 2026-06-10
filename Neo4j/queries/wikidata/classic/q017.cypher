// q17; freq=10; rpq=<289>/(<412>)*; readable=<P289>/(<P412>)*
MATCH (s)-[:P289]->(m20_0_0)
MATCH (m20_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
