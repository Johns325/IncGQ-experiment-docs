// q21; freq=8; rpq=(<12>)+; readable=(<P12>)+
MATCH p13_0 = (s)-[:P12*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
