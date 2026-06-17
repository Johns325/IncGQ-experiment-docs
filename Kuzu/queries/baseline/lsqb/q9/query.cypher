MATCH (person3:Person)-[:Person_hasInterest_Tag]->(tag:Tag)
WITH person3, count(tag) AS interestCount
MATCH (person1:Person)-[:Person_knows_Person]-(person2:Person)-[:Person_knows_Person]-(person3)
WHERE NOT (person1)-[:Person_knows_Person]-(person3)
  AND person1 <> person3
RETURN sum(interestCount) AS count
