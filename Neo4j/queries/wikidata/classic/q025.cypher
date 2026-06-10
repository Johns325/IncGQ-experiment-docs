// q25; freq=6; rpq=(<196>)*/(<12>)*; readable=(<P196>)*/(<P12>)*
MATCH (s)-[:P196*0..]->(m127_0_0)
MATCH (m127_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
