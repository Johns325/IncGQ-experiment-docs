// q183; freq=1; rpq=<289>/(<35>)*; readable=<P289>/(<P35>)*
MATCH (s)-[:P289]->(m63_0_0)
MATCH (m63_0_0)-[:P35*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
