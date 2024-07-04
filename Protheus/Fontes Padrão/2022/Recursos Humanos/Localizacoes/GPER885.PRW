#INCLUDE "GPER885.CH"        
#Include "REPORT.CH"
#INCLUDE "PROTHEUS.CH" 

#DEFINE _SEPARADOR "|"

Static _oGPER885
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑ| Programa    ณ GPER885  | Autor ณ Raul Ortiz Medina  | Data ณ 11/09/17      |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑ| Desc.       ณ Genera planilla de prima                                     |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso         ณ Generico                                                     |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑ|             ณ      ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.       |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑ| Programador ณ Data     ณIssue        ณMotivo da Alteracao                  |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑ|Roberto Glez ณ14/11/2017ณDMICNS-347   ณReplica de funcionalidad.            |ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿      
*/

Function GPER885()
Local nOpcA    := 0
Local aSays    := {}
Local aButtons := {}
Local aArea    := GetArea()
Local oReport  := Nil

Private cProcDes  := ""
Private cProcAte  := ""
Private cSitFol   := ""
Private cCatFun   := ""
Private dFecha    := CTOD("//")
Private nAnio     := 0
Private cRoteiro  := ""
Private cPerg     := "GPER885"
Private cAliasSRA := GetNextAlias()
Private nTamValor := TamSX3("RD_VALOR")[1]
Private cPictVlr  := PesqPict("SRC", "RC_VALOR", TamSX3("RC_VALOR")[1])

	Pergunte( cPerg, .F. )
	aAdd(aSays, OemToAnsi( STR0001 ) )  //"Planilla de Prima"
	aAdd(aButtons, { 5, .T., { || Pergunte(cPerg, .T.) } } )
	aAdd(aButtons, { 1, .T., { |o| IIf(VldParam(), (nOpcA := 1, o:oWnd:End()), Nil) }} )
	aAdd(aButtons, { 2, .T., { |o| nOpcA := 2, o:oWnd:End() }} )             
	FormBatch( oemtoansi(STR0001), aSays, aButtons ) //"Planilla de Prima"
	
	If nOpcA == 2
		Return
	Else
		cSitFol   := MV_PAR01
		cCatFun   := MV_PAR02
		cRoteiro  := MV_PAR03
		cProcDes  := MV_PAR04
		cProcAte  := MV_PAR05 
		nAnio     := MV_PAR06
	EndIf
	
	oReport := ReportDef()
	oReport:PrintDialog()
	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef  บAutor  ณLuis Samaniego      บFecha ณ  10/11/16   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define reporte                                              บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ReportDef()
