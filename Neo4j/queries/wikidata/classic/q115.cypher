// q115; freq=1; rpq=(<196>/<12>)/(<196>)*; readable=(<P196>/<P12>)/(<P196>)*
MATCH (s)-[:P196]->(m159_0_0)
MATCH (m159_0_0)-[:P12]->(m159_0_1)
MATCH (m159_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
