#INCLUDE "HSPAHR03.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR03  º Autor ³ Saude              º Data ³  27/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Solicitacao de produtos.                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHR03(cParam, nQtdImp, lInfPrn, nTpRel, cCodLocFar, aIAtend,cPlanoPart,cNrseqg)
Local nQImp			:= 0
Local cCabUsu		:= ""

Local nLin 			:= 80
Local cSQL			:= ""
Local cGajCodKit	:= ""
Local nForI			:= 0
Local lImprime		:= .F.
Local cItem			:= ""
Local nCont			:= 0

Private cIAtend		:= ""
Private lVerif			:= .F. // Usado para entrar no R3 ou no R4
Private lImpCupom		:= .F. 
Private aSolic		:= {}
Private cDescri		:= ""
Private cUnidade	:= ""     
Private m_pag		:= 1
Private cTamanho	:= "M"
Private nCaracter	:= 18
Private cTitulo		:= STR0001	//"Solicitação de Produtos"
Private nLastKey	:= 0
Private cAlias		:= "GAI"
Private cDesSol		:= ""  
Private cPort		:= ""		// VARIAVEL COM PORTA PARA IMPRESSORA CUPOM
Private cNrSol		:= ""
Private cDoc		:= ""
Private cSeq		:= ""
Private lAbortPrint	:= .F.
Private cCODIMP		:= ""
Private nMaxLin		:= 0		// quantidade maxima de linhas p/ impressao

Default nTpRel		:= 1		//nTpRel := IIf(nTpRel == Nil, 1, nTpRel)
Default cCodLocFar	:= ""		//cCodLocFar := IIf(cCodLocFar == Nil, "", cCodLocFar)
Default lInfPrn		:= .T.
Default aIAtend		:= {}
Default cPlanoPart  :=""
Default cNrseqg     :=""
 
For nForI := 1 to Len(aIAtend)
	cIAtend += aIAtend[nForI][1] + "/"
Next nForI

nMaxLin := HS_MaxLin(cCODIMP)

IF ExistBlock("HSPER03")
	Execblock("HSPER03",.F.,.F.,{cParam, nQtdImp, lInfPrn, nTpRel, cCodLocFar, aIAtend})
	Return(Nil)
EndIf

If cParam == Nil
	If !Pergunte("HSPR03",.T.)
		Return(Nil)
	Else
		lImpCupom	:= IIf(MV_PAR05 == 1, .F., .T.)
		cPort		:= IIf(MV_PAR06 == 1, "LPT1", IIf(MV_PAR06 == 2, "LPT2", IIf(MV_PAR06 == 3, "COM1", IIf(MV_PAR06 == 4, "COM2", "COM3"))))
		cNrSol		:= MV_PAR01  
		cDoc		:= MV_PAR02
		cSeq		:= MV_PAR03
		nTpRel		:= MV_PAR04 
 	Endif
Else
	cNrSol	:= cParam 
	nQtdImp	:= 1
	lInfPrn	:= .T.
Endif

 If FindFunction("TRepInUse") .And. TRepInUse() 
	lVerif := .T.
EndIf

If lVerif
	pergunte("HSPR03",.F.)
	oReport := ReportDef(nTpRel,cPlanoPart,cNrseqg) 
	oReport:PrintDialog()  
	Return(Nil)	
endif
// Localiza Setor informado e pegua as configuracoes da impressora e tipo de empresa //
If !Empty(cCodLocFar) .AND. cParam # Nil
	DbSelectArea("GCS")
	DbSetOrder(1)
	DbSeek(xFilial("GCS") + cCodLocFar)
	lImpCupom	:= IIf(GCS->GCS_IMPCUP == '0', .F., .T.) // 0 = Imp Norm (.F.)  //1= Imp Cupom (True)
	cPort		:= IIf(GCS->GCS_IMPORT == '0', "LPT1", IIf(GCS->GCS_IMPORT == '1', "LPT2", IIf(GCS->GCS_IMPORT == '2', "COM1", IIf(GCS->GCS_IMPORT == '3', "COM2", IIf(GCS->GCS_IMPORT == '4', "COM3", "COM4")))))
EndIf 
 
// Caso a impressao nao seja em cupom declara as variaveis private para relatorio //
If lInfPrn .AND. !lImpCupom
	Private aReturn 	:= {STR0002, 2, STR0003, 1, 4, "LPT1", "", 1}	//"Zebrado"###"Administracao"
	Private cNomProg	:= "HSPAHR03"
	Private cNomeRel	:= "HSPAHR03"
EndIf
 
