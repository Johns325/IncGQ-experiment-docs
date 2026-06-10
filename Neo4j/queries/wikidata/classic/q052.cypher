// q52; freq=2; rpq=((<204->|<203->))+; readable=((<P204^-1>|<P203^-1>))+
MATCH p198_0 = (s)<-[:P203|P204*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
