// Q11. Uses Person.countryName from queries/index/ldbc-bi/bi11/index.cypher.
MATCH (a:Person)-[k1:KNOWS]-(b:Person)
WHERE a.countryName = $country
  AND a.id < b.id
  AND $startDate <= k1.creationDate AND k1.creationDate <= $endDate
WITH DISTINCT a, b
WHERE b.countryName = $country
MATCH (b)-[k2:KNOWS]-(c:Person)
WHERE c.countryName = $country
  AND b.id < c.id
  AND $startDate <= k2.creationDate AND k2.creationDate <= $endDate
WITH DISTINCT a, b, c
MATCH (c)-[k3:KNOWS]-(a)
WHERE $startDate <= k3.creationDate AND k3.creationDate <= $endDate
WITH DISTINCT a, b, c
RETURN count(*) AS count
