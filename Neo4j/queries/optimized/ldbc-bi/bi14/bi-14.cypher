// Q14. Uses KNOWS.bi14_case* from queries/index/ldbc-bi/bi14/index.cypher for reply-interaction cases.
MATCH
  (country1:Country {name: $country1})<-[:IS_PART_OF]-(city1:City)<-[:IS_LOCATED_IN]-(person1:Person),
  (country2:Country {name: $country2})<-[:IS_PART_OF]-(city2:City)<-[:IS_LOCATED_IN]-(person2:Person),
  (person1)-[knows:KNOWS]-(person2)
WITH person1, person2, city1, knows,
     CASE WHEN person1 = startNode(knows) THEN knows.bi14_case1_fwd ELSE knows.bi14_case1_rev END AS case1Count,
     CASE WHEN person1 = startNode(knows) THEN knows.bi14_case2_fwd ELSE knows.bi14_case2_rev END AS case2Count
WITH person1, person2, city1,
     CASE WHEN case1Count = 0 THEN 0 ELSE 4 END
     + CASE WHEN case2Count = 0 THEN 0 ELSE 1 END AS score
OPTIONAL MATCH (person1)-[:LIKES]->(m:Message)-[:HAS_CREATOR]->(person2)
WITH DISTINCT person1, person2, city1, score + (CASE WHEN m IS NULL THEN 0 ELSE 10 END) AS score
OPTIONAL MATCH (person1)<-[:HAS_CREATOR]-(m:Message)<-[:LIKES]-(person2)
WITH DISTINCT person1, person2, city1, score + (CASE WHEN m IS NULL THEN 0 ELSE 1 END) AS score
ORDER BY city1.name ASC, score DESC, person1.id ASC, person2.id ASC
WITH city1, collect({score: score, person1Id: person1.id, person2Id: person2.id})[0] AS top
RETURN top.person1Id AS person1Id,
       top.person2Id AS person2Id,
       city1.name AS cityName,
       top.score AS score
ORDER BY score DESC, person1Id ASC, person2Id ASC
LIMIT 100
