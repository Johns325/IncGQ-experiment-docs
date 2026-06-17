// Q8. Recent replies
// Parameters for Kuzu Python:
//   personId: INT64
MATCH (start:PERSON {id: $personId})<-[:HASCREATOR]-(message)<-[:REPLYOF]-(comment:COMMENT)-[:HASCREATOR]->(person:PERSON)
WHERE label(message) = 'POST' OR label(message) = 'COMMENT'
RETURN person.id AS personId,
       person.firstName AS personFirstName,
       person.lastName AS personLastName,
       comment.creationDate AS commentCreationDate,
       comment.id AS commentId,
       comment.content AS commentContent
ORDER BY commentCreationDate DESC, commentId ASC
LIMIT 20
