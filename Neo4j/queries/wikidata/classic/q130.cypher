// q130; freq=1; rpq=(<308>/<12>)/(<196>)*; readable=(<P308>/<P12>)/(<P196>)*
MATCH (s)-[:P308]->(m155_0_0)
MATCH (m155_0_0)-[:P12]->(m155_0_1)
MATCH (m155_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
