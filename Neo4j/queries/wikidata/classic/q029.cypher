// q29; freq=5; rpq=(<303>)*; readable=(<P303>)*
MATCH p113_0 = (s)-[:P303*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
