// Uses Person.countryId from queries/index/lsqb/q3/index.cypher.
MATCH (person1:Person)-[:KNOWS]-(person2:Person)-[:KNOWS]-(person3:Person)-[:KNOWS]-(person1)
WHERE person1.countryId = person2.countryId
  AND person1.countryId = person3.countryId
RETURN count(*) AS count
