// Uses Person.countryId from queries/index/lsqb/q1/index.cypher.
MATCH (country:Country),
      (person:Person)<-[:HAS_MEMBER]-(:Forum)-[:CONTAINER_OF]->(:Post)<-[:REPLY_OF]-(:Comment)-[:HAS_TAG]->(:Tag)-[:HAS_TYPE]->(:TagClass)
WHERE person.countryId = country.id
RETURN count(*) AS count
