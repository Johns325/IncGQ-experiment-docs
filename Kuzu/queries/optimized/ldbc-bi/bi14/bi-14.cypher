// Q14. Uses KNOWS.bi14_case* from queries/index/ldbc-bi/bi14/index.cypher for reply-interaction cases.
MATCH
  (country1:PLACE {name: $country1})<-[:ISPARTOF]-(city1:PLACE)<-[:ISLOCATEDIN]-(person1:PERSON),
  (country2:PLACE {name: $country2})<-[:ISPARTOF]-(city2:PLACE)<-[:ISLOCATEDIN]-(person2:PERSON),
  (person1)-[knows:KNOWS]-(person2)
WHERE country1.type = 'country'
  AND country2.type = 'country'
  AND city1.type = 'city'
  AND city2.type = 'city'
WITH person1, person2, city1, knows,
  CASE WHEN person1 = START_NODE(knows) THEN knows.bi14_case1_fwd ELSE knows.bi14_case1_rev END AS case1Count,
  CASE WHEN person1 = START_NODE(knows) THEN knows.bi14_case2_fwd ELSE knows.bi14_case2_rev END AS case2Count
WITH person1, person2, city1,
     CASE WHEN case1Count = 0 THEN 0 ELSE 4 END
     + CASE WHEN case2Count = 0 THEN 0 ELSE 1 END AS score
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
