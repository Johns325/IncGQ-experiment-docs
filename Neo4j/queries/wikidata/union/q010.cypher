// q10; freq=1; rpq=((<204>)*/(<203>)*)|(<303->)*; readable=((<P204>)*/(<P203>)*)|(<P303^-1>)*
MATCH (s)-[:P204*0..]->(m104_0_0)
MATCH (m104_0_0)-[:P203*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p104_1 = (s)<-[:P303*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
