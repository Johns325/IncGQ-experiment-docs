// q135; freq=1; rpq=(<361>)*; readable=(<P361>)*
MATCH p146_0 = (s)-[:P361*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
