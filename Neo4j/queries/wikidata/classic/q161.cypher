// q161; freq=1; rpq=(<949>)*; readable=(<P949>)*
MATCH p82_0 = (s)-[:P949*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
