// source: query_sparse_8_191.graph
// vertices: 8, edges: 11
MATCH (n0)-[r0:authored|contains|contributed_to]-(n1),
      (n0)-[r1:authored|contains|contributed_to]-(n2),
      (n0)-[r2:authored|contains|contributed_to]-(n3),
      (n0)-[r3:authored|contains|contributed_to]-(n4),
      (n0)-[r4:authored|contains|contributed_to]-(n6),
      (n1)-[r5:authored|contains|contributed_to]-(n2),
      (n1)-[r6:authored|contains|contributed_to]-(n3),
      (n2)-[r7:authored|contains|contributed_to]-(n3),
      (n4)-[r8:authored|contains|contributed_to]-(n5),
      (n4)-[r9:authored|contains|contributed_to]-(n6),
      (n6)-[r10:authored|contains|contributed_to]-(n7)
WHERE id(n0) <> id(n1)
  AND id(n0) <> id(n2)
  AND id(n0) <> id(n3)
  AND id(n0) <> id(n4)
  AND id(n0) <> id(n5)
  AND id(n0) <> id(n6)
  AND id(n0) <> id(n7)
  AND id(n1) <> id(n2)
  AND id(n1) <> id(n3)
  AND id(n1) <> id(n4)
  AND id(n1) <> id(n5)
  AND id(n1) <> id(n6)
  AND id(n1) <> id(n7)
  AND id(n2) <> id(n3)
  AND id(n2) <> id(n4)
  AND id(n2) <> id(n5)
  AND id(n2) <> id(n6)
  AND id(n2) <> id(n7)
  AND id(n3) <> id(n4)
  AND id(n3) <> id(n5)
  AND id(n3) <> id(n6)
  AND id(n3) <> id(n7)
  AND id(n4) <> id(n5)
  AND id(n4) <> id(n6)
  AND id(n4) <> id(n7)
  AND id(n5) <> id(n6)
  AND id(n5) <> id(n7)
  AND id(n6) <> id(n7)
RETURN count(*) AS count;
