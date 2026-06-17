// Source: Neug lsqb/q1/index.cypher.
// Kuzu fallback: the NeuG-style Person.countryId materialization is not
// enabled because updating Person.countryId currently crashes this Kuzu build.
RETURN 'q1 materialization skipped: Kuzu update of Person.countryId segfaults' AS note;
