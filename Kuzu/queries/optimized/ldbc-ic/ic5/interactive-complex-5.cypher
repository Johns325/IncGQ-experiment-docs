// Q5. Uses HASMEMBER.postCount from queries/index/ldbc-ic/ic5/index.cypher.
MATCH (person:PERSON {id: $personId})-[:KNOWS*1..2]-(friend:PERSON)
WHERE NOT person = friend
WITH DISTINCT friend
MATCH (friend)<-[membership:HASMEMBER]-(forum:FORUM)
WHERE membership.joinDate > $minDate
WITH forum, sum(membership.postCount) AS postCount
RETURN forum.title AS forumName, postCount
ORDER BY postCount DESC, forum.id ASC
LIMIT 20
