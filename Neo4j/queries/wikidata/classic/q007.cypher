// q7; freq=33; rpq=(<412>)+; readable=(<P412>)+
MATCH p7_0 = (s)-[:P412*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
