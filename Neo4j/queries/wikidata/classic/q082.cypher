// q82; freq=1; rpq=((<196->)*/(<12->)?)/<159>; readable=((<P196^-1>)*/(<P12^-1>)?)/<P159>
MATCH (s)<-[:P196*0..]-(m96_0_0)
MATCH (m96_0_0)<-[:P12*0..1]-(m96_0_1)
MATCH (m96_0_1)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
