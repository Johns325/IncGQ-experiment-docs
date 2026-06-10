// q17; freq=1; rpq=(<12>/(<196>)*)|(<206>/(<196>)*); readable=(<P12>/(<P196>)*)|(<P206>/(<P196>)*)
MATCH (s)-[:P12]->(m83_0_0)
MATCH (m83_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P206]->(m83_1_0)
MATCH (m83_1_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
