// q147; freq=1; rpq=(<443>)*; readable=(<P443>)*
MATCH p164_0 = (s)-[:P443*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
