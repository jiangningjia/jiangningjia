#!/usr/bin/perl
use warnings;
use strict;

#for my $c(1..12){

open(IN, "<核酸多态性504RGN2.txt")|| die $!;
open(OUT, ">核酸多态性504RGN2.hmp.txt")|| die $!;

#print OUT "rs	alleles	chrom	pos	strand	assembly	center	protSID	assayLSID	panel	Qccode	CH1305	CH1003	CH1004	CH1005	CH1008	CH1009	CH1012	CH1013	CH1014	CH1015	CH1016	CH1017	CH1018	CH1019	CH1021	CH1022	CH1023	CH1024	CH1027	CH1028	CH1029	CH1030	CH1032	CH1034	CH1035	CH1037	CH1039	CH1041	CH1044	CH1045	CH1046	CH1048	CH1049	CH1054	CH1056	CH1059	CH1060	CH1061	CH1062	CH1063	CH1067	CH1068	CH1070	CH1071	CH1072	CH1076	CH1077	CH1082	CH1087	CH1090	CH1091	CH1092	CH1097	CH1098	CH1099	CH1100	CH1101	CH1102	CH1103	CH1104	CH1109	CH1110	CH1113	CH1116	CH1118	CH1119	CH1120	CH1122	CH1126	CH1128	CH1129	CH1131	CH1132	CH1134	CH1137	CH1141	CH1144	CH1145	CH1148	CH1149	CH1150	CH1155	CH1158	CH1159	CH1161	CH1162	CH1164	CH1165	CH1166	CH1167	CH1169	CH1170	CH1179	CH1183	CH1184	CH1185	CH1186	CH1190	CH1191	CH1193	CH1194	CH1196	CH1198	CH1202	CH1204	CH1205	CH1208	CH1209	CH1210	CH1211	CH1213	CH1214	CH1215	CH1219	CH1223	CH1224	CH1226	CH1227	CH1229	CH1230	CH1232	CH1233	CH1234	CH1235	CH1236	CH1237	CH1238	CH1239	CH1241	CH1242	CH1243	CH1245	CH1246	CH1247	CH1248	CH1249	CH1250	CH1251	CH1253	CH1255	CH1259	CH1260	CH1265	CH1267	CH1268	CH1269	CH1274	CH1276	CH1277	CH1278	CH1283	CH1284	CH1288	CH1289	CH1291	CH1293	CH1297	CH1298	CH1001	CH1002	CH1006	CH1010	CH1020	CH1026	CH1038	CH1050	CH1055	CH1057	CH1064	CH1069	CH1073	CH1074	CH1075	CH1081	CH1083	CH1085	CH1086	CH1088	CH1093	CH1094	CH1095	CH1096	CH1105	CH1106	CH1107	CH1108	CH1111	CH1112	CH1114	CH1115	CH1117	CH1125	CH1130	CH1133	CH1139	CH1142	CH1146	CH1147	CH1151	CH1152	CH1156	CH1163	CH1168	CH1171	CH1173	CH1180	CH1181	CH1182	CH1187	CH1189	CH1195	CH1197	CH1199	CH1203	CH1216	CH1217	CH1220	CH1221	CH1222	CH1225	CH1228	CH1231	CH1240	CH1244	CH1252	CH1256	CH1257	CH1258	CH1262	CH1263	CH1264	CH1266	CH1271	CH1272	CH1273	CH1275	CH1281	CH1282	CH1285	CH1286	CH1290	CH1294	CH1295	CH1296	CH1299	CH1302	CH1058	CH1084	CH1192	CH1033	CH1178	CH1011	CH1052	CH1136	CH1154	CH1089	CH1300	CH1301	CH1303	CH1160	CH1047	CH1157	CH1025	CH1121	CH1201	CH1079\n";

while (my $line = <IN>){
	chomp($line);
	my @tmp = split(/\s+/,$line);
	my $chr = $tmp[0];
	$chr=~s/Chr//;
	my $pos = $tmp[1];
	my $rs = "$tmp[0]\_$pos";
	my @basetype =();
	my %alleles=();
	push @basetype, "$tmp[2]"; #补进去参考基因组日本晴的基因型
	foreach (3 .. $#tmp){              # 9311-chr01 4567 T  A  T
    	my $base ="";
    	if ($tmp[$_]=~/[ATGC]{1}/){
			$alleles{$tmp[$_]}++;
			$base =$tmp[$_];    #  如果是纯和位点， 直接转换就行，A => AA,  G =>GG  T=>TT C=>CC
		}
		elsif($tmp[$_] =~/[MRWSYK]{1}/){
			if ($tmp[$_] eq "M") {
				$alleles{A}++; $alleles{C}++;
				$base="M";
		    }
		    elsif ($tmp[$_] eq "R") {
				$alleles{A}++; $alleles{G}++;
       			$base="R";
			}
			elsif ($tmp[$_] eq "W") {
				$alleles{A}++; $alleles{T}++;
				$base="W";
			}
			elsif ($tmp[$_] eq "S") {
				$alleles{C}++; $alleles{G}++;
				$base="S";
			}
			elsif ($tmp[$_] eq "Y") {
				$alleles{C}++; $alleles{T}++;
				$base="Y";
			}
			else {
				$alleles{G}++; $alleles{T}++;
				$base="K";
			}

		}
		else {
        	$base ="N";
		}
	push @basetype, $base;
	}

	my @alleles = sort keys %alleles;
	my $alleletype = "$alleles[0]/$alleles[1]";
	my $basetype_long = join "\t", @basetype;
	print OUT "$rs\t$alleletype\t$chr\t$pos\t+\tNA\tNA\tNA\tNA\tNA\tNA\t$basetype_long\n";

 }

#}


 close(IN);
 close(OUT);
 exit;