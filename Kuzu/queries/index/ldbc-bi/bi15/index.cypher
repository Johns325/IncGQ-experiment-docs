// Source: Neug bi15a setup_add_bi15_weight.cypher and setup_fill_bi15_weight.cypher.
// Materializes Neug's property name: KNOWS.bi15_weight.

ALTER TABLE KNOWS DROP IF EXISTS bi15_weight;
ALTER TABLE KNOWS ADD bi15_weight DOUBLE DEFAULT 1.0;

MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
MATCH (pA)<-[:HASCREATOR]-(m1:POST:COMMENT)-[:REPLYOF]-(m2:POST:COMMENT)-[:HASCREATOR]->(pB)
MATCH (m1)-[:REPLYOF*0..]->(:POST)<-[:CONTAINEROF]-(:FORUM)
WITH knows,
     sum(CASE (label(m1) = 'POST' OR label(m2) = 'POST')
         WHEN true THEN 1.0
         ELSE 0.5 END) AS weight
SET knows.bi15_weight = 1.0 / (weight + 1.0);
