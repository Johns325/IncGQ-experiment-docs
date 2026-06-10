// q139; freq=1; rpq=(<397>)*; readable=(<P397>)*
MATCH p26_0 = (s)-[:P397*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
