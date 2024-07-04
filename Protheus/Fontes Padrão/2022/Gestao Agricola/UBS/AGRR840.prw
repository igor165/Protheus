#INCLUDE "PROTHEUS.CH"
//#INCLUDE "AGRR840.CH"
#INCLUDE "REPORT.CH"

//--------------------------------------------------------------
/*{Protheus.doc} 
Relatorio Listagem de produção por OP e Data

@Author: Ana Laura Olegini
@Since.: 08/06/2015
@Uso...: Gestão Agricola - UBS
*/
//--------------------------------------------------------------
Function AGRR840()
	Local oReport
	Local cPerg		:= "AGRR840"
	
	Private cSec1Temp := GetNextAlias()	
           
	If FindFunction("TRepInUse") .And. TRepInUse()

		//-- PERGUNTE
		
		If !Pergunte("AGRR840",.T.) //"AGRR840"
			Return
		EndIf

		//-------------------------
		// Interface de impressão       
		//-------------------------
		oReport:= ReportDef(cPerg)
		oReport:PrintDialog()
	EndIf
Return

//--------------------------------------------------------------
/*{Protheus.doc} 
Função de definição do layout e formato do relatório	

@Return: oReport (Objeto criado com o formato do relatório)
@Author: Ana Laura Olegini
@Since.: 08/06/2015
@Uso...: Gestão Agricola - UBS
*/
//--------------------------------------------------------------
Static Function ReportDef(cPerg)
	Local oReport	:= NIL

	oReport := TReport():New("AGRR840", "Listagem Produção", cPerg, {| oReport | PrintReport( oReport ) }, "Este relatório tem como objetivo imprimir os dados dos contratos de depósito/remessa conforme os paramêtros informados.")
	
	oReport:SetTotalInLine( .f. )
	oReport:SetLandScape()
	
	oSection1 := TRSection():New( oReport, "Lotes", { "NP9" } ) 
	
	// Seção 1
	TRCell():New( oSection1, "NP9_LOTE"		, cSec1Temp	, , , 15 )
	TRCell():New( oSection1, "NP9_OP"		, cSec1Temp	, , , 15 )
	TRCell():New( oSection1, "NP9_PROD"		, cSec1Temp	, , , 15 )
	TRCell():New( oSection1, "NP9_QUANT"	, cSec1Temp	, , , 15 )
	
	
Return (oReport)

//--------------------------------------------------------------
/*{Protheus.doc} 
Função de definição do layout e formato do relatório	

@Param: oReport (Objeto para manipulação das seções, atributos e dados do relatório) 
@Author: Ana Laura Olegini
@Since.: 08/06/2015
@Uso...: Gestão Agricola - UBS
*/
//--------------------------------------------------------------
Static Function PrintReport(oReport)
	Local oS1	:= oReport:Section(1)

	//Cancela relatorio
	If oReport:Cancel()
		Return( Nil )
	EndIf
	
	oS1:Init()
	
	// Query do relatorio secao 1		
	cQuery := " SELECT NP9.NP9_LOTE, NP9.NP9_OP, NP9.NP9_PROD, NP9.NP9_QUANT "
	cQuery +=  " FROM " + RetSqlName("NP9") + " NP9, " + RetSqlName("SB1") + " SB1 "
	cQuery += " WHERE NP9.NP9_FILIAL = '"+ xFilial("NP9")+"' "
	cQuery +=   " AND NP9.NP9_LOTE >= '" + MV_PAR01 + "'"
	cQuery +=   " AND NP9.NP9_LOTE <= '" + MV_PAR02 + "'"
	cQuery +=   " AND NP9.NP9_PROD >= '" + MV_PAR03 + "'"
	cQuery +=   " AND NP9.NP9_PROD <= '" + MV_PAR04 + "'"
	cQuery +=   " AND SB1.B1_GRUPO >= '" + MV_PAR05 + "'"
	cQuery +=   " AND SB1.B1_GRUPO <= '" + MV_PAR06 + "'"
	cQuery +=   " AND NP9.NP9_DATA >= '" + DTOS(MV_PAR07) + "'"
	cQuery +=   " AND NP9.NP9_DATA <= '" + DTOS(MV_PAR08) + "'"
	cQuery +=   " AND NP9.NP9_OP   >= '" + MV_PAR09 + "'"
	cQuery +=   " AND NP9.NP9_OP   <= '" + MV_PAR10 + "'"
	cQuery +=   " AND NP9.NP9_TRATO = '" + IIF(MV_PAR11 == 1,'1','2') + "'"
	cQuery +=   " AND NP9.NP9_PROD   = SB1.B1_COD "
	cQuery +=   " AND NP9.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery ) 			
	If Select(cSec1Temp) <> 0
		(cSec1Temp)->(dbCloseArea())
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cSec1Temp, .F., .T. )
	
	dbSelectArea(cSec1Temp)
	dbGoTop()
	While .Not. (cSec1Temp)->( Eof() )
	
		oS1:PrintLine()
		
		
	
		(cSec1Temp)->( dbSkip() )
	EndDo
	oS1:Finish()	

Return (Nil)
