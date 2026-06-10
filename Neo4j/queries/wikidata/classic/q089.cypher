// q89; freq=1; rpq=(<12->)*/(<196>)*; readable=(<P12^-1>)*/(<P196>)*
MATCH (s)<-[:P12*0..]-(m187_0_0)
MATCH (m187_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
