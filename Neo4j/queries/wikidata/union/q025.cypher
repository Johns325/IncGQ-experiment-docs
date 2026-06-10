// q25; freq=1; rpq=<304>|(<1196>/(<176>)*); readable=<P304>|(<P1196>/(<P176>)*)
MATCH p97_0 = (s)-[:P304]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P1196]->(m97_1_0)
MATCH (m97_1_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
