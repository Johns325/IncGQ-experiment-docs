// TCR-12 for Kuzu: manually unroll person guarantee paths of length 1..3.
MATCH (p1:Person {id: $id})
OPTIONAL MATCH (p1)-[g1:PersonGuaranteePerson]->(p2:Person)-[:PersonApplyLoan]->(loan1:Loan)
WHERE $start_time < g1.timestamp AND g1.timestamp < $end_time
WITH p1, coalesce(sum(loan1.loanAmount), 0.0) AS sum1, count(loan1) AS count1
OPTIONAL MATCH (p1)-[g1:PersonGuaranteePerson]->(:Person)-[g2:PersonGuaranteePerson]->(p3:Person)-[:PersonApplyLoan]->(loan2:Loan)
WHERE $start_time < g1.timestamp AND g1.timestamp < $end_time
  AND $start_time < g2.timestamp AND g2.timestamp < $end_time
WITH p1, sum1, count1, coalesce(sum(loan2.loanAmount), 0.0) AS sum2, count(loan2) AS count2
OPTIONAL MATCH (p1)-[g1:PersonGuaranteePerson]->(:Person)-[g2:PersonGuaranteePerson]->(:Person)-[g3:PersonGuaranteePerson]->(p4:Person)-[:PersonApplyLoan]->(loan3:Loan)
WHERE $start_time < g1.timestamp AND g1.timestamp < $end_time
  AND $start_time < g2.timestamp AND g2.timestamp < $end_time
  AND $start_time < g3.timestamp AND g3.timestamp < $end_time
WITH sum1, count1, sum2, count2, coalesce(sum(loan3.loanAmount), 0.0) AS sum3, count(loan3) AS count3
RETURN sum1 + sum2 + sum3 AS sumLoanAmount, count1 + count2 + count3 AS numLoans
