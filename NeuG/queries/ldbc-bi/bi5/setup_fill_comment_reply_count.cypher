FILL COMMENT(replyCount) FROM (
MATCH (message:COMMENT)<-[:REPLYOF]-(reply:COMMENT)
RETURN message.id, count(reply));
