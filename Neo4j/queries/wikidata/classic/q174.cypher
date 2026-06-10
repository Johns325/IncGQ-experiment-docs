// q174; freq=1; rpq=<1473>/(<397->)*; readable=<P1473>/(<P397^-1>)*
MATCH (s)-[:P1473]->(m180_0_0)
MATCH (m180_0_0)<-[:P397*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
