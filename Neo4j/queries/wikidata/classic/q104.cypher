// q104; freq=1; rpq=(<159>)*/<13>; readable=(<P159>)*/<P13>
MATCH (s)-[:P159*0..]->(m230_0_0)
MATCH (m230_0_0)-[:P13]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
