// Source: Neug ic1 setup_add_university_*.cypher and setup_fill_university.cypher.

ALTER TABLE PERSON DROP IF EXISTS universityName;
ALTER TABLE PERSON DROP IF EXISTS universityClassYear;
ALTER TABLE PERSON DROP IF EXISTS universityCityName;
ALTER TABLE PERSON ADD universityName STRING DEFAULT '';
ALTER TABLE PERSON ADD universityClassYear INT32 DEFAULT 0;
ALTER TABLE PERSON ADD universityCityName STRING DEFAULT '';

MATCH (person:PERSON)-[studyAt:STUDYAT]->(university:ORGANISATION)-[:ISLOCATEDIN]->(universityCity:PLACE)
SET person.universityName = university.name,
    person.universityClassYear = studyAt.classYear,
    person.universityCityName = universityCity.name;
