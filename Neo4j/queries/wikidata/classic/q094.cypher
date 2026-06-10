// q94; freq=1; rpq=(<12>)*/(<412>)*; readable=(<P12>)*/(<P412>)*
MATCH (s)-[:P12*0..]->(m32_0_0)
MATCH (m32_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
