MATCH (acc:Account {id: $accountId}), (loan: Loan {id: $loanId})
CREATE (acc)-[:AccountRepayLoan {timestamp: $currentTime, amount: $amt}]->(loan)
