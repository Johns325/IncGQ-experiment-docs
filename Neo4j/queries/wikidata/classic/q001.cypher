// q1; freq=438; rpq=<12>/(<196>)*; readable=<P12>/(<P196>)*
MATCH (s)-[:P12]->(m2_0_0)
MATCH (m2_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
