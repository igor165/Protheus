#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"
#Include "XMLXFUN.CH"
#Include "TBICONN.CH"
#Include "FONT.CH"
#Include "RPTDEF.CH"
#Include "FWMVCDEF.CH"
#Include "FINA925.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³FINA925   ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Retenciones e Informacion de Pagos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ Financiero                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                         ACTUALIZACIONES                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha    ³ Comentario                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo   ³13/12/2016³Mod func OBTORDPAGO uso de FWTemporaryTable     ³±±
±±³LuisEnríquez³13/05/2020³DMINA-8678 Correcciones en proceso de Timbrado  ³±±
±±³            ³          ³de CFDI de Retenciones, se limpia rutina.       ³±±
±±³LuisEnríquez³04/11/2020³DMINA-10569 Corrección de error.log por uso la  ³±±
±±³            ³          ³función alltrim errado. (MEX)                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINA925()
	Local aSays			:={} 
	Local aButtons	   	:={}
	Local cPerg			:= "FINA925"
	Local nOpca			:=  0
	
	Private oBrowse      := Nil
	Private aTmpArea     := {}  
	Private aVendors     := {}
	Private aLogErr      := {}
	Private nMesIni      := 0
	Private nMesFin      := 0
	Private nAnoFis      := 0
	Private cDir         := &(SuperGetmv( "MV_CFDRETP" , .F. , "GetSrvProfString('startpath','')+'\cfd\retPagos\'" ))
	Private lEnvMail     := .F.
	Private lEnvTimb     := .F.
	Private lFiltrar     := .F.
	Private nDecs        := 2
	Private nMoneda      := 1
	Private cXml         := '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
	Private cNodoSup     := '<#cNomNodo# #cValNodo#>' + CRLF
	Private cNodoInf     := '<#cNomNodo# #cValNodo#/>' + CRLF
	Private cIniNodo     := '<#cNomNodo#>' + CRLF
	Private cFinNodo     := '</#cNomNodo#>' + CRLF
	Private cPictNum     := "@E 99999999999999.99"
	Private cPictVer     := "@E 99.9"
	Private cPictInt     := "@E 9999"
	Private nTipPago     := 0
	Private dFchIni      := CTOD("")
	Private dFchFin      := CTOD("")
	Private cNoCert 	 := SuperGetMv("MV_CFDI_CS",,"")
	Private cCertif 	 := LeeCert()
	Private cRetIVA      := SuperGetMv("MV_RETIVAM",,"")
	Private cRetISR      := SuperGetMv("MV_RETISR",,"")  
	Private cRetIEPS     := SuperGetMv("MV_RETIEPS",,"")
	Private cTimeZone    := Alltrim(SuperGetMv("MV_RETZONE",,"-06:00"))
	Private oTmpTable	 := Nil
	Private oObjMBrw     := Nil
	Private lVisPDF      := .F.
	Private aIndArqE     := {}
	Private cFilSEK      := xFilial("SEK")
	Private cFilSE5      := xFilial("SE5")
	Private cFilSA2      := xFilial("SA2")
	Private cFilSE2   	 := xFilial("SE2")
	Private cFilSFB      := xFilial("SFB")
	Private cFilSA6      := xFilial("SA6")
	Private cFilSFC      := xFilial("SFC")
	Private cFilSYA      := xFilial("SYA")
	Private CveRet       := ""
	Private aDatosSM0    := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CGC", "M0_NOME", "M0_CODIGO", "M0_CODFIL"} ) 
	
	//Inicialización de preguntas 
	MV_PAR11 := ""
	MV_PAR12 := 2

	Pergunte( cPerg, .F. )
	aAdd(aSays,OemToAnsi( STR0001) ) //"Generación y timbrado de CFDI de la Contancia de Retenciones e Información de Pagos." 
	aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{ |o| IIf(ParamOK(),(nOpcA := 1, o:oWnd:End()),) }} )
	aAdd(aButtons, { 2,.T.,{ |o| nOpca := 2,o:oWnd:End() }} )             
	
	FormBatch( oemtoansi(STR0002), aSays , aButtons ) //"Retenciones e información de pago"

	If nOpca == 1
		aVendors  := GetVendor(MV_PAR01)
		nMesIni   := MV_PAR02
		nMesFin   := MV_PAR03
		nAnoFis   := MV_PAR04
		nTipPago  := MV_PAR05
		dFchIni   := MV_PAR06
		dFchFin   := MV_PAR07
		lEnvMail  := IIf(MV_PAR08 == 1, .T., .F.) 
		lEnvTimb  := IIf(MV_PAR09 == 1, .T., .F.)
		lFiltrar  := IIf(MV_PAR10 == 1, .T., .F.)
		CveRet    := MV_PAR11
		lVisPDF   := IIf(MV_PAR12 == 1, .T., .F.)
		If Empty(CveRet)	
			MsgAlert(STR0103, STR0015) //"Es necesario indicar el parámetro de tipo de retención." # "Atención"
		Else
			Processa({ || ObtOrdPago() })
			If oTmpTable <> Nil 
				oTmpTable:Delete()
	        EndIf					
		EndIf
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ObtOrdPago³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Monta pantalla con las ordenes de pago                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtOrdPago()
	Local cOrdAnt    := ""
	Local cQuery     := ""
	Local aCposTmp   := {}
	Local aCposEnc   := {} 
	Local nTB        := 0
	Local nTR        := 0 
	Local nDe        := 0
	Local nRe        := 0 
	Local nI         := 0
	Local aCores     := {} 
	
	Private cMarcaTR := ""
	Private cCadastro	:= ""
	Private cArqTRB   := CriaTrab(Nil, .F.)
	Private cArqTmp  := ""
	Private lInverte := .F.
	Private aRotina  := {}
	
	//Estructura tabla temporal
	AADD(aCposTmp,{ "MARK"     , "C", 2,  0 })
	AADD(aCposTmp,{ "FILIAL"   , "C", TamSX3("EK_FILIAL")[1] , TamSX3("EK_FILIAL")[2] })
	AADD(aCposTmp,{ "PROVEEDOR", "C", TamSX3("EK_FORNECE")[1], TamSX3("EK_FORNECE")[2] })
	AADD(aCposTmp,{ "SUCURSAL" , "C", TamSX3("EK_LOJA")[1]   , TamSX3("EK_LOJA")[2] })
	AADD(aCposTmp,{ "NUMERO"   , "C", TamSX3("EK_ORDPAGO")[1], TamSX3("EK_ORDPAGO")[2] })
	AADD(aCposTmp,{ "TOTALBRUT", "N", 17, nDecs })
	AADD(aCposTmp,{ "TOTALDESC", "N", 17, nDecs })
	AADD(aCposTmp,{ "TOTALREDU", "N", 17, nDecs })
	AADD(aCposTmp,{ "TOTALNETO", "N", 17, nDecs })
	AADD(aCposTmp,{ "EMISION"  , "D", 8,  0 })
	AADD(aCposTmp,{ "XML"      , "C", 60, 0 })
	AADD(aCposTmp,{ "DESCONCEP", "C", TamSX3("EK_DCONCEP")[1], TamSX3("EK_DCONCEP")[2] }) 
	
	cArqTmp  := CriaTrab(aCposTmp, .F.)
	
	//Estructura encabezado
	AADD(aCposEnc,{ "MARK"     , "", "" })
	AADD(aCposEnc,{ "FILIAL"   , "", OemToAnsi(STR0063) }) //"Sucursal"
	AADD(aCposEnc,{ "PROVEEDOR", "", OemToAnsi(STR0007) }) //"Proveedor"
	AADD(aCposEnc,{ "SUCURSAL" , "", OemToAnsi(STR0008) }) //"Sucursal"
	AADD(aCposEnc,{ "NUMERO"   , "", OemToAnsi(STR0006) }) //"Ord. De Pago"
	AADD(aCposEnc,{ "TOTALBRUT", "", OemToAnsi(STR0009),PesqPict("SEK","EK_VALOR",17,1) }) //"Total bruto"
	AADD(aCposEnc,{ "TOTALDESC", "", OemToAnsi(STR0010),PesqPict("SEK","EK_VALOR",17,1) }) //"Total Desc. PA"
	AADD(aCposEnc,{ "TOTALREDU", "", OemToAnsi(STR0011),PesqPict("SEK","EK_VALOR",17,1) }) //"Total reducido"
	AADD(aCposEnc,{ "TOTALNETO", "", OemToAnsi(STR0012),PesqPict("SEK","EK_VALOR",17,1) }) //"Total neto"
	AADD(aCposEnc,{ "EMISION"  , "", OemToAnsi(STR0013) }) //"Emitido"
	AADD(aCposEnc,{ "DESCONCEP", "", OemToAnsi(STR0142),PesqPict("SEK","EK_DCONCEP",17,1) }) //"Desc. Concepto"
	AADD(aCposEnc,{ "XML"      , "", OemToAnsi(STR0058) }) //"Archivo XML"
		
	cQuery := " SELECT * FROM " + RetSqlName("SEK") + " WHERE"
	cQuery += " ("
	For nI := 1 To Len(aVendors)
		cQuery += " (EK_FORNECE = '" + Alltrim(aVendors[nI][1]) + "'" 
		cQuery += " AND EK_LOJA = '" + Alltrim(aVendors[nI][2]) + "')"
		If nI != Len(aVendors)
			cQuery += " OR"
		EndIf
	Next nI
	cQuery += " ) AND EK_EMISSAO BETWEEN '" + DTOS(dFchIni) + "' AND '" + DTOS(dFchFin) + "'"
	cQuery += " AND EK_CANCEL = 'F' "
	cQuery += " AND D_E_L_E_T_ <> '*'"
	If lFiltrar
		cQuery += " AND EK_XMLRET = ''"
	EndIf
	cQuery += " ORDER BY EK_FORNECE, EK_LOJA, EK_ORDPAGO DESC"
	cQuery := ChangeQuery(cQuery)
	MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cArqTRB, .F., .T.)},OemToAnsi(STR0005),OemToAnsi(STR0004)) //"Por favor espere. " # "Seleccionando registros... " 
	
	oTmpTable := FWTemporaryTable():New(cArqTmp)
	oTmpTable:SetFields( aCposTmp )
	oTmpTable:AddIndex("IN1", {"PROVEEDOR","SUCURSAL","NUMERO"})
	oTmpTable:Create()
	
	ProcRegua((cArqTRB)->(RecCount()))
	
	While !(cArqTRB)->(EOF())
		IncProc(STR0005) //"Por favor espere. "	
		
		Reclock((cArqTmp),.T.)
			(cArqTmp)->NUMERO     := (cArqTRB)->EK_ORDPAGO
			(cArqTmp)->PROVEEDOR  := (cArqTRB)->EK_FORNECE
			(cArqTmp)->SUCURSAL   := (cArqTRB)->EK_LOJA
			(cArqTmp)->EMISION    := STOD((cArqTRB)->EK_EMISSAO)
			(cArqTmp)->XML        := (cArqTRB)->EK_XMLRET
			(cArqTmp)->FILIAL     := (cArqTRB)->EK_FILIAL
			(cArqTmp)->DESCONCEP  := POSICIONE("SEK", 1, cFilSEK + (cArqTRB)->EK_ORDPAGO, "EK_DCONCEP")
			
			nTB		:= 0
			nTR		:= 0
			nDe		:= 0
			nRe		:= 0
			cOrdAnt	:= (cArqTRB)->EK_ORDPAGO
			Do While (cArqTRB)->EK_ORDPAGO == cOrdAnt .And. !(cArqTRB)->(EOF())			
				If (cArqTRB)->EK_TIPODOC = "TB"		
					If Alltrim((cArqTRB)->EK_TIPO)$("PA"+MV_CPNEG)
						nDe	+=	IIf(nMoneda==1,(cArqTRB)->EK_VLMOED1,xMoeda((cArqTRB)->EK_VALOR,Max(Val((cArqTRB)->EK_MOEDA),1),nMoneda,(cArqTRB)->EK_DTDIGIT,nDecs+1))
					ElseIf (cArqTRB)->EK_TIPO $ MVABATIM
						nRe	+=	IIf(nMoneda==1,(cArqTRB)->EK_VLMOED1,xMoeda((cArqTRB)->EK_VALOR,Max(Val((cArqTRB)->EK_MOEDA),1),nMoneda,(cArqTRB)->EK_DTDIGIT,nDecs+1))
					Else
						nTB	+=	IIf(nMoneda==1,(cArqTRB)->EK_VLMOED1,xMoeda((cArqTRB)->EK_VALOR,Max(Val((cArqTRB)->EK_MOEDA),1),nMoneda,(cArqTRB)->EK_DTDIGIT,nDecs+1))
				   		nDe += IIf(nMoneda==1,(cArqTRB)->EK_DESCONT,xMoeda((cArqTRB)->EK_DESCONT,Max(Val((cArqTRB)->EK_MOEDA),1),nMoneda,(cArqTRB)->EK_DTDIGIT,nDecs+1))
					EndIf
				ElseIf (cArqTRB)->EK_TIPODOC=="RG"
					nTR	+=	IIf(nMoneda==1,(cArqTRB)->EK_VLMOED1,xMoeda((cArqTRB)->EK_VALOR,Max(Val((cArqTRB)->EK_MOEDA),1),nMoneda,(cArqTRB)->EK_DTDIGIT,nDecs+1))
				ElseIf (cArqTRB)->EK_TIPODOC=="PA"
					nTB	+= IIf(nMoneda==1,(cArqTRB)->EK_VLMOED1,xMoeda((cArqTRB)->EK_VALOR,Max(Val((cArqTRB)->EK_MOEDA),1),nMoneda,(cArqTRB)->EK_DTDIGIT,nDecs+1))
				ElseIf (cArqTRB)->EK_TIPODOC=="DE"
					nTB	+= IIf(nMoneda==1,(cArqTRB)->EK_VLMOED1,xMoeda((cArqTRB)->EK_VALOR,Max(Val((cArqTRB)->EK_MOEDA),1),nMoneda,(cArqTRB)->EK_DTDIGIT,nDecs+1))			
				EndIf
				
				(cArqTRB)->(dbSkip())	
			EndDo	   	
	
			(cArqTmp)->TOTALBRUT  += nTB
			(cArqTmp)->TOTALNETO  += (nTB-nTR-nDe-nRe)
			(cArqTmp)->TOTALDESC  += nDe
			(cArqTmp)->TOTALREDU  += nRe
		MsUnlock()	
	EndDo
	
	Aadd(aCores,{'!Empty(XML)', "BR_AZUL"})	
	Aadd(aCores,{'Empty(XML)', "BR_VERDE"})	
	
	aRotina := MenuDef()
	cMarcaTR := GetMark()
	MarkBrow(cArqTmp,"MARK","XML",aCposEnc,,cMarcaTR,,.F.,,,"FA925CKMX(cArqTmp,(cArqTmp)->NUMERO)",,,,aCores) 
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³MenuDef   ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Menu de opciones                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd(aRotina, { OemToAnsi(STR0014),'Processa({ || GenRetXML() })',0 ,3}) //"Gen. Constancia de Ret."
	aAdd(aRotina, { OemToAnsi(STR0139),'FA925Leg()',0,7,0,.F.})  //"Leyenda"
	aAdd(aRotina, { OemToAnsi(STR0140),'FA925CCat()',0,8,0,.F.}) //"Cargar Catálogos"
