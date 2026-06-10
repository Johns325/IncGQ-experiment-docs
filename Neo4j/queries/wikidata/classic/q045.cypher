// q45; freq=3; rpq=(<212>)*; readable=(<P212>)*
MATCH p30_0 = (s)-[:P212*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
