// Source: Neug ic14 setup_add_ic14_weight.cypher and setup_fill_ic14_weight.cypher.

ALTER TABLE KNOWS DROP IF EXISTS ic14_weight;
ALTER TABLE KNOWS ADD ic14_weight DOUBLE DEFAULT 0.0;

MATCH (:PERSON)-[knows:KNOWS]->(:PERSON)
SET knows.ic14_weight = 0.0;

MATCH (person1:PERSON)-[knows:KNOWS]->(person2:PERSON)
MATCH (person1)<-[:HASCREATOR]-(n:POST:COMMENT)-[:REPLYOF]-(m:POST:COMMENT)-[:HASCREATOR]->(person2)
WITH knows,
     sum(CASE (label(m) = 'POST' OR label(n) = 'POST')
         WHEN true THEN 1.0
         ELSE 0.5 END) AS weight
SET knows.ic14_weight = weight;
