FILL ROOT_POST() FROM (
MATCH (post:Post)<-[e:REPLYOF*0..4294967295]-(message:COMMENT:POST)
RETURN DISTINCT message.id, post.id);
