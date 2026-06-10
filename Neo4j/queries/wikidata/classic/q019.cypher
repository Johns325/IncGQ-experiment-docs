// q19; freq=9; rpq=(<176>)*; readable=(<P176>)*
MATCH p27_0 = (s)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
