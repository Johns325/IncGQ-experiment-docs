// q8; freq=30; rpq=(<444>)*; readable=(<P444>)*
MATCH p41_0 = (s)-[:P444*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
