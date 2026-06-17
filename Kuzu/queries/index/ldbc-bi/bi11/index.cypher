// Source: Neug bi11 setup_add_country_name.cypher and setup_fill_country_name.cypher.

ALTER TABLE PERSON DROP IF EXISTS countryName;
ALTER TABLE PERSON ADD countryName STRING DEFAULT '';

MATCH (person:PERSON)-[:ISLOCATEDIN]->(city:PLACE)-[:ISPARTOF]->(country:PLACE)
WHERE city.type = 'city' AND country.type = 'country'
SET person.countryName = country.name;
