// Q2. Tag evolution
// Kuzu adaptation: Message is represented by the POST:COMMENT union.
// Kuzu 0.10 needs the parameter-derived window boundaries materialized with explicit TIMESTAMP casts.
WITH
  CAST($date, 'TIMESTAMP') AS windowStart,
  CAST($date, 'TIMESTAMP') + duration('100 days') AS windowMiddle,
  CAST($date, 'TIMESTAMP') + duration('200 days') AS windowEnd
MATCH (tag:TAG)-[:HASTYPE]->(:TAGCLASS {name: $tagClass})
OPTIONAL MATCH (message1:POST:COMMENT)-[:HASTAG]->(tag)
  WHERE windowStart <= message1.creationDate
    AND message1.creationDate < windowMiddle
WITH tag, windowMiddle, windowEnd, count(message1) AS countWindow1
OPTIONAL MATCH (message2:POST:COMMENT)-[:HASTAG]->(tag)
  WHERE windowMiddle <= message2.creationDate
    AND message2.creationDate < windowEnd
WITH tag, countWindow1, count(message2) AS countWindow2
RETURN
  tag.name AS name,
  countWindow1,
  countWindow2,
  abs(countWindow1 - countWindow2) AS diff
ORDER BY diff DESC, name ASC
LIMIT 100
