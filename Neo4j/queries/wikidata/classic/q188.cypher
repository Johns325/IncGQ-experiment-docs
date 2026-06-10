// q188; freq=1; rpq=<390>/(<4377>)*; readable=<P390>/(<P4377>)*
MATCH (s)-[:P390]->(m157_0_0)
MATCH (m157_0_0)-[:P4377*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
