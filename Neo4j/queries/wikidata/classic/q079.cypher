// q79; freq=1; rpq=((<12->|<1370->))+; readable=((<P12^-1>|<P1370^-1>))+
MATCH p227_0 = (s)<-[:P12|P1370*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
