// Q6. Uses Person.likeCount from queries/index/ldbc-bi/bi6/index.cypher.
MATCH (tag:Tag {name: $tag})<-[:HAS_TAG]-(message1:Message)-[:HAS_CREATOR]->(person1:Person)
OPTIONAL MATCH (message1)<-[:LIKES]-(person2:Person)
WITH DISTINCT person1, person2
RETURN person1.id AS personId,
       sum(CASE WHEN person2 IS NULL THEN 0 ELSE person2.likeCount END) AS authorityScore
ORDER BY authorityScore DESC, personId ASC
LIMIT 100
