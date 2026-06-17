MATCH (person1:PERSON { id: {} })-[path : KNOWS* ALL SHORTEST 1..]-(person2:PERSON {id: {} })
WITH path, rels(path) as rels_in_path
UNWIND rels_in_path as rel
WITH path,  START_NODE(rel) as rel0, END_NODE(rel) as rel1
OPTIONAL MATCH (rel0:PERSON)<-[:HASCREATOR]-(n:POST:COMMENT)-[:REPLYOF]-(m:POST:COMMENT)-[:HASCREATOR]->(rel1:PERSON)
With path, rel0, rel1, SUM(CASE n IS NOT NULL WHEN TRUE THEN  CASE (label(m) = 'POST' OR label(n) = 'POST') WHEN TRUE THEN 1.0 ELSE 0.5 END ELSE 0.0 END) as pathWeight
With path, nodes(path) as nodes_in_path,  SUM(pathWeight) AS w
UNWIND nodes_in_path as node
WITH path, COLLECT(node.id) as personIdsInPath,w
RETURN personIdsInPath, w AS pathWeight
ORDER BY w DESC;
