MATCH (p:PERSON {id: {}})-[:KNOWS*1..2]-(otherP:PERSON)
WITH distinct otherP
WHERE otherP.id <> {}
MATCH (country:PLACE)<-[:ISLOCATEDIN]-(message:POST:COMMENT)-[:HASCREATOR]->(otherP:PERSON)-[ISLOCATEDIN]->(city:PLACE)-[:ISPARTOF]-> (country2:PLACE)
WHERE  (country.name = '{}' OR country.name = '{}')
  AND message.creationDate >= TIMESTAMP('{}')
  AND message.creationDate < TIMESTAMP('{}')
WITH  message, otherP,  country,country2
WHERE (country2.name <> '{}' AND country2.name <> '{}')
WITH otherP, CASE WHEN country.name='{}' THEN 1 ELSE 0 END AS messageX, CASE WHEN country.name='{}' THEN 1 ELSE 0 END AS messageY
WITH otherP, sum(messageX) AS xCount, sum(messageY) AS yCount
WHERE xCount > 0 AND yCount > 0
RETURN otherP.id as id,otherP.firstName as firstName,  otherP.lastName as lastName, xCount,yCount, xCount + yCount as total
ORDER BY total DESC, id ASC LIMIT 20;
