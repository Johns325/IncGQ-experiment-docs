// q53; freq=2; rpq=((<206>)*/(<353>)*)/(<212>)*; readable=((<P206>)*/(<P353>)*)/(<P212>)*
MATCH (s)-[:P206*0..]->(m220_0_0)
MATCH (m220_0_0)-[:P353*0..]->(m220_0_1)
MATCH (m220_0_1)-[:P212*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
