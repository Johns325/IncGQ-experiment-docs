// q4; freq=83; rpq=<412>/(<412>)*; readable=<P412>/(<P412>)*
MATCH (s)-[:P412]->(m1_0_0)
MATCH (m1_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
