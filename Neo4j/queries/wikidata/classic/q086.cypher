// q86; freq=1; rpq=(<1141>)+; readable=(<P1141>)+
MATCH p21_0 = (s)-[:P1141*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
