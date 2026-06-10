// q160; freq=1; rpq=(<939>/(<12>)*)/(<196>)*; readable=(<P939>/(<P12>)*)/(<P196>)*
MATCH (s)-[:P939]->(m117_0_0)
MATCH (m117_0_0)-[:P12*0..]->(m117_0_1)
MATCH (m117_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
