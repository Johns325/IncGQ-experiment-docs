// q72; freq=2; rpq=<205>/(<196>)*; readable=<P205>/(<P196>)*
MATCH (s)-[:P205]->(m141_0_0)
MATCH (m141_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
