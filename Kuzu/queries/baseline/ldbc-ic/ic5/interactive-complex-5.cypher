// Q5. New groups
// Parameters for Kuzu Python:
//   personId: INT64, minDate: datetime.datetime
MATCH (person:PERSON {id: $personId})-[:KNOWS*1..2]-(friend:PERSON)
WHERE NOT person = friend
WITH DISTINCT friend
MATCH (friend)<-[membership:HASMEMBER]-(forum:FORUM)
WHERE membership.joinDate > $minDate
WITH forum, collect(friend) AS friends
OPTIONAL MATCH (friend:PERSON)<-[:HASCREATOR]-(post:POST)<-[:CONTAINEROF]-(forum)
WHERE friend IN friends
WITH forum, count(post) AS postCount
RETURN forum.title AS forumName, postCount
ORDER BY postCount DESC, forum.id ASC
LIMIT 20
