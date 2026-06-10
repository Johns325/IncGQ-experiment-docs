// q75; freq=1; rpq=((((<176->|<159->)|<13->)|<3908->))+; readable=((((<P176^-1>|<P159^-1>)|<P13^-1>)|<P3908^-1>))+
MATCH p172_0 = (s)<-[:P13|P159|P176|P3908*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
