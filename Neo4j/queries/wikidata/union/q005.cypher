// q5; freq=2; rpq=(<196>)+|(<12>)+; readable=(<P196>)+|(<P12>)+
MATCH p233_0 = (s)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p233_1 = (s)-[:P12*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
