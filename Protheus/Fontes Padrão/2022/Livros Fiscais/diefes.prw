#Include "Protheus.Ch"
#Include "DiefEs.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³fDiefEs   ³ Autor ³Andressa Fagundes      ³ Data ³09.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do meio-magnetico para a Dief-ES  (SEFAZ/ES)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fDiefEs (nFuncao)
	Local	xRet	:=	.T.
	//
	Default	nFuncao		:=	1
	//
	If (nFuncao==3)
		xRet	:=	sfRetCfop()
	ElseIf (nFuncao==5)
		xRet	:=	sfCafe ()
	Endif	
	//
Return (xRet)             

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³sfRetCfop ³ Autor ³Andressa Fagundes      ³ Data ³09.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna determinado codigo Cfop por categoria.              ³±±
±±³          ³Gera registro Transporte - Detalhamento.                    ³±±
±±³          ³Gera registro Comunicacao - Detalhamento.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC -> Codigo CFOP de acordo com layout.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN -> nPosFimCfp - Posicao final do arquivo CFP contendo  ³±±
±±³          ³ os relacionamentos de Cfop's.                              ³±±
±±³Parametros³ExpC -> cAlias - Alias criado pelo ResumeF3.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function sfRetCfop ()
	Local	nI			:=	0
	Local	nPos		:=	0
	Local	nPos1		:=	0
	Local	aCfop		:=	{}
	Local	nCont		:=	0
	Local	aStruRg5	:=	{}
	Local	cArqRg5		:=	""
	Local	cMacro		:=	"/"
	Local	cCfop		:=	""
	//
	Local	aArea		:=	GetArea ()
	Local	cArqTran	:=	""
	Local   cArqCom     := ""
	Local   cArqMun     := ""		
	Local   cArqRur     := ""  
	Local   cArqGI      := ""  			
	Local   cCodMun     := ""
	Local   cCodGi      := ""	 
	Local	aStruTran	:=	{}
	Local	aStruCom	:=	{}
	Local	aStruMun	:=	{}
	Local	aStruRur	:=	{}
	Local   aStruIcm	:= {}
	Local	cArqSf3		:=	"" 
	Local	cSaida		:= "S"
	Local	cEntr		:= "E"	 
	Local   cMesGI		:= GetNewPar("MV_MGICMS","")
	Local	lMCdiefes	:=	Iif(GetNewPar("MV_MCDFES","")=="", .F., .T.)
	Local   aCodMun     := {}
	Local   lTms		:=	IntTms() 
	
	//
	#IFDEF TOP
		Local	aStruSF3	:=	{}
		Local	nX			:=	0
	#ENDIF
	//
	ResumeF3 ("IC", _aTotal[001], _aTotal[002], "*", .F., .T., 1, .F., 2, Nil, Nil, {}, {}, "", .T., "RF3", .F., .F., .F.)
	//
	aAdd (aStruRg5, {"G5_NRCFOP",	"N",	004,	000})
	aAdd (aStruRg5, {"G5_VLCONT",	"N",	012,	002})
	aAdd (aStruRg5, {"G5_VLBASE",	"N",	012,	002})
	aAdd (aStruRg5, {"G5_VLIMPO",	"N",	012,	002})
	aAdd (aStruRg5, {"G5_VLISEN",	"N",	012,	002})
	aAdd (aStruRg5, {"G5_VLOUTR",	"N",	012,	002})
	//
	cArqRg5	:=	CriaTrab (aStruRg5, .T.)
	DbUseArea (.T., __LocalDriver, cArqRg5, "RG5")
	IndRegua ("RG5", cArqRg5, "G5_NRCFOP")
	//
	aAdd (aCfop, {"001", "110", "1100"})
	aAdd (aCfop, {"002", "120", "1150"})
	aAdd (aCfop, {"003", "130", "1200"})
	aAdd (aCfop, {"004", "140", "1250"})
	aAdd (aCfop, {"005", "150", "1300"})
	aAdd (aCfop, {"006", "160", "1350"})
	aAdd (aCfop, {"007", "170", "1400"})
	aAdd (aCfop, {"008", "", "1450"})
	aAdd (aCfop, {"009", "", "1500"})
	aAdd (aCfop, {"010", "", "1550"})
	aAdd (aCfop, {"011", "", "1600"})
	aAdd (aCfop, {"012", "", "1650"})
	aAdd (aCfop, {"013", "190", "1900"})
	aAdd (aCfop, {"014", "210", "2100"})
	aAdd (aCfop, {"015", "220", "2150"})
	aAdd (aCfop, {"016", "230", "2200"})
	aAdd (aCfop, {"017", "240", "2250"})
	aAdd (aCfop, {"018", "250", "2300"})
	aAdd (aCfop, {"019", "260", "2350"})
	aAdd (aCfop, {"020", "270", "2400"})
	aAdd (aCfop, {"021", "", "2500"})
	aAdd (aCfop, {"022", "", "2550"})
	aAdd (aCfop, {"023", "", "2600"})
	aAdd (aCfop, {"024", "", "2650"})
	aAdd (aCfop, {"025", "290", "2900"})
	aAdd (aCfop, {"026", "310", "3100"})
	aAdd (aCfop, {"027", "320", "3200"})
	aAdd (aCfop, {"028", "330", "3250"})
	aAdd (aCfop, {"029", "340", "3300"})
	aAdd (aCfop, {"030", "350", "3350"})
	aAdd (aCfop, {"031", "", "3500"})
	aAdd (aCfop, {"032", "", "3550"})
	aAdd (aCfop, {"033", "", "3650"})
	aAdd (aCfop, {"034", "390", "3900"})
	aAdd (aCfop, {"035", "510", "5100"})
	aAdd (aCfop, {"036", "520", "5150"})
	aAdd (aCfop, {"037", "530", "5200"})
	aAdd (aCfop, {"038", "540", "5250"})
	aAdd (aCfop, {"039", "550", "5300"})
	aAdd (aCfop, {"040", "560", "5350"})
	aAdd (aCfop, {"041", "570", "5400"})
	aAdd (aCfop, {"042", "", "5450"})
	aAdd (aCfop, {"043", "", "5500"})
	aAdd (aCfop, {"044", "", "5550"})
	aAdd (aCfop, {"045", "", "5600"})
	aAdd (aCfop, {"046", "", "5650"})
	aAdd (aCfop, {"047", "590", "5900"})
	aAdd (aCfop, {"048", "610", "6100"})
	aAdd (aCfop, {"049", "620", "6150"})
	aAdd (aCfop, {"050", "630", "6200"})
	aAdd (aCfop, {"051", "640", "6250"})
	aAdd (aCfop, {"052", "650", "6300"})
	aAdd (aCfop, {"053", "660", "6350"})
	aAdd (aCfop, {"054", "670", "6400"})
	aAdd (aCfop, {"055", "", "6500"})
	aAdd (aCfop, {"056", "", "6550"})
	aAdd (aCfop, {"057", "", "6600"})
	aAdd (aCfop, {"058", "", "6650"})
	aAdd (aCfop, {"059", "690", "6900"})
	aAdd (aCfop, {"060", "710", "7100"})
	aAdd (aCfop, {"061", "730", "7200"})
	aAdd (aCfop, {"062", "740", "7250"})
	aAdd (aCfop, {"063", "750", "7300"})
	aAdd (aCfop, {"064", "760", "7350"})
	aAdd (aCfop, {"065", "", "7500"})
	aAdd (aCfop, {"066", "", "7550"})
	aAdd (aCfop, {"067", "", "7650"})
	aAdd (aCfop, {"068", "790", "7900"})
	//
	RF3->(DbGoTop ())
	//
	Do While !(RF3->(Eof ()))
	    For nI := 1 To Val (aCfop[Len (aCfop)][1])               
			nPos:=aScan (_aTotal[097], {|x| AllTrim(RF3->CFOP)$x})
			Exit
		Next (nI)
		//
		If (nPos==0)
			Help (" ", 1, "FALTACFOP",,"Cfop ["+AllTrim (RF3->CFOP)+"] utilizado nao consta nos parametros.", 3, 0)
			cCfop	:=	"0"
			//
			RG5->(RecLock ("RG5", .T.))
				RG5->G5_NRCFOP	:=	Val (cCfop)
				RG5->G5_VLCONT	:=	RF3->VALCONT
				RG5->G5_VLBASE 	:=	RF3->BASEICM
				RG5->G5_VLIMPO	:=	RF3->VALICM
				RG5->G5_VLISEN	:=	RF3->ISENICM
				RG5->G5_VLOUTR	:=	RF3->OUTRICM
			RG5->(MsUnLock ())	
		Else
			If (RG5->(MsSeek (Val (aCfop[nPos][Iif ((Len (RF3->CFOP)==3),2 , 3)]))))
				RG5->(RecLock ("RG5", .F.))
					RG5->G5_VLCONT	+=	RF3->VALCONT
					RG5->G5_VLBASE 	+=	RF3->BASEICM
					RG5->G5_VLIMPO	+=	RF3->VALICM
					RG5->G5_VLISEN	+=	RF3->ISENICM
					RG5->G5_VLOUTR	+=	RF3->OUTRICM
				RG5->(MsUnLock ())
			Else
				cCfop	:=	aCfop[nPos][Iif ((Len (RF3->CFOP)==3),2 , 3)]
				cMacro	+=	AllTrim (aCfop[nPos][Iif ((Len (RF3->CFOP)==3),2 , 3)])+"/"
				//
				RG5->(RecLock ("RG5", .T.))
					RG5->G5_NRCFOP	:=	Val (cCfop)
					RG5->G5_VLCONT	:=	RF3->VALCONT
					RG5->G5_VLBASE 	:=	RF3->BASEICM
					RG5->G5_VLIMPO	:=	RF3->VALICM
					RG5->G5_VLISEN	:=	RF3->ISENICM
					RG5->G5_VLOUTR	:=	RF3->OUTRICM
				RG5->(MsUnLock ())	
			EndIf
		EndIf
		//
		RF3->(DbSkip ())
		nPos:=0
	EndDo
	//
	RF3->(DbCloseArea ())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os outros grupos de Cfops. Pois é exigido assim pelo validador.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To (Len (aCfop))
		If !(aCfop[nI][Iif ((Val(SubStr(DToS (_aTotal[001]),1,4))<2002),2,3)]$cMacro)
			RG5->(RecLock ("RG5", .T.))
				RG5->G5_NRCFOP	:=	Val (aCfop[nI][Iif ((Val(SubStr(DToS(_aTotal[001]),1,4))<2002),2,3)])
				RG5->G5_VLCONT	:=	0
				RG5->G5_VLBASE 	:=	0
				RG5->G5_VLIMPO	:=	0
				RG5->G5_VLISEN	:=	0
				RG5->G5_VLOUTR	:=	0
			RG5->(MsUnLock ())
		EndIf
	Next (nI)
	//                   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gerando registros para os Quadros:        				  ³ 
	//³- Quadro Transportes - Detalhamento       				  ³ 
	//³- Quadro Comunicacao - Detalhamento       				  ³
    //³- Quadro Mudanca de Municipio            				  ³ 
    //³- Quadro GI / ICMS                        				  ³ 
    //³- Produtor Rural											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//              
	//Transportes
	aAdd (aStruTran, {"TR_CODMUN",	"C",	006,	000})
	aAdd (aStruTran, {"TR_VLCONT",	"N",	010,	002})
	aAdd (aStruTran, {"TR_CLIEFOR",	"C",	006,	000})
	
	cArqTran	:=	CriaTrab (aStruTran, .T.)
	DbUseArea (.T., __LocalDriver, cArqTran, "TRA")
	//IndRegua ("TRA", cArqTran, "TR_CLIEFOR")
	IndRegua ("TRA", cArqTran, "TR_CODMUN")
	//
	//           
	//Comunicacao
	aAdd (aStruCom, {"CM_CODMUN",	"C",	006,	000})
	aAdd (aStruCom, {"CM_VLCONT",	"N",	010,	002})
	aAdd (aStruCom, {"CM_CLIEFOR",	"C",	006,	000})

	cArqCom	:=	CriaTrab (aStruCom, .T.)
	DbUseArea (.T., __LocalDriver, cArqCom, "COM")
	IndRegua ("COM", cArqCom, "CM_CLIEFOR")
	//
	//           
	//Mudanca de Municipio
	aAdd (aStruMun, {"MC_NRCFOP",	"N",	004,	000})
	aAdd (aStruMun, {"MC_VLCONT",	"N",	012,	002})

	cArqMun	:=	CriaTrab (aStruMun, .T.)
	DbUseArea (.T., __LocalDriver, cArqMun, "MUN")
	IndRegua ("MUN", cArqMun, "MC_NRCFOP")        
	//
	//           
	//GIM / ICMS
	aAdd (aStruIcm, {"GI_UFLOCAL",  "C",	002,	000})	//SIGLA DO LOCAL - UNIDADE FEDERATIVA
	aAdd (aStruIcm, {"GI_TPMOV",    "C",	001,	000})   //TIPO MOVIMENTO - E=ENTRADA; S=SAIDA
	aAdd (aStruIcm, {"GI_VLCONT",   "N",	012,	002})   //VALOR CONTABIL
	aAdd (aStruIcm, {"GI_VLCTNC",   "N",	012,	002})   //VALOR CONTABIL NAO CONTRIBUINTE - UTILIZADO APENAS P/ SAIDAS	
	aAdd (aStruIcm, {"GI_VLBASE",   "N",	012,	002})   //VALOR BASE
	aAdd (aStruIcm, {"GI_VLBSNC",   "N",	012,	002})   //VALOR BASE NAO CONTRIBUINTE - UTILIZADO APENAS P/ SAIDAS		
	aAdd (aStruIcm, {"GI_VLOUTR",   "N",	012,	002})   //VALOR OUTRAS
	aAdd (aStruIcm, {"GI_VLPTEN",   "N",	012,	002})   //VALOR PETROLEO ENERGIA
	aAdd (aStruIcm, {"GI_VLOTNC",   "N",	012,	002})   //VALOR OUTRAS NAO CONTRIBUINTE - ENTRADAS(OUTROS PRODUTOS) / SAIDAS(ICMS-ST)	
	
	cArqGI	:=	CriaTrab (aStruICM, .T.)
	DbUseArea (.T., __LocalDriver, cArqGI, "GIM")
	IndRegua ("GIM", cArqGI, "GI_UFLOCAL+GI_TPMOV")        	    
	//
	//                    
	//Produtor Rural
	aAdd (aStruRur, {"RR_INSC"   , "C",  	009,	000})
	aAdd (aStruRur, {"RR_NFISCAL", "C",		TamSX3("F2_DOC")[1],	000})
	aAdd (aStruRur, {"RR_DTEMISS", "D",		008,	000})
	aAdd (aStruRur, {"RR_UF"     , "C",		005,	000})
	aAdd (aStruRur, {"RR_NATUR"  , "N",		002,	000})
	aAdd (aStruRur, {"RR_TIPO"   , "N",		002,	000})
	aAdd (aStruRur, {"RR_VLCONT" , "N",		010,	002})
	aAdd (aStruRur, {"RR_VLICMS" , "N",		010,	002})
	
	cArqRur	:=	CriaTrab (aStruRur, .T.)
	DbUseArea (.T., __LocalDriver, cArqRur, "RUR")
	IndRegua ("RUR", cArqRur, "RR_NFISCAL")

	cAliasSF3	:=	"SF3"
	DbSelectArea ("SF3")
	#IFDEF TOP
	    If TcSrvType()<>"AS/400"
	    	
	    	aStruSF3  :=	SF3->(DbStruct ())
	    	
	    	cAliasSF3 :=	GetNextAlias()

			cQuery    := "SELECT * "
			cQuery    += "FROM " + RetSqlName("SF3") + " SF3 "
			cQuery    += "WHERE "
			cQuery    += "F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery    += "F3_ENTRADA >= '" + Dtos(_aTotal[001]) + "' AND "
			cQuery    += "F3_ENTRADA <= '" + Dtos(_aTotal[002]) + "' AND "
			cQuery    += "F3_TIPO <> 'S' AND F3_DTCANC='' AND "
			cQuery    += "SF3.D_E_L_E_T_  = ' ' "
			cQuery    += "ORDER BY F3_ENTRADA,F3_SERIE,F3_NFISCAL,F3_TIPO,F3_CLIEFOR,F3_LOJA"
						
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.) 
			For nX := 1 To len(aStruSF3)         
				If aStruSF3[nX][2] <> "C" 
					TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
				EndIf
			Next nX
		Else
   #ENDIF
	cArqSf3	:=	CriaTrab (Nil, .F.)
		IndRegua ("SF3", cArqSf3, (cAliasSF3)->(IndexKey ()),, 'SF3->F3_FILIAL=="'+xFilial ("SF3")+'" .And. DToS (SF3->F3_ENTRADA)>="'+DToS (_aTotal[001])+'" .And. DToS (SF3->F3_ENTRADA)<="'+DToS (_aTotal[002])+'" .And. SF3->F3_TIPO<>"S" .And. Empty(SF3->F3_DTCANC)')
		(cAliasSF3)->(DbGoTop ())	
	#IFDEF TOP
		EndIf
	#ENDIF
	//
	Do While !(cAliasSF3)->(Eof())
	    For nI := 1 To Val (aCfop[Len (aCfop)][1])
			nPos:=aScan (_aTotal[097], {|x| AllTrim((cAliasSF3)->F3_CFO)$x})
		Exit                            	
		Next (nI)
		
	    If lTms
	    	//A funcao abaixo retorna os dados do Remetente da CTR.
		    aCodMun := TMSInfSol((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSf3)->F3_CLIEFOR,(cAliasSf3)->F3_LOJA,.T.)	
		EndIf
		If Len(aCodMun)>0
			cCodMun := aCodMun[12]	
		EndIf
  		//
		DbSelectArea ("SA1")
		SA1->(DbSetOrder (1))
 		If (SA1->(DbSeek (xFilial ("SA1")+(cAliasSF3)->(F3_CLIEFOR+F3_LOJA))))
		    If ((nPos==40) .Or.(nPos==53) .Or.(nPos==64)) .And. (Substr((cAliasSF3)->F3_CFO,1,1)>="5")     //SAIDAS
				//If (TRA->(MsSeek(Alltrim((cAliasSF3)->F3_CLIEFOR))))
				If (TRA->(MsSeek(Alltrim(cCodMun))))
					TRA->(RecLock ("TRA", .F.))
					TRA->TR_VLCONT	+=	(cAliasSF3)->F3_VALCONT
					TRA->(MsUnLock ())
				Else
					cCodMun	:=	""					
					If (lMCdiefes) .And. (SA1->(FieldPos(GetNewPar("MV_MCDFES","")))>0)  //codigo de municipio - parametro MV_MCDFES						
 						//cCodMun := SA1->&(GetNewPar("MV_MCDFES"))																		
						//If Empty(cCodMun) .And. Len(aCodMun)>0							
						//If Len(aCodMun)>0
							//Codigo do Municipio do remetente retornado da funcao TMSInfSol()													
							cCodMun := aCodMun[12]							
						//EndIf						
					Else
						cCodMun	:= Iif(SM0->M0_ESTENT==(SA1->A1_EST),AllTrim (SA1->A1_COD_MUN),AllTrim(SM0->M0_CODMUN))
					EndIf
					TRA->(RecLock ("TRA", .T.))
					TRA->TR_CODMUN	:=	AllTrim(cCodMun)
					TRA->TR_VLCONT	:= (cAliasSF3)->F3_VALCONT
					TRA->TR_CLIEFOR := AllTrim((cAliasSF3)->F3_CLIEFOR)
					TRA->(MsUnLock ())
					//
				EndIf                                      
			Elseif (nPos==39) .And. (Substr((cAliasSF3)->F3_CFO,1,1)>="5")  //SAIDAS
				If (COM->(MsSeek(Alltrim((cAliasSF3)->F3_CLIEFOR))))
						COM->(RecLock ("TRA", .F.))
							COM->TR_VLCONT	+=	(cAliasSF3)->F3_VALCONT
						COM->(MsUnLock ())
				Else
					cCodMun	:= Iif(SM0->M0_ESTENT==(SA1->A1_EST),AllTrim (SA1->A1_COD_MUN),Alltrim(SM0->M0_CODMUN))					
					COM->(RecLock ("COM", .T.))
						COM->CM_CODMUN	:=	Alltrim(cCodMun)
						COM->CM_VLCONT	:= (cAliasSF3)->F3_VALCONT
						COM->CM_CLIEFOR := AllTrim((cAliasSF3)->F3_CLIEFOR)
					COM->(MsUnLock ())
					//
				EndIf                                      
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Saidas no municipio de origem do estabelecimento  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (Substr((cAliasSF3)->F3_CFO,1,1)>="5")
				If (Alltrim(SM0->M0_CODMUN)==SA1->A1_COD_MUN)  //SAIDA DENTRO DOMUNICIPIO                         
					If (nPos<>0)
						If (MUN->(MsSeek (Val(aCfop[nPos][Iif((Len((cAliasSF3)->F3_CFO)==3),2,3)]))))
							MUN->(RecLock ("MUN", .F.))
								MUN->MC_VLCONT	+=	(cAliasSF3)->F3_VALCONT
							MUN->(MsUnLock ())
						Else
							cCfop	:=	aCfop[nPos][Iif((Len((cAliasSF3)->F3_CFO)==3),2,3)]
							cMacro	+=	AllTrim (aCfop[nPos][Iif ((Len ((cAliasSF3)->F3_CFO)==3),2 , 3)])+"/"
							//
							MUN->(RecLock ("MUN", .T.))
								MUN->MC_NRCFOP	:=	Val (cCfop)
								MUN->MC_VLCONT	:=	(cAliasSF3)->F3_VALCONT
							MUN->(MsUnLock ())	
						EndIf
					Endif
		    	Endif     
		    Endif	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³NFP = Nota de Produtor Rural                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim((cAliasSF3)->F3_ESPECIE) == "NFP" .And. (Substr((cAliasSF3)->F3_CFO,1,1)>="5")
				If (RUR->(MsSeek(Alltrim((cAliasSF3)->F3_NFISCAL))))
						RUR->(RecLock ("RUR", .F.))
							RUR->RR_VLCONT	+=	(cAliasSF3)->F3_VALCONT
							RUR->RR_VLICMS	+=	(cAliasSF3)->F3_VALICM
						RUR->(MsUnLock ())
				Else
					RUR->(RecLock ("RUR", .T.))
						RUR->RR_INSC	:= SA1->A1_INSCR
						RUR->RR_NFISCAL	:= (cAliasSF3)->F3_NFISCAL
						RUR->RR_DTEMISS := (cAliasSF3)->F3_EMISSAO
						RUR->RR_UF      := SA1->A1_COD_MUN
						RUR->RR_NATUR   := 01 //Processando apenas as saidas, logo a natureza sera 01(Venda)
						RUR->RR_TIPO    := Iif(Substr((cAliasSF3)->F3_CFO,1,1)=="5",01,Iif(Substr((cAliasSF3)->F3_CFO,1,1)=="6",02,03))
						RUR->RR_VLCONT  := (cAliasSF3)->F3_VALCONT
						RUR->RR_VLICMS  := (cAliasSF3)->F3_VALICM
					RUR->(MsUnLock ())
					//
				EndIf                                      
	        Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Entradas no municipio de origem do estabelecimento  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	DbSelectArea("SA2")
		SA2->(DbSetOrder (1))
		If (SA2->(DbSeek (xFilial ("SA2")+(cAliasSF3)->(F3_CLIEFOR+F3_LOJA))))
			If (Substr((cAliasSF3)->F3_CFO,1,1)<"5")
				If (Alltrim(SM0->M0_CODMUN)==SA2->A2_COD_MUN)
					If (nPos<>0)
						If (MUN->(MsSeek (Val (aCfop[nPos][Iif ((Len ((cAliasSF3)->F3_CFO)==3),2 , 3)]))))
							MUN->(RecLock ("MUN", .F.))
							MUN->MC_VLCONT	+=	(cAliasSF3)->F3_VALCONT
							MUN->(MsUnLock ())
						Else
							cCfop	:=	aCfop[nPos][Iif ((Len ((cAliasSF3)->F3_CFO)==3),2 , 3)]
							cMacro	+=	AllTrim (aCfop[nPos][Iif ((Len ((cAliasSF3)->F3_CFO)==3),2 , 3)])+"/"
							//
							MUN->(RecLock ("MUN", .T.))
							MUN->MC_NRCFOP	:=	Val (cCfop)
							MUN->MC_VLCONT	:=	(cAliasSF3)->F3_VALCONT
							MUN->(MsUnLock ())	
						EndIf
					Endif	
		    	Endif     
	        Endif
	    Endif
		(cAliasSF3)->(DbSkip ())
   	EndDo
	//
	RetIndex ("SF3")
	Ferase (cArqSF3+(cAliasSF3)->(OrdBagExt ()))
	(cAliasSF3)->(DbClearFilter ())             
	//Se o mes for o mesmo do parametro, seleciona as informacoes do ano anterior
	//para gerar o registro MG-I conforme Legislacao abaixo:
	//Com base no Paragrafo 4, artigo 769-B do Regulamento de ICMS do Estado do Espirito Santo 
	//no mes de abril de cada ano, o contribuinte devera entregar a DIEF com as operacoes e prestacoes
	//interestaduais do ano imediatamente anterior
	If (Substr(Dtos(_aTotal[001]),5,2)) == cMesGI
		GerF3AnoAn(_aTotal[001],_aTotal[002],cMesGI)
		Ferase(cArqSF3+(cAliasSF3)->(OrdBagExt()))
		(cAliasSF3)->(DbClearFilter())
	Endif     	  			
	RestArea (aArea)
