// q74; freq=2; rpq=<809>/(<176>)*; readable=<P809>/(<P176>)*
MATCH (s)-[:P809]->(m238_0_0)
MATCH (m238_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
