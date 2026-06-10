// q109; freq=1; rpq=(<176>|<1189>)*; readable=(<P176>|<P1189>)*
MATCH p53_0 = (s)-[:P176|P1189*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
