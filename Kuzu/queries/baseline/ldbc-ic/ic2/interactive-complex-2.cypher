// Q2. Recent messages by your friends
// Parameters for Kuzu Python:
//   personId: INT64, maxDate: datetime.datetime
MATCH (:PERSON {id: $personId})-[:KNOWS]-(friend:PERSON)<-[:HASCREATOR]-(message)
WHERE message.creationDate <= $maxDate
  AND (label(message) = 'POST' OR label(message) = 'COMMENT')
RETURN friend.id AS personId,
       friend.firstName AS personFirstName,
       friend.lastName AS personLastName,
       message.id AS postOrCommentId,
       coalesce(message.content, message.imageFile) AS postOrCommentContent,
       message.creationDate AS postOrCommentCreationDate
ORDER BY postOrCommentCreationDate DESC, postOrCommentId ASC
LIMIT 20
