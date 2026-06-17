// Q5. Most active Posters of a given Topic
// Kuzu adaptation: Message is represented by the POST:COMMENT union.
MATCH (tag:TAG {name: $tag})<-[:HASTAG]-(message:POST:COMMENT)-[:HASCREATOR]->(person:PERSON)
OPTIONAL MATCH (message)<-[likes:LIKES]-(:PERSON)
WITH person, message, count(likes) AS likeCount
OPTIONAL MATCH (message)<-[:REPLYOF]-(reply:COMMENT)
WITH person, message, likeCount, count(reply) AS replyCount
WITH person, count(message) AS messageCount, sum(likeCount) AS likeCount, sum(replyCount) AS replyCount
RETURN
  person.id AS personId,
  replyCount,
  likeCount,
  messageCount,
  messageCount + 2 * replyCount + 10 * likeCount AS score
ORDER BY score DESC, personId ASC
LIMIT 100
