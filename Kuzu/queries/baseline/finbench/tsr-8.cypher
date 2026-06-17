// TSR-8 for Kuzu.
// The imported Kuzu FinBench schema has no workIn relationship, so p2Id is returned as an empty list.
MATCH (c:Company {id: $id})
OPTIONAL MATCH (c)-[:CompanyOwnAccount]->(acc:Account)
WITH c, collect(DISTINCT acc.id) AS accId
OPTIONAL MATCH (p1:Person)-[:PersonInvestCompany]->(c)
WITH c, accId, collect(DISTINCT p1.id) AS p1Id
OPTIONAL MATCH (com:Company)-[:CompanyInvestCompany]->(c)
WITH c, accId, p1Id, collect(DISTINCT com.id) AS comId
OPTIONAL MATCH (c)-[:CompanyApplyLoan]->(loan:Loan)
RETURN
  accId,
  p1Id,
  [] AS p2Id,
  comId,
  collect(DISTINCT loan.id) AS loanId
