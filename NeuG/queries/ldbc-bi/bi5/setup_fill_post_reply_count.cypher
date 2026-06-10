FILL POST(replyCount) FROM (
MATCH (message:POST)<-[:REPLYOF]-(reply:COMMENT)
RETURN message.id, count(reply));
