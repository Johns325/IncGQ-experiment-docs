// q195; freq=1; rpq=<537->/(<176->)*; readable=<P537^-1>/(<P176^-1>)*
MATCH (s)<-[:P537]-(m228_0_0)
MATCH (m228_0_0)<-[:P176*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
