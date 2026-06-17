// source: query_dense_24_53.graph
// vertices: 24, edges: 72
MATCH (n0)-[r0:authored|contains|contributed_to]-(n1),
      (n0)-[r1:authored|contains|contributed_to]-(n2),
      (n0)-[r2:authored|contains|contributed_to]-(n3),
      (n0)-[r3:authored|contains|contributed_to]-(n4),
      (n0)-[r4:authored|contains|contributed_to]-(n5),
      (n0)-[r5:authored|contains|contributed_to]-(n6),
      (n0)-[r6:authored|contains|contributed_to]-(n7),
      (n1)-[r7:authored|contains|contributed_to]-(n2),
      (n1)-[r8:authored|contains|contributed_to]-(n9),
      (n2)-[r9:authored|contains|contributed_to]-(n3),
      (n2)-[r10:authored|contains|contributed_to]-(n4),
      (n2)-[r11:authored|contains|contributed_to]-(n5),
      (n2)-[r12:authored|contains|contributed_to]-(n6),
      (n2)-[r13:authored|contains|contributed_to]-(n7),
      (n3)-[r14:authored|contains|contributed_to]-(n4),
      (n3)-[r15:authored|contains|contributed_to]-(n5),
      (n3)-[r16:authored|contains|contributed_to]-(n6),
      (n3)-[r17:authored|contains|contributed_to]-(n7),
      (n4)-[r18:authored|contains|contributed_to]-(n5),
      (n4)-[r19:authored|contains|contributed_to]-(n6),
      (n4)-[r20:authored|contains|contributed_to]-(n7),
      (n5)-[r21:authored|contains|contributed_to]-(n6),
      (n5)-[r22:authored|contains|contributed_to]-(n7),
      (n6)-[r23:authored|contains|contributed_to]-(n7),
      (n8)-[r24:authored|contains|contributed_to]-(n9),
      (n8)-[r25:authored|contains|contributed_to]-(n10),
      (n8)-[r26:authored|contains|contributed_to]-(n11),
      (n8)-[r27:authored|contains|contributed_to]-(n12),
      (n9)-[r28:authored|contains|contributed_to]-(n10),
      (n10)-[r29:authored|contains|contributed_to]-(n11),
      (n10)-[r30:authored|contains|contributed_to]-(n12),
      (n11)-[r31:authored|contains|contributed_to]-(n12),
      (n11)-[r32:authored|contains|contributed_to]-(n13),
      (n11)-[r33:authored|contains|contributed_to]-(n14),
      (n13)-[r34:authored|contains|contributed_to]-(n14),
      (n14)-[r35:authored|contains|contributed_to]-(n15),
      (n15)-[r36:authored|contains|contributed_to]-(n16),
      (n15)-[r37:authored|contains|contributed_to]-(n17),
      (n15)-[r38:authored|contains|contributed_to]-(n18),
      (n15)-[r39:authored|contains|contributed_to]-(n19),
      (n15)-[r40:authored|contains|contributed_to]-(n20),
      (n15)-[r41:authored|contains|contributed_to]-(n21),
      (n15)-[r42:authored|contains|contributed_to]-(n22),
      (n15)-[r43:authored|contains|contributed_to]-(n23),
      (n16)-[r44:authored|contains|contributed_to]-(n17),
      (n16)-[r45:authored|contains|contributed_to]-(n18),
      (n16)-[r46:authored|contains|contributed_to]-(n19),
      (n16)-[r47:authored|contains|contributed_to]-(n20),
      (n16)-[r48:authored|contains|contributed_to]-(n21),
      (n16)-[r49:authored|contains|contributed_to]-(n22),
      (n16)-[r50:authored|contains|contributed_to]-(n23),
      (n17)-[r51:authored|contains|contributed_to]-(n18),
      (n17)-[r52:authored|contains|contributed_to]-(n19),
      (n17)-[r53:authored|contains|contributed_to]-(n20),
      (n17)-[r54:authored|contains|contributed_to]-(n21),
      (n17)-[r55:authored|contains|contributed_to]-(n22),
      (n17)-[r56:authored|contains|contributed_to]-(n23),
      (n18)-[r57:authored|contains|contributed_to]-(n19),
      (n18)-[r58:authored|contains|contributed_to]-(n20),
      (n18)-[r59:authored|contains|contributed_to]-(n21),
      (n18)-[r60:authored|contains|contributed_to]-(n22),
      (n18)-[r61:authored|contains|contributed_to]-(n23),
      (n19)-[r62:authored|contains|contributed_to]-(n20),
      (n19)-[r63:authored|contains|contributed_to]-(n21),
      (n19)-[r64:authored|contains|contributed_to]-(n22),
      (n19)-[r65:authored|contains|contributed_to]-(n23),
      (n20)-[r66:authored|contains|contributed_to]-(n21),
      (n20)-[r67:authored|contains|contributed_to]-(n22),
      (n20)-[r68:authored|contains|contributed_to]-(n23),
      (n21)-[r69:authored|contains|contributed_to]-(n22),
      (n21)-[r70:authored|contains|contributed_to]-(n23),
      (n22)-[r71:authored|contains|contributed_to]-(n23)
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
