// TODO: implement truncation strategy
MATCH
  (loan:Loan)-[edge1:deposit]->(mid:Account {id: $id})-[edge2:repay]->(loan),
  (up:Account)-[edge3:transfer]->(mid)-[edge4:transfer]->(down:Account)
WHERE edge1.amount > $threshold AND $start_time < edge1.timestamp < $end_time
  AND edge2.amount > $threshold AND $start_time < edge2.timestamp < $end_time
  AND edge2.amount <> 0
  AND $lowerbound < edge1.amount / edge2.amount
  AND edge1.amount / edge2.amount < $upperbound
  AND edge3.amount > $threshold AND $start_time < edge3.timestamp < $end_time
  AND edge4.amount > $threshold AND $start_time < edge4.timestamp < $end_time
WITH
  sum(edge1.amount) AS depositAmount,
  sum(edge2.amount) AS repayAmount,
  sum(edge3.amount) AS inAmount,
  sum(edge4.amount) AS outAmount
RETURN
  CASE
    WHEN repayAmount IS NULL OR repayAmount = 0 THEN null
    ELSE round(1000.0 * depositAmount / repayAmount) / 1000
  END AS ratioRepay,
  CASE
    WHEN outAmount IS NULL OR outAmount = 0 THEN null
    ELSE round(1000.0 * depositAmount / outAmount) / 1000
  END AS ratioOut,
  CASE
    WHEN outAmount IS NULL OR outAmount = 0 THEN null
    ELSE round(1000.0 * inAmount / outAmount) / 1000
  END AS ratioIn
