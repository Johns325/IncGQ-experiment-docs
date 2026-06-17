// Run bi19/setup.cypher once before this query to populate KNOWS.weight_bi19.
MATCH (person1:PERSON)-[:ISLOCATEDIN]->(:PLACE {id: $city1Id}),
      (person2:PERSON)-[:ISLOCATEDIN]->(:PLACE {id: $city2Id})
OPTIONAL MATCH (person1)-[path:KNOWS* WSHORTEST(weight_bi19)(r, n | WHERE r.weight_bi19 <> 10000000000000.0)]-(person2)
WITH
    person1.id AS person1Id,
    person2.id AS person2Id,
    CASE path IS NULL
        WHEN true THEN -1.0
        ELSE CAST(cost(path) AS DOUBLE)
    END AS totalWeight
WITH min(totalWeight) AS minWeight,
     collect({p1: person1Id, p2: person2Id, w: totalWeight}) AS results
UNWIND results AS result
WITH result.p1 AS person1Id, result.p2 AS person2Id, result.w AS totalWeight, minWeight
WHERE totalWeight = minWeight
RETURN person1Id, person2Id, totalWeight
ORDER BY person1Id, person2Id;
