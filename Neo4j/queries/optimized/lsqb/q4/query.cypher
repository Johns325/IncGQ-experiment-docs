// Uses Message.q4_msg_cnt from queries/index/lsqb/q4/index.cypher.
MATCH (:Tag)<-[:HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(:Person)
RETURN coalesce(sum(message.q4_msg_cnt), 0) AS count
