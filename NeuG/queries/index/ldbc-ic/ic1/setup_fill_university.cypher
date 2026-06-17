FILL PERSON(universityName, universityClassYear, universityCityName) FROM (
  MATCH (f: PERSON)-[studyAt:STUDYAT]->(university:ORGANISATION)-[:ISLOCATEDIN]->(universityCity:PLACE)
  RETURN f.id, university.name, studyAt.classYear, universityCity.name);
