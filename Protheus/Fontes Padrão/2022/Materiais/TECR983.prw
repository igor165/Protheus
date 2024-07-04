#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECR983.CH"
#INCLUDE "REPORT.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR983()
Relatório de Posto Vago

@sample 	TECR983()
@return		oReport
@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECR983()
Local cPerg		:= "TECR983"
Local oReport	:= Nil

If TRepInUse() 
	Pergunte(cPerg,.F.)		
	oReport := Rt983RDef(cPerg)
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
Static Function Rt983RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local oSection2  	:= Nil				
Local oSection3 	:= Nil
Local cAlias1		:= GetNextAlias()

oReport   := TReport():New("TECR983",STR0001,cPerg,{|oReport| Rt983Print(oReport, cPerg, cAlias1)},STR0001) //"Posto Vago"

oSection1 := TRSection():New(oReport	,STR0002 ,{"TFJ"},,,,,,,,,,3,,,.T.) //"Orçamento"
DEFINE CELL NAME "TFJ_CONTRT"	OF oSection1 ALIAS "TFJ"
DEFINE CELL NAME "TFJ_CONREV"	OF oSection1 ALIAS "TFJ"

oSection2 := TRSection():New(oSection1	,STR0003 ,{"TFL","ABS"},,,,,,,,,,6,,,.T.) //"Locais"
DEFINE CELL NAME "TFL_LOCAL"	OF oSection2 ALIAS "TFL"
DEFINE CELL NAME "TFL_DESCRI"	OF oSection2 TITLE STR0004 SIZE (TamSX3("ABS_DESCRI")[1]) BLOCK {|| Posicione("ABS",1, xFilial("ABS")+PadR(Trim((cAlias1)->(TFL_LOCAL)), TamSx3("ABS_DESCRI")[1]),"ABS->ABS_DESCRI") } //"Desc. Local"		
DEFINE CELL NAME "TFL_DTINI"	OF oSection2 ALIAS "TFL"
DEFINE CELL NAME "TFL_DTFIM"	OF oSection2 ALIAS "TFL"

oSection3 := TRSection():New(oSection2	,"Postos" ,{"TFF","TDW","SRJ"},,,,,,,,,,9,,,.T.)
DEFINE CELL NAME "TFF_COD"		OF oSection3 TITLE STR0005 ALIAS "TFF" //"Cod. Posto" 
DEFINE CELL NAME "TFF_ESCALA"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_DESESC" 	OF oSection3 TITLE STR0006 SIZE (TamSX3("TDW_DESC")[1]) BLOCK {|| Posicione("TDW",1, xFilial("TDW")+PadR(Trim((cAlias1)->(TFF_ESCALA)), TamSx3("TDW_DESC")[1]),"TDW->TDW_DESC") } //"Desc. Local"
DEFINE CELL NAME "TFF_FUNCAO"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_DESFUN" 	OF oSection3 TITLE STR0007 SIZE (TamSX3("RJ_DESC")[1]) BLOCK {|| Posicione("SRJ",1, xFilial("SRJ")+PadR(Trim((cAlias1)->(TFF_FUNCAO)), TamSx3("RJ_DESC")[1]),"SRJ->RJ_DESC") } //"Desc. Função"
DEFINE CELL NAME "TFF_QTDVEN"	OF oSection3 ALIAS "TFF" TITLE STR0008 //"Qtd. Posto"
DEFINE CELL NAME "TFF_PERINI"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_PERFIM"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_QTDEFET" 	OF oSection3 TITLE STR0009 SIZE (TamSX3("TFF_QTDVEN")[1]) BLOCK {|| At983VagEf((cAlias1)->(TFF_QTDVEN),(cAlias1)->(TFF_ESCALA),(cAlias1)->(TFF_COD)) } //"Qtd. Vagas Efetivos"
DEFINE CELL NAME "TFF_QTDCOBE" 	OF oSection3 TITLE STR0010 SIZE (TamSX3("TFF_QTDVEN")[1]) BLOCK {|| At983VagCb((cAlias1)->(TFF_QTDVEN),(cAlias1)->(TFF_ESCALA),(cAlias1)->(TFF_COD))  } //"Qtd. Vagas Cobertura"
DEFINE CELL NAME "TFF_TOTVAGA" 	OF oSection3 TITLE STR0011 SIZE (TamSX3("TFF_QTDVEN")[1]) BLOCK {|| oSection3:Cell("TFF_QTDEFET"):GetValue(.T.)+oSection3:Cell("TFF_QTDCOBE"):GetValue(.T.) } //"Qtd. Total de Vagas"

