// Source-aligned with Kuzu queries/index/ldbc-ic/ic1/index.cypher.
MATCH (person:Person) REMOVE person.universityName, person.universityClassYear, person.universityCityName;
MATCH (person:Person)-[studyAt:STUDY_AT]->(university:University)-[:IS_LOCATED_IN]->(universityCity:City)
SET person.universityName = university.name,
    person.universityClassYear = studyAt.classYear,
    person.universityCityName = universityCity.name;
