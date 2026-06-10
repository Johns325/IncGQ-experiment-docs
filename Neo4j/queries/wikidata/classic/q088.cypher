// q88; freq=1; rpq=(<11>/<12>)/(<196>)*; readable=(<P11>/<P12>)/(<P196>)*
MATCH (s)-[:P11]->(m11_0_0)
MATCH (m11_0_0)-[:P12]->(m11_0_1)
MATCH (m11_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
