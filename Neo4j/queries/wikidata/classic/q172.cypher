// q172; freq=1; rpq=<1449>/(<176>)*; readable=<P1449>/(<P176>)*
MATCH (s)-[:P1449]->(m85_0_0)
MATCH (m85_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
