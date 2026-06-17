MATCH (dst:Account {id: $dstId}), (src:Account {id: $srcId})
CREATE (src)-[:transfer {timestamp: $currentTime, amount: $amt}]->(dst)
