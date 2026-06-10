// source: query_dense_24_186.graph
// vertices: 24, edges: 83
MATCH (n0)-[r0:authored|:contains|:contributed_to]-(n1),
      (n1)-[r1:authored|:contains|:contributed_to]-(n21),
      (n2)-[r2:authored|:contains|:contributed_to]-(n3),
      (n2)-[r3:authored|:contains|:contributed_to]-(n4),
      (n2)-[r4:authored|:contains|:contributed_to]-(n5),
      (n2)-[r5:authored|:contains|:contributed_to]-(n6),
      (n2)-[r6:authored|:contains|:contributed_to]-(n7),
      (n2)-[r7:authored|:contains|:contributed_to]-(n8),
      (n2)-[r8:authored|:contains|:contributed_to]-(n9),
      (n2)-[r9:authored|:contains|:contributed_to]-(n10),
      (n2)-[r10:authored|:contains|:contributed_to]-(n11),
      (n2)-[r11:authored|:contains|:contributed_to]-(n12),
      (n2)-[r12:authored|:contains|:contributed_to]-(n13),
      (n2)-[r13:authored|:contains|:contributed_to]-(n14),
      (n2)-[r14:authored|:contains|:contributed_to]-(n15),
      (n3)-[r15:authored|:contains|:contributed_to]-(n4),
      (n3)-[r16:authored|:contains|:contributed_to]-(n6),
      (n3)-[r17:authored|:contains|:contributed_to]-(n7),
      (n3)-[r18:authored|:contains|:contributed_to]-(n8),
      (n3)-[r19:authored|:contains|:contributed_to]-(n9),
      (n3)-[r20:authored|:contains|:contributed_to]-(n10),
      (n3)-[r21:authored|:contains|:contributed_to]-(n11),
      (n3)-[r22:authored|:contains|:contributed_to]-(n12),
      (n3)-[r23:authored|:contains|:contributed_to]-(n13),
      (n3)-[r24:authored|:contains|:contributed_to]-(n14),
      (n3)-[r25:authored|:contains|:contributed_to]-(n15),
      (n4)-[r26:authored|:contains|:contributed_to]-(n6),
      (n4)-[r27:authored|:contains|:contributed_to]-(n8),
      (n4)-[r28:authored|:contains|:contributed_to]-(n9),
      (n4)-[r29:authored|:contains|:contributed_to]-(n10),
      (n4)-[r30:authored|:contains|:contributed_to]-(n11),
      (n4)-[r31:authored|:contains|:contributed_to]-(n12),
      (n4)-[r32:authored|:contains|:contributed_to]-(n13),
      (n4)-[r33:authored|:contains|:contributed_to]-(n14),
      (n4)-[r34:authored|:contains|:contributed_to]-(n15),
      (n5)-[r35:authored|:contains|:contributed_to]-(n20),
      (n6)-[r36:authored|:contains|:contributed_to]-(n8),
      (n6)-[r37:authored|:contains|:contributed_to]-(n9),
      (n6)-[r38:authored|:contains|:contributed_to]-(n10),
      (n6)-[r39:authored|:contains|:contributed_to]-(n11),
      (n6)-[r40:authored|:contains|:contributed_to]-(n12),
      (n6)-[r41:authored|:contains|:contributed_to]-(n13),
      (n6)-[r42:authored|:contains|:contributed_to]-(n14),
      (n6)-[r43:authored|:contains|:contributed_to]-(n15),
      (n7)-[r44:authored|:contains|:contributed_to]-(n9),
      (n7)-[r45:authored|:contains|:contributed_to]-(n22),
      (n7)-[r46:authored|:contains|:contributed_to]-(n23),
      (n8)-[r47:authored|:contains|:contributed_to]-(n9),
      (n8)-[r48:authored|:contains|:contributed_to]-(n10),
      (n8)-[r49:authored|:contains|:contributed_to]-(n11),
      (n8)-[r50:authored|:contains|:contributed_to]-(n12),
      (n8)-[r51:authored|:contains|:contributed_to]-(n13),
      (n8)-[r52:authored|:contains|:contributed_to]-(n14),
      (n8)-[r53:authored|:contains|:contributed_to]-(n15),
      (n9)-[r54:authored|:contains|:contributed_to]-(n10),
      (n9)-[r55:authored|:contains|:contributed_to]-(n11),
      (n9)-[r56:authored|:contains|:contributed_to]-(n12),
      (n9)-[r57:authored|:contains|:contributed_to]-(n13),
      (n9)-[r58:authored|:contains|:contributed_to]-(n14),
      (n9)-[r59:authored|:contains|:contributed_to]-(n15),
      (n9)-[r60:authored|:contains|:contributed_to]-(n23),
      (n10)-[r61:authored|:contains|:contributed_to]-(n11),
      (n10)-[r62:authored|:contains|:contributed_to]-(n12),
      (n10)-[r63:authored|:contains|:contributed_to]-(n13),
      (n10)-[r64:authored|:contains|:contributed_to]-(n14),
      (n10)-[r65:authored|:contains|:contributed_to]-(n15),
      (n11)-[r66:authored|:contains|:contributed_to]-(n12),
      (n11)-[r67:authored|:contains|:contributed_to]-(n13),
      (n11)-[r68:authored|:contains|:contributed_to]-(n14),
      (n11)-[r69:authored|:contains|:contributed_to]-(n15),
      (n12)-[r70:authored|:contains|:contributed_to]-(n13),
      (n12)-[r71:authored|:contains|:contributed_to]-(n14),
      (n12)-[r72:authored|:contains|:contributed_to]-(n15),
      (n13)-[r73:authored|:contains|:contributed_to]-(n14),
      (n13)-[r74:authored|:contains|:contributed_to]-(n15),
      (n14)-[r75:authored|:contains|:contributed_to]-(n15),
      (n16)-[r76:authored|:contains|:contributed_to]-(n17),
      (n16)-[r77:authored|:contains|:contributed_to]-(n18),
      (n16)-[r78:authored|:contains|:contributed_to]-(n19),
      (n17)-[r79:authored|:contains|:contributed_to]-(n18),
      (n17)-[r80:authored|:contains|:contributed_to]-(n19),
      (n17)-[r81:authored|:contains|:contributed_to]-(n20),
      (n18)-[r82:authored|:contains|:contributed_to]-(n21)
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
  AND id(n0) <> id(n16)
  AND id(n0) <> id(n17)
  AND id(n0) <> id(n18)
  AND id(n0) <> id(n19)
  AND id(n0) <> id(n20)
  AND id(n0) <> id(n21)
  AND id(n0) <> id(n22)
  AND id(n0) <> id(n23)
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
  AND id(n1) <> id(n16)
  AND id(n1) <> id(n17)
  AND id(n1) <> id(n18)
  AND id(n1) <> id(n19)
  AND id(n1) <> id(n20)
  AND id(n1) <> id(n21)
  AND id(n1) <> id(n22)
  AND id(n1) <> id(n23)
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
  AND id(n2) <> id(n16)
  AND id(n2) <> id(n17)
  AND id(n2) <> id(n18)
  AND id(n2) <> id(n19)
  AND id(n2) <> id(n20)
  AND id(n2) <> id(n21)
  AND id(n2) <> id(n22)
  AND id(n2) <> id(n23)
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
  AND id(n3) <> id(n16)
  AND id(n3) <> id(n17)
  AND id(n3) <> id(n18)
  AND id(n3) <> id(n19)
  AND id(n3) <> id(n20)
  AND id(n3) <> id(n21)
  AND id(n3) <> id(n22)
  AND id(n3) <> id(n23)
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
  AND id(n4) <> id(n16)
  AND id(n4) <> id(n17)
  AND id(n4) <> id(n18)
  AND id(n4) <> id(n19)
  AND id(n4) <> id(n20)
  AND id(n4) <> id(n21)
  AND id(n4) <> id(n22)
  AND id(n4) <> id(n23)
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
  AND id(n5) <> id(n16)
  AND id(n5) <> id(n17)
  AND id(n5) <> id(n18)
  AND id(n5) <> id(n19)
  AND id(n5) <> id(n20)
  AND id(n5) <> id(n21)
  AND id(n5) <> id(n22)
  AND id(n5) <> id(n23)
  AND id(n6) <> id(n7)
  AND id(n6) <> id(n8)
  AND id(n6) <> id(n9)
  AND id(n6) <> id(n10)
  AND id(n6) <> id(n11)
  AND id(n6) <> id(n12)
  AND id(n6) <> id(n13)
  AND id(n6) <> id(n14)
  AND id(n6) <> id(n15)
  AND id(n6) <> id(n16)
  AND id(n6) <> id(n17)
  AND id(n6) <> id(n18)
  AND id(n6) <> id(n19)
  AND id(n6) <> id(n20)
  AND id(n6) <> id(n21)
  AND id(n6) <> id(n22)
  AND id(n6) <> id(n23)
  AND id(n7) <> id(n8)
  AND id(n7) <> id(n9)
  AND id(n7) <> id(n10)
  AND id(n7) <> id(n11)
  AND id(n7) <> id(n12)
  AND id(n7) <> id(n13)
  AND id(n7) <> id(n14)
  AND id(n7) <> id(n15)
  AND id(n7) <> id(n16)
  AND id(n7) <> id(n17)
  AND id(n7) <> id(n18)
  AND id(n7) <> id(n19)
  AND id(n7) <> id(n20)
  AND id(n7) <> id(n21)
  AND id(n7) <> id(n22)
  AND id(n7) <> id(n23)
  AND id(n8) <> id(n9)
  AND id(n8) <> id(n10)
  AND id(n8) <> id(n11)
  AND id(n8) <> id(n12)
  AND id(n8) <> id(n13)
  AND id(n8) <> id(n14)
  AND id(n8) <> id(n15)
  AND id(n8) <> id(n16)
  AND id(n8) <> id(n17)
  AND id(n8) <> id(n18)
  AND id(n8) <> id(n19)
  AND id(n8) <> id(n20)
  AND id(n8) <> id(n21)
  AND id(n8) <> id(n22)
  AND id(n8) <> id(n23)
  AND id(n9) <> id(n10)
  AND id(n9) <> id(n11)
  AND id(n9) <> id(n12)
  AND id(n9) <> id(n13)
  AND id(n9) <> id(n14)
  AND id(n9) <> id(n15)
  AND id(n9) <> id(n16)
  AND id(n9) <> id(n17)
  AND id(n9) <> id(n18)
  AND id(n9) <> id(n19)
  AND id(n9) <> id(n20)
  AND id(n9) <> id(n21)
  AND id(n9) <> id(n22)
  AND id(n9) <> id(n23)
  AND id(n10) <> id(n11)
  AND id(n10) <> id(n12)
  AND id(n10) <> id(n13)
  AND id(n10) <> id(n14)
  AND id(n10) <> id(n15)
  AND id(n10) <> id(n16)
  AND id(n10) <> id(n17)
  AND id(n10) <> id(n18)
  AND id(n10) <> id(n19)
  AND id(n10) <> id(n20)
  AND id(n10) <> id(n21)
  AND id(n10) <> id(n22)
  AND id(n10) <> id(n23)
  AND id(n11) <> id(n12)
  AND id(n11) <> id(n13)
  AND id(n11) <> id(n14)
  AND id(n11) <> id(n15)
  AND id(n11) <> id(n16)
  AND id(n11) <> id(n17)
  AND id(n11) <> id(n18)
  AND id(n11) <> id(n19)
  AND id(n11) <> id(n20)
  AND id(n11) <> id(n21)
  AND id(n11) <> id(n22)
  AND id(n11) <> id(n23)
  AND id(n12) <> id(n13)
  AND id(n12) <> id(n14)
  AND id(n12) <> id(n15)
  AND id(n12) <> id(n16)
  AND id(n12) <> id(n17)
  AND id(n12) <> id(n18)
  AND id(n12) <> id(n19)
  AND id(n12) <> id(n20)
  AND id(n12) <> id(n21)
  AND id(n12) <> id(n22)
  AND id(n12) <> id(n23)
  AND id(n13) <> id(n14)
  AND id(n13) <> id(n15)
  AND id(n13) <> id(n16)
  AND id(n13) <> id(n17)
  AND id(n13) <> id(n18)
  AND id(n13) <> id(n19)
  AND id(n13) <> id(n20)
  AND id(n13) <> id(n21)
  AND id(n13) <> id(n22)
  AND id(n13) <> id(n23)
  AND id(n14) <> id(n15)
  AND id(n14) <> id(n16)
  AND id(n14) <> id(n17)
  AND id(n14) <> id(n18)
  AND id(n14) <> id(n19)
  AND id(n14) <> id(n20)
  AND id(n14) <> id(n21)
  AND id(n14) <> id(n22)
  AND id(n14) <> id(n23)
  AND id(n15) <> id(n16)
  AND id(n15) <> id(n17)
  AND id(n15) <> id(n18)
  AND id(n15) <> id(n19)
  AND id(n15) <> id(n20)
  AND id(n15) <> id(n21)
  AND id(n15) <> id(n22)
  AND id(n15) <> id(n23)
  AND id(n16) <> id(n17)
  AND id(n16) <> id(n18)
  AND id(n16) <> id(n19)
  AND id(n16) <> id(n20)
  AND id(n16) <> id(n21)
  AND id(n16) <> id(n22)
  AND id(n16) <> id(n23)
  AND id(n17) <> id(n18)
  AND id(n17) <> id(n19)
  AND id(n17) <> id(n20)
  AND id(n17) <> id(n21)
  AND id(n17) <> id(n22)
  AND id(n17) <> id(n23)
  AND id(n18) <> id(n19)
  AND id(n18) <> id(n20)
  AND id(n18) <> id(n21)
  AND id(n18) <> id(n22)
  AND id(n18) <> id(n23)
  AND id(n19) <> id(n20)
  AND id(n19) <> id(n21)
  AND id(n19) <> id(n22)
  AND id(n19) <> id(n23)
  AND id(n20) <> id(n21)
  AND id(n20) <> id(n22)
  AND id(n20) <> id(n23)
  AND id(n21) <> id(n22)
  AND id(n21) <> id(n23)
  AND id(n22) <> id(n23)
RETURN count(*) AS count;
