// q67; freq=2; rpq=<1196>/(<176>)*; readable=<P1196>/(<P176>)*
MATCH (s)-[:P1196]->(m186_0_0)
MATCH (m186_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
