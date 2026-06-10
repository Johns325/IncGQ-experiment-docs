// q136; freq=1; rpq=(<361>)+/(<439>)*; readable=(<P361>)+/(<P439>)*
MATCH (s)-[:P361*1..]->(m60_0_0)
MATCH (m60_0_0)-[:P439*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
