// q51; freq=2; rpq=((<203->|<204->))+; readable=((<P203^-1>|<P204^-1>))+
MATCH p202_0 = (s)<-[:P203|P204*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
