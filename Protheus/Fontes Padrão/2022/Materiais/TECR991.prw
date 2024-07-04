#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECR991.CH"
#INCLUDE "REPORT.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR991()
Relatório de Sobra Plantão

@sample 	TECR983()
@return		oReport
@author 	Augusto Albuquerque
@since		10/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECR991()
Local cPerg		:= "TECR991"
Local oReport	:= Nil

If TRepInUse() 
	Pergunte(cPerg,.F.)		
	oReport := Rt991RDef(cPerg)
	oReport:SetLandScape()
	oReport:PrintDialog()
EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt991RDef()
Monta as Sections para impressão do relatório

@sample Rt991RDef(cPerg)
@param 	cPerg 
@return oReport

@author 	Augusto Albuquerque
@since		10/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt991RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local oSection2  	:= Nil				
Local oSection3 	:= Nil
Local cAlias1		:= GetNextAlias()

oReport   := TReport():New("TECR991",STR0001,cPerg,{|oReport| Rt991Print(oReport, cPerg, cAlias1)},STR0001) //"Sobra de Plantão"

oSection1 := TRSection():New(oReport	,STR0002 ,{"TDV"},,,,,,,,,,3,,,.T.) //"Data de Referencia"
DEFINE CELL NAME "TDV_DTREF"	OF oSection1 ALIAS "TDV"

oSection2 := TRSection():New(oSection1	,STR0003 ,{"TFF","ABS", "TFL", "TFJ"},,,,,,,,,,6,,,.T.) //"Posto"
DEFINE CELL NAME "TFF_DESESC" 	OF oSection2 TITLE STR0004 SIZE (TamSX3("TDW_DESC")[1]) BLOCK {|| Posicione("TDW",1, xFilial("TDW")+PadR(Trim((cAlias1)->(TFF_ESCALA)), TamSx3("TDW_DESC")[1]),"TDW->TDW_DESC") } //"Descrição da Escala"
DEFINE CELL NAME "TFF_DESCRI"	OF oSection2 TITLE STR0005 SIZE (TamSX3("ABS_DESCRI")[1]) BLOCK {|| Posicione("ABS",1, xFilial("ABS")+PadR(Trim((cAlias1)->(TFL_LOCAL)), TamSx3("ABS_DESCRI")[1]),"ABS->ABS_DESCRI") } //"Descrição do Local"
DEFINE CELL NAME "TFF_CONTRT"	OF oSection2 ALIAS "TFF" TITLE STR0006 //"Contrato"
DEFINE CELL NAME "TFF_CONREV"	OF oSection2 ALIAS "TFF" TITLE STR0007 //"Revisão"
DEFINE CELL NAME "TFF_COD"		OF oSection2 ALIAS "TFF" TITLE STR0008 //"Codigo do Posto"

oSection3 := TRSection():New(oSection2	,STR0016 ,{"ABB"},,,,,,,,,,9,,,.T.) //"Agenda"
DEFINE CELL NAME "ABB_CODTEC"		OF oSection3 TITLE STR0009 ALIAS "ABB" //"Cod do Tecnico"
DEFINE CELL NAME "ABB_NOMTEC"		OF oSection3 TITLE STR0010 ALIAS "ABB" //"Nome do Tecnico"
DEFINE CELL NAME "ABB_HRTOT"		OF oSection3 TITLE STR0011 ALIAS "ABB" //"Hora Total" 
DEFINE CELL NAME "ABB_HRINI"		OF oSection3 TITLE STR0012 ALIAS "ABB" //"Hr. Inicial" 
DEFINE CELL NAME "ABB_HRFIM"		OF oSection3 TITLE STR0013 ALIAS "ABB" //"Hr. Final"
DEFINE CELL NAME "ABB_DTINI"		OF oSection3 TITLE STR0014 ALIAS "ABB" //"Dt. Início"
DEFINE CELL NAME "ABB_DTFIM"		OF oSection3 TITLE STR0015 ALIAS "ABB" //"Dt. Final"

Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt991Print()
Monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt981Print(oReport, cPerg, cAlias1)
@param		oReport, 	Object,	Objeto do relatório de postos vagos
			cPerg, 		String,	Nome do grupo de perguntas
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum
@author 	Augusto Albuquerque
@since		10/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt991Print(oReport, cPerg, cAlias1)
Local cWhere	:= " 1 = 1 "
Local cSituac	:= ""
Local oSection1	:= oReport:Section(1)		
Local oSection2	:= oSection1:Section(1) 	
Local oSection3	:= oSection2:Section(1)
 	
