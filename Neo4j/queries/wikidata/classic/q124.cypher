// q124; freq=1; rpq=(<212->/(<196->)*); readable=(<P212^-1>/(<P196^-1>)*)
MATCH (s)<-[:P212]-(m101_0_0)
MATCH (m101_0_0)<-[:P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
