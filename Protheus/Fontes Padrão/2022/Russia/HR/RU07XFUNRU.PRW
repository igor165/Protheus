#INCLUDE "PROTHEUS.CH"
//#INCLUDE "STRCC2RUS.CH"
//#INCLUDE "RU07XFUNRU.CH"
//#INCLUDE "STRSRARUS.CH"
/*/
Function RU07XFUNRU()

	Local aFldTabl As Array
	Local aDataTabl As Array	
	
	aFldTabl := {"Q3_FILIAL","Q3_CARGO","Q3_DESCSUM","Q3_CC","Q3_DESCDET","Q3_DRESP","Q3_DRELINT","Q3_DHABILI","Q3_GRUPO","Q3_DEPTO","Q3_TIPO","Q3_PONTOSI","Q3_TABELA","Q3_TABNIVE","Q3_CLASSE","Q3_CHKNMB","Q3_RGWGRP","Q3_CTGCD","Q3_TABFAIX","Q3_ETKS","Q3_CATEG","Q3_OKZ","Q3_ADTPCAR","Q3_ADTPJU","Q3_ADTPESC","Q3_ADATIV","Q3_ADTPROV","Q3_ADHORAS","Q3_ADCP","Q3_ADRESP","Q3_PORTAL","Q3_CBO","Q3_ACUM","Q3_SUBSTIT","Q3_PRIORL","Q3_CTESP","Q3_DEDEXC","Q3_LEI","Q3_DTLEI","Q3_SIT"}
	aDataTabl := {}
	
    aAdd(aDataTabl, {"1020  ","20015"   ,STRSQ30001,"         ","022416","022415","022417","022418","  ","         ","",0,"   ","  ","   ",0,"          ","3"         ,"  ",0," ",3416," ","1","  "," "," ",0,"2",,"      ","000000","1"," ","     ","1","1","            ",,"1"})
    aAdd(aDataTabl, {"1020  ","1",       STRSQ30002,"         ","022480","022479","022481","022482","  ","000000001","",0,"   ","  ","   ",0,"          ","          ","  ",0," ",0   ," ","1","  "," "," ",0,"2",,"      ","      "," "," ","     "," "," ","            ",," "})
    aAdd(aDataTabl, {"1020  ","2",       STRSQ30003,"51"       ,"      ","      ","      ","      ","  ","000000031","",0,"   ","  ","   ",0,"          ","          ","  ",0," ",0   ," ","1","  "," "," ",0,"2",,"      ","      "," "," ","     "," "," ","            ",," "})
    aAdd(aDataTabl, {"1020  ","3",       STRSQ30004,"52"       ,"      ","      ","      ","      ","  ","000000031","",0,"   ","  ","   ",0,"          ","          ","  ",0," ",0   ," ","1","  "," "," ",0,"2",,"      ","      "," "," ","     "," "," ","            ",," "})
    aAdd(aDataTabl, {"1020  ","4",       STRSQ30005,"51"       ,"      ","      ","      ","      ","  ","000000001","",0,"   ","  ","   ",0,"          ","          ","  ",0," ",0   ," ","1","  "," "," ",0,"2",,"      ","      "," "," ","     "," "," ","            ",," "})
    aAdd(aDataTabl, {"1020  ",STRSQ30007,STRSQ30006,"2012"     ,"      ","      ","      ","      ","  ","         ","",0,"   ","  ","   ",0,"          ","          ","  ",0," ",0   ," ","1","  "," "," ",0,"2",,"      ","      "," "," ","     "," "," ","            ",," "})

	RU07XAddData("SQ3", aFldTabl, aDataTabl)
	
    aFldTabl := {"QB_FILIAL","QB_DEPTO","QB_DESCRIC","QB_CC","QB_REGIAO","QB_GRUPO","QB_DEPSUP","QB_KEYINI","QB_FILRESP","QB_ARELIN","QB_MATRESP","QB_CODUNIC","QB_DTSTART","QB_DTEND","QB_MEMO1"}
	aDataTabl := {}
	
    aAdd(aDataTabl, {"1020","000000031",STRSQB0001,"51"       ,"      ","  ","         ","                                                            ","      ","          ","      ","      ",          ,          ,""})
    aAdd(aDataTabl, {"1020","000000032",STRSQB0002,"52"       ,"      ","  ","         ","                                                            ","      ","          ","      ","      ","20190201",          ,""})
    aAdd(aDataTabl, {"1020","000000033",STRSQB0003,"52"       ,"      ","  ","         ","                                                            ","102030","          ","000198","001020","20191216","99991231",""})
    aAdd(aDataTabl, {"1020","000000034",STRSQB0004,"         ","      ","  ","         ","004"                                                         ,"      ","          ","      ","      ","20191230","99991231",""})
    aAdd(aDataTabl, {"1020","000000001",STRSQB0005,"51"       ,"      ","  ","         ","001"                                                         ,"102030","          ","000219","000093","20190901","99991231",""})

	RU07XAddData("SQB", aFldTabl, aDataTabl)
	
	aFldTabl := {"CTT_FILIAL","CTT_CUSTO","CTT_CLASSE","CTT_NORMAL","CTT_DESC01","CTT_DESC02","CTT_DESC03","CTT_DESC04","CTT_DESC05","CTT_BLOQ","CTT_DTBLIN","CTT_DTBLFI","CTT_DTEXIS","CTT_DTEXSF","CTT_CCLP","CTT_CCPON","CTT_BOOK","CTT_TIPO00","CTT_CCSUP","CTT_TIPO01","CTT_RES","CTT_CRGNV1","CTT_RGNV2","CTT_RGNV3","CTT_STATUS","CTT_FILMAT","CTT_MAT","CTT_PERCAC","CTT_PERFPA","CTT_NOME","CTT_ENDER","CTT_BAIRRO","CTT_CEP","CTT_ESTADO","CTT_MUNIC","CTT_TIPO","CTT_CEI","CTT_VALFAT","CTT_RETIDO","CTT_LOCAL","CTT_OCORRE","CTT_ITOBRG","CTT_CLOBRG","CTT_ACITEM","CTT_ACCLVL","CTT_CCVM","CTT_CCRED","CTT_CSINCO","CTT_OPERAC","CTT_TPINCT","CTT_NRINCT","CTT_INTRES","CTT_AT01OB","CTT_TPO03","CTT_ACATIV","CTT_RHEXP","CTT_ACAT01","CTT_ACAT03","CTT_EMAIL","CTT_RESERV","CTT_TPO01","CTT_ACAT02","CTT_ACAT04","CTT_AT03OB","CTT_ATOBRG","CTT_CPART","CTT_TPO02","CTT_TPO04","CTT_AT02OB","CTT_AT04OB","CTT_CESCRI"}
	aDataTabl := {}

	aAdd(aDataTabl, {"      ","49"  ,"2","1",STRCTT0040,"                                        ","                                        ","                                        ","                                        ","2",          ,          ,"19800101","        ","49"  ,"         ","                    ","  ","         ","  ","          ","            ","            ","            "," ","      ","      ",0,0,"                                        ","                                        ","                    ","        ","  ","                    "," ","         ",0,0,"  ","  ","2","2","1","1","         ","         "," ","   "," ","              ","2"," ","  "," ","      "," "," ","                                                            ","1","  "," "," "," "," ","      ","  ","  "," "," ","     "})
	aAdd(aDataTabl, {"      ","50"  ,"2","1",STRCTT0041,"                                        ","                                        ","                                        ","                                        ","2",          ,          ,"19800101","        ","50"  ,"         ","                    ","  ","         ","  ","          ","            ","            ","            "," ","      ","      ",0,0,"                                        ","                                        ","                    ","        ","  ","                    "," ","         ",0,0,"  ","  ","2","2","1","1","         ","         "," ","   "," ","              ","2"," ","  "," ","      "," "," ","                                                            ","1","  "," "," "," "," ","      ","  ","  "," "," ","     "})
	aAdd(aDataTabl, {"      ","51"  ,"2","1",STRCTT0042,"                                        ","                                        ","                                        ","                                        ","2",          ,          ,"19800101","        ","51"  ,"         ","                    ","  ","         ","  ","          ","            ","            ","            "," ","      ","      ",0,0,"                                        ","                                        ","                    ","        ","50","                    "," ","366406939",0,0,"  ","  ","2","2","1","1","         ","         "," ","   "," ","              ","2"," ","  "," ","      "," "," ","                                                            ","1","  "," "," "," "," ","      ","  ","  "," "," ","     "})
	aAdd(aDataTabl, {"      ","52"  ,"2","1",STRCTT0043,"                                        ","                                        ","                                        ","                                        ","2",          ,          ,"19800101","        ","52"  ,"         ","                    ","  ","         ","  ","          ","            ","            ","            "," ","      ","      ",0,0,"                                        ","                                        ","                    ","        ","78","                    "," ","         ",0,0,"  ","  ","2","2","1","1","         ","         "," ","   "," ","              ","2"," ","  "," ","      "," "," ","                                                            ","1","  "," "," "," "," ","      ","  ","  "," "," ","     "})

	RU07XAddData("CTT", aFldTabl, aDataTabl)
	
	aFldTabl := {"R8_FILIAL","R8_MAT","R8_DATA","R8_SEQ","R8_TIPOAFA","R8_ABROAD","R8_TIPO","R8_PD","R8_DATAINI","R8_AFARAIS","R8_DATAFIM","R8_CODMEMO","R8_DURACAO","R8_DIASEMP","R8_DPAGAR","R8_CONTINU","R8_DNAPLIC","R8_CODCAT","R8_CONTAFA","R8_DTCAT","R8_CID","R8_DPAGOS","R8_PER","R8_NUMPAGO","R8_NUMID","R8_SDPAGAR","R8_CODRPAT","R8_STATUS","R8_EMPPG","R8_DTBLEG","R8_PROCES","R8_RHEXP","R8_CODTPA","R8_EFDRETR","R8_OBSAFAS","R8_TPEFD","R8_ORIGALT","R8_NRPRCJU","R8_TIPOAT","R8_DATALT","R8_NMMED","R8_CRMMED","R8_UFCRM","R8_IDEOC","R8_CNPJCES","R8_TPCES","R8_CNPJSIN","R8_TPSIND","R8_PROADIC","R8_INTGTAF","R8_TPPROC","R8_TPEFDAN","R8_FILSUB","R8_TAFKA","R8_MATSUB","R8_TAFKI","R8_GEDOC","R8_TAFKF","R8_DTER"}
	aDataTabl := {}

	aAdd(aDataTabl, {"102030","000226","20200214","001","004","F"," ","006","20200113","  ","20200117","      ",5 ,15,5 ,"2",0,"             ","   ","        ","          ",0 ,"202001","01","SR800022600620200113      ",0,"    "," "," ","        ","00001","      ","      "," ","                                                                                                                                                                                                        ","  "," ","                     "," ","        ","                                                                                ","              ","  "," ","              "," ","              "," "," ","        "," ","  ","  ","                                                            ","      ","                                                            ","                    ","                                                            ","        "})
	aAdd(aDataTabl, {"102030","000228","20200214","001","004","F"," ","006","20200113","  ","20200117","      ",5 ,15,5 ,"2",0,"             ","   ","        ","          ",0 ,"202001","01","SR800022800620200113      ",0,"    "," "," ","        ","00001","      ","      "," ","                                                                                                                                                                                                        ","  "," ","                     "," ","        ","                                                                                ","              ","  "," ","              "," ","              "," "," ","        "," ","  ","  ","                                                            ","      ","                                                            ","                    ","                                                            ","        "})
//	aAdd(aDataTabl, {"102030","000226","20200214","001","004","F"," ","006","20200114","  ","20200121","      ",8 ,15,8 ,"2",0,"             ","   ","        ","          ",0 ,"202001","01","SR800022600620200114      ",0,"    "," "," ","        ","00001","      ","      "," ","                                                                                                                                                                                                        ","  "," ","                     "," ","        ","                                                                                ","              ","  "," ","              "," ","              "," "," ","        "," ","  ","  ","                                                            ","      ","                                                            ","                    ","                                                            ","        "})
	aAdd(aDataTabl, {"102030","000226","20200217","001","003","F"," ","005","20191209","  ","20191226","      ",18,15,15,"2",0,"             ","   ","        ","          ",15,"201912","01","SR800022600520191209      ",0,"    ","T"," ","        ","00001","      ","      "," ","                                                                                                                                                                                                        ","  "," ","                     "," ","        ","                                                                                ","              ","  "," ","              "," ","              "," "," ","        "," ","  ","  ","                                                            ","      ","                                                            ","                    ","                                                            ","        "})
//	aAdd(aDataTabl, {"102030","000228","20200217","001","004","F"," ","006","20191230","  ","20200103","      ",5 ,15,5 ,"2",0,"             ","   ","        ","          ",2 ,"201912","01","SR800022800620191230      ",3,"    ","T"," ","        ","00001","      ","      "," ","                                                                                                                                                                                                        ","  "," ","                     "," ","        ","                                                                                ","              ","  "," ","              "," ","              "," "," ","        "," ","  ","  ","                                                            ","      ","                                                            ","                    ","                                                            ","        "})

	RU07XAddData("SR8", aFldTabl, aDataTabl)

	aFldTabl := {"CC2_FILIAL","CC2_EST","CC2_CODMUN","CC2_MUN"}
	aDataTabl := {}

	aAdd(aDataTabl, {"102030",  "1", "00001", STRCC20001})
	aAdd(aDataTabl, {"102030",  "2", "00002", STRCC20002})
	aAdd(aDataTabl, {"102030",  "3", "00003", STRCC20003})
	aAdd(aDataTabl, {"102030",  "4", "00004", STRCC20004})
	aAdd(aDataTabl, {"102030",  "5", "00005", STRCC20005})
	aAdd(aDataTabl, {"102030",  "6", "00006", STRCC20006})
	aAdd(aDataTabl, {"102030",  "7", "00007", STRCC20007})
	aAdd(aDataTabl, {"102030",  "8", "00008", STRCC20008})
	aAdd(aDataTabl, {"102030",  "9", "00009", STRCC20009})
	aAdd(aDataTabl, {"102030", "10", "00010", STRCC20010})
	aAdd(aDataTabl, {"102030", "11", "00011", STRCC20011})
	aAdd(aDataTabl, {"102030", "12", "00012", STRCC20012})
	aAdd(aDataTabl, {"102030", "13", "00013", STRCC20013})
	aAdd(aDataTabl, {"102030", "14", "00014", STRCC20014})
	aAdd(aDataTabl, {"102030", "15", "00015", STRCC20015})
	aAdd(aDataTabl, {"102030", "16", "00016", STRCC20016})
	aAdd(aDataTabl, {"102030", "17", "00017", STRCC20017})
	aAdd(aDataTabl, {"102030", "18", "00018", STRCC20018})
	aAdd(aDataTabl, {"102030", "19", "00019", STRCC20019})
	aAdd(aDataTabl, {"102030", "20", "00020", STRCC20020})
	aAdd(aDataTabl, {"102030", "21", "00021", STRCC20021})
	aAdd(aDataTabl, {"102030", "22", "00022", STRCC20022})
	aAdd(aDataTabl, {"102030", "23", "00023", STRCC20023})
	aAdd(aDataTabl, {"102030", "24", "00024", STRCC20024})
	aAdd(aDataTabl, {"102030", "25", "00025", STRCC20025})
	aAdd(aDataTabl, {"102030", "26", "00026", STRCC20026})
	aAdd(aDataTabl, {"102030", "27", "00027", STRCC20027})
	aAdd(aDataTabl, {"102030", "28", "00028", STRCC20028})
	aAdd(aDataTabl, {"102030", "29", "00029", STRCC20029})
	aAdd(aDataTabl, {"102030", "30", "00030", STRCC20030})
	aAdd(aDataTabl, {"102030", "31", "00031", STRCC20031})
	aAdd(aDataTabl, {"102030", "32", "00032", STRCC20032})
	aAdd(aDataTabl, {"102030", "33", "00033", STRCC20033})
	aAdd(aDataTabl, {"102030", "34", "00034", STRCC20034})
	aAdd(aDataTabl, {"102030", "35", "00035", STRCC20035})
	aAdd(aDataTabl, {"102030", "36", "00036", STRCC20036})
	aAdd(aDataTabl, {"102030", "37", "00037", STRCC20037})
	aAdd(aDataTabl, {"102030", "38", "00038", STRCC20038})
	aAdd(aDataTabl, {"102030", "39", "00039", STRCC20039})
	aAdd(aDataTabl, {"102030", "40", "00040", STRCC20040})
	aAdd(aDataTabl, {"102030", "41", "00041", STRCC20041})
	aAdd(aDataTabl, {"102030", "42", "00042", STRCC20042})
	aAdd(aDataTabl, {"102030", "43", "00043", STRCC20043})
	aAdd(aDataTabl, {"102030", "44", "00044", STRCC20044})
	aAdd(aDataTabl, {"102030", "45", "00045", STRCC20045})
	aAdd(aDataTabl, {"102030", "46", "00046", STRCC20046})
	aAdd(aDataTabl, {"102030", "47", "00047", STRCC20047})
	aAdd(aDataTabl, {"102030", "48", "00048", STRCC20048})
	aAdd(aDataTabl, {"102030", "49", "00049", STRCC20049})
	aAdd(aDataTabl, {"102030", "50", "00050", STRCC20050})
	aAdd(aDataTabl, {"102030", "51", "00051", STRCC20051})
	aAdd(aDataTabl, {"102030", "52", "00052", STRCC20052})
	aAdd(aDataTabl, {"102030", "53", "00053", STRCC20053})
	aAdd(aDataTabl, {"102030", "54", "00054", STRCC20054})
	aAdd(aDataTabl, {"102030", "55", "00055", STRCC20055})
	aAdd(aDataTabl, {"102030", "56", "00056", STRCC20056})
	aAdd(aDataTabl, {"102030", "57", "00057", STRCC20057})
	aAdd(aDataTabl, {"102030", "58", "00058", STRCC20058})
	aAdd(aDataTabl, {"102030", "59", "00059", STRCC20059})
	aAdd(aDataTabl, {"102030", "60", "00060", STRCC20060})
	aAdd(aDataTabl, {"102030", "61", "00061", STRCC20061})
	aAdd(aDataTabl, {"102030", "62", "00062", STRCC20062})
	aAdd(aDataTabl, {"102030", "63", "00063", STRCC20063})
	aAdd(aDataTabl, {"102030", "64", "00064", STRCC20064})
	aAdd(aDataTabl, {"102030", "65", "00065", STRCC20065})
	aAdd(aDataTabl, {"102030", "66", "00066", STRCC20066})
	aAdd(aDataTabl, {"102030", "67", "00067", STRCC20067})
	aAdd(aDataTabl, {"102030", "68", "00068", STRCC20068})
	aAdd(aDataTabl, {"102030", "69", "00069", STRCC20069})
	aAdd(aDataTabl, {"102030", "70", "00070", STRCC20070})
	aAdd(aDataTabl, {"102030", "71", "00071", STRCC20071})
	aAdd(aDataTabl, {"102030", "72", "00072", STRCC20072})
	aAdd(aDataTabl, {"102030", "73", "00073", STRCC20073})
	aAdd(aDataTabl, {"102030", "74", "00074", STRCC20074})
	aAdd(aDataTabl, {"102030", "75", "00075", STRCC20075})
	aAdd(aDataTabl, {"102030", "76", "00076", STRCC20076})
	aAdd(aDataTabl, {"102030", "77", "00077", STRCC20077})
	aAdd(aDataTabl, {"102030", "78", "00078", STRCC20078})
	aAdd(aDataTabl, {"102030", "79", "00079", STRCC20079})
	aAdd(aDataTabl, {"102030", "80", "00080", STRCC20080})
	aAdd(aDataTabl, {"102030", "81", "00081", STRCC20081})
	aAdd(aDataTabl, {"102030", "82", "00082", STRCC20082})
	aAdd(aDataTabl, {"102030", "83", "00083", STRCC20083})
	aAdd(aDataTabl, {"102030", "84", "00084", STRCC20084})
	aAdd(aDataTabl, {"102030", "85", "00085", STRCC20085})

	RU07XAddData("CC2", aFldTabl, aDataTabl)

	aFldTabl := {"RA_FILIAL", "RA_BITMAP", "RA_MAT", "RA_PRISOBR", "RA_NOME", "RA_SECNOME", "RA_SECSOBR", "RA_NOMECMP", "RA_MAE", "RA_PAI", "RA_PRINOME", "RA_SEXO", "RA_HOJORVA", "RA_NSOCIAL", "RA_RACACOR", "RA_NASC", "RA_ALTNASC", "RA_ESTCIVI", "RA_CPAISOR", "RA_NACIONA", "RA_NACIONC", "RA_NATURAL", "RA_CODMUNN", "RA_APELIDO", "RA_GRINRAI", "RA_EMAIL", "RA_EMAIL2", "RA_RECMAIL", "RA_TPMAIL", "RA_DEFIFIS", "RA_BRPDH", "RA_TPDEFFI", "RA_PORTDEF", "RA_KEYLOC", "RA_OBSDEFI", "RA_CC", "RA_CLVL", "RA_ITEM", "RA_ADMISSA", "RA_ALTADM", "RA_DEPIR", "RA_TIPOADM", "RA_DEMISSA", "RA_TELEMOV", "RA_DEPSF", "RA_OPCAO", "RA_ALTOPC", "RA_BCDPFGT", "RA_CTDPFGT", "RA_CHAPA", "RA_PERFGTS", "RA_UTLVL", "RA_TNOTRAB", "RA_BCDEPSA", "RA_TPCTSAL", "RA_CTDEPSA", "RA_SITFOLH", "RA_PROCES", "RA_HRSMES", "RA_HRSEMAN", "RA_CATFUNC", "RA_HRSDIA", "RA_CODFUNC", "RA_TIMES", "RA_SALARIO", "RA_ANTEAUM", "RA_PGCTSIN", "RA_ADCPERI", "RA_TIPOCON", "RA_TPCONTR", "RA_CESTAB", "RA_PERWK", "RA_DTFIMCT", "RA_VALEREF", "RA_HOPARC", "RA_CLAURES", "RA_PERCADT", "RA_SINDICA", "RA_PENSALI", "RA_CBO", "RA_ALTCBO", "RA_TIPOPGT", "RA_VIEMRAI", "RA_GRPEMP", "RA_CATEG", "RA_CATEFD", "RA_VCTOEXP", "RA_PERICUL", "RA_PERADM", "RA_INSMIN", "RA_VCTEXP2", "RA_INSMED", "RA_EXAMEDI", "RA_PAGADM", "RA_OBRASOC", "RA_DTVTEST", "RA_PERAUM", "RA_ADCINS", "RA_PAGAUM", "RA_AFASFGT", "RA_ASSIST", "RA_CONFED", "RA_MENSIND", "RA_RESCRAI", "RA_MESESAN", "RA_MESTRAB", "RA_BASEINS", "RA_INSSOUT", "RA_CLASSEC", "RA_OCORREN", "RA_PERCSAT", "RA_CARGO", "RA_CODTIT", "RA_POSTO", "RA_DEPTO", "RA_TIPOSAL", "RA_ALTNOME", "RA_CODRET", "RA_CRACHA", "RA_FECREI", "RA_MEDIASE", "RA_REGRA", "RA_DEMIANT", "RA_MOLEST", "RA_COMPSAB", "RA_EAPOSEN", "RA_SEQTURN", "RA_SENHA", "RA_DTEFRET", "RA_DTEFRTN", "RA_CIC", "RA_NIVEL", "RA_PIS", "RA_TPRCBT", "RA_ALTPIS", "RA_RG", "RA_TCFMSG", "RA_INSSSC", "RA_RGUF", "RA_RGORG", "RA_RGEXP", "RA_ORGEMRG", "RA_DISTSN", "RA_NUMCP", "RA_BHFOL", "RA_SERCP", "RA_UFCP", "RA_HABILIT", "RA_ACUMBH", "RA_OKTRANS", "RA_TABELA", "RA_PRIMSEG", "RA_ALTCP", "RA_TABNIVE", "RA_TABFAIX", "RA_CNHORG", "RA_TIPODOC", "RA_DTEMCNH", "RA_DTVCCNH", "RA_RECPFNC", "RA_TIPENDE", "RA_RESEXT", "RA_TITULOE", "RA_ZONASEC", "RA_PAISEXT", "RA_LOGRTP", "RA_REGISTR", "RA_FICHA", "RA_SERVENT", "RA_LOGRDSC", "RA_LOGRNUM", "RA_PASSPOR", "RA_ENDEREC", "RA_CLASEST", "RA_NUMENDE", "RA_MSBLQL", "RA_COMPLEM", "RA_TIPCERT", "RA_BAIRRO", "RA_EMICERT", "RA_MATCERT", "RA_ESTADO", "RA_LIVCERT", "RA_CODMUN", "RA_FOLCERT", "RA_MUNICIP", "RA_CARCERT", "RA_CEP", "RA_UFCERT", "RA_CPOSTAL", "RA_CDMUCER", "RA_CEPCXPO", "RA_NUMEPAS", "RA_ALTEND", "RA_EMISPAS", "RA_DDDFONE", "RA_TELEFON", "RA_ASMEDIC", "RA_UFPAS", "RA_DDDCELU", "RA_DEMIPAS", "RA_DPASSME", "RA_DVALPAS", "RA_NUMCELU", "RA_CODPAIS", "RA_CHIDENT", "RA_NUMINSC", "RA_SERVICO", "RA_CATCNH", "RA_CODIGO", "RA_UFCNH", "RA_OCDTEXP", "RA_RESERVI", "RA_OCDTVAL", "RA_CODUNIC", "RA_PRCFCH", "RA_PERFCH", "RA_ROTFCH", "RA_NUPFCH", "RA_RNE", "RA_RNEORG", "RA_RNEDEXP", "RA_DATCHEG", "RA_ANOCHEG", "RA_NUMNATU", "RA_DATNATU", "RA_CASADBR", "RA_FILHOBR", "RA_INSSAUT", "RA_REGIME", "RA_FWIDM", "RA_DESEPS", "RA_INSMAX", "RA_ADCCONF", "RA_ADCTRF", "RA_PLSAUDE", "RA_RHEXP", "RA_ADTPOSE", "RA_MATMIG", "RA_AUTMEI", "RA_USRADM", "RA_CTPCD", "RA_RFNP"}
	aDataTabl := {}

	aAdd(aDataTabl, {"102030", "", "000228", STRSRA0001, STRSRA0002, STRSRA0003, "", STRSRA0004, "",  STRSRA0005, "", "M", "2", "", "", "19870402", "", "5", "", "", "643", "", "123", "", "13-06", "", "", "", "1", "2", "", "0", "", "", "", "52", "", "", "20191230", "", "", "9B", "", "", "", "20191230", "", "", "", "", "0", "0", "001", "044525600", "1", "40702810400260004426", "A", "00001", "160", "40", "M", "8", "", "", "115000", "0", "", "1", "", "", "", "0", "", "", "2", "1", "40", "01", "0", "", "", "M", "10", "", "", "", "", "0", "", "0", "", "0", "", "", "", "", "", "1", "", "", "2", "2", "2", "", "0", "", "0", "0", "", "", "0", "00003", "", "", "", "", "", "", "", "", "", "01", "", "", "1", "2", "01", "810501", "", "", "48831440510", "", "526317984689", "", "", "", "", "", "", "", "", "", "", "1234567", "S", "8TK-IIV", "23", "", "S", "", "", "0", "S", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "001020", "", "", "", "", "", "", "", "", "", "", "", "", "", "S", "", "", "", "0", "0", "0", "1", "", "******", "", "", "000281", "2", STRSRA0006, "", "2", "0"})
	aAdd(aDataTabl, {"102030", "", "000226", STRSRA0007, STRSRA0008, STRSRA0009, "", STRSRA0010, "",  STRSRA0011, "", "M", "2", "", "", "19450218", "", "2", "", "21", "643", "", "", "", "", "", "", "1", "1", "2", "", "0", "", "", "", "52", "", "", "20191008", "", "", "9B", "", "", "", "20190908", "", "", "", "", "0", "0", "001", "044525202", "1", "40817810099910004320", "", "00001", "160", "40", "M", "0", "00097", "", "115000", "115000", "N", "1", "", "1", "", "0", "", "", "2", "2", "40", "01", "0", "", "", "M", "10", "", "", "", "", "0", "", "0", "", "0", "", "", "", "", "", "1", "", "", "2", "2", "2", "", "0", "", "0", "0", "", "", "0", "25042", "", "", "", "", "", "", "", "", "", "01", "", "", "1", "2", "01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "N", "", "", "", "N", "", "", "0", "", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "001020", "", "", "", "", "", "", "", "", "", "", "", "", "", "S", "", "", "", "0", "0", "0", "2", "", "A*****", "", "", "000281", "2", STRSRA0012, "", "1", "0"})
	aAdd(aDataTabl, {"102030", "", "000243", STRSRA0013, STRSRA0014, STRSRA0015, "", STRSRA0016, "", "", "", "M", "2", "", "9", "19570521", "", "5", "", "10", "", "", "", "", STRSRA0017, "", "", "", "1", "2", "", "0", "", "", "", "52", "", "", "20200101", "", "", "9B", "", "", "", "20200303", "", "", "", "", "0", "0", "001", "", "", "", "", "00001", "160", "40", "H", "8", "", "", "1800", "0", "", "1", "", "2", "", "0", "", "", "2", "1", "30", "01", "0", "", "", "M", "10", "", "", "", "", "0", "", "0", "", "0", "", "", "", "", "", "1", "", "", "2", "2", "2", "", "0", "", "0", "0", "", "", "0", "00003", "", "", "000000031", "", "", "", "", "", "", "", "", "", "1", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "S", "", "", "", "S", "", "", "0", "", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "001020", "", "", "", "", "", "", "", "", "", "", "", "", "", "S", "", "", "", "0", "30", "15", "2", "", "AB****", "", "", "000281", "2", "", "", "3", "0"})
	aAdd(aDataTabl, {"102030", "", "000244", STRSRA0018, STRSRA0019, STRSRA0020, "", STRSRA0021, "", "", "", "M", "2", "", "", "19710106", "", "1", "", "", "", "", "", "", "", "", "", "", "1", "2", "", "0", "", "", "", "51", "", "", "20200101", "", "", "9B", "", "", "", "20200101", "", "", "", "", "0", "0", "002", "", "", "", "", "00001", "200", "40", "H", "8", "", "", "900", "0", "", "1", "", "", "", "0", "", "", "2", "1", "40", "01", "0", "", "", "M", "10", "", "", "", "", "0", "", "0", "", "0", "", "", "", "", "", "1", "", "", "2", "2", "2", "", "0", "", "0", "0", "", "", "0", "00004", "", "", "000000001", "", "", "", "", "", "", "", "", "", "1", "2", "01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "0", "", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "001020", "", "", "", "", "", "", "", "", "", "", "", "", "", "S", "", "", "", "0", "0", "0", "2", "", "***N**", "", "", "000281", "2", "", "", "4", "0"})
	aAdd(aDataTabl, {"102030", "", "000246", STRSRA0022, STRSRA0023, STRSRA0024, "", STRSRA0025, "", "", "", "M", "2", "", "", "19920302", "", "1", "", "", "", "", "", "", "", "", "", "", "1", "2", "", "0", "", "", "", "51", "", "", "20200101", "", "", "9A", "", "", "", "20200101", "", "", "", "", "0", "0", "004", "", "", "", "", "00001", "160", "40", "H", "8", "00097", "", "1200", "0", "", "1", "", "2", "", "0", "", "", "2", "1", "40", "01", "0", "", "", "M", "10", "", "", "", "", "0", "", "0", "", "0", "", "", "", "", "", "1", "", "", "2", "2", "2", "", "0", "", "0", "0", "", "", "0", "25042", "", "", "000000031", "", "", "", "", "", "", "", "", "", "1", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "0", "", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "001020", "", "", "", "", "", "", "", "", "", "", "", "", "", "S", "", "", "", "0", "0", "0", "2", "", "***N**", "", "", "000281", "2", "", "", "6", "0"})
	aAdd(aDataTabl, {"102030", "", "000245", STRSRA0026, STRSRA0027, STRSRA0028, "", STRSRA0029, "", "", "", "M", "2", "", "", "19900430", "", "2", "", "", "", "", "", "", "", "", "", "", "1", "2", "", "0", "", "", "", "51", "", "", "20200101", "", "", "9A", "", "", "", "20200101", "", "", "", "", "0", "0", "003", "", "", "", "", "00001", "160", "40", "H", "8", "", "", "1000", "0", "", "1", "", "2", "", "0", "", "", "2", "1", "40", "", "0", "", "", "M", "10", "", "", "", "", "0", "", "0", "", "0", "", "", "", "", "", "1", "", "", "2", "2", "2", "", "0", "", "0", "0", "", "", "0", "00002", "", "", "000000031", "", "", "", "", "", "", "", "", "", "1", "2", "01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "0", "", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "001020", "", "", "", "", "", "", "", "", "", "", "", "", "", "S", "", "", "", "0", "0", "0", "2", "", "***N**", "", "", "000281", "2", "", "", "5", "0"})

	RU07XAddData("SRA", aFldTabl, aDataTabl)

	aFldTabl := {"PJ_ENTRA1","PJ_SAIDA1","PJ_ENTRA2","PJ_FILIAL","PJ_SAIDA2","PJ_ENTRA3","PJ_SAIDA3","PJ_ENTRA4","PJ_SAIDA4","PJ_HORMAIS","PJ_CODREF","PJ_TPEXT","PJ_TPEXTN","PJ_NONAHOR","PJ_TURNO","PJ_INTERV1","PJ_INTERV2","PJ_INTERV3","PJ_JND1CON","PJ_JND2CON","PJ_JND3CON","PJ_JND4CON","PJ_HRSINT1","PJ_HRSINT2","PJ_HRSINT3","PJ_SEMANA","PJ_HRSTRAB","PJ_HRSTRA2","PJ_HRSTRA3","PJ_HRSTRA4","PJ_HRTOTAL","PJ_INTSREP","PJ_RHEXP","PJ_DIA","PJ_TPDIA","PJ_HORMENO"}
	aDataTabl := {}
	
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","2","6","N","001","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","1","N","0.01"," ","1","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","1","5","N","001","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","2","S","0.01"," ","2","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","1","5","N","001","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","3","S","0.01"," ","3","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","1","5","N","001","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","4","S","0.01"," ","4","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","1","5","N","001","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","5","S","0.01"," ","5","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","1","5","N","001","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","6","S","0.01"," ","6","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","3","7","N","001","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","7","N","0.01"," ","7","0"})

	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","8","  ","2","6","N","002","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","1","N","5"," ","8","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","8","  ","1","5","N","002","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","2","S","5"," ","9","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","8","  ","1","5","N","002","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","3","S","5"," ","10","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","8","  ","1","5","N","002","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","4","S","5"," ","11","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","8","  ","1","5","N","002","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","5","S","5"," ","12","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","8","  ","1","5","N","002","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","6","S","5"," ","13","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","8","  ","3","7","N","002","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","7","N","5"," ","14","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","5","  ","2","6","N","003","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","1","N","5"," ","15","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","5","  ","1","5","N","003","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","2","S","5"," ","16","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","5","  ","1","5","N","003","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","3","S","5"," ","17","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","5","  ","1","5","N","003","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","4","S","5"," ","18","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","5","  ","1","5","N","003","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","5","S","5"," ","19","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","5","  ","1","5","N","003","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","6","S","5"," ","20","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","5","  ","3","7","N","003","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","7","N","5"," ","21","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","2","6","N","004","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","1","N","0.01"," ","22","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","1","5","N","004","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","2","S","0.01"," ","23","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","1","5","N","004","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","3","S","0.01"," ","24","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","1","5","N","004","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","4","S","0.01"," ","25","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","1","5","N","004","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","5","S","0.01"," ","26","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","1","5","N","004","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","6","S","0.01"," ","27","0"})
	aAdd(aDataTabl, {"0","0","0","1020  ","0","0","0","0","0","0.01","  ","3","7","N","004","N","N","N","N","N","N","N","0","0","0","01","0","0","0","0","0","  ","      ","7","N","0.01"," ","28","0"})

	RU07XAddData("SPJ", aFldTabl, aDataTabl)

	SRAAddIndex() // Add index of SRA table into SIX table.

Return 

Function RU07XAddData(cArea, aFldTabl, aDataTabl)

	Local nX as Numeric
	Local nY as Numeric
	Local cType as Char

	DbSelectArea(cArea)
		If (cArea)->(eof())
			(cArea)->(DbGoTop())
			Begin Transaction
				For nX := 1 To Len(aDataTabl)
					RecLock(cArea, .T.)
					For nY := 1 To Len(aFldTabl)
						
						cType := GetSx3Cache(aFldTabl[nY],"X3_TIPO")
						
						If ( cType == "N" )
							if VALTYPE(aDataTabl[nX,nY])="N"
								&(aFldTabl[nY]) := aDataTabl[nX,nY]
							else
								&(aFldTabl[nY]) := Val(aDataTabl[nX,nY])
							endif
						ElseIf ( cType == "D" )
							if aDataTabl[nX,nY] == NIL 
								&(aFldTabl[nY]) := aDataTabl[nX,nY]
							else
								&(aFldTabl[nY]) := CTOD(aDataTabl[nX,nY])
							endif
						ElseIf ( cType == "L" )
							if aDataTabl[nX,nY]== "F"
								&(aFldTabl[nY]) := .F.
							else
								&(aFldTabl[nY]) := .T.
							Endif
						Else
							&(aFldTabl[nY]) := aDataTabl[nX,nY]
						EndIf
						
					Next nY
					MsUnLock()
				Next nX
			End Transaction
		endif
	DbCloseArea()

Return 

/*{Protheus.doc} RU07XAddIndx
	Add data of index to SIX table.
	@type  Function
	@author v.selyakov
	@since 202020320
	@version version
	@example

Function RU07XAddIndx(cArea, aFldTabl, aDataTabl)
	Local nX       As Numeric
	Local nY       As Numeric
	Local aCurArea As Array

	aCurArea := GetArea()

	DbSelectArea(cArea)	

		Begin Transaction
				For nX := 1 To Len(aDataTabl)
					If !(IsExstIndx(aDataTabl[nX,1], aDataTabl[nX,3]))
						RecLock(cArea, .T.)
						For nY := 1 To Len(aFldTabl)							
							&(aFldTabl[nY]) := aDataTabl[nX,nY]							
						Next nY
						MsUnLock()					
					EndIf
				Next nX
		End Transaction

	DbCloseArea()
	RestArea(aCurArea)
Return

/*{Protheus.doc} IsExstIndx
	Check exist data line into SIX table.
	@type  Function
	@author v.selyakov
	@since 202020320
	@version version
	@example IsExstIndx("SRA", "RA_FILIAL+RA_MAT")

Static Function IsExstIndx(cIndice, cChave)
	Local lRet        As Logical
	Local aCurArea    As Array
	Local cAlias      As Character
	Local cQuery      As Character
	Local oStatement  As Object
	Local nOrdem      As Numeric

	lRet := .F.
	nOrdem := 0

	aCurArea := GetArea()
	oStatement := FWPreparedStatement():New()
	
	cQuery := " SELECT COUNT(ORDEM) AS ORD FROM " + MPSysSQLName("SIX") + " WHERE INDICE=? AND CHAVE=? "

	oStatement:SetQuery(cQuery)
    oStatement:SetString(1, cIndice)
    oStatement:SetString(2, cChave)

	cQuery := oStatement:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)
   	DBSelectArea(cAlias)
   	DBGoTop()

	If (cAlias)->(!EOF()) 
		nOrdem := (cAlias)->ORD
	EndIf

	If !(nOrdem == 0)
		lRet := .T.
	EndIf

	RestArea(aCurArea)
Return lRet

/*{Protheus.doc} RU07XDropTable
	Removing and restoring a table passed to a function.
	@type  Function
	@author v.selyakov
	@since 202020325
	@version version
	@example RU07XDropTable("SRA")

Function RU07XDropTable(cTable)
	Local aCurArea    As Array

	aCurArea := GetArea()

	TCDelFile(RetSQLName(cTable))

	DBSelectArea(cTable)
   	DBSetOrder(1)
   	DBGoTop()

   	While !EOF()
   	  DBSkip()
   	Enddo

	RestArea(aCurArea)
Return

{Protheus.doc} SRAAddIndex
	Add new index into SIX to SRA table.
	@type  Function
	@author v.selyakov
	@since 202020320
	@version version
	@example SRAAddIndex()

Function SRAAddIndex()
	Local aFldTabl As Array
	Local aDataTabl As Array

	aFldTabl := {"INDICE","ORDEM","CHAVE","DESCRICAO","DESCSPA","DESCENG","PROPRI","F3","NICKNAME","SHOWPESQ","IX_VIRTUAL","IX_VIRCUST","IX_LOCALIZ","IX_LOCTYP"}
	aDataTabl := {}

	// Add index for RUS to RA_NOMECMP field.
	aAdd(aDataTabl, {"SRA", "V", "RA_FILIAL+RA_NOMECMP", "FILIAL + FULL NAME", "FILIAL + FULL NAME", "FILIAL + FULL NAME", "S", " ", " ", "S", "2", "3", "RUS", "3"})

	RU07XAddIndx("SIX", aFldTabl, aDataTabl)
Return
/