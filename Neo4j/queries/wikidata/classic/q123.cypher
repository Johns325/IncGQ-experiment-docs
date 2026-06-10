// q123; freq=1; rpq=(<206>|<196>)*; readable=(<P206>|<P196>)*
MATCH p165_0 = (s)-[:P196|P206*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
