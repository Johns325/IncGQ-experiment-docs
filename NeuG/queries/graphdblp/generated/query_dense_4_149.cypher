// source: query_dense_4_149.graph
// vertices: 4, edges: 4
MATCH (n0)-[r0:authored|contains|contributed_to]-(n1),
      (n0)-[r1:authored|contains|contributed_to]-(n2),
      (n1)-[r2:authored|contains|contributed_to]-(n2),
      (n1)-[r3:authored|contains|contributed_to]-(n3)
WHERE id(n0) <> id(n1)
  AND id(n0) <> id(n2)
  AND id(n0) <> id(n3)
  AND id(n1) <> id(n2)
  AND id(n1) <> id(n3)
  AND id(n2) <> id(n3)
RETURN count(*) AS count;
