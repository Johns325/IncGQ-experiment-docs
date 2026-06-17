MATCH (post:POST)<-[:CONTAINEROF]-(forum:FORUM)
SET post.rootPostId = post.id,
    post.rootForumId = forum.id;
