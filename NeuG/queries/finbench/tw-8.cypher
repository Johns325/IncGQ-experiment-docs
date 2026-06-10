MATCH (acc:Account {id: $accountId}), (loan: Loan {id: $loanId})
CREATE (acc)<-[:LoanDepositAccount {timestamp: $currentTime, amount: $amt}]-(loan)
