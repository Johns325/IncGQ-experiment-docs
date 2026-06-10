// q133; freq=1; rpq=(<338>/<12>)/(<196>)*; readable=(<P338>/<P12>)/(<P196>)*
MATCH (s)-[:P338]->(m72_0_0)
MATCH (m72_0_0)-[:P12]->(m72_0_1)
MATCH (m72_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
