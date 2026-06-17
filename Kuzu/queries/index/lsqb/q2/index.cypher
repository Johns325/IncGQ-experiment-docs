// Source: Neug lsqb/q2/index.cypher.
// Materializes directional comment-count summaries on Person_knows_Person.

ALTER TABLE Person_knows_Person DROP IF EXISTS q2_cnt;
ALTER TABLE Person_knows_Person DROP IF EXISTS q2_cnt_fwd;
ALTER TABLE Person_knows_Person DROP IF EXISTS q2_cnt_rev;
ALTER TABLE Person_knows_Person ADD q2_cnt_fwd INT64 DEFAULT 0;
ALTER TABLE Person_knows_Person ADD q2_cnt_rev INT64 DEFAULT 0;

MATCH (person1:Person)-[knows:Person_knows_Person]->(person2:Person)
WITH knows, person1, person2,
     count {
       MATCH (person1)<-[:Comment_hasCreator_Person]-(:Comment)-[:Comment_replyOf_Post]->(:Post)-[:Post_hasCreator_Person]->(person2)
     } AS cnt_fwd,
     count {
       MATCH (person2)<-[:Comment_hasCreator_Person]-(:Comment)-[:Comment_replyOf_Post]->(:Post)-[:Post_hasCreator_Person]->(person1)
     } AS cnt_rev
SET knows.q2_cnt_fwd = cnt_fwd,
    knows.q2_cnt_rev = cnt_rev;
