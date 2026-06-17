// Source-aligned with Kuzu queries/index/ldbc-bi/bi3/index.cypher.
MATCH (person:Person) REMOVE person.countryName;
MATCH (person:Person)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country:Country)
SET person.countryName = country.name;
MATCH ()-[rel:ROOT_POST]->() DELETE rel;
MATCH (post:Post)
MERGE (post)-[:ROOT_POST]->(post);
MATCH (post:Post)<-[:REPLY_OF*1..]-(message:Comment)
WITH DISTINCT message, post
MERGE (message)-[:ROOT_POST]->(post);
