#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE 'GTPR027.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR027()
Relatório de Clientes X Proposta X Viagens

@sample GTPR027()

@author Fábio Veiga
@since 18/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR027()

	Local oReport
	Local cPerg  := 'GTPR027'
	
	Pergunte(cPerg, .T.)
	
	oReport := ReportDef(cPerg)
	oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório de Clientes X Proposta X Viagens

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author Fábio Veiga 
@since 21/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)

Local cTitle   := STR0001 //Clientes x Proposta x Viagens
Local cHelp    := STR0002 //Gera o relatório de Cliente x Proposta x Viagens
Local cAliasQry   := GetNextAlias()
Local oReport
Local oSecCliente
Local oSecCabec
Local oSecViagem

oReport := TReport():New('GTPR027',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,.F./*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oReport:SetPortrait(.T.)
oReport:nFontBody := 5
oReport:SetTotalInLine(.F.)

oSecCliente := TRSection():New(oReport, cTitle, cAliasQry)
oSecCliente:SetTotalInLine(.F.)

TRCell():New(oSecCliente,"CLIENTES", cAliasQry, , /*Picture*/, 265/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
oSecCliente:SetHeaderSection(.F.)

oSecCabec := TRSection():New( oReport, "CABECALHO" ,NIL )
TRCell():New(oSecCabec, "cbOPORTUNIDADE",, '',"@",43/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.F./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T.) 
TRCell():New(oSecCabec, "cbDTVIAGEM"	,, '',"@",15/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.F./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T.) 
TRCell():New(oSecCabec, "cbORIGEM"		,, '',"@",35/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.F./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T.) 
TRCell():New(oSecCabec, "cbDESTINO"		,, '',"@",48/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.F./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T.) 
TRCell():New(oSecCabec, "cbVALOR"		,, '',"@",14/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,'03'/*cAlign*/,.F./*lLineBreak*/	,'03'/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T.) 

oSecViagem := TRSection():New(oReport,cTitle,cAliasQry)
oSecViagem:SetTotalInLine(.F.)

TRCell():New(oSecViagem	, "OPORTUNIDADE", cAliasQry	, '' , "@!"				, 43/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
TRCell():New(oSecViagem	, "DTVIAGEM"	, cAliasQry	, '' , "@!"				, 15/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 
TRCell():New(oSecViagem	, "ORIGEM"		, cAliasQry	, '' , "@!"				, 35/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)  
TRCell():New(oSecViagem	, "DESTINO"		, cAliasQry	, '' , "@!"				, 40/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)  
TRCell():New(oSecViagem	, "VALPROPOSTA"	, cAliasQry	, '' , "@E 999,999,999.99"	, 14/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,'03'/*cAlign*/,/*lLineBreak*/	,'03'/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)

oSecViagem:Cell("OPORTUNIDADE")	:lHeaderSize := .F.
oSecViagem:Cell("DTVIAGEM")		:lHeaderSize := .F.
oSecViagem:Cell("ORIGEM")		:lHeaderSize := .F.
oSecViagem:Cell("DESTINO")		:lHeaderSize := .F.
oSecViagem:Cell("VALPROPOSTA")	:lHeaderSize := .T.

oSecViagem:Cell("OPORTUNIDADE")	:SetBorder("BOTTOM",0,0,.T.)
oSecViagem:Cell("DTVIAGEM")		:SetBorder("BOTTOM",0,0,.T.)
oSecViagem:Cell("ORIGEM")		:SetBorder("BOTTOM",0,0,.T.)
oSecViagem:Cell("DESTINO")		:SetBorder("BOTTOM",0,0,.T.)

oSecViagem:Cell("VALPROPOSTA")	:SetBorder("BOTTOM",0,0,.T.)
oSecViagem:Cell("VALPROPOSTA")	:SetHeaderAlign("RIGHT")

oBreak:= TRBreak():New(oSecViagem,{||(cAliasQry)->(CLIENTE)},"",.T.)
oBreak:SetPageBreak(.F.)
oBreak:SetTotalInLine(.F.)
oBreak:SetTitle(STR0003)//Subtotal
oBreak:SetBorder("BOTTOM",0,0,.T.)

TRFunction():New(oSecViagem:Cell('VALPROPOSTA'),     , 'SUM'   ,oBreak ,,        ,        ,.F.        ,.T.       ,.F.     ,oSecViagem,          ,        ,         )

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author Fábio Veiga 
@since 21/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)
Local oSecCliente:= oReport:Section(1)
Local oSecCabec	 := oReport:Section(2)
Local oSecViagem := oReport:Section(3)
Local cCliente   := ""

Local cMV_PAR03	:= AllTrim(MV_PAR03)
Local cWhere	:= If (cMV_PAR03 <> ''," AND SA1.A1_COD = '" + MV_PAR03 + "' " , '')
 	
cWhere  := '% '+ cWhere  + ' %'

	oSecViagem:BeginQuery()

	BeginSQL Alias cAliasQry
		
	SELECT  AD1_NROPOR + '-' + AD1_DESCRI						 AS OPORTUNIDADE
			, SA1.A1_COD										 AS CLICOD
			, SA1.A1_NOME 										 AS CLIENTE
			, GI1ORIG.GI1_DESCRI 								 AS ORIGEM
			, GI1ODES.GI1_DESCRI 								 AS DESTINO
			, ADZ.ADZ_TOTAL + SUM(GIO.GIO_VALTOT) 				 AS VALPROPOSTA
			, CONVERT(CHAR,CAST(GIN.GIN_DSAIDA AS DATETIME),103) AS DTVIAGEM
	FROM %Table:GIN% GIN
	
	INNER JOIN %Table:AD1% AD1 ON
		AD1.AD1_PROPOS = GIN.GIN_PROPOS
		AND AD1.AD1_FILIAL = %xFilial:AD1%
		AND AD1.D_E_L_E_T_ = ' ' 
		AND AD1.AD1_STATUS = '9'
	
	INNER JOIN %Table:SA1% SA1 ON
		SA1.A1_COD = AD1.AD1_CODCLI
		AND SA1.D_E_L_E_T_ = ' ' 
		AND SA1.A1_TIPO = 'F'
	
	INNER JOIN %Table:GIO% GIO ON
		GIO.GIO_PROPOS = GIN.GIN_PROPOS
		AND GIO.GIO_FILIAL = %xFilial:GIO%
		
	INNER JOIN %Table:ADZ% ADZ ON
		ADZ.ADZ_FILIAL = %xFilial:ADZ%
		AND ADZ.ADZ_PROPOS = GIN.GIN_PROPOS
		AND ADZ.D_E_L_E_T_ = ' '		
	
	INNER JOIN %Table:GI1% GI1ORIG ON 
		GI1ORIG.GI1_COD = GIN.GIN_LOCOR 
		AND GI1ORIG.D_E_L_E_T_ = ' '
	
	INNER JOIN %Table:GI1% GI1ODES ON 
		GI1ODES.GI1_COD = GIN.GIN_LOCDES 
		AND GI1ODES.D_E_L_E_T_ = ' '
	
	WHERE GIN.GIN_DSAIDA BETWEEN %exp:dTos(MV_PAR01)% AND %exp:dTos(MV_PAR02)%
	AND GIN.GIN_FILIAL = %xFilial:GIN%
	AND GIN.GIN_ITEM = '01'
	%exp:cWhere%
	
	GROUP BY AD1_NROPOR, AD1_DESCRI, SA1.A1_COD, SA1.A1_NOME, GI1ORIG.GI1_DESCRI, GI1ODES.GI1_DESCRI, ADZ.ADZ_TOTAL, GIN.GIN_DSAIDA
	
	EndSQL 

	oSecViagem:EndQuery()
	
	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	If (cAliasQry)->(!Eof())
			oReport:StartPage()
			oSecCliente:Init()
			oSecCliente:Cell("CLIENTES"):SetValue(STR0004 + (cAliasQry)->CLICOD + ' - ' + (cAliasQry)->CLIENTE  ) // "- Cliente: "
			oSecCliente:Cell("CLIENTES"):SetBorder("BOTTOM",1,1,.F.)
			oSecCliente:PrintLine()	
	
			oSecCabec:Init()		
			oSecCabec:Cell("cbOPORTUNIDADE"):SetValue(STR0005)//Oportunidade:
			oSecCabec:Cell("cbOPORTUNIDADE"):SetBorder("BOTTOM",0,0,.T.)
			oSecCabec:Cell("cbDTVIAGEM")	:SetValue(STR0006)//Dt. Viagem:
			oSecCabec:Cell("cbDTVIAGEM")	:SetBorder("BOTTOM",0,0,.T.)
			oSecCabec:Cell("cbORIGEM")		:SetValue(STR0007)//Origem:
			oSecCabec:Cell("cbORIGEM")		:SetBorder("BOTTOM",0,0,.T.)
			oSecCabec:Cell("cbDESTINO")		:SetValue(STR0008) //Destino:
			oSecCabec:Cell("cbDESTINO")		:SetBorder("BOTTOM",0,0,.T.)
			oSecCabec:Cell("cbVALOR")		:SetValue(STR0009) //Valor:
			oSecCabec:Cell("cbVALOR")		:SetBorder("BOTTOM",0,0,.T.)	
		
			oSecCabec:PrintLine()
			
			cCliente := (cAliasQry)->CLIENTE
			
			WHILE !oReport:Cancel() .AND. (cAliasQry)->(!Eof())	
			
				IF cCliente != (cAliasQry)->CLIENTE
					oSecViagem:Finish()
					oSecCliente:Cell("CLIENTES"):SetValue(STR0004 + (cAliasQry)->CLICOD + ' - ' + (cAliasQry)->CLIENTE  )// "- Cliente: "
					oSecCliente:Cell("CLIENTES"):SetBorder("BOTTOM",0,0,.T.)
					oReport:SkipLine()
					
					oSecCliente:PrintLine()
					cCliente := (cAliasQry)->CLIENTE
					
					oSecCabec:PrintLine()
		
				ENDIF
		
				oSecViagem:Init()
				oSecViagem:PrintLine()
				
				(cAliasQry)->(DbSkip())  
				
			End
		
		   oSecCabec:Finish()
		   oSecCliente:Finish()
		   oSecViagem:Finish()
   Endif
   
Return