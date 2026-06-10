// q30; freq=5; rpq=(<303>)+; readable=(<P303>)+
MATCH p50_0 = (s)-[:P303*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
