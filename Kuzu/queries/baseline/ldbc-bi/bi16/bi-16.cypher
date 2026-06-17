// Q16. Fake news detection
// Kuzu adaptation: replaces Neo4j CALL subquery with explicit A/B branches in a single pipeline.
MATCH (person1:PERSON)
OPTIONAL MATCH (person1)<-[:HASCREATOR]-(messageA:POST:COMMENT)-[:HASTAG]->(:TAG {name: $tagA})
WHERE date(messageA.creationDate) = date($dateA)
WITH person1, count(DISTINCT messageA) AS messageCountA
WHERE messageCountA > 0
OPTIONAL MATCH (person1)-[:KNOWS]-(friendA:PERSON)<-[:HASCREATOR]-(friendMessageA:POST:COMMENT)-[:HASTAG]->(:TAG {name: $tagA})
WHERE date(friendMessageA.creationDate) = date($dateA)
WITH person1, messageCountA, count(DISTINCT friendA) AS friendCountA
WHERE friendCountA <= $maxKnowsLimit
OPTIONAL MATCH (person1)<-[:HASCREATOR]-(messageB:POST:COMMENT)-[:HASTAG]->(:TAG {name: $tagB})
WHERE date(messageB.creationDate) = date($dateB)
WITH person1, messageCountA, count(DISTINCT messageB) AS messageCountB
WHERE messageCountB > 0
OPTIONAL MATCH (person1)-[:KNOWS]-(friendB:PERSON)<-[:HASCREATOR]-(friendMessageB:POST:COMMENT)-[:HASTAG]->(:TAG {name: $tagB})
WHERE date(friendMessageB.creationDate) = date($dateB)
WITH person1, messageCountA, messageCountB, count(DISTINCT friendB) AS friendCountB
WHERE friendCountB <= $maxKnowsLimit
RETURN
  person1.id AS personId,
  messageCountA,
  messageCountB
ORDER BY messageCountA + messageCountB DESC, personId ASC
LIMIT 20
