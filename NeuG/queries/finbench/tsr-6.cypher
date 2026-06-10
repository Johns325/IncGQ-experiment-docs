MATCH (src:Account {id: $id})<-[e1:AccountTransferAccount]-(mid:Account)-[e2:AccountTransferAccount]->(dst:Account {isBlocked: true})
WHERE src.id <> dst.id
  AND $start_time < e1.timestamp AND e1.timestamp < $end_time
  AND $start_time < e2.timestamp AND e2.timestamp < $end_time
RETURN collect(dst.id) AS dstId