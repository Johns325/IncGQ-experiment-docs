// q68; freq=2; rpq=<12>/(<12>)*; readable=<P12>/(<P12>)*
MATCH (s)-[:P12]->(m99_0_0)
MATCH (m99_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
