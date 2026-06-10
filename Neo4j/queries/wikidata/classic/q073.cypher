// q73; freq=2; rpq=<586>/(<412>)*; readable=<P586>/(<P412>)*
MATCH (s)-[:P586]->(m176_0_0)
MATCH (m176_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
