// q26; freq=6; rpq=<170>/(<12>)*; readable=<P170>/(<P12>)*
MATCH (s)-[:P170]->(m178_0_0)
MATCH (m178_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
