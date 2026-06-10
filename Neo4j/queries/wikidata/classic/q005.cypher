// q5; freq=51; rpq=(<196>)+; readable=(<P196>)+
MATCH p12_0 = (s)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
