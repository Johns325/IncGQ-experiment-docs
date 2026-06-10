// q37; freq=4; rpq=(<12>|<196>)+; readable=(<P12>|<P196>)+
MATCH p24_0 = (s)-[:P12|P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
