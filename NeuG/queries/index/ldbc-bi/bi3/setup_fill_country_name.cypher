FILL PERSON(countryName) FROM (
MATCH (country:PLACE)<-[:ISPARTOF]-(:PLACE)<-[:ISLOCATEDIN]-(person:PERSON)
RETURN person.id, country.name);
