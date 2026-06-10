// q190; freq=1; rpq=<412>/(<12>)*; readable=<P412>/(<P12>)*
MATCH (s)-[:P412]->(m241_0_0)
MATCH (m241_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
