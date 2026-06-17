MATCH (acc:Account {id: $accountId})
CREATE (acc)<-[:MediumSignInAccount {timestamp: $currentTime}]-(:Medium {id: $mediumId, isBlocked: $mediumBlocked})
