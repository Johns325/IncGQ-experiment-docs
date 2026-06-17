// Q11. Friend triangles
// Parameters for Kuzu Python:
//   country: STRING, startDate: datetime.datetime, endDate: datetime.datetime
MATCH (a:PERSON)-[:ISLOCATEDIN]->(cityA:PLACE)-[:ISPARTOF]->(country:PLACE {name: $country}),
      (a)-[k1:KNOWS]-(b:PERSON)
WHERE cityA.type = 'city'
  AND country.type = 'country'
  AND a.id < b.id
  AND $startDate <= k1.creationDate AND k1.creationDate <= $endDate
WITH DISTINCT country, a, b
MATCH (b)-[:ISLOCATEDIN]->(cityB:PLACE)-[:ISPARTOF]->(country)
WHERE cityB.type = 'city'
WITH DISTINCT country, a, b
MATCH (b)-[k2:KNOWS]-(c:PERSON),
      (c)-[:ISLOCATEDIN]->(cityC:PLACE)-[:ISPARTOF]->(country)
WHERE cityC.type = 'city'
  AND b.id < c.id
  AND $startDate <= k2.creationDate AND k2.creationDate <= $endDate
WITH DISTINCT a, b, c
MATCH (c)-[k3:KNOWS]-(a)
WHERE $startDate <= k3.creationDate AND k3.creationDate <= $endDate
WITH DISTINCT a, b, c
RETURN count(*) AS count
