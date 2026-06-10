// q4; freq=2; rpq=(<12>/(<196>)*)|<12>; readable=(<P12>/(<P196>)*)|<P12>
MATCH (s)-[:P12]->(m116_0_0)
MATCH (m116_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p116_1 = (s)-[:P12]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
