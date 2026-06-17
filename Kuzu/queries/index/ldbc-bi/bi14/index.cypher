// Source: Neug bi14a setup_add_case*.cypher and setup_fill_case*.cypher.

ALTER TABLE KNOWS DROP IF EXISTS bi14_case1_fwd;
ALTER TABLE KNOWS DROP IF EXISTS bi14_case1_rev;
ALTER TABLE KNOWS DROP IF EXISTS bi14_case2_fwd;
ALTER TABLE KNOWS DROP IF EXISTS bi14_case2_rev;
ALTER TABLE KNOWS ADD bi14_case1_fwd INT64 DEFAULT 0;
ALTER TABLE KNOWS ADD bi14_case1_rev INT64 DEFAULT 0;
ALTER TABLE KNOWS ADD bi14_case2_fwd INT64 DEFAULT 0;
ALTER TABLE KNOWS ADD bi14_case2_rev INT64 DEFAULT 0;

MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
WITH knows, pA, pB,
     count {
       MATCH (pA)<-[:HASCREATOR]-(:COMMENT)-[:REPLYOF]->(:POST:COMMENT)-[:HASCREATOR]->(pB)
     } AS cnt
SET knows.bi14_case1_fwd = cnt;

MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
WITH knows, pA, pB,
     count {
       MATCH (pB)<-[:HASCREATOR]-(:COMMENT)-[:REPLYOF]->(:POST:COMMENT)-[:HASCREATOR]->(pA)
     } AS cnt
SET knows.bi14_case1_rev = cnt;

MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
WITH knows, pA, pB,
     count {
       MATCH (pA)<-[:HASCREATOR]-(:POST:COMMENT)<-[:REPLYOF]-(:COMMENT)-[:HASCREATOR]->(pB)
     } AS cnt
SET knows.bi14_case2_fwd = cnt;

MATCH (pA:PERSON)-[knows:KNOWS]->(pB:PERSON)
WITH knows, pA, pB,
     count {
       MATCH (pB)<-[:HASCREATOR]-(:POST:COMMENT)<-[:REPLYOF]-(:COMMENT)-[:HASCREATOR]->(pA)
     } AS cnt
SET knows.bi14_case2_rev = cnt;
