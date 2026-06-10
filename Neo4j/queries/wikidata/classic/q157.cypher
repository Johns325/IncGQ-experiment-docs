// q157; freq=1; rpq=(<602>/(<12>)?)/(<196>)*; readable=(<P602>/(<P12>)?)/(<P196>)*
MATCH (s)-[:P602]->(m145_0_0)
MATCH (m145_0_0)-[:P12*0..1]->(m145_0_1)
MATCH (m145_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
