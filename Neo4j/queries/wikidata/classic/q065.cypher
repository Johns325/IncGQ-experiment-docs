// q65; freq=2; rpq=(<527>)+; readable=(<P527>)+
MATCH p195_0 = (s)-[:P527*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
