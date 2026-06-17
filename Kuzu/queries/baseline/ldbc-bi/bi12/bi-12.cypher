// Q12. How many persons have a given number of posts
// Kuzu adaptation: Message is represented by the POST:COMMENT union.
MATCH (person:PERSON)
OPTIONAL MATCH (person)<-[:HASCREATOR]-(message:POST:COMMENT)-[:REPLYOF*0..]->(post:POST)
WHERE message.content IS NOT NULL
  AND message.length < $lengthThreshold
  AND message.creationDate > $startDate
  AND post.language IN $languages
WITH person, count(message) AS messageCount
RETURN
  messageCount,
  count(person) AS personCount
ORDER BY personCount DESC, messageCount DESC
