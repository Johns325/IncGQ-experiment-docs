// q129; freq=1; rpq=(<289>/(<586>)?)/(<412>)+; readable=(<P289>/(<P586>)?)/(<P412>)+
MATCH (s)-[:P289]->(m192_0_0)
MATCH (m192_0_0)-[:P586*0..1]->(m192_0_1)
MATCH (m192_0_1)-[:P412*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
