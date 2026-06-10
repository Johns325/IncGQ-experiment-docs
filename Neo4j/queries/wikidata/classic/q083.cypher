// q83; freq=1; rpq=((<196->|<12->))*; readable=((<P196^-1>|<P12^-1>))*
MATCH p171_0 = (s)<-[:P12|P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
