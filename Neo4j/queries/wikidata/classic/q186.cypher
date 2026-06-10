// q186; freq=1; rpq=<338>/(<196>)+; readable=<P338>/(<P196>)+
MATCH (s)-[:P338]->(m115_0_0)
MATCH (m115_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
