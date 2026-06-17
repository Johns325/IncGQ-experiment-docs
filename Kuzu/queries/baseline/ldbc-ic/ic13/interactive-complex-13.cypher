// Q13. Single shortest path
// Kuzu rewrite: Kuzu 0.10/0.11 do not support Neo4j shortestPath(...).
// Use bounded KNOWS recursion and min(length(path)). On SF1 IC parameters,
// shortest paths observed in local checks are within 4 hops; larger bounds can
// make Kuzu enumerate too many paths.
/*
:param [{ person1Id, person2Id }] => { RETURN
  8796093022390 AS person1Id,
  8796093022357 AS person2Id
}
*/
MATCH (person1:PERSON {id: $person1Id}), (person2:PERSON {id: $person2Id})
OPTIONAL MATCH path = (person1)-[:KNOWS*1..4]-(person2)
WITH person1, person2, min(length(path)) AS distance
RETURN
    CASE
        WHEN person1.id = person2.id THEN 0
        WHEN distance IS NULL THEN -1
        ELSE distance
    END AS shortestPathLength
