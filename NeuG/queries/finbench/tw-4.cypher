MATCH (dst:Account {id: $dstId, type: 'card'}), (src:Account {id: $srcId})
CREATE (src)-[:AccountWithdrawAccount {timestamp: $currentTime, amount: $amt}]->(dst)
