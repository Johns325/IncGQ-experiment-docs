// Source: Neug bi13 setup_add_country_name.cypher and setup_fill_country_name.cypher.

ALTER TABLE PERSON DROP IF EXISTS countryName;
ALTER TABLE PERSON ADD countryName STRING DEFAULT '';

MATCH (country:PLACE)<-[:ISPARTOF]-(city:PLACE)<-[:ISLOCATEDIN]-(person:PERSON)
WHERE city.type = 'city' AND country.type = 'country'
SET person.countryName = country.name;
