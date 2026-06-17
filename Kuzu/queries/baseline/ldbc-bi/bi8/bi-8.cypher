// Q8. Central Person for a Tag
// Kuzu adaptation: rewrites Neo4j pattern comprehensions as optional matches.
MATCH (tag:TAG {name: $tag}), (person:PERSON)
OPTIONAL MATCH (person)-[interest:HASINTEREST]->(tag)
OPTIONAL MATCH (person)<-[:HASCREATOR]-(message:POST:COMMENT)-[:HASTAG]->(tag)
  WHERE $startDate < message.creationDate AND message.creationDate < $endDate
WITH
  tag,
  person,
  100 * count(DISTINCT interest) + count(DISTINCT message) AS score
WHERE score > 0
OPTIONAL MATCH (person)-[:KNOWS]-(friend:PERSON)
OPTIONAL MATCH (friend)-[friendInterest:HASINTEREST]->(tag)
OPTIONAL MATCH (friend)<-[:HASCREATOR]-(friendMessage:POST:COMMENT)-[:HASTAG]->(tag)
  WHERE $startDate < friendMessage.creationDate AND friendMessage.creationDate < $endDate
WITH
  person,
  score,
  count(DISTINCT friendInterest) AS friendInterestCount,
  count(DISTINCT friendMessage) AS friendMessageCount
WITH
  person,
  score,
  100 * friendInterestCount + friendMessageCount AS friendsScore
RETURN
  person.id AS personId,
  score,
  friendsScore
ORDER BY score + friendsScore DESC, personId ASC
LIMIT 100
