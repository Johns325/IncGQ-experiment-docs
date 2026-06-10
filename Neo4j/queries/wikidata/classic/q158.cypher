// q158; freq=1; rpq=(<690>)+; readable=(<P690>)+
MATCH p181_0 = (s)-[:P690*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
