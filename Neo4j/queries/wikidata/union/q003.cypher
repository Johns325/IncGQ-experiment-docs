// q3; freq=3; rpq=(<12>/(<12>)*)|(<196>/(<196>)*); readable=(<P12>/(<P12>)*)|(<P196>/(<P196>)*)
MATCH (s)-[:P12]->(m234_0_0)
MATCH (m234_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P196]->(m234_1_0)
MATCH (m234_1_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
