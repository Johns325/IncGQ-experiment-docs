// q1; freq=4; rpq=<12>|(<12>/(<196>)*); readable=<P12>|(<P12>/(<P196>)*)
MATCH p139_0 = (s)-[:P12]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P12]->(m139_1_0)
MATCH (m139_1_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
