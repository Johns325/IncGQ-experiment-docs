MATCH (d:Person)
WITH d LIMIT 1
WITH
  count {
    MATCH (p1:Person {id: $id1})-[edge1:PersonInvestCompany]->(m:Company),
          (p2:Person {id: $id2})-[edge2:PersonInvestCompany]->(m)
    WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
      AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  } AS intersectionCount,
  count {
    MATCH (p1:Person {id: $id1})-[edge1:PersonInvestCompany]->(m1:Company)
    WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  } AS p1Count,
  count {
    MATCH (p2:Person {id: $id2})-[edge2:PersonInvestCompany]->(m2:Company)
    WHERE $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  } AS p2Count
RETURN CASE
  WHEN p1Count + p2Count - intersectionCount = 0 THEN 0.0
  ELSE round(CAST(intersectionCount AS DOUBLE) / CAST(p1Count + p2Count - intersectionCount AS DOUBLE), 3)
END AS jaccardSimilarity
