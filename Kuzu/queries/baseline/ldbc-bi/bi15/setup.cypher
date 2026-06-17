ALTER TABLE KNOWS ADD IF NOT EXISTS weight_bi15 DOUBLE DEFAULT 1.0;
MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
MATCH (pA)<-[:HASCREATOR]-(m1:POST:COMMENT)-[:REPLYOF]-(m2:POST:COMMENT)-[:HASCREATOR]->(pB)
MATCH (m1)-[:REPLYOF*0..]->(:POST)<-[:CONTAINEROF]-(forum:FORUM)
WITH knows,
    sum(CASE (label(m1) = 'POST' OR label(m2) = 'POST')
        WHEN true THEN 1.0
        ELSE 0.5 END
    ) AS w
SET knows.weight_bi15 = 1.0 / (w + 1.0);
