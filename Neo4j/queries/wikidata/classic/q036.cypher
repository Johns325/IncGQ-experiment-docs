// q36; freq=4; rpq=(<12->)?/(<196->)*; readable=(<P12^-1>)?/(<P196^-1>)*
MATCH (s)<-[:P12*0..1]-(m189_0_0)
MATCH (m189_0_0)<-[:P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
