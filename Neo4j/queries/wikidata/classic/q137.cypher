// q137; freq=1; rpq=(<381>/(<196>)*)/<12>; readable=(<P381>/(<P196>)*)/<P12>
MATCH (s)-[:P381]->(m210_0_0)
MATCH (m210_0_0)-[:P196*0..]->(m210_0_1)
MATCH (m210_0_1)-[:P12]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
