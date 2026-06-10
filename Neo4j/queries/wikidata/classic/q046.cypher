// q46; freq=3; rpq=(<303->)*; readable=(<P303^-1>)*
MATCH p105_0 = (s)<-[:P303*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
