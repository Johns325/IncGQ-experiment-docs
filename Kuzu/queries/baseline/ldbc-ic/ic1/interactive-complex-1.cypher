// Q1. Transitive friends with certain name
// Kuzu rewrite: find matching persons within 1..3 KNOWS hops and keep the minimum path length.
/*
:param [{ personId, firstName }] => { RETURN
  4398046511333 AS personId,
  "Jose" AS firstName
}
*/
MATCH path = (p:PERSON {id: $personId})-[:KNOWS*1..3]-(friend:PERSON {firstName: $firstName})
WHERE p.id <> friend.id
WITH friend, min(length(path)) AS distance
ORDER BY
    distance ASC,
    friend.lastName ASC,
    friend.id ASC
LIMIT 20

MATCH (friend)-[:ISLOCATEDIN]->(friendCity:PLACE)
WHERE friendCity.type = 'city'
OPTIONAL MATCH (friend)-[studyAt:STUDYAT]->(uni:ORGANISATION)-[:ISLOCATEDIN]->(uniCity:PLACE)
WITH friend, friendCity, distance,
     collect(
       CASE
         WHEN uni IS NULL THEN NULL
         ELSE [uni.name, CAST(studyAt.classYear AS STRING), uniCity.name]
       END
     ) AS unis

OPTIONAL MATCH (friend)-[workAt:WORKAT]->(company:ORGANISATION)-[:ISLOCATEDIN]->(companyCountry:PLACE)
WITH friend, friendCity, distance, unis,
     collect(
       CASE
         WHEN company IS NULL THEN NULL
         ELSE [company.name, CAST(workAt.workFrom AS STRING), companyCountry.name]
       END
     ) AS companies

RETURN
    friend.id AS friendId,
    friend.lastName AS friendLastName,
    distance AS distanceFromPerson,
    friend.birthday AS friendBirthday,
    friend.creationDate AS friendCreationDate,
    friend.gender AS friendGender,
    friend.browserUsed AS friendBrowserUsed,
    friend.locationIP AS friendLocationIp,
    friend.email AS friendEmails,
    friend.language AS friendLanguages,
    friendCity.name AS friendCityName,
    unis AS friendUniversities,
    companies AS friendCompanies
ORDER BY
    distanceFromPerson ASC,
    friendLastName ASC,
    friendId ASC
LIMIT 20
