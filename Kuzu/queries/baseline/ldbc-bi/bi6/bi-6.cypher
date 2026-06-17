// Q6. Most authoritative users on a given topic
// Kuzu adaptation: Message is represented by the POST:COMMENT union.
MATCH (tag:TAG {name: $tag})<-[:HASTAG]-(message1:POST:COMMENT)-[:HASCREATOR]->(person1:PERSON)
OPTIONAL MATCH (message1)<-[:LIKES]-(person2:PERSON)
OPTIONAL MATCH (person2)<-[:HASCREATOR]-(message2:POST:COMMENT)<-[like:LIKES]-(person3:PERSON)
RETURN
  person1.id AS personId,
  count(DISTINCT like) AS authorityScore
ORDER BY authorityScore DESC, personId ASC
LIMIT 100
