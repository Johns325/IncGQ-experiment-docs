FILL POST(likeCount) FROM (
MATCH (message:POST)<-[:LIKES]-(liker:PERSON)
RETURN message.id, count(liker));
