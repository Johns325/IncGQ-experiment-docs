FILL PERSON(countryName) FROM (
  MATCH (f:PERSON)-[ISLOCATEDIN]->(city:PLACE)-[:ISPARTOF]->(country2:PLACE)
  RETURN f.id, country2.name);
