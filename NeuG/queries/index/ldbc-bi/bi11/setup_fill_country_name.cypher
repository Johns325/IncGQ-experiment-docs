FILL PERSON(countryName) FROM (MATCH (n:PERSON)-[:ISLOCATEDIN]->(:PLACE)-[:ISPARTOF]->(country:PLACE) RETURN n.id, country.name);
