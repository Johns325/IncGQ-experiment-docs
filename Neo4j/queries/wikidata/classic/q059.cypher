// q59; freq=2; rpq=(<196>|<12>)*; readable=(<P196>|<P12>)*
MATCH p9_0 = (s)-[:P12|P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
