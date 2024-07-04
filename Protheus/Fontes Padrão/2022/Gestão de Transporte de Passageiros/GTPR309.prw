#include 'PROTHEUS.CH'
#include 'PARMTYPE.CH'
#include 'GTPR309.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR309
Relatório de Resumo Diário Contratos - Data de Viagem

@author GTP
@since 04/03/2020
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Function GTPR309()
Local cPerg := "GTPR309EX"
Private oReport

If Pergunte( cPerg, .T. )
	oReport := ReportDef( cPerg )
	oReport:PrintDialog()
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definições do Relatório

@author GTP
@since 04/03/2020
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local oReport   := Nil
Local oSection  := Nil

//Ajuste no Layout para apresentar as informações de pedagio.
oReport := TReport():New("GTPR309",STR0001,cPerg,{|oReport| ReportPrint(oReport)},STR0002,.T.) //STR0001 //"Viagens com ocorrência" //"texto"
oReport:SetTotalInLine(.F.)
oReport:SetLeftMargin(01) 

oSection:= TRSection():New(oReport,STR0003, {"G56","G6Q"}, , .F., .T.) // //"Ocorrência x Viagens"

TRCell():New(oSection,"G56_FILIAL","G56",STR0004			,,TAMSX3("G56_FILIAL")[1]) //STR0004 //"Filial"
TRCell():New(oSection,"G56_CODIGO","G56",STR0005			,,TAMSX3("G56_CODIGO")[1]) //"Cod Ocorrência" //"Código"
TRCell():New(oSection,"G56_TPOCOR","G56",STR0006				,,TAMSX3("G56_TPOCOR")[1]) //"Tp Ocorrência" //"Tipo"
TRCell():New(oSection,"TMP_TPOCOR","G56",STR0007		,,TAMSX3("G6Q_DESCRI")[1]) //STR0007 //"Descrição"
TRCell():New(oSection,"G56_VIAGEM","G56",STR0008			,,TAMSX3("G56_VIAGEM")[1]) //STR0008 //"Viagem"
TRCell():New(oSection,"G56_DTVIAG","G56",STR0009		,,TAMSX3("G56_DTVIAG")[1]) //STR0009 //"DT. Viagem"
TRCell():New(oSection,"G56_LOCORI","G56",STR0010			,,TAMSX3("G56_LOCORI")[1]) //"Local Inicio" //"Inicio"
TRCell():New(oSection,"TMP_LOCORI","G56",STR0007		,,TAMSX3("GI1_DESCRI")[1]) //STR0007 //"Descrição"
TRCell():New(oSection,"G56_LOCDES","G56",STR0011			,,TAMSX3("G56_LOCDES")[1]) //"Local Destino" //"Destino"
TRCell():New(oSection,"TMP_LOCDES","G56",STR0007		,,TAMSX3("GI1_DESCRI")[1]) //STR0007 //"Descrição"
TRCell():New(oSection,"G56_HORA"  ,"G56",STR0012				,,TAMSX3("G56_HORA"  )[1]) //STR0012 //"Hora"
TRCell():New(oSection,"G56_STSOCR","G56",STR0013			,,015					 ) //STR0013 //"Status"
 	
Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função responsável pela impressão.

@author GTP
@since 04/03/2020
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oSection := oReport:Section(STR0003) //"Ocorrência x Viagens"

SetQrySection(oReport)

oSection:Print()	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetQrySection
description
@author  GTP
@since   04/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function SetQrySection(oReport)
Local oSection   := oReport:Section(STR0003) //"Ocorrência x Viagens"
Local cAliasSec1 := GetNextAlias()
Local cWhere     := ""

Pergunte( "GTPR309EX", .F. )
cWhere += "%"
If !(EMPTY(MV_PAR01)) .OR. !(EMPTY(MV_PAR02))
	cWhere += " AND G56.G56_DTVIAG BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
EndIf

If !(EMPTY(MV_PAR03)) .OR. !(EMPTY(MV_PAR04))
	cWhere += " AND G56.G56_TPOCOR BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
EndIf

If MV_PAR05 <> 4
	cWhere += " AND G56.G56_STSOCR = " + cvaltochar(MV_PAR05) + " "
EndIf
cWhere += "%"
oSection:BeginQuery()
	BeginSql Alias cAliasSec1

		SELECT 
			G56.G56_FILIAL,
			G56.G56_CODIGO,
			G56.G56_TPOCOR,
			G6Q.G6Q_DESCRI TMP_TPOCOR,
			G56.G56_VIAGEM,
			CONVERT(CHAR ,CAST(G56.G56_DTVIAG AS DATETIME),103) G56_DTVIAG,
			G56.G56_LOCORI,
			GI1ORI.GI1_DESCRI TMP_LOCORI,
			G56.G56_LOCDES,
			GI1DES.GI1_DESCRI TMP_LOCDES,
			G56.G56_HORA  ,
			(CASE G56.G56_STSOCR WHEN '1' THEN 'Finalizada' WHEN '2' THEN 'Sem operacional' ELSE 'Com operacional' END) G56_STSOCR
		FROM %Table:G56% G56
		INNER JOIN %Table:G6Q% G6Q
			ON G6Q.G6Q_FILIAL = %xFilial:G6Q%
			AND G6Q.G6Q_CODIGO = G56.G56_TPOCOR
			AND G6Q.%NotDel%
		LEFT JOIN %Table:GI1% GI1ORI on
			GI1ORI.GI1_FILIAL = %xFilial:GI1%
			AND GI1ORI.GI1_COD = G56.G56_LOCORI
			AND GI1ORI.%NotDel%
		LEFT JOIN %Table:GI1% GI1DES on
			GI1DES.GI1_FILIAL = %xFilial:GI1%
			AND GI1DES.GI1_COD = G56.G56_LOCDES
			AND GI1DES.%NotDel%
		WHERE G56.G56_FILIAL = %xFilial:G56%
			AND G56.%NotDel%
			%Exp:cWhere%
		ORDER BY G56.G56_VIAGEM, G56.G56_FILIAL, G56.G56_CODIGO, G56.G56_TPOCOR
			
	EndSql

oSection:EndQuery()    

Return nil
