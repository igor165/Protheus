#INCLUDE "GTPR408A.CH"
#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'FWMVCDef.ch'

Static aVeic := {}
Static cCodManut	:= ""
Static oTableTmp
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR408A()
Relatório de escala de veículo 

@sample GTPR408A()

@author Flavio Martins
@since 25/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR408A(lAuto)

Local oReport := Nil

DEFAULT lAuto := .F.

    If lAuto
		G52->(DbSetOrder(2))
		G52->(DBSEEK("D MG    000003000005100000000007"))  
	EndIf
	// Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Imprime a escala de veículo.

@sample ReportDef(oBrowse)

@param oBrowse - Browse ativo

@return oReport - Objeto - Objeto TREPORT

@author Renan Ribeiro Brando
@since 21/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport   

oReport := TReport():New('GTPR408A', STR0001,,{|oReport|ReportPrint(oReport)}, "",/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/) // "Escala de Veículos

oReport:HideFooter()
oReport:HideHeader()
oReport:HideParamPage() 
oReport:SetLandScape(.T.)
Pergunte(oReport:uParam, .F.)


Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ImprCabec(oReport,cAliasQry,nKmMes,cCodigo)
description
@author  Flavio Martins
@since   24/08/2017
@version version
/*/
//-------------------------------------------------------------------

Static Function ImprCabec(oReport,cAliasQry,nKmMes,cCodigo)
Local oArial08N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	// Negrito
Local oArial10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)	// Normal
Local oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	// Negrito
Local nI 		:= 1
Local aStrVeic	:= {{""}}
Local nVeic		:= 1
Local nAux		:= 0300
oReport:StartPage()

IF oReport:oPage:nPage == 1
	aVeic := RetVeic(cCodigo)
ENDIF

// Header
oReport:Box(0100, 0050, 0400, 3170)	
oReport:Say(0120, 1450, STR0001, oArial10N) // "Escala de Veículos
oReport:Say(0200, 0600, STR0002, oArial08N) // "Escala: "
oReport:Say(0200, 0710, cCodigo, oArial10) 

oReport:Say(0250, 0600, "Loc. Manuteção:", oArial08N) // "Setor: "
oReport:Say(0250, 0830, AllTrim(Posicione('GI1',1,xFilial('GI1') + cCodManut, 'GI1_DESCRI')) , oArial10)
oReport:Say(0300, 0600, STR0004, oArial08N ) // "Veículos: "

For nI := 1 to Len(aVeic)
	
	If !Empty(aVeic[nI]) .And. nI > 1
		aStrVeic[nVeic,1] += " / "	
	EndIf
	If Len(aStrVeic[nVeic,1] + Alltrim(aVeic[nI])) <= 90
		aStrVeic[nVeic,1] += Alltrim(aVeic[nI])
	Else
		aAdd(aStrVeic,{""})
		nVeic++
		aStrVeic[nVeic,1] += Alltrim(aVeic[nI])
	Endif

Next nI
For nI := 1 To Len(aStrVeic)
	If nI > 1
		nAux += 50 
	Endif
	oReport:Say(nAux, 0740, aStrVeic[nI,1], oArial10)
Next

oReport:Say(0200, 2220, STR0007, oArial08N) // "KM Total: "
oReport:Say(0200, 2370, cValToChar(ROUND(nKmMes,0)), oArial08N) // "KM Total: "

oReport:Say(0250, 2220, STR0008, oArial08N) // "KM Diária: "
oReport:Say(0250, 2370, cValToChar(ROUND(nKmMes/30,0)), oArial08N) // "KM Diária: "

oReport:Say(0300, 2220, "Data: ", oArial08N) // "KM Diária: "
oReport:Say(0300, 2320, cValToChar(ddatabase), oArial08N) // "KM Diária: "

nLinha := 400

oReport:Box(nLinha, 0050, nLinha+100, 0150) 
oReport:Box(nLinha, 0150, nLinha+100, 0280) 
oReport:Box(nLinha, 0280, nLinha+100, 0430) 
oReport:Box(nLinha, 0430, nLinha+100, 0580) 
oReport:Box(nLinha, 0580, nLinha+100, 0650) 

oReport:Box(nLinha, 0650, nLinha+50, 1950) 
oReport:Box(nLinha, 1750, nLinha+100, 1750) 
oReport:Box(nLinha+50, 1850, nLinha+100, 1850) 

oReport:Box(nLinha, 1950, nLinha+50, 2350)
oReport:Box(nLinha+50, 1950, nLinha+100, 2050)
oReport:Box(nLinha+50, 2050, nLinha+100, 2190)

oReport:Box(nLinha, 2350, nLinha+50, 2650)
oReport:Box(nLinha+50, 2350, nLinha+100, 2450)
oReport:Box(nLinha+50, 2450, nLinha+100, 2550)
oReport:Box(nLinha+50, 2650, nLinha+100, 2650)

oReport:Box(nLinha, 2650, nLinha+50, 2850)
oReport:Box(nLinha+50, 2650, nLinha+100, 2750)
oReport:Box(nLinha+50, 2750, nLinha+100, 2850)

oReport:Box(nLinha, 2850, nLinha+50, 3130)
oReport:Box(nLinha+50, 2850, nLinha+100, 2890)
oReport:Box(nLinha+50, 2890, nLinha+100, 2930)
oReport:Box(nLinha+50, 2930, nLinha+100, 2970)
oReport:Box(nLinha+50, 2970, nLinha+100, 3010)
oReport:Box(nLinha+50, 3010, nLinha+100, 3050)
oReport:Box(nLinha+50, 3050, nLinha+100, 3090)
oReport:Box(nLinha+50, 3090, nLinha+100, 3130)
oReport:Box(nLinha, 3130, nLinha+100, 3170)

oReport:Say(0420, 0070, STR0009, oArial08N) // "Seq."
oReport:Say(0420, 0170, STR0010, oArial08N) // "Horário"
oReport:Say(0420, 0320, STR0011, oArial08N) // "Linha"
oReport:Say(0420, 0457, "Código", oArial08N) // "Grupo"
oReport:Say(0460, 0455, "Serviço", oArial08N) // "Escala"
oReport:Say(0410, 0590, STR0014, oArial08N) //"Dia"

oReport:Say(0410, 1190, STR0015, oArial08N) // "Itinerário"

oReport:Say(0460, 1140, STR0016 + " / " + STR0017, oArial08N) // "Origem" / "Destino"
oReport:Say(0410, 1820, STR0018, oArial08N) // "Saída" 
oReport:Say(0460, 1770, STR0019, oArial08N) // "GRG" 
oReport:Say(0460, 1875, STR0020, oArial08N) //"RDR"

oReport:Say(0410, 2100, STR0021, oArial08N) // "Chegada" 
oReport:Say(0460, 1980, STR0020, oArial08N) // "RDR"
oReport:Say(0460, 2080, STR0019, oArial08N) // "GRG"
oReport:Say(0460, 2225, STR0025, oArial08N) // "Tempo"  

oReport:Say(0410, 2440, STR0022, oArial08N) // "Garagem" 
oReport:Say(0460, 2370, STR0023, oArial08N) // "Início"
oReport:Say(0460, 2460, STR0024, oArial08N) // "Final"
oReport:Say(0460, 2560, STR0025, oArial08N) // "Tempo"
oReport:Say(0410, 2730, STR0026, oArial08N)  // "KM"
oReport:Say(0460, 2670, STR0027, oArial08N) // "Viag"
oReport:Say(0460, 2760, STR0028, oArial08N) // "Ac." 
oReport:Say(0410, 2920, STR0029, oArial08N) // "Frequência" 
oReport:Say(0460, 2860, STR0030, oArial08N) // "D"
oReport:Say(0460, 2900, STR0031, oArial08N) // "S"
oReport:Say(0460, 2940, STR0032, oArial08N) // "T"
oReport:Say(0460, 2980, STR0033, oArial08N) // "Q" 
oReport:Say(0460, 3020, STR0033, oArial08N) // "Q"
oReport:Say(0460, 3060, STR0031, oArial08N) // "S"
oReport:Say(0460, 3100, STR0031, oArial08N) // "S"
oReport:Say(0430, 3140, STR0034, oArial08N) // "P"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, oDados)

@param oReport - Objeto - Objeto TREPORT

@author Flavio Martins
@since 25/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local cAliasQry := ""
Local cCodigo     := G52->G52_CODIGO
Local cQry		:= ""
Local cHrSaiGr	:= ""
Local cLocPart	:= ""
Local cHGIAux	:= ""
Local cManut	:= "1" 
Local nLinha    := 0
Local nKmAcum   := 0 
Local nDiaAux	:= 0 
Local nDia		:= 0
Local nLinAux	:= 0
Local nP		:= 0
Local aIndexes	:= {}
Local nKmMes	:= 0
Local aDiasSem	:= {}
Local aLinha	:= {}
Local aSeek		:= {}	
// Local oTable
Local oPen 		:= TPen():New(100,1,5)	
Local oArial07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)	// Normal
Local oArial08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)	// Normal
Local cDscIni	:= ""
Local cDscFim	:= ""
oPen:Activate()

cQry := "SELECT " + chr(13)
cQry += "	G52.G52_SEQUEN, " + chr(13)
cQry += "	G52.G52_CODIGO,  " + chr(13)
cQry += "	G52.G52_SERVIC,  " + chr(13)
cQry += "	G52.G52_LINHA,  " + chr(13)
cQry += "	GI2.GI2_NUMLIN,  " + chr(13)
cQry += "	G52.G52_SENTID,  " + chr(13)
cQry += "	G52.G52_DIA,  " + chr(13)
cQry += "	G52.G52_LOCORI, " + chr(13)
cQry += "	G52.G52_LOCDST,  " + chr(13)
cQry += "	G52.G52_HRSDGR,  " + chr(13)
cQry += "	G52.G52_HRSDRD,  " + chr(13)
cQry += "	G52.G52_HRCHRD,  " + chr(13)
cQry += "	G52.G52_HRCHGR, " + chr(13)
cQry += "	G52.G52_HRGRIN,  " + chr(13)
cQry += "	G52.G52_HRGRFI,  " + chr(13)
cQry += "	G52.G52_KMVIAG, " + chr(13)
cQry += "	G52.G52_SEC, " + chr(13)
cQry += "	GID.GID_HORCAB, " + chr(13)
cQry += "	GID.GID_INIVIG, " + chr(13)
cQry += "	GID.GID_FINVIG, " + chr(13)
cQry += "	GID.GID_NUMSRV, " + chr(13)
cQry += "	GI2.GI2_KMVOLT, " + chr(13)
cQry += "	CASE WHEN G52.G52_DOMING = 'T' THEN 'X' ELSE '' END G52_DOMING, " + chr(13)
cQry += "	CASE WHEN G52.G52_SEGUND = 'T' THEN 'X' ELSE '' END G52_SEGUND , " + chr(13)
cQry += "	CASE WHEN G52.G52_TERCA  = 'T' THEN 'X' ELSE '' END G52_TERCA, " + chr(13)
cQry += "	CASE WHEN G52.G52_QUARTA = 'T' THEN 'X' ELSE '' END G52_QUARTA, " + chr(13)
cQry += "	CASE WHEN G52.G52_QUINTA = 'T' THEN 'X' ELSE '' END G52_QUINTA, " + chr(13)
cQry += "	CASE WHEN G52.G52_SEXTA  = 'T' THEN 'X' ELSE '' END G52_SEXTA, " + chr(13)
cQry += "	CASE WHEN G52.G52_SABADO = 'T' THEN 'X' ELSE '' END G52_SABADO, " + chr(13)
cQry += "	G52.G52_DIAPAR, " + chr(13)
cQry += "	GI2.GI2_LOCINI, " + chr(13)
cQry += "	GI2.GI2_LOCFIM, " + chr(13)
cQry += "	GI1ORI.GI1_DESCRI DSCORI, " + chr(13)
cQry += "	GI1DST.GI1_DESCRI DSCDST, " + chr(13)
cQry += "	GI1ORI.GI1_KMGRRD, " + chr(13)
cQry += "	GI1DST.GI1_KMRDGR, " + chr(13)

cQry += "	(SELECT SUM(GI4_KM) FROM " + RetSQLName("GI4") + " GI4  " + chr(13) 
cQry += "	 INNER JOIN " + RetSQLName("GIE") + " GIE " + chr(13)
cQry += "     ON GI4.GI4_LINHA = GIE.GIE_LINHA" + chr(13)
cQry += "     AND GI4.GI4_LOCORI = GIE.GIE_IDLOCP" + chr(13)
cQry += "     AND GI4.GI4_LOCDES = GIE.GIE_IDLOCD" + chr(13)
cQry += "     AND GI4.GI4_HIST = '2'" + chr(13)
//cQry += "     AND GI4.GI4_MSBLQL = '2'" + chr(13)
cQry += "     AND GI4.D_E_L_E_T_ = ' '" + chr(13)
cQry += "   WHERE" + chr(13)
cQry += "     GIE.GIE_CODGID = GID_COD" + chr(13)
cQry += "     AND GIE.D_E_L_E_T_ = ' '" + chr(13)
cQry += "     AND GIE.GIE_HIST = '2') KM_TRECHO," + chr(13)

cQry += "	(SELECT DISTINCT GI2.GI2_LOCFIM FROM " + RetSQLName("G52") + " G52  " + chr(13) 
cQry += "	 INNER JOIN " + RetSQLName("GI2") + " GI2 " + chr(13)
cQry += "		ON GI2.GI2_COD = G52.G52_LINHA " + chr(13)
cQry += "	AND GI2.GI2_HIST = '2' " + chr(13)
cQry += "		AND GI2.D_E_L_E_T_ = ' ' " + chr(13)
cQry += "	 WHERE " + chr(13)
cQry += "     G52.D_E_L_E_T_ = ' '  " + chr(13)
cQry += "     AND G52.G52_CODIGO = '" + cCodigo + "'" + chr(13)
cQry += "     AND G52.G52_PMANUT = '" + cManut + "') LOC_MANUT,  " + chr(13)

cQry += "	(SELECT COUNT(GQA_CODVEI) FROM " + RetSQLName("GQA") + " GQA  " + chr(13) 
cQry += "	 WHERE " + chr(13)
cQry += "	  GQA.D_E_L_E_T_ = ' ' " + chr(13)
cQry += "     AND GQA.GQA_CODESC = '" + cCodigo + "') QtdVeic  " + chr(13)


cQry += "FROM  " + chr(13)
cQry += "	" + RetSQLName("G52") + " G52 " + chr(13)
cQry += "INNER JOIN " + RetSQLName("GID") + " GID " + chr(13)
cQry += "	ON GID.GID_COD = G52.G52_SERVIC  " + chr(13)
cQry += "	AND GID.GID_HIST = '2' " + chr(13)
cQry += "	AND GID.D_E_L_E_T_ = ' ' " + chr(13)
cQry += "INNER JOIN " + RetSQLName("GI2") + " GI2 " + chr(13) 
cQry += "	ON GI2.GI2_COD = G52.G52_LINHA	 " + chr(13)
cQry += "	AND GI2.GI2_HIST = '2' " + chr(13)
cQry += "		AND GI2.D_E_L_E_T_ = ' ' " + chr(13)
cQry += "	INNER JOIN " + RetSQLName("GI1") + " GI1ORI " + chr(13)
cQry += "		ON GI1ORI.GI1_COD = GI2.GI2_LOCINI " + chr(13)
cQry += "		AND GI1ORI.D_E_L_E_T_ = ' ' " + chr(13)
cQry += "	INNER JOIN " + RetSQLName("GI1") + " GI1DST " + chr(13)
cQry += "		ON GI1DST.GI1_COD = GI2.GI2_LOCFIM " + chr(13)
cQry += "		AND GI1DST.D_E_L_E_T_ = ' ' " + chr(13)
cQry += "    WHERE " + chr(13)
cQry += "        G52.G52_FILIAL = '" +  xFilial("G52") + "' " + chr(13)
cQry += "        AND G52.D_E_L_E_T_ = ' ' " + chr(13)   
cQry += "        AND G52.G52_CODIGO = '" + cCodigo + "' " + chr(13)
//cQry += "	ORDER BY G52.G52_SEQUEN "

//aIndexes := {{"IDX",{"GYE_DTREF","GYP_ESCALA","GYP_ITEM"}}}

aAdd(aIndexes,{"IDX1",{"G52_SEQUEN"}})
aAdd(aIndexes,{"IDX2",{"G52_SEQUEN","G52_DIA","G52_HRSDGR"}})

GTPTemporaryTable(cQry,,aIndexes,{{"GID_INIVIG","D",8},{"GID_FINVIG","D",8}},@oTableTmp) //oTable := GTPTemporaryTable(cQry,cAliasQry,aIndexes,{{"GID_INIVIG","D",8},{"GID_FINVIG","D",8}})
cAliasQry	:= oTableTmp:GetAlias()
nKmMes		:=	RetKmMes(cAliasQry)     

ImprCabec(oReport,cAliasQry,nKmMes,cCodigo)
    
nLinha := 0500
WHILE ((cAliasQry)->(!Eof()))
	
	nDiaAux	:= (cAliasQry)->G52_DIA 
	
	oReport:Box(nLinha, 0050, nLinha, 3170)
	oReport:Box(nLinha, 0050, nLinha+40, 0050)
	oReport:Box(nLinha, 0150, nLinha+40, 0150)
	oReport:Box(nLinha, 0280, nLinha+40, 0280)
	oReport:Box(nLinha, 0430, nLinha+40, 0430)
	oReport:Box(nLinha, 0580, nLinha+40, 0580)
	oReport:Box(nLinha, 0650, nLinha+40, 0650)
	oReport:Box(nLinha, 1750, nLinha+40, 1750)
	oReport:Box(nLinha, 1850, nLinha+40, 1850)
	oReport:Box(nLinha, 1950, nLinha+40, 1950)
	oReport:Box(nLinha, 2050, nLinha+40, 1950)
	oReport:Box(nLinha, 2190, nLinha+40, 2190)
	oReport:Box(nLinha, 2350, nLinha+40, 2350)
	oReport:Box(nLinha, 2450, nLinha+40, 2450)
	oReport:Box(nLinha, 2550, nLinha+40, 2550)
	oReport:Box(nLinha, 2650, nLinha+40, 2650)
	oReport:Box(nLinha, 2750, nLinha+40, 2750)
	oReport:Box(nLinha, 2750, nLinha+40, 2750)
	oReport:Box(nLinha, 2850, nLinha+40, 2850)
	oReport:Box(nLinha, 2890, nLinha+40, 2890)
	oReport:Box(nLinha, 2930, nLinha+40, 2930)
	oReport:Box(nLinha, 2970, nLinha+40, 2970)
	oReport:Box(nLinha, 3010, nLinha+40, 3010)
	oReport:Box(nLinha, 3050, nLinha+40, 3050)
	oReport:Box(nLinha, 3090, nLinha+40, 3090)
	oReport:Box(nLinha, 3130, nLinha+40, 3130)
	oReport:Box(nLinha, 3170, nLinha+40, 3170)
	
	oReport:Say(nLinha+5, 0070, (cAliasQry)->G52_SEQUEN, oArial08, 150)  
	oReport:Say(nLinha+5, 0170, Transform((cAliasQry)->GID_HORCAB, "@R 99:99"), oArial08, 150)  
	oReport:Say(nLinha+5, 0320, (cAliasQry)->GI2_NUMLIN, oArial08, 150)
	oReport:Say(nLinha+5, 0485, (cAliasQry)->GID_NUMSRV, oArial08, 150)
	oReport:Say(nLinha+5, 0600, CVALTOCHAR((cAliasQry)->G52_DIA), oArial08, 150)  	
	
	If ( (cAliasQry)->G52_SEC == "1" )
		
		aSeek := {}
		
		aData	:= {{"GZQ_ESCALA","GZQ_SEQESC","GZQ_SERVIC","GZQ_SEQSER"}}
		
		aAdd(aSeek,{"GZQ_FILIAL",xFilial("GZQ")})
		aAdd(aSeek,{"GZQ_ESCALA",(cAliasQry)->G52_CODIGO})
		aAdd(aSeek,{"GZQ_SEQESC",(cAliasQry)->G52_SEQUEN})

		If ( GTPSeekTable("GZQ",aSeek,aData) )
			
			nP := aScan(aData,{|x| Alltrim(x[2]) == Alltrim((cAliasQry)->G52_SEQUEN) })
			
			If ( nP > 0 )
			
				aUpd	:= {{"GIE_IDLOCP","GIE_IDLOCD"}}
				aSeek	:= {}
				
				aAdd(aSeek,{"GIE_CODGID",(cAliasQry)->G52_SERVIC})
				aAdd(aSeek,{"GIE_SEQ",aData[nP,4]})				
				
				If ( GTPSeekTable("GIE",aSeek,aUpd) )		
					
					cDscIni	:= Alltrim(Posicione("GI1",1,xFilial("GI1")+aUpd[2,1],"GI1_DESCRI"))
					cDscFim	:= Alltrim(Posicione("GI1",1,xFilial("GI1")+aUpd[2,2],"GI1_DESCRI"))
					(cAliasQry)->KM_TRECHO := GetKmSeccio((cAliasQry)->G52_SERVIC,aUpd[2,1],aUpd[2,2])
				EndIf
			
			EndIf
			
			/*
			cDscIni := ""
			cDscFim := ""
			Ga408bGetSeq((cAliasQry)->G52_SEC,(cAliasQry)->G52_SERVIC,(cAliasQry)->G52_CODIGO,(cAliasQry)->G52_SEQUEN,@cDscIni,@cDscFim)*/	
		
		EndIf
		
	Else
	
		TPNomeLinh((cAliasQry)->G52_LINHA,aLinha,(cAliasQry)->G52_SENTID)
			
		If ( Len(aLinha) > 0 )
		
			cDscIni := Alltrim(aLinha[1,2][1,2])
			cDscFim := Alltrim(aLinha[1,2][2,2])
			
		EndIf
	
	EndIf
	nKmAcum += ((cAliasQry)->KM_TRECHO +  (cAliasQry)->GI1_KMGRRD + (cAliasQry)->GI1_KMRDGR)
	
	oReport:Say(nLinha+5, 0660, Alltrim(cDscIni) + " / " + Alltrim(cDscFim), oArial08, 600)
	oReport:Say(nLinha+5, 1780, Transform((cAliasQry)->G52_HRSDGR, "@R 99:99"), oArial08, 150) 
	oReport:Say(nLinha+5, 1880, Transform((cAliasQry)->G52_HRSDRD, "@R 99:99"), oArial08, 150) 
	oReport:Say(nLinha+5, 1980, Transform((cAliasQry)->G52_HRCHRD, "@R 99:99"), oArial08, 150)  
	oReport:Say(nLinha+5, 2080, Transform((cAliasQry)->G52_HRCHGR, "@R 99:99"), oArial08, 150)  
	
	nDia := RetDiaValido(GTFormatHour((cAliasQry)->G52_HRSDGR,"99:99"),GTFormatHour((cAliasQry)->G52_HRCHGR,"99:99"))
	
	oReport:Say(nLinha+5, 2240, GTFormatHour(	DataHora2Val(dDataBase,TRANSF((cAliasQry)->G52_HRSDGR,'@R 99:99'),dDataBase + nDia ,TRANSF((cAliasQry)->G52_HRCHGR ,'@R 99:99'),'H'), "99:99"), oArial08, 150)
	
	oReport:Say(nLinha+5, 2360, Transform((cAliasQry)->G52_HRGRIN, "@R 99:99"), oArial08, 150)  
	oReport:Say(nLinha+5, 2460, Transform((cAliasQry)->G52_HRGRFI, "@R 99:99"), oArial08, 150)  
	nLinAux:=  nLinha+5
	
	nDia := RetDiaValido(GTFormatHour((cAliasQry)->G52_HRGRIN,"99:99"),GTFormatHour((cAliasQry)->G52_HRGRFI,"99:99"))
	
	//oReport:Say(nLinha+5, 2560, Transform((cAliasQry)->G52_HRGRFI-(cAliasQry)->G52_HRGRIN, "@R 99:99"), oArial08, 150) 
	oReport:Say(nLinha+5, 2560, GTDeltaTime(dDataBase,GTFormatHour((cAliasQry)->G52_HRGRIN, "99:99"), dDataBase + nDia, GTFormatHour((cAliasQry)->G52_HRGRFI, "99:99") ), oArial08, 150)
	
	oReport:Say(nLinha+5, 2680, cValToChar((cAliasQry)->KM_TRECHO + (cAliasQry)->GI1_KMGRRD + (cAliasQry)->GI1_KMRDGR), oArial08, 150)		    
	oReport:Say(nLinha+5, 2760, cValToChar(nKmAcum), oArial08, 150)  
	oReport:Say(nLinha+5, 2860, (cAliasQry)->G52_DOMING, oArial08, 150)  
	oReport:Say(nLinha+5, 2900, (cAliasQry)->G52_SEGUND, oArial08, 150)  
	oReport:Say(nLinha+5, 2940, (cAliasQry)->G52_TERCA, oArial08, 150)  
	oReport:Say(nLinha+5, 2980, (cAliasQry)->G52_QUARTA, oArial08, 150)  
	oReport:Say(nLinha+5, 3020, (cAliasQry)->G52_QUINTA, oArial08, 150)  
	oReport:Say(nLinha+5, 3060, (cAliasQry)->G52_SEXTA, oArial08, 150)  
	oReport:Say(nLinha+5, 3100, (cAliasQry)->G52_SABADO, oArial08, 150)  
	oReport:Say(nLinha+5, 3140, cValToChar((cAliasQry)->G52_DIAPAR), oArial08, 150)  
	
	cHGIAux 	:= GTFormatHour((cAliasQry)->G52_HRGRIN,"99:99")
	nDia		:= (cAliasQry)->G52_DIA
	cHrSaiGr	:= (cAliasQry)->G52_HRSDGR
	cLocPart	:= (cAliasQry)->GI2_LOCFIM 
	
	//Armazena frequencia 
	aAdd(aDiasSem,(cAliasQry)->G52_DOMING)
	aAdd(aDiasSem,(cAliasQry)->G52_SEGUND)
	aAdd(aDiasSem,(cAliasQry)->G52_TERCA)
	aAdd(aDiasSem,(cAliasQry)->G52_QUARTA)
	aAdd(aDiasSem,(cAliasQry)->G52_QUINTA)
	aAdd(aDiasSem,(cAliasQry)->G52_SEXTA)
	aAdd(aDiasSem,(cAliasQry)->G52_SABADO)
	   
   (cAliasQry)->(DbSkip())
   
   	nLinha += 40

	IF nLinha > oReport:PageHeight()-200
		oReport:Box(nLinha, 0050, nLinha, 3170)
		oReport:Say(nLinha+20, 3000, STR0035 + cValToChar(oReport:oPage:nPage), oArial08, 150)  // Página"
		oReport:EndPage()
		oReport:StartPage()
		nLinha := 0500
		ImprCabec(oReport,cAliasQry,nKmMes,cCodigo)
	ENDIF
	
	//Verifica a necessidade realizar quebra de linha no relatorio analisando frequencia eo dia 
	If !(aDiasSem[1] == (cAliasQry)->G52_DOMING .AND. aDiasSem[2] == (cAliasQry)->G52_SEGUND;
		.AND. aDiasSem[3] == (cAliasQry)->G52_TERCA .AND. aDiasSem[4] == (cAliasQry)->G52_QUARTA;
		.AND. aDiasSem[5] == (cAliasQry)->G52_QUINTA .AND. aDiasSem[6] == (cAliasQry)->G52_SEXTA;
		.AND. aDiasSem[7] == (cAliasQry)->G52_SABADO) .OR. nDiaAux <> (cAliasQry)->G52_DIA
   		
   		nKmAcum	 := 0
   		oReport:Box(nLinha, 0050, nLinha+40, 3170)
		nLinha:= nLinha+40
		
	EndIf
	aDiasSem := {}   
