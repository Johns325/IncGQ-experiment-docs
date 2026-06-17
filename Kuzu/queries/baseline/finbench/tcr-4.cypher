MATCH (d:Account)
WITH d LIMIT 1
OPTIONAL MATCH
  (src:Account {id: $id1})-[edge1:AccountTransferAccount]->(dst:Account {id: $id2}),
  (src)<-[edge2:AccountTransferAccount]-(other:Account)-[edge3:AccountTransferAccount]->(dst)
WHERE $start_time < edge1.timestamp
  AND edge1.timestamp < $end_time
  AND $start_time < edge2.timestamp
  AND edge2.timestamp < $end_time
  AND $start_time < edge3.timestamp
  AND edge3.timestamp < $end_time
WITH
  other.id AS otherId,
  count(edge2) AS numEdge2, sum(edge2.amount) AS sumEdge2Amount, max(edge2.amount) AS maxEdge2Amount,
  count(edge3) AS numEdge3, sum(edge3.amount) AS sumEdge3Amount, max(edge3.amount) AS maxEdge3Amount
RETURN coalesce(otherId, -1) AS otherId,
       numEdge2,
       coalesce(sumEdge2Amount, 0.0) AS sumEdge2Amount,
       coalesce(maxEdge2Amount, 0.0) AS maxEdge2Amount,
       numEdge3,
       coalesce(sumEdge3Amount, 0.0) AS sumEdge3Amount,
       coalesce(maxEdge3Amount, 0.0) AS maxEdge3Amount
ORDER BY coalesce(sumEdge2Amount, 0.0) + coalesce(sumEdge3Amount, 0.0) DESC
LIMIT 1
