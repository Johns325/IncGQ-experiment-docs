FILL KNOWS(weight_bi19) FROM (
  MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON),
        (pA)<-[:HASCREATOR]-(m1:POST:COMMENT)-[:REPLYOF]-(m2:COMMENT:POST)-[:HASCREATOR]->(pB)
  WITH pA, pB, ROUND(40.0 - SQRT(COUNT(m1)), 0) AS score
  RETURN pA.id, pB.id, CASE WHEN score > 1.0 THEN score ELSE 1.0 END);
