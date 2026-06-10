// q126; freq=1; rpq=(<241>)*; readable=(<P241>)*
MATCH p204_0 = (s)-[:P241*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
