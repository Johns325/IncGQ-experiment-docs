// q179; freq=1; rpq=<205>/(<159>)*; readable=<P205>/(<P159>)*
MATCH (s)-[:P205]->(m149_0_0)
MATCH (m149_0_0)-[:P159*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
