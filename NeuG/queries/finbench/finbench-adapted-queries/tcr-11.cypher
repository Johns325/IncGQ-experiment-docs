MATCH path=(comp:Company {id: $id})<-[:PersonInvestCompany|:CompanyInvestCompany*1..3]-(investor)
WHERE label(investor) = 'Company' OR label(investor) = 'Person'
WITH investor.id AS id, label(investor) AS type, length(path) AS distance
RETURN id, type, 0.0 AS ratio
ORDER BY ratio DESC
LIMIT 500
