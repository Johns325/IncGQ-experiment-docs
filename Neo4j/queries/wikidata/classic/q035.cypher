// q35; freq=4; rpq=((<206>|<212>)|<12>)/(<196>)*; readable=((<P206>|<P212>)|<P12>)/(<P196>)*
MATCH (s)-[:P12|P206|P212]->(m22_0_0)
MATCH (m22_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
