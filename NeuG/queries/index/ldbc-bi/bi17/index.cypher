DROP TABLE IF EXISTS ROOT_POST;
ALTER TABLE COMMENT DROP IF EXISTS rootPostId;
ALTER TABLE COMMENT DROP IF EXISTS rootForumId;
ALTER TABLE POST DROP IF EXISTS rootPostId;
ALTER TABLE POST DROP IF EXISTS rootForumId;
ALTER TABLE COMMENT ADD IF NOT EXISTS rootPostId INT64 DEFAULT -1;
ALTER TABLE COMMENT ADD IF NOT EXISTS rootForumId INT64 DEFAULT -1;
ALTER TABLE POST ADD IF NOT EXISTS rootPostId INT64 DEFAULT -1;
ALTER TABLE POST ADD IF NOT EXISTS rootForumId INT64 DEFAULT -1;
MATCH (comment:COMMENT)
SET comment.rootPostId = -1,
    comment.rootForumId = -1;
MATCH (comment:COMMENT)-[:REPLYOF]->(post:POST)<-[:CONTAINEROF]-(forum:FORUM)
SET comment.rootPostId = post.id,
    comment.rootForumId = forum.id;
MATCH (comment:COMMENT)-[:REPLYOF]->(parent:COMMENT)
WHERE comment.rootPostId = -1 AND parent.rootPostId <> -1
SET comment.rootPostId = parent.rootPostId,
    comment.rootForumId = parent.rootForumId;
MATCH (comment:COMMENT)-[:REPLYOF]->(parent:COMMENT)
WHERE comment.rootPostId = -1 AND parent.rootPostId <> -1
SET comment.rootPostId = parent.rootPostId,
    comment.rootForumId = parent.rootForumId;
MATCH (comment:COMMENT)-[:REPLYOF]->(parent:COMMENT)
WHERE comment.rootPostId = -1 AND parent.rootPostId <> -1
SET comment.rootPostId = parent.rootPostId,
    comment.rootForumId = parent.rootForumId;
MATCH (comment:COMMENT)-[:REPLYOF]->(parent:COMMENT)
WHERE comment.rootPostId = -1 AND parent.rootPostId <> -1
SET comment.rootPostId = parent.rootPostId,
    comment.rootForumId = parent.rootForumId;
MATCH (comment:COMMENT)-[:REPLYOF]->(parent:COMMENT)
WHERE comment.rootPostId = -1 AND parent.rootPostId <> -1
SET comment.rootPostId = parent.rootPostId,
    comment.rootForumId = parent.rootForumId;
MATCH (comment:COMMENT)-[:REPLYOF]->(parent:COMMENT)
WHERE comment.rootPostId = -1 AND parent.rootPostId <> -1
SET comment.rootPostId = parent.rootPostId,
    comment.rootForumId = parent.rootForumId;
MATCH (comment:COMMENT)-[:REPLYOF]->(parent:COMMENT)
WHERE comment.rootPostId = -1 AND parent.rootPostId <> -1
SET comment.rootPostId = parent.rootPostId,
    comment.rootForumId = parent.rootForumId;
MATCH (post:POST)<-[:CONTAINEROF]-(forum:FORUM)
SET post.rootPostId = post.id,
    post.rootForumId = forum.id;
