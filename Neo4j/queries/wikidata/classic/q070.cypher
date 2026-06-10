// q70; freq=2; rpq=<1342>/(<196>)*; readable=<P1342>/(<P196>)*
MATCH (s)-[:P1342]->(m143_0_0)
MATCH (m143_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
