// q102; freq=1; rpq=(<159->)+; readable=(<P159^-1>)+
MATCH p173_0 = (s)<-[:P159*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
