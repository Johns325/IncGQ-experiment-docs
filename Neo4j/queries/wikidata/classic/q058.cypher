// q58; freq=2; rpq=(<159>|<412>)*; readable=(<P159>|<P412>)*
MATCH p6_0 = (s)-[:P159|P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
