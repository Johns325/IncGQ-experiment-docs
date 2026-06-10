// q3; freq=191; rpq=(<196>)*; readable=(<P196>)*
MATCH p3_0 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
