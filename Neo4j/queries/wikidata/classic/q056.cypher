// q56; freq=2; rpq=(<12>/<12>)/(<12>)+; readable=(<P12>/<P12>)/(<P12>)+
MATCH (s)-[:P12]->(m194_0_0)
MATCH (m194_0_0)-[:P12]->(m194_0_1)
MATCH (m194_0_1)-[:P12*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
