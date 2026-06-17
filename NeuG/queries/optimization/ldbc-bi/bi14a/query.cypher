MATCH
(country1:PLACE {name: '{}'})<-[:ISPARTOF]-(city1:PLACE)<-[:ISLOCATEDIN]-(person1:PERSON),
(country2:PLACE {name: '{}'})<-[:ISPARTOF]-(city2:PLACE)<-[:ISLOCATEDIN]-(person2:PERSON),
(person1)-[knows:KNOWS]-(person2)
OPTIONAL MATCH (person1)<-[:HASCREATOR]-(c:COMMENT)-[:REPLYOF]->(:POST:COMMENT)-[:HASCREATOR]->(person2)
WITH person1, person2, city1, knows, count(c) AS c_count
WITH person1, person2, city1, knows, CASE WHEN c_count = 0 THEN 0 ELSE 4 END AS s1
OPTIONAL MATCH (person1)<-[:HASCREATOR]-(m:COMMENT:POST)<-[:REPLYOF]-(:COMMENT)-[:HASCREATOR]->(person2)
WITH person1, person2, city1, knows, s1, count(m) AS m_count
WITH person1, person2, city1, knows, s1, CASE WHEN m_count = 0 THEN 0 ELSE 1 END AS s2
OPTIONAL MATCH (person1)-[:LIKES]->(m:POST:COMMENT)-[:HASCREATOR]->(person2)
WITH person1, person2, city1, knows, s1, s2, count(m) AS m_count
WITH person1, person2, city1, knows, s1, s2, CASE WHEN m_count = 0 THEN 0 ELSE 10 END AS s3
OPTIONAL MATCH (person1)<-[:HASCREATOR]-(m:POST:COMMENT)<-[:LIKES]-(person2)
WITH person1, person2, city1, knows, s1, s2, s3, count(m) AS m_count
WITH person1, person2, city1, s1 + s2 + s3 + CASE WHEN m_count = 0 THEN 0 ELSE 1 END AS score
ORDER BY city1.name ASC, score DESC, person1.id ASC, person2.id ASC
WITH city1, COLLECT(person1.id)[0] AS person1Id, COLLECT(person2.id)[0] AS person2Id, COLLECT(score)[0] AS score
RETURN person1Id, person2Id, city1.name AS cityName, score
ORDER BY score DESC, person1Id ASC, person2Id ASC
LIMIT 100
