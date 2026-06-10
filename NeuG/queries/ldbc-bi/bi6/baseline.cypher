MATCH (tag:Tag {name: '{}'})<-[:HASTAG]-(message1:COMMENT:POST)-[:HASCREATOR]->(person1:Person)
OPTIONAL MATCH (message1)<-[:LIKES]-(person2:Person)
OPTIONAL MATCH (person2)<-[:HASCREATOR]-(message2:COMMENT:POST)<-[like:LIKES]-(person3:Person)
RETURN person1.id, count(DISTINCT like) AS authorityScore
ORDER BY authorityScore DESC, person1.id ASC
LIMIT 100;
