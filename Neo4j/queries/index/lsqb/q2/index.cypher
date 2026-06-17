// Source-aligned with Kuzu queries/index/lsqb/q2/index.cypher.
MATCH ()-[knows:KNOWS]->() REMOVE knows.q2_cnt_fwd, knows.q2_cnt_rev;
MATCH (person1:Person)-[knows:KNOWS]->(person2:Person)
WITH knows, person1, person2,
     count {
       MATCH (person1)<-[:HAS_CREATOR]-(:Comment)-[:REPLY_OF]->(:Post)-[:HAS_CREATOR]->(person2)
     } AS cnt_fwd,
     count {
       MATCH (person2)<-[:HAS_CREATOR]-(:Comment)-[:REPLY_OF]->(:Post)-[:HAS_CREATOR]->(person1)
     } AS cnt_rev
SET knows.q2_cnt_fwd = cnt_fwd,
    knows.q2_cnt_rev = cnt_rev;
