// Q3. Uses Person.countryName from queries/index/ldbc-ic/ic3/index.cypher.
MATCH (countryX:Country {name: $countryXName}),
      (countryY:Country {name: $countryYName}),
      (person:Person {id: $personId})
WITH person, countryX, countryY
LIMIT 1
MATCH (person)-[:KNOWS*1..2]-(friend:Person)
WHERE NOT person = friend
  AND friend.countryName <> countryX.name
  AND friend.countryName <> countryY.name
WITH DISTINCT friend, countryX, countryY
MATCH (friend)<-[:HAS_CREATOR]-(message:Message),
      (message)-[:IS_LOCATED_IN]->(country:Country)
WHERE $endDate > message.creationDate >= $startDate
  AND country IN [countryX, countryY]
WITH friend,
     CASE WHEN country = countryX THEN 1 ELSE 0 END AS messageX,
     CASE WHEN country = countryY THEN 1 ELSE 0 END AS messageY
WITH friend, sum(messageX) AS xCount, sum(messageY) AS yCount
WHERE xCount > 0 AND yCount > 0
RETURN friend.id AS friendId,
       friend.firstName AS friendFirstName,
       friend.lastName AS friendLastName,
       xCount,
       yCount,
       xCount + yCount AS xyCount
ORDER BY xyCount DESC, friendId ASC
LIMIT 20
