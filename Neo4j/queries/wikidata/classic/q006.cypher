// q6; freq=45; rpq=(<12>)*; readable=(<P12>)*
MATCH p23_0 = (s)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
