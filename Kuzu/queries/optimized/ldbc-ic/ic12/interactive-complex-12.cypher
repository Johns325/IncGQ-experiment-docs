// Q12. Uses ROOT_TAGCLASS from queries/index/ldbc-ic/ic12/index.cypher.
MATCH (tag:TAG)-[:HASTYPE]->(tagClass:TAGCLASS)
WHERE tag.name = $tagClassName
   OR EXISTS {
        MATCH (tagClass)-[:ROOT_TAGCLASS]->(:TAGCLASS {name: $tagClassName})
      }
WITH collect(DISTINCT tag.id) AS tags
MATCH (:PERSON {id: $personId})-[:KNOWS]-(friend:PERSON)<-[:HASCREATOR]-(comment:COMMENT)-[:REPLYOF]->(:POST)-[:HASTAG]->(tag:TAG)
WHERE tag.id IN tags
RETURN friend.id AS personId,
       friend.firstName AS personFirstName,
       friend.lastName AS personLastName,
       collect(DISTINCT tag.name) AS tagNames,
       count(DISTINCT comment) AS replyCount
ORDER BY replyCount DESC, personId ASC
LIMIT 20
