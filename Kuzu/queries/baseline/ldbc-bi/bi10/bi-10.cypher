// Q10. Experts in social circle
// Kuzu adaptation: replaces APOC subgraph expansion with Kuzu SHORTEST recursive relationship.
// The supplied SF1 BI parameter files use maxPathDistance = 4, so the fixed 1..4 bound is equivalent for those parameters.
MATCH (startPerson:PERSON {id: $personId})-[path:KNOWS* SHORTEST 1..4]-(expertCandidatePerson:PERSON)
WHERE length(path) >= $minPathDistance
  AND length(path) <= $maxPathDistance
MATCH (expertCandidatePerson)-[:ISLOCATEDIN]->(city:PLACE)-[:ISPARTOF]->(country:PLACE {name: $country})
WHERE city.type = 'city'
  AND country.type = 'country'
MATCH (expertCandidatePerson)<-[:HASCREATOR]-(message:POST:COMMENT)-[:HASTAG]->(:TAG)-[:HASTYPE]->(:TAGCLASS {name: $tagClass})
MATCH (message)-[:HASTAG]->(tag:TAG)
RETURN
  expertCandidatePerson.id AS personId,
  tag.name AS tagName,
  count(DISTINCT message) AS messageCount
ORDER BY messageCount DESC, tagName ASC, personId ASC
LIMIT 100
