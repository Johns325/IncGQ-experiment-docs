// Q5. Uses HAS_MEMBER.postCount from queries/index/ldbc-ic/ic5/index.cypher.
MATCH (person:Person {id: $personId})-[:KNOWS*1..2]-(friend:Person)
WHERE NOT person = friend
WITH DISTINCT friend
MATCH (friend)<-[membership:HAS_MEMBER]-(forum:Forum)
WHERE membership.joinDate > $minDate
WITH forum, sum(membership.postCount) AS postCount
RETURN forum.title AS forumName, postCount
ORDER BY postCount DESC, forum.id ASC
LIMIT 20
