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
    MATCH (:Tag)<-[:Post_hasTag_Tag]-(message:Post)-[:Post_hasCreator_Person]->(creator:Person),
      (message)<-[:Person_likes_Post]-(liker:Person)
    WHERE NOT (message)<-[:Comment_replyOf_Post]-(:Comment)
  }
  +
  count {
    MATCH (:Tag)<-[:Post_hasTag_Tag]-(message:Post)-[:Post_hasCreator_Person]->(creator:Person),
      (message)<-[:Comment_replyOf_Post]-(comment:Comment)
    WHERE NOT (message)<-[:Person_likes_Post]-(:Person)
  }
  +
  count {
    MATCH (:Tag)<-[:Post_hasTag_Tag]-(message:Post)-[:Post_hasCreator_Person]->(creator:Person)
    WHERE NOT (message)<-[:Person_likes_Post]-(:Person)
      AND NOT (message)<-[:Comment_replyOf_Post]-(:Comment)
  }
  +
  count {
    MATCH (:Tag)<-[:Comment_hasTag_Tag]-(message:Comment)-[:Comment_hasCreator_Person]->(creator:Person),
      (message)<-[:Person_likes_Comment]-(liker:Person),
      (message)<-[:Comment_replyOf_Comment]-(comment:Comment)
  }
  +
  count {
    MATCH (:Tag)<-[:Comment_hasTag_Tag]-(message:Comment)-[:Comment_hasCreator_Person]->(creator:Person),
      (message)<-[:Person_likes_Comment]-(liker:Person)
    WHERE NOT (message)<-[:Comment_replyOf_Comment]-(:Comment)
  }
  +
  count {
    MATCH (:Tag)<-[:Comment_hasTag_Tag]-(message:Comment)-[:Comment_hasCreator_Person]->(creator:Person),
      (message)<-[:Comment_replyOf_Comment]-(comment:Comment)
    WHERE NOT (message)<-[:Person_likes_Comment]-(:Person)
  }
  +
  count {
    MATCH (:Tag)<-[:Comment_hasTag_Tag]-(message:Comment)-[:Comment_hasCreator_Person]->(creator:Person)
    WHERE NOT (message)<-[:Person_likes_Comment]-(:Person)
      AND NOT (message)<-[:Comment_replyOf_Comment]-(:Comment)
  } AS count
