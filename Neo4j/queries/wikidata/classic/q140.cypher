// q140; freq=1; rpq=(<397>)+; readable=(<P397>)+
MATCH p111_0 = (s)-[:P397*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
