// q132; freq=1; rpq=(<338>/(<12>)?)/(<196>)*; readable=(<P338>/(<P12>)?)/(<P196>)*
MATCH (s)-[:P338]->(m144_0_0)
MATCH (m144_0_0)-[:P12*0..1]->(m144_0_1)
MATCH (m144_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
