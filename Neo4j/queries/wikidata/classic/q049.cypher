// q49; freq=2; rpq=((<12>|<206>)|<338>)/(<196>)*; readable=((<P12>|<P206>)|<P338>)/(<P196>)*
MATCH (s)-[:P12|P206|P338]->(m134_0_0)
MATCH (m134_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
