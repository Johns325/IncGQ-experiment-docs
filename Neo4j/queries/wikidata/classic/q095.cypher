// q95; freq=1; rpq=(<12>/<12>)/(<196>)*; readable=(<P12>/<P12>)/(<P196>)*
MATCH (s)-[:P12]->(m236_0_0)
MATCH (m236_0_0)-[:P12]->(m236_0_1)
MATCH (m236_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
