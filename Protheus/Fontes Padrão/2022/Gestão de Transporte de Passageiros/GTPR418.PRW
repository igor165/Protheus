#Include 'Protheus.ch'
#include 'GTPR418.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR418()
Relatório de Comissão de Colaborador por Período

@sample GTPR418()

@author Flavio Martins
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------

Function GTPR418()

Local oReport
Local cPerg  := 'GTPR418'

	If Pergunte(cPerg, .T.)

		oReport := ReportDef(cPerg)
		oReport:PrintDialog()

	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Lista as comissões por período de acordo com os parâmetros selecionados

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author Flavio Martins 
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)

Local cTitle   := STR0001 // "Comissão de Tipo de Recurso por Período" 
Local cHelp    := STR0002 // "Gera o relátorio de comissão de tipo de recurso por período"
Local cAliasQry   := GetNextAlias()
Local oReport
Local oSection1
Local oSection2

oReport := TReport():New('GTPR418',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oReport:SetPortrait(.T.)
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, cTitle, cAliasQry)
TRCell():New(oSection1,"GIC_COLAB",	"GIC", STR0003, /*Picture*/, TamSX3("GIC_COLAB")[1], /*lPixel*/, /*{|| code-block de impressao }*/) //  "Código Colab."  
TRCell():New(oSection1,"GYG_NOME",		"GIC", STR0004, /*Picture*/, TamSX3("GYG_NOME")[1], /*lPixel*/, /*{|| code-block de impressao }*/) // "Nome do Colaborador"
TRCell():New(oSection1,"GYK_DESCRI",	"GIC", STR0005, /*Picture*/, TamSX3("GYK_DESCRI")[1], /*lPixel*/, /*{|| code-block de impressao }*/) // "Tipo de Recurso"
oSection1:SetHeaderSection(.T.)  

oSection2 := TRSection():New(oReport,cTitle,cAliasQry)
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2,"GIC_DTVEND",	"GIC", STR0006, /*Picture*/, TamSX3("GIC_DTVEND")[1] /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Data da Venda"
TRCell():New(oSection2,"GIC_PERCOM",	"GIC", STR0007, /*Picture*/, 6 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "% Comissão"
TRCell():New(oSection2,"VALBASE", 		"GIC", STR0008, /*Picture*/, 20/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Valor Base"
TRCell():New(oSection2,"VALCOM", 		"GIC", STR0009, /*Picture*/, 20/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Valor Comissão"

oBreak:= TRBreak():New(oSection1,{||(cAliasQry)->(GIC_COLAB)},"",.T.)
 
oBreak:SetPageBreak(.F.)

TRFunction():New(oSection2:Cell("VALCOM"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,)

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
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)
Local oSection1		:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local cColabDe		:= MV_PAR01
Local cColabAte		:= MV_PAR02
Local cDataDe		:= MV_PAR03
Local cDataAte		:= MV_PAR04
Local cExpFol		:= ""
Local cCodColab		:= ""
	
	
	If MV_PAR05 == '1'
		cExpFol := "%" + "GQ6.GQ6_EXPFOL IS NOT NULL" + "%"
	Else
		cExpFol := "%" + "GQ6.GQ6_EXPFOL IS NULL" + "%"
	Endif
	

	oSection2 :SetTotalText(STR0010) // "Totais do Colaborador"

	oSection2:BeginQuery()

	BeginSQL Alias cAliasQry
		
		SELECT	GIC.GIC_COLAB,
				GIC.GIC_DTVEND,
				GIC.GIC_PERCOM,
				GYG.GYG_NOME,
				GYK.GYK_DESCRI,
				SUM(GIC.GIC_VALTOT - GIC.GIC_VALIMP) VALBASE,
				SUM(GIC.GIC_VALCOM) VALCOM
		FROM %Table:GIC% GIC
		INNER JOIN %Table:GYG% GYG
			ON GYG.GYG_FILIAL = %xFilial:GYG% 
			AND GYG.GYG_CODIGO = GIC.GIC_COLAB
		INNER JOIN %Table:GYK% GYK
			ON GYK.GYK_FILIAL = %xFilial:GYK% 
			AND GYK.GYK_CODIGO = GYG.GYG_RECCOD
		INNER JOIN %Table:GQ6% GQ6
			ON GQ6.GQ6_FILIAL = %xFilial:GQ6% 
			AND GQ6.GQ6_CODIGO = GIC.GIC_CODGQ6
		WHERE
		GIC.GIC_COLAB BETWEEN %Exp:cColabDe% AND %Exp:cColabAte% 
		AND GIC.GIC_DTVEND BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
		AND %Exp:cExpFol% 
		AND GIC.%NotDel%		
		GROUP BY	GIC.GIC_COLAB,
					GIC.GIC_DTVEND,
					GIC.GIC_PERCOM,
					GYG.GYG_NOME,
					GYK.GYK_DESCRI
		ORDER BY 	GIC.GIC_COLAB, 
					GIC.GIC_DTVEND			
					
	EndSQL 
	
	oSection2:EndQuery()

	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())	
	
		If cCodColab != (cAliasQry)->GIC_COLAB
			
			oSection2:Finish()
			oSection1:Init()
			oSection1:Cell("GIC_COLAB"):SetValue((cAliasQry)->GIC_COLAB)
			oSection1:Cell("GYG_NOME"):SetValue((cAliasQry)->GYG_NOME)
			oSection1:Cell("GYK_DESCRI"):SetValue((cAliasQry)->GYK_DESCRI)
		
			oSection1:PrintLine()
			oReport:SkipLine(2)
			oSection1:Finish()
			
			cCodColab := (cAliasQry)->GIC_COLAB
			
		Endif
		
		oSection2:Init()
		oSection2:PrintLine()
		
		(cAliasQry)->(DbSkip())  
		
	End

   oSection2:Finish()

Return
