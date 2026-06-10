// q96; freq=1; rpq=(<12>/<196>)/(<31>)*; readable=(<P12>/<P196>)/(<P31>)*
MATCH (s)-[:P12]->(m207_0_0)
MATCH (m207_0_0)-[:P196]->(m207_0_1)
MATCH (m207_0_1)-[:P31*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
