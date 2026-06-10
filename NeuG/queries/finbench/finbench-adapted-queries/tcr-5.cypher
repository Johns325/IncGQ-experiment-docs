MATCH
  (person:Person {id: $id})-[:PersonOwnAccount]->(src:Account),
  (src)-[edge2:AccountTransferAccount*1..3 (r, n | WHERE $start_time < r.timestamp AND r.timestamp < $end_time)]->(dst:Account)
RETURN dst.id AS dstId, length(edge2) AS pathLength
ORDER BY pathLength DESC
LIMIT 500
