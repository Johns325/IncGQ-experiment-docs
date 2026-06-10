// q131; freq=1; rpq=(<31>)+; readable=(<P31>)+
MATCH p8_0 = (s)-[:P31*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
