// q100; freq=1; rpq=(<1420>)*; readable=(<P1420>)*
MATCH p58_0 = (s)-[:P1420*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
