// q173; freq=1; rpq=<1473>/(<176->)*; readable=<P1473>/(<P176^-1>)*
MATCH (s)-[:P1473]->(m179_0_0)
MATCH (m179_0_0)<-[:P176*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
