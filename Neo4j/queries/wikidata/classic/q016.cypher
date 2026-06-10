// q16; freq=10; rpq=<12>/(<196>)+; readable=<P12>/(<P196>)+
MATCH (s)-[:P12]->(m77_0_0)
MATCH (m77_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
