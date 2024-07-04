#INCLUDE "GPER883.CH"        
#Include "REPORT.CH"
#INCLUDE "PROTHEUS.CH" 

#DEFINE _SEPARADOR "|"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑ| Programa    ณ GPER883  | Autor ณ Luis Samaniego     | Data ณ 07/11/16      |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑ| Desc.       ณ Genera planilla de pago de aguinaldo de navidad              |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso         ณ Generico                                                     |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑ|             ณ      ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.       |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑ| Programador ณ Data     ณ Motivo da Alteracao                               |ฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑ|				  ณ		      ณ                                                   |ฑฑ
ฑฑ|				  ณ		      ณ		                                            |ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿      
*/

Function GPER883()
Local nOpcA    := 0
Local aSays    := {}
Local aButtons := {}
Local aArea    := GetArea()
Local oReport  := Nil

Private cProcesso := ""
Private cDeNumEm  := ""
Private cANumEmp  := ""
Private cOrden    := ""
Private dFecha    := CTOD("//")
Private nAnio     := 0
Private cPerg     := "GPER883"
Private cAliasSRA := GetNextAlias()
Private cMeses    := Getmv("MV_PERAGUI")
Private nTamValor := TamSX3("RD_VALOR")[1]
Private aMeses    := {}
Private cPictVlr  := PesqPict("SRC","RC_VALOR",TamSX3("RC_VALOR")[1])
	
	If !Empty(cMeses)
		aMeses := Separa(cMeses, _SEPARADOR, .T.)
	Else
		MsgAlert(STR0007)
		Return
	EndIf
	
	Pergunte( cPerg, .F. )
	aAdd(aSays, OemToAnsi( STR0001 ) ) 
	aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{ |o| IIf(VldParam(), (nOpcA := 1, o:oWnd:End()), Nil) }} )
	aAdd(aButtons, { 2,.T.,{ |o| nOpcA := 2, o:oWnd:End() }} )             
	FormBatch( oemtoansi(STR0001), aSays, aButtons )
	
	If nOpcA == 2
		Return
	Else
		cProcesso  := MV_PAR01
		cDeNumEm   := MV_PAR02
		cANumEmp   := MV_PAR03
		nAnio      := MV_PAR04
		cOrden     := MV_PAR05
		dFecha     := MV_PAR06
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
Local oSectionA
Local oSectionB
Local oSectionC
Local cNomeProg := FunName()

	DEFINE REPORT oReport NAME cNomeProg TITLE STR0001 PARAMETER "" ACTION {|oReport| PrintReport(oReport,oSectionA,oSectionB,oSectionC) } DESCRIPTION STR0001
	oReport:SetTotalInLine(.F.)
	oReport:SetLandscape(.T.)	
	
	DEFINE SECTION oSectionA OF oReport TITLE "ENCABEZADO" TABLE "SM0","SRA"
		DEFINE CELL NAME "TIT_EMP" OF oSectionA TITLE "TIT_EMP" SIZE 80 HEADER ALIGN LEFT
		DEFINE CELL NAME "INF_EMP" OF oSectionA TITLE "INF_EMP" SIZE 80 HEADER ALIGN LEFT
		oSectionA:SetTotalInLine(.F.)
		oSectionA:SetHeaderSection(.F.)

	DEFINE SECTION oSectionB OF oReport TITLE STR0001 TABLE "SM0","SRA"
		DEFINE CELL NAME "CORRELAT"  OF oSectionB TITLE OemToAnsi("Nบ") SIZE 6 HEADER ALIGN CENTER
		DEFINE CELL NAME "CARNET"    OF oSectionB TITLE OemToAnsi("CARNET DE"+CRLF+"IDENTIDAD") SIZE TamSX3("RA_CIC")[1] + TamSX3("RA_CODPAIS")[1] HEADER ALIGN CENTER
		DEFINE CELL NAME "APPATERNO" OF oSectionB TITLE OemToAnsi("APELLIDO"+CRLF+"PATERNO") SIZE TamSX3("RA_PRISOBR")[1] HEADER ALIGN CENTER
		DEFINE CELL NAME "APMATERNO" OF oSectionB TITLE OemToAnsi("APELLIDO"+CRLF+"MATERNO") SIZE TamSX3("RA_SECSOBR")[1] HEADER ALIGN CENTER
		DEFINE CELL NAME "APNOMBRES" OF oSectionB TITLE OemToAnsi("NOMBRES") SIZE TamSX3("RA_PRINOME")[1] + TamSX3("RA_SECNOME")[1] HEADER ALIGN CENTER
		DEFINE CELL NAME "NACIONAL"  OF oSectionB TITLE OemToAnsi("NACIONALIDAD") SIZE TamSX3("X5_DESCSPA")[1] HEADER ALIGN CENTER
		DEFINE CELL NAME "FECHANAC"  OF oSectionB TITLE OemToAnsi("FECHA DE"+CRLF+"NACIMIENTO") SIZE 15 HEADER ALIGN CENTER
		DEFINE CELL NAME "SEXO"      OF oSectionB TITLE OemToAnsi("SEXO"+CRLF+"(F/M)") SIZE 4 HEADER ALIGN CENTER
		DEFINE CELL NAME "OCUPACION" OF oSectionB TITLE OemToAnsi("OCUPACION"+CRLF+"QUE"+CRLF+"DESEMPEัA") SIZE TamSX3("Q3_DESCSUM")[1] HEADER ALIGN CENTER
		DEFINE CELL NAME "FECHAING"  OF oSectionB TITLE OemToAnsi("FECHA DE"+CRLF+"INGRESO") SIZE 15 HEADER ALIGN CENTER
		DEFINE CELL NAME "PHABERB"   OF oSectionB TITLE OemToAnsi("PROMEDIO"+CRLF+"HABER"+CRLF+"BASICO") PICTURE cPictVlr SIZE nTamValor HEADER ALIGN CENTER
		DEFINE CELL NAME "PBONOANT"  OF oSectionB TITLE OemToAnsi("PROMEDIO"+CRLF+"BONO DE"+CRLF+"ANTIGUEDAD") PICTURE cPictVlr SIZE nTamValor HEADER ALIGN CENTER
		DEFINE CELL NAME "PBONOPRO"  OF oSectionB TITLE OemToAnsi("PROMEDIO"+CRLF+"BONO DE"+CRLF+"PRODUCCION") PICTURE cPictVlr SIZE nTamValor HEADER ALIGN CENTER
		DEFINE CELL NAME "PSUBSFRO"  OF oSectionB TITLE OemToAnsi("PROMEDIO"+CRLF+"SUBSIDIO"+CRLF+"FRONTERA") PICTURE cPictVlr SIZE nTamValor HEADER ALIGN CENTER
		DEFINE CELL NAME "PTRABEYN"  OF oSectionB TITLE OemToAnsi("PROMEDIO"+CRLF+"TRAB. EXTR."+CRLF+"Y NOCTURNO") PICTURE cPictVlr SIZE nTamValor HEADER ALIGN CENTER
		DEFINE CELL NAME "PPAGODOM"  OF oSectionB TITLE OemToAnsi("PROMEDIO"+CRLF+"PAGO"+CRLF+"DOMINICAL") PICTURE cPictVlr SIZE nTamValor HEADER ALIGN CENTER
		DEFINE CELL NAME "POTROBON"  OF oSectionB TITLE OemToAnsi("PROMEDIO"+CRLF+"OTROS"+CRLF+"BONOS") PICTURE cPictVlr SIZE nTamValor HEADER ALIGN CENTER
		DEFINE CELL NAME "PTOTLGAN"  OF oSectionB TITLE OemToAnsi("PROMEDIO"+CRLF+"TOTAL"+CRLF+"GANADO") PICTURE cPictVlr SIZE nTamValor HEADER ALIGN CENTER
		DEFINE CELL NAME "MESESTRA"  OF oSectionB TITLE OemToAnsi("MESES"+CRLF+"TRABAJADOS") SIZE 10 HEADER ALIGN CENTER
		DEFINE CELL NAME "TOTGANDUO" OF oSectionB TITLE OemToAnsi("TOTAL"+CRLF+"DESPUES DE"+CRLF+"DUODECIMAS") PICTURE cPictVlr SIZE nTamValor HEADER ALIGN CENTER
		DEFINE CELL NAME "FIRMA"     OF oSectionB TITLE OemToAnsi("FIRMA "+CRLF+"EMPLEADO") SIZE 10 HEADER ALIGN CENTER
		
	DEFINE SECTION oSectionC OF oReport TITLE "FIRMA" TABLE "SM0","SRA"
		DEFINE CELL NAME "FINREPORT1" OF oSectionC TITLE "" SIZE 6 HEADER ALIGN LEFT
		DEFINE CELL NAME "FINREPORT2" OF oSectionC TITLE "" SIZE 10 HEADER ALIGN LEFT
		DEFINE CELL NAME "FINREPORT3" OF oSectionC TITLE "" SIZE 12 HEADER ALIGN LEFT
		DEFINE CELL NAME "FINREPORT4" OF oSectionC TITLE "" SIZE 12 HEADER ALIGN LEFT
		DEFINE CELL NAME "FINREPORT5" OF oSectionC TITLE "" SIZE 20 HEADER ALIGN LEFT
		DEFINE CELL NAME "FINREPORT6" OF oSectionC TITLE "" SIZE 60 HEADER ALIGN LEFT
		DEFINE CELL NAME "FINREPORT7"  OF oSectionC TITLE "" SIZE 10 HEADER ALIGN LEFT
		DEFINE CELL NAME "FINREPORT8"  OF oSectionC TITLE "" SIZE 4  HEADER ALIGN LEFT
		DEFINE CELL NAME "FINREPORT9"  OF oSectionC TITLE "" SIZE 12 HEADER ALIGN LEFT
		DEFINE CELL NAME "FINREPORT10" OF oSectionC TITLE "" SIZE 10 HEADER ALIGN LEFT
		DEFINE CELL NAME "FINREPORT11" OF oSectionC TITLE "" SIZE 10 HEADER ALIGN LEFT
		DEFINE CELL NAME "FINREPORT12" OF oSectionC TITLE "" SIZE 20 HEADER ALIGN LEFT
		oSectionC:SetTotalInLine(.F.)
		oSectionC:SetHeaderSection(.F.)
		
Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutor  ณLuis Samaniego      บFecha ณ  10/11/16   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime Reporte                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport,oSectionA,oSectionB,oSectionC)
Local nReg       := 0
Local nPos       := 0
Local nLoop      := 0
Local nPer       := 0
Local nHaberBas  := 0 //Haber Basico
Local nBonoAnt   := 0 //Bono Antiguedad
Local nBonoPro   := 0 //Bono de Produccion
Local nSubsidio  := 0 //Subsidio de Frontera
Local nTrbExtra  := 0 //Trabajo Extraordinario y Nocturno
Local nPagoDom   := 0 //Pago Dominical
Local nOtrosBon  := 0 //Otros Bonos
Local nTltGanad  := 0 //Total Ganado
Local nMeses     := 0 //Meses Trabajados
Local nTltGanDD  := 0 //Total Ganado Despues de Duodecimas
Local cQuery     := ""
Local cPeriod    := ""
Local cNumPago   := ""
Local cRoteiro   := "FOL"
Local aPeriodFOL := {}
Local aPeriodAGU := {}
/*Totalizadores*/
Local nTHaberBas  := 0 //Haber Basico
Local nTBonoAnt   := 0 //Total Bono Antiguedad
Local nTBonoPro   := 0 //Total Bono de Produccion
Local nTSubsidio  := 0 //Total Subsidio de Frontera
Local nTTrbExtra  := 0 //Total Trabajo Extraordinario y Nocturno
Local nTPagoDom   := 0 //Total Pago Dominical
Local nTOtrosBon  := 0 //Total Otros Bonos
Local nTTltGanad  := 0 //Suma Total Ganado
Local nTMeses     := 0 //Total Meses Trabajados
Local nTTltGanDD  := 0 //Suma Total Ganado Despues de Duodecimas
Local aPerAbe     := {} //Periodo Abierto
Local aPerFec     := {} //Periodo Cerrado
Local aVerbasFunc := {}

