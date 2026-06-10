// q156; freq=1; rpq=(<602>)*; readable=(<P602>)*
MATCH p229_0 = (s)-[:P602*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
