MATCH (:PLACE {name: '{}'})<-[:ISPARTOF]-(:PLACE)<-[:ISLOCATEDIN]-(person:Person)<-[:HASMODERATOR]-(forum:Forum)-[:CONTAINEROF]->(post:Post)<-[:REPLYOF*0..4294967295]-(message:COMMENT:POST)-[:HASTAG]->(:Tag)-[:HASTYPE]->(:TagClass {name: '{}'})
RETURN forum.id, forum.title, forum.creationDate, person.id, count(DISTINCT message) AS messageCount
ORDER BY messageCount DESC, forum.id ASC
LIMIT 20
