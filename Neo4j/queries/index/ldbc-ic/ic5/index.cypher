// Source-aligned with Kuzu queries/index/ldbc-ic/ic5/index.cypher.
MATCH ()-[membership:HAS_MEMBER]->() REMOVE membership.postCount;
MATCH (forum:Forum)-[membership:HAS_MEMBER]->(friend:Person)
OPTIONAL MATCH (friend)<-[:HAS_CREATOR]-(post:Post)<-[:CONTAINER_OF]-(forum)
WITH membership, count(post) AS postCount
SET membership.postCount = postCount;
