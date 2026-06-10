// q176; freq=1; rpq=<176>/(<176>)*; readable=<P176>/(<P176>)*
MATCH (s)-[:P176]->(m152_0_0)
MATCH (m152_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
