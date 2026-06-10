MATCH (tag:Tag {name: '{}'})<-[:HASTAG]-(message:COMMENT:POST)-[:HASCREATOR]->(person:PERSON)
OPTIONAL MATCH (message)<-[likes:LIKES]-(:PERSON)
WITH person, message, count(likes) AS likeCount
OPTIONAL MATCH (message)<-[:REPLYOF]-(reply:Comment)
WITH person, message, likeCount, count(reply) AS replyCount
WITH person, count(message) AS messageCount, sum(likeCount) AS likeCount, sum(replyCount) AS replyCount
RETURN
  person.id,
  replyCount,
  likeCount,
  messageCount,
  1*messageCount + 2*replyCount + 10*likeCount AS score
ORDER BY
  score DESC,
  person.id ASC
LIMIT 100
