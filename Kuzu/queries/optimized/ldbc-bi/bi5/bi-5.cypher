// Q5. Uses likeCount/replyCount from queries/index/ldbc-bi/bi5/index.cypher.
MATCH (tag:TAG {name: $tag})<-[:HASTAG]-(message:POST:COMMENT)-[:HASCREATOR]->(person:PERSON)
WITH person,
     count(message) AS messageCount,
     sum(message.likeCount) AS likeCount,
     sum(message.replyCount) AS replyCount
RETURN
  person.id AS personId,
  replyCount,
  likeCount,
  messageCount,
  messageCount + 2 * replyCount + 10 * likeCount AS score
ORDER BY score DESC, personId ASC
LIMIT 100
