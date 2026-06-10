// q178; freq=1; rpq=<201>/(<196>)*; readable=<P201>/(<P196>)*
MATCH (s)-[:P201]->(m203_0_0)
MATCH (m203_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
