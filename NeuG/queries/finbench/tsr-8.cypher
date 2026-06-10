MATCH (c:Company {id: $id})
OPTIONAL MATCH (c)-[:CompanyOwnAccount]->(acc:Account)
OPTIONAL MATCH (p1:Person)-[:PersonInvestCompany]->(c)
OPTIONAL MATCH (com:Company)-[:CompanyInvestCompany]->(c)
OPTIONAL MATCH (c)-[:CompanyApplyLoan]->(loan:Loan)
RETURN
  collect(acc.id) AS accId,
  collect(p1.id) AS p1Id,
  NULL AS p2Id,
  collect(com.id) AS comId,
  collect(loan.id) AS loanId
