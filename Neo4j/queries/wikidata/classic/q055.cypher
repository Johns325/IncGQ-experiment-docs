// q55; freq=2; rpq=(<12>)?/(<196>)+; readable=(<P12>)?/(<P196>)+
MATCH (s)-[:P12*0..1]->(m160_0_0)
MATCH (m160_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
