// q40; freq=4; rpq=(<206>)*; readable=(<P206>)*
MATCH p68_0 = (s)-[:P206*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
