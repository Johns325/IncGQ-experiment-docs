MATCH (person1:PERSON {id : {}})-[path:KNOWS* WSHORTEST(bi15_weight)]-(person2 :PERSON {id: {} })
RETURN  CASE path IS NULL
WHEN TRUE THEN -1.0
ELSE cost(path)
END AS totalCost;
