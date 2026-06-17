// Source-aligned with Kuzu queries/index/ldbc-ic/ic14/index.cypher.
MATCH ()-[knows:KNOWS]-() SET knows.ic14_weight = 0.0;
MATCH (person1:Person)-[knows:KNOWS]-(person2:Person)
WHERE id(person1) < id(person2)
OPTIONAL MATCH (person1)<-[:HAS_CREATOR]-(n:Message)-[:REPLY_OF]-(m:Message)-[:HAS_CREATOR]->(person2)
WITH knows, person1, person2,
     sum(CASE WHEN n IS NULL THEN 0.0 WHEN n:Post OR m:Post THEN 1.0 ELSE 0.5 END) AS forwardWeight
OPTIONAL MATCH (person2)<-[:HAS_CREATOR]-(n:Message)-[:REPLY_OF]-(m:Message)-[:HAS_CREATOR]->(person1)
WITH knows, forwardWeight,
     sum(CASE WHEN n IS NULL THEN 0.0 WHEN n:Post OR m:Post THEN 1.0 ELSE 0.5 END) AS reverseWeight
SET knows.ic14_weight = forwardWeight + reverseWeight;
