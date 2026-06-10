// q12; freq=1; rpq=((<412>/(<196>)*)|(<586>/(<196>)*))|(<176>/(<196>)*); readable=((<P412>/(<P196>)*)|(<P586>/(<P196>)*))|(<P176>/(<P196>)*)
MATCH (s)-[:P412]->(m109_0_0)
MATCH (m109_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P586]->(m109_1_0)
MATCH (m109_1_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P176]->(m109_2_0)
MATCH (m109_2_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
