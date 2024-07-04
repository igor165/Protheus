#Include 'Protheus.ch'
#include 'GTPR115.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR115A()
Lista os bilhetes cadastrados de acordo com os parâmetros selecionados
para a tesouraria 

@sample GTPR115A()

@author Renan Ribeiro Brando
@since 30/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR115A()

Local oReport
Local cPerg  := 'GTPR115A'

Pergunte(cPerg, .T.)

oReport := ReportDef(cPerg)
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Lista os bilhetes cadastrados de acordo com os parâmetros selecionados

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author Renan Ribeiro Brando
@since 30/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)

Local cTitle   := STR0001 //"Bilhetes"
Local cHelp    := STR0002 // "Gera o relatório de bilhetes."
Local cAliasQry   := GetNextAlias()
Local oReport
Local oSection1
Local oSection2

oReport := TReport():New('GTPR115A',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oReport:SetLandscape(.T.)
oReport:nFontBody := 5
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, cTitle, cAliasQry)
TRCell():New(oSection1,"AGENCIA", "GIC", , /*Picture*/, 100/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
oSection1:SetHeaderSection(.F.)  


oSection2 := TRSection():New(oReport,cTitle,cAliasQry)
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2,"GIC_CODIGO", "GIC", STR0003, /*Picture*/, TamSX3("GIC_CODIGO")[1] /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Codigo"
TRCell():New(oSection2,"GIC_BILHET", "GIC", STR0004,/*Picture*/, TamSX3("GIC_BILHET")[1] /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Num. Bilhete"
TRCell():New(oSection2,"GIC_CODGID", "GIC", STR0005, /*Picture*/, TamSX3("GIC_CODIGO")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Cod. Horário"
TRCell():New(oSection2,"GIC_LINHA",  "GIC", STR0006, /*Picture*/, TamSX3("GIC_LINHA")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) //"Cod. Linha"
TRCell():New(oSection2,"Origem", "GI1ORI", STR0009, /*Picture*/, TamSX3("GIC_NLOCORI")[1]-7/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Localidade de Origem"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
TRCell():New(oSection2,"Destino", "GI1DES", STR0011, /*Picture*/,TamSX3("GIC_NLOCDES")[1]-7 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) //"Localidade Destino" 
TRCell():New(oSection2,"GIC_SENTID", "GIC", STR0012, /*Picture*/, TamSX3("GIC_SENTID")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Sentido" 
TRCell():New(oSection2,"GIC_DTVIAG", "GIC", STR0013, /*Picture*/, TamSX3("GIC_DTVIAG")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Dt. Viagem" 
TRCell():New(oSection2,"GIC_HORA", "GIC", STR0014, /*Picture*/, TamSX3("GIC_HORA")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) //"Hora Viagem"
TRCell():New(oSection2,"GIC_TIPO", "GIC", STR0017, /*Picture*/, TamSX3("GIC_TIPO")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) //"Tipo Bilhete" 
TRCell():New(oSection2,"GIC_TAR", "GIC", STR0018, /*Picture*/, 10/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Vlr. Tarifa"
TRCell():New(oSection2,"GIC_TAX", "GIC", STR0019, /*Picture*/, 10/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Vlr. Taxas" 
TRCell():New(oSection2,"GIC_PED", "GIC", STR0020, /*Picture*/, 10/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Vlr. Pedagio" 
TRCell():New(oSection2,"GIC_SGFACU", "GIC", STR0021, /*Picture*/,10 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Vlr. Seguro" 
TRCell():New(oSection2,"GIC_OUTTOT", "GIC", STR0022, /*Picture*/,10 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Out. Vlrs." 
TRCell():New(oSection2,"GIC_VALTOT", "GIC", STR0023, /*Picture*/,12 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Valor Total" 
TRCell():New(oSection2,"GIC_STATUS", "GIC", STR0024, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // "Status" 

oSection2:Cell("GIC_TAR"):lHeaderSize := .F.
oSection2:Cell("GIC_TAX"):lHeaderSize := .F.
oSection2:Cell("GIC_PED"):lHeaderSize := .F.
oSection2:Cell("GIC_SGFACU"):lHeaderSize := .F.
oSection2:Cell("GIC_OUTTOT"):lHeaderSize := .F.
oSection2:Cell("GIC_VALTOT"):lHeaderSize := .F.
oSection2:Cell("GIC_STATUS"):lHeaderSize := .F.

oBreak:= TRBreak():New(oSection2,{||(cAliasQry)->(GIC_AGENCI)},"",.T.)
 
oBreak:SetPageBreak(.F.)

TRFunction():New(oSection2:Cell("GIC_TAR"),NIL,"SUM",,,"@E 9,999,999.99",,,,,,{|| GIC->GIC_STATUS != "C"})
TRFunction():New(oSection2:Cell("GIC_TAX"),NIL,"SUM",,,"@E 9,999,999.99",,,,,,{|| GIC->GIC_STATUS != "C"})
TRFunction():New(oSection2:Cell("GIC_PED"),NIL,"SUM",,,"@E 9,999,999.99",,,,,,{|| GIC->GIC_STATUS != "C"})
TRFunction():New(oSection2:Cell("GIC_SGFACU"),NIL,"SUM",,,"@E 9,999,999.99",,,,,,{|| GIC->GIC_STATUS != "C"})
TRFunction():New(oSection2:Cell("GIC_OUTTOT"),NIL,"SUM",,,"@E 9,999,999.99",,,,,,{|| GIC->GIC_STATUS != "C"})
TRFunction():New(oSection2:Cell("GIC_VALTOT"),NIL,"SUM",,,"@E 99,999,999.99",,,,,,{|| (cAliasQry)->(GIC_STATUS) != "C"})

oSection2:SetColSpace(1,.F.)
oSection2:SetAutoSize(.F.)
oSection2:SetLineBreak(.F.)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author Renan Ribeiro Brando
@since 30/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)
Local oSection1   := oReport:Section(1)
Local oSection2   := oReport:Section(2)
Local cTpLocalSql := ""
Local cSentidSql  := ""
Local cOrigemSql  := ""
Local cCodAge     := ""
Local cOrdem      := '%GIC.GIC_AGENCI%'
Local cEcf        := ""

oSection2 :SetTotalText(STR0027) // "Totais da Agência"

	oSection2:BeginQuery()

	BeginSQL Alias cAliasQry
		
		SELECT 
			GIC.GIC_CODIGO, 
			GIC.GIC_BILHET, 
			GIC.GIC_CODGID, 
			GIC.GIC_CODSRV, 
			GIC.GIC_LINHA, 
			GIC.GIC_LOCORI, 
			GI1ORI.GI1_DESCRI As Origem, 
			GIC.GIC_LOCDES, 
			GI1DES.GI1_DESCRI As Destino,
			GIC.GIC_SENTID, 
			GIC.GIC_DTVIAG, 
			GIC.GIC_HORA,
			GIC.GIC_AGENCI, 
			GI6.GI6_DESCRI,
			GIC.GIC_TIPO,
			GIC.GIC_TAR, 
			GIC.GIC_TAX, 
			GIC.GIC_PED,
			GIC.GIC_SGFACU,
			GIC.GIC_OUTTOT, 
			GIC.GIC_VALTOT, 
			GIC.GIC_STATUS 
		FROM 
			%Table:GIC% GIC
		INNER JOIN %Table:GI1% GI1ORI 
			ON  GI1ORI.GI1_FILIAL = %xFilial:GIC%
			AND GI1ORI.GI1_COD = GIC.GIC_LOCORI
		INNER JOIN %Table:GI1% GI1DES 
			ON  GI1DES.GI1_FILIAL = %xFilial:GIC%
			AND GI1DES.GI1_COD = GIC.GIC_LOCDES
		INNER JOIN %Table:GI6% GI6 
			ON GI6.GI6_FILIAL = %xFilial:GIC%
			AND GI6.GI6_CODIGO = GIC.GIC_AGENCI
		WHERE
			GIC.GIC_FILIAL = %Exp:xfilial('GIC')%
			AND GIC.%notDel%
			AND GIC.GIC_AGENCI BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%  
			AND GIC.GIC_NUMFCH IN (
				SELECT 
					G6Y.G6Y_NUMFCH 
				FROM 
					%Table:G6Y% G6Y 
				WHERE 
					G6Y.G6Y_FILIAL = %Exp:xfilial('GIC')%
					AND G6Y.%notDel%
					AND G6Y.G6Y_CODIGO = (
						SELECT 
							G6T.G6T_CODIGO 
						FROM 
							%Table:G6T% G6T 
						WHERE 
							G6T.G6T_FILIAL = %Exp:xfilial('GIC')%
							AND G6T.%notDel%
							AND G6T.G6T_DTOPEN >= %Exp:DTOS(mv_par03)% 
							AND G6T.G6T_DTOPEN <= %Exp:DTOS(mv_par04)%
						) 
				)

		ORDER BY %Exp:cOrdem%	
	
	EndSQL 

	oSection2:EndQuery()

	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	WHILE !oReport:Cancel() .AND. (cAliasQry)->(!Eof())	
	
		IF cCodAge != (cAliasQry)->GIC_AGENCI
			
			oSection2:Finish()
			oSection1:Init()
			oSection1:Cell("AGENCIA"):SetValue(STR0026 + (cAliasQry)->GIC_AGENCI + ' ' + (cAliasQry)->GI6_DESCRI) // "Agência: "
			oSection1:PrintLine()
			oReport:ThinLine()
			oReport:SkipLine(2)
			oSection1:Finish()
			
			cCodAge := (cAliasQry)->GIC_AGENCI
			
		ENDIF
		
		oSection2:Init()
		oSection2:PrintLine()
		
		(cAliasQry)->(DbSkip())  
		
	End

   oSection2:Finish()

Return
