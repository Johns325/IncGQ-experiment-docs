// q167; freq=1; rpq=<12>/(<612>)*; readable=<P12>/(<P612>)*
MATCH (s)-[:P12]->(m183_0_0)
MATCH (m183_0_0)-[:P612*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
