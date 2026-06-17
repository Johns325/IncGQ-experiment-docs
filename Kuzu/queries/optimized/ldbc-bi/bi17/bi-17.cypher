// Q17. Uses rootPostId/rootForumId from queries/index/ldbc-bi/bi17/index.cypher.
MATCH (tag:TAG {name: $tag})
MATCH (comment:COMMENT)-[:HASTAG]->(tag)
MATCH (comment)-[:HASCREATOR]->(person2:PERSON)<-[:HASMEMBER]-(forum1:FORUM)
MATCH (comment)-[:REPLYOF]->(message2:POST:COMMENT)
MATCH (message2)-[:HASTAG]->(tag)
MATCH (message2)-[:HASCREATOR]->(person3:PERSON)<-[:HASMEMBER]-(forum1)
WHERE person2 <> person3
WITH DISTINCT tag, forum1, message2,
     message2.rootForumId AS forum2Id,
     message2.creationDate AS message2CreationDate
MATCH (message1:POST:COMMENT)-[:HASTAG]->(tag)
MATCH (message1)-[:HASCREATOR]->(person1:PERSON)
WHERE forum1.id = message1.rootForumId
  AND message1.creationDate + duration(CAST($delta AS STRING) + ' hours') < message2CreationDate
WITH person1, message2, forum2Id
OPTIONAL MATCH (person1)<-[:HASMEMBER]-(person1Forum:FORUM)
WITH person1, message2, forum2Id, collect(person1Forum.id) AS person1ForumIds
WHERE NOT forum2Id IN person1ForumIds
RETURN person1.id AS personId, count(DISTINCT message2) AS messageCount
ORDER BY messageCount DESC, personId ASC
LIMIT 10
