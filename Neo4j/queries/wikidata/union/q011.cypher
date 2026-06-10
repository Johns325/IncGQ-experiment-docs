// q11; freq=1; rpq=((<412>)+|(<176>)+)|(<196>)+; readable=((<P412>)+|(<P176>)+)|(<P196>)+
MATCH p237_0 = (s)-[:P412*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p237_1 = (s)-[:P176*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p237_2 = (s)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