Local oReport
Local oSection
Local cNomeProg := FunName()

	DEFINE REPORT oReport NAME cNomeProg TITLE STR0001 PARAMETER "" ACTION {|oReport| PrintReport(oReport,oSection) } DESCRIPTION STR0001 //"Planilla de Prima"
	oReport:SetTotalInLine(.F.)
	oReport:SetLandscape(.T.)
	oReport:lHeaderVisible := .F. 	
	
	DEFINE SECTION oSection OF oReport TITLE STR0001 TABLE "SM0","SRA" //"Planilla de Prima"
	/*01*/DEFINE CELL NAME "CORRELAT"  OF oSection TITLE OemToAnsi("N?") SIZE 6 HEADER ALIGN CENTER
	/*02*/DEFINE CELL NAME "TPDOC"     OF oSection TITLE OemToAnsi("TIPO DE"+CRLF+"DOCUMENTO DE"+CRLF+"IDENTIDAD") SIZE TamSX3("RA_TPCIC")[1] HEADER ALIGN CENTER
	/*03*/DEFINE CELL NAME "CARNET"    OF oSection TITLE OemToAnsi("CARNET DE"+CRLF+"IDENTIDAD") SIZE TamSX3("RA_CIC")[1] HEADER ALIGN CENTER
	/*04*/DEFINE CELL NAME "EXTCARNET" OF oSection TITLE OemToAnsi("EXTENSION"+CRLF+"DEL DOCUMENTO"+CRLF+"DE IDENTIDAD") SIZE TamSX3("RA_CODPAIS")[1] HEADER ALIGN CENTER
	/*05*/DEFINE CELL NAME "TPAFP"     OF oSection TITLE OemToAnsi("AFP A LA"+CRLF+"QUE APORTA") SIZE TamSX3("RA_TPAFP")[1] HEADER ALIGN CENTER
	/*06*/DEFINE CELL NAME "NUA/CUA"   OF oSection TITLE OemToAnsi("NUA/CUA") SIZE TamSX3("RA_NRNUA")[1] HEADER ALIGN CENTER
	/*07*/DEFINE CELL NAME "APPATERNO" OF oSection TITLE OemToAnsi("APELLIDO"+CRLF+"PATERNO") SIZE TamSX3("RA_PRISOBR")[1] HEADER ALIGN CENTER
	/*08*/DEFINE CELL NAME "APMATERNO" OF oSection TITLE OemToAnsi("APELLIDO"+CRLF+"MATERNO") SIZE TamSX3("RA_SECSOBR")[1] HEADER ALIGN CENTER
	/*09*/DEFINE CELL NAME "APCASADA"  OF oSection TITLE OemToAnsi("APELLIDO"+CRLF+"DE"+CRLF+"CASADA") SIZE TamSX3("RA_PRISOBR")[1] HEADER ALIGN CENTER /*Blanco*/
	/*10*/DEFINE CELL NAME "APNOMBRE"  OF oSection TITLE OemToAnsi("PRIMER"+CRLF+"NOMBRE") SIZE TamSX3("RA_PRINOME")[1] HEADER ALIGN CENTER
	/*11*/DEFINE CELL NAME "APNOMBRES" OF oSection TITLE OemToAnsi("OTROS"+CRLF+"NOMBRES") SIZE TamSX3("RA_SECNOME")[1] HEADER ALIGN CENTER
	/*12*/DEFINE CELL NAME "NACIONAL"  OF oSection TITLE OemToAnsi("NACIONALIDAD") SIZE TamSX3("X5_DESCSPA")[1] HEADER ALIGN CENTER
	/*13*/DEFINE CELL NAME "FECHANAC"  OF oSection TITLE OemToAnsi("FECHA DE"+CRLF+"NACIMIENTO") SIZE 15 HEADER ALIGN CENTER
	/*14*/DEFINE CELL NAME "SEXO"      OF oSection TITLE OemToAnsi("SEXO"+CRLF+"(F/M)") SIZE 4 HEADER ALIGN CENTER
	/*15*/DEFINE CELL NAME "JUBILADO"  OF oSection TITLE OemToAnsi("JUBILADO") SIZE 4 HEADER ALIGN CENTER
	/*15*/DEFINE CELL NAME "CLASILAB"  OF oSection TITLE OemToAnsi("CLASIFICACION"+CRLF+"LABORAL") SIZE 4 HEADER ALIGN CENTER /*Blanco*/
	/*17*/DEFINE CELL NAME "OCUPACION" OF oSection TITLE OemToAnsi("OCUPACION"+CRLF+"QUE"+CRLF+"DESEMPEัO") SIZE TamSX3("Q3_DESCSUM")[1] HEADER ALIGN CENTER
	/*18*/DEFINE CELL NAME "FECHAING"  OF oSection TITLE OemToAnsi("FECHA DE"+CRLF+"INGRESO") SIZE 15 HEADER ALIGN CENTER
	/*19*/DEFINE CELL NAME "MODCONTRA" OF oSection TITLE OemToAnsi("MODALIDAD"+CRLF+"DE"+CRLF+"CONTRATO") SIZE 15 HEADER ALIGN CENTER /**/
	/*20*/DEFINE CELL NAME "FECHARET"  OF oSection TITLE OemToAnsi("FECHA DE"+CRLF+"RETIRO") SIZE 15 HEADER ALIGN CENTER
	/*21*/DEFINE CELL NAME "HORASDIA"  OF oSection TITLE OemToAnsi("HORAS"+CRLF+"PAGADAS"+CRLF+"DIA") SIZE 4 HEADER ALIGN CENTER /*Blanco*/
	/*22*/DEFINE CELL NAME "PHABERB"   OF oSection TITLE OemToAnsi("HABER"+CRLF+"BASICO") SIZE nTamValor HEADER ALIGN CENTER
	/*23*/DEFINE CELL NAME "PBONOANT"  OF oSection TITLE OemToAnsi("BONO DE"+CRLF+"ANTIGUEDAD") SIZE nTamValor HEADER ALIGN CENTER
	/*24*/DEFINE CELL NAME "PBONOPRO"  OF oSection TITLE OemToAnsi("BONO DE"+CRLF+"PRODUCCION") SIZE nTamValor HEADER ALIGN CENTER
	/*25*/DEFINE CELL NAME "PSUBSFRO"  OF oSection TITLE OemToAnsi("SUBSIDIO"+CRLF+"FRONTERA") SIZE nTamValor HEADER ALIGN CENTER
	/*26*/DEFINE CELL NAME "PTRABEYN"  OF oSection TITLE OemToAnsi("MONTO"+CRLF+"PAGADO POR"+CRLF+"TRABAJO"+CRLF+"EXTRAORDINARIO"+CRLF+"Y NOCTURNO") SIZE nTamValor HEADER ALIGN CENTER
	/*27*/DEFINE CELL NAME "POTROBON"  OF oSection TITLE OemToAnsi("OTROS"+CRLF+"BONOS"+CRLF+"O PAGOS") SIZE nTamValor HEADER ALIGN CENTER
	/*28*/DEFINE CELL NAME "PTOTLGAN"  OF oSection TITLE OemToAnsi("TOTAL"+CRLF+"GANADO") SIZE nTamValor HEADER ALIGN CENTER
	/*29*/DEFINE CELL NAME "APORAFPS"  OF oSection TITLE OemToAnsi("APORTE A"+CRLF+"LAS AFPs") SIZE nTamValor HEADER ALIGN CENTER /*Blanco*/
	/*30*/DEFINE CELL NAME "RCIVA"     OF oSection TITLE OemToAnsi("RC-IVA") SIZE nTamValor HEADER ALIGN CENTER /*Blanco*/
	/*31*/DEFINE CELL NAME "OTROSDES"  OF oSection TITLE OemToAnsi("OTROS"+CRLF+"DESCUENTOS") SIZE nTamValor HEADER ALIGN CENTER
	/*32*/DEFINE CELL NAME "TOTDESC"   OF oSection TITLE OemToAnsi("TOTAL"+CRLF+"DESCUENTOS") SIZE nTamValor HEADER ALIGN CENTER
	/*33*/DEFINE CELL NAME "LIQPAGAB"  OF oSection TITLE OemToAnsi("LIQUIDO"+CRLF+"PAGABLE") SIZE nTamValor HEADER ALIGN CENTER
	/*34*/DEFINE CELL NAME "SUCADIC"   OF oSection TITLE OemToAnsi("SUCURSAL O"+CRLF+"UBICACION"+CRLF+"ADICIONAL")SIZE 10 HEADER ALIGN CENTER
	
	oSection:SetHeaderPage(.F.)
	oSection:SetHeaderSection(.F.) 
	oSection:SetHeaderBreak(.T.)
				
Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutor  ณRaul Ortiz Medina   บFecha ณ  11/09/17   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime Reporte                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport,oSection)
	Local nReg       := 0
	Local nPos       := 0
	Local nLoop      := 0
	Local nPer       := 0
	Local nHaberBas  := 0 //Haber Basico
	Local nBonoAnt   := 0 //Bono Antiguedad
	Local nBonoPro   := 0 //Bono de Produccion
	Local nSubsidio  := 0 //Subsidio de Frontera
	Local nTrbExtra  := 0 //Trabajo Extraordinario y Nocturno
	Local nOtrosBon  := 0 //Otros Bonos
	Local nTltGanad  := 0 //Total Ganado
	Local nOtrosDes  := 0 //Total Descuentos
	Local nDescuent  := 0 //Descuentos
	Local nLiqGan    := 0 //Liquido Ganado
	Local nTltGanDD  := 0 //Total Ganado Despues de Duodecimas
	Local cQuery     := ""
	Local cPeriod    := ""
	Local cNumPago   := ""
	Local aPerAbe     := {} //Periodo Abierto
	Local aPerFec     := {} //Periodo Cerrado
	Local aVerbasFunc := {}
	Local aPeriod    := {}
	Local cSit		   := ""
	Local cCat       := ""
	Local aProc      := ""
	Local nProc      := 0
	Local nVerb      := 0
	Local aResVer    := {}
	Local nDiasTra   := 0
	Local nMesTra    := 0
	
	//Private cQrySRA     := GetNextAlias()
	//Private oTabTmp     := FWTemporaryTable():New(cQrySRA)
	Private aVerbas     := {}
	Private aConceptos  := {}
	Private aInfoEmp    := {,,,,}
	Private aVerbasFOL  := {}
	Private aConcepFOL  := {}
	Private aConcepAGU  := {}
	Private aVerbasAGU  := {}
	Private cProcesso   := ""
	
	//oTabTmp:Create()
	cSit := SeparaSit()
	cCat := SeparaCat()
	
	_oGPER885 := GetNextAlias()

	cQuery := "SELECT "
	cQuery += "RA_FILIAL, RA_MAT, RA_PROCES, RA_TPCIC, RA_CIC, RA_CODPAIS, RA_TPAFP, RA_NRNUA, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, " 
	cQuery += "RA_NACIONA, RA_NASC, RA_SEXO, RA_JUBILAC, RA_CARGO, RA_ADMISSA, RA_DEMISSA "
	cQuery += "FROM " + RetSqlName("SRA")
	cQuery += " WHERE "
	cQuery += "RA_PROCES BETWEEN '" + cProcDes + "' AND '" + cProcAte + "' "
	cQuery += "AND RA_SITFOLH IN (" + cSit + ") "
	cQuery += "AND RA_CATFUNC IN (" + cCat + ") "
	cQuery += "AND RA_MAT IN ("
	cQuery += "SELECT DISTINCT(RD_MAT) FROM " + RetSqlName("SRD")
	cQuery += " WHERE RD_ROTEIR = '" + cRoteiro + "') "
	
	If TcSrvType() == "AS/400"
		cQuery += "AND @DELETED@ = ' ' "
	Else
		cQuery += "AND D_E_L_E_T_ = ' ' "
	Endif 
	
	cQuery += "ORDER BY RA_FILIAL, RA_PROCES, RA_MAT"
	
	cQuery := ChangeQuery(cQuery)      
	
	//If Select(cQrySRA) > 0
		//(cQrySRA)->(dbCloseArea())
	//EndIf
	If Select("_oGPER885") > 0
		dbSelectArea("_oGPER885")
		_oGPER885->(dbCloseArea())
	EndIf
			
	//dbUseArea(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRA,.T.,.T.)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "_oGPER885", .T., .F.)
	
	TCSetField("_oGPER885","RA_NASC",   "D",8,0)
	TCSetField("_oGPER885","RA_ADMISSA","D",8,0)
	TCSetField("_oGPER885","RA_DEMISSA","D",8,0)
	
	aProc   := ObtProc()
	aPeriod := ObtPeriod(cRoteiro,aProc)
	ObtConcSRV() //Obtiene conceptos
	
	oReport:StartPage()
	oReport:SetTitle(UPPER(STR0001)) //"Planilla de Prima"
	oReport:SetPageNumber(1)
	
	nLoop := 1
	
	oSection:Init()
	/*01*/oSection:Cell("CORRELAT" ):SetValue(OemToAnsi("Nฐ"))
	/*02*/oSection:Cell("TPDOC"    ):SetValue(OemToAnsi("TIPO DE"+CRLF+"DOCUMENTO DE"+CRLF+" IDENTIDAD"))
	/*03*/oSection:Cell("CARNET"   ):SetValue(OemToAnsi("CARNET DE"+CRLF+" IDENTIDAD"))
	/*04*/oSection:Cell("EXTCARNET"):SetValue(OemToAnsi("EXTENSION"+CRLF+" DEL DOCUMENTO"+CRLF+" DE IDENTIDAD"))//
	/*05*/oSection:Cell("TPAFP"    ):SetValue(OemToAnsi("AFP A LA"+CRLF+" QUE APORTA"))
	/*06*/oSection:Cell("NUA/CUA"  ):SetValue(OemToAnsi("NUA/CUA"))
	/*07*/oSection:Cell("APPATERNO"):SetValue(OemToAnsi("APELLIDO"+CRLF+" PATERNO"))
	/*08*/oSection:Cell("APMATERNO"):SetValue(OemToAnsi("APELLIDO"+CRLF+" MATERNO"))
	/*09*/oSection:Cell("APCASADA" ):SetValue(OemToAnsi("APELLIDO"+CRLF+" DE"+CRLF+" CASADA"))
	/*10*/oSection:Cell("APNOMBRE" ):SetValue(OemToAnsi("PRIMER"+CRLF+" NOMBRE"))
	/*11*/oSection:Cell("APNOMBRES"):SetValue(OemToAnsi("OTROS"+CRLF+" NOMBRES"))
	/*12*/oSection:Cell("NACIONAL" ):SetValue(OemToAnsi("NACIONALIDAD"))
	/*13*/oSection:Cell("FECHANAC" ):SetValue(OemToAnsi("FECHA DE"+CRLF+" NACIMIENTO"))
	/*14*/oSection:Cell("SEXO"     ):SetValue(OemToAnsi("SEXO"+CRLF+"(F/M)"))
	/*15*/oSection:Cell("JUBILADO" ):SetValue(OemToAnsi("JUBILADO"))
	/*16*/oSection:Cell("CLASILAB" ):SetValue(OemToAnsi("CLASIFICACION"+CRLF+" LABORAL"))
	/*17*/oSection:Cell("OCUPACION"):SetValue(OemToAnsi("OCUPACION"+CRLF+" QUE"+CRLF+" DESEMPEัO"))
	/*18*/oSection:Cell("FECHAING" ):SetValue(OemToAnsi("FECHA DE"+CRLF+" INGRESO"))
	/*19*/oSection:Cell("MODCONTRA"):SetValue(OemToAnsi("MODALIDAD"+CRLF+" DE"+CRLF+" CONTRATO"))
	/*20*/oSection:Cell("FECHARET" ):SetValue(OemToAnsi("FECHA DE"+CRLF+" RETIRO"))
	/*21*/oSection:Cell("HORASDIA" ):SetValue(OemToAnsi("HORAS"+CRLF+" PAGADAS"+CRLF+" DIA"))
	/*22*/oSection:Cell("PHABERB"  ):SetValue(OemToAnsi("HABER"+CRLF+" BASICO"))
	/*23*/oSection:Cell("PBONOANT" ):SetValue(OemToAnsi("BONO DE"+CRLF+" ANTIGUEDAD"))
	/*24*/oSection:Cell("PBONOPRO" ):SetValue(OemToAnsi("BONO DE"+CRLF+" PRODUCCION"))
	/*25*/oSection:Cell("PSUBSFRO" ):SetValue(OemToAnsi("SUBSIDIO"+CRLF+" FRONTERA"))
	/*26*/oSection:Cell("PTRABEYN" ):SetValue(OemToAnsi("MONTO"+CRLF+" PAGADO POR"+CRLF+" TRABAJO"+CRLF+" EXTRAORDINARIO"+CRLF+" Y NOCTURNO"))
	/*27*/oSection:Cell("POTROBON" ):SetValue(OemToAnsi("OTROS"+CRLF+" BONOS"+CRLF+" O PAGOS"))
	/*28*/oSection:Cell("PTOTLGAN" ):SetValue(OemToAnsi("TOTAL"+CRLF+" GANADO"))
	/*29*/oSection:Cell("APORAFPS" ):SetValue(OemToAnsi("APORTE A"+CRLF+" LAS AFPs"))
	/*30*/oSection:Cell("RCIVA"    ):SetValue(OemToAnsi("RC-IVA"))
	/*31*/oSection:Cell("OTROSDES" ):SetValue(OemToAnsi("OTROS"+CRLF+" DESCUENTOS"))
	/*32*/oSection:Cell("TOTDESC"  ):SetValue(OemToAnsi("TOTAL"+CRLF+" DESCUENTOS"))
	/*33*/oSection:Cell("LIQPAGAB" ):SetValue(OemToAnsi("LIQUIDO"+CRLF+" PAGABLE"))
	/*34*/oSection:Cell("SUCADIC"  ):SetValue(OemToAnsi("SUCURSAL O"+CRLF+" UBICACION"+CRLF+" ADICIONAL"))
	oSection:PrintLine()
	_oGPER885->(dbGoTop())
	While !_oGPER885->(EOF())
	
		nHaberBas := 0 //Haber Basico
		nBonoAnt  := 0 //Bono Antiguedad
		nBonoPro  := 0 //Bono de Produccion
		nSubsidio := 0 //Subsidio de Frontera
		nTrbExtra := 0 //Trabajo Extraordinario y Nocturno
		nOtrosBon := 0 //Otros Bonos
		nTltGanad := 0 //Total Ganado
		nOtrosDes := 0 //Otros Descuentos
		nDescuent := 0 //Descuentos
		nLiqGan   := 0 //Liquido Ganado
		
		If cProcesso != _oGPER885->RA_PROCES
			If aScan(aPeriod,{|x| x[1] == _oGPER885->RA_PROCES}) > 0
				nProc := aScan(aPeriod,{|x| x[1] == _oGPER885->RA_PROCES})
				cProcesso := _oGPER885->RA_PROCES
			EndIf
		EndIf
		
		For nPer := 1 To Len(aPeriod[nProc][2])
			aPerAbe := {}
			aPerFec := {}
			
			nVerb := aScan(aResVer,{|x| x[1] == cProcesso + aPeriod[nProc][2][nPer][1] + aPeriod[nProc][2][nPer][2]})
			If nVerb == 0
			
				RetPerAbertFech( cProcesso ,; // Processo selecionado na Pergunte.
						cRoteiro ,; // Roteiro selecionado na Pergunte.
						aPeriod[nProc][2][nPer][1] ,; // Periodo selecionado na Pergunte.
						aPeriod[nProc][2][nPer][2] ,; // Numero de Pagamento selecionado na Pergunte.
						NIL ,;      // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
						NIL ,;      // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
						@aPerAbe ,; // Retorna array com os Periodos e NrPagtos Abertos
						@aPerFec )  // Retorna array com os Periodos e NrPagtos Fechados
						
				Aadd(aResVer,{cProcesso + aPeriod[nProc][2][nPer][1] + aPeriod[nProc][2][nPer][2],{aPerAbe,aPerFec} })
			Else
				aPerAbe := aResVer[nVerb][2][1]
				aPerFec := aResVer[nVerb][2][2]
			EndIf
						
			aVerbasFunc	:= RetornaVerbasFunc(	_oGPER885->RA_FILIAL,;	// Filial do funcionario corrente
					_oGPER885->RA_MAT,;	// Matricula do funcionario corrente
					NIL,;					// 
					cRoteiro,;				// Roteiro selecionado na pergunte
					aVerbasFOL,;		   // aVerbasFilter
					aPerAbe,;				// Array com os Periodos e Numero de pagamento abertos
					aPerFec)				// Array com os Periodos e Numero de pagamento fechados	
		
			For nReg := 1 To Len(aVerbasFunc)	
				nPos := aScan( aConcepFOL,{|x| x[1] == aVerbasFunc[nReg][03]} )									
				If nPos > 0
					If Alltrim(aConcepFOL[nPos][2]) == "A" //Haber Basico
						nHaberBas += aVerbasFunc[nReg][7] 
					ElseIf Alltrim(aConcepFOL[nPos][2]) == "B" //Bono Antiguedad
						nBonoAnt  += aVerbasFunc[nReg][7] 
					ElseIf Alltrim(aConcepFOL[nPos][2]) == "C" //Trabajo Extraordinario y Nocturno
						nTrbExtra += aVerbasFunc[nReg][7] 
					ElseIf Alltrim(aConcepFOL[nPos][2]) == "D" //Bono de Produccion
						nBonoPro  += aVerbasFunc[nReg][7] 
					ElseIf Alltrim(aConcepFOL[nPos][2]) == "F" //Otros Bonos
						nOtrosBon += aVerbasFunc[nReg][7] 
					ElseIf Alltrim(aConcepFOL[nPos][3]) == "1276" //Subsidio de Frontera
						nSubsidio += aVerbasFunc[nReg][7]
					ElseIf Alltrim(aConcepFOL[nPos][2]) == "J" //Descuentos
						nOtrosDes += aVerbasFunc[nReg][7]
					EndIf				
				EndIf
				If  PosSrv( aVerbasFunc[nReg, 3], _oGPER885->RA_FILIAL, "RV_TIPOCOD" ) == "2"
					nDescuent += aVerbasFunc[nReg][7]
				EndIf
			Next nReg
		
		Next nPer
		
		nHaberBas := nHaberBas / 3
		nBonoAnt  := nBonoAnt / 3
		nBonoPro  := nBonoPro / 3
		nSubsidio := nSubsidio / 3
		nTrbExtra := nTrbExtra / 3
		nOtrosBon := nOtrosBon / 3
		nTltGanad := nHaberBas + nBonoAnt + nBonoPro + nSubsidio + nTrbExtra + nOtrosBon
		nOtrosDes := nOtrosDes / 3
		nDescuent := nDescuent / 3
		nDiasTra  := (DATE() - _oGPER885->RA_ADMISSA) + 1 
		If nDiasTra > 90 .And. nDiasTra < 365
			nMesTra :=  Round(nDiasTra / 30, 0)
			nLiqGan := ((nTltGanad - nDescuent) / 12) * nMesTra
		Else
			nLiqGan := nTltGanad - nDescuent
		EndIf
		
		/*01*/oSection:Cell("CORRELAT" ):SetValue(Alltrim(Str(nLoop)))
		/*02*/oSection:Cell("TPDOC"    ):SetValue(Alltrim(_oGPER885->RA_TPCIC))
		/*03*/oSection:Cell("CARNET"   ):SetValue(Alltrim(_oGPER885->RA_CIC))
		/*04*/oSection:Cell("EXTCARNET"):SetValue(Alltrim(_oGPER885->RA_CODPAIS))
		/*05*/oSection:Cell("TPAFP"    ):SetValue(Alltrim(_oGPER885->RA_TPAFP))
		/*06*/oSection:Cell("NUA/CUA"  ):SetValue(Alltrim(_oGPER885->RA_NRNUA))
		/*07*/oSection:Cell("APPATERNO"):SetValue(Alltrim(_oGPER885->RA_PRISOBR))
		/*08*/oSection:Cell("APMATERNO"):SetValue(Alltrim(_oGPER885->RA_SECSOBR))
		/*09*/oSection:Cell("APCASADA" ):SetValue(Alltrim(""))//Vacํo
		/*10*/oSection:Cell("APNOMBRE" ):SetValue(Alltrim(_oGPER885->RA_PRINOME))
		/*11*/oSection:Cell("APNOMBRES"):SetValue(Alltrim(AllTrim(_oGPER885->RA_SECNOME)))
		/*12*/oSection:Cell("NACIONAL" ):SetValue(Alltrim(fDesc("SX5", "34"+_oGPER885->RA_NACIONA,"X5_DESCSPA")))
		/*13*/oSection:Cell("FECHANAC" ):SetValue(Alltrim(DTOC(_oGPER885->RA_NASC)))
		/*14*/oSection:Cell("SEXO"     ):SetValue(Iif(Alltrim(_oGPER885->RA_SEXO) == "M", "0", "1"))
		/*15*/oSection:Cell("JUBILADO" ):SetValue(Iif(Alltrim(_oGPER885->RA_JUBILAC) == "1", "1", "0"))
		/*16*/oSection:Cell("CLASILAB" ):SetValue(Alltrim(""))//Vacํo
		/*17*/oSection:Cell("OCUPACION"):SetValue(Alltrim(fDesc("SQ3", _oGPER885->RA_CARGO,"Q3_DESCSUM")))
		/*18*/oSection:Cell("FECHAING" ):SetValue(Alltrim(DTOC(_oGPER885->RA_ADMISSA)))
		/*19*/oSection:Cell("MODCONTRA"):SetValue(Alltrim(""))
		/*20*/oSection:Cell("FECHARET" ):SetValue(Alltrim(DTOC(_oGPER885->RA_DEMISSA)))
		/*21*/oSection:Cell("HORASDIA" ):SetValue(Alltrim(""))
		/*22*/oSection:Cell("PHABERB"  ):SetValue(TRANSFORM(nHaberBas, cPictVlr) )
		/*23*/oSection:Cell("PBONOANT" ):SetValue(TRANSFORM(nBonoAnt, cPictVlr ) )
		/*24*/oSection:Cell("PBONOPRO" ):SetValue(TRANSFORM(nBonoPro, cPictVlr ) )
		/*25*/oSection:Cell("PSUBSFRO" ):SetValue(TRANSFORM(nSubsidio, cPictVlr) )
		/*26*/oSection:Cell("PTRABEYN" ):SetValue(TRANSFORM(nTrbExtra, cPictVlr) )
		/*27*/oSection:Cell("POTROBON" ):SetValue(TRANSFORM(nOtrosBon, cPictVlr) )
		/*28*/oSection:Cell("PTOTLGAN" ):SetValue(TRANSFORM(nTltGanad, cPictVlr) )
		/*29*/oSection:Cell("APORAFPS" ):SetValue(TRANSFORM(0, cPictVlr))//Vacํo
		/*30*/oSection:Cell("RCIVA"    ):SetValue(TRANSFORM(0, cPictVlr))//Vacํo
		/*31*/oSection:Cell("OTROSDES" ):SetValue(TRANSFORM(nOtrosDes, cPictVlr) )
		/*32*/oSection:Cell("TOTDESC"  ):SetValue(TRANSFORM(nDescuent, cPictVlr) )
		/*33*/oSection:Cell("LIQPAGAB" ):SetValue(TRANSFORM(nLiqGan, cPictVlr) )
		/*34*/oSection:Cell("SUCADIC"  ):SetValue(Alltrim(""))//Vacํo
		oSection:PrintLine()
			
		
		nLoop += 1
		_oGPER885->(DbSkip())
	EndDo
	oReport:ThinLine()
	oSection:Finish()
	
	oReport:EndPage()
	_oGPER885->(dbCloseArea())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldParam   บAutor  ณRaul Ortiz Medina   บFecha ณ  12/09/17   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida parametros                                           บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldParam()
