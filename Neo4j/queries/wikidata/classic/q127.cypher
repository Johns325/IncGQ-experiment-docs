// q127; freq=1; rpq=(<289>)*; readable=(<P289>)*
MATCH p76_0 = (s)-[:P289*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
