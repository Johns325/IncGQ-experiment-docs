// q141; freq=1; rpq=(<412->)+; readable=(<P412^-1>)+
MATCH p154_0 = (s)<-[:P412*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
