// q103; freq=1; rpq=(<1594>)+; readable=(<P1594>)+
MATCH p28_0 = (s)-[:P1594*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
