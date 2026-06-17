// Source-aligned with Kuzu queries/index/ldbc-bi/bi14/index.cypher.
MATCH ()-[knows:KNOWS]->() REMOVE knows.bi14_case1_fwd, knows.bi14_case1_rev, knows.bi14_case2_fwd, knows.bi14_case2_rev;
MATCH (pA:Person)-[knows:KNOWS]->(pB:Person)
WITH knows, pA, pB,
     count {
       MATCH (pA)<-[:HAS_CREATOR]-(:Comment)-[:REPLY_OF]->(:Message)-[:HAS_CREATOR]->(pB)
     } AS cnt
SET knows.bi14_case1_fwd = cnt;
MATCH (pA:Person)-[knows:KNOWS]->(pB:Person)
WITH knows, pA, pB,
     count {
       MATCH (pB)<-[:HAS_CREATOR]-(:Comment)-[:REPLY_OF]->(:Message)-[:HAS_CREATOR]->(pA)
     } AS cnt
SET knows.bi14_case1_rev = cnt;
MATCH (pA:Person)-[knows:KNOWS]->(pB:Person)
WITH knows, pA, pB,
     count {
       MATCH (pA)<-[:HAS_CREATOR]-(:Message)<-[:REPLY_OF]-(:Comment)-[:HAS_CREATOR]->(pB)
     } AS cnt
SET knows.bi14_case2_fwd = cnt;
MATCH (pA:Person)-[knows:KNOWS]->(pB:Person)
WITH knows, pA, pB,
     count {
       MATCH (pB)<-[:HAS_CREATOR]-(:Message)<-[:REPLY_OF]-(:Comment)-[:HAS_CREATOR]->(pA)
     } AS cnt
SET knows.bi14_case2_rev = cnt;
