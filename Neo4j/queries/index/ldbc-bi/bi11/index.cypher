// Source-aligned with Kuzu queries/index/ldbc-bi/bi11/index.cypher.
MATCH (person:Person) REMOVE person.countryName;
MATCH (person:Person)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country:Country)
SET person.countryName = country.name;
