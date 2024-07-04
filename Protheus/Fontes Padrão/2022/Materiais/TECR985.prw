#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECR985.CH"
#INCLUDE "REPORT.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR985()
Relatório de SDF

@sample 	TECR985()
@return		oReport
@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECR985()
Local cPerg		:= "TECR980"
Local oReport	:= Nil

If TRepInUse()
	Pergunte(cPerg,.F.)		
	oReport := Rt985RDef(cPerg)
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
Static Function Rt985RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local oSection2  	:= Nil				
Local cAlias1		:= GetNextAlias()

oReport   := TReport():New("TECR985",STR0001,cPerg,{|oReport| Rt985Print(oReport, cPerg, cAlias1)},STR0001) //"SDF"

oSection1 := TRSection():New(oReport	,STR0002 ,{"TDV"},,,,,,,,,,,,,.T.) //"Dia"
DEFINE CELL NAME "TDV_DTREF"	OF oSection1 ALIAS "TDV"
DEFINE CELL NAME "TDV_DIASEM"	OF oSection1 TITLE STR0003 BLOCK {|| TECCdow(Dow((cAlias1)->TDV_DTREF)) } //"Dia da Semana"
DEFINE CELL NAME "TDV_DESFER"	OF oSection1 TITLE STR0004 BLOCK {|| At985Feri((cAlias1)->TFF_CALEND,(cAlias1)->TDV_DTREF)[2] } //"Descr. Feriado"

oSection2 := TRSection():New(oSection1	,STR0005 ,{"TDV","ABB"},,,,,,,,,,3,,,.T.) //"Agenda"
DEFINE CELL NAME "ABB_CODTEC"		OF oSection2 TITLE STR0006 ALIAS "ABB" //"Codigo do Tec"
DEFINE CELL NAME "ABB_NOMTEC"	 	OF oSection2 TITLE STR0007 SIZE (TamSX3("AA1_NOMTEC")[1]) BLOCK {|| Posicione("AA1",1, xFilial("AA1")+PadR(Trim((cAlias1)->ABB_CODTEC), TamSx3("AA1_NOMTEC")[1]),"AA1->AA1_NOMTEC") } //"Nome Atend."
DEFINE CELL NAME "ABB_DTINI"		OF oSection2 TITLE STR0008 ALIAS "ABB" //"Dt. Início"
DEFINE CELL NAME "ABB_HRINI"		OF oSection2 TITLE STR0009 ALIAS "ABB" //"Hr. Inicial" 
DEFINE CELL NAME "ABB_DTFIM"		OF oSection2 TITLE STR0010 ALIAS "ABB" //"Dt. Final"
DEFINE CELL NAME "ABB_HRFIM"		OF oSection2 TITLE STR0011 ALIAS "ABB" //"Hr. Final"
DEFINE CELL NAME "TDV_TPDIA"	    OF oSection2 TITLE STR0012 //"Dia Trabalhado?"

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
@since		27/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt985Print(oReport, cPerg, cAlias1)
Local oSection1	:= oReport:Section(1)		
Local oSection2	:= oSection1:Section(1) 	

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1
	Column TDV_DTREF as DATE

	SELECT TDV.TDV_DTREF, TDV.TDV_TPDIA, TFF.TFF_COD, ABB.ABB_CODTEC, TFF_CONTRT, TFF_CONREV, TFF_ESCALA,
		   ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_DTINI, ABB.ABB_DTFIM, TFF.TFF_CALEND
	FROM %table:TDV% TDV
	INNER JOIN %table:ABB% ABB ON (ABB.ABB_FILIAL=%xFilial:ABB% AND ABB.ABB_CODIGO=TDV.TDV_CODABB AND ABB.%NotDel%)
	INNER JOIN %table:ABQ% ABQ ON (ABQ_FILIAL=%xfilial:ABQ% AND ABQ.%notDel% AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM)
	INNER JOIN %table:TFF% TFF ON (TFF.TFF_COD=ABQ.ABQ_CODTFF AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND TFF.%notDel%)
	WHERE TDV.%notDel% AND TDV.TDV_FILIAL=%xfilial:TDV%
	AND ABB.ABB_CODTEC BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	AND TDV.TDV_DTREF  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
	AND TFF.TFF_LOCAL  BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
	AND TFF.TFF_ESCALA BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
	AND TFF.TFF_CONTRT BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
	AND ABB.ABB_ATIVO = '1'
	ORDER BY TDV.TDV_DTREF,ABB.ABB_CODTEC,ABB.ABB_DTINI,ABB.ABB_HRINI

EndSql

END REPORT QUERY oSection1

(cAlias1)->(DbGoTop())

oSection1:SetLineCondition({|| cValToChar(Dow((cAlias1)->TDV_DTREF))$"7|1" .Or. At985Feri((cAlias1)->TFF_CALEND,(cAlias1)->TDV_DTREF)[1] })

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->TDV_DTREF == cParam},{|| (cAlias1)->TDV_DTREF})

oSection1:Print()

(cAlias1)->(DbCloseArea())
          
Return(.T.)
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At985Feri()


@sample 	At985Feri(cCalend,dDtRef)
@param		cCalend, String, Calendário de feriados do posto 
			dDtRef,	 Data,	 Data de referencia
			
@return 	aRetFer
@author 	Kaique Schiller
@since		27/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At985Feri(cCalend,dDtRef)
Local cAliasQry := GetNextAlias()
Local aRetFer   := {.F.,""}

If !Empty(cCalend)
	BeginSQL Alias cAliasQry
		Column RR0_DATA as DATE
		SELECT RR0.RR0_FIXO,RR0.RR0_DATA ,RR0.RR0_DESC
		FROM %table:AC0% AC0
		INNER JOIN %table:RR0% RR0 ON (RR0.RR0_FILIAL=%xFilial:RR0% 
			AND RR0.RR0_CODCAL=AC0.AC0_CODIGO AND RR0.%NotDel%)
		WHERE AC0.%notDel% AND AC0.AC0_FILIAL=%xfilial:AC0%
			AND AC0.AC0_CODIGO = %Exp:cCalend%
	EndSql
	While !(cAliasQry)->(EOF())
		If ((cAliasQry)->RR0_FIXO == "S" .And. SubStr(DtoS((cAliasQry)->RR0_DATA),5,8) == SubStr(DtoS(dDtRef),5,8)) .Or.;
			((cAliasQry)->RR0_FIXO == "N" .And. (cAliasQry)->RR0_DATA == dDtRef)
			aRetFer[1] := .T.
			aRetFer[2] := (cAliasQry)->RR0_DESC
			Exit
		Endif
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

Endif

Return aRetFer
