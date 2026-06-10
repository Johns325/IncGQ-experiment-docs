MATCH (a:Person)-[:ISLOCATEDIN]->(:PLACE)-[:ISPARTOF]->(country1:PLACE {name : '{}'}), (a)-[k1:KNOWS]-(b:Person)
WHERE a.id < b.id
WITH DISTINCT a, b
MATCH (b)-[:ISLOCATEDIN]->(:PLACE)-[:ISPARTOF]->(country2:PLACE {name : '{}'})
WITH DISTINCT a, b
MATCH (b)-[k2:KNOWS]-(c:Person), (c)-[:ISLOCATEDIN]->(:PLACE)-[:ISPARTOF]->(country3:PLACE {name : '{}'})
WHERE b.id < c.id
WITH DISTINCT a, b, c
MATCH (c)-[k3:KNOWS]-(a)
WITH DISTINCT a, b, c
RETURN count(*) AS count;