END WHILE
        
// oTable:Delete()//(cAliasQry)->(DbCloseArea())

oReport:Box(nLinha, 0050, nLinha, 3170)
oReport:Say(nLinha+40, 2900, STR0035 + cValToChar(oReport:oPage:nPage), oArial07, 150)  // Página"

oReport:Finish()

oReport:lNoPrint := .F.
    
Return Nil


Static Function RetVeic(cCodEsc)
Local cAliasVeic := GetNextAlias()
Local aRet := {}

BeginSQL Alias cAliasVeic

	SELECT 
		GQA.GQA_CODVEI 
	FROM 
		%table:GQA% GQA
	WHERE
		GQA.GQA_CODESC = %Exp:cCodEsc%
		AND GQA.%NotDel%

EndSQL

WHILE ((cAliasVeic)->(!Eof()))

	aAdd(aRet,(cAliasVeic)->GQA_CODVEI)
	
	(cAliasVeic)->(DbSkip())
END

Return aRet



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetDiaValido()
Rotina responsavel em retornar se a faixa de horas definidas nos parametros
ultrapassou da 00:00. 

@Param		cHrIni = Horário de Inicio 
@Param		cHrFim = Horário de Final 
@Return 	nDia = 1 Se virou o dia / 0 Continua no mesmo dia
@sample	RetDiaValido()
@author	Inovação
@since		20/11/2015
@version	P12
/*/
//-----------------------------------------------------------------------------------------

Static Function RetDiaValido(cHrIni,cHrFim)

Local nDia := 0
	
If ( cHrFim < cHrIni )
	nDia := 1
EndIf

Return(nDia)
/*/{Protheus.doc} RetKmMes()
	Calcula km mes
	@type  Function
	@author Fernando Radu Muscalu
	@since 19/10/2017
	@version version
	@param	cLinha, caractere, Código da Linha
			cDireção, caractere, "O" - Origem; "D" - destino
	@return cRet, caractere, Código da localidade
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RetKmMes(cAliasQry)
Local nKmMes	:= 0
Local aSemana		:= {}
//Local cCodManut	:= (cAliasQry)->LOC_MANUT 
Local nQtdVeic	:= (cAliasQry)->QtdVeic
Local nI		:= 0 
Local nKmTotal	:= 0 
Local nKmAcum	:= 0 
Local nFreq		:= 0 
Local nDiaAux	:= 0 


