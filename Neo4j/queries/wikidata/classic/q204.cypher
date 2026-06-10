// q204; freq=1; rpq=<949>/(<196>)*; readable=<P949>/(<P196>)*
MATCH (s)-[:P949]->(m221_0_0)
MATCH (m221_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
