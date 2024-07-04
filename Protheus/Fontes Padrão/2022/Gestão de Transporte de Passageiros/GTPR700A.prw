#Include 'Protheus.ch'
#include 'GTPR700A.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR700A()
Relatório de Lançamento de Notas da tesouraria

@sample GTPR700A()

@author Fernando Amorim(Cafu)
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR700A()

Local oReport
Local cPerg  := 'GTPR700A'

Pergunte(cPerg, .T.)

oReport := ReportDef(cPerg)
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório de Lançamento de Notas da tesouraria

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author Fernando Amorim(Cafu)
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local cTitle   := STR0001 //"Lançamento de notas por caixa e agencia"
Local cHelp    := STR0002 //"Gera o relatório lançamento de notas por caixa e agencia"
Local cAliasQry   := GetNextAlias()
Local oReport
Local oSection1
Local oSection2


oReport := TReport():New('GTPR700A',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oReport:SetPortrait(.T.)
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, cTitle, cAliasQry)
TRCell():New(oSection1,"G6T_CODIGO", "G6T", , /*Picture*/, TamSX3("G6T_CODIGO")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"G6T_DTOPEN", "G6T", , /*Picture*/, TamSX3("G6T_DTOPEN")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"G6T_AGENCI", "G6T", , /*Picture*/, TamSX3("G6T_AGENCI")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection1,"G6T_DESCRI", "G6T", , /*Picture*/, TamSX3("G6T_DESCRI")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
oSection1:SetHeaderSection(.F.)  


oSection2 := TRSection():New(oReport,cTitle,cAliasQry)
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2,"G6Y_NUMFCH"	,		"G6Y", 	, /*Picture*/, TamSX3("G6Y_NUMFCH")[1] 	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6Y_NOTA"	, 		"G6Y", 	, /*Picture*/, TamSX3("G6Y_NOTA")[1] 	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6Y_SERIE"	, 		"G6Y", 	, /*Picture*/, TamSX3("G6Y_SERIE")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6Y_FORNEC"	,		"G6Y", 	, /*Picture*/, TamSX3("G6Y_FORNEC")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6Y_LOJA"	, 		"G6Y",	, /*Picture*/, TamSX3("G6Y_LOJA")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6Y_NOMFOR"	, 		"G6Y",	, /*Picture*/, TamSX3("G6Y_NOMFOR")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6Y_DATA"	, 		"G6Y",	, /*Picture*/, TamSX3("G6Y_DATA")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"G6Y_VALOR"	, 		"G6Y",	, /*Picture*/, TamSX3("G6Y_VALOR")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 

//oSection2:Cell("VALTOT"):lHeaderSize := .F.

oBreak:= TRBreak():New(oSection2,{||(cAliasQry)->(G6T_AGENCI)},"",.T.)
 
oBreak:SetPageBreak(.F.)

TRFunction():New(oSection2:Cell("G6Y_VALOR"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,)

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
Local cCodAGe	:= ''

	
	oSection2 :SetTotalText(STR0003)  //"Notas lançadas"

	oSection2:BeginQuery()

	BeginSQL Alias cAliasQry
 
		SELECT	G6T.G6T_DTOPEN,
				G6T.G6T_CODIGO,
				G6T.G6T_AGENCI,
				G6Y.G6Y_NUMFCH,
				G6Y.G6Y_NOTA,
				G6Y.G6Y_SERIE,
				G6Y.G6Y_FORNEC,
				G6Y.G6Y_LOJA,
				G6Y.G6Y_DATA,
				G6Y.G6Y_VALOR,
				GI6_DESCRI
		FROM %Table:G6T% G6T
		INNER JOIN %Table:G6Y% G6Y
		ON 	G6Y.G6Y_FILIAL = %xFilial:G6Y% 
		AND G6Y.G6Y_CODIGO = G6T.G6T_CODIGO	
		AND G6Y.G6Y_TPLANC = '1'
		AND G6Y.%NotDel%
		INNER JOIN %Table:GI6% GI6
		ON GI6.GI6_FILIAL = %xFilial:GI6%
		AND GI6.GI6_CODIGO = G6T.G6T_AGENCI
		WHERE  G6T.G6T_DTOPEN BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
				AND G6T.G6T_AGENCI BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% 
				AND G6T.%NotDel%					
		ORDER BY 	G6T.G6T_DTOPEN, 
					G6T.G6T_CODIGO,
					G6T.G6T_AGENCI,
					G6Y.G6Y_NOTA
	EndSQL 
	
	oSection2:EndQuery()

	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())	
	
		If cCodAge <> (cAliasQry)->G6T_AGENCI
			
			oSection2:Finish()
			oSection1:Init()
			oSection1:Cell("G6T_CODIGO"):SetValue((cAliasQry)->G6T_CODIGO )  
			oSection1:Cell("G6T_DTOPEN"):SetValue((cAliasQry)->G6T_DTOPEN ) 
			oSection1:Cell("G6T_AGENCI"):SetValue((cAliasQry)->G6T_AGENCI ) 		
			oSection1:Cell("G6T_DESCRI"):SetValue((cAliasQry)->GI6_DESCRI ) 
			oSection1:PrintLine()
			oReport:ThinLine()
			oReport:SkipLine(2)
			oSection1:Finish()
			
			cCodAge := (cAliasQry)->G6T_AGENCI
			
		Endif
		
		oSection2:Init()
		oSection2:PrintLine()
		
		(cAliasQry)->(DbSkip())  
		
	End

   oSection2:Finish()

Return
