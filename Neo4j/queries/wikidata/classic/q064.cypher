// q64; freq=2; rpq=(<4377>)*; readable=(<P4377>)*
MATCH p147_0 = (s)-[:P4377*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
