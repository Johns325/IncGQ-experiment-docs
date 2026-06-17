// Q10. Friend recommendation
// Parameters for Kuzu Python:
//   personId: INT64, month: INT64
MATCH (person:PERSON {id: $personId})-[:KNOWS]-(mid:PERSON)-[:KNOWS]-(friend:PERSON)-[:ISLOCATEDIN]->(city:PLACE)
WHERE NOT friend = person
  AND NOT (friend)-[:KNOWS]-(person)
  AND city.type = 'city'
  AND ((date_part('month', friend.birthday) = $month AND date_part('day', friend.birthday) >= 21)
       OR (date_part('month', friend.birthday) = ($month % 12) + 1 AND date_part('day', friend.birthday) < 22))
WITH DISTINCT friend, city, person
OPTIONAL MATCH (friend)<-[:HASCREATOR]-(post:POST)
WITH friend, city, person, count(post) AS postCount
OPTIONAL MATCH (friend)<-[:HASCREATOR]-(commonPost:POST)-[:HASTAG]->(:TAG)<-[:HASINTEREST]-(person)
WITH friend, city, postCount, count(DISTINCT commonPost) AS commonPostCount
RETURN friend.id AS personId,
       friend.firstName AS personFirstName,
       friend.lastName AS personLastName,
       commonPostCount - (postCount - commonPostCount) AS commonInterestScore,
       friend.gender AS personGender,
       city.name AS personCityName
ORDER BY commonInterestScore DESC, personId ASC
LIMIT 10
