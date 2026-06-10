MATCH (src:Account)-[edge1:AccountTransferAccount]->(mid:Account {id: $id})-[edge2:AccountTransferAccount]->(dst:Account)
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time AND edge1.amount > $threshold
  AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time AND edge2.amount > $threshold
RETURN count(src) AS numSrc, count(dst) AS numDst, round(1.0 * sum(edge1.amount) / sum(edge2.amount), 3) AS inOutRatio
