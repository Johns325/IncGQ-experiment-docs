// q99; freq=1; rpq=(<13>)*; readable=(<P13>)*
MATCH p65_0 = (s)-[:P13*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
