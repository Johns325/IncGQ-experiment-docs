// Q11. Job referral
// Parameters for Kuzu Python:
//   personId: INT64, countryName: STRING, workFromYear: INT64
MATCH (person:PERSON {id: $personId})-[:KNOWS*1..2]-(friend:PERSON)
WHERE NOT person = friend
WITH DISTINCT friend
MATCH (friend)-[workAt:WORKAT]->(company:ORGANISATION)-[:ISLOCATEDIN]->(country:PLACE {name: $countryName})
WHERE country.type = 'country'
  AND company.type = 'company'
  AND workAt.workFrom < $workFromYear
RETURN friend.id AS personId,
       friend.firstName AS personFirstName,
       friend.lastName AS personLastName,
       company.name AS organizationName,
       workAt.workFrom AS organizationWorkFromYear
ORDER BY organizationWorkFromYear ASC, personId ASC, organizationName DESC
LIMIT 10
