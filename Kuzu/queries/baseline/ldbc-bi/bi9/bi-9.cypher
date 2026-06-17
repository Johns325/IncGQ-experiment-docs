// Q9. Top thread initiators
// Kuzu adaptation: Message is represented by the POST:COMMENT union.
MATCH (person:PERSON)<-[:HASCREATOR]-(post:POST)<-[:REPLYOF*0..]-(reply:POST:COMMENT)
WHERE post.creationDate >= $startDate
  AND post.creationDate <= $endDate
  AND reply.creationDate >= $startDate
  AND reply.creationDate <= $endDate
RETURN
  person.id AS personId,
  person.firstName AS personFirstName,
  person.lastName AS personLastName,
  count(DISTINCT post) AS threadCount,
  count(DISTINCT reply) AS messageCount
ORDER BY messageCount DESC, personId ASC
LIMIT 100
