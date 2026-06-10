// q34; freq=4; rpq=(((<176->|<664->)|<3908->))+; readable=(((<P176^-1>|<P664^-1>)|<P3908^-1>))+
MATCH p166_0 = (s)<-[:P176|P664|P3908*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
