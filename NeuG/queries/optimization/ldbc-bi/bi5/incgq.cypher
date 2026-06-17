MATCH (tag:TAG {name: '{}'})<-[:HASTAG]-(message:COMMENT:POST)-[:HASCREATOR]->(person:PERSON)
OPTIONAL MATCH (message)<-[:LIKES]-(liker:PERSON)
WITH person, message, count(liker) AS likeCount
OPTIONAL MATCH (message)<-[:REPLYOF]-(reply:COMMENT)
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
LIMIT 100;