// q18; freq=9; rpq=(<12>)?/(<196>)*; readable=(<P12>)?/(<P196>)*
MATCH (s)-[:P12*0..1]->(m10_0_0)
MATCH (m10_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
