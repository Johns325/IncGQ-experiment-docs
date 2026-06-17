MATCH (comment:COMMENT)-[:REPLYOF]->(post:POST)<-[:CONTAINEROF]-(forum:FORUM)
SET comment.rootPostId = post.id,
    comment.rootForumId = forum.id;
