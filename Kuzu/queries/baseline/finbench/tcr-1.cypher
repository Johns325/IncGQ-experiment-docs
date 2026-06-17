// TCR-1 for Kuzu: manually unroll transfer paths of length 1..3.
MATCH p=(account:Account {id: $id})-[edge1:AccountTransferAccount]->(other:Account),
      (medium:Medium {isBlocked: true})-[signIn:MediumSignInAccount]->(other)
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND $start_time < signIn.timestamp AND signIn.timestamp < $end_time
RETURN other.id AS otherId, length(p) AS accountDistance, medium.id AS mediumId, medium.type AS mediumType
UNION ALL
MATCH p=(account:Account {id: $id})-[edge1:AccountTransferAccount]->(:Account)-[edge2:AccountTransferAccount]->(other:Account),
      (medium:Medium {isBlocked: true})-[signIn:MediumSignInAccount]->(other)
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  AND edge1.timestamp < edge2.timestamp
  AND $start_time < signIn.timestamp AND signIn.timestamp < $end_time
RETURN other.id AS otherId, length(p) AS accountDistance, medium.id AS mediumId, medium.type AS mediumType
UNION ALL
MATCH p=(account:Account {id: $id})-[edge1:AccountTransferAccount]->(:Account)-[edge2:AccountTransferAccount]->(:Account)-[edge3:AccountTransferAccount]->(other:Account),
      (medium:Medium {isBlocked: true})-[signIn:MediumSignInAccount]->(other)
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  AND $start_time < edge3.timestamp AND edge3.timestamp < $end_time
  AND edge1.timestamp < edge2.timestamp AND edge2.timestamp < edge3.timestamp
  AND $start_time < signIn.timestamp AND signIn.timestamp < $end_time
RETURN other.id AS otherId, length(p) AS accountDistance, medium.id AS mediumId, medium.type AS mediumType
ORDER BY accountDistance ASC
