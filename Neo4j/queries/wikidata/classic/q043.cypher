// q43; freq=3; rpq=(<159>)+; readable=(<P159>)+
MATCH p34_0 = (s)-[:P159*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
