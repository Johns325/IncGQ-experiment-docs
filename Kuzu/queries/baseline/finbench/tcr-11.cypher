// TCR-11 for Kuzu.
// The imported Kuzu schema stores investment ratio directly on PersonInvestCompany/CompanyInvestCompany.
MATCH (investor:Person)-[r1:PersonInvestCompany]->(comp:Company {id: $id})
RETURN investor.id AS id, 'Person' AS type, round(r1.ratio, 3) AS ratio
UNION ALL
MATCH (investor:Company)-[r1:CompanyInvestCompany]->(comp:Company {id: $id})
RETURN investor.id AS id, 'Company' AS type, round(r1.ratio, 3) AS ratio
UNION ALL
MATCH (investor:Person)-[r1:PersonInvestCompany]->(:Company)-[r2:CompanyInvestCompany]->(comp:Company {id: $id})
RETURN investor.id AS id, 'Person' AS type, round(r1.ratio * r2.ratio, 3) AS ratio
UNION ALL
MATCH (investor:Company)-[r1:CompanyInvestCompany]->(:Company)-[r2:CompanyInvestCompany]->(comp:Company {id: $id})
RETURN investor.id AS id, 'Company' AS type, round(r1.ratio * r2.ratio, 3) AS ratio
UNION ALL
MATCH (investor:Person)-[r1:PersonInvestCompany]->(:Company)-[r2:CompanyInvestCompany]->(:Company)-[r3:CompanyInvestCompany]->(comp:Company {id: $id})
RETURN investor.id AS id, 'Person' AS type, round(r1.ratio * r2.ratio * r3.ratio, 3) AS ratio
UNION ALL
MATCH (investor:Company)-[r1:CompanyInvestCompany]->(:Company)-[r2:CompanyInvestCompany]->(:Company)-[r3:CompanyInvestCompany]->(comp:Company {id: $id})
RETURN investor.id AS id, 'Company' AS type, round(r1.ratio * r2.ratio * r3.ratio, 3) AS ratio
ORDER BY ratio DESC
