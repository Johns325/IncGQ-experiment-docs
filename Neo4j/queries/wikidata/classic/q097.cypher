// q97; freq=1; rpq=(<12>|<206>)/(<196>)*; readable=(<P12>|<P206>)/(<P196>)*
MATCH (s)-[:P12|P206]->(m235_0_0)
MATCH (m235_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
