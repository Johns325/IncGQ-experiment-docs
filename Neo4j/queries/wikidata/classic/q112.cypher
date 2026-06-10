// q112; freq=1; rpq=(<196->)*/(<12->)*; readable=(<P196^-1>)*/(<P12^-1>)*
MATCH (s)<-[:P196*0..]-(m175_0_0)
MATCH (m175_0_0)<-[:P12*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
