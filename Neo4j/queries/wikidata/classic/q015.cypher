// q15; freq=11; rpq=(<444>)+; readable=(<P444>)+
MATCH p38_0 = (s)-[:P444*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
