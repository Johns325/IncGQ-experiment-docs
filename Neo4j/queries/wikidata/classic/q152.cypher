// q152; freq=1; rpq=(<545>)+; readable=(<P545>)+
MATCH p162_0 = (s)-[:P545*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
