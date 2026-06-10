// q24; freq=1; rpq=<159>|(<412>)*; readable=<P159>|(<P412>)*
MATCH p163_0 = (s)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p163_1 = (s)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
