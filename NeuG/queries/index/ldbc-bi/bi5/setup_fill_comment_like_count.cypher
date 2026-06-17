FILL COMMENT(likeCount) FROM (
MATCH (message:COMMENT)<-[:LIKES]-(liker:PERSON)
RETURN message.id, count(liker));
