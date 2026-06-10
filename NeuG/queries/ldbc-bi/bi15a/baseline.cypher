MATCH (person1:PERSON {id : {}}),(person2 :PERSON {id: {} })
OPTIONAL MATCH (person1)-[path:KNOWS* WSHORTEST(weight)]-(person2)
RETURN CASE path IS NULL
  WHEN TRUE THEN -1.0
  ELSE cost(path)
END AS totalCost;
