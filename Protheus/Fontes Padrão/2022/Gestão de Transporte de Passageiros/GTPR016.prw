#include 'PROTHEUS.CH'
#include 'PARMTYPE.CH'
#include 'GTPR016.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR016
Relatório de Resumo Diário Contratos - Data de Viagem

@author fabio.veiga
@since 11/07/2018
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Function GTPR016()
Local cPerg := "GTPR016"
Private oReport

If Pergunte( cPerg, .T. )
	oReport := ReportDef( cPerg )
	oReport:PrintDialog()
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definições do Relatório

@author fabio.veiga
@since 11/07/2018
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local oReport   := Nil
Local oSection1 := Nil
Local oBreak    := nil	

//Ajuste no Layout para apresentar as informações de pedagio.
oReport := TReport():New("GTPR016",STR0001,cPerg,{|oReport| ReportPrint(oReport)},"texto",.T.) //"Resumo Diário Contratos - Data Viagem"
oReport:nFontBody := 8
oReport:SetTotalInLine(.F.)
oReport:SetLeftMargin(01) 

oSection1:= TRSection():New(oReport,"Dados Filial", {"G6R","SM0"}, , .F., .T.) //

TRCell():New(oSection1,"DTINCL","G6R",STR0002,,14) //"DT. EMISSÃO"
TRCell():New(oSection1,"PROPOSTA","G6R",STR0003,,10) //"CONTRATO"
TRCell():New(oSection1,"DESCRI","G6R",STR0004,,29) //"ITINERARIO"
TRCell():New(oSection1,"DESORI","G6R",STR0005,,29) //"ORIGEM"
TRCell():New(oSection1,"DTIDA","G6R",STR0006,,12) //"DT. INICIO"
TRCell():New(oSection1,"DESDES","G6R",STR0007,,29) //"DESTINO"
TRCell():New(oSection1,"DTVLTA","G6R",STR0008,,12) //"DT. FIM"
TRCell():New(oSection1,"PDTOT","G6R",STR0009,"@E 999,999,999.99",10) //"PEDAGIO"
TRCell():New(oSection1,"KILOMETROS","G6R",STR0010,"@E 999,999,999" ,10) //"KM"
TRCell():New(oSection1,"VALACO","G6R",STR0011,"@E 999,999,999.99",10) //"VALOR"
TRCell():New(oSection1,"STATUS","G6R",STR0013,,10) //"STATUS"

oSection1:Cell("DTIDA"):lHeaderSize := .F.

TRFunction():New(oSection1:Cell("KILOMETROS"),"TOTAL","SUM",oBreak,,"@E 999,999,999",,.F.,.T.)
TRFunction():New(oSection1:Cell("VALACO"),"TOTAL","SUM",oBreak,,"@E 999,999,999.99",,.F.,.T.)
TRFunction():New(oSection1:Cell("PDTOT"),"TOTAL","SUM",oBreak,,"@E 999,999,999.99",,.F.,.T.)
 	
Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função responsável pela impressão.

@author fabio.veiga
@since 11/07/2018
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section("Dados Filial")

SetQrySection(oReport)

nKmAcumul := 0

oSection1:Print()	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetQrySection
description
@author  fabio.veiga
@since   11/07/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function SetQrySection(oReport)
Local oSection1  := oReport:Section("Dados Filial")
Local cAliasSec1 := GetNextAlias()
Local cWhere1    := "%%"
Local cWhere2    := "%%"
Local cCond      := MV_PAR02
Local cPedag     := MV_PAR03

//Ajuste na query para apresentar as informações de pedagio.
If cCond != 4
	cWhere1 := "%and G6R_STATUS = '" + cValTochar(cCond) + "'%"
Endif

If cPedag = 1
	cWhere2 := "% != '0'%"
elseif cPedag = 2
	cWhere2 := "% = '0'%"
else
	cWhere2 := "% >= '0'%"
Endif

Pergunte( "GTPR016", .F. )

oSection1:BeginQuery()
	BeginSql Alias cAliasSec1

		SELECT 
			G6R_FILIAL FILIAL,
			(
				CASE
					WHEN G6R_STATUS = '1' THEN 'Aberto'
					WHEN G6R_STATUS = '2' THEN 'Ganho'
					WHEN G6R_STATUS = '3' THEN 'Perdido'
					WHEN G6R_STATUS = '4' THEN 'Reaberto'
				END
			) STATUS,
			G6R_PROPOS PROPOSTA,
			G6R_DESCRI DESCRI,
			G6R_LOCORI,
			GI1ORI.GI1_DESCRI DESORI,
			G6R_LOCDES,
			G6R_PDTOT PDTOT,
			GI1DES.GI1_DESCRI DESDES,
			G6R_CODBEM CARRO,
			CONVERT(CHAR ,CAST(G6R_DTIDA AS DATETIME),103) DTIDA,
			CONVERT(CHAR ,CAST(G6R_DTVLTA AS DATETIME),103) DTVLTA,
			CONVERT(CHAR ,CAST(G6R_DTINCL AS DATETIME),103) DTINCL,
			G6R_KMCONT KILOMETROS,
			G6R_VALACO VALACO,
			ROUND(G6R_VALACO/G6R_KMCONT,2) AS VALORKM	
		FROM %Table:G6R% G6R
			INNER JOIN %Table:GI1% GI1ORI ON	
				GI1ORI.GI1_FILIAL = %xFilial:GI1%
				AND GI1ORI.GI1_COD = G6R.G6R_LOCORI
				AND GI1ORI.%NotDel%
			INNER JOIN %Table:GI1% GI1DES ON	
				GI1DES.GI1_FILIAL = %xFilial:GI1%
				AND GI1DES.GI1_COD = G6R.G6R_LOCDES
				AND GI1DES.%NotDel%
		WHERE
			G6R.G6R_FILIAL =  %xFilial:G6R%
			AND G6R_DTIDA = %Exp:MV_PAR01%
			AND G6R_PDTOT %Exp:cWhere2%
			AND G6R.%NotDel%
			%Exp:cWhere1%

	EndSql

oSection1:EndQuery()    

Return nil
