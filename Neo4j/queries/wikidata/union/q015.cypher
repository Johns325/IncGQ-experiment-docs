// q15; freq=1; rpq=(<12>)?|(<196>)*; readable=(<P12>)?|(<P196>)*
MATCH p100_0 = (s)-[:P12*0..1]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p100_1 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
