// q142; freq=1; rpq=(<412>)*/<397->; readable=(<P412>)*/<P397^-1>
MATCH (s)-[:P412*0..]->(m49_0_0)
MATCH (m49_0_0)<-[:P397]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
