// q125; freq=1; rpq=(<212>)*/(<399>)*; readable=(<P212>)*/(<P399>)*
MATCH (s)-[:P212*0..]->(m184_0_0)
MATCH (m184_0_0)-[:P399*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
