// Q3. Friends and friends of friends that have been to given countries
// Parameters for Kuzu Python:
//   personId: INT64, countryXName: STRING, countryYName: STRING,
//   startDate: datetime.datetime, endDate: datetime.datetime
MATCH (countryX:PLACE {name: $countryXName}),
      (countryY:PLACE {name: $countryYName}),
      (person:PERSON {id: $personId})
WHERE countryX.type = 'country' AND countryY.type = 'country'
WITH person, countryX, countryY
LIMIT 1
MATCH (city:PLACE)-[:ISPARTOF]->(country:PLACE)
WHERE city.type = 'city'
  AND country IN [countryX, countryY]
WITH person, countryX, countryY, collect(city) AS cities
MATCH (person)-[:KNOWS*1..2]-(friend:PERSON)-[:ISLOCATEDIN]->(city:PLACE)
WHERE NOT person = friend AND NOT city IN cities
WITH DISTINCT friend, countryX, countryY
MATCH (friend)<-[:HASCREATOR]-(message),
      (message)-[:ISLOCATEDIN]->(country:PLACE)
WHERE message.creationDate < $endDate
  AND message.creationDate >= $startDate
  AND country IN [countryX, countryY]
  AND (label(message) = 'POST' OR label(message) = 'COMMENT')
WITH friend,
     CASE WHEN country = countryX THEN 1 ELSE 0 END AS messageX,
     CASE WHEN country = countryY THEN 1 ELSE 0 END AS messageY
WITH friend, sum(CAST(messageX AS INT64)) AS xCount, sum(CAST(messageY AS INT64)) AS yCount
WHERE xCount > 0 AND yCount > 0
RETURN friend.id AS friendId,
       friend.firstName AS friendFirstName,
       friend.lastName AS friendLastName,
       xCount,
       yCount,
       xCount + yCount AS xyCount
ORDER BY xyCount DESC, friendId ASC
LIMIT 20
