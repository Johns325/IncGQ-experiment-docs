// Q3. Popular topics in a country
// Kuzu adaptation: Country/City are PLACE rows and Message is POST:COMMENT.
MATCH
  (country:PLACE {name: $country})<-[:ISPARTOF]-(city:PLACE)<-[:ISLOCATEDIN]-
  (person:PERSON)<-[:HASMODERATOR]-(forum:FORUM)-[:CONTAINEROF]->
  (post:POST)<-[:REPLYOF*0..]-(message:POST:COMMENT)-[:HASTAG]->(:TAG)-[:HASTYPE]->(:TAGCLASS {name: $tagClass})
WHERE country.type = 'country'
  AND city.type = 'city'
RETURN
  forum.id AS forumId,
  forum.title AS forumTitle,
  forum.creationDate AS forumCreationDate,
  person.id AS personId,
  count(DISTINCT message) AS messageCount
ORDER BY messageCount DESC, forumId ASC
LIMIT 20
