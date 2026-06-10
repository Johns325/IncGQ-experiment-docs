// q146; freq=1; rpq=(<4377>)*/<2667>; readable=(<P4377>)*/<P2667>
MATCH (s)-[:P4377*0..]->(m107_0_0)
MATCH (m107_0_0)-[:P2667]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
