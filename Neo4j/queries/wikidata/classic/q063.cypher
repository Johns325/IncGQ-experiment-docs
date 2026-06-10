// q63; freq=2; rpq=(<338>)*; readable=(<P338>)*
MATCH p39_0 = (s)-[:P338*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
