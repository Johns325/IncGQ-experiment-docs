FILL KNOWS(bi14_case2_rev) FROM (
MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
WITH pA, pB
MATCH (pB)<-[:HASCREATOR]-(m:COMMENT:POST)<-[:REPLYOF]-(:COMMENT)-[:HASCREATOR]->(pA)
RETURN pA.id, pB.id, count(m) AS cnt);
