// q189; freq=1; rpq=<397>/(<31>)*; readable=<P397>/(<P31>)*
MATCH (s)-[:P397]->(m205_0_0)
MATCH (m205_0_0)-[:P31*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
