// Source-aligned with Kuzu queries/index/ldbc-bi/bi6/index.cypher.
MATCH (person:Person) REMOVE person.likeCount;
MATCH (person2:Person)
WITH person2,
     count {
       MATCH (person2)<-[:HAS_CREATOR]-(:Message)<-[:LIKES]-(:Person)
     } AS likeCount
SET person2.likeCount = likeCount;
