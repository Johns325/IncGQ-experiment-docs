// Source: Neug bi17 root post/root forum setup templates.

ALTER TABLE POST DROP IF EXISTS rootPostId;
ALTER TABLE POST DROP IF EXISTS rootForumId;
ALTER TABLE COMMENT DROP IF EXISTS rootPostId;
ALTER TABLE COMMENT DROP IF EXISTS rootForumId;
ALTER TABLE POST ADD rootPostId INT64 DEFAULT -1;
ALTER TABLE POST ADD rootForumId INT64 DEFAULT -1;
ALTER TABLE COMMENT ADD rootPostId INT64 DEFAULT -1;
ALTER TABLE COMMENT ADD rootForumId INT64 DEFAULT -1;

MATCH (post:POST)<-[:CONTAINEROF]-(forum:FORUM)
SET post.rootPostId = post.id,
    post.rootForumId = forum.id;

MATCH (comment:COMMENT)-[:REPLYOF*1..]->(post:POST)<-[:CONTAINEROF]-(forum:FORUM)
SET comment.rootPostId = post.id,
    comment.rootForumId = forum.id;

DROP TABLE IF EXISTS ROOT_POST;
CREATE REL TABLE ROOT_POST(FROM COMMENT TO POST, FROM POST TO POST);

MATCH (post:POST)
CREATE (post)-[:ROOT_POST]->(post);

MATCH (comment:COMMENT)-[:REPLYOF*1..]->(post:POST)
WITH DISTINCT comment, post
CREATE (comment)-[:ROOT_POST]->(post);
