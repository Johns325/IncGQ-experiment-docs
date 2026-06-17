// TCR-5 for Kuzu: manually unroll transfer paths of length 1..3.
MATCH (person:Person {id: $id})-[:PersonOwnAccount]->(src:Account),
      p=(src)-[edge1:AccountTransferAccount]->(dst:Account)
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
RETURN p AS path, length(p) AS accountDistance
UNION ALL
MATCH (person:Person {id: $id})-[:PersonOwnAccount]->(src:Account),
      p=(src)-[edge1:AccountTransferAccount]->(:Account)-[edge2:AccountTransferAccount]->(dst:Account)
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  AND edge1.timestamp < edge2.timestamp
RETURN p AS path, length(p) AS accountDistance
UNION ALL
MATCH (person:Person {id: $id})-[:PersonOwnAccount]->(src:Account),
      p=(src)-[edge1:AccountTransferAccount]->(:Account)-[edge2:AccountTransferAccount]->(:Account)-[edge3:AccountTransferAccount]->(dst:Account)
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  AND $start_time < edge3.timestamp AND edge3.timestamp < $end_time
  AND edge1.timestamp < edge2.timestamp AND edge2.timestamp < edge3.timestamp
RETURN p AS path, length(p) AS accountDistance
ORDER BY accountDistance DESC