DEFINE FUNCTION FROM oSection3:Cell("TFF_QTDEFET") OF oSection1 FUNCTION SUM TITLE STR0013 //"Qtd Vagas Efetivos"
DEFINE FUNCTION FROM oSection3:Cell("TFF_QTDCOBE") OF oSection1 FUNCTION SUM TITLE STR0012 //"Qtd Vagas Cobertura"
DEFINE FUNCTION FROM oSection3:Cell("TFF_TOTVAGA") OF oSection1 FUNCTION SUM TITLE STR0011 //"Qtd. Total Vagas Efetivos"

DEFINE FUNCTION FROM oSection3:Cell("TFF_QTDEFET") OF oSection2 FUNCTION SUM NO END REPORT TITLE STR0013 //"Qtd Vagas Efetivos"
DEFINE FUNCTION FROM oSection3:Cell("TFF_QTDCOBE") OF oSection2 FUNCTION SUM NO END REPORT TITLE STR0012 //"Qtd Vagas Cobertura"
DEFINE FUNCTION FROM oSection3:Cell("TFF_TOTVAGA") OF oSection2 FUNCTION SUM NO END REPORT TITLE STR0011 //"Qtd. Total Vagas Efetivos"

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
Static Function Rt983Print(oReport, cPerg, cAlias1)
Local oSection1	 := oReport:Section(1)		
Local oSection2	 := oSection1:Section(1) 	
Local oSection3	 := oSection2:Section(1) 	
Local cWhere	 := "%%"
Local cDtRef	 := DtOS(MV_PAR09)
Local cExpGerVag := "AND TFF.TFF_GERVAG != 2"

If !IsBlind()
	If MV_PAR10 == 1  
		cWhere := "% AND NOT EXISTS( " +;
						"SELECT 1 " +; 
						"FROM "+RetSqlName("TGY")+" TGY " +;
						"WHERE TGY.D_E_L_E_T_=' ' " +; 
							"AND TGY.TGY_FILIAL = '"+xFilial("TGY")+"' " +;
							"AND TGY.TGY_CODTFF = TFF.TFF_COD " +;
							"AND '"+cDtRef+"' BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM " +;
					") %"
	Endif
EndIf


If TecBHasGvg()
	cExpGerVag := "% " + cExpGerVag + "%"
Else
	cExpGerVag := "% %"
EndIf

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1

	SELECT TFJ_CONTRT, TFJ_CONREV, TFL_LOCAL, TFL_DTINI, TFL_DTFIM, 
           TFF_COD, TFF_ESCALA, TFF_FUNCAO, TFF_QTDVEN, TFF_PERINI, TFF_PERFIM, 
           TFL_CODPAI, TFJ_CODIGO, TFF_CODPAI, TFL_CODIGO
	FROM %table:TFJ% TFJ
	INNER JOIN %table:TFL% TFL ON (TFL.TFL_FILIAL=%xFilial:TFL% AND TFL.TFL_CODPAI=TFJ_CODIGO AND TFL.%NotDel%)
	INNER JOIN %table:TFF% TFF ON (TFF.TFF_FILIAL=%xFilial:TFF% AND TFF.TFF_CODPAI=TFL.TFL_CODIGO AND TFF.%NotDel%)
	WHERE TFJ.TFJ_FILIAL=%xFilial:TFJ%
		AND TFJ.TFJ_CONTRT <> ''
		AND TFF.TFF_ESCALA <> ''
		AND TFJ.TFJ_STATUS = '1'
		AND TFJ.%NotDel%
		%Exp:cExpGerVag%
        AND TFL.TFL_LOCAL 	BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND TFF.TFF_ESCALA 	BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND TFJ.TFJ_CONTRT 	BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
        AND TFF.TFF_COD 	BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
        AND TFF.TFF_COD 	BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
        AND %Exp:cDtRef%	BETWEEN TFF.TFF_PERINI AND TFF.TFF_PERFIM
        %Exp:cWhere%
	ORDER BY TFJ_CODIGO,TFL_CODIGO,TFF_COD

EndSql

END REPORT QUERY oSection1

(cAlias1)->(DbGoTop())

oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->TFJ_CODIGO == cParam},{|| (cAlias1)->TFL_CODPAI })

oSection3:SetParentQuery()
oSection3:SetParentFilter({|cParam| (cAlias1)->TFL_CODIGO == cParam},{|| (cAlias1)->TFF_CODPAI })

oSection1:Print()

(cAlias1)->(DbCloseArea())
          
Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At983VagEf()
Calcula a quantidade de vagas disponíveis no posto

@sample 	At983VagEf(nQtdVend,cCodEsc)
@param		nQtdVend, 	Quantidade vendida
			cCodEsc, 	Código da escala
			cPosto, 	Código do Posto

