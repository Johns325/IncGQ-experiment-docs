// q16; freq=1; rpq=(<12>/(<196>)*)|(<196>)*; readable=(<P12>/(<P196>)*)|(<P196>)*
MATCH (s)-[:P12]->(m94_0_0)
MATCH (m94_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p94_1 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
