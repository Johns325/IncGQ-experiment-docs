// q38; freq=4; rpq=(<159>)*; readable=(<P159>)*
MATCH p29_0 = (s)-[:P159*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
