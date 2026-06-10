// q81; freq=1; rpq=((<1281>)*/(<196>)*)/(<1449>)*; readable=((<P1281>)*/(<P196>)*)/(<P1449>)*
MATCH (s)-[:P1281*0..]->(m93_0_0)
MATCH (m93_0_0)-[:P196*0..]->(m93_0_1)
MATCH (m93_0_1)-[:P1449*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
