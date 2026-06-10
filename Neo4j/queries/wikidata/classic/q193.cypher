// q193; freq=1; rpq=<443>/(<196>)*; readable=<P443>/(<P196>)*
MATCH (s)-[:P443]->(m206_0_0)
MATCH (m206_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
