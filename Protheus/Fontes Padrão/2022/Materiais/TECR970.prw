#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECR970.CH"
#INCLUDE "REPORT.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR970()
Relatório de Escala por Posto

@sample 	TECR970()
@return		oReport
@author 	Kaique Schiller
@since		26/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECR970()
Local cPerg		:= "TECR970"
Local oReport	:=  Nil

If TRepInUse() 
	Pergunte(cPerg,.F.)		
	oReport := Rt970RDef(cPerg)
	oReport:SetLandScape()
	oReport:PrintDialog()
EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt970RDef()
Monta as Sections para impressão do relatório

@sample Rt970RDef(cPerg)
@param 	cPerg 
@return oReport

@author 	Kaique Schiller
@since		26/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt970RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local oSection2  	:= Nil				
Local cAlias1		:= GetNextAlias()
Local nX 			:= 0
Local nDiaSem		:= 0
Local nDias			:= 0
Local nQtdDias		:= Day(LastDate(MV_PAR01)) 
Local aDiasSem		:= {{"AA1_SEG",STR0001},; //"Seg" 
						{"AA1_TER",STR0002},; //"Ter"
						{"AA1_QUA",STR0003},; //"Qua"
						{"AA1_QUI",STR0004},; //"Qui"
						{"AA1_SEX",STR0005},; //"Sex"
						{"AA1_SAB",STR0006},; //"Sab"
						{"AA1_DOM",STR0007}}  //"Dom"

oReport   := TReport():New("TECR970",STR0008,cPerg,{|oReport| Rt970Print(oReport, cPerg, cAlias1)},STR0008) //"Escala por Posto"

oSection1 := TRSection():New(oReport	,FwX2Nome("TFF") ,{"TFF","TDW","SRJ","ABS"},,,,,,,,,,,,,.T.)
DEFINE CELL NAME "TFF_FILIAL"	OF oSection1 TITLE STR0009   ALIAS "TFF" //"Filial" 
DEFINE CELL NAME "TFF_COD"		OF oSection1 TITLE STR0010   ALIAS "TFF" //"Cod. Posto" 
DEFINE CELL NAME "TFF_ESCALA"	OF oSection1 ALIAS "TFF" BLOCK {|| (cAlias1)->TFF_ESCALA }
DEFINE CELL NAME "TFF_DESESC" 	OF oSection1 TITLE STR0011 SIZE (TamSX3("TDW_DESC")[1]) BLOCK {|| Posicione("TDW",1, xFilial("TDW")+PadR(Trim((cAlias1)->(TFF_ESCALA)), TamSx3("TDW_DESC")[1]),"TDW->TDW_DESC") } //"Desc. Escala"
DEFINE CELL NAME "TFF_FUNCAO"	OF oSection1 ALIAS "TFF" BLOCK {|| (cAlias1)->TFF_FUNCAO }
DEFINE CELL NAME "TFF_DESFUN" 	OF oSection1 TITLE STR0012 SIZE (TamSX3("RJ_DESC")[1]) BLOCK {|| Posicione("SRJ",1, xFilial("SRJ")+PadR(Trim((cAlias1)->(TFF_FUNCAO)), TamSx3("RJ_DESC")[1]),"SRJ->RJ_DESC") } //"Desc. Função"
DEFINE CELL NAME "TFF_PERINI"	OF oSection1 ALIAS "TFF" BLOCK {|| (cAlias1)->TFF_PERINI }
DEFINE CELL NAME "TFF_PERFIM"	OF oSection1 ALIAS "TFF" BLOCK {|| (cAlias1)->TFF_PERFIM }

oSection2 := TRSection():New(oSection1	,FwX2Nome("AA1") ,{"AA1"},,,,,,,,,,3,,,.T.)
DEFINE CELL NAME "AA1_CODTEC"		OF oSection2 ALIAS "AA1" 
DEFINE CELL NAME "AA1_NOMTEC"	 	OF oSection2 ALIAS "AA1" BLOCK {|| Posicione("AA1",1, xFilial("AA1")+PadR(Trim((cAlias1)->(AA1_CODTEC)), TamSx3("AA1_NOMTEC")[1]),"AA1->AA1_NOMTEC")  }

For nX := 1 To nQtdDias
	If nDiaSem == 7
		nDiaSem := 0
	Endif
	nDiaSem++
	DEFINE CELL NAME aDiasSem[nDiaSem,1]+cValtOChar(nX) OF oSection2 ALIAS TITLE aDiasSem[nDiaSem,2]+" "+SubStr(cValToChar(MV_PAR01+(nX-1)),1,2) SIZE 14 BLOCK {|| At970DiaAg((cAlias1)->TFF_FILIAL,(cAlias1)->TFF_COD,(cAlias1)->AA1_CODTEC,MV_PAR01,@nDias)}
Next nX

