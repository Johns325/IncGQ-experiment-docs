// q8; freq=1; rpq=((<176>)*|<412>)|<586>; readable=((<P176>)*|<P412>)|<P586>
MATCH p45_0 = (s)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p45_1 = (s)-[:P412]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p45_2 = (s)-[:P586]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
