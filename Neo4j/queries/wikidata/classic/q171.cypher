// q171; freq=1; rpq=<13>/(<196>)*; readable=<P13>/(<P196>)*
MATCH (s)-[:P13]->(m209_0_0)
MATCH (m209_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
