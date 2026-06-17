FILL HASMEMBER(postCount) FROM (
MATCH (friend:PERSON)<-[:HASCREATOR]-(post)<-[:CONTAINEROF]-(forum:FORUM)
WITH forum, friend, count(post) AS postCount
MATCH (forum)-[:HASMEMBER]->(friend)
RETURN forum.id, friend.id, postCount);
