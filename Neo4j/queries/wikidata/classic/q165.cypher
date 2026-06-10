// q165; freq=1; rpq=<12>/(<320>)*; readable=<P12>/(<P320>)*
MATCH (s)-[:P12]->(m193_0_0)
MATCH (m193_0_0)-[:P320*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
