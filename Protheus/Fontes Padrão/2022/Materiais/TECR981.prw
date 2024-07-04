#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECR981.CH"
#INCLUDE "REPORT.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR981()
Relatório de relação de efetivos

@sample 	TECR981()
@return		oReport
@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECR981()
Local cPerg		:= "TECR981"
Local oReport	:= Nil

If TRepInUse() 
	Pergunte(cPerg,.F.)		
	oReport := Rt981RDef(cPerg)
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
Static Function Rt981RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local oSection2  	:= Nil				
Local oSection3 	:= Nil
Local oSection4 	:= Nil
Local cAlias1		:= GetNextAlias()

oReport   := TReport():New("TECR981",STR0001,cPerg,{|oReport| Rt981Print(oReport, cPerg, cAlias1)},STR0001) //"Relação de Efetivos"

oSection1 := TRSection():New(oReport	,FwX2Nome("TFJ") ,{"TFJ"},,,,,,,,,,,,,.T.)
DEFINE CELL NAME "TFJ_CONTRT"		OF oSection1 ALIAS "TFJ"
DEFINE CELL NAME "TFJ_CONREV"		OF oSection1 ALIAS "TFJ"
			
oSection2 := TRSection():New(oSection1	,FwX2Nome("TFL") ,{"TFL","ABS"},,,,,,,,,,3,,,.T.)
DEFINE CELL NAME "TFL_LOCAL"	OF oSection2 ALIAS "TFL"
DEFINE CELL NAME "TFL_DESCRI"	OF oSection2 TITLE STR0002 SIZE (TamSX3("ABS_DESCRI")[1]) BLOCK {|| Posicione("ABS",1, xFilial("ABS")+PadR(Trim((cAlias1)->(TFL_LOCAL)), TamSx3("ABS_DESCRI")[1]),"ABS->ABS_DESCRI") } //"Desc. Local"		
DEFINE CELL NAME "TFL_DTINI"	OF oSection2 ALIAS "TFL"
DEFINE CELL NAME "TFL_DTFIM"	OF oSection2 ALIAS "TFL"

oSection3 := TRSection():New(oSection2	,FwX2Nome("TFF") ,{"TFF","TDW","SRJ"},,,,,,,,,,6,,,.T.)
DEFINE CELL NAME "TFF_COD"		OF oSection3 TITLE STR0003 ALIAS "TFF" //"Cod. Posto" 
DEFINE CELL NAME "TFF_ESCALA"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_DESESC" 	OF oSection3 TITLE STR0004 SIZE (TamSX3("TDW_DESC")[1]) BLOCK {|| Posicione("TDW",1, xFilial("TDW")+PadR(Trim((cAlias1)->(TFF_ESCALA)), TamSx3("TDW_DESC")[1]),"TDW->TDW_DESC") } //"Desc. Local"
DEFINE CELL NAME "TFF_FUNCAO"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_DESFUN" 	OF oSection3 TITLE STR0005 SIZE (TamSX3("RJ_DESC")[1]) BLOCK {|| Posicione("SRJ",1, xFilial("SRJ")+PadR(Trim((cAlias1)->(TFF_FUNCAO)), TamSx3("RJ_DESC")[1]),"SRJ->RJ_DESC") } //"Desc. Função"
DEFINE CELL NAME "TFF_QTDVEN"	OF oSection3 ALIAS "TFF" TITLE STR0006 //"Qtd. Posto"
DEFINE CELL NAME "TFF_PERINI"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_PERFIM"	OF oSection3 ALIAS "TFF"

oSection4 := TRSection():New(oSection3	,FwX2Nome("TGY") ,{"TGY","AA1"},,,,,,,,,,9,,,.T.)
DEFINE CELL NAME "TGY_ATEND"		OF oSection4 ALIAS "TGY"
DEFINE CELL NAME "TGY_NOME"	 		OF oSection4 TITLE STR0007 SIZE (TamSX3("AA1_NOMTEC")[1])  BLOCK {|| Posicione("AA1",1, xFilial("AA1")+PadR(Trim((cAlias1)->TGY_ATEND), TamSx3("AA1_NOMTEC")[1]),"AA1->AA1_NOMTEC") } //"Nome Atend."
DEFINE CELL NAME "TGY_DTINI"	 	OF oSection4 ALIAS "TGY"
DEFINE CELL NAME "TGY_DTFIM"	 	OF oSection4 ALIAS "TGY"
DEFINE CELL NAME "TGY_ULTALO"	 	OF oSection4 ALIAS "TGY"

Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt981Print()
Monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt981Print(oReport, cPerg, cAlias1)
@param		oReport, 	Object,	Objeto do relatório de postos vagos
			cPerg, 		String,	Nome do grupo de perguntas
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum
@author 	Kaique
@since		27/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt981Print(oReport, cPerg, cAlias1)
Local oSection1	:= oReport:Section(1)		
Local oSection2	:= oSection1:Section(1) 	
Local oSection3	:= oSection2:Section(1) 	
Local oSection4	:= oSection3:Section(1) 	
Local cWhere	:= "%%"

MakeSqlExpr(cPerg)

If !Empty(MV_PAR10)
	cWhere := "% AND "+MV_PAR10+" %"
Endif

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1

	SELECT TFJ_CONTRT, TFJ_CONREV, TFL_LOCAL, TFL_DTINI, TFL_DTFIM, 
           TFF_COD, TFF_ESCALA, TFF_FUNCAO, TFF_QTDVEN, TFF_PERINI, TFF_PERFIM, 
           TGY_ATEND, TGY_DTINI, TGY_DTFIM, TFL_CODPAI, TFJ_CODIGO, TFF_CODPAI, TGY_CODTFF, TFL_CODIGO, TGY_ULTALO
	FROM %table:TFJ% TFJ
	INNER JOIN %table:TFL% TFL ON (TFL.TFL_FILIAL=%xFilial:TFL% AND TFL.TFL_CODPAI=TFJ_CODIGO AND TFL.%NotDel%)
	INNER JOIN %table:TFF% TFF ON (TFF.TFF_FILIAL=%xFilial:TFF% AND TFF.TFF_CODPAI=TFL.TFL_CODIGO AND TFF.%NotDel%)
	INNER JOIN %table:TGY% TGY ON (TGY.TGY_FILIAL=%xFilial:TGY% AND TGY.TGY_CODTFF=TFF.TFF_COD AND TGY.%NotDel%)
	WHERE TFJ.TFJ_FILIAL=%xFilial:TFJ%
		AND TFJ.%NotDel%
        AND TGY.TGY_ULTALO <> ''
		AND TGY.TGY_ATEND BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND TFL.TFL_LOCAL BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND TFF.TFF_ESCALA BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
        AND TFJ.TFJ_CONTRT BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
		AND %Exp:MV_PAR09% BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM
        %Exp:cWhere%
	ORDER BY TFJ_CODIGO,TFL_CODIGO,TFF_COD,TGY_CODTFF

EndSql

END REPORT QUERY oSection1

(cAlias1)->(DbGoTop())

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->TFJ_CODIGO == cParam},{|| (cAlias1)->TFL_CODPAI })

oSection3:SetParentQuery()
oSection3:SetParentFilter({|cParam| (cAlias1)->TFL_CODIGO == cParam},{|| (cAlias1)->TFF_CODPAI })

oSection4:SetParentQuery()
oSection4:SetParentFilter({|cParam| (cAlias1)->TFF_COD == cParam},{|| (cAlias1)->TGY_CODTFF })

oSection1:Print()

(cAlias1)->(DbCloseArea())
          
Return(.T.)
