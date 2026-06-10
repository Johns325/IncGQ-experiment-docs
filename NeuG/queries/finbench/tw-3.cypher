MATCH (dst:Account {id: $dstId}), (src:Account {id: $srcId})
CREATE (src)-[:AccountTransferAccount {timestamp: $currentTime, amount: $amt}]->(dst)
