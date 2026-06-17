FILL KNOWS(bi14_case1_fwd) FROM (
MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
WITH pA, pB
MATCH (pA)<-[:HASCREATOR]-(c:COMMENT)-[:REPLYOF]->(:COMMENT:POST)-[:HASCREATOR]->(pB)
RETURN pA.id, pB.id, count(c) AS cnt);