Return (cArqRg5)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³sfCafe    ³ Autor ³Andressa Fagundes      ³ Data ³09.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta o registro B de movimento de cafe cru.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet - .T.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function sfCafe ()
	Local	aArea		:=	GetArea ()
	Local	cArqCafe	:=	""
	Local	aStruCafe	:=	{}
	Local	cArqCert	:=	""
	Local	aStruCert	:=	{}
	Local	cArqSf1		:=	""
	Local	cArqSf2		:=	""
	Local	lRet		:=	.T.
	Local	lNrcSicE	:=	Iif (GetNewPar ("MV_NCSICE", "0")=="0", .F., .T.)
	Local	lExistSd1	:=	.F.
	Local	lExistSd2	:=	.F.
	Local	cCafMunEst	:=	""
	Local	cCafInsc	:=	""
    Local	cCafInscA	:=	""	
	Local   cMvLiga     := SB1->(FieldPos(GetNewPar("MV_LIGA","")))
	Local   nIERegB 	:= SF1->(FieldPos(GetNewPar("MV_IEDFES","")))
	Local 	nUFRegB 	:= SF1->(FieldPos(GetNewPar("MV_UFDFES","")))
	LOCAL	nTipoOper	:= 0
	Local   nPos        := 0
	Local   cCfopsC     := SuperGetMV("MV_CAFCF",,"")
	Local	cLiga		:= ""
	Local	lMCdiefes	:=	Iif(GetNewPar("MV_MCDFES","")=="", .F., .T.)
	Local	lPCdiefes	:=	Iif(GetNewPar("MV_PCDFES","")=="", .F., .T.)	
	Local	lMFdiefes	:=	Iif(GetNewPar("MV_MFDFES","")=="", .F., .T.)
	Local	lPFdiefes	:=	Iif(GetNewPar("MV_PFDFES","")=="", .F., .T.)	
    Local   lGeraCafe   :=  Iif(Substr(_aTotal[98][1][3],1,1)=="0",.T.,.F.)    
    Local	lCFOP		:=	.F.

	//
	#IFDEF TOP
		Local	aStruSF1	:=	{} 
		Local	aStruSF2	:=	{}
		Local	nX			:=	0
	#ENDIF
	If (lNrcSicE)
		If (SD1->(FieldPos (GetNewPar ("MV_NCSICE","")))>0)
			lExistSd1	:=	.T.
		Else
  	   	    If lGeraCafe
  	   	       Help (" ", 1, "CAMPO",,STR0001, 3, 0)	//"Campo cadastrado no parametro [MV_NCSICE] nao existe!"
		    Endif
		EndIf
	Else
		If lGeraCafe
		   Help (" ", 1, "PARAM",,STR0002, 3, 0)	//"Parametro [MV_NCSICE] nao encontrado!"
	    Endif
	EndIf
	aAdd (aStruCafe, {"AF_NRNOTA",	"C",	TamSX3("F2_DOC")[1],	000})
	aAdd (aStruCafe, {"AF_DTNOTA",	"N",	008,	000})
	aAdd (aStruCafe, {"AF_INSCRI",	"C",	015,	000})
	aAdd (aStruCafe, {"AF_CDLOCAL",	"C",	005,	000})
	aAdd (aStruCafe, {"AF_QTSACAS",	"N",	TamSX3("D2_QUANT")[1],	000})
	aAdd (aStruCafe, {"AF_SGLIGA",	"C",	002,	000})
	aAdd (aStruCafe, {"AF_TPCAFE",	"C",	003,	000})
	aAdd (aStruCafe, {"AF_CDCFOP",	"C",	004,	000})
	aAdd (aStruCafe, {"AF_STMOVI",	"C",	002,	000})
	aAdd (aStruCafe, {"AF_CDCONT",	"N",	002,	000})
	aAdd (aStruCafe, {"AF_NRCSIC",	"C",	017,	000})
	aAdd (aStruCafe, {"AF_VLICMSR",	"N",	011,	000})
	aAdd (aStruCafe, {"AF_INSCRI2",	"C",	015,	000})
	aAdd (aStruCafe, {"AF_CDUF",	"C",	002,	000})
	aAdd (aStruCafe, {"AF_PROD",	"C",	015,	000})
	//
	cArqCafe	:=	CriaTrab (aStruCafe, .T.)
	DbUseArea (.T., __LocalDriver, cArqCafe, "CAF")
	IndRegua ("CAF", cArqCafe, "AF_NRNOTA+AF_STMOVI+AF_SGLIGA+AF_INSCRI+AF_PROD+AF_CDCFOP")

	//
	aAdd (aStruCert, {"ER_NRNOTA",	"C",	TamSX3("F2_DOC")[1],	000})
	aAdd (aStruCert, {"ER_STMOVI",	"C",	002,	000})
	aAdd (aStruCert, {"ER_NRCERT",	"N",	007,	000})
	aAdd (aStruCert, {"ER_VLCERT",	"N",	011,	002})
	aAdd (aStruCert, {"ER_INSCRI",	"C",	015,	000})
	aAdd (aStruCert, {"ER_SGLIGA",	"C",	002,	000})
	//
	cArqCert	:=	CriaTrab (aStruCert, .T.)
	DbUseArea (.T., __LocalDriver, cArqCert, "CER")
	IndRegua ("CER", cArqCert, "ER_NRNOTA+ER_STMOVI+ER_SGLIGA+ER_INSCRI")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processando notas fiscais de entrada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasSF1	:=	"SF1" 
	DbSelectArea ("SF1")
	#IFDEF TOP
	    If TcSrvType()<>"AS/400"
	    	
	    	aStruSF1  :=	SF1->(DbStruct ())
	    	cAliasSF1 :=	GetNextAlias()

			cQuery    := "SELECT * "
			cQuery    += "FROM " + RetSqlName("SF1") + " SF1 "
			cQuery    += "WHERE "
			cQuery    += "F1_FILIAL = '" + xFilial("SF1") + "' AND "
			cQuery    += "F1_DTDIGIT >= '" + Dtos(_aTotal[001]) + "' AND "
			cQuery    += "F1_DTDIGIT <= '" + Dtos(_aTotal[002]) + "' "
			cQuery    += "AND D_E_L_E_T_ = '' "			
			cQuery    += "ORDER BY F1_DTDIGIT,F1_SERIE,F1_DOC"
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1,.T.,.T.) 
			For nX := 1 To len(aStruSF1)
				If aStruSF1[nX][2] <> "C" 
					TcSetField(cAliasSF1,aStruSF1[nX][1],aStruSF1[nX][2],aStruSF1[nX][3],aStruSF1[nX][4])
				EndIf
			Next nX
		Else
    #ENDIF
	DbSelectArea ("SF1")
	cArqSf1	:=	CriaTrab (Nil, .F.)
		IndRegua ("SF1", cArqSf1, (cAliasSF1)->(IndexKey ()),, 'SF1->F1_FILIAL=="'+xFilial ("SF1")+'" .And. DToS (SF1->F1_DTDIGIT)>="'+DToS (_aTotal[001])+'" .And. DToS (SF1->F1_DTDIGIT)<="'+DToS (_aTotal[002])+'"')
		(cAliasSF1)->(DbGoTop ())
	#IFDEF TOP
		EndIf
	#ENDIF	
	//
	Do While !(cAliasSF1)->(Eof ())
		SD1->(DbSetOrder (1))
		//
		If (SD1->(MsSeek (xFilial ("SD1")+(cAliasSF1)->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))))
			Do While !(SD1->(Eof ())) .And.;
				(SD1->D1_DOC==(cAliasSF1)->F1_DOC) .And. (SD1->D1_SERIE==(cAliasSF1)->F1_SERIE) .And.;
				(SD1->D1_FORNECE==(cAliasSF1)->F1_FORNECE) .And. (SD1->D1_LOJA==(cAliasSF1)->F1_LOJA)
				//
				If (SD1->D1_TIPO$"DB")
					SA1->(DbGoTop ())
					SA1->(MsSeek (xFilial ("SA1")+(cAliasSF1)->(F1_FORNECE+F1_LOJA)))
					//

					If nUFRegB > 0
						cCafMunEst	:=	Iif ((SubStr (AllTrim (SD1->D1_CF), 1, 1)=="1" .And. AllTrim (SA1->A1_COD_MUN)<> ""), AllTrim (SA1->A1_COD_MUN), (cAliasSF1)->&(GetNewPar("MV_UFDFES")))
					Else
						cCafMunEst	:=	Iif ((SubStr (AllTrim (SD1->D1_CF), 1, 1)=="1"), AllTrim (SA1->A1_COD_MUN), AllTrim (SA1->A1_EST))
					Endif
					
					If nIERegB > 0
						cCafInscA	:= 	(cAliasSF1)->&(GetNewPar("MV_IEDFES"))
					EndIf
						
						cCafInsc	:=	Substr(SA1->A1_INSCR,1,15)
						
					Do Case
						Case SubStr(AllTrim(SD1->D1_CF),1,1)=="1"
							nTipoOper  := 1
							If (lMCdiefes) 
								If (SA1->(FieldPos(GetNewPar("MV_MCDFES","")))>0)
									cCafMunEst := SA1->&(GetNewPar("MV_MCDFES"))
								Else
									If lGeraCafe
									   Help (" ", 1, "CAMPO",,STR0005, 3, 0)	//"Campo cadastrado no parametro [MV_MDIEFES] nao existe!"
								    Endif
								EndIf
							Else
								If lGeraCafe
								   Help (" ", 1, "PARAM",,STR0006, 3, 0)	//"Parametro [MV_MDIEFES] nao encontrado!"
							    Endif
							EndIf
	
						Case SubStr(AllTrim(SD1->D1_CF),1,1)=="2"
							nTipoOper:= 2 
							cCafMunEst := SA1->A1_EST  //Recebe o estado do cliente

						Case SubStr(AllTrim(SD1->D1_CF),1,1)=="3"
							nTipoOper:= 3
							If (lPCdiefes)
								If (SA1->(FieldPos(GetNewPar("MV_PCDFES","")))>0)
									cCafMunEst := SA1->&(GetNewPar("MV_PCDFES"))
								Else
									Help (" ", 1, "CAMPO",,STR0007, 3, 0)	//"Campo cadastrado no parametro [MV_PDIEFES] nao existe!"
								EndIf
							Else
								Help (" ", 1, "PARAM",,STR0008, 3, 0)	//"Parametro [MV_PDIEFES] nao encontrado!"
							EndIf
						OtherWise
							nTipoOper:= 0
							lCFOP := .T.
					EndCase

				Else							

					SA2->(DbGoTop ())
					SA2->(MsSeek(xFilial ("SA2")+(cAliasSF1)->(F1_FORNECE+F1_LOJA)))
					//
					If nUFRegB > 0
						cCafMunEst	:=	Iif ((SubStr (AllTrim (SD1->D1_CF), 1, 1)=="1" .And. AllTrim (SA2->A2_COD_MUN) <> ""), AllTrim (SA2->A2_COD_MUN), (cAliasSF1)->&(GetNewPar("MV_UFDFES")))						
					Else
						cCafMunEst	:=	Iif ((SubStr (AllTrim (SD1->D1_CF), 1, 1)=="1"), AllTrim (SA2->A2_COD_MUN), AllTrim (SA2->A2_EST))
					EndIf
							
					If nIERegB > 0
						cCafInscA	:= 	Substr((cAliasSF1)->&(GetNewPar("MV_IEDFES")),1,15)
					EndIF
					
						cCafInsc	:=	Substr(SA2->A2_INSCR,1,15)		
					
					Do Case
						Case SubStr(AllTrim(SD1->D1_CF),1,1)=="1"
							nTipoOper  := 1
							If (lMFdiefes) 
								If (SA2->(FieldPos(GetNewPar("MV_MFDFES","")))>0)
									cCafMunEst := SA2->&(GetNewPar("MV_MFDFES"))
								Else
								    If lGeraCafe   
										Help (" ", 1, "CAMPO",,STR0005, 3, 0)	//"Campo cadastrado no parametro [MV_MDIEFES] nao existe!"
								    Endif
								EndIf
							Else
								If lGeraCafe
								   Help (" ", 1, "PARAM",,STR0006, 3, 0)	//"Parametro [MV_MDIEFES] nao encontrado!"
							    Endif
							EndIf
	
						Case SubStr(AllTrim(SD1->D1_CF),1,1)=="2"
							nTipoOper:= 2 
							cCafMunEst := SA2->A2_EST  //Recebe o estado do cliente/fornecedor

						Case SubStr(AllTrim(SD1->D1_CF),1,1)=="3"
							nTipoOper:= 3
							If (lPFdiefes)
								If (SA2->(FieldPos(GetNewPar("MV_PFDFES","")))>0)  .And. nTipoOper == 3
									cCafMunEst := SA2->&(GetNewPar("MV_PFDFES"))
								Else
									Help (" ", 1, "CAMPO",,STR0007, 3, 0)	//"Campo cadastrado no parametro [MV_PDIEFES] nao existe!"
								EndIf
							Else
								Help (" ", 1, "PARAM",,STR0008, 3, 0)	//"Parametro [MV_PDIEFES] nao encontrado!"
							EndIf
						OtherWise
							nTipoOper:= 0
							lCFOP := .T.
					EndCase

				EndIf
        		//
				SB1->(DbSetOrder (1))
				If (SB1->(MsSeek (xFilial ("SB1")+SD1->D1_COD)) .And.;
					(Alltrim(SB1->B1_GRUPO)>=Alltrim(_aTotal[062])) .And. (Alltrim(SB1->B1_GRUPO)<=Alltrim(_aTotal[063])) .And.;
							(SubStr (AllTrim (SD1->D1_CF), 1, 1)<>"3") .And. Iif(!Empty(cCfopsC),AllTrim(SD1->D1_CF)$cCfopsC,.T.))
					
					cLiga := Iif(cMvLiga >0,SB1->(FieldGet(cMvLiga)),Space(02))

					DbSelectArea("CAF")
					If DbSeek((cAliasSF1)->F1_DOC + "E " + cLiga + cCafInsc + SD1->D1_COD+LEFT(SD1->D1_CF,4))
						CAF->(RecLock ("CAF", .F.))
							CAF->AF_QTSACAS	+=	SD1->D1_QUANT
							CAF->AF_VLICMSR	+=	SD1->D1_VALICM
						CAF->(MsUnLock ())
					Else
						CAF->(RecLock ("CAF", .T.))
							CAF->AF_NRNOTA	:=	(cAliasSF1)->F1_DOC
							CAF->AF_DTNOTA	:=	Val (DToS ((cAliasSF1)->F1_EMISSAO))
							CAF->AF_INSCRI	:=	cCafInsc
							CAF->AF_CDLOCAL	:=	AllTrim(cCafMunEst)
							CAF->AF_QTSACAS	:=	SD1->D1_QUANT
							CAF->AF_SGLIGA	:= 	cLiga
							CAF->AF_TPCAFE	:=	SubStr ((cAliasSF1)->F1_ESPECIE, 1, 3)
							CAF->AF_CDCFOP	:=	Iif(Len (AllTrim(SD1->D1_CF))==3,SubStr(SD1->D1_CF,1,1)+"."+SubStr(SD1->D1_CF,2,2),AllTrim (SD1->D1_CF))
							CAF->AF_STMOVI	:=	"E"						 
						    CAF->AF_INSCRI2	:=  cCafInscA	  
						    nPos:=aScan (_aTotal[100], {|x| AllTrim(SD1->D1_CF)$x})
			                       If nPos == 03
			       					  CAF->AF_CDCONT := 01	
			                       EndIf
			                       If npos == 04
			                          CAF->AF_CDCONT :=	02
			                       EndIf
			                       If npos == 05
							          CAF->AF_CDCONT := 03
								   EndIf
								   If npos == 06
			        			      CAF->AF_CDCONT := 04
			                       EndIf
			                       If npos == 07
			                          CAF->AF_CDCONT := 05
			                       EndIf
			                       If npos == 08
			                          CAF->AF_CDCONT :=	06
			                       EndIf
			                       If npos == 09
			                          CAF->AF_CDCONT := 07
			                       EndIf
			                       If npos == 10
			                          CAF->AF_CDCONT := 08
			                       EndIf
			                       If npos == 11
			                          CAF->AF_CDCONT := 09
			                       EndIf
			                       If npos == 12
			                          CAF->AF_CDCONT :=	10
			                       EndIf
			                       If npos == 13
			                          CAF->AF_CDCONT := 11
			                       EndIf
			                       If npos == 14
			                          CAF->AF_CDCONT :=	12
			                       EndIf
			                       If nPos == 0
			                          CAF->AF_CDCONT := nTipoOper                        			                       
							       EndIf
			                  Exit
							CAF->AF_NRCSIC	:=	Iif ((lNrcSicE), Iif ((lExistSd1), &("SD1->"+GetNewPar ("MV_NCSICE")), ""), "")
							CAF->AF_VLICMSR	:=	SD1->D1_VALICM
							CAF->AF_CDUF	:=	SM0->M0_ESTENT
							CAF->AF_PROD	:=	SD1->D1_COD
						CAF->(MsUnLock ())
						//
						CER->(RecLock ("CER", .T.))
							CER->ER_NRNOTA	:=	" "+(cAliasSF1)->F1_DOC
							CER->ER_STMOVI	:=	"E"
							CER->ER_NRCERT	:=	0
							CER->ER_VLCERT	:=	0       
							CER->ER_INSCRI	:=	cCafInsc
							CER->ER_SGLIGA	:= 	cLiga							
						CER->(MsUnLock ())
					EndIf
	            EndIf
	            SD1->(DbSkip ())
	    	EndDo
	    EndIf
        (cAliasSF1)->(DbSkip ())
	EndDo	
	//
	RetIndex ("SF1")
	Ferase (cArqSf1+(cAliasSF1)->(OrdBagExt ()))
	(cAliasSF1)->(DbClearFilter ())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processando notas fiscais de saida ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasSF2	:=	"SF2" 
	DbSelectArea ("SF2")
	#IFDEF TOP
	    If TcSrvType()<>"AS/400"
	    	
	    	aStruSF2  :=	SF2->(DbStruct ())
	    	cAliasSF2 :=	GetNextAlias()

			cQuery    := "SELECT * "
			cQuery    += "FROM " + RetSqlName("SF2") + " SF2 "
			cQuery    += "WHERE "
			cQuery    += "F2_FILIAL = '" + xFilial("SF2") + "' AND "
			cQuery    += "F2_EMISSAO >= '" + Dtos(_aTotal[001]) + "' AND "
			cQuery    += "F2_EMISSAO<= '" + Dtos(_aTotal[002]) + "' "
			cQuery    += "AND D_E_L_E_T_ = '' "			
			cQuery    += "ORDER BY F2_EMISSAO,F2_SERIE,F2_DOC"
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.T.,.T.) 
			For nX := 1 To len(aStruSF2)
				If aStruSF2[nX][2] <> "C" 
					TcSetField(cAliasSF2,aStruSF2[nX][1],aStruSF2[nX][2],aStruSF2[nX][3],aStruSF2[nX][4])
				EndIf
			Next nX
		Else
    #ENDIF
	DbSelectArea ("SF2")
	cArqSf2	:=	CriaTrab (Nil, .F.)
		IndRegua ("SF2", cArqSf2, (cAliasSF2)->(IndexKey ()),, 'SF2->F2_FILIAL=="'+xFilial ("SF2")+'" .And. DToS (SF2->F2_EMISSAO)>="'+DToS (_aTotal[001])+'" .And. DToS (SF2->F2_EMISSAO)<="'+DToS (_aTotal[002])+'"')
		(cAliasSF2)->(DbGoTop ())
	#IFDEF TOP
		EndIf
	#ENDIF		
	//
	Do While !((cAliasSF2)->(Eof ()))
		SD2->(DbSetOrder (3))
		//
		If (SD2->(MsSeek (xFilial ("SD2")+(cAliasSF2)->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))))
			Do While !(SD2->(Eof ())) .And.;
				(SD2->D2_DOC==(cAliasSF2)->F2_DOC) .And. (SD2->D2_SERIE==(cAliasSF2)->F2_SERIE) .And.;
				(SD2->D2_CLIENTE==(cAliasSF2)->F2_CLIENTE) .And. (SD2->D2_LOJA==(cAliasSF2)->F2_LOJA)
				//
				If (SD2->D2_TIPO$"DB")
					SA2->(DbGoTop ())
					SA2->(MsSeek (xFilial ("SA2")+(cAliasSF2)->(F2_CLIENTE+F2_LOJA)))

					Do Case
						Case SubStr(AllTrim(SD2->D2_CF),1,1)=="5"
							nTipoOper  := 1
							If (lMFdiefes) 
								If (SA2->(FieldPos(GetNewPar("MV_MFDFES","")))>0)
									cCafMunEst := SA2->&(GetNewPar("MV_MFDFES"))
								Else
									If lGeraCafe
									   Help (" ", 1, "CAMPO",,STR0005, 3, 0)	//"Campo cadastrado no parametro [MV_MDIEFES] nao existe!"
								    Endif
								EndIf
							Else
								If lGeraCafe
								   Help (" ", 1, "PARAM",,STR0006, 3, 0)	//"Parametro [MV_MDIEFES] nao encontrado!"
							    Endif
							EndIf
	
						Case SubStr(AllTrim(SD2->D2_CF),1,1)=="6"
							nTipoOper:= 2 
							cCafMunEst := SA2->A2_EST  //Recebe o estado do cliente/fornecedor

						Case SubStr(AllTrim(SD2->D2_CF),1,1)=="7"
							nTipoOper:= 3
							If (lPFdiefes)
								If (SA2->(FieldPos (GetNewPar ("MV_PFDFES","")))>0)  .And. nTipoOper == 3
									cCafMunEst := SA2->&(GetNewPar("MV_PFDFES"))
								Else
									Help (" ", 1, "CAMPO",,STR0007, 3, 0)	//"Campo cadastrado no parametro [MV_PDIEFES] nao existe!"
								EndIf
							Else
								Help (" ", 1, "PARAM",,STR0008, 3, 0)	//"Parametro [MV_PDIEFES] nao encontrado!"
							EndIf
						OtherWise
							nTipoOper:= 0
							lCFOP := .T.
					EndCase

					cCafInsc	:=	Iif(SubStr(SD2->D2_CF, 1, 1)=="7", "", Substr(SA1->A1_INSCR,1,15))
				Else
					SA1->(DbGoTop ())
					SA1->(MsSeek (xFilial ("SA1")+(cAliasSF2)->(F2_CLIENTE+F2_LOJA)))
	
					Do Case
						Case SubStr(AllTrim(SD2->D2_CF),1,1)=="5"
							nTipoOper  := 1
							If (lMCdiefes) 
								If (SA1->(FieldPos(GetNewPar("MV_MCDFES","")))>0)
									cCafMunEst := SA1->&(GetNewPar("MV_MCDFES"))
								Else
								    IF lGeraCafe
								       Help (" ", 1, "CAMPO",,STR0005, 3, 0)	//"Campo cadastrado no parametro [MV_MDIEFES] nao existe!"
								    Endif
								EndIf
							Else
								If lGeraCafe
								   Help (" ", 1, "PARAM",,STR0006, 3, 0)	//"Parametro [MV_MDIEFES] nao encontrado!"
							    Endif
							EndIf
	
						Case SubStr(AllTrim(SD2->D2_CF),1,1)=="6"
							nTipoOper:= 2 
							cCafMunEst := SA1->A1_EST  //Recebe o estado do cliente

						Case SubStr(AllTrim(SD2->D2_CF),1,1)=="7"
							nTipoOper:= 3
							If (lPCdiefes)
								If (SA1->(FieldPos(GetNewPar("MV_PCDFES","")))>0)
									cCafMunEst := SA1->&(GetNewPar("MV_PCDFES"))
								Else
									Help (" ", 1, "CAMPO",,STR0007, 3, 0)	//"Campo cadastrado no parametro [MV_PDIEFES] nao existe!"
								EndIf
							Else
								Help (" ", 1, "PARAM",,STR0008, 3, 0)	//"Parametro [MV_PDIEFES] nao encontrado!"
							EndIf
						OtherWise
							nTipoOper:= 0
							lCFOP := .T.
					EndCase

					cCafInsc	:=	Iif(SubStr(SD2->D2_CF, 1, 1)=="7", "", Substr(SA1->A1_INSCR,1,15))
				Endif						
				
				SB1->(DbSetOrder (1))
				If (SB1->(MsSeek (xFilial("SB1")+SD2->D2_COD)) .And.;
					(Alltrim(SB1->B1_GRUPO)>=Alltrim(_aTotal[062])) .And. (Alltrim(SB1->B1_GRUPO)<=Alltrim(_aTotal[063]));
				   		.And. Iif(!Empty(cCfopsC),AllTrim(SD2->D2_CF)$cCfopsC,.T.))
					
					cLiga := Iif(cMvLiga >0,SB1->(FieldGet(cMvLiga)),Space(02))
					
					DbSelectArea("CAF")
					If DbSeek((cAliasSF2)->F2_DOC + Iif (SubStr (SD2->D2_CF, 1, 1)=="7", "EX", "S ") + cLiga + cCafInsc + SD2->D2_COD+SD2->D2_CF+LEFT(SD2->D2_CF,4))
						CAF->(RecLock ("CAF", .F.))
							CAF->AF_QTSACAS	+=	SD2->D2_QUANT
							CAF->AF_VLICMSR	+=	SD2->D2_VALICM
						CAF->(MsUnLock ())
					Else
						CAF->(RecLock ("CAF", .T.))
							CAF->AF_NRNOTA	:=	(cAliasSF2)->F2_DOC
							CAF->AF_DTNOTA	:=	Val (DToS ((cAliasSF2)->F2_EMISSAO))
							CAF->AF_INSCRI	:=	cCafInsc
							CAF->AF_CDLOCAL	:=	AllTrim (cCafMunEst)
							CAF->AF_QTSACAS	:=	SD2->D2_QUANT
							CAF->AF_SGLIGA	:= 	cLiga
							CAF->AF_TPCAFE	:=	SubStr ((cAliasSF2)->F2_ESPECIE, 1, 3)
							CAF->AF_CDCFOP	:=	Iif(Len(AllTrim(SD2->D2_CF))==3, SubStr(SD2->D2_CF,1,1)+"."+SubStr(SD2->D2_CF,2,2),AllTrim (SD2->D2_CF))
							CAF->AF_STMOVI	:=	Iif(SubStr(SD2->D2_CF, 1, 1)=="7", "EX", "S ")						
		   					CAF->AF_INSCRI2	:=	cCafInscA  
		   					  nPos:=aScan (_aTotal[100], {|x| AllTrim(SD1->D1_CF)$x})
			                       If nPos == 03
			                    	CAF->AF_CDCONT := 01	
			                       EndIf
			                       If npos == 04
			                          CAF->AF_CDCONT :=	02
			                       EndIf
			                       If npos == 05
							          CAF->AF_CDCONT := 03
								   EndIf
								   If npos == 06
			        			      CAF->AF_CDCONT := 04
			                       EndIf
			                       If npos == 07
			                          CAF->AF_CDCONT := 05
			                       EndIf
			                       If npos == 08
			                          CAF->AF_CDCONT :=	06
			                       EndIf
			                       If npos == 09
			                          CAF->AF_CDCONT := 07
			                       EndIf
			                       If npos == 10
			                          CAF->AF_CDCONT := 08
			                       EndIf
			                       If npos == 11
			                          CAF->AF_CDCONT := 09
			                       EndIf
			                       If npos == 12
			                          CAF->AF_CDCONT :=	10
			                       EndIf
			                       If npos == 13
			                          CAF->AF_CDCONT := 11
			                       EndIf
			                       If npos == 14
			                          CAF->AF_CDCONT :=	12
			                       EndIf
			                       If nPos == 0
			                       CAF->AF_CDCONT := nTipoOper                        			                       
							       EndIf
			                  Exit                      						
							CAF->AF_NRCSIC	:=	""
							CAF->AF_VLICMSR	:=	SD2->D2_VALICM
							CAF->AF_CDUF	:=	SM0->M0_ESTENT
							CAF->AF_PROD	:=	SD2->D2_COD
						CAF->(MsUnLock ())
						//
						CER->(RecLock ("CER", .T.))
							CER->ER_NRNOTA	:=	" "+(cAliasSF2)->F2_DOC
							CER->ER_STMOVI	:=	Iif (SubStr (SD2->D2_CF, 1, 1)=="7", "EX", "S")
							CER->ER_NRCERT	:=	0
							CER->ER_VLCERT	:=	0       
							CER->ER_INSCRI	:=	cCafInsc                                    
							CER->ER_SGLIGA	:= 	cLiga
						CER->(MsUnLock ())
					EndIf
	            EndIf
	            SD2->(DbSkip ())
	    	EndDo
	    EndIf
        (cAliasSF2)->(DbSkip ())
	EndDo	
	//
	If lCFOP
		MsgInfo(STR0009) 	//"Código de Operação Inválida.")
	EndIf
	
	RetIndex ("SF2")
	Ferase (cArqSf2+(cAliasSF2)->(OrdBagExt ()))
	(cAliasSF2)->(DbClearFilter ())
	RestArea (aArea)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GerF3AnoAn³ Autor ³Mauro A. Goncalves     ³ Data ³06.06.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera o registro GIM com dados do ano anterior ao processado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dDtIni = Data Incial										  ³±±
