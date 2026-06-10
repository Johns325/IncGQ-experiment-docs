// q170; freq=1; rpq=<1337>/(<412>)*; readable=<P1337>/(<P412>)*
MATCH (s)-[:P1337]->(m35_0_0)
MATCH (m35_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
