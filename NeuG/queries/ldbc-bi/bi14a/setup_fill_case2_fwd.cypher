FILL KNOWS(bi14_case2_fwd) FROM (
MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
WITH pA, pB
MATCH (pA)<-[:HASCREATOR]-(m:COMMENT:POST)<-[:REPLYOF]-(:COMMENT)-[:HASCREATOR]->(pB)
RETURN pA.id, pB.id, count(m) AS cnt);
