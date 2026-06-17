ALTER TABLE PERSON ADD IF NOT EXISTS likeCount INT64;
FILL PERSON(likeCount) FROM (
MATCH (person2)<-[:HASCREATOR]-(message2:COMMENT:POST)<-[like:LIKES]-(person3:Person)
RETURN person2.id, count(person3));
