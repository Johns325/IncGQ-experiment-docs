// q20; freq=8; rpq=(<1135>)*; readable=(<P1135>)*
MATCH p84_0 = (s)-[:P1135*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
