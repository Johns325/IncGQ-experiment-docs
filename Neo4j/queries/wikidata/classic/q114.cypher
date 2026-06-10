// q114; freq=1; rpq=(<196>)*/<925>; readable=(<P196>)*/<P925>
MATCH (s)-[:P196*0..]->(m120_0_0)
MATCH (m120_0_0)-[:P925]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
