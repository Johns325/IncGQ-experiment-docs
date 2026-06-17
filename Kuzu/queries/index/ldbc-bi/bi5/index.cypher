// Source: Neug bi5 setup_add_*_count.cypher and setup_fill_*_count.cypher.

ALTER TABLE POST DROP IF EXISTS likeCount;
ALTER TABLE POST DROP IF EXISTS replyCount;
ALTER TABLE COMMENT DROP IF EXISTS likeCount;
ALTER TABLE COMMENT DROP IF EXISTS replyCount;
ALTER TABLE POST ADD likeCount INT64 DEFAULT 0;
ALTER TABLE POST ADD replyCount INT64 DEFAULT 0;
ALTER TABLE COMMENT ADD likeCount INT64 DEFAULT 0;
ALTER TABLE COMMENT ADD replyCount INT64 DEFAULT 0;

MATCH (message:POST)
WITH message, count { MATCH (message)<-[:LIKES]-(:PERSON) } AS cnt
SET message.likeCount = cnt;

MATCH (message:POST)
WITH message, count { MATCH (message)<-[:REPLYOF]-(:COMMENT) } AS cnt
SET message.replyCount = cnt;

MATCH (message:COMMENT)
WITH message, count { MATCH (message)<-[:LIKES]-(:PERSON) } AS cnt
SET message.likeCount = cnt;

MATCH (message:COMMENT)
WITH message, count { MATCH (message)<-[:REPLYOF]-(:COMMENT) } AS cnt
SET message.replyCount = cnt;
