// q2; freq=3; rpq=(<12>)*|(<196>)*; readable=(<P12>)*|(<P196>)*
MATCH p15_0 = (s)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p15_1 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
