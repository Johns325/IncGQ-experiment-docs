// q22; freq=7; rpq=(<12>|<196>)*; readable=(<P12>|<P196>)*
MATCH p40_0 = (s)-[:P12|P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
