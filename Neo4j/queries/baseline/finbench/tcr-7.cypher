// TODO: implement truncation strategy
MATCH (src:Account)-[edge1:transfer|withdraw]->(mid:Account {id: $id})-[edge2:transfer|withdraw]->(dst:Account)
WHERE $start_time < edge1.timestamp < $end_time AND edge1.amount > $threshold
  AND $start_time < edge2.timestamp < $end_time AND edge2.amount > $threshold
WITH count(src) AS numSrc, count(dst) AS numDst, sum(edge1.amount) AS inAmount, sum(edge2.amount) AS outAmount
RETURN
  numSrc,
  numDst,
  CASE
    WHEN outAmount IS NULL OR outAmount = 0 THEN null
    ELSE round(1000.0 * inAmount / outAmount) / 1000
  END AS inOutRatio
