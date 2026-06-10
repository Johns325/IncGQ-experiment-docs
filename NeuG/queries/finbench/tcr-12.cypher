MATCH (p1:Person {id: $id})-[path:PersonGuaranteePerson*1..3 (r, n | WHERE $start_time < r.timestamp AND r.timestamp < $end_time)]->(person:Person)
MATCH (person)-[:PersonApplyLoan]->(loan:Loan)
RETURN sum(loan.loanAmount) AS sumLoanAmount, count(loan) AS numLoans
