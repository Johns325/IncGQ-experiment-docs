// Q13. Uses Person.countryName from queries/index/ldbc-bi/bi13/index.cypher.
MATCH (zombie:Person)
WHERE zombie.countryName = $country
  AND zombie.creationDate < $endDate
OPTIONAL MATCH (zombie)<-[:HAS_CREATOR]-(message:Message)
WHERE message.creationDate < $endDate
WITH zombie, count(message) AS messageCount
WITH zombie,
     12 * ($endDate.year - zombie.creationDate.year)
       + ($endDate.month - zombie.creationDate.month)
       + 1 AS months,
     messageCount
WHERE messageCount / toFloat(months) < 1.0
WITH collect(zombie) AS zombies
UNWIND zombies AS zombie
OPTIONAL MATCH (zombie)<-[:HAS_CREATOR]-(message:Message)<-[:LIKES]-(likerZombie:Person)
WHERE likerZombie IN zombies
WITH zombie, count(likerZombie) AS zombieLikeCount
OPTIONAL MATCH (zombie)<-[:HAS_CREATOR]-(message:Message)<-[:LIKES]-(likerPerson:Person)
WHERE likerPerson.creationDate < $endDate
WITH zombie, zombieLikeCount, count(likerPerson) AS totalLikeCount
RETURN zombie.id AS zombieId,
       zombieLikeCount,
       totalLikeCount,
       CASE totalLikeCount WHEN 0 THEN 0.0 ELSE zombieLikeCount / toFloat(totalLikeCount) END AS zombieScore
ORDER BY zombieScore DESC, zombieId ASC
LIMIT 100
