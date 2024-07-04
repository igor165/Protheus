#include 'protheus.ch'
#include 'parmtype.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR422()
DAPE

@sample GTPR422()

@author SIGAGTP | Gabriela Naommi Kamimoto
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR422()

Local oReport
Local cPerg  := 'GTPR422'

Pergunte(cPerg, .T.)

oReport := ReportDef(cPerg)
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
DAPE

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author SIGAGTP | Gabriela Naommi Kamimoto
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local cTitle   := "Demonstrativo de Acerto de Passagens de Estrada (DAPE)" //"Lançamento de notas por caixa e agencia"
Local cHelp    := "Gera Demonstrativo de Acerto de Passagens de Estrada (DAPE)" //"Gera o relatório lançamento de notas por caixa e agencia"
Local cAliasQry   := GetNextAlias()
Local oReport
Local oSection1
Local oSection2


oReport := TReport():New('GTPR422',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oReport:SetPortrait(.T.)
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, cTitle, cAliasQry)

TRCell():New(oSection1,"GY3_CODIGO", "GY3", , /*Picture*/, TamSX3("GY3_CODIGO")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GY3_DTENTR", "GY3", , /*Picture*/, TamSX3("GY3_DTENTR")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GY3_CODEMI", "GY3", , /*Picture*/, TamSX3("GY3_CODEMI")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GYG_NOME"  , "GYG", , /*Picture*/, TamSX3("GYG_NOME")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GYG_FUNCIO", "GYG", , /*Picture*/, TamSX3("GYG_FUNCIO")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)


oSection2 := TRSection():New(oReport,cTitle,cAliasQry)
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2,"GIC_LINHA"	,		"GIC", 	, /*Picture*/, TamSX3("GIC_LINHA")[1] 	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"GIC_CODIGO"	, 		"GIC", 	, /*Picture*/, TamSX3("GIC_CODIGO")[1] 	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"GIC_TAR"	, 		"GIC", 	, /*Picture*/, TamSX3("GIC_TAR")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
TRCell():New(oSection2,"GIC_PED"	,		"GIC", 	, /*Picture*/, TamSX3("GIC_PED")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
//TRCell():New(oSection2,"GIC_VLACER"	, 		"GIC",	, /*Picture*/, TamSX3("GIC_VLACER")[1]	/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 


oBreak:= TRBreak():New(oSection2,{||(cAliasQry)->(GIC_CODGY3)},"",.T.)
 
oBreak:SetPageBreak(.F.)

TRFunction():New(oSection2:Cell("GIC_TAR"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,)
TRFunction():New(oSection2:Cell("GIC_PED"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,)

oSection2:SetColSpace(1,.F.)
oSection2:SetAutoSize(.F.)
oSection2:SetLineBreak(.F.)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author SIGAGTP | Gabriela Naommi Kamimoto
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)
Local oSection1	 := oReport:Section(1)
Local oSection2	 := oReport:Section(2)
Local cCodigo	 := ''
Local cConfer    := '2'
Local cGY3Colab  := ''
Local cGY3Matri  := ''
Local cGY3Funcao := ''

	
	oSection2 :SetTotalText("DAPE")  //"Notas lançadas"

	oSection2:BeginQuery()

	BeginSql Alias cAliasQry
			
	        SELECT 
	            GIC.GIC_CODIGO,
	            GIC.GIC_LINHA,
	            GIC.GIC_TAR,
	            GIC.GIC_PED,
	            GIC.GIC_VLACER,
	            GIC.GIC_CONFER,
	            GIC.GIC_CODGY3,
	            GIC_DTVEND,
	            GIC.GIC_COLAB     
	        FROM 
		        %Table:GIC% GIC 
	        WHERE
	            GIC.GIC_FILIAL = %xFilial:GIC%
	            AND GIC.%NotDel% 
	          //  AND GIC.GIC_CONFER = %Exp:cConfer%
		        AND GIC.GIC_CODGY3 IN (
			        SELECT 
	                    GY3.GY3_CODIGO 
	                FROM 
				         %Table:GY3% GY3
	                WHERE 
	                    GY3.GY3_FILIAL = %xFilial:GY3%
	                    AND GY3.%NotDel%
	                    AND GY3.GY3_CODIGO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
	                    AND GY3.GY3_DTCANC = ''
	                )
	EndSql
	
	oSection2:EndQuery()

	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())	
	
		If cCodigo <> (cAliasQry)->GIC_CODGY3
			
			oSection2:Finish()
			oSection1:Init()
			
			cGY3Colab  := Posicione("GYG",1,xFilial("GYG")+(cAliasQry)->GIC_COLAB,"GYG_NOME")
			cGY3Matri  := Posicione("GYG",1,xFilial("GYG")+(cAliasQry)->GIC_COLAB,"GYG_FUNCIO")
	
			oSection1:Cell("GY3_CODIGO"):SetValue((cAliasQry)->GIC_CODGY3 )  
			oSection1:Cell("GY3_DTENTR"):SetValue((cAliasQry)->GIC_DTVEND )
			oSection1:Cell("GY3_CODEMI"):SetValue((cAliasQry)->GIC_COLAB )
			
			oSection1:Cell("GYG_NOME"):SetValue(cGY3Colab )
			oSection1:Cell("GYG_FUNCIO"):SetValue(cGY3Matri)
			
			oSection1:PrintLine()
			oReport:ThinLine()
			oReport:SkipLine(2)
			oSection1:Finish()
			
			cCodigo := (cAliasQry)->GIC_CODGY3
			
		Endif
		
		oSection2:Init()
		oSection2:PrintLine()
		
		(cAliasQry)->(DbSkip())  
		
	End

   oSection2:Finish()

Return
