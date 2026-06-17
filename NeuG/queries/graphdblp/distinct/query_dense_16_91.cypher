// source: query_dense_16_91.graph
// vertices: 16, edges: 45
MATCH (n0)-[r0:authored|contains|contributed_to]-(n1),
      (n0)-[r1:authored|contains|contributed_to]-(n2),
      (n0)-[r2:authored|contains|contributed_to]-(n3),
      (n0)-[r3:authored|contains|contributed_to]-(n4),
      (n0)-[r4:authored|contains|contributed_to]-(n5),
      (n0)-[r5:authored|contains|contributed_to]-(n6),
      (n0)-[r6:authored|contains|contributed_to]-(n7),
      (n1)-[r7:authored|contains|contributed_to]-(n2),
      (n1)-[r8:authored|contains|contributed_to]-(n3),
      (n1)-[r9:authored|contains|contributed_to]-(n4),
      (n1)-[r10:authored|contains|contributed_to]-(n5),
      (n1)-[r11:authored|contains|contributed_to]-(n6),
      (n1)-[r12:authored|contains|contributed_to]-(n7),
      (n1)-[r13:authored|contains|contributed_to]-(n8),
      (n1)-[r14:authored|contains|contributed_to]-(n9),
      (n1)-[r15:authored|contains|contributed_to]-(n10),
      (n1)-[r16:authored|contains|contributed_to]-(n11),
      (n2)-[r17:authored|contains|contributed_to]-(n3),
      (n2)-[r18:authored|contains|contributed_to]-(n4),
      (n2)-[r19:authored|contains|contributed_to]-(n5),
      (n2)-[r20:authored|contains|contributed_to]-(n6),
      (n2)-[r21:authored|contains|contributed_to]-(n7),
      (n2)-[r22:authored|contains|contributed_to]-(n9),
      (n2)-[r23:authored|contains|contributed_to]-(n10),
      (n2)-[r24:authored|contains|contributed_to]-(n11),
      (n3)-[r25:authored|contains|contributed_to]-(n4),
      (n3)-[r26:authored|contains|contributed_to]-(n5),
      (n3)-[r27:authored|contains|contributed_to]-(n6),
      (n3)-[r28:authored|contains|contributed_to]-(n7),
      (n3)-[r29:authored|contains|contributed_to]-(n10),
      (n3)-[r30:authored|contains|contributed_to]-(n11),
      (n4)-[r31:authored|contains|contributed_to]-(n5),
      (n4)-[r32:authored|contains|contributed_to]-(n6),
      (n4)-[r33:authored|contains|contributed_to]-(n7),
      (n5)-[r34:authored|contains|contributed_to]-(n6),
      (n5)-[r35:authored|contains|contributed_to]-(n7),
      (n6)-[r36:authored|contains|contributed_to]-(n7),
      (n7)-[r37:authored|contains|contributed_to]-(n8),
      (n8)-[r38:authored|contains|contributed_to]-(n12),
      (n8)-[r39:authored|contains|contributed_to]-(n13),
      (n10)-[r40:authored|contains|contributed_to]-(n11),
      (n12)-[r41:authored|contains|contributed_to]-(n13),
      (n13)-[r42:authored|contains|contributed_to]-(n14),
      (n13)-[r43:authored|contains|contributed_to]-(n15),
      (n14)-[r44:authored|contains|contributed_to]-(n15)
