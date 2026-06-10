// q1; freq=4; rpq=<12>|(<12>/(<196>)*); readable=<P12>|(<P12>/(<P196>)*)
MATCH p139_0 = (s)-[:P12]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P12]->(m139_1_0)
MATCH (m139_1_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q2; freq=3; rpq=(<12>)*|(<196>)*; readable=(<P12>)*|(<P196>)*
MATCH p15_0 = (s)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p15_1 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q3; freq=3; rpq=(<12>/(<12>)*)|(<196>/(<196>)*); readable=(<P12>/(<P12>)*)|(<P196>/(<P196>)*)
MATCH (s)-[:P12]->(m234_0_0)
MATCH (m234_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P196]->(m234_1_0)
MATCH (m234_1_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q4; freq=2; rpq=(<12>/(<196>)*)|<12>; readable=(<P12>/(<P196>)*)|<P12>
MATCH (s)-[:P12]->(m116_0_0)
MATCH (m116_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p116_1 = (s)-[:P12]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q5; freq=2; rpq=(<196>)+|(<12>)+; readable=(<P196>)+|(<P12>)+
MATCH p233_0 = (s)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p233_1 = (s)-[:P12*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q6; freq=2; rpq=<12>|(<196>)*; readable=<P12>|(<P196>)*
MATCH p55_0 = (s)-[:P12]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p55_1 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q7; freq=1; rpq=((<176>)*|(<586>)*)|(<412>)*; readable=((<P176>)*|(<P586>)*)|(<P412>)*
MATCH p44_0 = (s)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p44_1 = (s)-[:P586*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p44_2 = (s)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q8; freq=1; rpq=((<176>)*|<412>)|<586>; readable=((<P176>)*|<P412>)|<P586>
MATCH p45_0 = (s)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p45_1 = (s)-[:P412]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p45_2 = (s)-[:P586]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q9; freq=1; rpq=((<176>|<196>))+|<12>; readable=((<P176>|<P196>))+|<P12>
MATCH p153_0 = (s)-[:P176|P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p153_1 = (s)-[:P12]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q10; freq=1; rpq=((<204>)*/(<203>)*)|(<303->)*; readable=((<P204>)*/(<P203>)*)|(<P303^-1>)*
MATCH (s)-[:P204*0..]->(m104_0_0)
MATCH (m104_0_0)-[:P203*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p104_1 = (s)<-[:P303*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q11; freq=1; rpq=((<412>)+|(<176>)+)|(<196>)+; readable=((<P412>)+|(<P176>)+)|(<P196>)+
MATCH p237_0 = (s)-[:P412*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p237_1 = (s)-[:P176*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p237_2 = (s)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q12; freq=1; rpq=((<412>/(<196>)*)|(<586>/(<196>)*))|(<176>/(<196>)*); readable=((<P412>/(<P196>)*)|(<P586>/(<P196>)*))|(<P176>/(<P196>)*)
MATCH (s)-[:P412]->(m109_0_0)
MATCH (m109_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P586]->(m109_1_0)
MATCH (m109_1_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P176]->(m109_2_0)
MATCH (m109_2_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q13; freq=1; rpq=(<12->)*|(<196->)*; readable=(<P12^-1>)*|(<P196^-1>)*
MATCH p18_0 = (s)<-[:P12*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p18_1 = (s)<-[:P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q14; freq=1; rpq=(<12>)*|(<196->)*; readable=(<P12>)*|(<P196^-1>)*
MATCH p17_0 = (s)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p17_1 = (s)<-[:P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q15; freq=1; rpq=(<12>)?|(<196>)*; readable=(<P12>)?|(<P196>)*
MATCH p100_0 = (s)-[:P12*0..1]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p100_1 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q16; freq=1; rpq=(<12>/(<196>)*)|(<196>)*; readable=(<P12>/(<P196>)*)|(<P196>)*
MATCH (s)-[:P12]->(m94_0_0)
MATCH (m94_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p94_1 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q17; freq=1; rpq=(<12>/(<196>)*)|(<206>/(<196>)*); readable=(<P12>/(<P196>)*)|(<P206>/(<P196>)*)
MATCH (s)-[:P12]->(m83_0_0)
MATCH (m83_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P206]->(m83_1_0)
MATCH (m83_1_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q18; freq=1; rpq=(<12>/(<196>)*)|<206>; readable=(<P12>/(<P196>)*)|<P206>
MATCH (s)-[:P12]->(m89_0_0)
MATCH (m89_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p89_1 = (s)-[:P206]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q19; freq=1; rpq=(<176>/(<176>)*)|(<664>)*; readable=(<P176>/(<P176>)*)|(<P664>)*
MATCH (s)-[:P176]->(m129_0_0)
MATCH (m129_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p129_1 = (s)-[:P664*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q20; freq=1; rpq=(<196>)*|(<176>)*; readable=(<P196>)*|(<P176>)*
MATCH p185_0 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p185_1 = (s)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q21; freq=1; rpq=(<196>)+|(<12>/(<196>)*); readable=(<P196>)+|(<P12>/(<P196>)*)
MATCH p56_0 = (s)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P12]->(m56_1_0)
MATCH (m56_1_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q22; freq=1; rpq=(<304>|<43>)|(<1196>/(<176>)*); readable=(<P304>|<P43>)|(<P1196>/(<P176>)*)
MATCH p148_0 = (s)-[:P304]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p148_1 = (s)-[:P43]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P1196]->(m148_2_0)
MATCH (m148_2_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q23; freq=1; rpq=(<412>)+|<586>; readable=(<P412>)+|<P586>
MATCH p47_0 = (s)-[:P412*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p47_1 = (s)-[:P586]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q24; freq=1; rpq=<159>|(<412>)*; readable=<P159>|(<P412>)*
MATCH p163_0 = (s)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH p163_1 = (s)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q25; freq=1; rpq=<304>|(<1196>/(<176>)*); readable=<P304>|(<P1196>/(<P176>)*)
MATCH p97_0 = (s)-[:P304]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst
UNION
MATCH (s)-[:P1196]->(m97_1_0)
MATCH (m97_1_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

