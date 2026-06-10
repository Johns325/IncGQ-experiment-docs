// q14; freq=1; rpq=(<12>)*|(<196->)*; readable=(<P12>)*|(<P196^-1>)*
MATCH p17_0 = (s)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p17_1 = (s)<-[:P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
