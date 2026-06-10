// q162; freq=1; rpq=(<949>/<925->)/(<196>)*; readable=(<P949>/<P925^-1>)/(<P196>)*
MATCH (s)-[:P949]->(m87_0_0)
MATCH (m87_0_0)<-[:P925]-(m87_0_1)
MATCH (m87_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
