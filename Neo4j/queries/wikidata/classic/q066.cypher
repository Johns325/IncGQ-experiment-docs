// q66; freq=2; rpq=(<811>)*; readable=(<P811>)*
MATCH p223_0 = (s)-[:P811*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
