// q19; freq=1; rpq=(<176>/(<176>)*)|(<664>)*; readable=(<P176>/(<P176>)*)|(<P664>)*
MATCH (s)-[:P176]->(m129_0_0)
MATCH (m129_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p129_1 = (s)-[:P664*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
