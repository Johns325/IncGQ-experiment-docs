// q177; freq=1; rpq=<199>/(<412>)*; readable=<P199>/(<P412>)*
MATCH (s)-[:P199]->(m122_0_0)
MATCH (m122_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
