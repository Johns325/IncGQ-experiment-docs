// Q13. Uses PERSON.countryName from queries/index/ldbc-bi/bi13/index.cypher.
MATCH (zombie:PERSON)
WHERE zombie.countryName = $country
  AND zombie.creationDate < $endDate
OPTIONAL MATCH (zombie)<-[:HASCREATOR]-(message:POST:COMMENT)
WHERE message.creationDate < $endDate
WITH zombie, count(message) AS messageCount
WITH
  zombie,
  12 * (date_part('year', $endDate) - date_part('year', zombie.creationDate))
    + (date_part('month', $endDate) - date_part('month', zombie.creationDate))
    + 1 AS months,
  messageCount
WHERE CAST(messageCount AS DOUBLE) / CAST(months AS DOUBLE) < 1.0
WITH collect(zombie) AS zombies
UNWIND zombies AS zombie
OPTIONAL MATCH (zombie)<-[:HASCREATOR]-(message:POST:COMMENT)<-[:LIKES]-(likerZombie:PERSON)
WHERE likerZombie IN zombies
WITH zombie, count(likerZombie) AS zombieLikeCount
OPTIONAL MATCH (zombie)<-[:HASCREATOR]-(message:POST:COMMENT)<-[:LIKES]-(likerPerson:PERSON)
WHERE likerPerson.creationDate < $endDate
WITH zombie, zombieLikeCount, count(likerPerson) AS totalLikeCount
RETURN
  zombie.id AS zombieId,
  zombieLikeCount,
  totalLikeCount,
  CASE totalLikeCount WHEN 0 THEN 0.0 ELSE CAST(zombieLikeCount AS DOUBLE) / CAST(totalLikeCount AS DOUBLE) END AS zombieScore
ORDER BY zombieScore DESC, zombieId ASC
LIMIT 100
