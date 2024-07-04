#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECR950.CH"
#INCLUDE "REPORT.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR950()
Relatório de Experiência no Posto

@sample 	TECR950()
@return		oReport
@author 	Kaique Schiller
@since		09/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECR950()
Local cPerg		:= "TECR950"
Local oReport	:= Nil

If TRepInUse()
	Pergunte(cPerg,.F.)
	oReport := Rt950RDef(cPerg)
	oReport:SetLandScape()
	oReport:PrintDialog()
EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt981RDef()
Monta as Sections para impressão do relatório

@sample Rt981RDef(cPerg)
@param 	cPerg 
@return oReport

@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt950RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local oSection2  	:= Nil				
Local cAlias1		:= GetNextAlias()

oReport   := TReport():New("TECR950",STR0001,cPerg,{|oReport| Rt950Print(oReport, cPerg, cAlias1)},STR0001) //"Experiência"

oSection1 := TRSection():New(oReport	,STR0002 ,{"TFF","TDW","SRJ"},,,,,,,,,,,,,.T.) //"Posto"
DEFINE CELL NAME "TFF_COD"		OF oSection1 TITLE STR0003 ALIAS "TFF" //"Cod. Posto"
DEFINE CELL NAME "TFF_ESCALA"	OF oSection1 ALIAS "TFF"
DEFINE CELL NAME "TFF_DESESC" 	OF oSection1 TITLE STR0004 SIZE (TamSX3("TDW_DESC")[1]) BLOCK {|| Posicione("TDW",1, xFilial("TDW")+PadR(Trim((cAlias1)->(TFF_ESCALA)), TamSx3("TDW_DESC")[1]),"TDW->TDW_DESC") } //"Desc. Escala"
DEFINE CELL NAME "TFF_FUNCAO"	OF oSection1 ALIAS "TFF" 
DEFINE CELL NAME "TFF_DESFUN" 	OF oSection1 TITLE STR0005 SIZE (TamSX3("RJ_DESC")[1]) BLOCK {|| Posicione("SRJ",1, xFilial("SRJ")+PadR(Trim((cAlias1)->(TFF_FUNCAO)), TamSx3("RJ_DESC")[1]),"SRJ->RJ_DESC") } //"Desc. Função"
DEFINE CELL NAME "TFF_PERINI"	OF oSection1 ALIAS "TFF" 
DEFINE CELL NAME "TFF_PERFIM"	OF oSection1 ALIAS "TFF"

oSection2 := TRSection():New(oSection1	,STR0005 ,{"AA1","ABB"},,,,,,,,,,3,,,.T.) //"Atendente"
DEFINE CELL NAME "ABB_CODTEC"		OF oSection2 TITLE STR0006 ALIAS "ABB" //"Codigo do Tec"
DEFINE CELL NAME "ABB_NOMTEC"	 	OF oSection2 TITLE STR0007 SIZE (TamSX3("AA1_NOMTEC")[1]) BLOCK {|| Posicione("AA1",1, xFilial("AA1")+PadR(Trim((cAlias1)->ABB_CODTEC), TamSx3("AA1_NOMTEC")[1]),"AA1->AA1_NOMTEC") } //"Nome Atend."
DEFINE CELL NAME "ABB_QTDDIAS"	    OF oSection2 TITLE STR0008 BLOCK {|| At961QtdAg((cAlias1)->TFF_FILIAL,(cAlias1)->TFF_COD,(cAlias1)->ABB_CODTEC) } //"Qtd. Dias Aloc."