±±³          ³dDtFim = Data Final  										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerF3AnoAn(dDtIni,dDtFim,cMesGI)

Local dDtAntIni	:= CToD(StrZero(Day(dDtIni))+"/"+StrZero(Month(dDtIni))+"/"+StrZero(Year(dDtIni)-1))
Local dDtAntFim   := CToD(StrZero(Day(dDtFim))+"/"+StrZero(Month(dDtFim))+"/"+StrZero(Year(dDtFim)-1))
Local	cSaida		:= "S"
Local	cEntr			:= "E"	 
Local nX				:= 0   
Local	aUF			:=	{}
Default cMesGI := GetNewPar("MV_MGICMS","") 

// Caso seja o Mes 4 Deve gerar o ano Posterior inteiro
If "4" $ cMesGI 
	dDtAntIni	:= CtoD("01/01/"+StrZero(Year(dDtIni)-1))
	dDtAntFim   := CtoD("31/12/"+StrZero(Year(dDtFim)-1))
EndIf

aAdd(aUF,"AC")
aAdd(aUF,"AL")
aAdd(aUF,"AM")
aAdd(aUF,"AP")
aAdd(aUF,"BA")
aAdd(aUF,"CE")
aAdd(aUF,"DF")
aAdd(aUF,"ES")
aAdd(aUF,"GO")
aAdd(aUF,"MA")
aAdd(aUF,"MS")
aAdd(aUF,"MT")
aAdd(aUF,"MG")
aAdd(aUF,"PA")
aAdd(aUF,"PB")
aAdd(aUF,"PR")
aAdd(aUF,"PE")
aAdd(aUF,"PI")
aAdd(aUF,"RN")
aAdd(aUF,"RS")
aAdd(aUF,"RJ")
aAdd(aUF,"RO")
aAdd(aUF,"RR")
aAdd(aUF,"SC")
aAdd(aUF,"SP")
aAdd(aUF,"SE")
aAdd(aUF,"TO")
aSort(aUF,,,{|x,y| x<y})

