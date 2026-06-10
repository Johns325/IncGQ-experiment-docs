// q181; freq=1; rpq=<210>/(<12>)*; readable=<P210>/(<P12>)*
MATCH (s)-[:P210]->(m151_0_0)
MATCH (m151_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
