// q13; freq=13; rpq=<196>/(<196>)*; readable=<P196>/(<P196>)*
MATCH (s)-[:P196]->(m42_0_0)
MATCH (m42_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
