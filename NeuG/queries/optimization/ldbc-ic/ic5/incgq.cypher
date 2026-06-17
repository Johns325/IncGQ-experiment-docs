MATCH (person:PERSON { id: {} })-[:KNOWS*1..2]-(friend)
WITH DISTINCT friend
WHERE friend.id <> {}
CALL (friend) {
    MATCH (friend)<-[membership:HASMEMBER]-(forum)
    WHERE membership.joinDate > TIMESTAMP('{}')
    WITH distinct forum
    WITH forum, 0 AS postCount
    ORDER BY forum.id ASC
    LIMIT 20
    RETURN forum, postCount
  UNION ALL
    MATCH (friend)<-[membership:HASMEMBER]-(forum)
    WHERE membership.joinDate > TIMESTAMP('{}')
    MATCH (friend)<-[:HASCREATOR]-(post)<-[:CONTAINEROF]-(forum)
    WITH forum, count(post) AS postCount
    WITH forum, postCount
    ORDER BY postCount DESC, forum.id ASC
    LIMIT 20
    RETURN forum, postCount
}
WITH forum, max(postCount) AS postCount
ORDER BY postCount DESC, forum.id ASC
LIMIT 20
RETURN forum.title as name, postCount;