Return(aRotina)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³GenRetXML ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Genera XML                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GenRetXML()
	Local cNumOrdPag := ""
	Local cProveedor := ""
	Local cSucursal  := ""
	Local cXMLRet    := ""
	Local cExtXML    := ".xml"
	Local cNomXML    := ""
	Local cNomPDF    := ""
	Local nArchXML   := 0
	Local nI         := 0
	Local nPos       := 0
	Local nPdf       := 0
	Local aXML       := {}
	Local cVld       := ""
	Local oMark      := GetMarkBrow()
	Local aProc      := {}
	
	Private cFilAnt    := FWGETCODFILIAL
	Private aDetPag    := {} // Informacion de pagos
	Private aTRetSat   := {}
	Private aTImpSat   := {}
	Private nVersion   := 1.0
	Private lReq       := .T. // Atributo requerido
	Private lOpc       := .F. // Atributo opcional
	Private lCadOrig   := .T. // Atributo se usa para formar la cadena original
	Private lCodHTML   := .T. // Codifica caracteres especiales
	Private cCadOrig   := ""
	Private cFil	   := ""	
	Private cDesConc   := ""

	dbSelectArea("SA2")
	SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA 
	dbSelectArea("SE2")
	SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	dbSelectArea("SA6")
	SA6->(DbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	dbSelectArea("SF1")
	SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	dbSelectArea("SF2")
	SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	dbSelectArea("SD1")
	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	dbSelectArea("SD2")
	SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	dbSelectArea("SEK")
	SEK->(DbSetOrder(1)) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
	dbSelectArea("SE5")
	SE5->(DbSetORder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
	DbSelectArea("SFB")
	SFB->(DbSetOrder(1)) //FB_FILIAL+FB_CODIGO
	
	dbSelectArea(cArqTmp)
	(cArqTmp)->(dbGoTop())	
	ProcRegua(Reccount())
	Do While !(cArqTmp)->(EOF())
		IncProc()
		If IsMArk("MARK",cMarcaTR,lInverte)
			If SEK->(MsSeek(cFilSEK + (cArqTmp)->NUMERO))
				cNumOrdPag := (cArqTmp)->NUMERO
				cProveedor := (cArqTmp)->PROVEEDOR
				cSucursal  := (cArqTmp)->SUCURSAL
				cFil	   := (cArqTmp)->FILIAL
				cDesConc   := (cArqTmp)->DESCONCEP
				
				RetPago(cProveedor, cSucursal, cNumOrdPag)
				
			EndIf			
		EndIf
		
		RecLock(cArqTmp, .F.)
			MARK := ""
		MsUnLock()
		(cArqTmp)->(dbSkip())
					
		If Len(aDetPag) > 0
			For nI := 1 To Len(aTRetSat)
				cCadOrig := "||"
				cVld     := ""
				nPos := Len(aDetPag)

				cNomXML  := cFil +"_"+ IIf(Empty(aDetPag[nPos, 3]), 'XAXX010101000', Alltrim(aDetPag[nPos, 3])) +"_"+ Alltrim(Str(nMesIni)) +"_"+ Alltrim(Str(nMesFin)) +"_"+ Alltrim(Str(nAnoFis)) +"_"+ Alltrim(cNumOrdPag) + "_" + aTRetSat[nI,1] +  ".xml"
				cNomPDF  := cFil +"_"+ IIf(Empty(aDetPag[nPos, 3]), 'XAXX010101000', Alltrim(aDetPag[nPos, 3])) +"_"+ Alltrim(Str(nMesIni)) +"_"+ Alltrim(Str(nMesFin)) +"_"+ Alltrim(Str(nAnoFis)) +"_"+ Alltrim(cNumOrdPag) + "_" + aTRetSat[nI,1] + ".pdf"
				
				cVld := F925VldReg(cProveedor, cSucursal)
				
				If Empty(cVld)
					cXMLRet  := CreaXML(nI)
					
					If Len(aTImpSat) > 0
						cNomXML := StrTran( cNomXML, ' ', '_' )
						nArchXML := CreaArch(cNomXML, cExtXML)
						GrabaTexto(cXMLRet, nArchXML, .T.)						
					EndIf						
				EndIf
									
				aAdd(aXML, {cNomXML, aDetPag[nPos, 16],cVld,aDetPag[nPos,17],cProveedor+cSucursal,cNumOrdPag,.F.,.F.})
				
				If Empty(cVld)
					If Len(aXML) > 0 
						CFDiRecRet(@aXML)
						fUpdRetTmp(aXML)
						For nPdf := 1 to Len(aXML)
							If aXML[nPdf,7] //Timbrado
								ImpPDF(aXML[nPdf,1],Replace(aXML[nPdf,1],".xml",".pdf"))
							EndIf
						Next nPdf
						aAdd(aProc, {aXML[1][1],aXML[1][2],aXML[1][3],aXML[1][4],aXML[1][5],aXML[1][6],aXML[1][7],aXML[1][8]})
					EndIf
						
					If lEnvMail .And. Len(aXML) > 0
						fEnvMail(@aXML)
					EndIf										
				EndIf				
				
				cXMLRet  := ""
				aTImpSat := {}
			Next nI
			aDetPag  := {}
			aTRetSat := {}
			aOrdPag  := {}
			aImpostos:= {}
			aXML     := {}
		EndIf				
	EndDo
	
	ImprimeLog(aProc)
    
	oMark:oBrowse:Refresh()	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³RetPago   ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Calculo de retenciones                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetPago(cProv, cLoja, cOrdPago)
	Local cQuery		:= ""
	Local cAlias		:= CriaTrab(Nil, .F.)
	Local cCpoIVC		:= ""
	Local cCpoIEP		:= ""
	Local cCpoImp		:= ""
	Local cIEPS	        := SubStr(GetNewPar("MV_IEPS ",""),1,3)
	Local nValTit		:= 0
	Local nI			:= 0
	Local nX			:= 0
	Local nTit			:= 0
	Local nPos			:= 0
	Local nPorc		    := 0
	Local nPorcTit	    := 0
	Local nTtlOrd	    := 0
	Local nTtlTits	    := 0
	Local nVlrBase	    := 0
	Local nBaseFat	    := 0
	Local nVlrPago	    := 0
	Local nBaseTit	    := 0
	Local nMoedaBco	    := 0
	Local aTitulos	    := {}
	Local aImpD		    := {}
	Local aImpostos	    := {}
	Local aOrdPag       := {}
	Local dFechCHDeb	:= ctod("//")   
	Local cTipMoeSEK	:= ""           
	Local nVlrMoeSEK	:= 0           
	Local lMoedaPac 	:= .F.          
	Local nTaxaSEK  	:= 0           
	Local lChkDebPost	:= .F.		
	Local nEntBase  	:= 0            
	Local nEntVal   	:= 0           
	Local lLoop     	:= .F.	// No procesar movimientos
	Local cMoeExcep 	:= ""  // Excepcion por el tipo de moneda que se graba en SE5  
	Local cTabla        := ""
	Local cTablaDet     := ""		

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Estrutura do array aTitulos:                ³
	³1) Tipo - 1 compensacao; 0 normal           ³
	³2) Ordem de pago                            ³
	³3) Numero do documento (fatura)             ³
	³4) Serie do documento                       ³
	³5) Fornecedor                               ³
	³6) Filial do fornecedor                     ³
	³7) Valor                                    ³
	³8) Especie (CH,EF,TF,NCP,NDI etc)           ³
	³9) Documento (no caso de compensacao, possui³
	³   o documento original da compensacao)     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/	
	
	If SFB->(MsSeek(cFilSFB + "IVC"))
		cCpoIVC	:= "SD1->D1_VALIMP" + AllTrim(SFB->FB_CPOLVRO)
	EndIf
	If SFB->(MsSeek(cFilSFB + cIEPS))
		cCpoIEP	:= "SD1->D1_VALIMP" + AllTrim(SFB->FB_CPOLVRO)
	EndIf
	cQuery := " SELECT E5_DATA,E5_TIPO,E5_TIPODOC,E5_VALOR,E5_MOEDA,E5_VLMOED2,E5_ORDREC,E5_MOTBX,E5_DTDISPO,E5_NUMERO,E5_PREFIXO,E5_PARCELA,E5_FORNECE,E5_CLIENTE,E5_LOJA,E5_CLIFOR,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_TXMOEDA, E5_DOCUMEN, SE5.R_E_C_N_O_ 
	cQuery += " FROM " + RetSqlName("SE5")+ " SE5 "
	cQuery += " WHERE D_E_L_E_T_= ''"
	cQuery += " AND E5_FILIAL = '" + cFilSE5 + "'"
	cQuery += " AND ((E5_CLIFOR = '" + cProv + "'"
	cQuery += " AND E5_LOJA = '" + cLoja + "'" 
	cQuery += " AND E5_ORDREC = '" + cOrdPago + "')"
	cQuery += " AND E5_DATA >= '" + DTOS(dFchIni) + "'"
	cQuery += " AND E5_DATA <= '" + DTOS(dFchFin) + "'"
	cQuery += " AND (E5_MOTBX = 'NOR' OR E5_MOTBX = 'CMP')" // LEMP(17/11/11):Solo procesa Compensacion (PA/NCP) y bajas automaticas (OP)
	cQuery += " AND E5_SITUACA <> 'C'" 
	cQuery += " AND (((E5_TIPODOC IN ('VL','BA','CP')) AND E5_RECPAG = 'P')"
	cQuery += " OR (E5_TIPODOC='ES' and E5_RECPAG='R')))"
	cQuery += " UNION "  
	cQuery += " SELECT E5_DATA,E5_TIPO,E5_TIPODOC,E5_VALOR,E5_MOEDA,E5_VLMOED2,E5_ORDREC,E5_MOTBX,E5_DTDISPO,E5_NUMERO,E5_PREFIXO,E5_PARCELA,E5_FORNECE,E5_CLIENTE,E5_LOJA,E5_CLIFOR,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_TXMOEDA, E5_DOCUMEN, SE5.R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("SE5") +" SE5, "+ RetSqlName("SE2") +" SE2,"+ RetSqlName("SEK") + " SEK"
	cQuery += " WHERE SE5.D_E_L_E_T_=''" 
	cQuery += " AND SEK.D_E_L_E_T_=''"
	cQuery += " AND SE2.D_E_L_E_T_=''"
	cQuery += " AND E5_FILIAL = '" + cFilSE5 + "' AND EK_FILIAL = '" + cFilSEK + "' AND E2_FILIAL = '" + cFilSE2 + "'"
	cQuery += " AND ((E5_CLIFOR = '" + cProv + "'"
	cQuery += " AND E5_LOJA = '" + cLoja + "'" 
	cQuery += " AND E5_ORDREC = '" + cOrdPago + "')"
	cQuery += " AND (E5_MOTBX = 'NOR' OR E5_MOTBX = 'CMP')" // LEMP(17/11/11):Solo procesa Compensacion (PA/NCP) y bajas automaticas (OP)  
	cQuery += " AND E5_ORDREC  = EK_ORDPAGO"       	
	cQuery += " AND EK_PREFIXO = E2_PREFIXO" 
	cQuery += " AND EK_NUM     = E2_NUM" 
	cQuery += " AND EK_PARCELA = E2_PARCELA" 
	cQuery += " AND EK_TIPO    = E2_TIPO" 
	cQuery += " AND EK_FORNECE = E2_FORNECE" 
	cQuery += " AND EK_LOJA    = E2_LOJA" 	
	cQuery += " AND E2_BAIXA >= '" + DTOS(dFchIni) + "'"
	cQuery += " AND E2_BAIXA <= '" + DTOS(dFchFin) + "'"
	cQuery += " AND E5_SITUACA <> 'C'" 
	cQuery += " AND (((E5_TIPODOC IN ('VL','BA','CP')) AND E5_RECPAG = 'P')"
	cQuery += " OR (E5_TIPODOC='ES' AND E5_RECPAG='R')))"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	TCSetField(cAlias,"E5_DATA","D",8,0)
	
	dbSelectArea(cAlias)
	(cAlias)->(DbGotop())
	While !((cAlias)->(Eof()))
		aTitulos   := {}
		nTtlOrd    := 0
		nTtlTits   := 0         
		dFechCHDeb := ctod("//")
		lMoedaPac  := .F.
		nTaxaSEK   := 0
		lChkDebPost:= .F.
		cTipMoeSEK := ""
		nVlrMoeSEK := 0
		lLoop      := .F.
		cMoeExcep  := (cAlias)->E5_MOEDA
		
		If SA6->(MsSeek(cFilSA6 + (cAlias)->E5_BANCO + (cAlias)->E5_AGENCIA + (cAlias)->E5_CONTA))
			nMoedaBco := If(SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA)
		EndIf
		If   Alltrim((cAlias)->E5_TIPODOC)=='CP' .And. (cAlias)->E5_MOEDA == '02'  
			cMoeExcep :="  " 
		EndIf
		If  nMoedaBco == 0 .And. !Empty(cMoeExcep)	
			nMoedaBco := Val(cMoeExcep)
		EndIf     
		
		If  cMoeExcep != '01' .And. ((cAlias)->E5_TXMOEDA !=1 .And. (cAlias)->E5_TXMOEDA !=0) 
			nValTit := xMoeda((cAlias)->E5_VALOR,nMoedaBco,1,(cAlias)->E5_DATA,MsDecimais(1),(cAlias)->E5_TXMOEDA)
		Else
			nValTit := xMoeda((cAlias)->E5_VALOR,nMoedaBco,1,(cAlias)->E5_DATA,MsDecimais(1))
		EndIf
		
		Do Case                                                                                               
			Case (cAlias)->E5_MOTBX == "NOR"
				If !Empty((cAlias)->E5_ORDREC)
					If (AllTrim((cAlias)->E5_TIPO) $ "NCP|NDI|NF|NDP|PA")
						cOrdPago := AllTrim((cAlias)->E5_ORDREC)
						SEK->(MsSeek(cFilSEK + cOrdPago))
						
						While !(SEK->(Eof())) .And. SEK->EK_FILIAL == cFilSEK .And. SEK->EK_ORDPAGO == cOrdPago
							If  Alltrim(SEK->EK_TIPO) == "CH"   
								nTaxaSEK:=0
								
								If SE2->(MsSeek(cFilSE2 + SEK->EK_PREFIXO + SEK->EK_NUM + SEK->EK_PARCELA + SEK->EK_TIPO + SEK->EK_FORNECE + SEK->EK_LOJA))
									If  !(dFchIni<=SE2->E2_BAIXA .And. dFchFin>=SE2->E2_BAIXA)
										SEK->(DbSkip())
										lLoop := .T.
										Loop
									EndIf 
									If  SE2->E2_SALDO == 0
										If  SEK->EK_MOEDA <> '1'
											dFechCHDeb:= SE2->E2_BAIXA
										Else
											cTipMoeSEK:= SEK->EK_MOEDA
											nVlrMoeSEK:= SEK->EK_TXMOE02
										EndIf 
										nTtlOrd += SEK->EK_VLMOED1 
										cMoeda:= IIf(Len(Alltrim(SEK->EK_MOEDA))==1,"0"+SEK->EK_MOEDA,SEK->EK_MOEDA) 
										If (SEK->(FieldPos("EK_TXMOE"+cMoeda)) > 0 ) 
											nTaxaSEK := MoedaPact((cAlias)->E5_DATA, SE2->E2_BAIXA, SE2->E2_VENCTO, SEK->&("EK_TXMOE"+cMoeda), cMoeda)
										EndIf 
										If  SE2->E2_BAIXA<>(cAlias)->E5_DATA  
											lMoedaPac := .T.
										EndIf
										If cMoeExcep <> cMoeda .And. cMoeda == "01"
											nTaxaSEK := SEK->&("EK_TXMOE"+cMoeExcep)
										EndIf
										
										nPos := Ascan(aOrdPag,{|x| x[1] == SEK->EK_ORDPAGO .And. x[2] == SEK->(RECNO())})
										If nPos == 0
											aAdd(aOrdPag, {SEK->EK_ORDPAGO, SEK->(RECNO())})
										EndIf
									EndIf
								EndIf
							ElseIf Alltrim(SEK->EK_TIPO) $ "EF|TF|PA"
								nTtlOrd += SEK->EK_VLMOED1     
								nTaxaSEK:=0
								If  Alltrim(SEK->EK_TIPO) $ "EF|TF"                                               
									If  SEK->EK_MOEDA == '1'             
									 	cTipMoeSEK:= SEK->EK_MOEDA    
										nVlrMoeSEK:= SEK->EK_TXMOE02
									EndIf 
									
									cMoeda := IIf(Len(Alltrim(SEK->EK_MOEDA))==1,"0","") + Trim(SEK->EK_MOEDA)
									
									If (SEK->(FieldPos("EK_TXMOE"+cMoeExcep)) > 0 )
										If cMoeExcep <> cMoeda .And. cMoeda == "01"
											nTaxaSEK := SEK->&("EK_TXMOE"+cMoeExcep)
										Else
											nTaxaSEK := MoedaPact((cAlias)->E5_DATA, SE2->E2_BAIXA, SE2->E2_VENCTO, SEK->&("EK_TXMOE"+cMoeda), cMoeda)
										EndIf
									EndIf
								EndIf    
								
								nPos := Ascan(aOrdPag,{|x| x[1] == SEK->EK_ORDPAGO .And. x[2] == SEK->(RECNO())})
								If nPos == 0
									aAdd(aOrdPag, {SEK->EK_ORDPAGO, SEK->(RECNO())})
								EndIf
							ElseIf Alltrim(SEK->EK_TIPO) $ "NCP|NDI"
								nTtlTits -= SEK->EK_VLMOED1
								
								nPos := Ascan(aImpostos,{|x| x[1] == SEK->EK_ORDPAGO})
								If nPos == 0
									aAdd(aOrdPag, {SEK->EK_ORDPAGO, SEK->R_E_C_N_O_})
								EndIf
							ElseIf  AllTrim(SEK->EK_TIPO) $ "NF|NDP"
								nTtlTits += SEK->EK_VLMOED1			
								
								nPos := Ascan(aOrdPag,{|x| x[1] == SEK->EK_ORDPAGO .And. x[2] == SEK->(RECNO())})
								If nPos == 0
									aAdd(aOrdPag, {SEK->EK_ORDPAGO, SEK->(RECNO())})
								EndIf				
							EndIf
							
							SEK->(DbSkip())
						Enddo
						    
						If  lLoop    
							(cAlias)->(DbSkip())
							Loop
						EndIf
						nPorcTit := nTtlOrd / nTtlTits
						If  nTtlOrd <> 0
							Aadd(aTitulos,{0,Iif((!Empty(dFechCHDeb) .And. dFechCHDeb<>(cAlias)->E5_DATA) .Or. lChkDebPost,"1",""),(cAlias)->E5_NUMERO,(cAlias)->E5_PREFIXO,(cAlias)->E5_CLIFOR,(cAlias)->E5_LOJA,nValTit,1,(cAlias)->E5_TIPO,"",Iif(!Empty(dFechCHDeb),dFechCHDeb,(cAlias)->E5_DATA)})  //LEMP(04/05/11)
						EndIf
					EndIf
				EndIf
		EndCase
	
		For nI := 1 To Len(aTitulos)
			aTitulos[nI,7] := aTitulos[nI,7] * nPorcTit
			aTitulos[nI,8] := nPorcTit
		Next nI
	
		For nTit := 1 To Len(aTitulos)
			nTtlFat := 0
			cTipoPag := ""
			aImpostos := {}
			If AllTrim(aTitulos[nTit, 9])  $ "NF|NDP"
				cTabla    := "SF1"
				cTablaDet := "SD1"
			ElseIf AllTrim(aTitulos[nTit, 9]) $ "NCP|NDI"
				cTabla    := "SF2"
				cTablaDet := "SD2"
			EndIf

			If  (cTabla)->(MsSeek(xFilial(cTabla) + aTitulos[nTit,3] + aTitulos[nTit,4] + aTitulos[nTit,5] + aTitulos[nTit,6]))
				nMoeda		:= &((cTabla) + "->" + Substr(cTabla, 2, 2) + "_MOEDA")
				nDtDigit	:= &((cTabla) + "->" + Substr(cTabla, 2, 2) + "_DTDIGIT")
				nTxMoeda	:= &((cTabla) + "->" + Substr(cTabla, 2, 2) + "_TXMOEDA")
				dDtEmis	:= &((cTabla) + "->" + Substr(cTabla, 2, 2) + "_EMISSAO")
				cEspNF		:= &((cTabla) + "->" + Substr(cTabla, 2, 2) + "_ESPECIE")
				cFilSE		:= xFilial(cTablaDet)
				nVlrBase := 0
				nBaseFat := 0
				nBaseTit := 0
				nVlrTit  := 0   
				nEntBase := 0
				nEntVal  := 0
				
				If  (cTipMoeSEK =="1" .And. nMoeda !=1) .And. (lMoedaPac)                                                                          
					nTtlFat := xMoeda(&((cTabla) + "->" + Substr(cTabla, 2, 2) + "_VALBRUT"),nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nVlrMoeSEK)
				Else
					nTtlFat := xMoeda(&((cTabla) + "->" + Substr(cTabla, 2, 2) + "_VALBRUT"),nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)
				EndIf 
				
				(cTablaDet)->(MsSeek(cFilSE + aTitulos[nTit,3] + aTitulos[nTit,4] + aTitulos[nTit,5] + aTitulos[nTit,6]))
				
				While !((cTablaDet)->(Eof())) .And. &((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_FILIAL") == cFilSE .And.;
					 &((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_DOC") == aTitulos[nTit,3] .And.;
					 AllTrim(&((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_SERIE")) == AllTrim(aTitulos[nTit,4]) .And.;
					 &((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + IIf(cTablaDet == "SD1", "_FORNECE", "_CLIENTE")) == aTitulos[nTit,5] .And.;
					 Alltrim(&((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_LOJA")) == Alltrim(aTitulos[nTit,6])
				
					nVlrBase := &((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_TOTAL")
					nVlrTit  := &((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_TOTAL") 
					If cTablaDet == "SD1"   
						If !Empty(&((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_VALDESC"))   //Existe un descuente a nivel item y no se consideraba
							nVlrBase-= &((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_VALDESC")
							nVlrTit -= &((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_VALDESC")
						EndIf
					EndIf

					aImpD := DefImposto(&((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_TES"))
					For nX := 1 To Len(aImpD)
						cCampoBase:= (cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_" + aImpD[nX][7]
						cCampoAliq:= (cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_" + aImpD[nX][8]
						cCampoVal := (cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_" + aImpD[nX][2]
						nPos := Ascan(aImpostos,{|aimp| aimp[1] == aImpD[nX,1] .And. aimp[2] == &cCampoAliq})
						If nPos == 0
							Aadd(aImpostos,{aImpD[nX,1],&cCampoAliq,0,0,0,0,"",""})
							nPos := Len(aImpostos)
						EndIf   
						If  dDtEmis ==  aTitulos[nTit,11]   //Considerar la moneda pactada
							lMoedaPac := .T.             
						EndIf                         
						If  (cTipMoeSEK =="1" .And. nMoeda !=1) .And. (lMoedaPac)   //Significa que el pago es en $ y la NF en dolar
							aImpostos[nPos,3] += xMoeda(&cCampoBase,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)
							aImpostos[nPos,4] += xMoeda(&cCampoVal,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)
							nEntBase := xMoeda(&cCampoBase,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)
							nEntVal  := xMoeda(&cCampoVal,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)
						Else                                                                         
							aImpostos[nPos,3] += xMoeda(&cCampoBase,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)
							aImpostos[nPos,4] += xMoeda(&cCampoVal,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)		
							nEntBase := xMoeda(&cCampoBase,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)
							nEntVal  := xMoeda(&cCampoVal,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)
						EndIf
					Next nX
					
					SFC->(MsSeek(cFilSFC +  &((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_TES")))
					While !(SFC->(Eof())) .And. SFC->FC_TES == &((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_TES")
						Do Case
							Case SFC->FC_IMPOSTO == "IVC"
								nVlrBase := nVlrBase -&cCpoIVC
							Case SFC->FC_IMPOSTO == cIEPS
								nVlrBase := nVlrBase- &cCpoIEP
							OtherWise
								IF SFC->FC_INCDUPL=="2"
									SFB->(MsSeek(cFilSFB + SFC->FC_IMPOSTO))
									cCpoImp := ((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_VALIMP") + AllTrim(SFB->FB_CPOLVRO)
									nVlrTit -= &cCpoImp
								ElseIf SFC->FC_INCDUPL=="1"
									SFB->(MsSeek(cFilSFB + SFC->FC_IMPOSTO))
									cCpoImp := ((cTablaDet) + "->" + Substr(cTablaDet, 2, 2) + "_VALIMP") + AllTrim(SFB->FB_CPOLVRO)
									nVlrTit += &cCpoImp
								EndIf
						EndCase     
						SFC->(DbSkip())
					EndDo
					
					(cTablaDet)->(DbSkip())
					nBaseFat += nVlrBase
					nBaseTit += nVlrTit
					
					IF  Len(aImpD)==0    //IVA EXENTO
						Aadd(aImpostos,{"EXENTO",0,0,0,0,0,"",""})         
						If  (cTipMoeSEK =="1" .And. nMoeda !=1) .And. (lMoedaPac)      
							aImpostos[len(aImpostos),4] += xMoeda(nVlrBase,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)
						Else                                                                         
							aImpostos[len(aImpostos),4] += xMoeda(nVlrBase,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)
						EndIf			
					Elseif  nBaseFat <> 0 .AND. nBaseTit <> 0
						If  aImpostos[nPos,2] == 0 //IVA CERO
							If  (nEntBase == 0 .And. nEntVal == 0)
								If  (cTipMoeSEK =="1" .And. nMoeda !=1) .And. (lMoedaPac)
									aImpostos[nPos,3] += xMoeda(nVlrBase,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)
									aImpostos[nPos,4] += xMoeda(nVlrTit,nMoeda,1,ctod("//"),MsDecimais(1),nVlrMoeSEK)
								Else                                                                         		
									aImpostos[nPos,3] += xMoeda(nVlrBase,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)
									aImpostos[nPos,4] += xMoeda(nVlrTit,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)
								EndIf
							EndIf
						EndIf
					EndIf   
		        Enddo
				
				If  (cTipMoeSEK == "1" .And. nMoeda != 1) .And. (lMoedaPac)
					nBaseFat := xMoeda(nBaseFat,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nVlrMoeSEK)
					nBaseTit := xMoeda(nBaseTit,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nVlrMoeSEK)
				Else
					nBaseFat := xMoeda(nBaseFat,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)
					nBaseTit := xMoeda(nBaseTit,nMoeda,1,aTitulos[nTit,11],MsDecimais(1),nTaxaSEK)
		    	EndIf
		    	
				nPorc := aTitulos[nTit,7] / nBaseTit
				nPorc := Iif(AllTrim((cAlias)->E5_TIPODOC) == "ES",-1*Min(1,abs(nPorc)),Iif(AllTrim((cAlias)->E5_TIPODOC) == "CP",nPorc,Min(1,abs(nPorc))))
				If  !Empty(aTitulos[nTit,2])
				   	nPorc:=1
				EndIf

				nVlrPago := nBaseTit * nPorc
				
				For nI := 1 To Len(aImpostos)
					aImpostos[nI, 5] := aImpostos[nI, 3] * nPorc
					aImpostos[nI, 6] := aImpostos[nI, 4] * nPorc
					If SFB->(MsSeek(cFilSFB + aImpostos[nI, 1]))
						aImpostos[nI, 7] := Alltrim(SFB->FB_TRETSAT)
						aImpostos[nI, 8] := Alltrim(SFB->FB_DESTRET)
							
						nPos := Ascan(aTRetSat,{|x| x[1] == Alltrim(SFB->FB_TRETSAT)})
						If nPos == 0 .And. (SFB->FB_CODIGO $ cRetIVA .Or. SFB->FB_CODIGO $ cRetISR .Or. SFB->FB_CODIGO $ cRetIEPS)
							aAdd(aTRetSat, {Alltrim(CveRet), Alltrim(ObtSX5 ("XF",CveRet))})	
						EndIf
					EndIf
				Next nI
				                       
				nPos := Ascan(aDetPag,{|fat| fat[1] == aTitulos[nTit,5] .And. fat[2] == aTitulos[nTit,6] .And. fat[6] == cFilAnt})
				
				If  nPos == 0
					SA2->(MsSeek(cFilSA2 + aTitulos[nTit,5] + aTitulos[nTit,6]))
					Aadd(aDetPag,{aTitulos[nTit,5],aTitulos[nTit,6],SA2->A2_CGC,SA2->A2_CURP,{},cFilAnt,SA2->A2_TIPOTER,SA2->A2_TPOPER,SA2->A2_CVESAT,SA2->A2_RLRFC,SA2->A2_RLCURP,SA2->A2_RLCVSAT,SA2->A2_ESBENEF,SA2->A2_EST,SA2->A2_NOME,SA2->A2_EMAIL,{},ObtPaisSat(SA2->A2_PAIS)}) 
					nPos := Len(aDetPag)
				EndIf
					
			  	If  !Empty(dDtEmis)
				   	Aadd(aDetPag[nPos,5],{aTitulos[nTit,3],aTitulos[nTit,4],nTtlFat,nBaseFat,nMoeda,IIf((lMoedaPac .And. (cTipMoeSEK =="1" .And. nMoeda !=1)), nVlrMoeSEK, nTaxaSEK),dDtEmis,cEspNF,0,0,aImpostos,aTitulos[nTit,11],nPorc})
				   	nPosNF := Len(aDetPag[nPos,5])
					If aTitulos[nTit,1] == 1
						aDetPag[nPos,5,nPosNF,9] -= nVlrPago
						aDetPag[nPos,5,nPosNF,10] -= nVlrPago
					Else
						aDetPag[nPos,5,nPosNF,9] += nVlrPago
					EndIf 
					aAdd(aDetPag[nPos,17],aOrdPag) 
				EndIf
			EndIf
		Next nTit
		(cAlias)->(DbSkip())
	Enddo
	aAdd ( aTmpArea , cAlias ) 
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³MoedaPact ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Determina si la TC fue pactado                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MoedaPact(dFchEmi, dFchBaja, dFchVen, nTC, cMoneda)
	Local nTCFchEmi := ObtTipCambio(dFchEmi, cMoneda)
	Local nTCFchBaj := ObtTipCambio(dFchBaja, cMoneda)
	Local nTCMoneda := nTC
	Local lPactada  := .F.

	If nTC <> nTCFchEmi
		lPactada := .T.
	EndIf
	If !lPactada .And. dFchBaja != dFchVen
		nTCMoneda := nTCFchBaj
	EndIf
Return nTCMoneda

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ObtTipCambio³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Determina si la TC fue pactado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtTipCambio(dFecha, cMoneda)
Local nTipCam := 1
	
	If CTP->(DbSeek( xFilial("CTP") + DTOS(dFecha) + cMoneda))
		nTipCam := CTP->CTP_TAXA 
	EndIF
	
Return nTipCam

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³CreaXML     ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Forma archivo XML de retenciones                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CreaXML(nI)
	Local aAuxNodo   := {}
	Local nJ         := 0
	Local nK         := 0
	Local nL         := 0
	Local nPos       := 0
	Local nTotOper   := 0 // Total Operacion
	Local nTotGrav   := 0 // Total Gravado
	Local nTotExent  := 0 // Total Exento
	Local nTotRet    := 0 // Total Retenido
	Local cAuxXml    := cXml
	Local cSello     := ""  
	Local cPagProv   := "Pago provisional"
	Local cPagDef    := "Pago definitivo"
	Local cXmlnsRet  := " http://www.sat.gob.mx/esquemas/retencionpago/1"
	Local cXmlnsXsi  := " http://www.w3.org/2001/XMLSchema-instance"
	Local cXmlnsPag  := " http://www.sat.gob.mx/esquemas/retencionpago/1/pagosaextranjeros"
	Local cXsiSLocR  := " http://www.sat.gob.mx/esquemas/retencionpago/1 http://www.sat.gob.mx/esquemas/retencionpago/1/retencionpagov1.xsd"
	Local cXsiSLocP  := " http://www.sat.gob.mx/esquemas/retencionpago/1/pagosaextranjeros http://www.sat.gob.mx/esquemas/retencionpago/1/pagosaextranjeros/pagosaextranjeros.xsd"

	/*------------------------------------------
	|	1.- Nombre Atributo                     |
	|	2.- Valor                               |
	|	3.- Requerido/Opcional (.T. / .F.)      |
	|	4.- Forma Cadena original (.T. / .F.)   |
	|	5.- Usa CodHTML()                       |
	-------------------------------------------*/

	For nJ := 1 To Len(aDetPag)
	
			// Elemento: Retenciones 
			aAuxNodo := {{'Version="#cVal#"',		nVersion, lReq, lCadOrig, .F.},;
					{'NumCert="#cVal#"',				cNoCert, lReq, lCadOrig, .F.},;
					{'FechaExp="#cVal#"',   			FWTimeStamp(3, DATE(), Time()) + IIf(!Empty(cTimeZone),cTimeZone,"-00:00") , lReq, lCadOrig, .F.},;
					{'CveRetenc="#cVal#"',  			aTRetSat[nI,1], lReq, lCadOrig, lCodHTML},;
					{'DescRetenc="#cVal#"', 			aTRetSat[nI,2], lOpc, lCadOrig, lCodHTML},;
					{'Sello="#cVal#"',      			"#cSello#", lReq, .F., .F.},;
					{'Cert="#cVal#"',       			cCertif, lReq, .F., .F.},;
					{'xmlns:retenciones="#cVal#"', cXmlnsRet, lReq, .F., .F.},;
					{'xmlns:xsi="#cVal#"',       	cXmlnsXsi, lReq, .F., .F.}}
					
					If Alltrim(aDetPag[nJ, 14]) == "EX"
						aAdd(aAuxNodo, {'xmlns:pagosaextranjeros="#cVal#"', cXmlnsPag, lReq, .F., .F.})
					EndIf
					
					aAdd(aAuxNodo, {'xsi:schemaLocation="#cVal#"', cXsiSLocR + IIf(Alltrim(aDetPag[nJ, 14]) == "EX", cXsiSLocP, "") , lReq, .F., .F.})
							
					cAuxXml += ObtNodo(aAuxNodo, cNodoSup, 'retenciones:Retenciones')	
			
			// Elemento: Emisor 
			aAuxNodo := {{'RFCEmisor="#cVal#"',  aDatosSM0[1][2], lReq, lCadOrig, .F.},;   //SM0->M0_CGC
					{'NomDenRazSocE="#cVal#"', aDatosSM0[2][2], lOpc, lCadOrig, lCodHTML}} //SM0->M0_NOME
			
					cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'retenciones:Emisor')	
			
			// Elemento: Receptor
			aAuxNodo := {{'Nacionalidad="#cVal#"', IIf((Alltrim(aDetPag[nJ, 14]) == "EX"), "Extranjero", "Nacional"), lReq, lCadOrig, lCodHTML}}	
			
					cAuxXml += ObtNodo(aAuxNodo, cNodoSup, 'retenciones:Receptor')
			
			If !(Alltrim(aDetPag[nJ, 14])) == "EX" //Nacional
				// Elemento: Nacional
				aAuxNodo := {{'RFCRecep="#cVal#"',   IIf(Empty(aDetPag[nJ, 3]), 'XAXX010101000', aDetPag[nJ, 3]), lReq, lCadOrig, lCodHTML},;
						{'NomDenRazSocR="#cVal#"',   aDetPag[nJ, 15], lOpc, lCadOrig, lCodHTML},;
						{'CURPR="#cVal#"',           aDetPag[nJ, 4], lOpc, lCadOrig, lCodHTML}}
						
						cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'retenciones:Nacional')			
			Else //Extranjero
				// Elemento: Extranjero
				aAuxNodo := {{'NumRegIdTrib="#cVal#"',     IIf(Empty(aDetPag[nJ, 3]), 'XEXX010101000', aDetPag[nJ, 3]), lOpc, lCadOrig, lCodHTML},;
						{'NomDenRazSocR="#cVal#"',   aDetPag[nJ, 15], lReq, lCadOrig, lCodHTML}}	
							
						cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'retenciones:Extranjero')
			EndIf
				
			cAuxXml += Strtran(cFinNodo, '#cNomNodo#', 'retenciones:Receptor')			
							
			// Elemento: Periodo				
			aAuxNodo := {{'MesIni="#cVal#"',  nMesIni, lReq, lCadOrig, .F.},;
					{'MesFin="#cVal#"', nMesFin, lReq, lCadOrig, .F.},;
					{'Ejerc="#cVal#"',  nAnoFis, lReq, lCadOrig, .F.}}
				
					cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'retenciones:Periodo')
			
			/* Totales Retenidos */
			nTotOper   := 0 
			nTotGrav   := 0 
			nTotExent  := 0
			nTotRet    := 0 
		
			For nK := 1 To Len(aDetPag[nJ, 5])
				If Alltrim(aDetPag[nJ, 5, nK, 8]) $ "NF|NDP"
					nTotOper += aDetPag[nJ, 5, nK, 9] 							// Total Operacion
				ElseIf Alltrim(aDetPag[nJ, 5, nK, 8]) $ "NCP|NDI"
					nTotOper -= aDetPag[nJ, 5, nK, 9] 							// Total Operacion
				EndIf
				
				For nL := 1 To Len(aDetPag[nJ,5,nK,11])
					If Alltrim(aDetPag[nJ,5,nK,11,nL,1]) == "EXENTO"
						nTotExent += aDetPag[nJ, 5, nK, 5]						// Total Exento
					ElseIf Alltrim(aDetPag[nJ,5,nK,11,nL,1]) $ (cRetISR)		// Retencion de ISR
						nPos := Ascan(aTImpSat,{|x| Alltrim(x[3]) $ "01"})
						If nPos == 0
							If aDetPag[nJ,5,nK,11,nL,6] != 0
								aAdd(aTImpSat, {aDetPag[nJ,5,nK,11,nL,5], aDetPag[nJ,5,nK,11,nL,6], "01"})
							EndIf
						Else
							aTImpSat[nPos,1] += aDetPag[nJ,5,nK,11,nL,5]		// Base Retencion
							aTImpSat[nPos,2] += aDetPag[nJ,5,nK,11,nL,6]		// Monto Retenido
						EndIf
						nTotRet += aDetPag[nJ,5,nK,11,nL,6]					// Total Retenido
					ElseIf Alltrim(aDetPag[nJ,5,nK,11,nL,1]) $ (cRetIVA)		// Retencion de IVA
						nPos := Ascan(aTImpSat,{|x| Alltrim(x[3]) $ "02"})
						If nPos == 0
							If aDetPag[nJ,5,nK,11,nL,6] != 0
								aAdd(aTImpSat, {aDetPag[nJ,5,nK,11,nL,5], aDetPag[nJ,5,nK,11,nL,6], "02"})
							EndIf
						Else
							aTImpSat[nPos,1] += aDetPag[nJ,5,nK,11,nL,5]		// Base Retencion
							aTImpSat[nPos,2] += aDetPag[nJ,5,nK,11,nL,6]		// Monto Retenido
						EndIf
						nTotRet += aDetPag[nJ,5,nK,11,nL,6]					// Total Retenido
					ElseIf Alltrim(aDetPag[nJ,5,nK,11,nL,1]) $ (cRetIEPS)	// Retencion de IEPS
						nPos := Ascan(aTImpSat,{|x| Alltrim(x[3]) $ "03"})
						If nPos == 0
							If aDetPag[nJ,5,nK,11,nL,6] != 0
								aAdd(aTImpSat, {aDetPag[nJ,5,nK,11,nL,5], aDetPag[nJ,5,nK,11,nL,6], "03"})
							EndIf
						Else
							aTImpSat[nPos,1] += aDetPag[nJ,5,nK,11,nL,5]		// Base Retencion
							aTImpSat[nPos,2] += aDetPag[nJ,5,nK,11,nL,6]		// Monto Retenido
						EndIf
						nTotRet += aDetPag[nJ,5,nK,11,nL,6]					// Total Retenido
					EndIf
				Next nL
				If Alltrim(aDetPag[nJ, 5, nK, 8]) $ "NF|NDP"
					nTotGrav += aDetPag[nJ, 5, nK, 4] * aDetPag[nJ, 5, nK, 13] // Total Gravado
				ElseIf Alltrim(aDetPag[nJ, 5, nK, 8]) $ "NCP|NDI"
					nTotGrav -= aDetPag[nJ, 5, nK, 4] * aDetPag[nJ, 5, nK, 13] // Total Gravado
				EndIf
				
			Next nK
			nTotGrav -= nTotExent
			
			// Elemento: Totales 
			aAuxNodo := {{'montoTotOperacion="#cVal#"', nTotOper, lReq, lCadOrig, .F.},;
				{'montoTotGrav="#cVal#"',     nTotGrav, lReq, lCadOrig, .F.},;
				{'montoTotExent="#cVal#"',    nTotExent, lReq, lCadOrig, .F.},;
				{'montoTotRet="#cVal#"',      nTotRet, lReq, lCadOrig, .F.}}
				
				cAuxXml += ObtNodo(aAuxNodo, cNodoSup, 'retenciones:Totales')
			
			For nPos := 1 To Len(aTImpSat)
				// Elemento: ImpRetenidos 
				aAuxNodo := {{'BaseRet="#cVal#"',          aTImpSat[nPos,1], lOpc, lCadOrig, .F.},;
					{'Impuesto="#cVal#"',        aTImpSat[nPos,3], lOpc, lCadOrig, .F.},;
					{'montoRet="#cVal#"',        aTImpSat[nPos,2], lReq, lCadOrig, .F.},;
					{'TipoPagoRet="#cVal#"',     IIf(nTipPago == 1, cPagProv, cPagDef), lReq, lCadOrig, lCodHTML}}
					
					cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'retenciones:ImpRetenidos')
			Next nPos
			
			cAuxXml += Strtran(cFinNodo, '#cNomNodo#', 'retenciones:Totales')
			
			// Elemento: Complemento
			cAuxXml += Strtran(cIniNodo, '#cNomNodo#', 'retenciones:Complemento')
			
			If Alltrim(aDetPag[nJ, 14]) == "EX"
			
				// Elemento: Pagosaextranjeros 
				aAuxNodo := {{'Version="#cVal#"', nVersion, lReq, lCadOrig, .F.},;
					{'EsBenefEfectDelCobro="#cVal#"', IIf(Alltrim(aDetPag[nJ, 13]) == "S", "SI", "NO"), lReq, lCadOrig, lCodHTML}}
				
					cAuxXml += ObtNodo(aAuxNodo, cNodoSup, 'pagosaextranjeros:Pagosaextranjeros')
					
				If Alltrim(aDetPag[nJ, 13]) != "S"
					// Elemento: NoBeneficiario 
					aAuxNodo := {{'PaisDeResidParaEfecFisc="#cVal#"', aDetPag[nJ, 18], lReq, lCadOrig, lCodHTML},;
						{'ConceptoPago="#cVal#"',           aDetPag[nJ, 12], lReq, lCadOrig, lCodHTML},;
						{'DescripcionConcepto="#cVal#"',    Alltrim(cDesConc), lReq, lCadOrig, lCodHTML}}
						
						cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'pagosaextranjeros:NoBeneficiario')
				Else
					// Elemento: Beneficiario 
					aAuxNodo := {{'RFC="#cVal#"',        aDetPag[nJ, 10], lReq, lCadOrig, lCodHTML},;
						{'CURP="#cVal#"',                aDetPag[nJ, 11], lReq, lCadOrig, lCodHTML},;
						{'NomDenRazSocB="#cVal#"',       aDetPag[nJ, 15], lReq, lCadOrig, lCodHTML},;
						{'ConceptoPago="#cVal#"',        aDetPag[nJ, 12], lReq, lCadOrig, lCodHTML},;
						{'DescripcionConcepto="#cVal#"', Alltrim(cDesConc), lReq, lCadOrig, lCodHTML}}
						
						cAuxXml += ObtNodo(aAuxNodo, cNodoInf, 'pagosaextranjeros:Beneficiario')
				EndIf
				
				cAuxXml += Strtran(cFinNodo, '#cNomNodo#', 'pagosaextranjeros:Pagosaextranjeros')		
			EndIf
			
			cAuxXml += Strtran(cFinNodo, '#cNomNodo#', 'retenciones:Complemento')
			cAuxXml += Strtran(cFinNodo, '#cNomNodo#', 'retenciones:Retenciones')
	Next nJ
	
	cCadOrig += "|"
	cSello := F925SeCade(cCadOrig) 
	
	cAuxXml := Replace(cAuxXml, '#cSello#', cSello)
Return cAuxXml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ObtNodo   ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Forma estructura del nodo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtNodo(aAuxNodo, cTipoNodo, cNomNodo)
	Local cAuxNodo   := "" 

	cAuxNodo := AddXML(aAuxNodo)
	cAuxNodo := Strtran(cTipoNodo, '#cValNodo#', cAuxNodo)
	cAuxNodo := Strtran(cAuxNodo, '#cNomNodo#', cNomNodo)
Return cAuxNodo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ObtPaisSat³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Obtiene el Pais SAT                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtPaisSat(cPais)
	Local cPaisSat   := ""
	
	If SYA->(MsSeek(cFilSYA + SA2->A2_PAIS))
		cPaisSat := Alltrim(SYA->YA_CVESAT)
	EndIf
Return cPaisSat

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³fVendor   ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Retenciones e Informacion de Pagos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetVendor(cBuffer)
	Local aDatos	:= {}
	Local nloop := 0
	Local nTamV := TamSX3("A2_COD")[1]
	Local nTamL := TamSX3("A2_LOJA")[1]
    
	cBuffer := Alltrim(cBuffer)
	
	If !Empty(cBuffer)
		If subStr(cBuffer,len(cBuffer),1) != ";"
			cBuffer += ";"
		EndIf
			
		For nloop=1 to len(cBuffer)
			cCadena := substr(cBuffer,1,at(";",cBuffer)-1)
			cBuffer := substr(cBuffer,at(";",cBuffer)+1,len(cBuffer)-at(";",cBuffer))
			
			aAdd(aDatos, { substr(cCadena, 1, nTamV), substr(cCadena, (at("-",cCadena) + 1), nTamL) })
			
			If  Len(cBuffer) == 0
				Exit
			EndIf
		Next nloop
	EndIf
Return aDatos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³fVendor   ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Retenciones e Informacion de Pagos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fVendor(l1Elem, lTipoRet, aElem)
	Local cTitulo	:= OemToAnsi(STR0003) //"Selección de proveedores"
	Local nFor		:= 0
	Local MvPar
	Local MvParDef	:=""
	Local MvRetor	:= ""
	Local nX3Tam	:= 0
	
	Private aSit:={}
	
	l1Elem := If (l1Elem = Nil , .F. , .T.)
	
	Default lTipoRet 	:= .T. 
	Default aElem		:= {}

	cAlias := Alias()		// Salva Alias Anterior
	
	IF lTipoRet
		MvPar:=&(Alltrim(ReadVar()))	// Carrega Nome da Variavel do Get em Questao
		mvRet:=Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
	EndIf
	
	dbSelectArea("SA2")
	If MsSeek(cFilial)
		CursorWait()
		While !Eof() .And. SA2->A2_FILIAL == cFilial
			Aadd(aSit, Alltrim(SA2->A2_NOME))		//SA2->A2_COD + " - " + SA2->A2_LOJA
			MvParDef += SA2->A2_COD + "-" + SA2->A2_LOJA
			dbSkip()
		Enddo  
		CursorArrow()
	EndIf
	
	IF lTipoRet         
		nX3Tam := (GetSx3Cache("A2_COD","X3_TAMANHO") + GetSx3Cache("A2_LOJA","X3_TAMANHO")) + 1
		IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,,,l1Elem, nX3Tam)		// Chama funcao f_Opcoes
			CursorWait()
			For nFor := 1 To Len( mVpar ) Step nX3Tam
				IF ( SubStr( mVpar , nFor , nX3Tam ) # "***" )
					mvRetor += SubStr( mVpar , nFor , nX3Tam ) + ";"
				EndIf
			Next nFor
		   	If( Empty(mvRetor) )
				mvRetor := Space(99)
			EndIf                       
			&MvRet 	:= mvRetor
			CursorArrow()	
		EndIf	
	EndIf
	
	dbSelectArea(cAlias)		// Retorna Alias
Return( IF( lTipoRet , .T. , MvParDef ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ValidMes  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Validad mes inicial y mes final                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ValidMes(nValMes)
	Local lOk := .F.

	If nValMes >= 1 .And. nValMes <= 12 
		lOk := .T.	
	EndIf
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ValidAnio ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Valida anio del ejercicio fiscal                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ValidAnio(nValAnio)
	Local lOk        := .F.  

	If nValAnio >= 2004 .And. nValAnio <= 2024
		lOk := .T.	
	EndIf
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ObtDirXML ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Obtener directorio para archivos XML y PDF                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ObtDirXML()
	Local lOk := .F.
	Local cRuta := ""

	cRuta := cGetFile( '|(*.*)|' , 'Seleccione Diretório', 0 , "C:\", .F., GETF_LocalHARD + GETF_LocalFLOPPY + GETF_RETDIRECTORY  )
	
	If !Empty(cRuta)
		MV_PAR06 := cRuta
		lOk := .T.
	EndIf
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ParamOK   ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Valida los parametros                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ParamOK()
	Local lOK := .T.

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03) .Or. Empty(MV_PAR04) .Or. Empty(MV_PAR05) .Or. Empty(MV_PAR06) .Or.;
		Empty(MV_PAR07) .Or. Empty(MV_PAR08) .Or. Empty(MV_PAR09) .Or. Empty(MV_PAR10) 
			Aviso( OemToAnsi(STR0015), OemToAnsi(STR0017), {STR0016} ) //"Atención" # "Existen parámetros sin informar" # "Aceptar"
			lOK := .F.
	EndIf
Return lOK

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³VldCveRet ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Valida la clave de retencion                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldCveRet()
	Local cTRetSat := Alltrim(M->FB_TRETSAT)
	Local cDestRet := Alltrim(M->FB_DESTRET)
	Local lOK := .T.

	If cTRetSat == "25" .And. Empty(cDestRet)
		Aviso( OemToAnsi(STR0015), OemToAnsi(STR0018), {STR0016} ) //"Atención" # "Debe informar la descripción del tipo de retención" # "Aceptar"
		lOK := .F.	
	EndIf
Return lOK

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³AddXML      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Procesa atributos para formar nodo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddXML(aDatos)
	Local cCadena := ""
	Local nLoop   := 0

/*------------------------------------------
|	1.- Nombre Atributo                     |
|	2.- Valor                               |
|	3.- Requerido/Opcional (.T. / .F.)      |
|	4.- Forma Cadena original (.T. / .F.)   |
|	5.- Usa CodHTML()                       |
-------------------------------------------*/

  	For nLoop := 1 To Len(aDatos)
  		If Len(aDatos[nLoop]) > 0
	  		cCadena += AddNodo(aDatos[nLoop][1], aDatos[nLoop][2], aDatos[nLoop][3], aDatos[nLoop][4], aDatos[nLoop][5], '#cVal#' )
	  	EndIf	
  	Next nLoop
Return cCadena

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³AddNodo     ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Formatea atributos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddNodo(cNomAtrib, xValAtrib, lUso, lCadOr, lCodHTML, cValRep)
	Local cAtributo := ""
	Local cAuxAtrib := Replace(cNomAtrib, '="#cVal#"', '')
	
	// Procesa valores tipo numerico
	If Valtype(xValAtrib) == "N"
		If cAuxAtrib $ 'Version'
			cAtributo := Transform(xValAtrib, cPictVer)
		ElseIf cAuxAtrib $ 'montoTotOperacion|montoTotGrav|montoTotExent|montoTotRet|BaseRet|montoRet'
			If !Empty(xValAtrib)
				cAtributo := Transform(xValAtrib, cPictNum)
			Else
				cAtributo := Transform(0, cPictNum)
			EndIf
		ElseIf cAuxAtrib $ 'MesIni|MesFin|Ejerc|ConceptoPago'
			If !Empty(xValAtrib)
				cAtributo := Transform(xValAtrib, cPictInt)
			ElseIf Empty(xValAtrib) .And. lUso
				aAdd(aLogErr, {/*ORD Pago; Proveedor; Tienda; Atributo; Valor*/})
			EndIf
		EndIf
		
		IIf(lCadOr, cCadOrig += (CodHTML(cAtributo) + "|"), "") // Forma Cadena Original
		cAtributo := Strtran(cNomAtrib, cValRep, AllTrim(cAtributo)) + Space(1)
	
	// Procesa valores tipo caracter	
	ElseIf Valtype(xValAtrib) == "C"
		If !Empty(xValAtrib)
			IIf(lCadOr, cCadOrig += (CodHTML(xValAtrib) + "|"), "") // Forma Cadena Original
			cAtributo := Strtran(cNomAtrib, cValRep, CodHTML(xValAtrib, lCodHTML)) + Space(1)
		ElseIf Empty(xValAtrib) .And. lUso
			aAdd(aLogErr, {/*ORD Pago; Proveedor; Tienda; Atributo; Valor*/})
		EndIf
	EndIf	
Return cAtributo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³CodHTML     ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Caracteres HTML                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function CodHTML(cTexto, lCodHtml)
	Local cRet   := ""                    
	Local nChar	 :=	0
	
	Default lCodHtml := .F.

	If !Empty(cTexto)
		For nChar := 1 to Len(cTexto)     
			If nChar<Len(cTexto)
				If Substr(cTexto,nChar,1)==" " .and. Substr(cTexto,nChar,1)==Substr(cTexto,nChar+1,1)
					Loop
				Else
					cRet:=cRet+Substr(cTexto,nChar,1)
				EndIf
			Else
				cRet:=cRet+Substr(cTexto,nChar,1)	      
			EndIf
		Next nChar
		cRet := Alltrim(cRet)
	EndIf
	
	If lCodHtml
		cRet := Replace(cRet, '&', '&amp;')
		cRet := Replace(cRet, "‘", '&apos;')
		cRet := Replace(cRet, '"', '&quot;')
		cRet := Replace(cRet, '<', '&lt;')
		cRet := Replace(cRet, '>', '&gt;')
	EndIf	
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³LeeCert     ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Lee archivo de certificado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LeeCert()
	Local cBuffer	:= ""
	Local nHandle   := 0
	Local cLinea    := ""
	Local cFile     := &(SuperGetMv("MV_CFDDIRS",,""))+SuperGetMv("MV_CFDI_CP",,"")

	nHandle := FT_FUse(cFile)
	// Se hay error al abrir el archivo
	If  nHandle = -1
		MsgAlert(STR0019 + cFile) //"No se encontró el archivo de certificado"
	return ""
	EndIf
	// Se posiciona en la primera línea
	FT_FGoTop()
	
	While !FT_FEOF()
		cLinea := FT_FReadLn() // lee cada línea del archivo
		If Alltrim(cLinea) <> "-----BEGIN CERTIFICATE-----" .And. Alltrim(cLinea) <> "-----END CERTIFICATE-----"
			cBuffer += Alltrim(cLinea)
		EndIf
		FT_FSKIP() // Salta a siguiente línea
	End
	
	// Fecha o Arquivo
	FT_FUSE()
Return cBuffer

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³F925SeCade ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Crea sello con la cadena original                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F925SeCade(cCadena)
	Local cSello := ""

	cSello := LjHex2Asc(SHA1(cCadena,2))
	cSello := PrivSignRSA(&(SuperGetMv("MV_CFDDIRS",,""))+SuperGetMv("MV_CFDI_KP",,""),cSello,2,"assinatura")
	cSello := ENCODE64(cSello)	
Return cSello

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³CreaArch    ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Crea archivo                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CreaArch(cNomArch, cExt)
	Local nHdle     := 0
	Local cDrive    := ""
	Local cNewFile  := cDir + cNomArch

	SplitPath(cNewFile,@cDrive,@cDir,@cNomArch,@cExt)
	cDir := cDrive + cDir
	Makedir(cDir)
	cNomArc := cDir + cNomArch + cExt   

	nHdle := FCreate (cNomArc,0)
	If nHdle == -1
		Aviso( OemToAnsi(STR0003), OemToAnsi(STR0011 + cNomArc), {STR0005} ) //"Selección de proveedores" # "Total reducido" # "Por favor espere. "
	EndIf
Return nHdle

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³GrabaTexto  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Graba datos en archivo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrabaTexto(cArcXml, nHdle, lClose, lEncode)
	Default cArcXml := ""
	Default lClose := .F.
	Default lEncode := .F.
   
    If lEncode
		cArcXml := ENCODEUTF8(cArcXml)
	EndIf
	FWrite(nHdle, cArcXml)
	If lClose
		FClose (nHdle)
	EndIf
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³fEnvMail    ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Envia e-mail                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fEnvMail(aXML)
	Local cAccount    := GetMV("MV_RELACNT",,"" )
	Local cPassword   := GetMV("MV_RELPSW",,""  )
	Local cServer     := GetMV("MV_RELSERV",,"" )        
	Local lUseSSL     := GetMv("MV_RELSSL")	
	Local lAuth       := GetMv("MV_RELAUTH")	
	Local nPort       := GetMv("MV_SRVPORT",,25)
	Local oMailServer := Nil
	Local oMessage    := Nil
	Local cFrom       := cAccount    
	Local cAttach     := ""
	Local cEmailBcc   := ""
	Local cError      := "" 
	Local cEmailTo    := ""
	Local cArchivo    := ""
	Local lresult     := .F.
	Local nX          := 0
	Local nI          := 0
	Local nPos        := 0
	Local cEMailAst   := STR0024 //"Retención e información de pagos"
	Local cSrvDir     := Curdir()
	Local _aAnexo := {}
	
	// Valida si existe Cuenta de Correo
	If 	Empty(cAccount)
		Help(" ",1,"SEMCONTA")
		Return(.F.)
	EndIf

	// Valida si existe contraseña de la cuenta de correo
	If 	Empty(cPassword)
		Help(" ",1,"SEMSENHA")
		Return(.F.)
	EndIf
	
	// Valida si existe servidor SMTP
	If 	Empty(cServer)
		Help(" ",1,"SEMSMTP")
		Return(.F.)
	EndIf
	
	// Valida que exista puerto
	If Empty(nPort)
		nPort := 25
	EndIf
	
	For nPos := 1 To Len(aXML)	
		lresult := .F.
		If aXML[nPos, 7]  .Or. !lEnvTimb
			cEmailTo := aXML[nPos, 2] 
			If !Empty(cEmailTo)
				cArchivo := Replace(aXML[nPos, 1], ".xml", "")
				
				aAdd(_aAnexo, cDir + cArchivo + ".xml")
				aAdd(_aAnexo, cDir + cArchivo + ".pdf")
			
				If !lAuth 
					
					For nI:= 1 to Len(_aAnexo)
						cAttach += _aAnexo[nI] + "; "
					Next nI
					
					CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
					
					If lResult
						SEND MAIL FROM cFrom ;
						TO      	cEmailTo;
						BCC     	cEmailBcc;
						SUBJECT 	cEMailAst;
						BODY    	cEMailAst;
						ATTACHMENT  cAttach  ;
						RESULT lResult
						
						If !lResult
							GET MAIL ERROR cError
							Help(" ",1,STR0020,,cError,4,5)	//"Atención"
						EndIf
						
						DISCONNECT SMTP SERVER						
					Else
						//Erro na conexao com o SMTP Server
						GET MAIL ERROR cError
						
						Help(" ",1,STR0020,,cError,4,5)	//"Atención"					
					EndIf
					DISCONNECT SMTP SERVER
				Else
						//Instancia o objeto do MailServer
						oMailServer:= TMailManager():New()
						oMailServer:SetUseSSL(lUseSSL)
						oMailServer:SetUseTLS(.T.) 	
						oMailServer:Init("pop.totvs.com.br",cServer,cAccount,cPassword,0,nPort)
						
							//Definição do timeout do servidor
					   	If oMailServer:SetSmtpTimeOut(120) != 0
					   		Help(" ",1,STR0020,,STR0021 ,4,5) //"Atención" # "No fue posible establecer el tiempo de espera del servidor de envío"
					        Return .F.
					    EndIf
				
					    //Conexão com servidor
					    nErr := oMailServer:smtpConnect()
						If nErr <> 0
							Help(" ",1,STR0020,,oMailServer:getErrorString(nErr),4,5) //"Atención"
							oMailServer:smtpDisconnect()
							Return .F.
						EndIf
						
						//Autenticação com servidor smtp
						nErr := oMailServer:smtpAuth(cAccount, cPassword)
						If nErr <> 0
							Help(" ",1,STR0020,,STR0022 + oMailServer:getErrorString(nErr),4,5) //"Atención" # "[Error] Falla al autenticar: "
							oMailServer:smtpDisconnect()
							return .F.
						EndIf
						
						//Cria objeto da mensagem+
						oMessage := tMailMessage():new()
						oMessage:clear()
						oMessage:cFrom := cFrom 
						oMessage:cTo := cEmailTo 
						oMessage:cCc := cEmailBcc
						oMessage:cSubject :=  cEMailAst
					
						oMessage:cBody := cEMailAst
						
						For nX := 1 to Len(_aAnexo)
							oMessage:AddAttHTag("Content-ID: <" + _aAnexo[nX] + ">")
							oMessage:AttachFile(_aAnexo[nX])
						Next nX
						
						//Dispara o email	
						nErr := oMessage:send(oMailServer)
						If nErr <> 0
							Help(" ",1,STR0020,,STR0023 + oMailServer:getErrorString(nErr),4,5) //"Atención" # "[Error] Falla al enviar: "
							oMailServer:smtpDisconnect()
							Return .F.
						Else
							lResult := .T.
						EndIf
						
						//Desconecta do servidor
						oMailServer:smtpDisconnect()			
				EndIf
				If lResult
					aXML[nPos, 8] := .T.
				EndIf
				IIf( File( cSrvDir + cArchivo + ".xml"), FErase( cSrvDir + cArchivo + ".xml"), "" )
				IIf( File( cSrvDir + cArchivo + ".pdf"), FErase( cSrvDir + cArchivo + ".pdf"), "" )
			EndIf
		EndIf
	Next nPos
Return(lResult)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³fUpdRetPag  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Actualiza tabla SEK                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fUpdRetPag(aOrdPag, cXml)
	Local nI := 0	
	Local nJ := 0 

	For nI := 1 To Len(aOrdPag)
		For nJ := 1 To Len(aOrdPag[nI])
			SEK->(dbGoTo(aOrdPag[nI,nJ,2]))
			If Alltrim(aOrdPag[nI,nJ,1]) == Alltrim(SEK->EK_ORDPAGO)
				RecLock("SEK",.F.)
					SEK->EK_XMLRET  := cXml
				    SEK->EK_UUID    := cUUID	
				    SEK->EK_FECTIMB := STOD(cFechaTim)
				MsUnLock()
			EndIf
		Next
	Next nI
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³CFDiRecNom³ Autor ³ Raul Ortiz Medina    ³ Fecha³ 12/06/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Timbrado de CFDi con complemento de recibo de nómina      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ CFDiRecNom( aRecibos )                                    ³±±
±±³           ³ aRecibos - Lista de archivos a procesar                   ³±±
±±³           ³ [x,1] - Nombre del archivo xml                            ³±±
±±³           ³ [x,2] - Regresa UUID o mensaje de error (*)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ TimbreRecNom                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CFDiRecRet( aRecibos )
	Local cRutaSmr := &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))	// Ruta Local en donde se procesarán los archivos
	Local cCFDiUsr := SuperGetmv( "MV_CFDI_US" , .F. , "" )						// Usuario del servicio web
	Local cCFDiCon := SuperGetmv( "MV_CFDI_CO" , .F. , "" )						// Contraseña del servicio web
	Local cCFDiPAC := SuperGetmv( "MV_CFDI_PA" , .F. , "" )						// Rutina a ejecutar (PAC)
	Local cCFDiAmb := SuperGetmv( "MV_CFDI_AM" , .F. , "T" )					// Ambiente (Teste o Produccion)
	Local cCFDiPub := SuperGetmv( "MV_CFDI_CE" , .F. , "" )						// Archivo de llave pública (.cer)
	Local cCFDiPri := SuperGetmv( "MV_CFDI_PR" , .F. , "" )						// Archivo de llave privada (.key)
	Local cCFDiCve := SuperGetmv( "MV_CFDI_CL" , .F. , "" )						// Clave de llave privada para autenticar WS
	Local nCFDiCmd := SuperGetmv( "MV_CFDICMD" , .F. , 0 )						// Mostrar ventana de comando del Shell: 0=no, 1=si
	Local lProxySr := SuperGetmv( "MV_PROXYSR" , .F. , .F. )					// Emplear Proxy Server?
	Local cProxyIP := SuperGetmv( "MV_PROXYIP" , .F. , "" )						// IP del Proxy Server
	Local nProxyPt := SuperGetmv( "MV_PROXYPT" , .F. , 0 )						// Puerto del Proxy Server
	Local lProxyAW := SuperGetmv( "MV_PROXYAW" , .F. , .F. )					// Autenticación en Proxy Server con credenciales de Windows?
	Local cProxyUr := SuperGetmv( "MV_PROXYUR" , .F. , "" )						// Usuario para autenticar Proxy Server
	Local cProxyPw := SuperGetmv( "MV_PROXYPW" , .F. , "" )						// Clave para autenticar Proxy Server
	Local cProxyDm := SuperGetmv( "MV_PROXYDM" , .F. , "" )						// Dominio para autenticar Proxy Server
	Local cNameCFDI:= ""
	Local cRutina  := "Timbrado" + Trim(cCFDiPAC) + ".exe "
	Local cParametros := ""
	Local cProxy   := "[PROXY]"
	Local cIniFile := "TimbradoCFDi.ini" //"TimbradoCFDi.ini"
	Local cBatch   := "Timbrado.bat" //"Timbrado.bat"
	Local nHandle  := 0
	Local nLoop    := 0
	Local nOpc     := 0
	Local lRet     := .F.
	Local cRutaCFDI:= cRutaSmr + "Recibos\"
	
	Private cError   := ""  //Contiene el numero de error
	Private cDetalle := ""  //Contiene el detalle del error, cuando el timbre no es generado
	Private cUUID 		:= ""
	Private cFechaTim 	:= ""

	If Empty(cRutaSmr) .Or. Empty(cCFDiUsr) .Or. Empty(cCFDiCon) .Or. Empty(cCFDiPAC)
		Aviso( STR0025 , STR0026, {STR0027} ) //"CFDi - Complemento retenciones" # "Faltan parámetros por definir para este proceso" # "OK"
		Return lRet
	EndIf

	// Valida ruta de alojamiento del ejecutable de timbrado
	If !( cRutaSmr == Strtran( cRutaSmr , " " ) )
		Aviso( STR0025 , STR0028, {STR0027}) //"CFDi - Complemento retenciones" # "La dirección del ejecutable de timbrado no es válida" # "OK"
		Return lRet
	EndIf

	// Verifica la existencia del EXE de WS para timbrado
	If !File( cRutaSmr + Trim(cRutina) )
		Aviso( STR0025 , STR0029 + cRutaSmr + cRutina , {STR0027} ) //"CFDi - Complemento retenciones" # "No existe el cliente de servicio web: " # "OK"
		Return lRet
	EndIf

	// Parámetros para el Proxy Server
	cProxy += "[" + If( lProxySr , "1" , "0" ) + "]"
	cProxy += "[" + Alltrim(cProxyIP) + "]"
	cProxy += "[" + lTrim( Str( nProxyPt ) ) + "]"
	cProxy += "[" + If( lProxyAW , "1" , "0" ) + "]"
	cProxy += "[" + If( lProxyAW , "" , Alltrim(cProxyUr) ) + "]"
	cProxy += "[" + If( lProxyAW , "" , Alltrim(cProxyPw) ) + "]"
	cProxy += "[" + If( lProxyAW , "" , Alltrim(cProxyDm) ) + "]"

	// Parametros obligatorios: (1)Usuario, (2)Password, (3)Factura.xml, (4)Ambiente,
	cParametros := cCFDiUsr + " " + cCFDiCon + " " + cIniFile + " " +cCFDiAmb +  " " 
	// otros parametros segun el PAC: (5)Archivo.cer, (6)Archivo.key, (7)ClaveAutenticacion, (8)., (9)Timbrar/Cancelar, (10)Parametros del Proxy
	cParametros += cCFDiPub + " " + cCFDiPri + " " + cCFDiCve + " . T " + cProxy

	// Visualización de ventana de comando
	If nCFDiCmd < 0 .Or. nCFDiCmd > 10
		nCFDiCmd := 0
	EndIf

	// Archivo .ini con la lista de CFDi a timbrar
	nHandle	:= FCreate( cRutaSmr + cIniFile )

	If nHandle == -1
		Aviso( STR0025 , STR0030 + cRutaSmr, {STR0027} ) //"CFDi - Complemento retenciones" # "No es posible crear archivo temporal en la dirección" # "OK"
		Return lRet
	EndIf

	FWrite( nHandle, "[RECIBOS]" + CRLF )

	// Copiar archivos .xml del servidor a la ruta del smartclient o la establecida (StartPath...\CFD\RECIBOS\xxx...xxx.XML a x:\totvs\protheusroot\bin\smartclient)
	MakeDir( cRutaCFDI )

	For nLoop := 1 to Len( aRecibos )
		cNameCFDI := aRecibos[nLoop , 1 ]

		If File( cRutaCFDI + cNameCFDI )
			FErase( cRutaCFDI + cNameCFDI )
		EndIf

		If File( cRutaCFDI + cNameCFDI + ".out" )
			FErase( cRutaCFDI + cNameCFDI )
		EndIf

		__CopyFile( cDir + cNameCFDI , cRutaCFDI + cNameCFDI )

		FWrite( nHandle, cNameCFDI + CRLF )
	Next nLoop

	fClose( nHandle )

	If nCFDiCmd == 3 .Or. nCFDiCmd == 10
		nHandle	:= FCreate( cRutaSmr + cBatch )
		If nHandle == -1
			Aviso( STR0025 , STR0031 + cRutaSmr, {STR0027} ) //"CFDi - Complemento retenciones" # "No es posible crear archivo de comandos en la dirección" # "OK"
			Return lRet
		EndIf

		FWrite( nHandle, cRutaSmr + cRutina + Trim(cParametros) + CRLF )
		FWrite( nHandle, "Pause" + CRLF )
		fClose( nHandle )

		nOpc := WAITRUN( cRutaSmr + cBatch, nCFDiCmd )

	Else
		// Ejecuta cliente de servicio web
		nOpc := WAITRUN( cRutaSmr + cRutina + Trim(cParametros), nCFDiCmd)	// SW_HIDE
	EndIf

	ProcRegua(Len(aRecibos))
	
	For nLoop := 1 to Len( aRecibos )
		cNameCFDI := aRecibos[nLoop , 1 ]
		If nOpc > 0 .Or. !File( cRutaCFDI + cNameCFDI + ".out" )
			Conout( ProcName(0) + ": " + STR0032 + cNameCFDI ) //"No se obtuvo respuesta para el comprobante"
			aRecibos[ nLoop , 3 ] := "*" + STR0032 //"No se obtuvo respuesta para el comprobante"
		Else
			//  Copia respuesta del WS a la carpeta original
			__CopyFile( cRutaCFDI + cNameCFDI + ".out" , cDir + cNameCFDI + ".out" )

			//Validar si se genero el timbre y si es asi se debe actualizar el campo F2_TIMBRE
			If  LeeXMLOut( cDir, cRutaCFDI, cNameCFDI, @cError, @cDetalle )
				IncProc(STR0126 + Alltrim(Str(nLoop)) + "/" + Alltrim(Str(Len(aRecibos)))) //"Actualizando orden de pago con el timbre fiscal "
				fUpdRetPag(aRecibos[nLoop][4],aRecibos[nLoop][1] )
				// Nuevo CFDi en el Remote
				Ferase( cRutaCFDI + cNameCFDI )
				Frename( cRutaCFDI + cNameCFDI + ".timbre" , cRutaCFDI + cNameCFDI )
				__CopyFile( cRutaCFDI + cNameCFDI , cDir + cNameCFDI )
				
				Ferase( cDir + cNameCFDI + ".out" )
				// Flag de proceso correcto
				aRecibos[ nLoop , 3 ] := STR0127  + "" + cDir + cNameCFDI //"CFDI de Retenciones timbrado con éxito, Ruta del XML: "
				aRecibos[ nLoop , 7 ] := .T.
				lRet := .T.
			Else
				Conout( ProcName(0) + ": " + STR0033 + cNameCFDI + CRLF + cError + If( Empty(cDetalle), "", " - " ) + cDetalle )  //"No fue posible recuperar la firma del comprobante"
				aRecibos[ nLoop , 3 ] := "*" + If( !Empty(cError), cError + If( Empty(cDetalle), "", " - " ) + cDetalle, STR0033) //"No fue posible recuperar la firma del comprobante"
				aRecibos[ nLoop , 7 ] := .F.
			EndIf
		EndIf

		// Eliminar temporales
		Ferase( cRutaCFDI + cNameCFDI )
		Ferase( cRutaCFDI + cNameCFDI + ".out" )
	Next nLoop

	GrabaLog( cRutaSmr + "Errores\", aRecibos )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ LeeXMLOut³ Autor ³ Raul Ortiz Medina    ³ Data ³ 18/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Valida si el archivo .OUT obtenido del WS contiene TFD    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ LeeXMLOut( ruta , archivo , @error , @detalle )           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ CFDiRecNom                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LeeXMLOut(cRutaSrv, cRuta, cNombre, cError, cDetalle)
	Local oXML     := Nil
	Local cXML     := ""
	Local cArchiOUT:= cRutaSrv + cNombre + ".out"   
	Local cTimbre  := ""
	Local lRet     := .F.
	
	cUUID 		:= ""
	cFechaTim 	:= ""

	If Substr(cArchiOUT,1,1) == IIf( IsSrvUnix() , "/" , "\" )
		cArchiOUT := Substr(cArchiOUT,2)
	EndIf
	
	oXml := XmlParserFile(cArchiOUT, "", @cError, @cDetalle )
	
	If valType(oXml) == "O"	
		SAVE oXml XMLSTRING cXML
	
		If AT( "ERROR" , Upper(cXML) ) > 0 .And. AT ("UUID=" , Upper(cXML)) = 0	// El archivo tiene errores
			If AT( "CFDI:ERROR" , Upper(cXML) ) > 0
				If 	ValType(oXml:_CFDI_ERROR) == "O"
					cError := oXml:_CFDI_ERROR:_CODIGO:TEXT
					cDetalle := oXml:_CFDI_ERROR:_CFDI_DESCRIPCIONERROR:TEXT
				EndIf
			ElseIf AT( "<ERROR" , Upper(cXML) ) > 0
				If 	ValType(oXml:_ERROR) == "O"
					cError := oXml:_ERROR:_CODIGO:TEXT
					cDetalle := oXml:_ERROR:_DESCRIPCIONERROR:TEXT
				EndIf
		    EndIf
			If Empty(cError)
				cError := cXML
			EndIf
		Else
			If At( "RETENCIONES:RETENCIONES" , Upper(cXml) ) > 0
				If At( "TFD:TIMBREFISCALDIGITAL " , Upper(cXml) ) > 0
					cTimbre 	:= oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
					cUUID 		:= oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
			 		cFechaTim 	:= REPLACE(SUBSTR(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT,1,10),"-","")
				ElseIf At( "TIMBREFISCALDIGITAL:TIMBREFISCALDIGITAL " , Upper(cXml) ) > 0
					cTimbre := oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TIMBREFISCALDIGITAL_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
					cUUID 		:= oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TIMBREFISCALDIGITAL_TIMBREFISCALDIGITAL:_UUID:TEXT
			 		cFechaTim 	:= REPLACE(SUBSTR(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TIMBREFISCALDIGITAL_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT,1,10),"-","")
				EndIf
				If !Empty( cTimbre )
					lRet := AddTimbre2(cRuta, cNombre, cXML)
				EndIf
			ElseIf At( "TFD:TIMBREFISCALDIGITAL " , Upper(cXml) ) > 0
				lRet := AddTimbre(cRuta, cNombre, cXml)
				cUUID 		:= oXml:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
			 	cFechaTim 	:= REPLACE(SUBSTR(oXml:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT,1,10),"-","")
			EndIf
		EndIf
	Else								
		cError := If(Empty(cError), "", Alltrim(cError) + " ") + MemoRead( cRuta + cNombre + ".out")
	EndIf
	
	oXml := Nil
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ AddTimbre³ Autor ³ Alberto Rodriguez    ³ Data ³ 18/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Integra timbre fiscal en CFDi (temporales)                ³±±
±±³           ³ El WS devuelve solo TFD                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ AddTimbre( ruta , archivo , oXML )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ LeeXMLOut                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AddTimbre(cRutaXML, cArchivo, cTimbre)
	Local cFile		:= cRutaXML + cArchivo
	Local nHandle	:= 0
	Local aInfoFile	:= {}
	Local nSize		:= 0
	Local cXML		:= ""
	Local nIni		:= 0 
	Local cUTF8		:= Chr(239) + Chr(187) + Chr(191)
	Local lRet		:= .F.

	Begin Sequence
		If !( File( cFile ) )
			Break
		EndIf
	
		nHandle 	:= fOpen( cFile )
	
		If nHandle <= 0
			Break
		EndIf
	
		aInfoFile	:= Directory( cFile )
		nSize		:= aInfoFile[ 1 , 2 ]
		cXML		:= fReadStr( nHandle , nSize )
		fClose( nHandle )
	
		nIni := At( "</retenciones:Complemento>" , cXML)
	
		If nIni == 0
			Conout( ProcName(0) + ": " + STR0034 + " " + cArchivo + ".out" ) //"Archivo XML no válido"
			Break
		EndIf
	
		//Inserta nodo del timbre fiscal
		cXML := Substr(cXML, 1, nIni-1) + ;
				Space(8) + cTimbre + CRLF + ;
				Substr(cXML, nIni)
	
		// Codificacion UTF-8
		If Substr(cXML,1,1) == "<"
			cXML := Strtran( cXML , cUTF8 )
			cXML := cUTF8 + cXML // EncodeUTF8( cXML )
		EndIf
	
		// Graba el xml actualizado
		If ( nHandle := fCreate( cFile + ".timbre" ) ) <> -1 
			If fWrite( nHandle , cXML ) == Len(cXML)
				lRet := .T.
			EndIf
			fClose( nHandle )
		EndIf
	
	End Sequence
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ GrabaLog ³ Autor ³ Alberto Rodriguez    ³ Fecha³ 19/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Graba log de recibos no timbrados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ GrabaLog( cRuta , aRecibos )                              ³±±
±±³           ³ [x,1] - Nombre del archivo xml                            ³±±
±±³           ³ [x,2] - *mensaje de error                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ CFDiRecNom       		                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GrabaLog(cRuta , aRecibos)
	Local cArchivo  := DtoS(dDataBase) + Strtran(Time(), ":") + ".log"
	Local nHandle	:= FCreate(cRuta + cArchivo)
	Local nLoop		:= 0
	Local lRet		:= .F.
	
	If !(nHandle == -1)
		For nLoop := 1 to Len(aRecibos)
			FWrite(nHandle, aRecibos[nLoop,1] + " " + aRecibos[nLoop,3] + CRLF)
		Next nLoop
		FClose(nHandle)
		lRet := .T.
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³AddTimbre2³ Autor ³ Alberto Rodriguez    ³ Data ³ 18/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Integra timbre fiscal en CFDi (temporales)                ³±±
±±³           ³ El WS devuelve TFD integrado en CFDi                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ AddTimbre( ruta , archivo , oXML )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ LeeXMLOut                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AddTimbre2(cRutaXML, cArchivo, cXML)
	Local cFile		:= cRutaXML + cArchivo + ".out"
	
	Local nIni		:= 0
	Local lRet		:= .F.
	
	// Leer xml recibido como string
	Begin Sequence	
		nIni		:= At( ":TimbreFiscalDigital " , cXML)
		If nIni == 0
				Conout( ProcName(0) + ": " + STR0034 + " " + cArchivo + ".out" ) //"Archivo XML no válido"
			Break
		EndIf
	
		// Graba copia del xml recibido
		lRet := __CopyFile( cFile , cRutaXML + cArchivo + ".timbre" )
	
	End Sequence
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³fUpdRetTmp  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Actualiza tabla Temporal                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fUpdRetTmp(aOrdPag)
	Local nI := 0	
	Local nJ := 0 
	Local nK := 0
	
	dbSelectArea(cArqTmp)
	(cArqTmp)->(dbGoTop())	
	For nI := 1 To Len(aOrdPag)
		IF aOrdPag[nI,3] == "Timbrado"
			For nJ := 1 To Len(aOrdPag[nI][4])
				For nK := 1 To Len(aOrdPag[nI][4][nJ])
					If (cArqTmp)->(MsSeek(aOrdPag[nI,5]+aOrdPag[nI,4,nJ,nK,1]))
						If Alltrim(aOrdPag[nI,4,nJ,nK,1]) == Alltrim((cArqTmp)->NUMERO)
							RecLock(cArqTmp, .F.)
								(cArqTmp)->XML := aOrdPag[nI,1]
							MsUnLock()
						EndIf
					EndIf
				Next
			Next
		EndIf
	Next nI
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ImpPDF      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Impresion de archivo                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpPDF(cXmlNom,cPdfNom)
	Local cCaminhoXML := ""
	Local cPath 	  := Replace( cDir, "\\", "\" )
	Local oXML		  := NIL
	Local oPrinter    := Nil
	Local cError      := ""
	Local cDetalle    := ""
	Local cRutaSmr    := &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))
	
	Private cBuffer := ""
	Private oFont   := NIL
	Private oFont1  := NIL
	Private oFont2  := NIL
	Private oFont3  := NIL
	Private oFont4  := NIL
	Private oFont5  := NIL
	Private oFont6  := NIL
	Private oFont7  := NIL
	Private cCadenaOr := "||"

	cCaminhoXML := Replace( cDir + cXmlNom, "\\", "\" )

	IF ISSRVUNIX()
		cCaminhoXML := Replace( cCaminhoXML, "\", "/" )
		cCaminho := Replace( cDir, "\", "/" )
		cPath := Replace( cPath, "\", "/" )
	EndIf
	
	If File(GetClientDir() + cPdfNom)				
		Delete File &(GetClientDir() + cPdfNom)
	EndIf	

    oPrinter := FWMSPrinter():New(cPdfNom,6,.F.,GetClientDir(),.T.,,,,,.F.,,.T.)
    
	oFont1 := TFont():New('Courier new',,40,.T., .T.)
	oFont := TFont():New( "ARIAL", , 07, .T., .F.)
	oFont2 := TFont():New( "ARIAL", , 05, .T., .F.)
	oFont3 := TFont():New( "ARIAL", , 12, .T., .T.)
	oFont4 := TFont():New( "ARIAL", , 07, .T., .T.)
	oFont5 := TFont():New( "ARIAL", , 05, .T., .T.)
	oFont6 := TFont():New( "ARIAL", , 07, .T., .F.)
	oFont7 := TFont():New( "ARIAL", , 05, .T., .F.)
	oFont8 := TFont():New("Arial",,15,.T., .T.)
	
	If FILE(cCaminhoXML) 
		oXML := XmlParserFile(cCaminhoXML, "", @cError, @cDetalle )
	EndIf

	If oXML == NIL
		Return ""
	EndIf

	oPrinter:setDevice(IMP_PDF)
	oPrinter:cPathPDF := GetClientDir() //cPath

	oPrinter:StartPage()
	ImprRecNom(oPrinter,oXml)
	oPrinter:EndPage()

	oPrinter:SetViewPDF(lVisPDF) 
	oPrinter:Print()
	
	CpyT2S(GetClientDir() + cPdfNom, cDir)
				
	FreeObj(oPrinter)
	oPrinter := Nil
	If FILE(cRutaSmr + replace(cXmlNom,".xml",".rel"))
		FERASE(cRutaSmr + replace(cXmlNom,".xml",".rel"))
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ImprRecNom  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Impresion de archivo                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImprRecNom(oPrinter,oXml)
	Private cMsg	:= ""
	Private LI	    := 0
	Private cPict1	:=	"@E 999,999,999.99"
	Private cPict2 	:=	"@E 99,999,999.99"
	Private cPict3 	:=	"@E 999,999.99"
	Private nEsp1   := 10
	Private nEsp2   := 10
	Private nEsp3   := 15
	Private nEsp4   := 25
	Private nEspLi1 := 5
	Private nEspLi3 := 15
	Private nEspLi2 := 10

	ImpEnc(oPrinter,oXml)
	fLanca(oPrinter,oXML)
	fRodape(oPrinter,oXML)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ImpEnc      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Impresion de archivo                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpEnc(oPrinter,oXml)
	Local cMesIni  := oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_PERIODO:_MESINI:TEXT
	Local cMesFin  := oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_PERIODO:_MESFIN:TEXT
	Local cEJERC   := oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_PERIODO:_EJERC:TEXT
	Local cFechExp := oXml:_RETENCIONES_RETENCIONES:_FECHAEXP:TEXT
	Local cFileLogo:= ""

	cFechExp := Substr(cFechExp, 1, 10)

	F925CLogo(@cFileLogo)
	If File(cFileLogo)
		LI += 20 
		oPrinter:SayBitmap(LI, 15, cFileLogo, 50, 50) // Tem que estar abaixo do RootPath
	Endif	
	
	oPrinter:Line(5,5,820,5,,"-2") //Linea lateral izquierda
	oPrinter:Line(5,585,820,585,,"-4") //Linea lateral derecha
	oPrinter:Line(5,5,5,585,,"-4")//Linea horizontal de marco

	LI += 30
	oPrinter:Say(LI,175,STR0037,oFont8) //"Registro de pagos y retenciones CFDi"
	LI += 15
	oPrinter:Say(LI,235,STR0098,oFont8) //"del ISR, IVA e IEPS"
	LI += 15
	oPrinter:Say(LI,300,STR0099,oFont5) //"Período que ampara el registro"
	
	LI += 10
	oPrinter:Say(LI,450,STR0080,oFont5) //"Mes inicial"
	oPrinter:Say(LI,495,STR0081,oFont5) //"Mes final"
	oPrinter:Say(LI,540,STR0082,oFont5) //"Ejercicio"
	
	LI += 10
	cuadrosEnc(LI,450,oPrinter,retMes(cMesIni))
	cuadrosEnc(LI,495,oPrinter,retMes(cMesFin))
	cuadrosEnc(LI,540,oPrinter,cEJERC)
	
	LI += 25
	oPrinter:Say(LI,450,STR0039,oFont5) //"Fecha de expedición"
	oPrinter:Say(LI,504,cFechExp,oFont5)

	LI += 8
	oPrinter:Say(LI,450,STR0040,oFont5) //"Número de certificado"
	oPrinter:Say(LI,504,oXml:_RETENCIONES_RETENCIONES:_NUMCERT:TEXT,oFont5)

	cCadenaOr +=  oXml:_RETENCIONES_RETENCIONES:_VERSION:TEXT
	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_NUMCERT:TEXT
	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_FECHAEXP:TEXT
	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_CVERETENC:TEXT
	If XmlChildEx(oXml:_RETENCIONES_RETENCIONES, "_DESCRETENC") <> Nil
		cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_DESCRETENC:TEXT //si trae datos
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³fLanca      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Impresion de archivo                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fLanca(oPrinter,oXML)   // Impressao dos Lancamentos
	Local nI		:= 0
	Local cNac      := oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_NACIONALIDAD:TEXT
	Local cBenfect  := ""
	Local cImp      := ""
	Local nLiAuxD   := 0
	Local cStrAux   := ""
	Local nX        := 1
	Local nLong     := 1
	Local cCveRet   := oXml:_RETENCIONES_RETENCIONES:_CVERETENC:TEXT
	Local cRtSat    := SuperGetMV("MV_RTCVRET", .T., '')
	Local cImpSat   := SuperGetMV("MV_RTCVIMP", .T., '')

	LI += nEspLi1
	oPrinter:Line(LI,5,LI,585,,"-4")

	LI += nEspli3
	oPrinter:Line(LI,5,LI,585,,"-4")
	oPrinter:Say(LI -= 5,215,STR0041,oFont3) //"Datos de identificación del tercero"

	LI += 15
	oPrinter:Say(LI,15,STR0042,oFont4) //"RFC del emisor"
	oPrinter:Say(LI,120,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_EMISOR:_RFCEMISOR:TEXT,oFont)
	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_EMISOR:_RFCEMISOR:TEXT

	If XmlChildEx(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_EMISOR, "_CURPE") <> Nil	
		LI += 15
		oPrinter:Say(LI,15,STR0043,oFont4) //"CURP"
		oPrinter:Say(LI,120,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_EMISOR:_CURPE:TEXT,oFont)
	EndIf

	LI += 15
	oPrinter:Say(LI,15,STR0044,oFont4) //"Nombre o razón social"
	oPrinter:Say(LI,120,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_EMISOR:_NOMDENRAZSOCE:TEXT,oFont)

	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_EMISOR:_NOMDENRAZSOCE:TEXT

	LI += nEspLi1
	oPrinter:Line(LI,5,LI,585,,"-4")

	LI += nEspli3
	oPrinter:Line(LI,5,LI,585,,"-4")
	oPrinter:Say(LI -= 5,250,STR0045,oFont3) //"Pagos y retenciones"

	
	LI += 15
	oPrinter:Say(LI,15,STR0046,oFont4) //"Clave de retención"
	oPrinter:Say(LI,120,cCveRet,oFont)

	oPrinter:Say(LI,350,STR0047,oFont4) //"Total de la operación"
	oPrinter:Say(Li,450,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_MONTOTOTOPERACION:TEXT,oFont)

	LI += 20
	oPrinter:Say(LI,15,STR0048,oFont4) //"Descripción de la retención"
	cCveRet := ObtSX5 (cRtSat,cCveRet)
	oPrinter:Say(LI,120,cCveRet,oFont)
	
	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_NACIONALIDAD:TEXT

	if(cNac == "Nacional")
		cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_RETENCIONES_NACIONAL:_RFCRECEP:TEXT
		cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_RETENCIONES_NACIONAL:_NOMDENRAZSOCR:TEXT
		If XmlChildEx(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_RETENCIONES_NACIONAL, "_CURPR") <> Nil
			cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_RETENCIONES_NACIONAL:_CURPR:TEXT
		EndIf
	Else
		cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_RETENCIONES_EXTRANJERO:_NUMREGIDTRIB:TEXT
		cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_RETENCIONES_EXTRANJERO:_NOMDENRAZSOCR:TEXT
	EndIf

	LI += 25

	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_PERIODO:_MESINI:TEXT
	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_PERIODO:_MESFIN:TEXT
	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_PERIODO:_EJERC:TEXT

	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_MONTOTOTOPERACION:TEXT
	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_MONTOTOTGRAV:TEXT
	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_MONTOTOTEXENT:TEXT
	cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_MONTOTOTRET:TEXT

	/*Valida que exista el nodo de impuestos retenidos*/
	IF valtype(oXML:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS) == "A" //Varios impuestos
		For nI := 1 to len (oXML:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS)
			cImp := oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS[nI]:_IMPUESTO:TEXT

			If !Empty(cImpSat)
				cImp := ObtSX5 (cImpSat,cImp)
			EndIf

			LI += 15
			oPrinter:Say(LI,15,STR0049,oFont4) //Base del impuesto retenido
			oPrinter:Say(LI,120,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS[nI]:_BASERET:TEXT,oFont)

			oPrinter:Say(LI,350,STR0050,oFont4)//Tipo de impuesto
			oPrinter:SAY(Li,450 ,cImp,oFont)

			LI += 15
			oPrinter:Say(LI,15,STR0059,oFont4) //Monto retenido
			oPrinter:Say(Li,120,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS[nI]:_MONTORET:TEXT,oFont)

			oPrinter:Say(LI,350,STR0051,oFont4) //Tipo de pago
			oPrinter:Say(LI,450,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS[nI]:_TIPOPAGORET:TEXT,oFont)

			LI += 5
			oPrinter:Line(LI,5,LI,585,,"-4")

			cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS[nI]:_BASERET:TEXT
			cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS[nI]:_IMPUESTO:TEXT
			cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS[nI]:_MONTORET:TEXT
			cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS[nI]:_TIPOPAGORET:TEXT
		Next nI	
	Else
		cImp := oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS:_IMPUESTO:TEXT
	
		If !Empty(cImpSat)
			cImp := ObtSX5 (cImpSat,cImp)
		EndIf
	
		LI += 15
		oPrinter:Say(LI,15,STR0049,oFont4) //"Base del impuesto retenido"
		oPrinter:Say(LI,120,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS:_BASERET:TEXT,oFont)
	
		oPrinter:Say(LI,350,STR0050,oFont4) //"Tipo de impuesto"
		oPrinter:SAY(Li,450 ,cImp,oFont)
	
		LI += 15
		oPrinter:Say(LI,15,STR0059,oFont4) //"Valor retenido"
		oPrinter:Say(Li,120,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS:_MONTORET:TEXT,oFont)
	
		oPrinter:Say(LI,350,STR0051,oFont4) //"Total de pago"
		oPrinter:Say(LI,450,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS:_TIPOPAGORET:TEXT,oFont)
	
		LI += 5
		oPrinter:Line(LI,5,LI,585,,"-4")
	
		cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS:_BASERET:TEXT
		cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS:_IMPUESTO:TEXT
		cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS:_MONTORET:TEXT
		cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_RETENCIONES_IMPRETENIDOS:_TIPOPAGORET:TEXT	
	EndIf

	LI += 20
	oPrinter:Say(LI,15,STR0052,oFont4) //"Total gravado"
	oPrinter:SAY(LI,120 ,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_MONTOTOTGRAV:TEXT,oFont)
	LI += 15
	oPrinter:Say(LI,15,STR0053,oFont4) //"Total exento"
	oPrinter:SAY(LI,120 , oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_MONTOTOTEXENT:TEXT,oFont)

	LI += 15
	oPrinter:Say(LI,15,STR0054,oFont4) //"Total retenido"
	oPrinter:SAY(LI,120 , oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_MONTOTOTRET:TEXT,oFont)


	LI += nEspLi1
	oPrinter:Line(LI,5,LI,585,,"-4")
	
	If XmlChildEx(oXML:_RETENCIONES_RETENCIONES, "_RETENCIONES_COMPLEMENTO") <> Nil
		If XmlChildEx(oXML:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO, "_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS") <> Nil	
			LI += nEspli3
			oPrinter:Line(LI,5,LI,585,,"-4")
			oPrinter:Say(LI -= 5,250,STR0060,oFont3) //"Pagos extranjeros"
			
			cBenfect := oXML:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_ESBENEFEFECTDELCOBRO:TEXT
			cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_VERSION:TEXT
			cCadenaOr += "|" + cBenfect
	
			If( cBenfect == "SI")
				LI += 15
				oPrinter:Say(LI,15,STR0061,oFont4) //"RFC representante legal"
				oPrinter:SAY(LI,120 , oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_BENEFICIARIO:_RFC:TEXT,oFont)
				cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_BENEFICIARIO:_RFC:TEXT
	
				oPrinter:Say(LI,350,STR0064,oFont4) //"Concepto de pago"
				oPrinter:SAY(LI,450 , oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_BENEFICIARIO:_CONCEPTOPAGO:TEXT,oFont)
	
				LI += 15
				oPrinter:Say(LI,15,STR0062,oFont4) //"CURP representante legal"
				oPrinter:SAY(LI,120 , oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_BENEFICIARIO:_CURP:TEXT,oFont)
	
				oPrinter:Say(LI,350,STR0065,oFont4) //"Descripción del concepto"
				nLiAuxD := LI
				nLong := CalRen(Len(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_BENEFICIARIO:_DESCRIPCIONCONCEPTO:TEXT))
				
				For nI := 1 to nLong
					cStrAux:= Substr(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_BENEFICIARIO:_DESCRIPCIONCONCEPTO:TEXT,nX,Iif(nI>1,78,42))//170)
					nX += IIf(nI > 1,78,42) //170
					oPrinter:SAY(nLiAuxD,IIf(nI > 1,350,450) ,cStrAux,oFont)
					nLiAuxD += 10
				Next nI
				
				LI += 15
				oPrinter:Say(LI,15,STR0044,oFont4) //"Nombre o razón social"
				oPrinter:SAY(LI,120 , oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_BENEFICIARIO:_NOMDENRAZSOCB:TEXT,oFont)
				
				LI := IIF (nLiAuxD > LI,nLiAuxD,LI)
				cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_BENEFICIARIO:_CURP:TEXT
				cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_BENEFICIARIO:_NOMDENRAZSOCB:TEXT
				cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_BENEFICIARIO:_CONCEPTOPAGO:TEXT
				cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_BENEFICIARIO:_DESCRIPCIONCONCEPTO:TEXT			
			ElseIf (cBenfect == "NO")
				cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_NOBENEFICIARIO:_PAISDERESIDPARAEFECFISC:TEXT
				cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_NOBENEFICIARIO:_CONCEPTOPAGO:TEXT
				cCadenaOr += "|" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_NOBENEFICIARIO:_DESCRIPCIONCONCEPTO:TEXT
				
				LI += 15
				oPrinter:Say(LI,15,STR0066,oFont4) //"País de residencia"
				oPrinter:SAY(Li,120 , oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_NOBENEFICIARIO:_PAISDERESIDPARAEFECFISC:TEXT,oFont)
	
				oPrinter:Say(LI,350,STR0064,oFont4) //"Concepto de pago"
				oPrinter:SAY(Li,450 , oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_NOBENEFICIARIO:_CONCEPTOPAGO:TEXT,oFont)
	
				LI += 15
	
				oPrinter:Say(LI,350,STR0065,oFont4) //"Descripción del concepto"
				
				nLiAuxD := Li
				nLong := CalRen(Len(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_NOBENEFICIARIO:_DESCRIPCIONCONCEPTO:TEXT))
				For nI := 1 to nLong
					cStrAux:= Substr(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_PAGOSAEXTRANJEROS_PAGOSAEXTRANJEROS:_PAGOSAEXTRANJEROS_NOBENEFICIARIO:_DESCRIPCIONCONCEPTO:TEXT,nX,Iif(nI>1,78,42))//170)
					nX += IIf(nI > 1,78,42)//170
					oPrinter:SAY(nLiAuxD,IIf(nI > 1,350,450) ,cStrAux,oFont)
					nLiAuxD+=10
				Next nI
				LI := IIf(nLiAuxD > LI,nLiAuxD,LI)
			EndIf
		EndIf
	EndIf
	cCadenaOr += "||"

	LI += nEspLi1
	oPrinter:Line(LI,5,LI,585,,"-4")

	LI += nEspli3
	oPrinter:Line(LI,5,LI,585,,"-4")
	oPrinter:Say(LI -= 5,250,STR0055,oFont3) //"Datos del retenedor"

	If (cNac == "Nacional")
		LI += 15
		oPrinter:Say(LI,15,STR0056,oFont4) //"Nacionalidad"
		oPrinter:SAY(LI,120,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_NACIONALIDAD:TEXT,oFont)

		oPrinter:Say(LI,350,STR0057,oFont4) //"Número de registro fiscal"
		oPrinter:SAY(LI,450,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_RETENCIONES_NACIONAL:_RFCRECEP:TEXT,oFont)

		LI += 15
		oPrinter:Say(LI,15,STR0044,oFont4) //"Nombre o razón social"
		oPrinter:SAY(LI,120,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_RETENCIONES_NACIONAL:_NOMDENRAZSOCR:TEXT,oFont)

		LI += 5
		oPrinter:Line(LI,5,LI,585,,"-4")
	Else
		LI += 15
		oPrinter:Say(LI,15,STR0056,oFont4) //"Nacionalidad"
		oPrinter:SAY(LI,120,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_NACIONALIDAD:TEXT,oFont)
		
		LI += 15
		oPrinter:Say(LI,15,STR0044,oFont4) //"Nombre o razón social"
		oPrinter:SAY(LI,120,oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_RETENCIONES_EXTRANJERO:_NUMREGIDTRIB:TEXT,oFont)
	EndIf
	
    LI += 10
	
	cuadros(LI,10,oPrinter,STR0073)  //"Firma del retenedor o representante legal"
	cuadros(LI,201,oPrinter,STR0074) //"Firma del retenedor (en caso de tener)"
	cuadros(LI,392,oPrinter,STR0075) //"Firma de recebido por el contribuyente"
	
	LI += 100
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³fRodape     ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Impresion de archivo                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fRodape(oPrinter,oXML)
	Local nI			:= 0
	Local nx			:= 0
	Local cCadAux		:= ""
	Local nLiaux		:= 0
	Local nLiAuxIzq 	:= 0

	LI += nEspLi1
	newPage(oPrinter)
	oPrinter:Line(LI,5,LI,585,,"-4")

	newPage(oPrinter)

	oPrinter:Line(LI,5,LI,585,,"-4")
	LI += nEspLi2
	newPage(oPrinter)

	aBlock := LoadBlock(oXML)
	If aBlock[4][2] > 815 - LI
		newPage(oPrinter, .T.)
	EndIf
	nLiaux	:= LI

	oPrinter:SAY(LI,130 ,STR0067,oFont5) //"Sello digital del emisor"
	oPrinter:SAY(LI,485 ,STR0071,oFont5) //"Fecha de certificación"
	nLiaux	:= LI
	LI += nEsp2

	If XmlChildEx(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL, "_SELLOCFD") <> Nil
		nX := 1
		nLiAuxIzq := Li
		For nI := 1 to aBlock[2][2]
			cCadAux:= Substr(aBlock[2][1],nX,125)
			nX+=120
			oPrinter:SAY(LI,130,cCadAux,oFont7)
			LI += nEsp1
		Next nI
		
		If !Empty(aBlock[5][1])
			nX := 1
			For nI := 1 to aBlock[5][2]
				cCadAux:= Substr(aBlock[5][1],nX,93)
				nX += 93
				oPrinter:SAY(nLiAuxIzq,485 ,cCadAux,oFont7)
				nLiAuxIzq += nEsp1
			Next nI
		EndIf
	Else
		LI += nEsp2
	EndIf

	oPrinter:SAY(LI,130 , STR0068, oFont5) //"Sello digital del SAT"
	oPrinter:SAY(LI,485 , STR0070, oFont5) //"Número fiscal"
	LI += nEsp2

	If	XmlChildEx(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL, "_SELLOSAT") <> Nil
		nX := 1
		nLiAuxIzq := LI
		For nI := 1 to aBlock[3][2]
			cCadAux:= Substr(aBlock[3][1],nX,130)
			nX += 130
			oPrinter:SAY(LI,130 ,cCadAux,oFont7)
			LI += nEsp1
		Next nI
		
		oPrinter:QRCode(10,nLiaux + 110 ,aBlock[4][1], 50)
		
		If !Empty(aBlock[6][1])
			nX := 1
			For nI := 1 to aBlock[6][2]
				cCadAux:= Substr(aBlock[6][1],nX,93)
				nX += 93
				oPrinter:SAY(nLiAuxIzq,485 ,cCadAux,oFont7)
				nLiAuxIzq+=nEsp1
			Next nI
		EndIf		
	Else
		LI += nEsp1
	EndIf

	oPrinter:SAY(LI,130 , STR0069, oFont5) //"Cadena original de la firma"
	oPrinter:SAY(LI,485 , STR0072, oFont5) //"Núm. Certificado SAT"
	LI += nEsp2

	If XmlChildEx(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO, "_TFD_TIMBREFISCALDIGITAL") <> Nil
		nX := 1
		nLiAuxIzq := LI
		For nI := 1 to aBlock[1][2]
			cCadAux := Substr(aBlock[1][1],nX,131)
			nX += 131
			oPrinter:SAY(LI,130 ,cCadAux,oFont7)
			LI += nEsp1
		Next nI
		
		If !Empty(aBlock[7][1])
			nX := 1
			For nI := 1 to aBlock[7][2]//2
				cCadAux:= Substr(aBlock[7][1],nX,93)
				nX += 93
				oPrinter:SAY(nLiAuxIzq,485 ,cCadAux,oFont7)
				nLiAuxIzq += nEsp1
			Next nI
		EndIf
	Else
		LI += nEsp2
	EndIf
	
	LI += nEsp3
	oPrinter:SAY(lI,130,STR0076,oFont5) //"Este documento es una representación impresa de un CFDI"
	oPrinter:Line(820,5,820,585,,"-4")	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³fRodape     ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Calcula bloque y regresa cadenas de los nodos y lineas a usar³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LoadBlock(oXML)
	Local aBlock   := {{{},{}},{{},{}},{{},{}},{{},{}},{{},{}},{{},{}},{{},{}}}
	Local nLineas  := 0
	Local cCadena  := ""
	Local nX       := 0
	Local nI       := 0
	Local nTmp     := 0
	Local nLiAux   := 0
	Local cCertSAT := ""
	Local nTtlAux  := 0
	Local cNac     := oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_NACIONALIDAD:TEXT

	nLineas += oFont5:NHEIGHT
	nLineas += nEsp2
	
	If !Empty(cCadenaOr)
		
		nX := 1
		nTmp := (len(cCadenaOr)/225)	+ 2

		For nI := 1 to nTmp
			cCadAux:= Substr(cCadenaOr,nX,225)
			nX += 225
			nLineas += oFont7:NHEIGHT
			nLineas += nEsp2
		Next nI
		aBlock[1][1] := cCadenaOr
		aBlock[1][2] := nTmp
	Else
		nLineas += nEsp2
	EndIf

	nLiAux += oFont5:NHEIGHT
	nLiAux += nEsp2
	
	If XmlChildEx(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL, "_SELLOCFD") <> Nil
		cCadena :=  oXML:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOCFD:TEXT
		nX := 1
		nTmp := (len(cCadena)/170)	+ 1
		For nI := 1 to nTmp
			cCadAux:= Substr(cCadena,nX,170)
			nX+=170
			nLiAux	+= oFont7:NHEIGHT
			nLiAux += nEsp1
		Next nI
		aBlock[2][1] := cCadena
		aBlock[2][2] := nTmp
	Else
		nLiAux += nEsp2
	EndIf

	nLiAux += oFont5:NHEIGHT
	nLiAux += nEsp2

	If XmlChildEx(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL, "_SELLOSAT") <> Nil
		If Val(oXML:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_MONTOTOTOPERACION:TEXT) < 0
			nTtlAux := Val(oXML:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_MONTOTOTOPERACION:TEXT) * (- 1)
			nTtlAux := "-" + Replace(Transform(nTtlAux,"999999999.999999") , " ", "0")
		Else
			nTtlAux := Val(oXML:_RETENCIONES_RETENCIONES:_RETENCIONES_TOTALES:_MONTOTOTOPERACION:TEXT)
			nTtlAux := Replace(Transform(nTtlAux,"9999999999.999999") , " ", "0")

		EndIf

		cCertSAT := "?re=" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_EMISOR:_RFCEMISOR:TEXT
		If cNac == "Nacional"
			cCertSAT += "&rr=" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_RETENCIONES_NACIONAL:_RFCRECEP:TEXT
		Else
			cCertSAT += "&nr=" + oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_RECEPTOR:_RETENCIONES_EXTRANJERO:_NUMREGIDTRIB:TEXT
		EndIf
		cCertSAT += "&tt=" + nTtlAux
		cCertSAT += "&id=" + oXML:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT

		aBlock[4][1] := cCertSAT
		cCadena :=  oXML:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_SELLOSAT:TEXT
		nX := 1
		nTmp := (len(cCadena)/170)	+ 1

		For nI := 1 to  nTmp

			cCadAux:= Substr(cCadena,nX,170)
			nX+=170
			nLiAux += 	oFont7:NHEIGHT
			nLiAux += nEsp1
		Next nI
		aBlock[3][1] := cCadena
		aBlock[3][2] := nTmp
	Else
		nLiAux += nEsp1
	EndIf

	nLiAux += nEsp3
	nLiAux += oFont7:NHEIGHT

	If nLiAux <= 115
		nLineas += 120
	Else
		nLineas += nLiAux
	EndIf
	aBlock[4][2] := nLineas
	
	
	If XmlChildEx(oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO, "_TFD_TIMBREFISCALDIGITAL") <> Nil
			cCadena := oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
			nX := 1
			nTmp := (len(cCadena)/93)
	
			For nI := 1 to nTmp
				cCadAux:= Substr(cCadena,nX,93)
				nX += 93
				nLineas += oFont7:NHEIGHT
				nLineas += nEsp2
			Next nI
			aBlock[5][1] := cCadena
			aBlock[5][2] := Iif (nTmp>1,nTmp,1)
			
			cCadena := oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
			nX := 1
			nTmp := (len(cCadena)/93)
	
			For nI := 1 to nTmp
				cCadAux:= Substr(cCadena,nX,93)
				nX += 93
				nLineas += oFont7:NHEIGHT
				nLineas += nEsp2
			Next nI
			aBlock[6][1] := cCadena
			aBlock[6][2] := Iif (nTmp>1,nTmp,1)
			
			cCadena := oXml:_RETENCIONES_RETENCIONES:_RETENCIONES_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
			nX := 1
			nTmp := (len(cCadena)/93)
	
			For nI := 1 to nTmp
				cCadAux:= Substr(cCadena,nX,93)
				nX += 93
				nLineas += oFont7:NHEIGHT
				nLineas += nEsp2
			Next nI
			aBlock[7][1] := cCadena
			aBlock[7][2] := Iif (nTmp>1,nTmp,1)
	EndIf
Return aBlock

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³Cuadros     ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Divide hoja en cuadros                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Cuadros(nAlto,nHor,oPrinter,cTexto)
	oPrinter:Line(nAlto,nHor,nAlto,nHor + 186,,"-4") //Linea superior
	oPrinter:Line(nAlto,nHor,nAlto + 90 ,nHor,,"-4") //Linea lateral izquierda
	oPrinter:Line(nAlto,nHor + 186,nAlto + 90,nHor + 186,,"-4") //Linea lateral derecha
	oPrinter:Say(nAlto + 85,nHor + 45,cTexto,oFont5)
	oPrinter:Line(nAlto + 90 ,nHor,nAlto + 90,nHor + 186,,"-4")//Linea horizontal inferior	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³CuadrosEnc  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Divide hoja en cuadros                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CuadrosEnc(nAlto,nHor,oPrinter,cTexto)
	
	oPrinter:Line(nAlto,nHor,nAlto,nHor + 40,,"-4") //Linea superior
	oPrinter:Line(nAlto,nHor,nAlto + 15 ,nHor,,"-4") //Linea lateral izquierda
	oPrinter:Line(nAlto,nHor + 40,nAlto + 15,nHor + 40,,"-4") //Linea lateral derecha
	oPrinter:Say(nAlto + 10,nHor + 10,cTexto,oFont5)
	oPrinter:Line(nAlto + 15 ,nHor,nAlto + 15,nHor + 40,,"-4")//Linea horizontal inferior	
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ObtSX5      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Obtiene informacion de SX5                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtSX5(cTabla, cClave)
	Local cDesc :=""

	DbSelectArea("SX5") //Abrir la tabla
	SX5->(DbSetOrder(1)) // Ordena por indica [1]
	If MsSeek( Space(Len(SX5->X5_FILIAL)) + cTabla + cClave  )//busca en la tabal con el indice con los datos que se le pasen
		cDesc := SX5->X5_DESCSPA
	EndIf
Return cDesc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ObtSX5      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Comprueba el espacio restante en la pagina                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function newPage(oPrinter,lCheck)
	Local lNewPage := .F.
	Default lCheck := .F.

	If lCheck
		lNewPage := .T.
	Else
		If li >= 815
			lNewPage := .T.
		EndIf
	EndIf

	If lNewPage
		oPrinter:Line(820,5,820,585,,"-4")
		oPrinter:SAY(825,10 , cMsg,oFont7)
		oPrinter:EndPage()
		LI := 50
		oPrinter:StartPage()
		oPrinter:Line(5,5,820,5,,"-4") //Linea lateral izquierda
		oPrinter:Line(5,585,820,585,,"-4") //Linea lateral derecha
		oPrinter:Line(5,5,5,585,,"-4")//Linea horizontal de marco
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³RetMes      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Obtiene mes en letra                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function RetMes(cMes)
	Local cMesTxt := ""
	DO CASE
    	CASE Val(cMes) == 1
         	cMesTxt := "Enero"
		CASE Val(cMes) == 2
         	cMesTxt := "Febrero"
       CASE Val(cMes) == 3
         	cMesTxt := "Marzo"
       CASE Val(cMes) == 4
         	cMesTxt := "Abril"
       CASE Val(cMes) == 5
         	cMesTxt := "Mayo"
       CASE Val(cMes) == 6
         	cMesTxt := "Junio"
       CASE Val(cMes) == 7
         	cMesTxt := "Julio"
	   CASE Val(cMes) == 8
         	cMesTxt := "Agosto"
       CASE Val(cMes) == 9
         	cMesTxt := "Septiembre"
       CASE Val(cMes) == 10
         	cMesTxt := "Octubre"
       CASE Val(cMes) == 11
         	cMesTxt := "Noviembre"
       CASE Val(cMes) == 12
         	cMesTxt := "Diciembre"
	ENDCASE
Return cMesTxt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³FI925IMPCT  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Importacion de catalogos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FI925IMPCT()
	Local	oFld   := Nil
	Local   aCombo := {}
	Private oGet   := Nil
	Private oDlg   := Nil
	Private cCombo := ""
	Private lCat   := .T.
	Private lAct   := .F.

	aAdd (aCombo, STR0077) //"1- Retenciones"
	aAdd (aCombo, STR0086) //"2- Tipo contribuyente"
	aAdd (aCombo, STR0087) //"3- Países"
	aAdd (aCombo, STR0088) //"4- Tipo impuesto"
	
	DEFINE MSDIALOG oDlg TITLE STR0079 FROM 0,0 TO 200,450 OF oDlg PIXEL //"Agregar catálogos"
	@ 020,020 TO 070,150 LABEL STR0089 OF oDlg PIXEL                     //"Tipo de catálogo"
	@ 030,025 SAY STR0090 SIZE 150,008 PIXEL                             //"Seleccione el catálogo que desea subir."
	@ 040,025 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 75,8 PIXEL OF oFld 
	
	
	@ 035,178 BUTTON STR0091 SIZE 026,016 PIXEL ACTION ImpArq(Val(Subs(cCombo,1,1))) //"&Aceptar"
	@ 055,178 BUTTON STR0092 SIZE 026,016 PIXEL ACTION oDlg:End() //"&Salir"
	
	ACTIVATE MSDIALOG oDlg CENTER
Return Nil
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ValExtFile  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Valida extension del archivo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValExtFile(cNomeFile)
	Local lCat := .T.
	Local cExt	:= Substr(cNomeFile,len(cNomeFile)-2)//Substr(cNomeFile,at(".",cNomeFile)+1)
	
	Do Case
	Case (Empty(UPPER(cNomeFile)))
		MsgAlert(STR0124,STR0015) //"Es necesario seleccionar un archivo" # "Atención"
		lCat := .F.
	Case (!(cExt $"csv|CSV|txt|TXT"))
		MsgAlert(STR0094) //"Formato de archivo no válido."
	EndCase	
Return lCat

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ValExtFile  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Funcion para agregar archivo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/	
Static Function FGetFile()
	Local cRet := Space(50)
	
	oDlg01 := MSDialog():New(000,000,100,500,STR0093,,,,,,,,,.T.) //"Seleccionar archivo"
	
		oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,{||ValExtFile(cRet)},,,,,,.T.,,,,,,,,,,"cRet")
		oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0093,,.T.) //"Seleccionar archivo"
		
		oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
		oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)
	
	oDlg01:Activate(,,,.T.,,,)
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ValExtFile  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Funcion para obtener dirección                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/	
Static Function FGetDir(oTGet)
	Local cDir := ""
	
	cDir := cGetFile(,STR0093,,,.T.,GETF_LocalFLOPPY+GETF_LocalHARD+GETF_NETWORKDRIVE) //"Seleccionar archivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	EndIf
	
	oTGet:SetFocus()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ImpArq      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Selecciona el tipo de archivo a procesar                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpArq(nOpc,cTabla)
	Local nI       := 0
	Local lEsArch  := .F.
	Local cTitulo  := "" 
		  
	Default cTabla   := ""   
	
	Private cArchivo := FGetFile() 
	Private aSX5     := {}

	If nOpc == 1
		cTabla  := Alltrim(SuperGetMV("MV_RTCVRET",,""))
		cTitulo := STR0120 //"Tipo de Retenciones"
	ElseIf nOpc == 2
		cTabla  := Alltrim(SuperGetMV("MV_RTCCONT",,""))
		cTitulo := STR0121 //"Tipo de Contribuyente"
	ElseIf nOpc == 3
		cTabla  := Alltrim(SuperGetMV("MV_RTCPAIS",,""))
		cTitulo := STR0122 //"Paises"
	ElseIf nOpc == 4
		cTabla  := Alltrim(SuperGetMV("MV_RTCVIMP",,""))
		cTitulo := STR0123 //"Tipo de Impuestos"
	EndIf

	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))

	If !Empty(cArchivo)  //Existe la ruta y el archivo, se debe cargar
		Imp(cArchivo, cTabla, cTitulo) //Lee el archivo y lo carga
		lEsArch  := .T.
	EndIf

	If Len(aSX5)>0 
		DbSelectArea("SX5")
		SX5->(DbSetOrder(1))
	
		//Elimina solo esta vez el catalogo
		
		If MsSeek(xFilial("SX5") + cTabla)    
			BorraCat("SX5"," X5_TABELA ='00' AND X5_CHAVE = '" + Padr(cTabla,TAMSX3("X5_CHAVE")[1]) + "'" )
			BorraCat("SX5"," X5_TABELA ='" + Padr(cTabla,TAMSX3("X5_TABELA")[1]) + "'" )
		EndIf                         
	
		Begin Transaction
			For nI := 1 To Len(aSX5)
				If !MsSeek(xFilial("SX5")+aSX5[nI][02]+aSX5[nI][03])
					RecLock("SX5",.T.)
						X5_FILIAL  := aSX5[nI][1]
						X5_TABELA  := aSX5[nI][2]
						X5_CHAVE   := aSX5[nI][3]
						X5_DESCSPA := aSX5[nI][4]
						X5_DESCENG := aSX5[nI][5]
						X5_DESCRI  := aSX5[nI][6]
					MsUnLock()
				EndIf
			Next nI
		End Transaction
	EndIf 
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BorraCat  ºAutor  ³Laura Medina        ºFecha ³  10/12/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcion para borrar catalogos, solo mientras tengan constan-º±±
±±º          ³tes cambios.    b                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BorraCat(cAliasElm,cWhere)
	Local cQuery := ""

	cQuery := "DELETE FROM " +RetSqlName(cAliasElm) +"  "
	If  !Empty(cWhere)
		cQuery += " WHERE ("+cWhere+") " 
	EndIf
	
	If TcSqlExec(cQuery) <> 0  
	   MsgAlert(TcSqlError()) 
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ImpArq      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Procesa archivo y coloca su contenido en tabla temporal TRD  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imp(cFile,cTabla,cTitulo)
	Local cBuffer	:= ""
	Local nFor		:= 0
	Local nHandle		
	Local nX		:= 0
	Local lRet 		:= .F.
	Local nloop     := 0
		
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))	
	
	nHandle := FT_FUse(cFile)
	
	IF nHandle = -1  
		MsgAlert(STR0095 + STR0096)	//"El archivo" # "No puede abrirse"
		return .F.	
	Else
		// Se posiciona en la primera línea
		FT_FGoTop()
		
		nFor := FT_FLastRec()
		
		ProcRegua(nFor)
		
		While !FT_FEOF()   
			nX++
		
			nRecno 	:= FT_FRecno()
			IncProc(STR0006 + str(nX)) //"Ord. De Pago"
			cBuffer := FT_FReadLn()  
			cBuffer := Alltrim(cBuffer)
			aLinea  := {}
	
			If subStr(cBuffer,len(cBuffer),1) != ";"
				cBuffer += ";"
			EndIf
			
			If cBuffer != ";"
				For nloop := 1 to Len(cBuffer)
					aAdd(aLinea,allTrim(substr(cBuffer,1,at(";",cBuffer)-1)))
					cBuffer := substr(cBuffer,at(";",cBuffer)+1,len(cBuffer)-at(";",cBuffer))
					If Len(cBuffer) == 0
						Exit
					EndIf
				Next nloop
			EndIf
			
			If Len(aLinea) > 0
				aAdd(aSX5,{Space(Len(SX5->X5_FILIAL)),cTabla,aLinea[1],aLinea[2],aLinea[2],aLinea[2]})   
		    EndIf
		     		 
			FT_FSKIP()
		EndDo
		
		If len(aSX5) > 0 
			MsgInfo(STR0095 + STR0097,"Exito") //"El archivo" # "Fue procesado con éxito"
			aAdd(aSX5,{Space(Len(SX5->X5_FILIAL)),"00",cTabla,cTitulo, cTitulo, cTitulo})
		EndIf
		
	EndIf
	// Fecha o Arquivo
	FT_FUSE()
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³CalRen      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Calcula numero de renglones                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalRen(nLen)
	Local nLong := 0
	Local nI := 0

	If nLen > 42
		nLong += 1
		nLen -= 42
		If (nLen) / 78 > 1
			For nI := 1 to (nLen) / 78
				nLong += 1
				nLen -= 78
			Next nI
			If nLen > 0
				nLong += 1
			EndIf
		Else
			nLong += 1
		EndIf
	Else
		nLong := 1
	EndIf
Return nLong 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³vldRet      ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion |Valida codigo de retencion                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function vldRet(cCodRet)
	Local lRet := .T.
	
	If !(cCodRet $ "01|05")
		MsgAlert(STR0100 + CRLF + STR0101 + CRLF + STR0102) //"Solo se permite utilizar los códigos:" # "01 - Servicios profesionales" # "05 - Arrendamiento"
		lRet := .F.
	EndIf
Return lRet 

/*/{Protheus.doc} ImprimeLog
//Imprime Log del proceso.
@author luis enriquez mata
@since 05/05/2020
@version 1.0
@return Nil
@type function
/*/
Static Function ImprimeLog(aRegs)
	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }
	Local cTamanho	:= "M"
	Local cTitulo	:= STR0104 //"Timbrado de CFDI de retenciones"
	Local aLogTitle	:= Array(2)	
	Local aLog		:= {}
	Local nLenDoc	:= Len((cArqTmp)->NUMERO) + 4
	Local nLenCte	:= Len((cArqTmp)->PROVEEDOR + (cArqTmp)->SUCURSAL) + 5	
	Local nX		:= 1
	Local nC        := 1
	Local nPos      := 1
	Local cDetalle  := ""
	Local nEnv      := 0

	aLogTitle[1] := PadR(STR0117,nLenDoc) + PadR(STR0118,nLenCte) + STR0119	//"Documento" # "Cliente" # "Mensaje"
	aLogTitle[2] := STR0105 //"Resumen del proceso de solicitud de timbrado de CFDI de Retenciones"
	
	aAdd( aLog, {})

	For nX := 1 to Len(aRegs)
		cDetalle := ""
		nPos := 1
		If Len(aRegs[nX,3]) > 84
			For nC:= 1 to (Len(aRegs[nX,3])/84) + 1				 
				cDetalle += SUBSTR(aRegs[nX,3],nPos,84)  + (chr(13) + chr(10)) + SPACE(40)
				nPos += 84
			Next nC			
		Else
			cDetalle := aRegs[nX,3]
		EndIf	
	    aAdd(aLog[1],	aRegs[nX,6] + Space(4) + ; // Retención
	    				aRegs[nX,5] + Space(4) + ; // Cliente + Loja
	    				cDetalle ) // Detalle  
	    If aRegs[nX,8]
	    	nEnv += 1
	    EndIf   			
	Next nX
	
	aAdd( aLog, {})
	aAdd( aLog[2], "")
	aAdd( aLog[2], STR0106 + Str(Len(aRegs),5)) //"Total de documentos procesados: "
	If nEnv > 0
		aAdd( aLog[2], STR0107 + Str(nEnv,5)) //"Total de documentos enviados: "
	EndIf
	
	/*
		1 -	aLogFile 	//Array que contem os Detalhes de Ocorrencia de Log
		2 -	aLogTitle	//Array que contem os Titulos de Acordo com as Ocorrencias
		3 -	cPerg		//Pergunte a Ser Listado
		4 -	lShowLog	//Se Havera "Display" de Tela
		5 -	cLogName	//Nome Alternativo do Log
		6 -	cTitulo		//Titulo Alternativo do Log
		7 -	cTamanho	//Tamanho Vertical do Relatorio de Log ("P","M","G")
		8 -	cLandPort	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
		9 -	aRet		//Array com a Mesma Estrutura do aReturn
		10-	lAddOldLog	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
	*/
	MsAguarde( { ||fMakeLog( aLog , aLogTitle , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn , .F. )}, STR0125) //"Generando Log de proceso..." 	
Return Nil

/*/{Protheus.doc} F925VldReg
Valida datos necesarios para generación del XML de retenciones
@type function
@author luis.enríquez
@since 10/05/2020
@version 1.0
@return cVal .- String con mensajes de validaciones.
/*/
Static Function F925VldReg(cCodPro, cCodLoja)
	Local cVal  := ""
	Local aArea := getArea()
	
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
	SA2->(dbGoTop())
	
	If SA2->(MsSeek(cFilSA2 + cCodPro + cCodLoja))
		cVal += IIf(Empty(SA2->A2_NOME),STR0110 + Alltrim(FWX3Titulo("A2_NOME")) + " (A2_NOME)" + STR0111 +" |" ,"") //" El campo " # " del proveedor está vacío"
		cVal += IIf(Empty(SA2->A2_EST),STR0110 + Alltrim(FWX3Titulo("A2_EST")) + " (A2_EST)" + STR0111 + " |" ,"") //" El campo " # " del proveedor está vacío"
		cVal += IIf(Empty(ObtPaisSat(SA2->A2_PAIS)),STR0112 + " (" + Alltrim(SA2->A2_PAIS) +")" + STR0110 + Alltrim(FWX3Titulo("YA_CVESAT")) + " (YA_CVESAT) "+ STR0113 + " |" ,"") //" Para el país" # " El campo " # "está vacío"
		If Alltrim(SA2->A2_EST) == "EX"
			cVal += IIf(Empty(cDesConc),STR0110 + Alltrim(FWX3Titulo("EK_DCONCEP")) + " (EK_DCONCEP) " + STR0114 + " |" ,"") //"El campo " # "de la Orden de Pago está vacío"
		EndIf
	EndIf
	
	RestArea(aArea)
Return cVal

/*/{Protheus.doc} CargaLogo
Carga logo de la empresa
@type function
@author luis.enriquez
@since 10/05/2020
@version 1.0
@return cLogo .- Retorna url de ubicación de logo de empresa.
/*/
Static Function F925CLogo(cLogo)
	Local cStartPath := GetSrvProfString("Startpath", "")
	
	cLogo	:= cStartPath + "\LGRL"+ aDatosSM0[3][2] + aDatosSM0[4][2] + ".BMP" //SM0->M0_CODIGO + SM0->M0_CODFIL
	//-- Logotipo da Empresa
	If !File( cLogo )
		cLogo := cStartPath + "\LGRL" + aDatosSM0[3][2] + ".BMP" //SM0->M0_CODIGO
	EndIf
Return Nil

/*/{Protheus.doc} FA925Leg
Carga leyendas para el browse
@type function
@author luis.enriquez
@since 11/05/2020
@version 1.0
/*/
Function FA925Leg()
	Local aCores := {}
	
	aAdd(aCores,{"BR_VERDE"	,STR0115})    //"Disponible"
	aAdd(aCores,{"BR_AZUL"	,STR0116}) //"CFDI Timbrado"
	
	BrwLegenda(STR0108,STR0109,aCores) //"Leyenda" # "Status para CFDI de Retenciones"
Return Nil

/*/{Protheus.doc} FA925CKMX
Valida selección de ordenes de pago para timbrado de CFDI.
@type function
@author luis.enriquez
@since 12/05/2020
@version 1.0
/*/
Function FA925CKMX(cAlias,cRecibo)
	Local lRet	:= .T.
	Local lMarca := Nil
	
	dbSelectArea("SEK")
	SEK->(DbSetOrder(1)) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ	
	
	If Empty((cAlias)->MARK)
		If SEK->(MsSeek(cFilSEK + cRecibo))
			If !Empty(SEK->EK_XMLRET)
				MsgAlert(STR0128 + Alltrim(cRecibo) + STR0129, STR0015) //"El CDFI de retención para la Orden de Pago " # " ya fue generado." # "Atención"
				lRet := .F.
			EndIf
	    Else
	    	lRet := .F.
	    EndIf
		If lRet
			lMarca := ((cAlias)->MARK== cMarcaTR)
			(cAlias)->MARK := IIf(lMarca,"",cMarcaTR)
		EndIf
	Else	
	   (cAlias)->MARK := ""
	EndIf
Return(lRet)

/*/{Protheus.doc} FA925CCat
Función para cargar los catálogos de tablas genericas Tipos de Retenciones (XF), 
Tipos de Contribuyentes (XG), Países (XH) y Tipos de Impuestos (XI).
@type function
@author luis.enriquez
@since 13/05/2020
@version 1.0
/*/
Function FA925CCat()
	Local nRegProc := 0
	Local cCtrl    := (chr(13) + chr(10))
	Local cAviso   := ""
	Local cAuxArch := ""
	
	Private cPath := Alltrim(SuperGetMV("MV_PATH814",,"C:\Temp\FISA814\"))
	
	//"Tipos de Retenciones"
	cAuxArch := "01TiposRetencion.csv"
	If File(cPath + cAuxArch)
		Processa( {|| nRegProc := F925ImpArq(cPath + cAuxArch,1,"XF")},STR0130, STR0131, .T. ) //"Procesando..." # "Catálogo de Tipos de Retenciones"
		cAviso += STR0132 + Alltrim(Str(nRegProc)) + STR0133 + STR0131 + STR0137 + " XF." + cCtrl //"Se insertaron " # " registros para " # "Catálogo de Tipos de Retenciones" # " en la tabla genérica "
	Else
		cAviso += STR0141 + cPath + cAuxArch + cCtrl //"No se encontró el archivo" 	
	EndIf 	
    
	//"Tipos de Contribuyentes"
	cAuxArch := "02TiposContribuyentes.csv"
	If File(cPath + cAuxArch)
		Processa( {|| nRegProc := F925ImpArq(cPath + cAuxArch,2,"XG")},STR0130,STR0134, .T. ) //"Procesando..." # "Catálogo de Tipos de Contribuyentes"
		cAviso += STR0132 + Alltrim(Str(nRegProc)) + STR0133 + STR0134 + STR0137 + " XG." + cCtrl //"Se insertaron " # " registros para " # "Catálogo de Tipos de Contribuyentes"
	Else
		cAviso += STR0141 + cPath + cAuxArch + cCtrl //"No se encontró el archivo" 	
	EndIf 	
	
	//"Paises"
	cAuxArch := "03PaisesRetencion.csv"
	If File(cPath + cAuxArch)
		Processa( {|| nRegProc := F925ImpArq(cPath + cAuxArch,3,"XH")},STR0130,STR0135, .T. ) //"Procesando..." # "Catálogo de Paises"
		cAviso += STR0132 + Alltrim(Str(nRegProc)) + STR0133 + STR0135 + STR0137 + " XH." + cCtrl //"Se insertaron " # " registros para " # "Catálogo de Paises" # " en la tabla genérica "
	Else
		cAviso += STR0141 + cPath + cAuxArch + cCtrl //"No se encontró el archivo" 	
	EndIf 	
	
	//"Tipos de Impuestos"
	cAuxArch := "04TiposImpuestoRet.csv"
	If File(cPath + cAuxArch)
		Processa( {|| nRegProc := F925ImpArq(cPath + cAuxArch,4,"XI")},STR0130,STR0136, .T. ) //"Procesando..." # "Catálogo de Tipos de Impuestos"
		cAviso += STR0132 + Alltrim(Str(nRegProc)) + STR0133 + STR0136 + STR0137 + " XI." + cCtrl //"Se insertaron " # " registros para " # "Catálogo de Tipos de Impuestos" # " en la tabla genérica "
	Else
		cAviso += STR0141 + cPath + cAuxArch + cCtrl //"No se encontró el archivo " 
	EndIf 	
	
	If !Empty(cAviso)
		MsgInfo(cAviso,STR0015) //"Atención"
	EndIf	
Return Nil

/*/{Protheus.doc} F925ImpArq
Llendado de tablas genericas Tipos de Retenciones (XF), 
Tipos de Contribuyentes (XG), Países (XH) y Tipos de Impuestos (XI).
@type function
@author luis.enriquez
@since 13/05/2020
@version 1.0
/*/
Static Function F925ImpArq(cArchivo,nOpc,cTabla) 
	Local nFor     := 0
	Local nReg     := 0
	
	Default cArchivo := ""
	Default nOpc     := 0
	Default cTabla   := ""   

	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	SX5->(dbGoTop())

	If !MsSeek(xFilial("SX5") + cTabla) 
		nHandle := FT_FUse(cArchivo)
		If nHandle != -1
	
			FT_FGoTop()
			nFor := FT_FLastRec()
			ProcRegua(nFor)
			
			While !FT_FEOF()
				aLinea := {}
				aLinea := Separa(FT_FREADLN(),"|")
				
				IncProc(Alltrim(cTabla) + "-" + Alltrim(aLinea[2]))
				
				If  Empty(aLinea)
					FT_FSKIP() 
					Loop
				EndIf 		
				
				Begin Transaction	
					RecLock("SX5",.T.)
						X5_FILIAL  := Space(Len(SX5->X5_FILIAL))
						X5_TABELA  := cTabla
						X5_CHAVE   := aLinea[1]
						X5_DESCSPA := aLinea[2]
						X5_DESCENG := aLinea[2]
						X5_DESCRI  := aLinea[2]
						nReg += 1
					MsUnLock()				
				End Transaction						
				
				FT_FSKIP()
			EndDo
			FT_FUSE()
		Else
			MsgAlert(STR0138 + " " + cArchivo) //"No se puede leer el archivo"	
		EndIf	 
	EndIf                          
Return nReg

