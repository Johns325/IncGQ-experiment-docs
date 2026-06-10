MATCH
  (account:Account {id: $id})-[edge1:AccountTransferAccount*1..3 (r, n | WHERE $start_time < r.timestamp AND r.timestamp < $end_time)]->(other:Account),
  (other)<-[edge2:MediumSignInAccount]-(medium:Medium {isBlocked: true})
WHERE $start_time < edge2.timestamp AND edge2.timestamp < $end_time
RETURN other.id AS otherId, length(edge1) AS accountDistance, medium.id AS mediumId, medium.type AS mediumType
ORDER BY accountDistance ASC
LIMIT 500
