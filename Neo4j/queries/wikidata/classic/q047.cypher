// q47; freq=3; rpq=(<439>)*; readable=(<P439>)*
MATCH p59_0 = (s)-[:P439*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