Private cQrySRA     := CriaTrab(Nil,.F.)
Private aVerbas     := {}
Private aConceptos  := {}
Private aInfoEmp    := {'','','','',''}
Private aVerbasFOL  := {}
Private aConcepFOL  := {}
Private aConcepAGU  := {}
Private aVerbasAGU  := {}

	cQuery := "SELECT "
	cQuery += " RA_FILIAL, RA_MAT, RA_CIC, RA_CODPAIS, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RA_NACIONA, RA_NASC, RA_SEXO, RA_ADMISSA, RA_CARGO"
	cQuery += " FROM " + RetSqlName("SRA")
	cQuery += " WHERE "
	cQuery += " RA_MAT BETWEEN '" + cDeNumEm + "' AND '" + cANumEmp + "'"
	cQuery += "  AND "
	cQuery += " RA_PROCES = '" + cProcesso + "'"
	cQuery += " AND (RA_SITFOLH <> 'D' AND RA_SITFOLH <> 'T')"
	
	If TcSrvType() == "AS/400"
		cQuery += " AND @DELETED@ = ' ' "
	Else
		cQuery += " AND D_E_L_E_T_ = ' ' "
	Endif 
	
	If cOrden == 1
		cQuery += " ORDER BY RA_FILIAL, RA_MAT "
	EndIf
	
	cQuery := ChangeQuery(cQuery)      
	
	If Select(cQrySRA) > 0
		(cQrySRA)->(dbCloseArea())
	EndIf
			
	dbUseArea(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRA,.T.,.T.)
	TCSetField(cQrySRA,"RA_NASC",   "D",8,0)
	TCSetField(cQrySRA,"RA_ADMISSA","D",8,0)

	obtInfoEmp() //Obtiene informacion de tabla S007
	ObtConcSRV(cRoteiro) //Obtiene conceptos
	ObtConcSRV("AGU") //Obtiene conceptos
	aPeriodFOL := ObtPeriod(cRoteiro,aMeses)
	aPeriodAGU := ObtPeriod("AGU",{"12"})
	
	oReport:StartPage()
	oReport:SetTitle(UPPER(STR0001))
	oReport:SetPageNumber(1)
	
	oSectionA:Cell("TIT_EMP"):SetTitle("")
	oSectionA:Cell("INF_EMP"):SetTitle("")
	
	oSectionA:Init() 
	oSectionA:PrintLine()
	oSectionA:Cell("TIT_EMP"):SetValue(UPPER(STR0003))
	oSectionA:Cell("INF_EMP"):SetValue(UPPER(Alltrim(SM0->M0_NOMECOM)))
	oSectionA:PrintLine()
	oSectionA:Cell("TIT_EMP"):SetValue(UPPER(STR0004))
	oSectionA:Cell("INF_EMP"):SetValue(aInfoEmp[1])
	oSectionA:PrintLine()
	oSectionA:Cell("TIT_EMP"):SetValue(UPPER(STR0005))
	oSectionA:Cell("INF_EMP"):SetValue(aInfoEmp[2])
	oSectionA:PrintLine()
	oSectionA:Cell("TIT_EMP"):SetValue(UPPER(STR0006))
	oSectionA:Cell("INF_EMP"):SetValue(aInfoEmp[3])
	oSectionA:PrintLine()
	oReport:SkipLine(1)
	oReport:ThinLine()
	oSectionA:Finish()
	
	nLoop := 1
	
	oSectionB:Init()
	//oSectionB:PrintLine()
	(cQrySRA)->(dbGoTop())
	While !(cQrySRA)->(EOF())
		nHaberBas := 0 //Haber Basico
		nBonoAnt  := 0 //Bono Antiguedad
		nBonoPro  := 0 //Bono de Produccion
		nSubsidio := 0 //Subsidio de Frontera
		nTrbExtra := 0 //Trabajo Extraordinario y Nocturno
		nPagoDom  := 0 //Pago Dominical
		nOtrosBon := 0 //Otros Bonos
		nTltGanad := 0 //Total Ganado
		nMeses    := 0 //Meses Trabajados
		nTltGanDD := 0 //Total Ganado Despues de Duodecimas
		
		For nPer := 1 To Len(aPeriodFOL)
			aPerAbe := {}
			aPerFec := {}	
			RetPerAbertFech( cProcesso ,; // Processo selecionado na Pergunte.
					cRoteiro ,; // Roteiro selecionado na Pergunte.
					aPeriodFOL[nPer][1] ,; // Periodo selecionado na Pergunte.
					aPeriodFOL[nPer][2] ,; // Numero de Pagamento selecionado na Pergunte.
					NIL ,;      // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
					NIL ,;      // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
					@aPerAbe ,; // Retorna array com os Periodos e NrPagtos Abertos
					@aPerFec )  // Retorna array com os Periodos e NrPagtos Fechados
						
			aVerbasFunc	:= RetornaVerbasFunc(	(cQrySRA)->RA_FILIAL,;	// Filial do funcionario corrente
					(cQrySRA)->RA_MAT,;	// Matricula do funcionario corrente
					NIL,;					// 
					cRoteiro,;				// Roteiro selecionado na pergunte
					aVerbasFOL,;		   // aVerbasFilter
					aPerAbe,;				// Array com os Periodos e Numero de pagamento abertos
					aPerFec)				// Array com os Periodos e Numero de pagamento fechados
			
			For nReg := 1 To Len(aVerbasFunc)	
				nPos := aScan( aConcepFOL,{|x| x[1] == aVerbasFunc[nReg][03]} )									
				If Substr(aVerbasFunc[nReg][10], 5,2) $ (cMeses) .And. nPos > 0
					If Alltrim(aConcepFOL[nPos][2]) == "A" //Haber Basico
						nHaberBas += aVerbasFunc[nReg][7] 
					ElseIf Alltrim(aConcepFOL[nPos][2]) == "B" //Bono Antiguedad
						nBonoAnt  += aVerbasFunc[nReg][7] 
					ElseIf Alltrim(aConcepFOL[nPos][2]) == "C" //Trabajo Extraordinario y Nocturno
						nTrbExtra += aVerbasFunc[nReg][7] 
					ElseIf Alltrim(aConcepFOL[nPos][2]) == "D" //Bono de Produccion
						nBonoPro  += aVerbasFunc[nReg][7] 
					ElseIf Alltrim(aConcepFOL[nPos][2]) == "E" //Pago Dominical
						nPagoDom  += aVerbasFunc[nReg][7] 
					ElseIf Alltrim(aConcepFOL[nPos][2]) == "F" //Otros Bonos
						nOtrosBon += aVerbasFunc[nReg][7] 
					ElseIf Alltrim(aConcepFOL[nPos][3]) == "1276" //Subsidio de Frontera
						nSubsidio += aVerbasFunc[nReg][7]
					EndIf				
				EndIf
			Next nReg
		Next nPer
		
		nHaberBas := (nHaberBas / Len(aMeses))
		nBonoAnt  := (nBonoAnt  / Len(aMeses))
		nBonoPro  := (nBonoPro  / Len(aMeses))
		nSubsidio := (nSubsidio / Len(aMeses))
		nTrbExtra := (nTrbExtra / Len(aMeses))
		nPagoDom  := (nPagoDom  / Len(aMeses))
		nOtrosBon := (nOtrosBon / Len(aMeses))
	
		nTltGanad += nHaberBas + nBonoAnt + nTrbExtra + nBonoPro + nPagoDom + nOtrosBon + nSubsidio //Total Ganado
		
		ObtValAGU("AGU", aPeriodAGU, @nMeses, @nTltGanDD) //Obtiene Valores AGUINALDO
		nTltGanDD := ((nTltGanad * nMeses) / 12) //Total Ganado Despues de Duodecimas
		
		nTHaberBas += nHaberBas //Haber Basico
		nTBonoAnt  += nBonoAnt  //Total Bono Antiguedad
		nTBonoPro  += nBonoPro  //Total Bono de Produccion
		nTSubsidio += nSubsidio //Total Subsidio de Frontera
		nTTrbExtra += nTrbExtra //Total Trabajo Extraordinario y Nocturno
		nTPagoDom  += nPagoDom  //Total Pago Dominical
		nTOtrosBon += nOtrosBon //Total Otros Bonos
		nTTltGanad += nTltGanad //Suma Total Ganado
		nTMeses    += nMeses    //Total Meses Trabajados
		nTTltGanDD += nTltGanDD //Suma Total Ganado Despues de Duodecimas
		
		oSectionB:Cell("CORRELAT" ):SetValue(Alltrim(Str(nLoop)))
		oSectionB:Cell("CARNET"   ):SetValue(Alltrim((cQrySRA)->RA_CIC) +" "+ Alltrim((cQrySRA)->RA_CODPAIS))
		oSectionB:Cell("APPATERNO"):SetValue(Alltrim((cQrySRA)->RA_PRISOBR))
		oSectionB:Cell("APMATERNO"):SetValue(Alltrim((cQrySRA)->RA_SECSOBR))
		oSectionB:Cell("APNOMBRES"):SetValue(Alltrim((cQrySRA)->RA_PRINOME) +" "+ AllTrim((cQrySRA)->RA_SECNOME))
		oSectionB:Cell("NACIONAL" ):SetValue(Alltrim(fDesc("SX5","34"+(cQrySRA)->RA_NACIONA,"X5_DESCSPA")))
		oSectionB:Cell("FECHANAC" ):SetValue(Alltrim(DTOC((cQrySRA)->RA_NASC)))
		oSectionB:Cell("SEXO"     ):SetValue(Alltrim((cQrySRA)->RA_SEXO))
		oSectionB:Cell("OCUPACION"):SetValue(Alltrim(fDesc("SQ3",(cQrySRA)->RA_CARGO,"Q3_DESCSUM")))
		oSectionB:Cell("FECHAING" ):SetValue(Alltrim(DTOC((cQrySRA)->RA_ADMISSA)))
		oSectionB:Cell("PHABERB"  ):SetValue(nHaberBas)
		oSectionB:Cell("PBONOANT" ):SetValue(nBonoAnt)
		oSectionB:Cell("PBONOPRO" ):SetValue(nBonoPro)
		oSectionB:Cell("PSUBSFRO" ):SetValue(nSubsidio)
		oSectionB:Cell("PTRABEYN" ):SetValue(nTrbExtra)
		oSectionB:Cell("PPAGODOM" ):SetValue(nPagoDom)
		oSectionB:Cell("POTROBON" ):SetValue(nOtrosBon)
		oSectionB:Cell("PTOTLGAN" ):SetValue(nTltGanad)
		oSectionB:Cell("MESESTRA" ):SetValue(Alltrim(Str(nMeses)))
		oSectionB:Cell("TOTGANDUO"):SetValue(nTltGanDD)
		oSectionB:Cell("FIRMA"    ):SetValue("")
		oSectionB:PrintLine()
		
		nLoop += 1
		(cQrySRA)->(DbSkip())
	EndDo
	oReport:ThinLine()
	
	If nLoop > 0 
		oReport:SkipLine(1)
		oSectionB:Cell("CORRELAT" ):Hide()
		oSectionB:Cell("CARNET"   ):SetValue("TOTALES")
		oSectionB:Cell("APPATERNO"):Hide()
		oSectionB:Cell("APMATERNO"):Hide()
		oSectionB:Cell("APNOMBRES"):Hide()
		oSectionB:Cell("NACIONAL" ):Hide()
		oSectionB:Cell("FECHANAC" ):Hide()
		oSectionB:Cell("SEXO"     ):Hide()
		oSectionB:Cell("OCUPACION"):Hide()
		oSectionB:Cell("FECHAING" ):Hide()
		oSectionB:Cell("PHABERB"  ):SetValue(nTHaberBas)
		oSectionB:Cell("PBONOANT" ):SetValue(nTBonoAnt)
		oSectionB:Cell("PBONOPRO" ):SetValue(nTBonoPro)
		oSectionB:Cell("PSUBSFRO" ):SetValue(nTSubsidio)
		oSectionB:Cell("PTRABEYN" ):SetValue(nTTrbExtra)
		oSectionB:Cell("PPAGODOM" ):SetValue(nTPagoDom)
		oSectionB:Cell("POTROBON" ):SetValue(nTOtrosBon)
		oSectionB:Cell("PTOTLGAN" ):SetValue(nTTltGanad)
		oSectionB:Cell("MESESTRA" ):SetValue(Alltrim(Str(nTMeses)))
		oSectionB:Cell("TOTGANDUO"):SetValue(nTTltGanDD)
		oSectionB:Cell("FIRMA"    ):Hide()
		oSectionB:PrintLine()
		oReport:SkipLine(1)
		oReport:ThinLine()
	EndIf
	oReport:SkipLine(2)
	oSectionB:Finish()
	
	oSectionC:Init() 
	oSectionC:PrintLine()
	oSectionC:Cell("FINREPORT1"):Hide()
	oSectionC:Cell("FINREPORT2"):Hide()
	oSectionC:Cell("FINREPORT3"):Hide()
	oSectionC:Cell("FINREPORT4"):Hide()
	oSectionC:Cell("FINREPORT5"):Hide()
	oSectionC:Cell("FINREPORT6"):SetValue(PADR("_", Len(aInfoEmp[4]) + 20, "_"))
	oSectionC:Cell("FINREPORT7"):Hide()
	oSectionC:Cell("FINREPORT8"):Hide()
	oSectionC:Cell("FINREPORT9"):Hide()
	oSectionC:Cell("FINREPORT10"):Hide()
	oSectionC:Cell("FINREPORT11"):Hide()
	oSectionC:Cell("FINREPORT12"):SetValue("")
	oSectionC:Cell("FINREPORT6"):nAlign := 2
	oSectionC:Cell("FINREPORT12"):nAlign := 2
	oSectionC:PrintLine()
	
	oSectionC:Cell("FINREPORT6"):SetValue(UPPER(aInfoEmp[4]))
	oSectionC:Cell("FINREPORT12"):SetValue("Fecha: " + DTOC(dFecha))
	oSectionC:PrintLine()
	
	oSectionC:Cell("FINREPORT6"):SetValue(UPPER(aInfoEmp[5]))
	oSectionC:Cell("FINREPORT12"):SetValue("")
	oSectionC:PrintLine()
	
	oSectionC:Cell("FINREPORT6"):SetValue(UPPER("REPRESENTANTE LEGAL"))
	oSectionC:Cell("FINREPORT12"):SetValue("")
	oSectionC:PrintLine()
	
	oSectionC:Finish()	
	oReport:EndPage()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtPeriod  บAutor  ณLuis Samaniego      บFecha ณ  10/11/16   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene periodo y numero de pago                            บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtPeriod(cRoteiro, aMesPer)
