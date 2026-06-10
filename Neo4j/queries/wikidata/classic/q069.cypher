// q69; freq=2; rpq=<12>/(<4377>)*; readable=<P12>/(<P4377>)*
MATCH (s)-[:P12]->(m64_0_0)
MATCH (m64_0_0)-[:P4377*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
