// q153; freq=1; rpq=(<55>/<12>)/(<196>)*; readable=(<P55>/<P12>)/(<P196>)*
MATCH (s)-[:P55]->(m232_0_0)
MATCH (m232_0_0)-[:P12]->(m232_0_1)
MATCH (m232_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
