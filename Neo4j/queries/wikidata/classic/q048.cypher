// q48; freq=3; rpq=<210>/(<196>)*; readable=<P210>/(<P196>)*
MATCH (s)-[:P210]->(m66_0_0)
MATCH (m66_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
