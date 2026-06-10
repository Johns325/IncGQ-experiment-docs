// q121; freq=1; rpq=(<206>)+; readable=(<P206>)+
MATCH p142_0 = (s)-[:P206*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
