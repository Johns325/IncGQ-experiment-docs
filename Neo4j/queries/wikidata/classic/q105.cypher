// q105; freq=1; rpq=(<159>)*/<159>; readable=(<P159>)*/<P159>
MATCH (s)-[:P159*0..]->(m213_0_0)
MATCH (m213_0_0)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
