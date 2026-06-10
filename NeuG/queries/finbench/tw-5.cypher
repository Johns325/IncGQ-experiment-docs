MATCH (p:Person {id: $personId})
CREATE (:Loan {id: $loanId, loanAmount: $amount})<-[:PersonApplyLoan {timestamp: $currentTime}]-(p)
