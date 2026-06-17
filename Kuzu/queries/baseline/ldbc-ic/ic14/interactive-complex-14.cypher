// Q14. Trusted connection paths
// Kuzu adaptation based on ALL SHORTEST paths and explicit rel endpoint rebinding.
// This follows the runnable NeuG/Kuzu style: paths without any message interaction are omitted.
MATCH path = (person1:PERSON { id: $person1Id })-[:KNOWS* ALL SHORTEST 1..]-(person2:PERSON {id: $person2Id })
WITH path AS path, rels(path) AS rels_in_path
UNWIND rels_in_path AS rel
WITH path AS path, START_NODE(rel) AS rel0_id, END_NODE(rel) AS rel1_id
MATCH (n_rel0:PERSON), (n_rel1:PERSON)
WHERE id(n_rel0) = rel0_id AND id(n_rel1) = rel1_id
WITH path AS path, n_rel0 AS n_rel0, n_rel1 AS n_rel1
MATCH (n_rel0)<-[:HASCREATOR]-(n:COMMENT:POST)-[:REPLYOF]-(m:COMMENT:POST)-[:HASCREATOR]->(n_rel1)
WITH path AS path,
  CASE WHEN n IS NOT NULL
    THEN CASE WHEN label(m) = 'POST' OR label(n) = 'POST' THEN 1.0 ELSE 0.5 END
    ELSE 0.0
  END AS w
WITH path AS path, nodes(path) AS nodes_in_path, sum(w) AS pathWeight
UNWIND nodes_in_path AS node
WITH path AS path, collect(node.id) AS personIdsInPath, pathWeight AS pathWeight
RETURN personIdsInPath, pathWeight
ORDER BY pathWeight DESC
