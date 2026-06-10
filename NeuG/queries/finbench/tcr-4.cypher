MATCH
  (src:Account {id: $id1})-[edge1:AccountTransferAccount]->(dst:Account {id: $id2}),
  (src)<-[edge2:AccountTransferAccount]-(other:Account)-[edge3:AccountTransferAccount]->(dst)
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  AND $start_time < edge3.timestamp AND edge3.timestamp < $end_time
WITH
  other.id AS otherId,
  count(edge2) AS numEdge2, sum(edge2.amount) AS sumEdge2Amount, max(edge2.amount) AS maxEdge2Amount,
  count(edge3) AS numEdge3, sum(edge3.amount) AS sumEdge3Amount, max(edge3.amount) AS maxEdge3Amount
RETURN otherId, numEdge2, sumEdge2Amount, maxEdge2Amount, numEdge3, sumEdge3Amount, maxEdge3Amount
ORDER BY sumEdge2Amount + sumEdge3Amount DESC
LIMIT 1
