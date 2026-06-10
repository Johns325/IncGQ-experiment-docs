// q6; freq=2; rpq=<12>|(<196>)*; readable=<P12>|(<P196>)*
MATCH p55_0 = (s)-[:P12]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p55_1 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
