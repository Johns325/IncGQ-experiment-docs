// q87; freq=1; rpq=(<1141>/(<412>)*)/<159>; readable=(<P1141>/(<P412>)*)/<P159>
MATCH (s)-[:P1141]->(m128_0_0)
MATCH (m128_0_0)-[:P412*0..]->(m128_0_1)
MATCH (m128_0_1)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