DbSelectArea ("SF3")
#IFDEF TOP
    If TcSrvType()<>"AS/400"	    	
    	aStruSF3  :=	SF3->(DbStruct())    	
    	cAliasSF3 :=	GetNextAlias()

		cQuery    := "SELECT SF3.*,A1_INSCR,A2_INSCR "
		cQuery    += "FROM " + RetSqlName("SF3") + " SF3 "
		cQuery    += "LEFT JOIN " + RetSqlName( "SA1" ) + " SA1 ON(SA1.A1_FILIAL='" + xFilial( "SA1" ) + "' AND SA1.A1_COD=SF3.F3_CLIEFOR AND SA1.A1_LOJA=SF3.F3_LOJA AND SA1.D_E_L_E_T_=' ') "
    	cQuery    += "LEFT JOIN " + RetSqlName( "SA2" ) + " SA2 ON(SA2.A2_FILIAL='" + xFilial( "SA2" ) + "' AND SA2.A2_COD=SF3.F3_CLIEFOR AND SA2.A2_LOJA=SF3.F3_LOJA AND SA2.D_E_L_E_T_=' ') "
		cQuery    += "WHERE "
		cQuery    += "F3_FILIAL = '" + xFilial("SF3") + "' AND "
		cQuery    += "F3_ENTRADA >= '" + Dtos(dDtAntIni) + "' AND "
		cQuery    += "F3_ENTRADA <= '" + Dtos(dDtAntFim) + "' AND "
		cQuery    += "F3_TIPO <> 'S' AND F3_DTCANC='' AND "
		cQuery    += "SF3.D_E_L_E_T_ = ' ' "
		cQuery    += "ORDER BY F3_ENTRADA,F3_SERIE,F3_NFISCAL,F3_TIPO,F3_CLIEFOR,F3_LOJA"
						
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.) 
		For nX := 1 To len(aStruSF3)
			If aStruSF3[nX][2] <> "C" 
				TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
			EndIf
		Next nX
	Else
