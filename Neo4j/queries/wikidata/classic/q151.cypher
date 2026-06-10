// q151; freq=1; rpq=(<537>)*; readable=(<P537>)*
MATCH p124_0 = (s)-[:P537*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
