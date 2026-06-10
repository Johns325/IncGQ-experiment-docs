// q24; freq=7; rpq=(<412>)*/(<399>)*; readable=(<P412>)*/(<P399>)*
MATCH (s)-[:P412*0..]->(m57_0_0)
MATCH (m57_0_0)-[:P399*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
