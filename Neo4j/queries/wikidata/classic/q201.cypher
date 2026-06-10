// q201; freq=1; rpq=<925->/(<196>)*; readable=<P925^-1>/(<P196>)*
MATCH (s)<-[:P925]-(m86_0_0)
MATCH (m86_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
