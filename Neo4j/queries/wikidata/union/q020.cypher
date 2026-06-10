// q20; freq=1; rpq=(<196>)*|(<176>)*; readable=(<P196>)*|(<P176>)*
MATCH p185_0 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p185_1 = (s)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
