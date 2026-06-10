// q118; freq=1; rpq=(<203>|<303>)+; readable=(<P203>|<P303>)+
MATCH p158_0 = (s)-[:P203|P303*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
