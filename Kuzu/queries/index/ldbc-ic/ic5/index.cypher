// Source: Neug ic5 setup_add_post_count.cypher and setup_set_post_count.cypher.

ALTER TABLE HASMEMBER DROP IF EXISTS postCount;
ALTER TABLE HASMEMBER ADD postCount INT64 DEFAULT 0;

MATCH (forum:FORUM)-[membership:HASMEMBER]->(friend:PERSON)
OPTIONAL MATCH (friend)<-[:HASCREATOR]-(post:POST)<-[:CONTAINEROF]-(forum)
WITH membership, count(post) AS postCount
SET membership.postCount = postCount;
