// q168; freq=1; rpq=<12>/(<800>)*; readable=<P12>/(<P800>)*
MATCH (s)-[:P12]->(m88_0_0)
MATCH (m88_0_0)-[:P800*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
