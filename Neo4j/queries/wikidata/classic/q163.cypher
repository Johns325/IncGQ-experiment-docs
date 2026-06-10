// q163; freq=1; rpq=<1141>/(<412>)*; readable=<P1141>/(<P412>)*
MATCH (s)-[:P1141]->(m121_0_0)
MATCH (m121_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
