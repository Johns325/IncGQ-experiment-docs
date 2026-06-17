MATCH (unused:PERSON {id: {} })-[:KNOWS]-(friend:PERSON)<-[:HASCREATOR]-(comments:COMMENT)-[:REPLYOF]->(:POST)-[:HASTAG]->(tags:TAG)
WITH friend, tags, comments
MATCH (tags:TAG)-[:HASTYPE]->(:TAGCLASS)-[:ISSUBCLASSOF*0..4294967295]->(:TAGCLASS {name: '{}'})
WITH  friend AS friend,  COLLECT(DISTINCT tags.name) AS tagNames,  count(DISTINCT comments) AS replyCount
WITH replyCount, friend.id AS personId, tagNames, friend
ORDER BY  replyCount DESC, personId ASC
LIMIT 20
RETURN personId, friend.firstName AS personFirstName, friend.lastName AS personLastName, tagNames,  replyCount;
