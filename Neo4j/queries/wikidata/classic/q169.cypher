// q169; freq=1; rpq=<12>/(<949>)*; readable=<P12>/(<P949>)*
MATCH (s)-[:P12]->(m123_0_0)
MATCH (m123_0_0)-[:P949*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