(cAliasQry)->(DbSetOrder(1))
(cAliasQry)->(DbGoTop())

cCodManut	:= (cAliasQry)->LOC_MANUT 
WHILE ((cAliasQry)->(!Eof()))
	nDiaAux	:= (cAliasQry)->G52_DIA 
	nKmAcum += ((cAliasQry)->KM_TRECHO +  (cAliasQry)->GI1_KMGRRD + (cAliasQry)->GI1_KMRDGR)
	
	//Armazena frequencia 
	aAdd(aSemana,(cAliasQry)->G52_DOMING)
	aAdd(aSemana,(cAliasQry)->G52_SEGUND)
	aAdd(aSemana,(cAliasQry)->G52_TERCA)
	aAdd(aSemana,(cAliasQry)->G52_QUARTA)
	aAdd(aSemana,(cAliasQry)->G52_QUINTA)
	aAdd(aSemana,(cAliasQry)->G52_SEXTA)
	aAdd(aSemana,(cAliasQry)->G52_SABADO)
	
	(cAliasQry)->(DbSkip())
	
	If !(aSemana[1] == (cAliasQry)->G52_DOMING .AND. aSemana[2] == (cAliasQry)->G52_SEGUND;
		.AND. aSemana[3] == (cAliasQry)->G52_TERCA .AND. aSemana[4] == (cAliasQry)->G52_QUARTA;
		.AND. aSemana[5] == (cAliasQry)->G52_QUINTA .AND. aSemana[6] == (cAliasQry)->G52_SEXTA;
		.AND. aSemana[7] == (cAliasQry)->G52_SABADO) .OR. nDiaAux <> (cAliasQry)->G52_DIA
   		
   		For nI := 1 to Len(aSemana)
   			If !Empty(aSemana[nI])
   				nFreq++
   			EndIf  
   		Next
   		
   		If nFreq < 6
   			nKmTotal	:= ((nKmAcum * 52 * nFreq)/nQtdVeic)/12
   		ElseIf nFreq == 6
   			nKmTotal	:= ((nKmAcum *  313)/nQtdVeic)/12
   		ElseIf nFreq == 7
   			nKmTotal	:= ((nKmAcum *  365)/nQtdVeic)/12
   		EndIf
   		nKmMes += nKmTotal
   		nFreq	 := 0
   		nKmTotal := 0
   		nKmAcum	 := 0
	EndIf
	aSemana := {}
	
	
