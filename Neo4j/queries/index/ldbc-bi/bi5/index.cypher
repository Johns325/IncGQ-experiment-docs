// Source-aligned with Kuzu queries/index/ldbc-bi/bi5/index.cypher.
MATCH (message:Message)
CALL {
  WITH message
  REMOVE message.likeCount, message.replyCount
} IN TRANSACTIONS OF 10000 ROWS;

MATCH (message:Post)
CALL {
  WITH message
  WITH message, count { MATCH (message)<-[:LIKES]-(:Person) } AS cnt
  SET message.likeCount = cnt
} IN TRANSACTIONS OF 10000 ROWS;

MATCH (message:Comment)
CALL {
  WITH message
  WITH message, count { MATCH (message)<-[:LIKES]-(:Person) } AS cnt
  SET message.likeCount = cnt
} IN TRANSACTIONS OF 10000 ROWS;

MATCH (message:Post)
CALL {
  WITH message
  WITH message, count { MATCH (message)<-[:REPLY_OF]-(:Comment) } AS cnt
  SET message.replyCount = cnt
} IN TRANSACTIONS OF 10000 ROWS;

MATCH (message:Comment)
CALL {
  WITH message
  WITH message, count { MATCH (message)<-[:REPLY_OF]-(:Comment) } AS cnt
  SET message.replyCount = cnt
} IN TRANSACTIONS OF 10000 ROWS;
