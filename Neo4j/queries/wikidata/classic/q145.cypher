// q145; freq=1; rpq=(<412>/(<196>)*)/<159>; readable=(<P412>/(<P196>)*)/<P159>
MATCH (s)-[:P412]->(m62_0_0)
MATCH (m62_0_0)-[:P196*0..]->(m62_0_1)
MATCH (m62_0_1)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
