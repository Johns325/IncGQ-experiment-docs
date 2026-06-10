// q11; freq=24; rpq=(<12>)*/(<196>)*; readable=(<P12>)*/(<P196>)*
MATCH (s)-[:P12*0..]->(m14_0_0)
MATCH (m14_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
