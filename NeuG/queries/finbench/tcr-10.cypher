MATCH (:Person {id: $id1})-[edge1:PersonInvestCompany]->(m1:Company)
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
WITH count(DISTINCT m1) AS c1
MATCH (:Person {id: $id2})-[edge2:PersonInvestCompany]->(m2:Company)
WHERE $start_time < edge2.timestamp AND edge2.timestamp < $end_time
WITH c1, count(DISTINCT m2) AS c2
OPTIONAL MATCH (:Person {id: $id1})-[edge3:PersonInvestCompany]->(mi:Company)<-[edge4:PersonInvestCompany]-(:Person {id: $id2})
WHERE $start_time < edge3.timestamp AND edge3.timestamp < $end_time
  AND $start_time < edge4.timestamp AND edge4.timestamp < $end_time
WITH c1, c2, count(DISTINCT mi) AS inter
WITH CASE WHEN c1 + c2 - inter = 0 THEN 0.0 ELSE 1.0 * inter / (c1 + c2 - inter) END AS jaccardSimilarity
RETURN round(jaccardSimilarity, 3) AS jaccardSimilarity
