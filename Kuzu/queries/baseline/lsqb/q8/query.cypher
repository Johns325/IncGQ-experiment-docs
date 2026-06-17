MATCH (d:Person)
WITH d LIMIT 1
RETURN
  count {
    MATCH (tag1:Tag)<-[:Post_hasTag_Tag]-(message:Post)<-[:Comment_replyOf_Post]-(comment:Comment)-[:Comment_hasTag_Tag]->(tag2:Tag)
    WHERE NOT (comment)-[:Comment_hasTag_Tag]->(tag1)
      AND tag1 <> tag2
  }
  +
  count {
    MATCH (tag1:Tag)<-[:Comment_hasTag_Tag]-(message:Comment)<-[:Comment_replyOf_Comment]-(comment:Comment)-[:Comment_hasTag_Tag]->(tag2:Tag)
    WHERE NOT (comment)-[:Comment_hasTag_Tag]->(tag1)
      AND tag1 <> tag2
  } AS count
