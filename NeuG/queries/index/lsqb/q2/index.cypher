ALTER TABLE Person_knows_Person DROP IF EXISTS q2_cnt;
ALTER TABLE Person_knows_Person ADD IF NOT EXISTS q2_cnt_fwd int64 DEFAULT 0;
ALTER TABLE Person_knows_Person ADD IF NOT EXISTS q2_cnt_rev int64 DEFAULT 0;
FILL Person_knows_Person(q2_cnt_fwd, q2_cnt_rev) FROM (
  MATCH (person1:Person)-[knows:Person_knows_Person]->(person2:Person)
  OPTIONAL MATCH (person1)<-[:Comment_hasCreator_Person]-(commentFwd:Comment)-[:Comment_replyOf_Post]->(postFwd:Post)-[:Post_hasCreator_Person]->(person2)
  OPTIONAL MATCH (person2)<-[:Comment_hasCreator_Person]-(commentRev:Comment)-[:Comment_replyOf_Post]->(postRev:Post)-[:Post_hasCreator_Person]->(person1)
  RETURN person1.PersonId, person2.PersonId,
         count(DISTINCT commentFwd) AS cnt_fwd,
         count(DISTINCT commentRev) AS cnt_rev
);
