// q138; freq=1; rpq=(<381>/<12>)/(<196>)+; readable=(<P381>/<P12>)/(<P196>)+
MATCH (s)-[:P381]->(m108_0_0)
MATCH (m108_0_0)-[:P12]->(m108_0_1)
MATCH (m108_0_1)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
