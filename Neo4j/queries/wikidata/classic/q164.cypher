// q164; freq=1; rpq=<12>/(<3130>)*; readable=<P12>/(<P3130>)*
MATCH (s)-[:P12]->(m112_0_0)
MATCH (m112_0_0)-[:P3130*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
