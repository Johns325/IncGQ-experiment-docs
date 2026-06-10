// q84; freq=1; rpq=((<196->|<12->))+; readable=((<P196^-1>|<P12^-1>))+
MATCH p168_0 = (s)<-[:P12|P196*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
