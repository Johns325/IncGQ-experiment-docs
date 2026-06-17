COPY ROOT_POST FROM (
MATCH (post:Post)
RETURN post.id, post.id AS rootPostId) (from="Post", to="Post");
