MATCH (src:Account)-[edge2:AccountTransferAccount]->(dst:Account {id: $id})
OPTIONAL MATCH (blockedSrc:Account {isBlocked: true})-[edge1:AccountTransferAccount]->(dst)
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND edge1.amount > $threshold
RETURN round(1.0 * count(edge1) / count(edge2), 3) AS blockRatio
