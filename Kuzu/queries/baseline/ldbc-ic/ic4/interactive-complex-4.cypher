// Q4. New topics
// Parameters for Kuzu Python:
//   personId: INT64, startDate: datetime.datetime, endDate: datetime.datetime
MATCH (person:PERSON {id: $personId})-[:KNOWS]-(friend:PERSON),
      (friend)<-[:HASCREATOR]-(post:POST)-[:HASTAG]->(tag:TAG)
WITH DISTINCT tag, post
WITH tag,
     CASE WHEN $startDate <= post.creationDate AND post.creationDate < $endDate THEN 1 ELSE 0 END AS valid,
     CASE WHEN post.creationDate < $startDate THEN 1 ELSE 0 END AS inValid
WITH tag, sum(CAST(valid AS INT64)) AS postCount, sum(CAST(inValid AS INT64)) AS inValidPostCount
WHERE postCount > 0 AND inValidPostCount = 0
RETURN tag.name AS tagName, postCount
ORDER BY postCount DESC, tagName ASC
LIMIT 10
