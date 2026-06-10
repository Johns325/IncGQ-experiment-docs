// q166; freq=1; rpq=<12>/(<586>)*; readable=<P12>/(<P586>)*
MATCH (s)-[:P12]->(m79_0_0)
MATCH (m79_0_0)-[:P586*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
