// source: query_dense_16_3.graph
// vertices: 16, edges: 72
MATCH (n0)-[r0:authored|:contains|:contributed_to]-(n1),
      (n0)-[r1:authored|:contains|:contributed_to]-(n2),
      (n0)-[r2:authored|:contains|:contributed_to]-(n3),
      (n1)-[r3:authored|:contains|:contributed_to]-(n3),
      (n1)-[r4:authored|:contains|:contributed_to]-(n4),
      (n1)-[r5:authored|:contains|:contributed_to]-(n5),
      (n1)-[r6:authored|:contains|:contributed_to]-(n6),
      (n1)-[r7:authored|:contains|:contributed_to]-(n7),
      (n1)-[r8:authored|:contains|:contributed_to]-(n8),
      (n1)-[r9:authored|:contains|:contributed_to]-(n9),
      (n1)-[r10:authored|:contains|:contributed_to]-(n10),
      (n1)-[r11:authored|:contains|:contributed_to]-(n11),
      (n1)-[r12:authored|:contains|:contributed_to]-(n12),
      (n1)-[r13:authored|:contains|:contributed_to]-(n13),
      (n1)-[r14:authored|:contains|:contributed_to]-(n14),
      (n3)-[r15:authored|:contains|:contributed_to]-(n5),
      (n3)-[r16:authored|:contains|:contributed_to]-(n6),
      (n3)-[r17:authored|:contains|:contributed_to]-(n7),
      (n3)-[r18:authored|:contains|:contributed_to]-(n8),
      (n3)-[r19:authored|:contains|:contributed_to]-(n9),
      (n3)-[r20:authored|:contains|:contributed_to]-(n10),
      (n3)-[r21:authored|:contains|:contributed_to]-(n11),
      (n3)-[r22:authored|:contains|:contributed_to]-(n12),
      (n3)-[r23:authored|:contains|:contributed_to]-(n13),
      (n3)-[r24:authored|:contains|:contributed_to]-(n14),
      (n4)-[r25:authored|:contains|:contributed_to]-(n12),
      (n4)-[r26:authored|:contains|:contributed_to]-(n15),
      (n5)-[r27:authored|:contains|:contributed_to]-(n6),
      (n5)-[r28:authored|:contains|:contributed_to]-(n7),
      (n5)-[r29:authored|:contains|:contributed_to]-(n8),
      (n5)-[r30:authored|:contains|:contributed_to]-(n9),
      (n5)-[r31:authored|:contains|:contributed_to]-(n10),
      (n5)-[r32:authored|:contains|:contributed_to]-(n11),
      (n5)-[r33:authored|:contains|:contributed_to]-(n12),
      (n5)-[r34:authored|:contains|:contributed_to]-(n13),
      (n5)-[r35:authored|:contains|:contributed_to]-(n14),
      (n6)-[r36:authored|:contains|:contributed_to]-(n7),
      (n6)-[r37:authored|:contains|:contributed_to]-(n8),
      (n6)-[r38:authored|:contains|:contributed_to]-(n9),
      (n6)-[r39:authored|:contains|:contributed_to]-(n10),
      (n6)-[r40:authored|:contains|:contributed_to]-(n11),
      (n6)-[r41:authored|:contains|:contributed_to]-(n12),
      (n6)-[r42:authored|:contains|:contributed_to]-(n13),
      (n6)-[r43:authored|:contains|:contributed_to]-(n14),
      (n7)-[r44:authored|:contains|:contributed_to]-(n8),
      (n7)-[r45:authored|:contains|:contributed_to]-(n9),
      (n7)-[r46:authored|:contains|:contributed_to]-(n10),
      (n7)-[r47:authored|:contains|:contributed_to]-(n11),
      (n7)-[r48:authored|:contains|:contributed_to]-(n12),
      (n7)-[r49:authored|:contains|:contributed_to]-(n13),
      (n7)-[r50:authored|:contains|:contributed_to]-(n14),
      (n8)-[r51:authored|:contains|:contributed_to]-(n9),
      (n8)-[r52:authored|:contains|:contributed_to]-(n10),
      (n8)-[r53:authored|:contains|:contributed_to]-(n11),
      (n8)-[r54:authored|:contains|:contributed_to]-(n12),
      (n8)-[r55:authored|:contains|:contributed_to]-(n13),
      (n8)-[r56:authored|:contains|:contributed_to]-(n14),
      (n9)-[r57:authored|:contains|:contributed_to]-(n10),
      (n9)-[r58:authored|:contains|:contributed_to]-(n11),
      (n9)-[r59:authored|:contains|:contributed_to]-(n12),
      (n9)-[r60:authored|:contains|:contributed_to]-(n13),
      (n9)-[r61:authored|:contains|:contributed_to]-(n14),
      (n10)-[r62:authored|:contains|:contributed_to]-(n11),
      (n10)-[r63:authored|:contains|:contributed_to]-(n12),
      (n10)-[r64:authored|:contains|:contributed_to]-(n13),
      (n10)-[r65:authored|:contains|:contributed_to]-(n14),
      (n11)-[r66:authored|:contains|:contributed_to]-(n12),
      (n11)-[r67:authored|:contains|:contributed_to]-(n13),
      (n11)-[r68:authored|:contains|:contributed_to]-(n14),
      (n12)-[r69:authored|:contains|:contributed_to]-(n13),
      (n12)-[r70:authored|:contains|:contributed_to]-(n14),
      (n13)-[r71:authored|:contains|:contributed_to]-(n14)
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
