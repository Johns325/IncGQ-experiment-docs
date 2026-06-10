// q185; freq=1; rpq=<31>/(<412>)*; readable=<P31>/(<P412>)*
MATCH (s)-[:P31]->(m200_0_0)
MATCH (m200_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
