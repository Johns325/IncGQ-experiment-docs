MATCH (person2:Person)-[:Person_isLocatedIn_City]->(city2:City)-[:City_isPartOf_Country]->(country),
      (country:Country)<-[:City_isPartOf_Country]-(city1:City)<-[:Person_isLocatedIn_City]-(person1:Person)-[:Person_knows_Person]-(person2)-[:Person_knows_Person]-(person3:Person)-[:Person_isLocatedIn_City]->(city3:City)-[:City_isPartOf_Country]->(country),
      (person3)-[:Person_knows_Person]-(person1)
RETURN count(*) AS count;
