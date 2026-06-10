MATCH (tag:Tag {name: '{}'})<-[:HASTAG]-(message1:COMMENT:POST)-[:HASCREATOR]->(person1:Person)
OPTIONAL MATCH (message1)<-[:LIKES]-(person2:Person)
WITH DISTINCT person1, person2
OPTIONAL MATCH (person2)<-[:HASCREATOR]-(message2:COMMENT:POST)<-[like:LIKES]-(person3:Person)
WITH person1, person2, count(person3) AS rewriteProbe
RETURN person1.id, sum(CASE WHEN person2 IS NULL THEN 0 ELSE person2.likeCount END) AS authorityScore
ORDER BY authorityScore DESC, person1.id ASC
LIMIT 100;
