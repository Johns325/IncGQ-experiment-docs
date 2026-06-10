MATCH
  (loan:Loan)-[edge1:LoanDepositAccount]->(mid:Account {id: $id})-[edge2:AccountRepayLoan]->(loan),
  (up:Account)-[edge3:AccountTransferAccount]->(mid)-[edge4:AccountTransferAccount]->(down:Account)
WHERE edge1.amount > $threshold AND $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND edge2.amount > $threshold AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  AND edge3.amount > $threshold AND $start_time < edge3.timestamp AND edge3.timestamp < $end_time
  AND edge4.amount > $threshold AND $start_time < edge4.timestamp AND edge4.timestamp < $end_time
RETURN
  round(1.0 * sum(edge1.amount) / sum(edge2.amount), 3) AS ratioRepay,
  round(1.0 * sum(edge1.amount) / sum(edge4.amount), 3) AS ratioOut,
  round(1.0 * sum(edge3.amount) / sum(edge4.amount), 3) AS ratioIn
LIMIT 500
