// Q20. Recruitment
// Requires the Neo4j Graph Data Science library
/*
:params { company: 'Falcon_Air', person2Id: 66 }
*/
MATCH
  (company:Company {name: $company})<-[:WORK_AT]-(person1:Person),
  (person2:Person {id: $person2Id})
WITH collect(person1) AS sourcePersons, person2
CALL gds.graph.drop('bi20_without_precomputation', false)
YIELD graphName

// ----------------------------------------------------------------------------------------------------
WITH sourcePersons, person2, count(*) AS dummy
// ----------------------------------------------------------------------------------------------------

CALL gds.graph.project.cypher(
  'bi20_without_precomputation',
  'MATCH (p:Person) RETURN id(p) AS id',
  'MATCH
     (personA:Person)-[:KNOWS]-(personB:Person),
     (personA)-[saA:STUDY_AT]->(u:University)<-[saB:STUDY_AT]-(personB)
   RETURN
     id(personA) AS source,
     id(personB) AS target,
     min(abs(saA.classYear - saB.classYear)) + 1 AS weight'
)
YIELD graphName

// ----------------------------------------------------------------------------------------------------
WITH graphName, sourcePersons, person2
// ----------------------------------------------------------------------------------------------------

UNWIND sourcePersons AS person1
WITH graphName, person1, person2
WHERE person1.id <> $person2Id
CALL gds.shortestPath.dijkstra.stream(graphName, {
  sourceNode: person1,
  targetNode: person2,
  relationshipWeightProperty: 'weight'
})
YIELD totalCost
WITH graphName, person1.id AS person1Id, totalCost AS totalWeight
ORDER BY totalWeight ASC, person1Id ASC
WITH graphName, collect({person1Id: person1Id, totalWeight: totalWeight}) AS results
CALL gds.graph.drop(graphName, false)
YIELD graphName AS droppedGraphName
WITH results
UNWIND results AS result
WITH result.person1Id AS person1Id, result.totalWeight AS totalWeight, results
WHERE totalWeight = results[0].totalWeight
RETURN person1Id, totalWeight
ORDER BY person1Id ASC
LIMIT 20
