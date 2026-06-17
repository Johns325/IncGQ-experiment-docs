// Source-aligned with Kuzu queries/index/lsqb/q3/index.cypher.
MATCH (person:Person) REMOVE person.countryId;
MATCH (country:Country)<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-(person:Person)
SET person.countryId = country.id;
