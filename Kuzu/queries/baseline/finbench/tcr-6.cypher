MATCH (src1:Account)-[edge1:AccountTransferAccount]->(mid:Account)-[edge2:AccountWithdrawAccount]->(dstCard:Account {id: $id, type: 'card'})
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time AND edge1.amount > $threshold1
  AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time AND edge2.amount > $threshold2
RETURN mid.id AS midId, sum(edge1.amount) AS sumEdge1Amount, sum(edge2.amount) AS sumEdge2Amount
ORDER BY sumEdge2Amount DESC
