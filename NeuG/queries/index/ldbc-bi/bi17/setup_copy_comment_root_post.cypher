COPY ROOT_POST FROM (
MATCH (comment:COMMENT)
WHERE comment.rootPostId <> -1
RETURN comment.id, comment.rootPostId) (from="Comment", to="Post");
