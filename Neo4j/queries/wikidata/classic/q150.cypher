// q150; freq=1; rpq=(<530>)*/(<530>)*; readable=(<P530>)*/(<P530>)*
MATCH (s)-[:P530*0..]->(m214_0_0)
MATCH (m214_0_0)-[:P530*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
