MATCH (person2:PERSON)-[:ISLOCATEDIN]->(city2:PLACE {id: {}})
MATCH (person2)-[e:KNOWS* WSHORTEST(weight_bi19)(r, n | WHERE r.weight_bi19 <> 10000000000000.0)]-(person1:PERSON)-[:ISLOCATEDIN]->(city1:PLACE {id: {}})
WITH person1.id AS person1Id, person2.id AS person2Id,
     cast(cost(e), 'DOUBLE') AS totalWeight
WITH min(totalWeight) AS minWeight,
     collect([cast(person1Id, 'DOUBLE'), cast(person2Id, 'DOUBLE'), totalWeight]) AS results
UNWIND results AS result
WITH cast(result[0], 'INT64') AS person1Id,
     cast(result[1], 'INT64') AS person2Id,
     result[2] AS totalWeight,
     minWeight
WHERE totalWeight = minWeight
RETURN person1Id, person2Id, totalWeight
ORDER BY person1Id, person2Id;

