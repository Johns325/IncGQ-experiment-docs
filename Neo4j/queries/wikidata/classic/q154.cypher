// q154; freq=1; rpq=(<586>)*/(<159>)*; readable=(<P586>)*/(<P159>)*
MATCH (s)-[:P586*0..]->(m91_0_0)
MATCH (m91_0_0)-[:P159*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
