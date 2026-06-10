// q128; freq=1; rpq=(<289>/(<412>)*)/<397->; readable=(<P289>/(<P412>)*)/<P397^-1>
MATCH (s)-[:P289]->(m48_0_0)
MATCH (m48_0_0)-[:P412*0..]->(m48_0_1)
MATCH (m48_0_1)<-[:P397]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
