// q42; freq=3; rpq=(<1135>)+; readable=(<P1135>)+
MATCH p215_0 = (s)-[:P1135*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
