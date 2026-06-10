// q23; freq=1; rpq=(<412>)+|<586>; readable=(<P412>)+|<P586>
MATCH p47_0 = (s)-[:P412*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p47_1 = (s)-[:P586]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
