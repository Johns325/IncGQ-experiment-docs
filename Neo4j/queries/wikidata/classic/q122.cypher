// q122; freq=1; rpq=(<206>/(<196>)*)/(<196>)*; readable=(<P206>/(<P196>)*)/(<P196>)*
MATCH (s)-[:P206]->(m70_0_0)
MATCH (m70_0_0)-[:P196*0..]->(m70_0_1)
MATCH (m70_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
