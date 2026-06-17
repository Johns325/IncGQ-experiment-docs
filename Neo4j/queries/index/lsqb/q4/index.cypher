// Source-aligned with Kuzu queries/index/lsqb/q4/index.cypher.
MATCH (message:Message) REMOVE message.q4_msg_cnt;
MATCH (message:Message)<-[:LIKES]-(:Person),
      (message)<-[:REPLY_OF]-(:Comment)
WITH message, count(*) AS cnt
SET message.q4_msg_cnt = cnt;
