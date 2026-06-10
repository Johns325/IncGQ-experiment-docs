// q202; freq=1; rpq=<939>/(<176>)+; readable=<P939>/(<P176>)+
MATCH (s)-[:P939]->(m118_0_0)
MATCH (m118_0_0)-[:P176*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
