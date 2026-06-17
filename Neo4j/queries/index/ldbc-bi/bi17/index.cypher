// Source-aligned with Kuzu queries/index/ldbc-bi/bi17/index.cypher.
MATCH (message:Message) REMOVE message.rootPostId, message.rootForumId;
MATCH (post:Post)<-[:CONTAINER_OF]-(forum:Forum)
SET post.rootPostId = post.id,
    post.rootForumId = forum.id;
MATCH (comment:Comment)-[:REPLY_OF*1..]->(post:Post)<-[:CONTAINER_OF]-(forum:Forum)
SET comment.rootPostId = post.id,
    comment.rootForumId = forum.id;
MATCH ()-[rel:ROOT_POST]->() DELETE rel;
MATCH (post:Post)
MERGE (post)-[:ROOT_POST]->(post);
MATCH (comment:Comment)-[:REPLY_OF*1..]->(post:Post)
WITH DISTINCT comment, post
MERGE (comment)-[:ROOT_POST]->(post);