Local lRet := .T.

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03) .Or. Empty(MV_PAR04) .Or. Empty(MV_PAR05) .Or. Empty(MV_PAR06)
		lRet := .F.
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtProc    บAutor  ณRaul Ortiz Medina   บFecha ณ  28/09/17   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene los procesos a considerar                           บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtProc()
Local aProc   := {}
Local cFilRCJ := xFilial("RCJ")
Local lCont   := .T.


	dbSelectArea("RCJ")
	RCJ->(dbSetOrder(1)) //RCJ_FILIAL+RCJ_CODIGO
	If RCJ->(MsSeek(cFilRCJ + cProcDes))
		While RCJ->(!EOF()) .And. lCont
			aAdd(aProc, RCJ->RCJ_CODIGO)
			If cProcAte == RCJ->RCJ_CODIGO
				lCont := .F.
			EndIf
			RCJ->(dbSkip())
		EndDo
	EndIf

Return aProc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtPeriod  บAutor  ณRaul Ortiz Medina   บFecha ณ  12/09/17   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene periodo y numero de pago                            บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtPeriod(cRoteiro,aProc)
Local nI       := 0
Local nJ       := 0
Local cPeriodo := ""
Local cFilRCH  := xFilial("RCH")
Local aMesPer  := {"10","11","12"}
Local aPeriod  := {}
	
	dbSelectArea("RCH")
	RCH->(dbSetOrder(4)) //RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG
	For nJ := 1 To Len(aProc)
		AADD(aPeriod,{aProc[nJ],{}})
		For nI := 1 To Len(aMesPer) 
			cPeriodo := Alltrim(nAnio + aMesPer[nI])
			If RCH->(MsSeek(cFilRCH + aProc[nJ] + cRoteiro + cPeriodo))
				While RCH->(!EOF()) .And. RCH->(RCH_FILIAL + RCH_PROCES + RCH_ROTEIR + RCH_PER) == (cFilRCH + aProc[nJ] + cRoteiro + cPeriodo)
					If !Empty(RCH->(RCH_DTFECH))
						aAdd(aPeriod[Len(aPeriod)][2], {Alltrim(RCH_PER), Alltrim(RCH_NUMPAG)})
					EndIf
					RCH->(dbSkip())
				EndDo
			EndIf
		Next nI
	Next nJ
	