@return 	nQtdVaga - Quantidade de vagas do efetivo
@author 	Kaique Schiller
@since		27/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At983VagEf(nQtdVend,cCodEsc,cPosto)
Local cAliasEfet := GetNextAlias()
Local nQtdVaga := 0
Local nQtdEfet := 0

BeginSQL Alias cAliasEfet
	SELECT COUNT(TDX.TDX_CODTDW) QTDVAGA
	FROM %table:TDX% TDX
	WHERE TDX.TDX_FILIAL=%xFilial:TDX%
		AND TDX_CODTDW = %Exp:cCodEsc%
		AND TDX.%NotDel%
EndSql

//Quantidade de cadeiras no posto
If !(cAliasEfet)->(EOF())
	nQtdVaga := nQtdVend*(cAliasEfet)->(QTDVAGA)
Endif

(cAliasEfet)->(DbCloseArea())

cAliasEfet := GetNextAlias()

BeginSQL Alias cAliasEfet
	SELECT TGY.TGY_CODTFF
	FROM %table:TGY% TGY
	WHERE TGY.TGY_FILIAL=%xFilial:TGY%
		AND TGY.TGY_CODTFF = %Exp:cPosto%
		AND TGY.TGY_ULTALO <> ''
		AND TGY.%NotDel%
        AND %Exp:DtOS(MV_PAR09)% BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM
EndSql

//Quantidade de cadeiras utilizadas 
While !(cAliasEfet)->(EOF())
	nQtdEfet++
	(cAliasEfet)->(dbSkip())
EndDo

(cAliasEfet)->(DbCloseArea())

nQtdVaga := nQtdVaga-nQtdEfet

Return nQtdVaga

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At983VagCb()
Calcula a quantidade de vagas de cobertura disponíveis no posto

@sample 	At983VagCb(nQtdVend,cCodEsc)
@param		nQtdVend, 	Quantidade vendida
			cCodEsc, 	Código da escala
			cPosto, 	Código do Posto

@return 	nQtdVaga - Quantidade de vagas da cobertura
@author 	Kaique Schiller
@since		27/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At983VagCb(nQtdVend,cCodEsc,cPosto)
Local cAliasCob := GetNextAlias()
Local nQtdVaga := 0
Local nQtdCob  := 0

BeginSQL Alias cAliasCob
	SELECT DISTINCT TGW_EFETDX, TGW_COBTDX  
	FROM %table:TDX% TDX
	INNER JOIN  %table:TGW% TGW ON TGW.TGW_FILIAL = %xFilial:TGW%
		AND TGW.TGW_EFETDX = TDX.TDX_COD
		AND TGW.TGW_COBTDX <> ''
		AND TGW.%NotDel%	
	WHERE TDX.TDX_FILIAL = %xFilial:TDX%
		AND TDX.TDX_CODTDW =  %Exp:cCodEsc%
		AND TDX.%NotDel%
EndSql

While !(cAliasCob)->(EOF())
	nQtdCob++
	(cAliasCob)->(dbSkip())
EndDo

(cAliasCob)->(DbCloseArea())

//Quantidade de cadeiras para cobertura
If nQtdCob <> 0
	nQtdVaga := nQtdVend*nQtdCob
Endif

nQtdCob := 0

cAliasCob := GetNextAlias()

BeginSQL Alias cAliasCob
	SELECT TGZ.TGZ_CODTFF
	FROM %table:TGZ% TGZ
	WHERE TGZ.TGZ_FILIAL=%xFilial:TGZ%
		AND TGZ.TGZ_CODTFF = %Exp:cPosto%
		AND TGZ.%NotDel%
        AND %Exp:DtOS(MV_PAR09)% BETWEEN TGZ.TGZ_DTINI AND TGZ.TGZ_DTFIM
		AND EXISTS (SELECT 1 FROM %table:ABB% ABB 
					INNER JOIN  %table:TDV% TDV ON TDV.TDV_FILIAL = %xFilial:TDV%
						AND TDV.TDV_CODABB = ABB.ABB_CODIGO
						AND TDV.TDV_DTREF BETWEEN TGZ_DTINI AND TGZ.TGZ_DTFIM
						AND TDV.%NotDel%
					WHERE ABB.ABB_FILIAL=%xFilial:ABB% 
						AND ABB.ABB_CODTEC = TGZ.TGZ_ATEND
						AND ABB.%NotDel% )
EndSql

//Quantidade de cadeiras utilizadas
While !(cAliasCob)->(EOF())
	nQtdCob++
	(cAliasCob)->(dbSkip())
EndDo

(cAliasCob)->(DbCloseArea())

nQtdVaga := nQtdVaga-nQtdCob

Return nQtdVaga
