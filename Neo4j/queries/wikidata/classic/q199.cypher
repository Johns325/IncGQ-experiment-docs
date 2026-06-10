// q199; freq=1; rpq=<602>/(<196>)*; readable=<P602>/(<P196>)*
MATCH (s)-[:P602]->(m216_0_0)
MATCH (m216_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
