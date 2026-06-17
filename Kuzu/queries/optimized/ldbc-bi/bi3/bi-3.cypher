// Q3. Uses ROOT_POST from queries/index/ldbc-bi/bi3/index.cypher.
MATCH
  (country:PLACE {name: $country})<-[:ISPARTOF]-(city:PLACE)<-[:ISLOCATEDIN]-
  (person:PERSON)<-[:HASMODERATOR]-(forum:FORUM)-[:CONTAINEROF]->
  (post:POST)<-[:ROOT_POST]-(message:POST:COMMENT)-[:HASTAG]->(:TAG)-[:HASTYPE]->(:TAGCLASS {name: $tagClass})
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
