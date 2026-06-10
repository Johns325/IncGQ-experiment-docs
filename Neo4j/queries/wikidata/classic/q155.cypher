// q155; freq=1; rpq=(<586>)+; readable=(<P586>)+
MATCH p71_0 = (s)-[:P586*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
