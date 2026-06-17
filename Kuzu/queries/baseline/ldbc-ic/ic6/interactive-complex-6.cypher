// Q6. Tag co-occurrence
// Parameters for Kuzu Python:
//   personId: INT64, tagName: STRING
MATCH (knownTag:TAG {name: $tagName})
WITH knownTag.id AS knownTagId
MATCH (person:PERSON {id: $personId})-[:KNOWS*1..2]-(f:PERSON)
WHERE NOT person = f
WITH DISTINCT knownTagId, f
MATCH (f)<-[:HASCREATOR]-(post:POST),
      (post)-[:HASTAG]->(t:TAG {id: knownTagId}),
      (post)-[:HASTAG]->(tag:TAG)
WHERE NOT t = tag
WITH tag.name AS tagName, count(post) AS postCount
RETURN tagName, postCount
ORDER BY postCount DESC, tagName ASC
LIMIT 10
