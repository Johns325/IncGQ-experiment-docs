// q62; freq=2; rpq=(<31>)*; readable=(<P31>)*
MATCH p5_0 = (s)-[:P31*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
