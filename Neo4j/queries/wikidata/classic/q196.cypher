// q196; freq=1; rpq=<537->/(<176>)*; readable=<P537^-1>/(<P176>)*
MATCH (s)<-[:P537]-(m226_0_0)
MATCH (m226_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
