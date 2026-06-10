// source: query_dense_8_116.graph
// vertices: 8, edges: 22
MATCH (n0)-[r0:authored|:contains|:contributed_to]-(n1),
      (n0)-[r1:authored|:contains|:contributed_to]-(n2),
      (n0)-[r2:authored|:contains|:contributed_to]-(n3),
      (n0)-[r3:authored|:contains|:contributed_to]-(n4),
      (n0)-[r4:authored|:contains|:contributed_to]-(n5),
      (n0)-[r5:authored|:contains|:contributed_to]-(n6),
      (n1)-[r6:authored|:contains|:contributed_to]-(n2),
      (n1)-[r7:authored|:contains|:contributed_to]-(n3),
      (n1)-[r8:authored|:contains|:contributed_to]-(n4),
      (n1)-[r9:authored|:contains|:contributed_to]-(n5),
      (n1)-[r10:authored|:contains|:contributed_to]-(n6),
      (n2)-[r11:authored|:contains|:contributed_to]-(n3),
      (n2)-[r12:authored|:contains|:contributed_to]-(n4),
      (n2)-[r13:authored|:contains|:contributed_to]-(n5),
      (n2)-[r14:authored|:contains|:contributed_to]-(n6),
      (n2)-[r15:authored|:contains|:contributed_to]-(n7),
      (n3)-[r16:authored|:contains|:contributed_to]-(n4),
      (n3)-[r17:authored|:contains|:contributed_to]-(n5),
      (n3)-[r18:authored|:contains|:contributed_to]-(n6),
      (n4)-[r19:authored|:contains|:contributed_to]-(n5),
      (n4)-[r20:authored|:contains|:contributed_to]-(n6),
      (n5)-[r21:authored|:contains|:contributed_to]-(n6)
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
