ALTER TABLE PERSON ADD IF NOT EXISTS universityName STRING;
ALTER TABLE PERSON ADD IF NOT EXISTS universityClassYear INT32;
ALTER TABLE PERSON ADD IF NOT EXISTS universityCityName STRING;
FILL PERSON(universityName, universityClassYear, universityCityName) FROM (
  MATCH (f: PERSON)-[studyAt:STUDYAT]->(university:ORGANISATION)-[:ISLOCATEDIN]->(universityCity:PLACE)
  RETURN f.id, university.name, studyAt.classYear, universityCity.name);
