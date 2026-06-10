// q203; freq=1; rpq=<939>/(<933>)+; readable=<P939>/(<P933>)+
MATCH (s)-[:P939]->(m119_0_0)
MATCH (m119_0_0)-[:P933*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
