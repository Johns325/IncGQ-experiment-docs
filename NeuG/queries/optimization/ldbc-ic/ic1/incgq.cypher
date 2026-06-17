MATCH (p: PERSON {id : {}}) -[k:KNOWS*SHORTEST 1..3]-(f:PERSON {firstName : '{}' })
where f <> p
WITH f, length(k) as distance
WITH f, distance, f.lastName as lastName, f.id as id
ORDER  BY distance ASC, lastName ASC, id ASC
LIMIT 20
OPTIONAL MATCH (f:PERSON)-[workAt:WORKAT]->(company:ORGANISATION)-[:ISLOCATEDIN]->(country:PLACE)
WITH f, distance, CASE WHEN company is null Then null ELSE [company.name,workAt.workFrom, country.name] END as companies
WITH f, COLLECT(companies) AS company_info, distance
OPTIONAL MATCH (f: PERSON)-[studyAt:STUDYAT]->(university:ORGANISATION)-[:ISLOCATEDIN]->(universityCity:PLACE)
WITH f, company_info, distance, university.name as university_name, universityCity.name as university_city_name, studyAt.classYear as university_class_year
WITH f, company_info, distance,
  CASE  WHEN university_name is null OR university_name = "" Then null ELSE [university_name,university_class_year, university_city_name] END as universities
WITH f, COLLECT(universities) as university_info , company_info, distance
MATCH (f:PERSON)-[:ISLOCATEDIN]->(locationCity:PLACE)
return f.id AS friendId, distance AS distanceFromPerson, f.lastName AS friendLastName, f.birthday AS friendBirthday, f.creationDate AS friendCreationDate, f.gender AS friendGender, f.browserUsed AS friendBrowserUsed,f.locationIP AS friendLocationIp,
        locationCity.name AS friendCityName, f.email AS friendEmail, f.language AS friendLanguage, university_info AS friendUniversities, company_info AS friendCompanies
ORDER BY distanceFromPerson ASC, friendLastName ASC, friendId ASC LIMIT 20;
