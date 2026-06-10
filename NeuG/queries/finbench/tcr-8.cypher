MATCH
  (loan:Loan {id: $id})-[edge1:LoanDepositAccount]->(src:Account),
  (src)-[edge234:AccountTransferAccount*1..3 (r, n | WHERE $start_time < r.timestamp AND r.timestamp < $end_time)]->(dst:Account)
WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
WITH loan, length(edge234)+1 AS distanceFromLoan, dst, sum(edge1.amount) AS inflow
RETURN dst.id AS dstId, round(1.0 * inflow / loan.loanAmount, 3) AS ratio, distanceFromLoan
ORDER BY distanceFromLoan DESC, ratio DESC
LIMIT 500
