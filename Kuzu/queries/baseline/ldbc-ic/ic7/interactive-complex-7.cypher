// Q7. Recent likers
// Parameters for Kuzu Python:
//   personId: INT64
MATCH (person:PERSON {id: $personId})<-[:HASCREATOR]-(message)<-[like:LIKES]-(liker:PERSON)
WHERE label(message) = 'POST' OR label(message) = 'COMMENT'
WITH liker, person, max(like.creationDate) AS likeCreationDate
MATCH (person)<-[:HASCREATOR]-(message)<-[like:LIKES]-(liker)
WHERE (label(message) = 'POST' OR label(message) = 'COMMENT')
  AND like.creationDate = likeCreationDate
WITH liker, person, likeCreationDate, min(message.id) AS commentOrPostId
MATCH (person)<-[:HASCREATOR]-(message {id: commentOrPostId})<-[like:LIKES]-(liker)
WHERE (label(message) = 'POST' OR label(message) = 'COMMENT')
  AND like.creationDate = likeCreationDate
WITH liker, person, message, likeCreationDate, like.creationDate - message.creationDate AS latency
RETURN liker.id AS personId,
       liker.firstName AS personFirstName,
       liker.lastName AS personLastName,
       likeCreationDate AS likeCreationDate,
       message.id AS commentOrPostId,
       coalesce(message.content, message.imageFile) AS commentOrPostContent,
       date_part('day', latency) * 1440 + date_part('hour', latency) * 60 + date_part('minute', latency) AS minutesLatency,
       NOT ((liker)-[:KNOWS]-(person)) AS isNew
ORDER BY likeCreationDate DESC, personId ASC
LIMIT 20
