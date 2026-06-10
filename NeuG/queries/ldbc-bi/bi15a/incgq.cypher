MATCH (pA:PERSON {id: {}})-[knows:KNOWS]->(pB:PERSON) WITH pA, knows, pB
MATCH (pA)<-[:HASCREATOR]-(m1:COMMENT:POST)-[:REPLYOF]-(m2:COMMENT:POST)-[:HASCREATOR]->(pB), (m1)-[:REPLYOF*0..]->(p:POST)<-[:CONTAINEROF]-(forum:FORUM)
WITH 1.0 / (sum(CASE forum IS NOT NULL WHEN TRUE THEN CASE (label(m1) = 'POST' OR label(m2) = 'POST') WHEN TRUE THEN 1.0 ELSE 0.5 END ELSE 0.0 END) + 1.0) AS w
MATCH (person1:PERSON {id : {}})-[path:KNOWS* WSHORTEST(bi15_weight)]-(person2 :PERSON {id: {} })
RETURN  CASE path IS NULL
WHEN TRUE THEN -1.0
ELSE cost(path)
END AS totalCost;
