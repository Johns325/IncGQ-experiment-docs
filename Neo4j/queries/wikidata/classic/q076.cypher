// q76; freq=1; rpq=((((<176->|<664->)|<3908->)|<159->))+; readable=((((<P176^-1>|<P664^-1>)|<P3908^-1>)|<P159^-1>))+
MATCH p177_0 = (s)<-[:P159|P176|P664|P3908*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
