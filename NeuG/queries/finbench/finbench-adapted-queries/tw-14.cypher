MATCH (acc:Account {id: $id})
OPTIONAL MATCH (acc)-[:AccountRepayLoan]->(loan:Loan)-[:LoanDepositAccount]->(acc)
DETACH DELETE acc, loan
