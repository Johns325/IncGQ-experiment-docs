// Q14. Uses KNOWS.ic14_weight from queries/index/ldbc-ic/ic14/index.cypher.
MATCH path = allShortestPaths((person1:Person {id: $person1Id})-[:KNOWS*0..]-(person2:Person {id: $person2Id}))
WITH [node IN nodes(path) | node.id] AS personIdsInPath,
     reduce(pathWeight = 0.0, rel IN relationships(path) | pathWeight + coalesce(rel.ic14_weight, 0.0)) AS pathWeight
RETURN personIdsInPath, pathWeight
ORDER BY pathWeight DESC