MakeSqlExpr(cPerg)

If !Empty(MV_PAR07)
	If "IN" $ MV_PAR07 .OR. "BETWEEN" $ MV_PAR07
		cSituac := RIGHT(MV_PAR07, LEN(MV_PAR07) - 1)
		cSituac := LEFT(cSituac, LEN(cSituac) - 1)
		
		If AT('ABB_TIPOMV',MV_PAR07) > 0
			cWhere := " " + cSituac + " "
		Else
			cWhere := " ABB_TIPOMV " + cSituac + " "
		EndIf
	Else
		cWhere := " ABB_TIPOMV ='" + MV_PAR07 + "' "
	EndIf
EndIf

cWhere := "%" + cWhere + "%"

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1
	Column TDV_DTREF as DATE

	SELECT TDV.TDV_DTREF, TFF.TFF_COD, ABB.ABB_CODTEC, TFF_CONTRT, TFF_CONREV, AA1_NOMTEC ABB_NOMTEC, TFL_LOCAL, TFF_ESCALA,
			ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_HRTOT
	FROM %table:TDV% TDV
	INNER JOIN %table:ABB% ABB ON (ABB.ABB_FILIAL=%xFilial:ABB% AND ABB.ABB_CODIGO=TDV.TDV_CODABB AND ABB.%NotDel%)
	INNER JOIN %table:ABQ% ABQ ON (ABQ_FILIAL =  %xfilial:ABQ% AND ABQ.%notDel% AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM)
	INNER JOIN %table:TFF% TFF ON (TFF.TFF_COD = ABQ.ABQ_CODTFF AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND TFF.%notDel% AND TFF.TFF_ESCALA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%)
	INNER JOIN %table:TFL% TFL ON (TFL.TFL_CODIGO = TFF.TFF_CODPAI AND TFL.TFL_FILIAL = %xfilial:TFL% AND TFL.%notDel%)
	INNER JOIN %table:TFJ% TFJ ON (TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND TFJ.TFJ_FILIAL = %xfilial:TFJ% AND TFJ.%notDel% AND TFJ.TFJ_STATUS = '1'
		AND TFJ.TFJ_CONTRT BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%)
	INNER JOIN %table:ABS% ABS ON (ABS.ABS_LOCAL = TFL.TFL_LOCAL AND ABS.ABS_FILIAL = %xfilial:ABS% AND ABS.%notDel% AND ABS.ABS_RESTEC = '1'
		AND ABS.ABS_LOCAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%  )
	INNER JOIN %table:AA1% AA1 ON (AA1.AA1_FILIAL=%xFilial:AA1% AND AA1.AA1_CODTEC = ABB.ABB_CODTEC AND AA1.%NotDel%)
	INNER JOIN %table:TCU% TCU ON (TCU.TCU_FILIAL=%xFilial:TCU% AND TCU.TCU_COD = ABB.ABB_TIPOMV AND TCU.%NotDel% AND TCU.TCU_RESTEC = '1')
	WHERE 			
	TDV.%notDel% AND TDV_FILIAL =  %xfilial:TDV% 
	AND TDV.TDV_DTREF BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR09% 
	AND %Exp:cWhere%
	ORDER BY TDV.TDV_DTREF,TFF_COD,ABB_CODTEC,ABB_DTINI,ABB_HRINI

EndSql

END REPORT QUERY oSection1

(cAlias1)->(DbGoTop())

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->TDV_DTREF == cParam},{|| (cAlias1)->TDV_DTREF})

oSection3:SetParentQuery()
oSection3:SetParentFilter({|cParam| dTos((cAlias1)->TDV_DTREF)+(cAlias1)->TFF_COD == cParam},{|| dTos((cAlias1)->TDV_DTREF)+(cAlias1)->TFF_COD})

oSection1:Print()

(cAlias1)->(DbCloseArea())
          
Return(.T.)
