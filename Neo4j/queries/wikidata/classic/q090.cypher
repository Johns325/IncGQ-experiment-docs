// q90; freq=1; rpq=(<12->)+/(<196>)+; readable=(<P12^-1>)+/(<P196>)+
MATCH (s)<-[:P12*1..]-(m188_0_0)
MATCH (m188_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
