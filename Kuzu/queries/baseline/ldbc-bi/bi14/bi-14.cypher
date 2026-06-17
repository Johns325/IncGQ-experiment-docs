// Q14. International dialog
// Kuzu adaptation: Country/City are PLACE rows and Message is POST:COMMENT.
MATCH
  (country1:PLACE {name: $country1})<-[:ISPARTOF]-(city1:PLACE)<-[:ISLOCATEDIN]-(person1:PERSON),
  (country2:PLACE {name: $country2})<-[:ISPARTOF]-(city2:PLACE)<-[:ISLOCATEDIN]-(person2:PERSON),
  (person1)-[:KNOWS]-(person2)
WHERE country1.type = 'country'
  AND country2.type = 'country'
  AND city1.type = 'city'
  AND city2.type = 'city'
WITH person1, person2, city1, 0 AS score
OPTIONAL MATCH (person1)<-[:HASCREATOR]-(c:COMMENT)-[:REPLYOF]->(:POST:COMMENT)-[:HASCREATOR]->(person2)
WITH DISTINCT person1, person2, city1, score + (CASE WHEN c IS NULL THEN 0 ELSE 4 END) AS score
OPTIONAL MATCH (person1)<-[:HASCREATOR]-(m:POST:COMMENT)<-[:REPLYOF]-(:COMMENT)-[:HASCREATOR]->(person2)
WITH DISTINCT person1, person2, city1, score + (CASE WHEN m IS NULL THEN 0 ELSE 1 END) AS score
OPTIONAL MATCH (person1)-[:LIKES]->(m:POST:COMMENT)-[:HASCREATOR]->(person2)
WITH DISTINCT person1, person2, city1, score + (CASE WHEN m IS NULL THEN 0 ELSE 10 END) AS score
OPTIONAL MATCH (person1)<-[:HASCREATOR]-(m:POST:COMMENT)<-[:LIKES]-(person2)
WITH DISTINCT person1, person2, city1, score + (CASE WHEN m IS NULL THEN 0 ELSE 1 END) AS score
ORDER BY city1.name ASC, score DESC, person1.id ASC, person2.id ASC
LIMIT 1000000000
WITH city1, collect(person1.id)[0] AS person1Id, collect(person2.id)[0] AS person2Id, collect(score)[0] AS score
RETURN
  person1Id,
  person2Id,
  city1.name AS cityName,
  score
ORDER BY score DESC, person1Id ASC, person2Id ASC
LIMIT 100
