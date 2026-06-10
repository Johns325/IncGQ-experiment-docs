MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
OPTIONAL MATCH
  (pA)<-[:HASCREATOR]-(m1:POST:COMMENT)-[:REPLYOF]-(m2:COMMENT:POST)-[:HASCREATOR]->(pB)
WITH knows, COUNT(m1) AS messageCount
WITH knows, messageCount, ROUND(40.0 - SQRT(messageCount), 0) AS score
SET knows.weight_bi19 =
  CASE messageCount
  WHEN 0 THEN 10000000000000.0
  ELSE CASE WHEN score > 1.0 THEN score ELSE 1.0 END
  END;
