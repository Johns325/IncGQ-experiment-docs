// q159; freq=1; rpq=(<939>)*; readable=(<P939>)*
MATCH p43_0 = (s)-[:P939*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
