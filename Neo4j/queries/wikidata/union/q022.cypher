// q22; freq=1; rpq=(<304>|<43>)|(<1196>/(<176>)*); readable=(<P304>|<P43>)|(<P1196>/(<P176>)*)
MATCH p148_0 = (s)-[:P304]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p148_1 = (s)-[:P43]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P1196]->(m148_2_0)
MATCH (m148_2_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
