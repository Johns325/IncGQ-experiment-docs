MATCH (comment:COMMENT)-[:REPLYOF]->(parent:COMMENT)
WHERE comment.rootPostId = -1 AND parent.rootPostId <> -1
SET comment.rootPostId = parent.rootPostId,
    comment.rootForumId = parent.rootForumId;
