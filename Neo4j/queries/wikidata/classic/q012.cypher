// q12; freq=23; rpq=(<196>|<412>)*; readable=(<P196>|<P412>)*
MATCH p54_0 = (s)-[:P196|P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
