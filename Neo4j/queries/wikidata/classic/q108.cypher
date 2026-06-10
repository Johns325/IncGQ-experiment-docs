// q108; freq=1; rpq=(<176>)*/<159>; readable=(<P176>)*/<P159>
MATCH (s)-[:P176*0..]->(m133_0_0)
MATCH (m133_0_0)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
