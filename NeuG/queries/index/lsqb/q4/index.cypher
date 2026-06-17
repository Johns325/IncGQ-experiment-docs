ALTER TABLE Post ADD IF NOT EXISTS q4_msg_cnt int64 DEFAULT 0;
ALTER TABLE Comment ADD IF NOT EXISTS q4_msg_cnt int64 DEFAULT 0;
FILL Post(q4_msg_cnt) FROM (
  MATCH (message:Post)<-[:Person_likes_Post]-(:Person),
        (message)<-[:Comment_replyOf_Post]-(:Comment)
  RETURN message.PostId, count(*) AS cnt
);
FILL Comment(q4_msg_cnt) FROM (
  MATCH (message:Comment)<-[:Person_likes_Comment]-(:Person),
        (message)<-[:Comment_replyOf_Comment]-(:Comment)
  RETURN message.CommentId, count(*) AS cnt
);
