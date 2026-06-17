// Q17. Information propagation analysis
// Kuzu adaptation: follows the existing Kuzu/NeuG-style decomposition and parameterizes tag/delta.
MATCH
  (message1:POST:COMMENT)-[:REPLYOF*0..]->(post1:POST)<-[:CONTAINEROF]-(forum1:FORUM),
  (message1)-[:HASTAG]->(tag:TAG {name: $tag}),
  (forum1)-[:HASMEMBER]-(person2:PERSON)<-[:HASCREATOR]-(comment:COMMENT)-[:HASTAG]->(tag)
WITH DISTINCT tag, message1, forum1, comment
MATCH (comment)-[:REPLYOF]->(message2)-[:HASTAG]->(tag)
WHERE message1.creationDate + duration(CAST($delta AS STRING) + ' hours') < message2.creationDate
WITH DISTINCT message1, forum1 AS m1_forum1, message2
MATCH (message1)-[:HASCREATOR]->(person1:PERSON)<-[:HASMEMBER]-(forum2:FORUM)
WITH message1, person1, m1_forum1, message2, collect(forum2) AS m1_forum2
MATCH (message2)-[:REPLYOF*0..]->(post2:POST)<-[:CONTAINEROF]-(m2_forum1:FORUM)
MATCH (message2)-[:HASCREATOR]->(person3:PERSON)<-[:HASMEMBER]-(m2_forum2:FORUM)
WHERE m1_forum1 = m2_forum2
  AND NOT (m2_forum1 IN m1_forum2)
WITH DISTINCT person1, message2
RETURN person1.id AS personId, count(DISTINCT message2) AS messageCount
ORDER BY messageCount DESC, personId ASC
LIMIT 10
