// q41; freq=4; rpq=<338>/(<196>)*; readable=<P338>/(<P196>)*
MATCH (s)-[:P338]->(m114_0_0)
MATCH (m114_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
