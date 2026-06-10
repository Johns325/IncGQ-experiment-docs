// q39; freq=4; rpq=(<196->)*/<12->; readable=(<P196^-1>)*/<P12^-1>
MATCH (s)<-[:P196*0..]-(m137_0_0)
MATCH (m137_0_0)<-[:P12]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
