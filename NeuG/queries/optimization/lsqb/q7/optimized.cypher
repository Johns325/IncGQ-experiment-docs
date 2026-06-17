MATCH (:Tag)<-[:Post_hasTag_Tag|:Comment_hasTag_Tag]-(message:Post:Comment)-[:Post_hasCreator_Person|:Comment_hasCreator_Person]->(creator:Person)
RETURN sum(
  (CASE WHEN message.q7_like_cnt = 0 THEN 1 ELSE message.q7_like_cnt END) *
  (CASE WHEN message.q7_reply_count = 0 THEN 1 ELSE message.q7_reply_count END)
) AS count;
