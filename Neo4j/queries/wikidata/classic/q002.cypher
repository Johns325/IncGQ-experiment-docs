// q2; freq=207; rpq=(<412>)*; readable=(<P412>)*
MATCH p4_0 = (s)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
