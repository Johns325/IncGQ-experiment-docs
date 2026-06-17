ALTER TABLE HASMEMBER ADD IF NOT EXISTS postCount INT64 DEFAULT 0;
MATCH (:FORUM)-[membership:HASMEMBER]->(:PERSON)
SET membership.postCount = 0;
FILL HASMEMBER(postCount) FROM (
MATCH (friend:PERSON)<-[:HASCREATOR]-(post)<-[:CONTAINEROF]-(forum:FORUM)
WITH forum, friend, count(post) AS postCount
MATCH (forum)-[:HASMEMBER]->(friend)
RETURN forum.id, friend.id, postCount);
MATCH (forum:FORUM)-[membership:HASMEMBER]->(friend:PERSON)
WITH forum, friend, membership
MATCH (friend)<-[:HASCREATOR]-(post)<-[:CONTAINEROF]-(forum)
WITH membership, count(*) AS postCount
SET membership.postCount = postCount;
