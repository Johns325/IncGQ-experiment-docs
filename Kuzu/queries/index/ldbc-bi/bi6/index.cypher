// Source: Neug bi6 setup_add_like_count.cypher and setup_fill_like_count.cypher.

ALTER TABLE PERSON DROP IF EXISTS likeCount;
ALTER TABLE PERSON ADD likeCount INT64 DEFAULT 0;

MATCH (person2:PERSON)
WITH person2,
     count {
       MATCH (person2)<-[:HASCREATOR]-(:POST:COMMENT)<-[:LIKES]-(:PERSON)
     } AS likeCount
SET person2.likeCount = likeCount;