EndDo
(cAliasQry)->(DbGoTop())
Return(nKmMes) 


Static Function GetKmSeccio(cServico,cLocOri,cLocDes)
Local nRet		:= 0
Local cTmpAlias	:= GetNextAlias()

	BeginSql Alias cTmpAlias
		SELECT 
			SUM(GI4_KM) AS KMTRECHO
		FROM %Table:GI4% GI4  
			INNER JOIN %Table:GIE% GIE ON
				GIE.GIE_CODGID = %Exp:cServico%
				AND GIE.GIE_LINHA = GI4.GI4_LINHA
				AND GIE.GIE_IDLOCP = GI4.GI4_LOCORI
				AND GIE.GIE_IDLOCD = GI4.GI4_LOCDES
				AND GIE.GIE_HIST = '2'
				AND GIE.%NotDel%
		WHERE
			GI4.GI4_FILIAL = %xFilial:GI4%
			AND GI4.GI4_LOCORI = %Exp:cLocOri%
			AND GI4.GI4_LOCDES = %Exp:cLocDes%
			AND GI4.GI4_HIST = '2'
			AND GI4.%NotDel%
	EndSql
	
	nRet := (cTmpAlias)->KMTRECHO
	(cTmpAlias)->(DbCloseArea())
Return nRet
