MATCH (tag:Tag {name: '{}'})
MATCH (comment:COMMENT)-[:HASTAG]->(tag)
MATCH (comment)-[:HASCREATOR]->(person2:PERSON)<-[:HASMEMBER]-(forum1:FORUM)
MATCH (comment)-[:REPLYOF]->(message2:COMMENT:POST)
MATCH (message2)-[:HASTAG]->(tag)
MATCH (message2)-[:HASCREATOR]->(person3:PERSON)<-[:HASMEMBER]-(forum1)
WHERE person2 <> person3
  AND forum1.id <> message2.rootForumId
WITH DISTINCT tag, forum1, message2,
     message2.rootForumId AS forum2Id,
     message2.creationDate AS message2CreationDate
MATCH (message1:COMMENT:POST)-[:HASTAG]->(tag)
MATCH (message1)-[:HASCREATOR]->(person1:PERSON)
WHERE forum1.id = message1.rootForumId
  AND message2CreationDate > message1.creationDate + INTERVAL('{} HOURS')
WITH person1, message2, forum2Id
OPTIONAL MATCH (person1)<-[:HASMEMBER]-(person1Forum:FORUM)
WITH person1, message2, forum2Id, collect(person1Forum.id) AS person1ForumIds
WHERE (forum2Id IN person1ForumIds) = FALSE
RETURN person1.id, count(DISTINCT message2) AS messageCount
ORDER BY messageCount DESC, person1.id ASC
LIMIT 10
