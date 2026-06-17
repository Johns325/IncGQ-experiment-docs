// TCR-2 for Kuzu.
// Uses EXISTS for 1/2/3-hop ordered reverse-transfer reachability, then aggregates each reachable account's loans once.
MATCH (person:Person {id: $id}), (other:Account)<-[deposit:LoanDepositAccount]-(loan:Loan)
WHERE $start_time < deposit.timestamp AND deposit.timestamp < $end_time
  AND (
    EXISTS {
      MATCH (person)-[:PersonOwnAccount]->(account:Account)<-[edge1:AccountTransferAccount]-(other)
      WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
    }
    OR EXISTS {
      MATCH (person)-[:PersonOwnAccount]->(account:Account)<-[edge1:AccountTransferAccount]-(:Account)<-[edge2:AccountTransferAccount]-(other)
      WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
        AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
        AND edge1.timestamp < edge2.timestamp
    }
    OR EXISTS {
      MATCH (person)-[:PersonOwnAccount]->(account:Account)<-[edge1:AccountTransferAccount]-(:Account)<-[edge2:AccountTransferAccount]-(:Account)<-[edge3:AccountTransferAccount]-(other)
      WHERE $start_time < edge1.timestamp AND edge1.timestamp < $end_time
        AND $start_time < edge2.timestamp AND edge2.timestamp < $end_time
        AND $start_time < edge3.timestamp AND edge3.timestamp < $end_time
        AND edge1.timestamp < edge2.timestamp AND edge2.timestamp < edge3.timestamp
    }
  )
RETURN other.id AS otherId, sum(loan.loanAmount) AS sumLoanAmount, sum(loan.balance) AS sumLoanBalance
ORDER BY sumLoanAmount DESC