Return aPeriod

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtConcSRV บAutor  ณRaul Ortiz Medina   บFecha ณ  12/09/17   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene conceptos                                           บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtConcSRV(cRoteiro)
Local cFilSRV	   := xFilial("SRV")
Default cRoteiro := ""

	SRV->(DBSetOrder(1))
	SRV->(MsSeek(cFilSRV))
		
	If cRoteiro == "AGU"
		aConcepAGU := {}
		aVerbasAGU := {}
		SRV->(DBEval( {|| IF(SRV->RV_CODFOL $ "0024", AAdd(aVerbasAGU, {SRV->RV_COD}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
		SRV->(DBEval( {|| IF(SRV->RV_CODFOL $ "0024", AAdd(aConcepAGU, {SRV->RV_COD, SRV->RV_INFSAL, SRV->RV_CODFOL}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
	Else
		aConcepFOL := {}
		aVerbasFOL := {}
		SRV->(DBEval( {|| IF(SRV->RV_INFSAL $ "A|B|C|D|E|F|J" .OR. SRV->RV_CODFOL $ "1276", AAdd(aVerbasFOL, {SRV->RV_COD}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
		SRV->(DBEval( {|| IF(SRV->RV_INFSAL $ "A|B|C|D|E|F|J" .OR. SRV->RV_CODFOL $ "1276", AAdd(aConcepFOL, {SRV->RV_COD, SRV->RV_INFSAL, SRV->RV_CODFOL}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSeparaSit  บAutor  ณRaul Ortiz Medina   บFecha ณ  12/09/17   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Separa situaciones a ser consideradas                       บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SeparaSit()
Local nX    := 0
Local cSit  := ""
Local nTo   := Len(cSitFol)

	For nX := 1 To nTo
		cSit += "'" +  SUBSTRING (cSitFol, nX, 1) + "'" + Iif(nX<nTo, ",","")
	Next nX


Return cSit

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSeparaCat  บAutor  ณRaul Ortiz Medina   บFecha ณ  12/09/17   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Separa Categorias a ser consideradas                        บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SeparaCat()
Local nX    := 0
Local cCat  := ""
Local nTo   := Len(cCatFun)

	For nX := 1 To nTo
		cCat += "'" +  SUBSTRING (cCatFun, nX, 1) + "'" + Iif(nX<nTo, ",","")
	Next nX


Return cCat