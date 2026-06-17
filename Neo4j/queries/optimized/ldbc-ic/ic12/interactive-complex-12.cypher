// Q12. Uses ROOT_TAGCLASS from queries/index/ldbc-ic/ic12/index.cypher.
MATCH (tag:Tag)-[:HAS_TYPE]->(tagClass:TagClass)
WHERE tag.name = $tagClassName
   OR EXISTS {
        MATCH (tagClass)-[:ROOT_TAGCLASS]->(:TagClass {name: $tagClassName})
      }
WITH collect(DISTINCT tag.id) AS tags
MATCH (:Person {id: $personId})-[:KNOWS]-(friend:Person)<-[:HAS_CREATOR]-(comment:Comment)-[:REPLY_OF]->(:Post)-[:HAS_TAG]->(tag:Tag)
WHERE tag.id IN tags
RETURN friend.id AS personId,
       friend.firstName AS personFirstName,
       friend.lastName AS personLastName,
       collect(DISTINCT tag.name) AS tagNames,
       count(DISTINCT comment) AS replyCount
ORDER BY replyCount DESC, personId ASC
LIMIT 20
