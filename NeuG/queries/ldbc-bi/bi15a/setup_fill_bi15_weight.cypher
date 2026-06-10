FILL KNOWS(bi15_weight) FROM (
  MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
  WITH pA, pB
  MATCH (pA)<-[:HASCREATOR]-(m1:COMMENT:POST)-[:REPLYOF]-(m2:COMMENT:POST)-[:HASCREATOR]->(pB),
        (m1)-[:REPLYOF*0..]->(p:POST)<-[:CONTAINEROF]-(forum:FORUM)
  WITH pA, pB,
      sum(CASE (label(m1) = 'POST' OR label(m2) = 'POST') WHEN TRUE THEN 1.0 ELSE 0.5 END) AS w
  RETURN pA.id, pB.id, 1.0 / (w + 1.0) AS score1);
