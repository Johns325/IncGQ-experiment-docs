// TCR-8 for Kuzu.
// Kuzu 0.10 times out on the full 3-hop transfer/withdraw expansion for SF1, so this runnable version uses a 2-hop truncation.
MATCH (loan:Loan {id: $id})-[deposit:LoanDepositAccount]->(src:Account),
      (src)-[edge1:AccountTransferAccount]->(dst:Account)
WHERE $start_time < deposit.timestamp AND deposit.timestamp < $end_time
  AND $start_time < edge1.timestamp AND edge1.timestamp < $end_time
WITH loan, dst, 2 AS distanceFromLoan, sum(edge1.amount) AS inflow
RETURN dst.id AS dstId, round(inflow / loan.loanAmount, 3) AS ratio, distanceFromLoan
UNION ALL
MATCH (loan:Loan {id: $id})-[deposit:LoanDepositAccount]->(src:Account),
      (src)-[edge1:AccountWithdrawAccount]->(dst:Account)
WHERE $start_time < deposit.timestamp AND deposit.timestamp < $end_time
  AND $start_time < edge1.timestamp AND edge1.timestamp < $end_time
WITH loan, dst, 2 AS distanceFromLoan, sum(edge1.amount) AS inflow
RETURN dst.id AS dstId, round(inflow / loan.loanAmount, 3) AS ratio, distanceFromLoan
UNION ALL
MATCH (loan:Loan {id: $id})-[deposit:LoanDepositAccount]->(src:Account),
      (src)-[edge1:AccountTransferAccount]->(:Account)-[edge2:AccountTransferAccount]->(dst:Account)
WHERE $start_time < deposit.timestamp AND deposit.timestamp < $end_time
  AND $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  AND edge2.amount > edge1.amount * $threshold
WITH loan, dst, 3 AS distanceFromLoan, sum(edge2.amount) AS inflow
RETURN dst.id AS dstId, round(inflow / loan.loanAmount, 3) AS ratio, distanceFromLoan
UNION ALL
MATCH (loan:Loan {id: $id})-[deposit:LoanDepositAccount]->(src:Account),
      (src)-[edge1:AccountTransferAccount]->(:Account)-[edge2:AccountWithdrawAccount]->(dst:Account)
WHERE $start_time < deposit.timestamp AND deposit.timestamp < $end_time
  AND $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  AND edge2.amount > edge1.amount * $threshold
WITH loan, dst, 3 AS distanceFromLoan, sum(edge2.amount) AS inflow
RETURN dst.id AS dstId, round(inflow / loan.loanAmount, 3) AS ratio, distanceFromLoan
UNION ALL
MATCH (loan:Loan {id: $id})-[deposit:LoanDepositAccount]->(src:Account),
      (src)-[edge1:AccountWithdrawAccount]->(:Account)-[edge2:AccountTransferAccount]->(dst:Account)
WHERE $start_time < deposit.timestamp AND deposit.timestamp < $end_time
  AND $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  AND edge2.amount > edge1.amount * $threshold
WITH loan, dst, 3 AS distanceFromLoan, sum(edge2.amount) AS inflow
RETURN dst.id AS dstId, round(inflow / loan.loanAmount, 3) AS ratio, distanceFromLoan
UNION ALL
MATCH (loan:Loan {id: $id})-[deposit:LoanDepositAccount]->(src:Account),
      (src)-[edge1:AccountWithdrawAccount]->(:Account)-[edge2:AccountWithdrawAccount]->(dst:Account)
WHERE $start_time < deposit.timestamp AND deposit.timestamp < $end_time
  AND $start_time < edge1.timestamp AND edge1.timestamp < $end_time
  AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
  AND edge2.amount > edge1.amount * $threshold
WITH loan, dst, 3 AS distanceFromLoan, sum(edge2.amount) AS inflow
RETURN dst.id AS dstId, round(inflow / loan.loanAmount, 3) AS ratio, distanceFromLoan
LIMIT 500
