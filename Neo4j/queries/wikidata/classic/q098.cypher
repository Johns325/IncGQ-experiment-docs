// q98; freq=1; rpq=(<1341>)+/(<439>)*; readable=(<P1341>)+/(<P439>)*
MATCH (s)-[:P1341*1..]->(m61_0_0)
MATCH (m61_0_0)-[:P439*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
