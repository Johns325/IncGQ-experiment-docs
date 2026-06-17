ALTER TABLE Person ADD IF NOT EXISTS countryId int64 DEFAULT 0;
FILL Person(countryId) FROM (
  MATCH (country:Country)<-[:City_isPartOf_Country]-(:City)<-[:Person_isLocatedIn_City]-(person:Person)
  RETURN person.PersonId, country.CountryId
);