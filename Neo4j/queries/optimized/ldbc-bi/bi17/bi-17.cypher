// Q17. Uses Message.rootForumId from queries/index/ldbc-bi/bi17/index.cypher.
MATCH (tag:Tag {name: $tag})
MATCH (comment:Comment)-[:HAS_TAG]->(tag)
MATCH (comment)-[:HAS_CREATOR]->(person2:Person)<-[:HAS_MEMBER]-(forum1:Forum)
MATCH (comment)-[:REPLY_OF]->(message2:Message)
MATCH (message2)-[:HAS_TAG]->(tag)
MATCH (message2)-[:HAS_CREATOR]->(person3:Person)<-[:HAS_MEMBER]-(forum1)
WHERE person2 <> person3
WITH DISTINCT tag, forum1, message2,
     message2.rootForumId AS forum2Id,
     message2.creationDate AS message2CreationDate
MATCH (message1:Message)-[:HAS_TAG]->(tag)
MATCH (message1)-[:HAS_CREATOR]->(person1:Person)
WHERE forum1.id = message1.rootForumId
  AND message1.creationDate + duration({hours: $delta}) < message2CreationDate
WITH person1, message2, forum2Id
OPTIONAL MATCH (person1)<-[:HAS_MEMBER]-(person1Forum:Forum)
WITH person1, message2, forum2Id, collect(person1Forum.id) AS person1ForumIds
WHERE NOT forum2Id IN person1ForumIds
RETURN person1.id AS personId, count(DISTINCT message2) AS messageCount
ORDER BY messageCount DESC, personId ASC
LIMIT 10
