MATCH (person:Person {id: $id})
   -[edge1:PersonOwnAccount]->(pAcc:Account)
   -[edge2:AccountTransferAccount]->(compAcc:Account)
  <-[edge3:CompanyOwnAccount]-(company:Company)
WHERE $start_time < edge2.timestamp AND edge2.timestamp < $end_time
RETURN compAcc.id AS compAccountId, sum(edge2.amount) AS sumEdge2Amount
ORDER BY sumEdge2Amount DESC
