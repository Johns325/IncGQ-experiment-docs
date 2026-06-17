// Q6. Uses PERSON.likeCount from queries/index/ldbc-bi/bi6/index.cypher.
MATCH (tag:TAG {name: $tag})<-[:HASTAG]-(message1:POST:COMMENT)-[:HASCREATOR]->(person1:PERSON)
OPTIONAL MATCH (message1)<-[:LIKES]-(person2:PERSON)
WITH DISTINCT person1, person2
RETURN
  person1.id AS personId,
  sum(CASE WHEN person2 IS NULL THEN 0 ELSE person2.likeCount END) AS authorityScore
ORDER BY authorityScore DESC, personId ASC
LIMIT 100
