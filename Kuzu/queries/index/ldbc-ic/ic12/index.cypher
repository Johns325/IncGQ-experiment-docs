// Source: Neug ic12 setup_create_root_tagclass.cypher and setup_fill_root_tagclass.cypher.

DROP TABLE IF EXISTS ROOT_TAGCLASS;
CREATE REL TABLE ROOT_TAGCLASS(FROM TAGCLASS TO TAGCLASS);

MATCH (fromTagClass:TAGCLASS)-[:ISSUBCLASSOF*0..]->(toTagClass:TAGCLASS)
WITH DISTINCT fromTagClass, toTagClass
CREATE (fromTagClass)-[:ROOT_TAGCLASS]->(toTagClass);