oReport:SetLandscape(.T.)
oSection2:SetLineStyle(.T.)

Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt970Print()
Monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt970Print(oReport, cPerg, cAlias1)
@param		oReport, 	Object,	Objeto do relatório de postos vagos
			cPerg, 		String,	Nome do grupo de perguntas
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum
@author 	Kaique Schiller
@since		26/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt970Print(oReport, cPerg, cAlias1)
Local oSection1	:= oReport:Section(1)		
Local oSection2	:= oSection1:Section(1)
Local cFilTFJ	:= "% TFJ.TFJ_FILIAL = '"+xFilial("TFJ")+"' %"
Local cFilTFL	:= "% TFL.TFL_FILIAL = '"+xFilial("TFL")+"' %"
Local cFilTFF	:= "% TFF.TFF_FILIAL = '"+xFilial("TFF")+"' %"
Local cFilABQ	:= "% ABQ.ABQ_FILIAL = '"+xFilial("ABQ")+"' %" 
Local cFilABB	:= "% ABB.ABB_FILIAL = '"+xFilial("ABB")+"' %" 
Local cFilTDV	:= "% TDV.TDV_FILIAL = '"+xFilial("TDV")+"' %"
Local cFilAA1	:= "% AA1.AA1_FILIAL = '"+xFilial("AA1")+"' %" 
Local cFilABS	:= "% ABS.ABS_FILIAL = '"+xFilial("ABS")+"' %" 
Local nQtdDias	:= Day(LastDate(MV_PAR01)) - 1   //29

MakeSqlExpr(cPerg)

If !Empty(MV_PAR10)
	cFilTFJ := "%" + MV_PAR10 + "%"
	cFilTFL := "%" + FWJoinFilial("TFL" , "TFJ" , "TFL", "TFJ", .T.) + "%"
	cFilTFF := "%" + FWJoinFilial("TFF" , "TFL" , "TFF", "TFL", .T.) + "%"
	cFilABQ := "%" + FWJoinFilial("ABQ" , "TFF" , "ABQ", "TFF", .T.) + "%"
	cFilABB := "%" + FWJoinFilial("ABB" , "ABQ" , "ABB", "ABQ", .T.) + "%"
	cFilTDV := "%" + FWJoinFilial("TDV" , "ABB" , "TDV", "ABB", .T.) + "%"
	cFilAA1 := "%" + FWJoinFilial("AA1" , "ABB" , "AA1", "ABB", .T.) + "%"
	cFilABS := "%" + FWJoinFilial("ABS" , "TFL" , "ABS", "TFL", .T.) + "%"
Endif

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1

	SELECT DISTINCT TFJ_FILIAL,
		   TFJ_CODIGO,
	       TFL_FILIAL,
		   TFL_CODIGO,
		   TFL_LOCAL,
    	   TFF_FILIAL,
    	   TFF_COD,
		   TFF_ESCALA,
		   TFF_FUNCAO,
		   TFF_PERINI,
		   TFF_PERFIM,
		   AA1_CODTEC
	FROM %table:TFJ% TFJ
		INNER JOIN %table:TFL% TFL ON (%Exp:cFilTFL% AND TFL.TFL_CODPAI=TFJ_CODIGO AND TFL.%NotDel%)
		INNER JOIN %table:TFF% TFF ON (%Exp:cFilTFF% AND TFF.TFF_CODPAI=TFL.TFL_CODIGO AND TFF.%NotDel%)
		INNER JOIN %table:ABQ% ABQ ON (%Exp:cFilABQ% AND ABQ.ABQ_CODTFF=TFF.TFF_COD AND ABQ.ABQ_FILTFF=TFF.TFF_FILIAL AND ABQ.%NotDel%)
		INNER JOIN %table:ABB% ABB ON (%Exp:cFilABB% AND ABB.ABB_IDCFAL=ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM||'CN9' AND ABB.%NotDel%)
		INNER JOIN %table:TDV% TDV ON (%Exp:cFilTDV% AND TDV.TDV_CODABB=ABB.ABB_CODIGO AND TDV.%NotDel%)
		INNER JOIN %table:AA1% AA1 ON (%Exp:cFilAA1% AND AA1.AA1_CODTEC=ABB.ABB_CODTEC AND AA1.%NotDel%)
		INNER JOIN %table:ABS% ABS ON (%Exp:cFilABS% AND ABS.ABS_LOCAL=TFF.TFF_LOCAL AND ABS.%NotDel%)
	WHERE %Exp:cFilTFJ%
		AND TFJ.%NotDel%
		AND TDV.TDV_DTREF  BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR01+nQtdDias%
        AND TFL.TFL_LOCAL  BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
        AND TFF.TFF_ESCALA BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
        AND TFJ.TFJ_CONTRT BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
		AND ABB.ABB_ATIVO = '1'
		AND TFJ.TFJ_STATUS = '1'
	ORDER BY TFJ_FILIAL,TFJ_CODIGO,TFL_FILIAL,TFL_CODIGO,TFF_FILIAL,TFF_COD,AA1_CODTEC
EndSql

END REPORT QUERY oSection1

(cAlias1)->(DbGoTop())

