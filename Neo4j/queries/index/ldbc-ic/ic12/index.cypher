// Source-aligned with Kuzu queries/index/ldbc-ic/ic12/index.cypher.
MATCH ()-[rel:ROOT_TAGCLASS]->() DELETE rel;
MATCH (fromTagClass:TagClass)-[:IS_SUBCLASS_OF*0..]->(toTagClass:TagClass)
WITH DISTINCT fromTagClass, toTagClass
MERGE (fromTagClass)-[:ROOT_TAGCLASS]->(toTagClass);
