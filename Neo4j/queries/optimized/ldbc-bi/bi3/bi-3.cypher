// Q3. Uses ROOT_POST from queries/index/ldbc-bi/bi3/index.cypher.
MATCH
  (:Country {name: $country})<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-
  (person:Person)<-[:HAS_MODERATOR]-(forum:Forum)-[:CONTAINER_OF]->
  (post:Post)<-[:ROOT_POST]-(message:Message)-[:HAS_TAG]->(:Tag)-[:HAS_TYPE]->(:TagClass {name: $tagClass})
RETURN forum.id AS forumId,
       forum.title AS forumTitle,
       forum.creationDate AS forumCreationDate,
       person.id AS personId,
       count(DISTINCT message) AS messageCount
ORDER BY messageCount DESC, forumId ASC
LIMIT 20
