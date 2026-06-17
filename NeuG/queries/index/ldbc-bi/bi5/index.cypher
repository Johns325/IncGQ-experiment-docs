ALTER TABLE COMMENT ADD IF NOT EXISTS likeCount INT64 DEFAULT 0;
ALTER TABLE POST ADD IF NOT EXISTS likeCount INT64 DEFAULT 0;
ALTER TABLE COMMENT ADD IF NOT EXISTS replyCount INT64 DEFAULT 0;
ALTER TABLE POST ADD IF NOT EXISTS replyCount INT64 DEFAULT 0;
FILL COMMENT(likeCount) FROM (
MATCH (message:COMMENT)<-[:LIKES]-(liker:PERSON)
RETURN message.id, count(liker));
FILL POST(likeCount) FROM (
MATCH (message:POST)<-[:LIKES]-(liker:PERSON)
RETURN message.id, count(liker));
FILL COMMENT(replyCount) FROM (
MATCH (message:COMMENT)<-[:REPLYOF]-(reply:COMMENT)
RETURN message.id, count(reply));
FILL POST(replyCount) FROM (
MATCH (message:POST)<-[:REPLYOF]-(reply:COMMENT)
RETURN message.id, count(reply));
