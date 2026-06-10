// q93; freq=1; rpq=(<121>)*; readable=(<P121>)*
MATCH p125_0 = (s)-[:P121*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
