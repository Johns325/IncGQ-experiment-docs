MATCH (forum:FORUM)-[membership:HASMEMBER]->(friend:PERSON)
WITH forum, friend, membership
MATCH (friend)<-[:HASCREATOR]-(post)<-[:CONTAINEROF]-(forum)
WITH membership, count(*) AS postCount
SET membership.postCount = postCount;
