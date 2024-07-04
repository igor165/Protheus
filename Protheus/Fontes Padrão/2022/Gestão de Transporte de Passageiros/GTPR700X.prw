#Include 'Protheus.ch'
#include 'GTPR700A.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR700X()
Relatório de Lançamento de Notas da tesouraria

@sample GTPR700X()

@author Yuki Shiroma
@since 06/03/2018
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR700X()

Local oReport
Local cPerg  := 'GTPR700X'

Pergunte(cPerg, .T.)

oReport := ReportDef(cPerg)
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório de Fichas de Remessa X Caixa

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author Fernando Amorim(Cafu)
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local cTitle   := "Fichas de Remessa X Caixa" //"Lançamento de ficha de remessa por caixa e agência"
Local cHelp    := "Gera o relatório Fichas de Remessa X Caixa" //"Gera o relatório lançamento de notas por caixa e agencia"
Local cAliasQry   := GetNextAlias()
Local oReport
Local oSection1
Local oSection2


oReport := TReport():New('GTPR700X',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oReport:SetPortrait(.T.)
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, cTitle, cAliasQry)
TRCell():New(oSection1,"G6T_CODIGO", "G6T", , /*Picture*/, TamSX3("G6T_CODIGO")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"G6T_DTOPEN", "G6T", , /*Picture*/, TamSX3("G6T_DTOPEN")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"G6T_AGENCI", "G6T", , /*Picture*/, TamSX3("G6T_AGENCI")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection1,"G6T_DESCRI", "GI6", , /*Picture*/, TamSX3("GI6_DESCRI")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"G6T_STATUS", "GI6", , /*Picture*/, 15/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
oSection1:SetHeaderSection(.F.)  


oSection2 := TRSection():New(oReport,cTitle,cAliasQry)
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2,"G6X_NUMFCH"	, 		"G6X", 	, /*Picture*/, TamSX3("G6X_NUMFCH")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6X_RECCX"	,		"G6X", 	, /*Picture*/, TamSX3("G6X_RECCX")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6X_DESCX"	, 		"G6X",	, /*Picture*/, TamSX3("G6X_DESCX")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6X_SLDCX"	, 		"G6X",	, /*Picture*/, TamSX3("G6X_SLDCX")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6X_TPSLCX"	, 		"G6X",	, /*Picture*/, TamSX3("G6X_TPSLCX")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6X_TITCX"	, 		"G6X",	, /*Picture*/, TamSX3("G6X_TITCX")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"FICHAST"	, 		,"Status Ficha"	, /*Picture*/, 15	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 

oBreak:= TRBreak():New(oSection2,{||(cAliasQry)->(G6T_CODIGO)},"",.T.)
 
oBreak:SetPageBreak(.F.)

TRFunction():New(oSection2:Cell("G6X_RECCX"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,)
TRFunction():New(oSection2:Cell("G6X_DESCX"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,)
TRFunction():New(oSection2:Cell("G6X_SLDCX"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,)

oSection2:SetColSpace(1,.F.)
oSection2:SetAutoSize(.F.)
oSection2:SetLineBreak(.F.)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author Flavio Martins 
@since 30/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)
Local oSection1	:= oReport:Section(1)
Local oSection2	:= oReport:Section(2)
Local cCodCX	:= ''

	
	oSection2 :SetTotalText("Total")  //"Notas lançadas"

	oSection2:BeginQuery()

	BeginSQL Alias cAliasQry
 		
 		SELECT DISTINCT
			G6X_CODCX,
			G6X_AGENCI, 
			GI6_DESCRI,
			G6X_NUMFCH,
			G6X_RECCX,
			G6X_DESCX,
			G6X_SLDCX,
			G6X_TPSLCX,
			SUBSTRING(G6X_TITCX, 9, 25) AS G6X_TITCX,
			G6T_DTOPEN,
			G6T_DTCLOS,
			(Case When G6T_STATUS = '1' THEN 'Caixa Aberta' 
				When G6T_STATUS = '2' THEN 'Caixa Fechada' 
				When G6T_STATUS = '3' THEN 'Caixa Reaberta' 
				END) as G6T_STATUS,
			(Case When G6X_FECHCX = 'F' THEN 'Aberta' 
				When G6X_FECHCX = 'T' THEN 'Fechada' 
				END) as FICHAST,
			SUBSTRING(G6X_TITCX, 8, 25) AS G6X_TITCX,
			G6T_CODIGO
		
		FROM %Table:G6X% G6X 
		
		INNER JOIN %Table:G6T% G6T ON
			G6T.G6T_AGENCI = G6X.G6X_AGENCI
			AND G6T.G6T_CODIGO = G6X.G6X_CODCX 
			AND G6T.%NotDel%
		INNER JOIN %Table:GI6% GI6 ON
			GI6.GI6_FILIAL = %xFilial:GI6%
			AND GI6.GI6_CODIGO = G6X.G6X_AGENCI
			AND GI6.%NotDel%
		
		WHERE 
			G6X.G6X_FILIAL = %xFilial:G6X%
			AND G6X.G6X_CODCX BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND G6X.G6X_NUMFCH BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND G6X.G6X_AGENCI BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
			AND G6X.G6X_DTINI >= %Exp:DtoS(MV_PAR07)%
			AND G6X.G6X_DTFIN <= %Exp:DtoS(MV_PAR08)%
			AND G6X.%NotDel%
		
			ORDER BY 
				G6X_CODCX,
				G6X_NUMFCH
	EndSQL 
	
	oSection2:EndQuery()

	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())	
	
		If cCodCX <> (cAliasQry)->G6T_CODIGO
			
			oSection2:Finish()
			oReport:SkipLine(2)
			oSection1:Init()
			oSection1:Cell("G6T_CODIGO"):SetValue((cAliasQry)->G6T_CODIGO )  
			oSection1:Cell("G6T_DTOPEN"):SetValue((cAliasQry)->G6T_DTOPEN ) 
			oSection1:Cell("G6T_AGENCI"):SetValue((cAliasQry)->G6X_AGENCI ) 		
			oSection1:Cell("G6T_DESCRI"):SetValue((cAliasQry)->GI6_DESCRI ) 
			oSection1:Cell("G6T_STATUS"):SetValue((cAliasQry)->G6T_STATUS )
			oSection1:PrintLine()
			oReport:ThinLine()
			oSection1:Finish()
			
			cCodCX := (cAliasQry)->G6T_CODIGO
			
		Endif
		
		oSection2:Init()
		oSection2:PrintLine()
		(cAliasQry)->(DbSkip())  
		
	End

   oSection2:Finish()

Return
