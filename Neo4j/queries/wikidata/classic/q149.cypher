// q149; freq=1; rpq=(<494>)*; readable=(<P494>)*
MATCH p73_0 = (s)-[:P494*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
