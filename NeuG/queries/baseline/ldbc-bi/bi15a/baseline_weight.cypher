MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
OPTIONAL MATCH
  (pA)<-[:HASCREATOR]-(m1:COMMENT:POST)-[:REPLYOF]-(m2:COMMENT:POST)-[:HASCREATOR]->(pB),
  (m1)-[:REPLYOF*0..]->(p:POST)<-[:CONTAINEROF]-(forum:FORUM)
WITH pA, pB, knows,
     sum(
       CASE forum IS NOT NULL
       WHEN TRUE THEN
         CASE (label(m1) = 'POST' OR label(m2) = 'POST')
         WHEN TRUE THEN 1.0
         ELSE 0.5
         END
       ELSE 0.0
       END
     ) AS w
SET knows.weight = 1.0 / (w + 1.0);
