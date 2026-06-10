// q27; freq=6; rpq=<811>/(<196>)*; readable=<P811>/(<P196>)*
MATCH (s)-[:P811]->(m80_0_0)
MATCH (m80_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
