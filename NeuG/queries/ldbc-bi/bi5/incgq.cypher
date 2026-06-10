MATCH (tag:Tag {name: '{}'})<-[:HASTAG]-(message:COMMENT:POST)-[:HASCREATOR]->(person:PERSON)
WITH person,
     count(message) AS messageCount,
     sum(message.likeCount) AS likeCount,
     sum(message.replyCount) AS replyCount
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
