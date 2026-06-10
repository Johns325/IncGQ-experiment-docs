// q120; freq=1; rpq=(<205>/<12>)/(<196>)*; readable=(<P205>/<P12>)/(<P196>)*
MATCH (s)-[:P205]->(m170_0_0)
MATCH (m170_0_0)-[:P12]->(m170_0_1)
MATCH (m170_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
