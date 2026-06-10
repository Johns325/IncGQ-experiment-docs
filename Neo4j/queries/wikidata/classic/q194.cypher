// q194; freq=1; rpq=<52>/((<690>|<52>))*; readable=<P52>/((<P690>|<P52>))*
MATCH (s)-[:P52]->(m218_0_0)
MATCH (m218_0_0)-[:P52|P690*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;