Local nI       := 0
Local cPeriodo := ""
Local cFilRCH  := xFilial("RCH")
Local aPeriod  := {}
	
	dbSelectArea("RCH")
	RCH->(dbSetOrder(RetOrder("RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG")))
	For nI := 1 To Len(aMesPer) 
		cPeriodo := Alltrim(Str(nAnio) + aMesPer[nI])
		If RCH->(dbSeek(cFilRCH + cProcesso + cRoteiro + cPeriodo))
			While RCH->(!EOF()) .And. RCH->(RCH_FILIAL + RCH_PROCES + RCH_ROTEIR + RCH_PER) == (cFilRCH + cProcesso + cRoteiro + cPeriodo)
				aAdd(aPeriod, {Alltrim(RCH_PER), Alltrim(RCH_NUMPAG)})
				RCH->(dbSkip())
			EndDo
		EndIf
	Next nI
	
Return aPeriod

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณobtInfoEmp บAutor  ณLuis Samaniego      บFecha ณ  10/11/16   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene informacion de empresa y representante legal        บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function obtInfoEmp()
Local cCpo     := ""
Local cNomeArq := ""
Local cFilRCB  := ""
Local cFilRCC  := ""
Local nPoint   := 0
Local aPos     := {,,,,}
	
	nPoint   := 1
	cNomeArq := "S007"
	cFilRCB  := xFilial("RCB")
	
	DbSelectArea("RCB")     
	DbSetOrder(1)
	If RCB->(DbSeek(cFilRCB + cNomeArq))
		cCpo:= Alltrim(RCB->RCB_CAMPOS)
		
		While cFilRCB == RCB->RCB_FILIAL .and. RCB->RCB_CODIGO == cNomeArq
			cCpo:= Alltrim(RCB->RCB_CAMPOS)
			Do Case
				Case cCpo == "NEMPMITR"  
					aPos[1]:={nPoint, RCB->RCB_TAMAN}
				Case cCpo == "NIT"
					aPos[2]:={nPoint, RCB->RCB_TAMAN}
				Case cCpo == "NSEGSOC"
					aPos[3]:={nPoint, RCB->RCB_TAMAN}
				Case cCpo == "REPLEG"
					aPos[4]:={nPoint, RCB->RCB_TAMAN}
				Case cCpo == "IDREPLEG"
					aPos[5]:={nPoint, RCB->RCB_TAMAN}
			EndCase
			nPoint += RCB->RCB_TAMAN
			RCB->(DbSkip())
		Enddo
	
	EndIf
	
	cFilRCC  := xFilial("RCC")
	
	DbSelectArea("RCC")
	DbSetOrder(1)      
	If RCC->(DbSeek(cFilRCC + cNomeArq))
		Do While cFilRCC == RCC_FILIAL .and. RCC_CODIGO == cNomeArq
			aInfoEmp[1] := Alltrim(SubStr(RCC_CONTEU, aPos[1,1], aPos[1,2]))//NEMPMITR
			aInfoEmp[2] := Alltrim(SubStr(RCC_CONTEU, aPos[2,1], aPos[2,2]))//NIT
			aInfoEmp[3] := Alltrim(SubStr(RCC_CONTEU, aPos[3,1], aPos[3,2]))//NSEGSOC
			aInfoEmp[4] := Alltrim(SubStr(RCC_CONTEU, aPos[4,1], aPos[4,2]))//REPLEG
			aInfoEmp[5] := Alltrim(SubStr(RCC_CONTEU, aPos[5,1], aPos[5,2]))//IDREPLEG
			DbSkip()	
		EndDo  		
	EndIf
