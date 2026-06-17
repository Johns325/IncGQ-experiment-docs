// Q15. Weighted interaction paths
// Run bi15/setup.cypher once before this query to populate KNOWS.weight_bi15.
MATCH (person1:PERSON {id: $person1Id}), (person2:PERSON {id: $person2Id})
OPTIONAL MATCH (person1)-[path:KNOWS* WSHORTEST(weight_bi15)]-(person2)
RETURN CASE path IS NULL WHEN true THEN -1.0 ELSE CAST(cost(path) AS DOUBLE) END AS totalCost;
