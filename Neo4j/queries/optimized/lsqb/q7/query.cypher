// Uses Message.q7_like_cnt/q7_reply_count from queries/index/lsqb/q7/index.cypher.
MATCH (:Tag)<-[:HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(:Person)
RETURN coalesce(sum(
  CASE WHEN message.q7_like_cnt = 0 THEN 1 ELSE message.q7_like_cnt END *
  CASE WHEN message.q7_reply_count = 0 THEN 1 ELSE message.q7_reply_count END
), 0) AS count
