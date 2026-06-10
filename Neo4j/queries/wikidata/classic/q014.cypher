// q14; freq=12; rpq=(<803>)*; readable=(<P803>)*
MATCH p140_0 = (s)-[:P803*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
