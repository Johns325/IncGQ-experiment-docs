// q60; freq=2; rpq=(<204>)*/(<203>)*; readable=(<P204>)*/(<P203>)*
MATCH (s)-[:P204*0..]->(m103_0_0)
MATCH (m103_0_0)-[:P203*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
