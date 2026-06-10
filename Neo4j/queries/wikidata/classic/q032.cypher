// q32; freq=5; rpq=<212>/(<196>)*; readable=<P212>/(<P196>)*
MATCH (s)-[:P212]->(m102_0_0)
MATCH (m102_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
