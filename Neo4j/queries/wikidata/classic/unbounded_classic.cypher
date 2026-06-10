// q1; freq=438; rpq=<12>/(<196>)*; readable=<P12>/(<P196>)*
MATCH (s)-[:P12]->(m2_0_0)
MATCH (m2_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q2; freq=207; rpq=(<412>)*; readable=(<P412>)*
MATCH p4_0 = (s)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q3; freq=191; rpq=(<196>)*; readable=(<P196>)*
MATCH p3_0 = (s)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q4; freq=83; rpq=<412>/(<412>)*; readable=<P412>/(<P412>)*
MATCH (s)-[:P412]->(m1_0_0)
MATCH (m1_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q5; freq=51; rpq=(<196>)+; readable=(<P196>)+
MATCH p12_0 = (s)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q6; freq=45; rpq=(<12>)*; readable=(<P12>)*
MATCH p23_0 = (s)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q7; freq=33; rpq=(<412>)+; readable=(<P412>)+
MATCH p7_0 = (s)-[:P412*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q8; freq=30; rpq=(<444>)*; readable=(<P444>)*
MATCH p41_0 = (s)-[:P444*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q9; freq=30; rpq=<206>/(<196>)*; readable=<P206>/(<P196>)*
MATCH (s)-[:P206]->(m19_0_0)
MATCH (m19_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q10; freq=28; rpq=((((<212>)*/(<353>)*)/(<206>)*)/(<196>)*)/(<12>)*; readable=((((<P212>)*/(<P353>)*)/(<P206>)*)/(<P196>)*)/(<P12>)*
MATCH (s)-[:P212*0..]->(m219_0_0)
MATCH (m219_0_0)-[:P353*0..]->(m219_0_1)
MATCH (m219_0_1)-[:P206*0..]->(m219_0_2)
MATCH (m219_0_2)-[:P196*0..]->(m219_0_3)
MATCH (m219_0_3)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q11; freq=24; rpq=(<12>)*/(<196>)*; readable=(<P12>)*/(<P196>)*
MATCH (s)-[:P12*0..]->(m14_0_0)
MATCH (m14_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q12; freq=23; rpq=(<196>|<412>)*; readable=(<P196>|<P412>)*
MATCH p54_0 = (s)-[:P196|P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q13; freq=13; rpq=<196>/(<196>)*; readable=<P196>/(<P196>)*
MATCH (s)-[:P196]->(m42_0_0)
MATCH (m42_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q14; freq=12; rpq=(<803>)*; readable=(<P803>)*
MATCH p140_0 = (s)-[:P803*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q15; freq=11; rpq=(<444>)+; readable=(<P444>)+
MATCH p38_0 = (s)-[:P444*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q16; freq=10; rpq=<12>/(<196>)+; readable=<P12>/(<P196>)+
MATCH (s)-[:P12]->(m77_0_0)
MATCH (m77_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q17; freq=10; rpq=<289>/(<412>)*; readable=<P289>/(<P412>)*
MATCH (s)-[:P289]->(m20_0_0)
MATCH (m20_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q18; freq=9; rpq=(<12>)?/(<196>)*; readable=(<P12>)?/(<P196>)*
MATCH (s)-[:P12*0..1]->(m10_0_0)
MATCH (m10_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q19; freq=9; rpq=(<176>)*; readable=(<P176>)*
MATCH p27_0 = (s)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q20; freq=8; rpq=(<1135>)*; readable=(<P1135>)*
MATCH p84_0 = (s)-[:P1135*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q21; freq=8; rpq=(<12>)+; readable=(<P12>)+
MATCH p13_0 = (s)-[:P12*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q22; freq=7; rpq=(<12>|<196>)*; readable=(<P12>|<P196>)*
MATCH p40_0 = (s)-[:P12|P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q23; freq=7; rpq=(<204>|<203>)*; readable=(<P204>|<P203>)*
MATCH p106_0 = (s)-[:P203|P204*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q24; freq=7; rpq=(<412>)*/(<399>)*; readable=(<P412>)*/(<P399>)*
MATCH (s)-[:P412*0..]->(m57_0_0)
MATCH (m57_0_0)-[:P399*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q25; freq=6; rpq=(<196>)*/(<12>)*; readable=(<P196>)*/(<P12>)*
MATCH (s)-[:P196*0..]->(m127_0_0)
MATCH (m127_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q26; freq=6; rpq=<170>/(<12>)*; readable=<P170>/(<P12>)*
MATCH (s)-[:P170]->(m178_0_0)
MATCH (m178_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q27; freq=6; rpq=<811>/(<196>)*; readable=<P811>/(<P196>)*
MATCH (s)-[:P811]->(m80_0_0)
MATCH (m80_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q28; freq=5; rpq=(<12>)*/(<444>)*; readable=(<P12>)*/(<P444>)*
MATCH (s)-[:P12*0..]->(m161_0_0)
MATCH (m161_0_0)-[:P444*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q29; freq=5; rpq=(<303>)*; readable=(<P303>)*
MATCH p113_0 = (s)-[:P303*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q30; freq=5; rpq=(<303>)+; readable=(<P303>)+
MATCH p50_0 = (s)-[:P303*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q31; freq=5; rpq=(<412>)*/<159>; readable=(<P412>)*/<P159>
MATCH (s)-[:P412*0..]->(m25_0_0)
MATCH (m25_0_0)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q32; freq=5; rpq=<212>/(<196>)*; readable=<P212>/(<P196>)*
MATCH (s)-[:P212]->(m102_0_0)
MATCH (m102_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q33; freq=5; rpq=<303>/(<303>)*; readable=<P303>/(<P303>)*
MATCH (s)-[:P303]->(m242_0_0)
MATCH (m242_0_0)-[:P303*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q34; freq=4; rpq=(((<176->|<664->)|<3908->))+; readable=(((<P176^-1>|<P664^-1>)|<P3908^-1>))+
MATCH p166_0 = (s)<-[:P176|P664|P3908*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q35; freq=4; rpq=((<206>|<212>)|<12>)/(<196>)*; readable=((<P206>|<P212>)|<P12>)/(<P196>)*
MATCH (s)-[:P12|P206|P212]->(m22_0_0)
MATCH (m22_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q36; freq=4; rpq=(<12->)?/(<196->)*; readable=(<P12^-1>)?/(<P196^-1>)*
MATCH (s)<-[:P12*0..1]-(m189_0_0)
MATCH (m189_0_0)<-[:P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q37; freq=4; rpq=(<12>|<196>)+; readable=(<P12>|<P196>)+
MATCH p24_0 = (s)-[:P12|P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q38; freq=4; rpq=(<159>)*; readable=(<P159>)*
MATCH p29_0 = (s)-[:P159*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q39; freq=4; rpq=(<196->)*/<12->; readable=(<P196^-1>)*/<P12^-1>
MATCH (s)<-[:P196*0..]-(m137_0_0)
MATCH (m137_0_0)<-[:P12]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q40; freq=4; rpq=(<206>)*; readable=(<P206>)*
MATCH p68_0 = (s)-[:P206*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q41; freq=4; rpq=<338>/(<196>)*; readable=<P338>/(<P196>)*
MATCH (s)-[:P338]->(m114_0_0)
MATCH (m114_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q42; freq=3; rpq=(<1135>)+; readable=(<P1135>)+
MATCH p215_0 = (s)-[:P1135*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q43; freq=3; rpq=(<159>)+; readable=(<P159>)+
MATCH p34_0 = (s)-[:P159*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q44; freq=3; rpq=(<176>)+; readable=(<P176>)+
MATCH p33_0 = (s)-[:P176*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q45; freq=3; rpq=(<212>)*; readable=(<P212>)*
MATCH p30_0 = (s)-[:P212*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q46; freq=3; rpq=(<303->)*; readable=(<P303^-1>)*
MATCH p105_0 = (s)<-[:P303*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q47; freq=3; rpq=(<439>)*; readable=(<P439>)*
MATCH p59_0 = (s)-[:P439*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q48; freq=3; rpq=<210>/(<196>)*; readable=<P210>/(<P196>)*
MATCH (s)-[:P210]->(m66_0_0)
MATCH (m66_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q49; freq=2; rpq=((<12>|<206>)|<338>)/(<196>)*; readable=((<P12>|<P206>)|<P338>)/(<P196>)*
MATCH (s)-[:P12|P206|P338]->(m134_0_0)
MATCH (m134_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q50; freq=2; rpq=((<176->|<664->))+; readable=((<P176^-1>|<P664^-1>))+
MATCH p132_0 = (s)<-[:P176|P664*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q51; freq=2; rpq=((<203->|<204->))+; readable=((<P203^-1>|<P204^-1>))+
MATCH p202_0 = (s)<-[:P203|P204*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q52; freq=2; rpq=((<204->|<203->))+; readable=((<P204^-1>|<P203^-1>))+
MATCH p198_0 = (s)<-[:P203|P204*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q53; freq=2; rpq=((<206>)*/(<353>)*)/(<212>)*; readable=((<P206>)*/(<P353>)*)/(<P212>)*
MATCH (s)-[:P206*0..]->(m220_0_0)
MATCH (m220_0_0)-[:P353*0..]->(m220_0_1)
MATCH (m220_0_1)-[:P212*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q54; freq=2; rpq=(<12>)+/(<196>)+; readable=(<P12>)+/(<P196>)+
MATCH (s)-[:P12*1..]->(m69_0_0)
MATCH (m69_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q55; freq=2; rpq=(<12>)?/(<196>)+; readable=(<P12>)?/(<P196>)+
MATCH (s)-[:P12*0..1]->(m160_0_0)
MATCH (m160_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q56; freq=2; rpq=(<12>/<12>)/(<12>)+; readable=(<P12>/<P12>)/(<P12>)+
MATCH (s)-[:P12]->(m194_0_0)
MATCH (m194_0_0)-[:P12]->(m194_0_1)
MATCH (m194_0_1)-[:P12*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q57; freq=2; rpq=(<12>/<196>)/(<196>)+; readable=(<P12>/<P196>)/(<P196>)+
MATCH (s)-[:P12]->(m78_0_0)
MATCH (m78_0_0)-[:P196]->(m78_0_1)
MATCH (m78_0_1)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q58; freq=2; rpq=(<159>|<412>)*; readable=(<P159>|<P412>)*
MATCH p6_0 = (s)-[:P159|P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q59; freq=2; rpq=(<196>|<12>)*; readable=(<P196>|<P12>)*
MATCH p9_0 = (s)-[:P12|P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q60; freq=2; rpq=(<204>)*/(<203>)*; readable=(<P204>)*/(<P203>)*
MATCH (s)-[:P204*0..]->(m103_0_0)
MATCH (m103_0_0)-[:P203*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q61; freq=2; rpq=(<205>)*; readable=(<P205>)*
MATCH p169_0 = (s)-[:P205*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q62; freq=2; rpq=(<31>)*; readable=(<P31>)*
MATCH p5_0 = (s)-[:P31*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q63; freq=2; rpq=(<338>)*; readable=(<P338>)*
MATCH p39_0 = (s)-[:P338*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q64; freq=2; rpq=(<4377>)*; readable=(<P4377>)*
MATCH p147_0 = (s)-[:P4377*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q65; freq=2; rpq=(<527>)+; readable=(<P527>)+
MATCH p195_0 = (s)-[:P527*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q66; freq=2; rpq=(<811>)*; readable=(<P811>)*
MATCH p223_0 = (s)-[:P811*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q67; freq=2; rpq=<1196>/(<176>)*; readable=<P1196>/(<P176>)*
MATCH (s)-[:P1196]->(m186_0_0)
MATCH (m186_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q68; freq=2; rpq=<12>/(<12>)*; readable=<P12>/(<P12>)*
MATCH (s)-[:P12]->(m99_0_0)
MATCH (m99_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q69; freq=2; rpq=<12>/(<4377>)*; readable=<P12>/(<P4377>)*
MATCH (s)-[:P12]->(m64_0_0)
MATCH (m64_0_0)-[:P4377*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q70; freq=2; rpq=<1342>/(<196>)*; readable=<P1342>/(<P196>)*
MATCH (s)-[:P1342]->(m143_0_0)
MATCH (m143_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q71; freq=2; rpq=<1473>/(<176>)*; readable=<P1473>/(<P176>)*
MATCH (s)-[:P1473]->(m98_0_0)
MATCH (m98_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q72; freq=2; rpq=<205>/(<196>)*; readable=<P205>/(<P196>)*
MATCH (s)-[:P205]->(m141_0_0)
MATCH (m141_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q73; freq=2; rpq=<586>/(<412>)*; readable=<P586>/(<P412>)*
MATCH (s)-[:P586]->(m176_0_0)
MATCH (m176_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q74; freq=2; rpq=<809>/(<176>)*; readable=<P809>/(<P176>)*
MATCH (s)-[:P809]->(m238_0_0)
MATCH (m238_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q75; freq=1; rpq=((((<176->|<159->)|<13->)|<3908->))+; readable=((((<P176^-1>|<P159^-1>)|<P13^-1>)|<P3908^-1>))+
MATCH p172_0 = (s)<-[:P13|P159|P176|P3908*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q76; freq=1; rpq=((((<176->|<664->)|<3908->)|<159->))+; readable=((((<P176^-1>|<P664^-1>)|<P3908^-1>)|<P159^-1>))+
MATCH p177_0 = (s)<-[:P159|P176|P664|P3908*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q77; freq=1; rpq=(((<1281>)*/(<196>)*)/(<1449>)*)/(<176>)*; readable=(((<P1281>)*/(<P196>)*)/(<P1449>)*)/(<P176>)*
MATCH (s)-[:P1281*0..]->(m92_0_0)
MATCH (m92_0_0)-[:P196*0..]->(m92_0_1)
MATCH (m92_0_1)-[:P1449*0..]->(m92_0_2)
MATCH (m92_0_2)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q78; freq=1; rpq=(((<412>)*/(<159>)?)/(<13>)?)/(<176>)?; readable=(((<P412>)*/(<P159>)?)/(<P13>)?)/(<P176>)?
MATCH (s)-[:P412*0..]->(m37_0_0)
MATCH (m37_0_0)-[:P159*0..1]->(m37_0_1)
MATCH (m37_0_1)-[:P13*0..1]->(m37_0_2)
MATCH (m37_0_2)-[:P176*0..1]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q79; freq=1; rpq=((<12->|<1370->))+; readable=((<P12^-1>|<P1370^-1>))+
MATCH p227_0 = (s)<-[:P12|P1370*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q80; freq=1; rpq=((<1281>)*/(<1449>)*)/(<176>)*; readable=((<P1281>)*/(<P1449>)*)/(<P176>)*
MATCH (s)-[:P1281*0..]->(m90_0_0)
MATCH (m90_0_0)-[:P1449*0..]->(m90_0_1)
MATCH (m90_0_1)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q81; freq=1; rpq=((<1281>)*/(<196>)*)/(<1449>)*; readable=((<P1281>)*/(<P196>)*)/(<P1449>)*
MATCH (s)-[:P1281*0..]->(m93_0_0)
MATCH (m93_0_0)-[:P196*0..]->(m93_0_1)
MATCH (m93_0_1)-[:P1449*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q82; freq=1; rpq=((<196->)*/(<12->)?)/<159>; readable=((<P196^-1>)*/(<P12^-1>)?)/<P159>
MATCH (s)<-[:P196*0..]-(m96_0_0)
MATCH (m96_0_0)<-[:P12*0..1]-(m96_0_1)
MATCH (m96_0_1)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q83; freq=1; rpq=((<196->|<12->))*; readable=((<P196^-1>|<P12^-1>))*
MATCH p171_0 = (s)<-[:P12|P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q84; freq=1; rpq=((<196->|<12->))+; readable=((<P196^-1>|<P12^-1>))+
MATCH p168_0 = (s)<-[:P12|P196*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q85; freq=1; rpq=((<412>)*/(<176>)*)/(<399>)*; readable=((<P412>)*/(<P176>)*)/(<P399>)*
MATCH (s)-[:P412*0..]->(m135_0_0)
MATCH (m135_0_0)-[:P176*0..]->(m135_0_1)
MATCH (m135_0_1)-[:P399*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q86; freq=1; rpq=(<1141>)+; readable=(<P1141>)+
MATCH p21_0 = (s)-[:P1141*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q87; freq=1; rpq=(<1141>/(<412>)*)/<159>; readable=(<P1141>/(<P412>)*)/<P159>
MATCH (s)-[:P1141]->(m128_0_0)
MATCH (m128_0_0)-[:P412*0..]->(m128_0_1)
MATCH (m128_0_1)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q88; freq=1; rpq=(<11>/<12>)/(<196>)*; readable=(<P11>/<P12>)/(<P196>)*
MATCH (s)-[:P11]->(m11_0_0)
MATCH (m11_0_0)-[:P12]->(m11_0_1)
MATCH (m11_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q89; freq=1; rpq=(<12->)*/(<196>)*; readable=(<P12^-1>)*/(<P196>)*
MATCH (s)<-[:P12*0..]-(m187_0_0)
MATCH (m187_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q90; freq=1; rpq=(<12->)+/(<196>)+; readable=(<P12^-1>)+/(<P196>)+
MATCH (s)<-[:P12*1..]-(m188_0_0)
MATCH (m188_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q91; freq=1; rpq=(<12->)?/(<196>)*; readable=(<P12^-1>)?/(<P196>)*
MATCH (s)<-[:P12*0..1]-(m190_0_0)
MATCH (m190_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q92; freq=1; rpq=(<12->)?/(<196>)+; readable=(<P12^-1>)?/(<P196>)+
MATCH (s)<-[:P12*0..1]-(m191_0_0)
MATCH (m191_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q93; freq=1; rpq=(<121>)*; readable=(<P121>)*
MATCH p125_0 = (s)-[:P121*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q94; freq=1; rpq=(<12>)*/(<412>)*; readable=(<P12>)*/(<P412>)*
MATCH (s)-[:P12*0..]->(m32_0_0)
MATCH (m32_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q95; freq=1; rpq=(<12>/<12>)/(<196>)*; readable=(<P12>/<P12>)/(<P196>)*
MATCH (s)-[:P12]->(m236_0_0)
MATCH (m236_0_0)-[:P12]->(m236_0_1)
MATCH (m236_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q96; freq=1; rpq=(<12>/<196>)/(<31>)*; readable=(<P12>/<P196>)/(<P31>)*
MATCH (s)-[:P12]->(m207_0_0)
MATCH (m207_0_0)-[:P196]->(m207_0_1)
MATCH (m207_0_1)-[:P31*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q97; freq=1; rpq=(<12>|<206>)/(<196>)*; readable=(<P12>|<P206>)/(<P196>)*
MATCH (s)-[:P12|P206]->(m235_0_0)
MATCH (m235_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q98; freq=1; rpq=(<1341>)+/(<439>)*; readable=(<P1341>)+/(<P439>)*
MATCH (s)-[:P1341*1..]->(m61_0_0)
MATCH (m61_0_0)-[:P439*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q99; freq=1; rpq=(<13>)*; readable=(<P13>)*
MATCH p65_0 = (s)-[:P13*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q100; freq=1; rpq=(<1420>)*; readable=(<P1420>)*
MATCH p58_0 = (s)-[:P1420*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q101; freq=1; rpq=(<1503>)*; readable=(<P1503>)*
MATCH p126_0 = (s)-[:P1503*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q102; freq=1; rpq=(<159->)+; readable=(<P159^-1>)+
MATCH p173_0 = (s)<-[:P159*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q103; freq=1; rpq=(<1594>)+; readable=(<P1594>)+
MATCH p28_0 = (s)-[:P1594*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q104; freq=1; rpq=(<159>)*/<13>; readable=(<P159>)*/<P13>
MATCH (s)-[:P159*0..]->(m230_0_0)
MATCH (m230_0_0)-[:P13]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q105; freq=1; rpq=(<159>)*/<159>; readable=(<P159>)*/<P159>
MATCH (s)-[:P159*0..]->(m213_0_0)
MATCH (m213_0_0)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q106; freq=1; rpq=(<176->|<664->)+; readable=(<P176^-1>|<P664^-1>)+
MATCH p131_0 = (s)<-[:P176|P664*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q107; freq=1; rpq=(<176>)*/(<412>)*; readable=(<P176>)*/(<P412>)*
MATCH (s)-[:P176*0..]->(m31_0_0)
MATCH (m31_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q108; freq=1; rpq=(<176>)*/<159>; readable=(<P176>)*/<P159>
MATCH (s)-[:P176*0..]->(m133_0_0)
MATCH (m133_0_0)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q109; freq=1; rpq=(<176>|<1189>)*; readable=(<P176>|<P1189>)*
MATCH p53_0 = (s)-[:P176|P1189*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q110; freq=1; rpq=(<176>|<664>)+; readable=(<P176>|<P664>)+
MATCH p130_0 = (s)-[:P176|P664*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q111; freq=1; rpq=(<196->)*; readable=(<P196^-1>)*
MATCH p16_0 = (s)<-[:P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q112; freq=1; rpq=(<196->)*/(<12->)*; readable=(<P196^-1>)*/(<P12^-1>)*
MATCH (s)<-[:P196*0..]-(m175_0_0)
MATCH (m175_0_0)<-[:P12*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q113; freq=1; rpq=(<196>)*/<800>; readable=(<P196>)*/<P800>
MATCH (s)-[:P196*0..]->(m46_0_0)
MATCH (m46_0_0)-[:P800]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q114; freq=1; rpq=(<196>)*/<925>; readable=(<P196>)*/<P925>
MATCH (s)-[:P196*0..]->(m120_0_0)
MATCH (m120_0_0)-[:P925]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q115; freq=1; rpq=(<196>/<12>)/(<196>)*; readable=(<P196>/<P12>)/(<P196>)*
MATCH (s)-[:P196]->(m159_0_0)
MATCH (m159_0_0)-[:P12]->(m159_0_1)
MATCH (m159_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q116; freq=1; rpq=(<196>/<196>)/(<196>)*; readable=(<P196>/<P196>)/(<P196>)*
MATCH (s)-[:P196]->(m208_0_0)
MATCH (m208_0_0)-[:P196]->(m208_0_1)
MATCH (m208_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q117; freq=1; rpq=(<199>)*; readable=(<P199>)*
MATCH p51_0 = (s)-[:P199*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q118; freq=1; rpq=(<203>|<303>)+; readable=(<P203>|<P303>)+
MATCH p158_0 = (s)-[:P203|P303*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q119; freq=1; rpq=(<204>|<203>)+; readable=(<P204>|<P203>)+
MATCH p201_0 = (s)-[:P203|P204*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q120; freq=1; rpq=(<205>/<12>)/(<196>)*; readable=(<P205>/<P12>)/(<P196>)*
MATCH (s)-[:P205]->(m170_0_0)
MATCH (m170_0_0)-[:P12]->(m170_0_1)
MATCH (m170_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q121; freq=1; rpq=(<206>)+; readable=(<P206>)+
MATCH p142_0 = (s)-[:P206*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q122; freq=1; rpq=(<206>/(<196>)*)/(<196>)*; readable=(<P206>/(<P196>)*)/(<P196>)*
MATCH (s)-[:P206]->(m70_0_0)
MATCH (m70_0_0)-[:P196*0..]->(m70_0_1)
MATCH (m70_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q123; freq=1; rpq=(<206>|<196>)*; readable=(<P206>|<P196>)*
MATCH p165_0 = (s)-[:P196|P206*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q124; freq=1; rpq=(<212->/(<196->)*); readable=(<P212^-1>/(<P196^-1>)*)
MATCH (s)<-[:P212]-(m101_0_0)
MATCH (m101_0_0)<-[:P196*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q125; freq=1; rpq=(<212>)*/(<399>)*; readable=(<P212>)*/(<P399>)*
MATCH (s)-[:P212*0..]->(m184_0_0)
MATCH (m184_0_0)-[:P399*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q126; freq=1; rpq=(<241>)*; readable=(<P241>)*
MATCH p204_0 = (s)-[:P241*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q127; freq=1; rpq=(<289>)*; readable=(<P289>)*
MATCH p76_0 = (s)-[:P289*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q128; freq=1; rpq=(<289>/(<412>)*)/<397->; readable=(<P289>/(<P412>)*)/<P397^-1>
MATCH (s)-[:P289]->(m48_0_0)
MATCH (m48_0_0)-[:P412*0..]->(m48_0_1)
MATCH (m48_0_1)<-[:P397]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q129; freq=1; rpq=(<289>/(<586>)?)/(<412>)+; readable=(<P289>/(<P586>)?)/(<P412>)+
MATCH (s)-[:P289]->(m192_0_0)
MATCH (m192_0_0)-[:P586*0..1]->(m192_0_1)
MATCH (m192_0_1)-[:P412*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q130; freq=1; rpq=(<308>/<12>)/(<196>)*; readable=(<P308>/<P12>)/(<P196>)*
MATCH (s)-[:P308]->(m155_0_0)
MATCH (m155_0_0)-[:P12]->(m155_0_1)
MATCH (m155_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q131; freq=1; rpq=(<31>)+; readable=(<P31>)+
MATCH p8_0 = (s)-[:P31*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q132; freq=1; rpq=(<338>/(<12>)?)/(<196>)*; readable=(<P338>/(<P12>)?)/(<P196>)*
MATCH (s)-[:P338]->(m144_0_0)
MATCH (m144_0_0)-[:P12*0..1]->(m144_0_1)
MATCH (m144_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q133; freq=1; rpq=(<338>/<12>)/(<196>)*; readable=(<P338>/<P12>)/(<P196>)*
MATCH (s)-[:P338]->(m72_0_0)
MATCH (m72_0_0)-[:P12]->(m72_0_1)
MATCH (m72_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q134; freq=1; rpq=(<352>)*; readable=(<P352>)*
MATCH p222_0 = (s)-[:P352*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q135; freq=1; rpq=(<361>)*; readable=(<P361>)*
MATCH p146_0 = (s)-[:P361*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q136; freq=1; rpq=(<361>)+/(<439>)*; readable=(<P361>)+/(<P439>)*
MATCH (s)-[:P361*1..]->(m60_0_0)
MATCH (m60_0_0)-[:P439*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q137; freq=1; rpq=(<381>/(<196>)*)/<12>; readable=(<P381>/(<P196>)*)/<P12>
MATCH (s)-[:P381]->(m210_0_0)
MATCH (m210_0_0)-[:P196*0..]->(m210_0_1)
MATCH (m210_0_1)-[:P12]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q138; freq=1; rpq=(<381>/<12>)/(<196>)+; readable=(<P381>/<P12>)/(<P196>)+
MATCH (s)-[:P381]->(m108_0_0)
MATCH (m108_0_0)-[:P12]->(m108_0_1)
MATCH (m108_0_1)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q139; freq=1; rpq=(<397>)*; readable=(<P397>)*
MATCH p26_0 = (s)-[:P397*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q140; freq=1; rpq=(<397>)+; readable=(<P397>)+
MATCH p111_0 = (s)-[:P397*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q141; freq=1; rpq=(<412->)+; readable=(<P412^-1>)+
MATCH p154_0 = (s)<-[:P412*1..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q142; freq=1; rpq=(<412>)*/<397->; readable=(<P412>)*/<P397^-1>
MATCH (s)-[:P412*0..]->(m49_0_0)
MATCH (m49_0_0)<-[:P397]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q143; freq=1; rpq=(<412>)+/(<159>)*; readable=(<P412>)+/(<P159>)*
MATCH (s)-[:P412*1..]->(m212_0_0)
MATCH (m212_0_0)-[:P159*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q144; freq=1; rpq=(<412>)+/(<159>)+; readable=(<P412>)+/(<P159>)+
MATCH (s)-[:P412*1..]->(m211_0_0)
MATCH (m211_0_0)-[:P159*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q145; freq=1; rpq=(<412>/(<196>)*)/<159>; readable=(<P412>/(<P196>)*)/<P159>
MATCH (s)-[:P412]->(m62_0_0)
MATCH (m62_0_0)-[:P196*0..]->(m62_0_1)
MATCH (m62_0_1)-[:P159]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q146; freq=1; rpq=(<4377>)*/<2667>; readable=(<P4377>)*/<P2667>
MATCH (s)-[:P4377*0..]->(m107_0_0)
MATCH (m107_0_0)-[:P2667]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q147; freq=1; rpq=(<443>)*; readable=(<P443>)*
MATCH p164_0 = (s)-[:P443*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q148; freq=1; rpq=(<45>)*; readable=(<P45>)*
MATCH p217_0 = (s)-[:P45*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q149; freq=1; rpq=(<494>)*; readable=(<P494>)*
MATCH p73_0 = (s)-[:P494*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q150; freq=1; rpq=(<530>)*/(<530>)*; readable=(<P530>)*/(<P530>)*
MATCH (s)-[:P530*0..]->(m214_0_0)
MATCH (m214_0_0)-[:P530*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q151; freq=1; rpq=(<537>)*; readable=(<P537>)*
MATCH p124_0 = (s)-[:P537*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q152; freq=1; rpq=(<545>)+; readable=(<P545>)+
MATCH p162_0 = (s)-[:P545*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q153; freq=1; rpq=(<55>/<12>)/(<196>)*; readable=(<P55>/<P12>)/(<P196>)*
MATCH (s)-[:P55]->(m232_0_0)
MATCH (m232_0_0)-[:P12]->(m232_0_1)
MATCH (m232_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q154; freq=1; rpq=(<586>)*/(<159>)*; readable=(<P586>)*/(<P159>)*
MATCH (s)-[:P586*0..]->(m91_0_0)
MATCH (m91_0_0)-[:P159*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q155; freq=1; rpq=(<586>)+; readable=(<P586>)+
MATCH p71_0 = (s)-[:P586*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q156; freq=1; rpq=(<602>)*; readable=(<P602>)*
MATCH p229_0 = (s)-[:P602*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q157; freq=1; rpq=(<602>/(<12>)?)/(<196>)*; readable=(<P602>/(<P12>)?)/(<P196>)*
MATCH (s)-[:P602]->(m145_0_0)
MATCH (m145_0_0)-[:P12*0..1]->(m145_0_1)
MATCH (m145_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q158; freq=1; rpq=(<690>)+; readable=(<P690>)+
MATCH p181_0 = (s)-[:P690*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q159; freq=1; rpq=(<939>)*; readable=(<P939>)*
MATCH p43_0 = (s)-[:P939*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q160; freq=1; rpq=(<939>/(<12>)*)/(<196>)*; readable=(<P939>/(<P12>)*)/(<P196>)*
MATCH (s)-[:P939]->(m117_0_0)
MATCH (m117_0_0)-[:P12*0..]->(m117_0_1)
MATCH (m117_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q161; freq=1; rpq=(<949>)*; readable=(<P949>)*
MATCH p82_0 = (s)-[:P949*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q162; freq=1; rpq=(<949>/<925->)/(<196>)*; readable=(<P949>/<P925^-1>)/(<P196>)*
MATCH (s)-[:P949]->(m87_0_0)
MATCH (m87_0_0)<-[:P925]-(m87_0_1)
MATCH (m87_0_1)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q163; freq=1; rpq=<1141>/(<412>)*; readable=<P1141>/(<P412>)*
MATCH (s)-[:P1141]->(m121_0_0)
MATCH (m121_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q164; freq=1; rpq=<12>/(<3130>)*; readable=<P12>/(<P3130>)*
MATCH (s)-[:P12]->(m112_0_0)
MATCH (m112_0_0)-[:P3130*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q165; freq=1; rpq=<12>/(<320>)*; readable=<P12>/(<P320>)*
MATCH (s)-[:P12]->(m193_0_0)
MATCH (m193_0_0)-[:P320*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q166; freq=1; rpq=<12>/(<586>)*; readable=<P12>/(<P586>)*
MATCH (s)-[:P12]->(m79_0_0)
MATCH (m79_0_0)-[:P586*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q167; freq=1; rpq=<12>/(<612>)*; readable=<P12>/(<P612>)*
MATCH (s)-[:P12]->(m183_0_0)
MATCH (m183_0_0)-[:P612*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q168; freq=1; rpq=<12>/(<800>)*; readable=<P12>/(<P800>)*
MATCH (s)-[:P12]->(m88_0_0)
MATCH (m88_0_0)-[:P800*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q169; freq=1; rpq=<12>/(<949>)*; readable=<P12>/(<P949>)*
MATCH (s)-[:P12]->(m123_0_0)
MATCH (m123_0_0)-[:P949*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q170; freq=1; rpq=<1337>/(<412>)*; readable=<P1337>/(<P412>)*
MATCH (s)-[:P1337]->(m35_0_0)
MATCH (m35_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q171; freq=1; rpq=<13>/(<196>)*; readable=<P13>/(<P196>)*
MATCH (s)-[:P13]->(m209_0_0)
MATCH (m209_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q172; freq=1; rpq=<1449>/(<176>)*; readable=<P1449>/(<P176>)*
MATCH (s)-[:P1449]->(m85_0_0)
MATCH (m85_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q173; freq=1; rpq=<1473>/(<176->)*; readable=<P1473>/(<P176^-1>)*
MATCH (s)-[:P1473]->(m179_0_0)
MATCH (m179_0_0)<-[:P176*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q174; freq=1; rpq=<1473>/(<397->)*; readable=<P1473>/(<P397^-1>)*
MATCH (s)-[:P1473]->(m180_0_0)
MATCH (m180_0_0)<-[:P397*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q175; freq=1; rpq=<1712>/(<196>)*; readable=<P1712>/(<P196>)*
MATCH (s)-[:P1712]->(m110_0_0)
MATCH (m110_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q176; freq=1; rpq=<176>/(<176>)*; readable=<P176>/(<P176>)*
MATCH (s)-[:P176]->(m152_0_0)
MATCH (m152_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q177; freq=1; rpq=<199>/(<412>)*; readable=<P199>/(<P412>)*
MATCH (s)-[:P199]->(m122_0_0)
MATCH (m122_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q178; freq=1; rpq=<201>/(<196>)*; readable=<P201>/(<P196>)*
MATCH (s)-[:P201]->(m203_0_0)
MATCH (m203_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q179; freq=1; rpq=<205>/(<159>)*; readable=<P205>/(<P159>)*
MATCH (s)-[:P205]->(m149_0_0)
MATCH (m149_0_0)-[:P159*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q180; freq=1; rpq=<206>/(<196>)+; readable=<P206>/(<P196>)+
MATCH (s)-[:P206]->(m81_0_0)
MATCH (m81_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q181; freq=1; rpq=<210>/(<12>)*; readable=<P210>/(<P12>)*
MATCH (s)-[:P210]->(m151_0_0)
MATCH (m151_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q182; freq=1; rpq=<2277>/(<196>)*; readable=<P2277>/(<P196>)*
MATCH (s)-[:P2277]->(m36_0_0)
MATCH (m36_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q183; freq=1; rpq=<289>/(<35>)*; readable=<P289>/(<P35>)*
MATCH (s)-[:P289]->(m63_0_0)
MATCH (m63_0_0)-[:P35*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q184; freq=1; rpq=<304>/(<1341>)*; readable=<P304>/(<P1341>)*
MATCH (s)-[:P304]->(m231_0_0)
MATCH (m231_0_0)-[:P1341*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q185; freq=1; rpq=<31>/(<412>)*; readable=<P31>/(<P412>)*
MATCH (s)-[:P31]->(m200_0_0)
MATCH (m200_0_0)-[:P412*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q186; freq=1; rpq=<338>/(<196>)+; readable=<P338>/(<P196>)+
MATCH (s)-[:P338]->(m115_0_0)
MATCH (m115_0_0)-[:P196*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q187; freq=1; rpq=<390>/(<196>)*; readable=<P390>/(<P196>)*
MATCH (s)-[:P390]->(m156_0_0)
MATCH (m156_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q188; freq=1; rpq=<390>/(<4377>)*; readable=<P390>/(<P4377>)*
MATCH (s)-[:P390]->(m157_0_0)
MATCH (m157_0_0)-[:P4377*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q189; freq=1; rpq=<397>/(<31>)*; readable=<P397>/(<P31>)*
MATCH (s)-[:P397]->(m205_0_0)
MATCH (m205_0_0)-[:P31*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q190; freq=1; rpq=<412>/(<12>)*; readable=<P412>/(<P12>)*
MATCH (s)-[:P412]->(m241_0_0)
MATCH (m241_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q191; freq=1; rpq=<412>/(<159>)*; readable=<P412>/(<P159>)*
MATCH (s)-[:P412]->(m67_0_0)
MATCH (m67_0_0)-[:P159*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q192; freq=1; rpq=<412>/(<196>)*; readable=<P412>/(<P196>)*
MATCH (s)-[:P412]->(m150_0_0)
MATCH (m150_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q193; freq=1; rpq=<443>/(<196>)*; readable=<P443>/(<P196>)*
MATCH (s)-[:P443]->(m206_0_0)
MATCH (m206_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q194; freq=1; rpq=<52>/((<690>|<52>))*; readable=<P52>/((<P690>|<P52>))*
MATCH (s)-[:P52]->(m218_0_0)
MATCH (m218_0_0)-[:P52|P690*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q195; freq=1; rpq=<537->/(<176->)*; readable=<P537^-1>/(<P176^-1>)*
MATCH (s)<-[:P537]-(m228_0_0)
MATCH (m228_0_0)<-[:P176*0..]-(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q196; freq=1; rpq=<537->/(<176>)*; readable=<P537^-1>/(<P176>)*
MATCH (s)<-[:P537]-(m226_0_0)
MATCH (m226_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q197; freq=1; rpq=<537>/(<176>)*; readable=<P537>/(<P176>)*
MATCH (s)-[:P537]->(m225_0_0)
MATCH (m225_0_0)-[:P176*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q198; freq=1; rpq=<602>/(<12>)*; readable=<P602>/(<P12>)*
MATCH (s)-[:P602]->(m95_0_0)
MATCH (m95_0_0)-[:P12*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q199; freq=1; rpq=<602>/(<196>)*; readable=<P602>/(<P196>)*
MATCH (s)-[:P602]->(m216_0_0)
MATCH (m216_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q200; freq=1; rpq=<847>/(<196>)*; readable=<P847>/(<P196>)*
MATCH (s)-[:P847]->(m136_0_0)
MATCH (m136_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q201; freq=1; rpq=<925->/(<196>)*; readable=<P925^-1>/(<P196>)*
MATCH (s)<-[:P925]-(m86_0_0)
MATCH (m86_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q202; freq=1; rpq=<939>/(<176>)+; readable=<P939>/(<P176>)+
MATCH (s)-[:P939]->(m118_0_0)
MATCH (m118_0_0)-[:P176*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q203; freq=1; rpq=<939>/(<933>)+; readable=<P939>/(<P933>)+
MATCH (s)-[:P939]->(m119_0_0)
MATCH (m119_0_0)-[:P933*1..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

// q204; freq=1; rpq=<949>/(<196>)*; readable=<P949>/(<P196>)*
MATCH (s)-[:P949]->(m221_0_0)
MATCH (m221_0_0)-[:P196*0..]->(t)
RETURN DISTINCT id(s) AS src, id(t) AS dst;

