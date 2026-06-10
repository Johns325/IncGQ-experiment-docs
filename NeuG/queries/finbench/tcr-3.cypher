MATCH (src:Account {id: $id1})-[path1:AccountTransferAccount*1..3 (r, n | WHERE $start_time < r.timestamp AND r.timestamp < $end_time)]->(dst:Account {id: $id2})
RETURN length(path1) AS shortestPathLength
ORDER BY shortestPathLength ASC
LIMIT 1
