#Include 'Protheus.ch'
#include 'GTPR417.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR417()
Relatório de Comissão de Colaboradores por Agência

@sample GTPR417()

@author Flavio Martins
@since 30/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR417()

Local oReport
Local cPerg  := 'GTPR417'

	If Pergunte(cPerg, .T.)

		oReport := ReportDef(cPerg)
		oReport:PrintDialog()

	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Lista as comissões dos colaboradores de acordo com os parâmetros selecionados

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author Flavio Martins 
@since 30/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local cTitle   := STR0001 // "Comissão de Tipo de Recurso por Agência"
Local cHelp    := STR0002 // "Gera o relatório de comissão de tipo de recurso por agência"
Local cAliasQry   := GetNextAlias()
Local oReport
Local oSection1
Local oSection2

oReport := TReport():New('GTPR417',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oReport:SetPortrait(.T.)
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, cTitle, cAliasQry)
TRCell():New(oSection1,"AGENCIA", "GIC", , /*Picture*/, 100/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
oSection1:SetHeaderSection(.F.)  


oSection2 := TRSection():New(oReport,cTitle,cAliasQry)
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2,"GIC_COLAB",	"GIC", STR0003, /*Picture*/, TamSX3("GIC_COLAB")[1] /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Código Colab."
TRCell():New(oSection2,"GYG_NOME", 	"GIC", STR0004, /*Picture*/, 40 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Nome do Colaborador"
TRCell():New(oSection2,"TOTAL_I", 		"GIC", STR0005, /*Picture*/, 16/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Total Informatizado"
TRCell():New(oSection2,"TOTAL_E",		"GIC", STR0006, /*Picture*/, 16/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // ""Total Embarcada""
TRCell():New(oSection2,"TOTAL_M", 		"GIC",	STR0007, /*Picture*/, 16/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // ""Total Manual""
TRCell():New(oSection2,"VALTOT", 		"GIC", STR0008, /*Picture*/, 16/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Valor Total"

oSection2:Cell("VALTOT"):lHeaderSize := .F.

oBreak:= TRBreak():New(oSection2,{||(cAliasQry)->(GIC_AGENCI)},"",.T.)
 
oBreak:SetPageBreak(.F.)

TRFunction():New(oSection2:Cell("TOTAL_I"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,)
TRFunction():New(oSection2:Cell("TOTAL_E"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,)
TRFunction():New(oSection2:Cell("TOTAL_M"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,)
TRFunction():New(oSection2:Cell("VALTOT"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,)

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
Local oSection1		:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local cAgenciDe		:= MV_PAR01
Local cAgenciAte	:= MV_PAR02
Local cColabDe		:= MV_PAR03
Local cColabAte		:= MV_PAR04
Local cDataDe		:= MV_PAR05
Local cDataAte		:= MV_PAR06
Local cExpFol		:= ""
Local cCodAge		:= ""
	
	If MV_PAR07 == '1'
		cExpFol := "%" + "GQ6.GQ6_EXPFOL IS NOT NULL" + "%"
	Else
		cExpFol := "%" + "GQ6.GQ6_EXPFOL IS NULL" + "%"
	Endif
	
	oSection2 :SetTotalText(STR0009) // "Totais da Agência"

	oSection2:BeginQuery()

	BeginSQL Alias cAliasQry
		
		SELECT	GIC.GIC_AGENCI,
				GI6.GI6_DESCRI,
				GIC.GIC_COLAB,
				GYG.GYG_NOME,
				
				(SELECT SUM(GIC_VALCOM) 
					FROM %Table:GIC% GIC
				 INNER JOIN %Table:GQ6% GQ6
				 	ON 	GQ6.GQ6_FILIAL = %xFilial:GQ6% 
					AND GQ6.GQ6_CODIGO = GIC.GIC_CODGQ6	
				 WHERE  GIC.GIC_AGENCI BETWEEN %Exp:cAgenciDe% AND %Exp:cAgenciDe% 
					AND GIC.GIC_COLAB BETWEEN %Exp:cColabDe% AND %Exp:cColabAte% 
					AND GIC.GIC_DTVEND BETWEEN %Exp:cDataDe% AND %Exp:cDataAte% 
					AND %Exp:cExpFol% 
					AND GIC.%NotDel%
					AND GIC.GIC_TIPO = 'I') TOTAL_I,
					
				(SELECT SUM(GIC_VALCOM) 
					FROM %Table:GIC% GIC
				 INNER JOIN %Table:GQ6% GQ6
				 	ON 	GQ6.GQ6_FILIAL = %xFilial:GQ6% 
					AND GQ6.GQ6_CODIGO = GIC.GIC_CODGQ6	
				 WHERE  GIC.GIC_AGENCI BETWEEN %Exp:cAgenciDe% AND %Exp:cAgenciDe% 
					AND GIC.GIC_COLAB BETWEEN %Exp:cColabDe% AND %Exp:cColabAte% 
					AND GIC.GIC_DTVEND BETWEEN %Exp:cDataDe% AND %Exp:cDataAte% 
					AND %Exp:cExpFol% 
					AND GIC.%NotDel%
					AND GIC.GIC_TIPO = 'E') TOTAL_E,
					
				(SELECT SUM(GIC_VALCOM) 
					FROM %Table:GIC% GIC
				 INNER JOIN %Table:GQ6% GQ6
				 	ON 	GQ6.GQ6_FILIAL = %xFilial:GQ6% 
					AND GQ6.GQ6_CODIGO = GIC.GIC_CODGQ6	
				 WHERE  GIC.GIC_AGENCI BETWEEN %Exp:cAgenciDe% AND %Exp:cAgenciDe% 
					AND GIC.GIC_COLAB BETWEEN %Exp:cColabDe% AND %Exp:cColabAte% 
					AND GIC.GIC_DTVEND BETWEEN %Exp:cDataDe% AND %Exp:cDataAte% 
					AND %Exp:cExpFol% 
					AND GIC.%NotDel%
					AND GIC.GIC_TIPO = 'M') TOTAL_M,
				
				SUM(GIC.GIC_VALCOM) VALTOT
 		FROM %Table:GIC% GIC
		INNER JOIN %Table:GI6% GI6
			ON GI6.GI6_FILIAL = %xFilial:GI6%
			AND GI6.GI6_CODIGO = GIC.GIC_AGENCI
		INNER JOIN %Table:GYG% GYG
			ON GYG.GYG_FILIAL = %xFilial:GYG%
			AND GYG.GYG_CODIGO = GIC.GIC_COLAB
		INNER JOIN %Table:GQ6% GQ6
			ON GQ6.GQ6_FILIAL = %xFilial:GQ6% 
			AND GQ6.GQ6_CODIGO = GIC.GIC_CODGQ6	
		WHERE GIC.GIC_AGENCI BETWEEN %Exp:cAgenciDe% AND %Exp:cAgenciDe%
		AND GIC.GIC_COLAB BETWEEN %Exp:cColabDe% AND %Exp:cColabAte%
		AND GIC.GIC_DTVEND BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
		AND %Exp:cExpFol% 
		AND GIC.%NotDel%		
		GROUP BY	GIC.GIC_AGENCI,
					GI6.GI6_DESCRI,
					GIC.GIC_COLAB,
					GYG.GYG_NOME
		ORDER BY 	GIC.GIC_COLAB, 
					GIC.GIC_AGENCI
					
	EndSQL 
	
	oSection2:EndQuery()

	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())	
	
		If cCodAge != (cAliasQry)->GIC_AGENCI
			
			oSection2:Finish()
			oSection1:Init()
			oSection1:Cell("AGENCIA"):SetValue(STR0010 + (cAliasQry)->GIC_AGENCI + ' ' + (cAliasQry)->GI6_DESCRI) // "Colaborador: "
			oSection1:PrintLine()
			oReport:ThinLine()
			oReport:SkipLine(2)
			oSection1:Finish()
			
			cCodAge := (cAliasQry)->GIC_AGENCI
			
		Endif
		
		oSection2:Init()
		oSection2:PrintLine()
		
		(cAliasQry)->(DbSkip())  
		
	End

   oSection2:Finish()

Return
