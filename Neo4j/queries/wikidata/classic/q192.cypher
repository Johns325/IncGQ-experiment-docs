// q192; freq=1; rpq=<412>/(<196>)*; readable=<P412>/(<P196>)*
MATCH (s)-[:P412]->(m150_0_0)
MATCH (m150_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
