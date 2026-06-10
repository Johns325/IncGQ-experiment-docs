CREATE (:Person {id: $personId, name: $personName})-[:PersonOwnAccount]->(:Account {id: $accountId, createTime: $currentTime, isBlocked: $accountBlocked, type: $accountType})
