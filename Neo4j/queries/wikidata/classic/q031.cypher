// q31; freq=5; rpq=(<412>)*/<159>; readable=(<P412>)*/<P159>
MATCH (s)-[:P412*0..]->(m25_0_0)
MATCH (m25_0_0)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
