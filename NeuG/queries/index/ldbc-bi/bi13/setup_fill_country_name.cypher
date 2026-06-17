FILL PERSON(countryName) FROM (
MATCH (country:PLACE)<-[:ISPARTOF]-(:PLACE)<-[:ISLOCATEDIN]-(zombie:PERSON)
RETURN zombie.id, country.name);