Return aInfoEmp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtConcSRV บAutor  ณLuis Samaniego      บFecha ณ  10/11/16   บฑฑ
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
Local cFilSRV		:= xFilial("SRV")

	SRV->(DBSetOrder(1))
	SRV->(DBSeek(cFilSRV))
	If cRoteiro == "FOL"
		aConcepFOL := {}
		aVerbasFOL := {}
		SRV->(DBEval( {|| IF(SRV->RV_INFSAL $ "A|B|C|D|E|F" .OR. SRV->RV_CODFOL $ "1276", AAdd(aVerbasFOL, {SRV->RV_COD}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
		SRV->(DBEval( {|| IF(SRV->RV_INFSAL $ "A|B|C|D|E|F" .OR. SRV->RV_CODFOL $ "1276", AAdd(aConcepFOL, {SRV->RV_COD, SRV->RV_INFSAL, SRV->RV_CODFOL}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
	ElseIf cRoteiro == "AGU"
		aConcepAGU := {}
		aVerbasAGU := {}
		SRV->(DBEval( {|| IF(SRV->RV_CODFOL $ "0024", AAdd(aVerbasAGU, {SRV->RV_COD}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
		SRV->(DBEval( {|| IF(SRV->RV_CODFOL $ "0024", AAdd(aConcepAGU, {SRV->RV_COD, SRV->RV_INFSAL, SRV->RV_CODFOL}), NIL) }, {|| SRV->RV_FILIAL ==  cFilSRV} ) )
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldParam   บAutor  ณLuis Samaniego      บFecha ณ  10/11/16   บฑฑ
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

	If Empty(MV_PAR01) .Or. Empty(MV_PAR03) .Or. Empty(MV_PAR04) .Or. Empty(MV_PAR05) .Or. Empty(MV_PAR06)
		lRet := .F.
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtValAGU  บAutor  ณLuis Samaniego      บFecha ณ  10/11/16   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene conceptos de aguinaldo                              บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtValAGU(cRoteiro, aPeriodAGU, nMeses, nTltGanDD)
Local nPer        := 0
Local nReg        := 0
Local aPerAbe     := {} //Periodo Abierto
Local aPerFec     := {} //Periodo Cerrado
Local aVerbasFunc := {}
	
	For nPer := 1 To Len(aPeriodAGU)
		aPerAbe := {}
		aPerFec := {}	
		RetPerAbertFech(;
				cProcesso ,; // Processo selecionado na Pergunte.
				cRoteiro ,; // Roteiro selecionado na Pergunte.
				aPeriodAGU[nPer][1] ,; // Periodo selecionado na Pergunte.
				aPeriodAGU[nPer][2] ,; // Numero de Pagamento selecionado na Pergunte.
				NIL ,;      // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
				NIL ,;      // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
				@aPerAbe ,; // Retorna array com os Periodos e NrPagtos Abertos
				@aPerFec )  // Retorna array com os Periodos e NrPagtos Fechados
					
		aVerbasFunc	:= RetornaVerbasFunc(	(cQrySRA)->RA_FILIAL,;	// Filial do funcionario corrente
				(cQrySRA)->RA_MAT,;	// Matricula do funcionario corrente
				NIL,;					// 
				cRoteiro,;				// Roteiro selecionado na pergunte
				aVerbasAGU,;		   // aVerbasFilter
				aPerAbe,;				// Array com os Periodos e Numero de pagamento abertos
				aPerFec)				// Array com os Periodos e Numero de pagamento fechados
		
		For nReg := 1 To Len(aVerbasFunc)	
			nPos := aScan( aConcepAGU,{|x| x[1] == aVerbasFunc[nReg][03]} )									
			If nPos > 0
				If Alltrim(aConcepAGU[nPos][3]) == "0024" //Meses Trabajados
					nMeses    := aVerbasFunc[nReg][6] 
					nTltGanDD += aVerbasFunc[nReg][7]
				EndIf				
			EndIf
		Next nReg
		
	Next
Return