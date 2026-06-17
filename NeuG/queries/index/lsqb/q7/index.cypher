ALTER TABLE Post ADD IF NOT EXISTS q7_like_cnt int64 DEFAULT 0;
ALTER TABLE Post ADD IF NOT EXISTS q7_reply_count int64 DEFAULT 0;
ALTER TABLE Comment ADD IF NOT EXISTS q7_like_cnt int64 DEFAULT 0;
ALTER TABLE Comment ADD IF NOT EXISTS q7_reply_count int64 DEFAULT 0;
FILL Post(q7_like_cnt) FROM (
  MATCH (message:Post)<-[:Person_likes_Post]-(liker:Person)
  RETURN message.PostId, count(liker) AS like_cnt
);
FILL Post(q7_reply_count) FROM (
  MATCH (message:Post)<-[:Comment_replyOf_Post]-(comment:Comment)
  RETURN message.PostId, count(comment) AS reply_count
);
FILL Comment(q7_like_cnt) FROM (
  MATCH (message:Comment)<-[:Person_likes_Comment]-(liker:Person)
  RETURN message.CommentId, count(liker) AS like_cnt
);
FILL Comment(q7_reply_count) FROM (
  MATCH (message:Comment)<-[:Comment_replyOf_Comment]-(comment:Comment)
  RETURN message.CommentId, count(comment) AS reply_count
);
