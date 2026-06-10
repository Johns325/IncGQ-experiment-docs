MATCH (comment:COMMENT)
SET comment.rootPostId = -1,
    comment.rootForumId = -1;
