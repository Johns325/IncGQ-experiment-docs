// q9; freq=1; rpq=((<176>|<196>))+|<12>; readable=((<P176>|<P196>))+|<P12>
MATCH p153_0 = (s)-[:P176|P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p153_1 = (s)-[:P12]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
