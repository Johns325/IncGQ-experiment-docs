// q119; freq=1; rpq=(<204>|<203>)+; readable=(<P204>|<P203>)+
MATCH p201_0 = (s)-[:P203|P204*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
