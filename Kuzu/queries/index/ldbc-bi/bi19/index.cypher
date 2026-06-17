// Source: Neug bi19a fill_weight_bi19.cypher.

ALTER TABLE KNOWS DROP IF EXISTS weight_bi19;
ALTER TABLE KNOWS ADD weight_bi19 DOUBLE DEFAULT 10000000000000.0;

MATCH (:PERSON)-[knows:KNOWS]->(:PERSON)
SET knows.weight_bi19 = 10000000000000.0;

MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
MATCH (pA)<-[:HASCREATOR]-(m1:POST:COMMENT)-[:REPLYOF]-(m2:POST:COMMENT)-[:HASCREATOR]->(pB)
WITH knows, count(m1) AS numInteractions
SET knows.weight_bi19 =
    CASE WHEN round(40.0 - sqrt(CAST(numInteractions AS DOUBLE)), 0) > 1.0
         THEN round(40.0 - sqrt(CAST(numInteractions AS DOUBLE)), 0)
         ELSE 1.0
    END;
