// q92; freq=1; rpq=(<12->)?/(<196>)+; readable=(<P12^-1>)?/(<P196>)+
MATCH (s)<-[:P12*0..1]-(m191_0_0)
MATCH (m191_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
