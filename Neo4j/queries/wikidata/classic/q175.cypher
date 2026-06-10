// q175; freq=1; rpq=<1712>/(<196>)*; readable=<P1712>/(<P196>)*
MATCH (s)-[:P1712]->(m110_0_0)
MATCH (m110_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
