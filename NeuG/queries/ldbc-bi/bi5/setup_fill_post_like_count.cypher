FILL POST(likeCount) FROM (
MATCH (message:POST)<-[likes:LIKES]-(:PERSON)
RETURN message.id, count(likes));
