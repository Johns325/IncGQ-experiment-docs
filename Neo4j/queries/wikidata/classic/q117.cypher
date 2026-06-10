// q117; freq=1; rpq=(<199>)*; readable=(<P199>)*
MATCH p51_0 = (s)-[:P199*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
