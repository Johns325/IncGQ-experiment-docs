// q101; freq=1; rpq=(<1503>)*; readable=(<P1503>)*
MATCH p126_0 = (s)-[:P1503*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
