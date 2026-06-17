// Source-aligned with Kuzu queries/index/lsqb/q7/index.cypher.
MATCH (message:Message)
CALL {
  WITH message
  REMOVE message.q7_like_cnt, message.q7_reply_count
} IN TRANSACTIONS OF 10000 ROWS;

MATCH (message:Message)
CALL {
  WITH message
  WITH message, count { MATCH (message)<-[:LIKES]-(:Person) } AS like_cnt
  SET message.q7_like_cnt = like_cnt
} IN TRANSACTIONS OF 10000 ROWS;

MATCH (message:Message)
CALL {
  WITH message
  WITH message, count { MATCH (message)<-[:REPLY_OF]-(:Comment) } AS reply_count
  SET message.q7_reply_count = reply_count
} IN TRANSACTIONS OF 10000 ROWS;
