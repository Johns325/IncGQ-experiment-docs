MATCH (country:PLACE)<-[:ISPARTOF]-(:PLACE)<-[:ISLOCATEDIN]-(zombie:PERSON)
WHERE country.name = '{}' AND zombie.creationDate < TIMESTAMP('{} 00:00:00')
WITH zombie
OPTIONAL MATCH (zombie)<-[:HASCREATOR]-(message:POST:COMMENT)
WITH zombie, TIMESTAMP('{} 00:00:00') AS idate, zombie.creationDate AS zdate,
     sum(CASE WHEN message IS NOT NULL AND message.creationDate < TIMESTAMP('{} 00:00:00') THEN 1 ELSE 0 END) AS messageCount
WITH zombie, 12 * (date_part('year', idate) - date_part('year', zdate)) + (date_part('month', idate) - date_part('month', zdate)) + 1 AS months, messageCount
WHERE messageCount / months < 1
WITH COLLECT(zombie) AS zombies
UNWIND zombies AS zombie
OPTIONAL MATCH (zombie)<-[:HASCREATOR]-(message:POST:COMMENT)<-[:LIKES]-(likerZombie:PERSON)
WITH zombie, zombies, sum(CASE WHEN likerZombie IN zombies THEN 1 ELSE 0 END) AS zombieLikeCount
OPTIONAL MATCH (zombie)<-[:HASCREATOR]-(message:POST:COMMENT)<-[:LIKES]-(likerPerson:PERSON)
WITH zombie, zombieLikeCount,
     sum(CASE WHEN likerPerson IS NOT NULL AND likerPerson.creationDate < TIMESTAMP('{} 00:00:00') THEN 1 ELSE 0 END) AS totalLikeCount
RETURN zombie.id AS zid, zombieLikeCount, totalLikeCount,
CASE totalLikeCount WHEN 0 THEN 0.0 ELSE 1.0 * zombieLikeCount / totalLikeCount END AS zombieScore
ORDER BY zombieScore DESC, zid ASC
LIMIT 100;
