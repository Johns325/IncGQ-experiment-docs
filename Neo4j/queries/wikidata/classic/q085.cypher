// q85; freq=1; rpq=((<412>)*/(<176>)*)/(<399>)*; readable=((<P412>)*/(<P176>)*)/(<P399>)*
MATCH (s)-[:P412*0..]->(m135_0_0)
MATCH (m135_0_0)-[:P176*0..]->(m135_0_1)
MATCH (m135_0_1)-[:P399*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
