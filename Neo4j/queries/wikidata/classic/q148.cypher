// q148; freq=1; rpq=(<45>)*; readable=(<P45>)*
MATCH p217_0 = (s)-[:P45*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
