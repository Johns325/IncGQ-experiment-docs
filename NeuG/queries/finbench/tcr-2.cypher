MATCH
  (person:Person {id: $id})-[:PersonOwnAccount]->(accounts:Account),
  (accounts)<-[edge2:AccountTransferAccount*1..3 (r, n | WHERE $start_time < r.timestamp AND r.timestamp < $end_time)]-(other:Account),
  (other)<-[edge3:LoanDepositAccount]-(loan:Loan)
WHERE $start_time < edge3.timestamp AND edge3.timestamp < $end_time
RETURN other.id AS otherId, sum(loan.loanAmount) AS sumLoanAmount, sum(loan.balance) AS sumLoanBalance
ORDER BY sumLoanAmount DESC
LIMIT 500
