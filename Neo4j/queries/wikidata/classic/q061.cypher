// q61; freq=2; rpq=(<205>)*; readable=(<P205>)*
MATCH p169_0 = (s)-[:P205*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
