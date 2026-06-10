MATCH (person:Person {id: $id})
OPTIONAL MATCH (person)-[edge1:PersonInvestCompany]->(comp:Company)
RETURN collect(comp.id)
