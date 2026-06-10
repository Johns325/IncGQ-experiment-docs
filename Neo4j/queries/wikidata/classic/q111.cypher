// q111; freq=1; rpq=(<196->)*; readable=(<P196^-1>)*
MATCH p16_0 = (s)<-[:P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
