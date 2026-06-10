// q198; freq=1; rpq=<602>/(<12>)*; readable=<P602>/(<P12>)*
MATCH (s)-[:P602]->(m95_0_0)
MATCH (m95_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
