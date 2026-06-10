CREATE (:Company {id: $companyId, name: $companyName})-[:CompanyOwnAccount]->(:Account {id: $accountId, createTime: $currentTime, isBlocked: $accountBlocked, type: $accountType})
