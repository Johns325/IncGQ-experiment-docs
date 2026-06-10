// q9; freq=30; rpq=<206>/(<196>)*; readable=<P206>/(<P196>)*
MATCH (s)-[:P206]->(m19_0_0)
MATCH (m19_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
