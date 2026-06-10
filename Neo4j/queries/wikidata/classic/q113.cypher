// q113; freq=1; rpq=(<196>)*/<800>; readable=(<P196>)*/<P800>
MATCH (s)-[:P196*0..]->(m46_0_0)
MATCH (m46_0_0)-[:P800]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