oSection1:SetLineCondition({|| At970Sup((cAlias1)->TFL_LOCAL) })

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->(TFF_FILIAL+TFF_COD) == cParam},{|| (cAlias1)->(TFF_FILIAL+TFF_COD) })

oSection1:Print()

(cAlias1)->(DbCloseArea())

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At970DiaAg()

@sample 	At970DiaAg(cCodTFF,cCodAtend)
@param		cFilTFF, 	String,	Filial
			cCodTFF, 	String,	Codigo de posto
			cCodAtend, 	String,	Codigo do atendente
			dDtRef, 	Data,	Data de referencia

@return 	cRetHr, Caracter, Horário inicio e fim da Agenda
@author 	Kaique Schiller
@since		26/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At970DiaAg(cFilTFF,cCodTFF,cCodAtend,dDtRef,nDias)
Local cAliasQry	:= GetNextAlias()
Local cRetHr	:= ""
Local cHrIni    := ""
Local cHrFim    := ""
Local cFilABB	:= "% ABB.ABB_FILIAL = '"+xFilial("ABB")+"' %" 
Local cFilTDV	:= "% TDV.TDV_FILIAL = '"+xFilial("TDV")+"' %" 
Local nQtdDias	:= Day(LastDate(MV_PAR01)) 

If nDias > nQtdDias
	nDias := 0
Endif

dDtRef := dDtRef+nDias
nDias++

If !Empty(MV_PAR10)
	cFilABB := "%" + FWJoinFilial("ABB" , "ABQ" , "ABB", "ABQ", .T.) + "%"
	cFilTDV := "%" + FWJoinFilial("TDV" , "ABB" , "TDV", "ABB", .T.) + "%"
Endif

BeginSQL Alias cAliasQry
	SELECT TDV.TDV_DTREF,ABB_HRINI,ABB_HRFIM
	FROM %table:ABB% ABB
	INNER JOIN %table:TDV% TDV ON (%Exp:cFilTDV% AND TDV.TDV_CODABB=ABB.ABB_CODIGO AND TDV.TDV_DTREF = %Exp:dDtRef% AND TDV.%NotDel%)
	WHERE ABB.ABB_CODTEC = %Exp:cCodAtend%
	AND ABB.ABB_ATIVO = '1'
	AND ABB.%NotDel%
EndSql

(cAliasQry)->(DbGoTop())

While !(cAliasQry)->(EOF())
    If Empty(cHrIni)
	    cHrIni := (cAliasQry)->ABB_HRINI
    Endif
    cHrFim := (cAliasQry)->ABB_HRFIM
	(cAliasQry)->(dbSkip())
EndDo

If !Empty(cHrIni) .And. !Empty(cHrFim)
    cRetHr := cHrIni+"|"+cHrFim
Endif

(cAliasQry)->(DbCloseArea())

Return cRetHr

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At970Sup()

@sample 	At970Sup(cCodTFF,cCodAtend)
@param		cLocal, 	String,	Filial

@return 	lRet, Logico, Exibe linha do cabeçalho TFF
@author 	Kaique Schiller
@since		26/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At970Sup(cLocal)
Local lRet := .T.
Local cAliasQry	:= GetNextAlias()
Local cFilTXI	:= "% TXI.TXI_FILIAL = '"+xFilial("TXI")+"' %"
Local nQtdDias	:= Day(LastDate(MV_PAR01)) -1		

If !Empty(MV_PAR10)
	cFilTXI := "%" + FWJoinFilial("TXI" , "ABS" , "TXI", "ABS", .T.) + "%"
Endif

BeginSQL Alias cAliasQry
	SELECT TXI.TXI_CODTEC,
		TXI.TXI_DTINI, 
		TXI.TXI_DTFIM
	FROM %table:TXI% TXI
	WHERE %Exp:cFilTXI%
	AND TXI.TXI_LOCAL = %Exp:cLocal%
	AND TXI.%NotDel%
EndSql

While (cAliasQry)->(!Eof())
	lRet := .F.
	If (cAliasQry)->TXI_CODTEC >= MV_PAR08 .And. (cAliasQry)->TXI_CODTEC <= MV_PAR09 .And.;
		((sTod((cAliasQry)->TXI_DTINI) <= MV_PAR01 .OR. sTod((cAliasQry)->TXI_DTINI) >= MV_PAR01 .And. sTod((cAliasQry)->TXI_DTINI) <= MV_PAR01+nQtdDias);
		.AND. (sTod((cAliasQry)->TXI_DTFIM) >= MV_PAR01+nQtdDias .OR. sTod((cAliasQry)->TXI_DTFIM) >= MV_PAR01 .And. sTod((cAliasQry)->TXI_DTFIM) <= MV_PAR01+nQtdDias );
		 .OR. sTod((cAliasQry)->TXI_DTINI) = sTod('') .OR. sTod((cAliasQry)->TXI_DTFIM) = sTod(''))
		lRet := .T.
		Exit
	Endif
	(cAliasQry)->(dbSkip())

EndDo

Return lRet
