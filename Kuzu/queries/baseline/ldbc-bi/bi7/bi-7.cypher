// Q7. Related Topics
// Kuzu adaptation: Message is represented by the POST:COMMENT union.
MATCH
  (tag:TAG {name: $tag})<-[:HASTAG]-(message:POST:COMMENT),
  (message)<-[:REPLYOF]-(comment:COMMENT)-[:HASTAG]->(relatedTag:TAG)
WHERE NOT (comment)-[:HASTAG]->(tag)
RETURN
  relatedTag.name AS name,
  count(DISTINCT comment) AS count
ORDER BY count DESC, name ASC
LIMIT 100
