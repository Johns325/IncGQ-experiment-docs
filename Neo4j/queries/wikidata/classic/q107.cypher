// q107; freq=1; rpq=(<176>)*/(<412>)*; readable=(<P176>)*/(<P412>)*
MATCH (s)-[:P176*0..]->(m31_0_0)
MATCH (m31_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