If (nQtdImp # NIL)
	If nQtdImp <= 0
		Return(Nil)
	EndIf
Else
	nQtdImp := 1
EndIf 
 
If (lInfPrn .AND. !lImpCupom)
	cTitulo		:= cTitulo + " - " + IIf(nTpRel == 1, STR0004, STR0005)		//"Sintético"###"Analítico"
	cNomeRel	:= SetPrint(cAlias, cNomeRel, "HSPR03", @cTitulo, "", "", "", .F., "", .F., cTamanho, Nil, Nil, Nil,)
 
	If nLastKey == 27
		DbClearFilter()
		Return
	Endif
	SetDefault(aReturn, cAlias)
EndIf

cSQL := "SELECT GAI.GAI_SOLICI SOLICI, GAI.GAI_DATSOL DATSOL, GAI.GAI_HORSOL HORSOL, GAI.GAI_REQUIS REQUIS, GCS.GCS_NOMLOC NOMLOC, "
cSQL += "GAI.GAI_CODLOC CODLOC, GAI.GAI_REGATE REGATE, GAJ.GAJ_ITESOL ITESOL, GAJ.GAJ_PROSOL PROSOL, SB1.B1_DESC DESCSOL, "
cSQL += "SB1.B1_UM UMSOL, GAJ.GAJ_PROALT PROALT, SB12.B1_DESC DESCALT, SB12.B1_UM UMALT, GAJ.GAJ_QTDSOL QTDSOL, "
cSQL += "GAJ.GAJ_QTDATE QTDATE, GAJ.GAJ_CODKIT CODKIT, GAF.GAF_DESKIT DESKIT, GAI.GAI_LOGARQ LOGARQ, GAI.GAI_URGENC URGENC, "
cSQL += "GAI.GAI_REGATE REGATE, GAI.GAI_NOMPAC NOMPAC, GAI.GAI_CRMPRE, GCY.GCY_REGGER REGGER, "
cSQL += "GCY.GCY_QUAINT QUAINT, GCY.GCY_LEIINT LEIINT, "
cSQL += IIf(GAI->(FieldPos("GAI_QUARTO"))==0, "GCY.GCY_QUAINT", "GAI.GAI_QUARTO") + " QUARTO, "
cSQL += IIf(GAI->(FieldPos("GAI_QUARTO"))==0, "GCY.GCY_LEIINT", "GAI.GAI_LEITO") + " LEITO, "
cSQL += "GCY.GCY_CODCRM CODCRM, SRA.RA_NOME NOME, GAI.GAI_USUDIS USUDIS, GAI.GAI_USUCON USUCON"
cSQL += "	FROM " + RetSQLName("GAI") +" GAI		JOIN " + RetSQLName("GAJ") + " GAJ 	ON GAJ.GAJ_FILIAL 	= '" + xFilial("GAJ") + "' AND GAJ.GAJ_SOLICI 	= GAI.GAI_SOLICI AND GAJ.D_E_L_E_T_ 		<> '*'"
If !Empty(cIAtend)
	cSQL += "AND GAJ.GAJ_ITESOL IN (" + HS_InSQL(cIAtend) + ")"
Endif
cSQL += "	JOIN " + RetSQLName("SB1") + " SB1 	ON SB1.B1_FILIAL  	= '" + xFilial("SB1") + "' AND SB1.B1_COD	  			= GAJ.GAJ_PROSOL AND SB1.D_E_L_E_T_ 	<> '*'"
cSQL += "	LEFT JOIN " + RetSQLName("GAF") + " GAF 	ON GAF.GAF_FILIAL 	= '" + xFilial("GAF") + "' AND GAF.GAF_CODKIT 	= GAJ.GAJ_CODKIT AND GAF.D_E_L_E_T_ 	<> '*'"
cSQL += "	LEFT JOIN " + RetSQLName("GCY") + " GCY 	ON GCY.GCY_FILIAL 	= '" + xFilial("GCY") + "' AND GCY.GCY_REGATE 	= GAI.GAI_REGATE AND GCY.D_E_L_E_T_ 	<> '*'"
cSQL += "	LEFT JOIN " + RetSQLName("SRA") + " SRA 	ON SRA.RA_FILIAL  	= '" + xFilial("SRA") + "' AND SRA.RA_CODIGO  	= GCY.GCY_CODCRM AND SRA.D_E_L_E_T_ 	<> '*'"
cSQL += "	LEFT JOIN " + RetSQLName("SB1") + " SB12	ON SB12.B1_FILIAL	= '" + xFilial("SB1") + "' AND SB12.B1_COD		= GAJ.GAJ_PROALT AND SB12.D_E_L_E_T_	<> '*'"
If !Empty(cDoc) .OR. !Empty(cSeq)
	cSQL += "	JOIN " + RetSQLName("GD5") + " GD5	 	ON GD5.GD5_FILIAL	= '" + xFilial("GD5") + "' AND GD5.GD5_SOLICI 	= GAI.GAI_SOLICI AND GD5.GD5_ITESOL = GAJ.GAJ_ITESOL AND GD5.D_E_L_E_T_	 	<> '*'" 
	If !Empty(cDoc)
		cSQL += " AND RTRIM(GD5.GD5_SD3DOC)='"+ RTrim(cDoc) +"' "
	EndIf
	If !Empty(cSeq)
		cSQL += " AND RTRIM(GD5.GD5_NUMSEQ)='"+ RTrim(cSeq) +"' "
	EndIf
EndIf 
cSQL += "	JOIN " + RetSQLName("GCS") + " GCS 	ON GCS.GCS_FILIAL  	= '" + xFilial("GCS") + "' AND GCS.GCS_CODLOC	 = GAI.GAI_CODLOC AND GCS.D_E_L_E_T_ <> '*'"  
cSQL += "	WHERE GAI.GAI_FILIAL = '" + xFilial("GAI") + "' AND GAI.D_E_L_E_T_ <> '*'"
If !Empty(cNrSol)
	cSQL += "	AND GAI.GAI_SOLICI = '" + cNrSol + "'"
EndIf
If lImpCupom
	cSQL += "	ORDER BY GAI.GAI_FILIAL, GAI.GAI_SOLICI, GAJ.GAJ_ITESOL"
Else
	cSQL += IIf (nTpRel == 1, "	ORDER BY GAI.GAI_FILIAL, GAJ.GAJ_PROSOL", "	ORDER BY GAI.GAI_FILIAL, GAJ.GAJ_CODKIT, GAJ.GAJ_PROSOL")
EndIf

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTMP",.T.,.T.)

If Eof()
	HS_MsgInf(STR0006, STR0007, STR0008)	//"Solicitação não encontrada"###"Atenção"###"Seleção de registros"
	DbCloseArea()
	Return(nil)
EndIf 

If lImpCupom
	FS_ImpCup()
	DbCloseArea()
	Return(nil)
EndIf

// Configuracao do cabecalho //
cDesSol := IIf(QRYTMP->REQUIS == "1", STR0009, IIf(QRYTMP->REQUIS == "2", STR0010, IIf(QRYTMP->REQUIS == "3", STR0011, "               "))) //"PACIENTE       "###"CONSUMO PROPRIO"###"TRANSFERENCIA  "
If (cParam # Nil)
	cCabec2  := STR0012 + cDesSol + Space(38) + STR0041 + SubStr(cUserName, 7, 13) //"SOLICITACAO A   "###"OPERADOR "
Else 
	cCabec2  := STR0014 + cDesSol + Space(26) + STR0041 + SubStr(cUserName, 7, 13) //"REIMPRESSAO DA SOLICITACAO  "###"OPERADOR "
EndIf
If Empty(cIAtend)
	cCabec2  := STR0014 + cDesSol + Space(26) + STR0041 + SubStr(cUserName, 7, 13) //"REIMPRESSAO DA SOLICITACAO  "###"OPERADOR "
Endif			

If !Empty(QRYTMP->USUDIS)
	cCabUsu := "|"
	cCabUsu += STR0015 + PadR(Alltrim(QRYTMP->USUDIS), 41, "-") + "|-" //"USUARIO RESP.DISPENSA: "
EndIf

If !Empty(QRYTMP->USUCON)
	cCabUsu := If(Empty(cCabUsu),"|", cCabUsu)
	cCabUsu += STR0016 + PadR(Alltrim(QRYTMP->USUCON), 41, "-") + "|" //"USUARIO RESP. CONFER.: "
EndIf

cCabUsu := If(	!Empty(cCabUsu).AND.Len(cCabUsu) < 60, 	Alltrim(cCabUsu) += Repl("-", 165-Len(Alltrim(cCabUsu))-1) + "|", cCabUsu)

// Inicio da impressao //
ProcRegua(nQtdImp)
For nQImp := 1 To nQtdImp
	IncProc()
	dbGoTop()
	While !Eof()
		
		If lAbortPrint
			@nLin,00 PSAY STR0017	//"*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
	 	
	 	If cItem <> QRYTMP->ITESOL
	 		lImprime := .T.
	 	Else
	 		lImprime := .F.
	 	EndIf
//	 	IIf(cItem<>QRYTMP->ITESOL,lImprime:=.T.,lImprime:=.F.)
		If (nLin > nMaxLin)
			cCabec1  := STR0018 + Space(41) + STR0013 + Subs(QRYTMP->LOGARQ, 01, 13) //"SISTEMA DE GESTÃO HOSPITALAR"###"OPERADOR "
			nLin     := Cabec(ctitulo, cCabec1, cCabec2, cNomProg, cTamanho, nCaracter) + 1
			@ nLin, 000 PSAY STR0019 + QRYTMP->SOLICI	//"SOLICITACAO: "
 		 
			If QRYTMP->URGENC = "1"
				@ nLin, 021 PSAY STR0020	//"URGENTE"
			EndIf 
 		 
			@ nLin, 030 PSAY STR0021 + QRYTMP->NOMLOC				//"SETOR SOLICITANTE: "
			@ nLin, 100 PSAY STR0022 + DTOC(STOD(QRYTMP->DATSOL))	//"DATA: "
			@ nLin, 120 PSAY STR0023 + QRYTMP->HORSOL				//"HORA: " 
			nLin ++
			@ nLin, 000 PSAY STR0024 + QRYTMP->REGATE + "  " + QRYTMP->NOMPAC						//"ATENDIMENTO: "
			@ nLin, 080 PSAY STR0025 + QRYTMP->REGGER												//"PRONTUARIO: "
			@ nLin, 100 PSAY STR0026 + IIf(Empty(QRYTMP->QUARTO), QRYTMP->QUAINT ,QRYTMP->QUARTO)	//"QUARTO: " Darcio
			@ nLin, 120 PSAY STR0027 + IIf(Empty(QRYTMP->LEITO), QRYTMP->LEIINT ,QRYTMP->LEITO)		//"LEITO: " Darcio
			nLin ++
			@ nLin, 000 PSAY STR0028 	+ QRYTMP->NOME												//"MEDICO RESPONSAVEL: "
			@ nLin, 080 PSAY STR0029 	+ HS_IniPadr("GCM",  2, HS_IniPadr("GCZ",  IIf(Empty(cPlanoPart),2,1), IIf(Empty(cPlanoPart),QRYTMP->REGATE,cNrseqg), "GCZ_CODPLA",, .F.), "GCM_DESPLA",, .F.)	//"PLANO: "
			nLin++
			If HS_ExisDic({{"C","GAI_CRMPRE"}} , .F.)
				If !Empty(QRYTMP->GAI_CRMPRE)
					@ nLin, 000 PSAY "MEDICO PRESCRICAO.: " + POSICIONE("SRA",11,XFILIAL("SRA")+QRYTMP->GAI_CRMPRE,"RA_NOME")
					nLin++     
				EndIf
			EndIf
 			@ nLin, 000 PSAY REPLICATE("-", 140) 
 			nLin++
 			If (nTpRel == 1)
 															//"                                                                                                    1         1         1         1
 										  //"          1         2         3         4         5         6         7         8         9         0         1         2         3
 										  //"0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 				@ nLin++, 00 PSAY STR0030 //"ORIGEM PRODUTO SOLICITADO                      UN PRODUTO ALTERNATIVO                           UN     QTD.SOL  NRO.DOC.   QTD.ATE"
 			Else																																																																																																																																																																		                                                                                                                            		  
 		 		@ nLin++, 00 PSAY STR0031 //"       PRODUTO SOLICITADO                      UN PRODUTO ALTERNATIVO                           UN     QTD.SOL  NRO.DOC.   QTD.ATE"
 			EndIf	
 			@ nLin++, 00 PSAY REPLICATE("-", 140)  
 		EndIf
 	 
		If (nTpRel == 1) 
			If lImprime
				@ nLin, 000 PSAY IIf(Empty(QRYTMP->CODKIT), " ", "K")
				@ nLin, 001 PSAY QRYTMP->CODKIT
				@ nLin, 007 PSAY QRYTMP->PROSOL + " " + QRYTMP->DESCSOL
				@ nLin, 054 PSAY QRYTMP->UMSOL	
				@ nLin, 057 PSAY QRYTMP->PROALT + " " + QRYTMP->DESCALT	
				@ nLin, 097 PSAY QRYTMP->UMALT	
				@ nLin, 099 PSAY PadL(TRANSFORM(QRYTMP->QTDSOL, "@E 99,999.9999"), 11)
	   If QRYTMP->REQUIS <> "1"
				 @ nLin, 127 PSAY PadL(TRANSFORM(QRYTMP->QTDATE, "@E 99,999.9999"), 11)
	   Endif
			EndIf
			If Empty(cIAtend)  
				DbSelectArea("GD5") 
				DbSetOrder(4)  		     
				DbSeek(xFilial("GD5")+QRYTMP->SOLICI+QRYTMP->ITESOL)  
				While !Eof()
					lImprime:=.F. 
					IIf(!Empty(cNrSol) .AND. GD5->GD5_SOLICI == QRYTMP->SOLICI .AND. GD5->GD5_ITESOL ==QRYTMP->ITESOL,lImprime:=.T.,)  
					IIf(!Empty(cDoc)   .AND. GD5->GD5_SD3DOC == cDoc           .AND. GD5->GD5_ITESOL ==QRYTMP->ITESOL,lImprime:=.T.,)  
					IIf(!Empty(cSeq)   .AND. GD5->GD5_NUMSEQ == cSeq           .AND. GD5->GD5_ITESOL ==QRYTMP->ITESOL,lImprime:=.T.,)  
					If lImprime
						@ nLin, 119 PSAY GD5->GD5_SD3DOC	
						@ nLin, 126 PSAY PadL(TRANSFORM(GD5->GD5_QTDDES, "@E 99,999.9999"), 11)	
						nLin ++
					EndIf 
					dbSkip()
	     		End	  		                                                 
			Else
   	  			For nCont :=1 to Len(aIAtend) 	     
   	   				If aIAtend[nCont][1]==QRYTMP->ITESOL
						@ nLin, 115 PSAY aIAtend[nCont][3]
						@ nLin, 126 PSAY PadL(TRANSFORM(aIAtend[nCont][2], "@E 99,999.9999"), 11)  
   	  				EndIf
  	  			Next nCont
    		Endif	 	
  		Else
			If lImprime
				If (QRYTMP->CODKIT # cGajCodKit)
					If !Empty(QRYTMP->CODKIT) 		// Nao imprime cabecalho caso nao tenha kit //    		
  						@ nLin++, 000 PSAY REPLICATE("-", 140)   
 	 					nLin++
 		 				@ nLin++, 000 PSAY STR0032 + IIf(Empty(QRYTMP->CODKIT), " ", "K") + QRYTMP->CODKIT	//"ORIGEM: "
  		 				nLin++
  			 		EndIf
  			 		cGajCodKit := QRYTMP->CODKIT
  		 		EndIf
				@ nLin, 007 PSAY QRYTMP->PROSOL + " " + QRYTMP->DESCSOL
				@ nLin, 054 PSAY QRYTMP->UMSOL 	
				@ nLin, 057 PSAY QRYTMP->PROALT + " " + QRYTMP->DESCALT	
				@ nLin, 097 PSAY QRYTMP->UMALT	
				@ nLin, 099 PSAY PadL(TRANSFORM(QRYTMP->QTDSOL, "@E 99,999.9999"), 11)
   	  If QRYTMP->REQUIS <> "1"
			   	 @ nLin, 127 PSAY PadL(TRANSFORM(QRYTMP->QTDATE, "@E 99,999.9999"), 11)
	     Endif  		
  			EndIf
			If Empty(cIAtend)  
				DbSelectArea("GD5") 
				DbSetOrder(4)  		     
				DbSeek(xFilial("GD5")+QRYTMP->SOLICI+QRYTMP->ITESOL)  
				While !Eof() 
					lImprime:=.F. 
  		   			IIf(!Empty(cNrSol) .AND. GD5->GD5_SOLICI == QRYTMP->SOLICI .AND. GD5->GD5_ITESOL ==QRYTMP->ITESOL,lImprime:=.T.,)
					IIf(!Empty(cDoc)   .AND. GD5->GD5_SD3DOC == cDoc           .AND. GD5->GD5_ITESOL ==QRYTMP->ITESOL,lImprime:=.T.,)
					IIf(!Empty(cSeq)   .AND. GD5->GD5_NUMSEQ == cSeq           .AND. GD5->GD5_ITESOL ==QRYTMP->ITESOL,lImprime:=.T.,)
  					If lImprime  		     
						@ nLin, 119 PSAY GD5->GD5_SD3DOC	
						@ nLin, 126 PSAY PadL(TRANSFORM(GD5->GD5_QTDDES, "@E 99,999.9999"), 11)	
						nLin ++   
					EndIf
					dbSkip()
				End
			Else
				For nCont :=1 to Len(aIAtend) 	     
					If aIAtend[nCont][1]==QRYTMP->ITESOL
						@ nLin, 115 PSAY aIAtend[nCont][3]
						@ nLin, 126 PSAY PadL(TRANSFORM(aIAtend[nCont][2], "@E 99,999.9999"), 11)  
					EndIf
				Next nCont	 	
			Endif	 	
		EndIf
  	
		nLin++
		cItem := 	QRYTMP->ITESOL
   
		DbSelectArea("QRYTMP")
		DbSkip()
	End
 		
Next nQImp   

FS_CabResp(cCabUsu)

DbCloseArea()
 
If (lInfPrn .AND. !lImpCupom)
	Ms_Flush()
	DbCloseArea()
	Set Printer to
	Set Device  to Screen
	If aReturn[5] == 1
		OurSpool(cNomeRel)
	EndIf
EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CabRespº Autor ³ Saude              º Data ³ Agosto/2001 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao utilizada para impressao do cabecalho do usuario.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_CabResp(cCabUsu)
Local cLinSep := "|"+Space(64)+"|"+Space(65)+"|"

nLin := 55

If !Empty(cCabUsu)
	@ nLin++, 00 PSAY cCabUsu
	@ nLin++, 00 PSAY cLinSep
	@ nLin++, 00 PSAY cLinSep
	@ nLin++, 00 PSAY cLinSep
	@ nLin++, 00 PSAY REPLICATE("-", 165)
EndIf
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ImpCup º Autor ³ Saude              º Data ³ Agosto/2001 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao utilizada para impressao em cupom.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ImpCup()
Local cConteudo := ""
Local nTotQtd   := 0, nTotItem := 0
Local nH

cConteudo += PADR(STR0022 + DTOC(STOD(QRYTMP->DATSOL)), 24) + PADL(STR0023 + QRYTMP->HORSOL, 23) + chr(13) + chr(10) //"Data: "###"Hora: "
cConteudo += PADR("==== ", 12) + STR0033 + 	PADL(" ====", 13) + 	chr(13) + chr(10)	//"Relacao de conferencia"
cConteudo += "" + chr(13) + chr(10)
cConteudo += PADC(ALLTRIM(QRYTMP->NOMLOC), 45) + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += STR0034 + QRYTMP->REGGER + " " + SUBSTR(QRYTMP->NOMPAC,1,27) + chr(13) + chr(10)		//"PACIENTE...: "
cConteudo += STR0035 + QRYTMP->SOLICI + chr(13) + chr(10)											//"PRESC. No..: "
cConteudo += STR0036 + QRYTMP->CODLOC + " - " + SUBSTR(QRYTMP->NOMLOC, 1, 28) + chr(13) + chr(10)	//"SETOR DEST.: "
cConteudo += "" + chr(13) + chr(10)
 												//									 1         2         3         4       
 												//012345678901234567890123456789012345678901234567
cConteudo += STR0037 + chr(13) + chr(10) //"            COD ITEM               UND     QTDE"
 
dbGoTop()
While !Eof()
	cConteudo += PADL(ALLTRIM(QRYTMP->PROSOL), 15) + " " + SUBSTR(QRYTMP->DESCSOL, 1, 18) + " " + QRYTMP->UMSOL + "  " + TRANSFORM(QRYTMP->QTDSOL, "@E 99,999.9999") + TRANSFORM(QRYTMP->QTDATE, "@E 99,999.9999")+ chr(13) + chr(10)
	nTotQtd 		+= QRYTMP->QTDSOL
	nTotItem++
	dbSkip()
EndDo
 
cConteudo += "" + chr(13)	+	chr(10)
cConteudo += REPLICATE("-",	47) + chr(13)	+	chr(10)
cConteudo += STR0038 + chr(13) + chr(10)	//"TOTAIS"
cConteudo += "" + chr(13)+chr(10)
cConteudo += STR0039 + TRANSFORM(nTotItem, "@E 999,999") + STR0040 + TRANSFORM(nTotQtd,"@E 999.999") + chr(13) + chr(10) //"ITENS: "###"       QUANTIDADE: "
cConteudo += REPLICATE("-",47) + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
cConteudo += "" + chr(13) + chr(10)
 
nH := CBOpenPort(cPort)
Fwrite(nH,cConteudo)
Fclose(nH)
Return() 

Static Function ReportDef(nTpRel,cPlanoPart,cNrseqg)
Local oReport 
Local oSection1,oSection2,oSection3
Local oCell
Local oBreak1  
                                                                        
 
	oReport := TReport():New("HSPAHR03",STR0001,"HSPR03",{|oReport| R03IMP(oReport)}, cTitulo)
	oReport:SetTotalInLine(.F.) 
	oReport:SetLandscape() 

 oSection1 := TRSection():New(oReport, "Solicitação", {"QRYSQL","GAI"})
 oSection1:SetHeaderPage(.T.)
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetHeaderSection(.T.)  
 oSection1:SetTotalInLine(.F.)  

	oCell := TRCell():New(oSection1,"cSolici","QRYSQL",STR0019,,100,,{|| cSolici:= ("QRYSQL")->SOLICI}) //"SOLICITACAO 		
	oCell := TRCell():New(oSection1,"NOMLOC","QRYSQL",STR0021,,150,,) //"SETOR SOLICITANTE: "
	oCell := TRCell():New(oSection1,"cDataSo","QRYSQL",STR0022,, 70,,{|| cDataSo :=  DTOC(STOD(("QRYSQL")->DATSOL))}) //"data"
	oCell := TRCell():New(oSection1,"cHorSolic","QRYSQL",STR0023,,30,,{|| cDataSo := ("QRYSQL")->HORSOL}) //"hora" 
	oCell := TRCell():New(oSection1,"cRegat","QRYSQL",STR0024,, 150,,{|| cRegat := ("QRYSQL")->REGATE + "  " + ("QRYSQL")->NOMPAC}) //"ATENDIMENTO: "
	oCell := TRCell():New(oSection1,"cRegger","QRYSQL",STR0025,, 35,,{|| cRegger :=  ("QRYSQL")->REGGER}) //"PRONTUARIO: "
	oCell := TRCell():New(oSection1,"cQuart","QRYSQL",STR0026,, 35,,{|| cQuart := IIf(Empty(("QRYSQL")->QUARTO), ("QRYSQL")->QUAINT ,("QRYSQL")->QUARTO)})//"quarto"
	oCell := TRCell():New(oSection1,"cLei","QRYSQL",STR0027,, 35,,{|| cLei :=  IIf(Empty(("QRYSQL")->LEITO), ("QRYSQL")->LEIINT ,("QRYSQL")->LEITO)})//"LEITO: "
	oCell := TRCell():New(oSection1,"cPLN","QRYSQL",STR0029,, 50,,{|| cPLM := HS_IniPadr("GCM",  2, HS_IniPadr("GCZ",  IIf(Empty(cPlanoPart),2,1), IIf(Empty(cPlanoPart),("QRYSQL")->REGATE,cNrseqg), "GCZ_CODPLA",, .F.), "GCM_DESPLA",, .F.)})//"PLANO: "
	oCell := TRCell():New(oSection1,"cNome","QRYSQL",STR0028,, 100,,{|| cNome :=  ("QRYSQL")->NOME}) //"MEDICO RESPONSAVEL: "
	oCell := TRCell():New(oSection1,"cMedicPre","QRYSQL",STR0050,, 100,,{||cMedicPre :=	IIF(HS_ExisDic({{"C","GAI_CRMPRE"}} , .F.) .AND.!Empty(("QRYSQL")->GAI_CRMPRE), ( POSICIONE("SRA",11,XFILIAL("SRA")+("QRYSQL")->GAI_CRMPRE,"RA_NOME")),"")})//	"MEDICO PRESCRICAO."
	oCell := TRCell():New(oSection1,"cUrgente","",STR0051,, 60,,{||cUrgente :=IIf(("QRYSQL")->URGENC == "1", STR0020,"               ")})//"TIPO Solici."
	oCell := TRCell():New(oSection1,"cTitulo","QRYSQL",STR0013,, 50,,{|| cTitulo := Subs(("QRYSQL")->LOGARQ, 01, 13)}) //"OPERADOR "
	oCell := TRCell():New(oSection1,"cDesSol","QRYSQL",STR0014,, 150,,{|| cDesSol := IIf(("QRYSQL")->REQUIS == "1", STR0009, IIf(("QRYSQL")->REQUIS == "2", STR0010, IIf(("QRYSQL")->REQUIS == "3", STR0011, "               ")))}) //"REIMPRESSAO DA SOLICITACAO  "





	oSection2 := TRSection():New(oSection1, "Itens da Solicitacao", {"GAJ","SB1"})
	oSection2:SetHeaderPage(.T.)
	oSection2:SetHeaderBreak(.T.)
	oSection2:SetHeaderSection(.T.)  
	oSection2:SetTotalInLine(.F.)  
	

	oCell := TRCell():New(oSection2,"cKit","QRYSQL",STR0042,, 40,,{|| cKit :=  IIf(Empty(("QRYSQL")->CODKIT), " ", "K")+  ("QRYSQL")->CODKIT})//"Origem" 
	oCell := TRCell():New(oSection2,"cProd","QRYSQL",STR0043,, 150,,{|| cProd := ("QRYSQL")->PROSOL +" " +("QRYSQL")->DESCSOL })//"Produto Solicitado"
	oCell := TRCell():New(oSection2,"UMSOL","QRYSQL",STR0045,,20)//"UN."
	oCell := TRCell():New(oSection2,"cProdAlt","QRYSQL",STR0044,,150,,{|| cProdAlt :=("QRYSQL")->PROALT + " " + ("QRYSQL")->DESCALT})//"Produto Alternativo"
	oCell := TRCell():New(oSection2,"UMALT","QRYSQL",STR0045,,20)//"UN."		
	oCell := TRCell():New(oSection2,"cQtdade","QRYSQL",STR0046,, 60,,{|| cQtdade :=PadL(TRANSFORM(("QRYSQL")->QTDSOL, "@E 99,999.9999"), 11)})//"Qtd.Sol."
 oCell := TRCell():New(oSection2,"Funcao","","",,25,,{||HS_DocQtd(("QRYSQL")->SOLICI,("QRYSQL")->ITESOL) })
 oCell := TRCell():New(oSection2,"cDoc1","GD5",STR0047,,25,,{||cDoc1})//"Nro.Doc."
 oCell := TRCell():New(oSection2,"cQTDDES","GD5",STR0048,,25,,{|| IIf(Empty(cQTDDES),cQTDDES:=PadL(TRANSFORM(("QRYSQL")->QTDATE, "@E 99,999.9999"), 11),cQTDDES)})//"Qtd.Atendida"
  
Return (oReport)         
                                                                         	`					
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R03Imp   ³ Autor ³                       ³ Data ³ 04/02/09 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   

Static Function R03IMP(oReport,nTpRel,aIAtend,cPlanoPart,cNrseqg)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local nCont:=0


Private cCond1 := ""
Private cCond2 := ""
Private cCond3 := ""
Private cCond4 := ""
Private cDoc1   :=""
Private cQTDDES :=""
Private cSol    :="" 
Private ciTen   :=""
Private cSequenc:=""

MakeSqlExpr(oReport:uParam)                      
oSection1:BeginQuery()                             

cCond1 += "% GAI.GAI_SOLICI SOLICI, GAI.GAI_DATSOL DATSOL, GAI.GAI_HORSOL HORSOL, GAI.GAI_REQUIS REQUIS, GCS.GCS_NOMLOC NOMLOC, "
cCond1 += " GAI.GAI_CODLOC CODLOC, GAI.GAI_REGATE REGATE, GAJ.GAJ_ITESOL ITESOL, GAJ.GAJ_PROSOL PROSOL, SB1.B1_DESC DESCSOL,  "
cCond1 += " SB1.B1_UM UMSOL, GAJ.GAJ_PROALT PROALT, SB12.B1_DESC DESCALT, SB12.B1_UM UMALT, GAJ.GAJ_QTDSOL QTDSOL, "
cCond1 += " GAJ.GAJ_QTDATE QTDATE, GAJ.GAJ_CODKIT CODKIT, GAF.GAF_DESKIT DESKIT, GAI.GAI_LOGARQ LOGARQ, GAI.GAI_URGENC URGENC, "
cCond1 += " GAI.GAI_REGATE REGATE, GAI.GAI_NOMPAC NOMPAC, GAI.GAI_CRMPRE, GCY.GCY_REGGER REGGER, "
cCond1 += " GCY.GCY_QUAINT QUAINT, GCY.GCY_LEIINT LEIINT, "
cCond1 +=IIf(GAI->(FieldPos("GAI_QUARTO"))==0, "GCY.GCY_QUAINT", "GAI.GAI_QUARTO") + " QUARTO, "
cCond1 +=IIf(GAI->(FieldPos("GAI_QUARTO"))==0, "GCY.GCY_LEIINT", "GAI.GAI_LEITO") + " LEITO, "
cCond1 +=" GCY.GCY_CODCRM CODCRM, SRA.RA_NOME NOME, GAI.GAI_USUDIS USUDIS, GAI.GAI_USUCON USUCON%"

cCond2 += "% " + RetSQLName("GAI") +" GAI		JOIN " + RetSQLName("GAJ") + " GAJ 	ON GAJ.GAJ_FILIAL 	= '" + xFilial("GAJ") + "' AND GAJ.GAJ_SOLICI 	= GAI.GAI_SOLICI AND GAJ.D_E_L_E_T_ 		<> '*'"
If !Empty(cIAtend)
cCond2 += " AND GAJ.GAJ_ITESOL IN (" + HS_InSQL(cIAtend) + ")"
Endif

cCond2 += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  	= '" + xFilial("SB1") + "' AND SB1.B1_COD	  			= GAJ.GAJ_PROSOL AND SB1.D_E_L_E_T_ 	<> '*'"
cCond2 += " LEFT JOIN " + RetSqlName("GAF") + " GAF 	ON GAF.GAF_FILIAL 	= '" + xFilial("GAF") + "' AND GAF.GAF_CODKIT 	= GAJ.GAJ_CODKIT AND GAF.D_E_L_E_T_ 	<> '*'"
cCond2 += " LEFT JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL 	= '" + xFilial("GCY") + "' AND GCY.GCY_REGATE 	= GAI.GAI_REGATE AND GCY.D_E_L_E_T_ 	<> '*'"
cCond2 += " LEFT JOIN " + RetSqlName("SRA") + " SRA 	ON SRA.RA_FILIAL  	= '" + xFilial("SRA") + "' AND SRA.RA_CODIGO  	= GCY.GCY_CODCRM AND SRA.D_E_L_E_T_ 	<> '*'"
cCond2 += "	LEFT JOIN " + RetSQLName("SB1") + " SB12	ON SB12.B1_FILIAL	= '" + xFilial("SB1") + "' AND SB12.B1_COD		= GAJ.GAJ_PROALT AND SB12.D_E_L_E_T_	<> '*' "
If !Empty(cDoc) .OR. !Empty(cSeq)
  cCond2 += "  JOIN " + RetSQLName("GD5") + " GD5	 	ON GD5.GD5_FILIAL	= '" + xFilial("GD5") + "' AND GD5.GD5_SOLICI 	= GAI.GAI_SOLICI AND GD5.GD5_ITESOL = GAJ.GAJ_ITESOL AND GD5.D_E_L_E_T_	 	<> '*'" 
	If !Empty(cDoc)
		cCond2 += " AND RTRIM(GD5.GD5_SD3DOC)='"+ RTrim(cDoc) +"' "
	EndIf
	If !Empty(cSeq)
		cCond2 += " AND RTRIM(GD5.GD5_NUMSEQ)='"+ RTrim(cSeq) +"' "
	EndIf
EndIf 

cCond2 += " LEFT JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL  	= '" + xFilial("GCS") + "' AND GCS.GCS_CODLOC	 = GAI.GAI_CODLOC AND GCS.D_E_L_E_T_ <> '*' %"  

cCond3 += "% GAI.GAI_FILIAL = '" + xFilial("GAI") + "' AND GAI.D_E_L_E_T_ <> '*' "

If !Empty(cNrSol)
	cCond3 += "	AND GAI.GAI_SOLICI = '" + cNrSol + "' "
endIf
cCond3+= "  %"

If lImpCupom
	cCond4 += "%GAI.GAI_FILIAL, GAI.GAI_SOLICI, GAJ.GAJ_ITESOL%"
Else
	cCond4 +=	IIf (nTpRel == 1, "	% GAI.GAI_FILIAL, GAJ.GAJ_PROSOL %", "%	GAI.GAI_FILIAL, GAJ.GAJ_CODKIT, GAJ.GAJ_PROSOL%")
Endif

BeginSql alias "QRYSQL"
 SELECT		%Exp:cCond1%
 FROM     	%Exp:cCond2%
 WHERE    	%Exp:cCond3%                                      	
 ORDER BY	%Exp:cCond4% 
EndSql 

oSection1:EndQuery() 
	                                    

	                                     
DbSelectArea("QRYSQL")
DbGoTop()                                                                                                                                

oSection2:Cell("Funcao"):Hide()
oSection2:SetParentQuery()
oSection2:SetParentFilter( {|G|   ("QRYSQL")->SOLICI  == G }, {||  ("QRYSQL")->SOLICI}) 


oSection1:Print() 
oReport:SetMeter(QRYSQL->(LastRec())) 

Return (Nil)




/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³função para imprimir em r4 os itens da GD5³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

Static Function HS_DocQtd(Solici,Itesol)
Local nCont:=0

cSol:=""
ciTen:=""
cSequenc:=""
cDoc1:=""
cQTDDES:=""

lImprime:=.F.
		
If Empty(cIAtend)  
	DbSelectArea("GD5") 
	DbSetOrder(4)  		     
	DbSeek(xFilial("GD5")+QRYSQL->SOLICI+QRYSQL->ITESOL)			
	While GD5->(!Eof()) .and.GD5->GD5_ITESOL==Itesol
		IIf(!Empty(cNrSol) .AND. GD5->GD5_SOLICI == QRYSQL->SOLICI .AND. GD5->GD5_ITESOL ==QRYSQL->ITESOL,lImprime:=.T.,)
		IIf(!Empty(cDoc)   .AND. GD5->GD5_SD3DOC == cDoc           .AND. GD5->GD5_ITESOL ==QRYSQL->ITESOL,lImprime:=.T.,)
		IIf(!Empty(cSeq)   .AND. GD5->GD5_NUMSEQ == cSeq           .AND. GD5->GD5_ITESOL ==QRYSQL->ITESOL,lImprime:=.T.,)
		If lImprime             	
			cSol     +=GD5->GD5_SOLICI 
			ciTen    +=GD5->GD5_ITESOL
			cSequenc +=GD5->GD5_NUMSEQ    				
			cDoc1    += GD5->GD5_SD3DOC	  		
			cQTDDES		+= PadL(TRANSFORM(GD5->GD5_QTDDES, "@E 99,999.9999"), 11)	
		EndIf
	GD5->	(dbSkip())
	Enddo
Else
	For nCont :=1 to Len(aIAtend) 	     
		If aIAtend[nCont][1]==QRYSQL->ITESOL					
			cSol     +=GD5->GD5_SOLICI 
			ciTen    +=GD5->GD5_ITESOL
			cSequenc +=GD5->GD5_NUMSEQ 
			cDoc1     += aIAtend[nCont][3]
			cQTDDES		+=  PadL(TRANSFORM(aIAtend[nCont][2], "@E 99,999.9999"), 11)  						
		EndIf
	Next nCont	 	
			
EndIf                         




Return(cDoc1,cQTDDES)                                             

