// q134; freq=1; rpq=(<352>)*; readable=(<P352>)*
MATCH p222_0 = (s)-[:P352*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
