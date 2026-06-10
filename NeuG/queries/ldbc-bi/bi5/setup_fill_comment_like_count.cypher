FILL COMMENT(likeCount) FROM (
MATCH (message:COMMENT)<-[likes:LIKES]-(:PERSON)
RETURN message.id, count(likes));
