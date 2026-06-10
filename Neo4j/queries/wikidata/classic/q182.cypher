// q182; freq=1; rpq=<2277>/(<196>)*; readable=<P2277>/(<P196>)*
MATCH (s)-[:P2277]->(m36_0_0)
MATCH (m36_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
