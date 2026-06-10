// q50; freq=2; rpq=((<176->|<664->))+; readable=((<P176^-1>|<P664^-1>))+
MATCH p132_0 = (s)<-[:P176|P664*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