#ENDIF
	cArqSf3	:=	CriaTrab(Nil,.F.)
	IndRegua ("SF3", cArqSf3, (cAliasSF3)->(IndexKey()),, 'SF3->F3_FILIAL=="'+xFilial("SF3")+'" .And. DToS (SF3->F3_ENTRADA)>="'+DToS (_aTotal[001])+'" .And. DToS (SF3->F3_ENTRADA)<="'+DToS(_aTotal[002])+'" .And. SF3->F3_TIPO<>"S" .And. Empty(SF3->F3_DTCANC)')
	(cAliasSF3)->(DbGoTop())	
#IFDEF TOP
	EndIf
#ENDIF                 
	                           
While !(cAliasSF3)->(EOF())
	//Saida de mercadorias interestaduais
	If SubStr((cAliasSF3)->F3_CFO,1,1) == "6"
		If (GIM->(MsSeek(Alltrim((cAliasSF3)->F3_ESTADO)+cSaida)))
	    	RecLock("GIM",.F.)
			If SubStr((cAliasSF3)->F3_CFO,2,2) == "25" .OR. SubStr((cAliasSF3)->F3_CFO,2,2) == "65" 
				GIM->GI_VLPTEN	+= (cAliasSF3)->F3_VALCONT
			EndIf
			If (EMPTY((cAliasSF3)->F3_TIPO)  .And. !Empty((cAliasSF3)->A1_INSCR) .And. !('ISENT' $ (cAliasSF3)->A1_INSCR)) .OR. ;
				((cAliasSF3)->F3_TIPO=='D'  .And. !Empty((cAliasSF3)->A2_INSCR) .And. !('ISENT' $ (cAliasSF3)->A2_INSCR))
				GIM->GI_VLCONT	+= (cAliasSF3)->F3_VALCONT
				GIM->GI_VLBASE	+= (cAliasSF3)->F3_BASEICM
			Else	
				GIM->GI_VLCTNC	+= (cAliasSF3)->F3_VALCONT
				GIM->GI_VLBSNC	+= (cAliasSF3)->F3_BASEICM
         	EndIf
			GIM->GI_VLOUTR		+= (cAliasSF3)->F3_OUTRICM
			GIM->GI_VLOTNC		+= (cAliasSF3)->F3_ICMSRET
			MsUnLock()
		Else
	    	RecLock("GIM",.T.) 
			GIM->GI_UFLOCAL		:= (cAliasSF3)->F3_ESTADO
			GIM->GI_TPMOV		:= "S"			    	
			If (EMPTY((cAliasSF3)->F3_TIPO)  .And. !Empty((cAliasSF3)->A1_INSCR) .And. !('ISENT' $ (cAliasSF3)->A1_INSCR)) .OR. ;
			((cAliasSF3)->F3_TIPO=='D'  .And. !Empty((cAliasSF3)->A2_INSCR) .And. !('ISENT' $ (cAliasSF3)->A2_INSCR))
				GIM->GI_VLCONT	+= (cAliasSF3)->F3_VALCONT
				GIM->GI_VLBASE	+= (cAliasSF3)->F3_BASEICM
			Else	
				GIM->GI_VLCTNC	+= (cAliasSF3)->F3_VALCONT
				GIM->GI_VLBSNC	+= (cAliasSF3)->F3_BASEICM
         	EndIf
			GIM->GI_VLOUTR		:= (cAliasSF3)->F3_OUTRICM
			GIM->GI_VLOTNC		:= (cAliasSF3)->F3_ICMSRET
			MsUnLock()
		Endif	
	endif
	//Entrada de Mercadorias Interestaduais
	If SubStr((cAliasSF3)->F3_CFO,1,1) == "2" //FORA DO ESTADO
		If (GIM->(MsSeek(Alltrim((cAliasSF3)->F3_ESTADO)+cEntr)))
	    	RecLock("GIM",.F.)
			If SubStr((cAliasSF3)->F3_CFO,2,2) == "25" .OR. SubStr((cAliasSF3)->F3_CFO,2,2) == "65" 
				GIM->GI_VLPTEN	+= (cAliasSF3)->F3_VALCONT
			Else	
				GIM->GI_VLCONT	+= (cAliasSF3)->F3_VALCONT
				GIM->GI_VLBASE	+= (cAliasSF3)->F3_BASEICM
           Endif
			GIM->GI_VLOUTR		+= (cAliasSF3)->F3_OUTRICM
			GIM->GI_VLOTNC		+= (cAliasSF3)->F3_OUTRICM    
			MsUnLock()      
		Else
	    	RecLock("GIM",.T.)
			GIM->GI_UFLOCAL	:= (cAliasSF3)->F3_ESTADO
			GIM->GI_TPMOV		:= "E"			    	
			If SubStr((cAliasSF3)->F3_CFO,2,2) == "25" .OR. SubStr((cAliasSF3)->F3_CFO,2,2) == "65" 
				GIM->GI_VLPTEN	:= (cAliasSF3)->F3_VALCONT
			Else	
				GIM->GI_VLCONT	:= (cAliasSF3)->F3_VALCONT
				GIM->GI_VLBASE	:= (cAliasSF3)->F3_BASEICM
           Endif
			GIM->GI_VLOUTR		:= (cAliasSF3)->F3_OUTRICM
			GIM->GI_VLOTNC		:= (cAliasSF3)->F3_OUTRICM
			MsUnLock()
		Endif	        
   Endif       	                           
	(cAliasSF3)->(DbSkip())	
