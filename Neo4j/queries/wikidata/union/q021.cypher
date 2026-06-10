// q21; freq=1; rpq=(<196>)+|(<12>/(<196>)*); readable=(<P196>)+|(<P12>/(<P196>)*)
MATCH p56_0 = (s)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P12]->(m56_1_0)
MATCH (m56_1_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
