// q106; freq=1; rpq=(<176->|<664->)+; readable=(<P176^-1>|<P664^-1>)+
MATCH p131_0 = (s)<-[:P176|P664*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
