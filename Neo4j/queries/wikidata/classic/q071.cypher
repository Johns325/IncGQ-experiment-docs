// q71; freq=2; rpq=<1473>/(<176>)*; readable=<P1473>/(<P176>)*
MATCH (s)-[:P1473]->(m98_0_0)
MATCH (m98_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
