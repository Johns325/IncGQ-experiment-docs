// q23; freq=7; rpq=(<204>|<203>)*; readable=(<P204>|<P203>)*
MATCH p106_0 = (s)-[:P203|P204*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
