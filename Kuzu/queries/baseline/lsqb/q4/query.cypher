MATCH (d:Person)
WITH d LIMIT 1
RETURN
  count {
    MATCH (:Tag)<-[:Post_hasTag_Tag]-(message:Post)-[:Post_hasCreator_Person]->(creator:Person),
      (message)<-[:Person_likes_Post]-(liker:Person),
      (message)<-[:Comment_replyOf_Post]-(comment:Comment)
  }
  +
  count {
    MATCH (:Tag)<-[:Comment_hasTag_Tag]-(message:Comment)-[:Comment_hasCreator_Person]->(creator:Person),
      (message)<-[:Person_likes_Comment]-(liker:Person),
      (message)<-[:Comment_replyOf_Comment]-(comment:Comment)
  } AS count
