// q187; freq=1; rpq=<390>/(<196>)*; readable=<P390>/(<P196>)*
MATCH (s)-[:P390]->(m156_0_0)
MATCH (m156_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
