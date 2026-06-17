MATCH (tag:Tag {name: '{}'})
MATCH (comment:COMMENT)-[:HASTAG]->(tag)
MATCH (comment)-[:HASCREATOR]->(person2:PERSON)<-[:HASMEMBER]-(forum1:FORUM)
MATCH (comment)-[:REPLYOF]->(message2:COMMENT:POST)
MATCH (message2)-[:HASTAG]->(tag)
MATCH (message2)-[:HASCREATOR]->(person3:PERSON)<-[:HASMEMBER]-(forum1)
MATCH (message2)-[:REPLYOF*0..4294967295]->(post2:Post)<-[:CONTAINEROF]-(forum2:FORUM)
WHERE person2 <> person3
  AND forum1 <> forum2
WITH DISTINCT tag, forum1, forum2, message2,
     message2.creationDate AS message2CreationDate
MATCH (message1:COMMENT:POST)-[:HASTAG]->(tag)
MATCH (message1)-[:HASCREATOR]->(person1:PERSON)
MATCH (message1)-[:REPLYOF*0..4294967295]->(post1:Post)<-[:CONTAINEROF]-(forum1)
WHERE message2CreationDate > message1.creationDate + INTERVAL('{} HOURS')
WITH person1, message2, forum2
OPTIONAL MATCH (forum2)-[person1Forum2Member:HASMEMBER]->(person1)
WITH person1, message2, person1Forum2Member
WHERE person1Forum2Member IS NULL
RETURN person1.id, count(DISTINCT message2) AS messageCount
ORDER BY messageCount DESC, person1.id ASC
LIMIT 10
