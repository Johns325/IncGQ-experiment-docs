// q28; freq=5; rpq=(<12>)*/(<444>)*; readable=(<P12>)*/(<P444>)*
MATCH (s)-[:P12*0..]->(m161_0_0)
MATCH (m161_0_0)-[:P444*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
