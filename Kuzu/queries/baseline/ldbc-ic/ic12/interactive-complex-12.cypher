// Q12. Expert search
// Parameters for Kuzu Python:
//   personId: INT64, tagClassName: STRING
MATCH (tag:TAG)-[:HASTYPE]->(tagClass:TAGCLASS)-[:ISSUBCLASSOF*0..]->(baseTagClass:TAGCLASS)
WHERE tag.name = $tagClassName OR baseTagClass.name = $tagClassName
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
