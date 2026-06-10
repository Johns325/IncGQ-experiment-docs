// q80; freq=1; rpq=((<1281>)*/(<1449>)*)/(<176>)*; readable=((<P1281>)*/(<P1449>)*)/(<P176>)*
MATCH (s)-[:P1281*0..]->(m90_0_0)
MATCH (m90_0_0)-[:P1449*0..]->(m90_0_1)
MATCH (m90_0_1)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
