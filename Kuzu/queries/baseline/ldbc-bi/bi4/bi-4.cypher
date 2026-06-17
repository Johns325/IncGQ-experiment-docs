// Q4. Top message creators in a country
// Kuzu adaptation: rewrites Neo4j CALL/UNION into an OPTIONAL MATCH over top forum members.
MATCH (country:PLACE)<-[:ISPARTOF]-(city:PLACE)<-[:ISLOCATEDIN]-(member:PERSON)<-[:HASMEMBER]-(forum:FORUM)
WHERE country.type = 'country'
  AND city.type = 'city'
  AND forum.creationDate > $date
WITH country, forum, count(member) AS numberOfMembers
ORDER BY numberOfMembers DESC, forum.id ASC, country.id ASC
LIMIT 100
WITH collect(DISTINCT forum) AS topForums
UNWIND topForums AS memberForum
MATCH (person:PERSON)<-[:HASMEMBER]-(memberForum)
WITH DISTINCT topForums, person
UNWIND topForums AS topForum
OPTIONAL MATCH (topForum)-[:CONTAINEROF]->(post:POST)<-[:REPLYOF*0..]-(message:POST:COMMENT)-[:HASCREATOR]->(person)<-[:HASMEMBER]-(messageForum:FORUM)
WHERE messageForum IN topForums
WITH person, count(DISTINCT message) AS messageCount
RETURN
  person.id AS personId,
  person.firstName AS personFirstName,
  person.lastName AS personLastName,
  person.creationDate AS personCreationDate,
  messageCount
ORDER BY messageCount DESC, personId ASC
LIMIT 100
