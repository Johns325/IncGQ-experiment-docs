// Q14. Uses KNOWS.ic14_weight from queries/index/ldbc-ic/ic14/index.cypher.
MATCH path = (person1:PERSON { id: $person1Id })-[:KNOWS* ALL SHORTEST 1..]-(person2:PERSON {id: $person2Id })
WITH path AS path, nodes(path) AS nodes_in_path, rels(path) AS rels_in_path
UNWIND rels_in_path AS rel
WITH path AS path, nodes_in_path AS nodes_in_path, sum(rel.ic14_weight) AS pathWeight
WHERE pathWeight > 0.0
UNWIND nodes_in_path AS node
WITH path AS path, collect(node.id) AS personIdsInPath, pathWeight AS pathWeight
RETURN personIdsInPath, pathWeight
ORDER BY pathWeight DESC
