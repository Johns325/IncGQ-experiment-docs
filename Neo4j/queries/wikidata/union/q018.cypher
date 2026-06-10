// q18; freq=1; rpq=(<12>/(<196>)*)|<206>; readable=(<P12>/(<P196>)*)|<P206>
MATCH (s)-[:P12]->(m89_0_0)
MATCH (m89_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p89_1 = (s)-[:P206]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
