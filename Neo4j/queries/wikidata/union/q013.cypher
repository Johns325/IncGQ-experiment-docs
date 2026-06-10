// q13; freq=1; rpq=(<12->)*|(<196->)*; readable=(<P12^-1>)*|(<P196^-1>)*
MATCH p18_0 = (s)<-[:P12*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p18_1 = (s)<-[:P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
