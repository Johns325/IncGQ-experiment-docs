MATCH (dst:Account {id: $dstId, type: 'card'}), (src:Account {id: $srcId})
CREATE (src)-[:withdraw {timestamp: $currentTime, amount: $amt}]->(dst)
