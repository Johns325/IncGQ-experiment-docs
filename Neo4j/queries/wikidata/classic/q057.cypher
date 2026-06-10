// q57; freq=2; rpq=(<12>/<196>)/(<196>)+; readable=(<P12>/<P196>)/(<P196>)+
MATCH (s)-[:P12]->(m78_0_0)
MATCH (m78_0_0)-[:P196]->(m78_0_1)
MATCH (m78_0_1)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
