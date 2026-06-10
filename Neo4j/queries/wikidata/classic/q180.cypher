// q180; freq=1; rpq=<206>/(<196>)+; readable=<P206>/(<P196>)+
MATCH (s)-[:P206]->(m81_0_0)
MATCH (m81_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
