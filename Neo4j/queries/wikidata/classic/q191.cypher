// q191; freq=1; rpq=<412>/(<159>)*; readable=<P412>/(<P159>)*
MATCH (s)-[:P412]->(m67_0_0)
MATCH (m67_0_0)-[:P159*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
