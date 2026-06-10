// q44; freq=3; rpq=(<176>)+; readable=(<P176>)+
MATCH p33_0 = (s)-[:P176*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
