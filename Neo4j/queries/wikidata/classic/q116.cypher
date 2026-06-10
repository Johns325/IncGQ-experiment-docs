// q116; freq=1; rpq=(<196>/<196>)/(<196>)*; readable=(<P196>/<P196>)/(<P196>)*
MATCH (s)-[:P196]->(m208_0_0)
MATCH (m208_0_0)-[:P196]->(m208_0_1)
MATCH (m208_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
