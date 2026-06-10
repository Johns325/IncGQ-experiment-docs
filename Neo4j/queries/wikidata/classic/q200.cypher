// q200; freq=1; rpq=<847>/(<196>)*; readable=<P847>/(<P196>)*
MATCH (s)-[:P847]->(m136_0_0)
MATCH (m136_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
