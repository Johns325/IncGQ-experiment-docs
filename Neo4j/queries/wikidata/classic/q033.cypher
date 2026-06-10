// q33; freq=5; rpq=<303>/(<303>)*; readable=<P303>/(<P303>)*
MATCH (s)-[:P303]->(m242_0_0)
MATCH (m242_0_0)-[:P303*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