WHERE id(n0) <> id(n1)
  AND id(n0) <> id(n2)
  AND id(n0) <> id(n3)
  AND id(n0) <> id(n4)
  AND id(n0) <> id(n5)
  AND id(n0) <> id(n6)
  AND id(n0) <> id(n7)
  AND id(n0) <> id(n8)
  AND id(n0) <> id(n9)
  AND id(n0) <> id(n10)
  AND id(n0) <> id(n11)
  AND id(n0) <> id(n12)
  AND id(n0) <> id(n13)
  AND id(n0) <> id(n14)
  AND id(n0) <> id(n15)
  AND id(n1) <> id(n2)
  AND id(n1) <> id(n3)
  AND id(n1) <> id(n4)
  AND id(n1) <> id(n5)
  AND id(n1) <> id(n6)
  AND id(n1) <> id(n7)
  AND id(n1) <> id(n8)
  AND id(n1) <> id(n9)
  AND id(n1) <> id(n10)
  AND id(n1) <> id(n11)
  AND id(n1) <> id(n12)
  AND id(n1) <> id(n13)
  AND id(n1) <> id(n14)
  AND id(n1) <> id(n15)
  AND id(n2) <> id(n3)
  AND id(n2) <> id(n4)
  AND id(n2) <> id(n5)
  AND id(n2) <> id(n6)
  AND id(n2) <> id(n7)
  AND id(n2) <> id(n8)
  AND id(n2) <> id(n9)
  AND id(n2) <> id(n10)
  AND id(n2) <> id(n11)
  AND id(n2) <> id(n12)
  AND id(n2) <> id(n13)
  AND id(n2) <> id(n14)
  AND id(n2) <> id(n15)
  AND id(n3) <> id(n4)
  AND id(n3) <> id(n5)
  AND id(n3) <> id(n6)
  AND id(n3) <> id(n7)
  AND id(n3) <> id(n8)
  AND id(n3) <> id(n9)
  AND id(n3) <> id(n10)
  AND id(n3) <> id(n11)
  AND id(n3) <> id(n12)
  AND id(n3) <> id(n13)
  AND id(n3) <> id(n14)
  AND id(n3) <> id(n15)
  AND id(n4) <> id(n5)
  AND id(n4) <> id(n6)
  AND id(n4) <> id(n7)
  AND id(n4) <> id(n8)
  AND id(n4) <> id(n9)
  AND id(n4) <> id(n10)
  AND id(n4) <> id(n11)
  AND id(n4) <> id(n12)
  AND id(n4) <> id(n13)
  AND id(n4) <> id(n14)
  AND id(n4) <> id(n15)
  AND id(n5) <> id(n6)
  AND id(n5) <> id(n7)
  AND id(n5) <> id(n8)
  AND id(n5) <> id(n9)
  AND id(n5) <> id(n10)
  AND id(n5) <> id(n11)
  AND id(n5) <> id(n12)
  AND id(n5) <> id(n13)
  AND id(n5) <> id(n14)
  AND id(n5) <> id(n15)
  AND id(n6) <> id(n7)
  AND id(n6) <> id(n8)
  AND id(n6) <> id(n9)
  AND id(n6) <> id(n10)
  AND id(n6) <> id(n11)
  AND id(n6) <> id(n12)
  AND id(n6) <> id(n13)
  AND id(n6) <> id(n14)
  AND id(n6) <> id(n15)
  AND id(n7) <> id(n8)
  AND id(n7) <> id(n9)
  AND id(n7) <> id(n10)
  AND id(n7) <> id(n11)
  AND id(n7) <> id(n12)
  AND id(n7) <> id(n13)
  AND id(n7) <> id(n14)
  AND id(n7) <> id(n15)
  AND id(n8) <> id(n9)
  AND id(n8) <> id(n10)
  AND id(n8) <> id(n11)
  AND id(n8) <> id(n12)
  AND id(n8) <> id(n13)
  AND id(n8) <> id(n14)
  AND id(n8) <> id(n15)
  AND id(n9) <> id(n10)
  AND id(n9) <> id(n11)
  AND id(n9) <> id(n12)
  AND id(n9) <> id(n13)
  AND id(n9) <> id(n14)
  AND id(n9) <> id(n15)
  AND id(n10) <> id(n11)
  AND id(n10) <> id(n12)
  AND id(n10) <> id(n13)
  AND id(n10) <> id(n14)
  AND id(n10) <> id(n15)
  AND id(n11) <> id(n12)
  AND id(n11) <> id(n13)
  AND id(n11) <> id(n14)
  AND id(n11) <> id(n15)
  AND id(n12) <> id(n13)
  AND id(n12) <> id(n14)
  AND id(n12) <> id(n15)
  AND id(n13) <> id(n14)
  AND id(n13) <> id(n15)
  AND id(n14) <> id(n15)
RETURN count(*) AS count;
