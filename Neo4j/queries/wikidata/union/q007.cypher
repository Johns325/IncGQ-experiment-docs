// q7; freq=1; rpq=((<176>)*|(<586>)*)|(<412>)*; readable=((<P176>)*|(<P586>)*)|(<P412>)*
MATCH p44_0 = (s)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p44_1 = (s)-[:P586*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p44_2 = (s)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