Enddo		
//Necessario pois o validador pede que os campos sejam zerados caso nao tenha movimentacao
For nX:=1 to Len(aUF)
	If !GIM->(MsSeek(Alltrim(aUF[nX]+cSaida)))
    	RecLock("GIM",.T.) 
		GIM->GI_UFLOCAL	:= aUF[nX]
		GIM->GI_TPMOV		:= "S"
	Endif	
	If !GIM->(MsSeek(Alltrim(aUF[nX]+cEntr)))
    	RecLock("GIM",.T.) 
		GIM->GI_UFLOCAL	:= aUF[nX]
		GIM->GI_TPMOV		:= "E"
	Endif	
	MsUnLock()
Next  	
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GerF3AnoAn³ Autor ³Henrique Pereria     	³ Data ³06.06.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o valor de estorno a ser desconsiderado como estorno³±±
±±³ e somado como debito ou credito											 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/

Function EstorDief(aApur,cCodEst)
Local nValor 		:= 0
Local nX			:= 0
Default cCodEst	:= "" 

If !Empty(cCodEst) .And. Len(aApur) > 0
	
	  For nX := 1 to Len(aApur)
 		If aApur[nX][1]$cCodEst .And. SubStr(aApur[nX][4],5,6)>="90"
 		   nValor += aApur[nX][3]
 		EndIf
	  Next		 		

