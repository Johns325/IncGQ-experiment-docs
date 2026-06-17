// Generic ROOT_POST materialization for LDBC BI-style schemas.
// Source: Neug bi3/setup_create_root_post.cypher and bi3/setup_fill_root_post.cypher.

DROP TABLE IF EXISTS ROOT_POST;
CREATE REL TABLE ROOT_POST(FROM COMMENT TO POST, FROM POST TO POST);

MATCH (post:POST)
CREATE (post)-[:ROOT_POST]->(post);

MATCH (post:POST)<-[:REPLYOF*1..]-(message:COMMENT)
WITH DISTINCT message, post
CREATE (message)-[:ROOT_POST]->(post);
