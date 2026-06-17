// Q9. Recent messages by friends or friends of friends
// Parameters for Kuzu Python:
//   personId: INT64, maxDate: datetime.datetime
MATCH (root:PERSON {id: $personId})-[:KNOWS*1..2]-(friend:PERSON)
WHERE NOT friend = root
WITH DISTINCT friend
MATCH (friend)<-[:HASCREATOR]-(message)
WHERE message.creationDate < $maxDate
  AND (label(message) = 'POST' OR label(message) = 'COMMENT')
RETURN friend.id AS personId,
       friend.firstName AS personFirstName,
       friend.lastName AS personLastName,
       message.id AS commentOrPostId,
       coalesce(message.content, message.imageFile) AS commentOrPostContent,
       message.creationDate AS commentOrPostCreationDate
ORDER BY commentOrPostCreationDate DESC, commentOrPostId ASC
LIMIT 20
