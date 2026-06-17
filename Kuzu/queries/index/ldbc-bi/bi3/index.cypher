// Source: Neug bi3 setup_add_country_name.cypher, setup_fill_country_name.cypher,
// setup_create_root_post.cypher, and setup_fill_root_post.cypher.

ALTER TABLE PERSON DROP IF EXISTS countryName;
ALTER TABLE PERSON ADD countryName STRING DEFAULT '';

MATCH (country:PLACE)<-[:ISPARTOF]-(city:PLACE)<-[:ISLOCATEDIN]-(person:PERSON)
WHERE city.type = 'city' AND country.type = 'country'
SET person.countryName = country.name;

DROP TABLE IF EXISTS ROOT_POST;
CREATE REL TABLE ROOT_POST(FROM COMMENT TO POST, FROM POST TO POST);

MATCH (post:POST)
CREATE (post)-[:ROOT_POST]->(post);

MATCH (post:POST)<-[:REPLYOF*1..]-(message:COMMENT)
WITH DISTINCT message, post
CREATE (message)-[:ROOT_POST]->(post);