oSection2:Cell("ABB_QTDDIAS"):SetAlign("LEFT")

Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt981Print()
Monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt981Print(oReport, cPerg, cAlias1)
@param		oReport, 	Object,	Objeto do relatório de postos vagos
			cPerg, 		String,	Nome do grupo de perguntas
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum
@author 	Kaique Schiller
@since		09/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt950Print(oReport, cPerg, cAlias1)
Local oSection1	:= oReport:Section(1)
Local oSection2	:= oSection1:Section(1) 	
Local cCodTFF	:= ""
Local lFinalPrint := .F.

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1
	Column TFF_PERINI as DATE
	Column TFF_PERFIM as DATE
	
	SELECT DISTINCT TFF.TFF_FILIAL,TFF.TFF_COD,TFF.TFF_ESCALA,TFF.TFF_FUNCAO,TFF.TFF_PERINI,TFF.TFF_PERFIM,ABB.ABB_CODTEC
	FROM %table:TFF% TFF
        INNER JOIN %table:ABQ% ABQ ON (ABQ.ABQ_FILIAL=%xfilial:ABQ% AND ABQ.%notDel% AND ABQ.ABQ_FILTFF = TFF.TFF_FILIAL AND ABQ.ABQ_CODTFF=TFF.TFF_COD)
        INNER JOIN %table:ABB% ABB ON (ABB.ABB_FILIAL=%xFilial:ABB% AND ABB.ABB_IDCFAL=ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM||'CN9' AND ABB.%NotDel%)
        INNER JOIN %table:TDV% TDV ON (TDV.TDV_FILIAL=%xFilial:TDV% AND TDV.TDV_CODABB=ABB.ABB_CODIGO AND TDV.%NotDel%)
	WHERE TFF.%notDel% AND TFF.TFF_FILIAL=%xfilial:TFF%
	AND ABB.ABB_CODTEC BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	AND TDV.TDV_DTREF  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
	AND TFF.TFF_LOCAL  BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
	AND TFF.TFF_ESCALA BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR09%
	AND TFF.TFF_CONTRT BETWEEN %Exp:MV_PAR10% AND %Exp:MV_PAR11%
	AND ABB.ABB_ATIVO = '1'
	ORDER BY TFF.TFF_FILIAL,TFF.TFF_COD,ABB.ABB_CODTEC

EndSql

END REPORT QUERY oSection1

(cAlias1)->(DbGoTop())

oSection2:SetParentQuery()

While !(cAlias1)->(EOF())
	If !IsBlind()
		nQtdAgd := At961QtdAg((cAlias1)->TFF_FILIAL,(cAlias1)->TFF_COD,(cAlias1)->ABB_CODTEC)
		If nQtdAgd > Val(MV_PAR05)
			If cCodTFF <> (cAlias1)->TFF_COD
				If lFinalPrint
					oSection1:Finish()
					oSection2:Finish()
					lFinalPrint := .F.
				Endif
				oSection1:Init()
				oSection1:PrintLine()
				oSection2:Init()
			Endif
			oSection2:PrintLine()
			lFinalPrint := .T.
		Endif
		cCodTFF := (cAlias1)->TFF_COD
	EndIf
	(cAlias1)->(DbSkip())
EndDo

(cAlias1)->(DbCloseArea())
          
Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At961QtdAg()
Quantidade de dias trabalhados

@sample 	At961QtdAg(cCodTFF,cCodAtend)
@param		cCodTFF, 	String,	Codigo de posto
			cAtend, 	String,	Codigo do atendente

@return 	nQtdAgd, Numeric, Quantidade de dias trabalhados
@author 	Kaique Schiller
@since		27/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At961QtdAg(cFilTFF,cCodTFF,cAtend)
Local cAliasQry	:= GetNextAlias()
Local nQtdAgd	:= 0

BeginSQL Alias cAliasQry
	SELECT COUNT(TDV.TDV_DTREF)
	FROM %table:ABQ% ABQ
		INNER JOIN %table:ABB% ABB ON (ABB.ABB_FILIAL=%xFilial:ABB% AND ABB.ABB_IDCFAL=ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM||'CN9' AND ABB.%NotDel%)
		INNER JOIN %table:TDV% TDV ON (TDV.TDV_FILIAL=%xFilial:TDV% AND TDV.TDV_CODABB = ABB.ABB_CODIGO AND TDV.%NotDel%)
	WHERE ABQ.ABQ_FILIAL=%xFilial:ABQ% AND ABQ.ABQ_CODTFF=%Exp:cCodTFF% AND ABQ.%NotDel%
	AND ABQ.ABQ_FILTFF = %Exp:cFilTFF%
	AND ABQ.ABQ_CODTFF = %Exp:cCodTFF%
	AND TDV.TDV_DTREF BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
	AND ABB.ABB_CODTEC = %Exp:cAtend%
	AND ABB.ABB_ATIVO = '1'
	GROUP BY TDV.TDV_DTREF
EndSql

(cAliasQry)->(DbGoTop())

While !(cAliasQry)->(EOF())
	nQtdAgd++
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

Return nQtdAgd