EndIf
Return nValor


/*/
Programa  CredDief
Autor Rafael S.Oliveira
Data 11.01.2018

Descricao:Retorna o valor credito processados nas sub-Apurações dos livros informados no parametro MV_APUSEP
/*/
Function CredDief(dDataAte,nCredPer,nCredAnt,aQuadroB)

Local cApurSep	:= Alltrim(GetNewPar("MV_APUSEP",""))
Local aLivro	:= StrTokArr( cApurSep, "/" )
Local nMes		:= Month(dDataAte)
Local nAno		:= Year(dDataAte)
Local aApICM	:= {}
Local nX		:= 0
Local nValAjus	:= 0

Default aQuadroB := {"",0}

For nX := 1 To len(aLivro)

	aApICM	:=	FisApur("IC",nAno,nMes,3,1,aLivro[nX],.F.,{},1,.F.,"")
	nCredPer +=	Iif (aScan(aApICM, {|a| a[1]=="014"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="014"   })][3],0)
	nCredAnt +=	Iif (aScan(aApICM, {|a| a[1]=="009"   })<>0, aApICM[aScan(aApICM, {|a| a[1]=="009"   })][3],0)
	nValAjus += Iif (aScan(aApICM, {|a| a[1]=="GNR"   })<>0, val(aApICM[aScan(aApICM, {|a| a[1]=="GNR"   })][4]),0)
Next

If nValAjus > 0
	aQuadroB := {"Ajuste Sub-apuração do ICMS",nValAjus}
Endif

Return 