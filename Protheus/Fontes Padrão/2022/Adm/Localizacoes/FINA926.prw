#include "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#Include "RPTDEF.CH"
#include "FINA926.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³FINA926   ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Cancelacion de Retenciones e Informacion de Pagos          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FINA925                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                         ACTUALIZACIONES                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha    ³ Comentario                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo   ³13/12/2016³Mod func OBTUUIDRET por uso FWTemporaryTable    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINA926()
Local aArea    := GetArea()
Local aSays			:={} 
Local aButtons	   	:={}
Local cPerg			:= "FINA926"
Local nOpca			:=  0

Private aTmpArea    	:= {}  
Private aVendors     := {}
Private dFchIni      := CTOD("")
Private dFchFin      := CTOD("")
Private lFiltrar     := .F.
Private cRutaXML     := ""
Private cFechCanc    := ""
Private oTmpTable	  := Nil
	
	If !VldSIX()
		MsgAlert(STR0026)
		Return
	EndIf
	
	Pergunte( cPerg, .F. )
	aAdd(aSays,OemToAnsi( STR0001) ) 
	aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{ |o| IIf(ParamOK(),(nOpcA := 1, o:oWnd:End()),) }} )
	aAdd(aButtons, { 2,.T.,{ |o| nOpca := 2,o:oWnd:End() }} )             
	FormBatch( oemtoansi(STR0002), aSays , aButtons )

	If nOpca == 1
		aVendors  := GetVendor(MV_PAR01)
		dFchIni   := MV_PAR02
		dFchFin   := MV_PAR03
		lFiltrar  := IIf(MV_PAR04 == 1, .T., .F.)
		cRutaXML  := Alltrim(MV_PAR05)
		ObtUUIDRet()
        If oTmpTable <> Nil
		    oTmpTable:Delete()
        EndIF
	EndIf

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ObtUUIDRet³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Monta pantalla con los folios fiscales                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtUUIDRet()
Local cOrdAnt    := ""
Local cQuery     := ""
Local aCampos    := {} // Crea estructura
Local aCpos      := {} // Crea encabezado
Local nTB        := 0
Local nTR        := 0 
Local nDe        := 0
Local nRe        := 0 
Local nI         := 0

Private cMarcaTR  := ""
Private cCadastro := ""
Private cArqTRB   := CriaTrab(Nil, .F.)
Private cArqTmp   := ""
Private lInverte  := .F.
Private aRotina   := ""
	
	// Estructura tabla temporal
	AADD(aCampos,{ "MARK",        "C", 2,  0 })
	AADD(aCampos,{ "FILIAL",      "C", TamSX3("EK_FILIAL")[1],  TamSX3("EK_FILIAL")[2] })
	AADD(aCampos,{ "PROVEEDOR",   "C", TamSX3("EK_FORNECE")[1], TamSX3("EK_FORNECE")[2] })
	AADD(aCampos,{ "SUCURSAL",    "C", TamSX3("EK_LOJA")[1],    TamSX3("EK_LOJA")[2] })
	AADD(aCampos,{ "NOMBRE",      "C", TamSX3("A2_NOME")[1],    TamSX3("A2_NOME")[2] })
	AADD(aCampos,{ "TIMBRADO",    "D", TamSX3("EK_FECTIMB")[1], TamSX3("EK_FECTIMB")[2] })
	AADD(aCampos,{ "UUID",        "C", TamSX3("EK_UUID")[1],    TamSX3("EK_UUID")[2] })
	AADD(aCampos,{ "XML",		  "C", TamSX3("EK_XMLRET")[1],  TamSX3("EK_XMLRET")[2] })
	AADD(aCampos,{ "PERIODO",  	  "C", 10,  0 })
	AADD(aCampos,{ "CANCELADO",   "D", TamSX3("EK_FECANTF")[1],  TamSX3("EK_FECANTF")[2] })
	
	 cArqTmp  := CriaTrab(aCampos, .F.)
	
	// Estructura encabezado
	AADD(aCpos,{ "MARK",       "", "" })
	AADD(aCpos,{ "FILIAL",     "", OemToAnsi(STR0025) })
	AADD(aCpos,{ "PROVEEDOR",  "", OemToAnsi(STR0006) })
	AADD(aCpos,{ "SUCURSAL",   "", OemToAnsi(STR0007) })
	AADD(aCpos,{ "NOMBRE",     "", OemToAnsi(STR0008) })
	AADD(aCpos,{ "TIMBRADO",   "", OemToAnsi(STR0009) })
	AADD(aCpos,{ "UUID",       "", OemToAnsi(STR0010) })
	AADD(aCpos,{ "PERIODO",    "", OemToAnsi(STR0012) })
	AADD(aCpos,{ "CANCELADO",  "", OemToAnsi(STR0015) })
		
	cQuery:= " SELECT DISTINCT(SEK.EK_UUID), SEK.EK_FORNECE, SEK.EK_LOJA, SEK.EK_FECTIMB, SEK.EK_FECANTF, SEK.EK_XMLRET, SA2.A2_NOME, SEK.EK_FILIAL"
	cQuery+= " FROM " + RetSqlName("SEK") + " SEK, " + RetSqlName("SA2") + " SA2"
	cQuery+= " WHERE SEK.EK_FORNECE = SA2.A2_COD AND SEK.EK_LOJA = SA2.A2_LOJA AND"
	cQuery+= " ("
	For nI := 1 To Len(aVendors)
		cQuery+= " (SEK.EK_FORNECE = '" + Alltrim(aVendors[nI][1]) + "'" 
		cQuery+= " AND SEK.EK_LOJA = '" + Alltrim(aVendors[nI][2]) + "')"
		If nI != Len(aVendors)
			cQuery+= " OR"
		EndIf
	Next
	cQuery+= " ) AND SEK.EK_FECTIMB BETWEEN '" + DTOS(dFchIni) + "' AND '" + DTOS(dFchFin) + "'"
	cQuery+= " AND SEK.EK_CANCEL = 'F' "
	cQuery+= " AND SEK.EK_UUID <> '' "
	cQuery+= " AND SEK.D_E_L_E_T_ <> '*'"
	cQuery+= " AND SA2.D_E_L_E_T_ <> '*'"
	If lFiltrar
		cQuery+= " AND SEK.EK_FECANTF = ''"
	EndIf
	cQuery+= " ORDER BY SEK.EK_FORNECE, SEK.EK_LOJA, SEK.EK_FECTIMB DESC"
	cQuery:= ChangeQuery(cQuery)
	MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cArqTRB, .F., .T.)},OemToAnsi(STR0014),OemToAnsi(STR0013))

	oTmpTable := FWTemporaryTable():New(cArqTmp) 		// MC
	oTmpTable:SetFields(aCampos)						// MC	
	oTmpTable:AddIndex("IN1", {"FILIAL","PROVEEDOR","SUCURSAL","UUID"}) //MC
	oTmpTable:Create()	// MC
	
	ProcRegua((cArqTRB)->(RecCount()))
	While !(cArqTRB)->(EOF())
		IncProc(STR0014)	
		
		Reclock((cArqTmp),.T.)
			(cArqTmp)->FILIAL     := (cArqTRB)->EK_FILIAL
			(cArqTmp)->PROVEEDOR  := (cArqTRB)->EK_FORNECE
			(cArqTmp)->SUCURSAL   := (cArqTRB)->EK_LOJA
			(cArqTmp)->NOMBRE     := (cArqTRB)->A2_NOME
			(cArqTmp)->TIMBRADO   := STOD((cArqTRB)->EK_FECTIMB)
			(cArqTmp)->UUID       := (cArqTRB)->EK_UUID
			(cArqTmp)->PERIODO    := ObtPeriodo(Alltrim((cArqTRB)->EK_XMLRET))
			(cArqTmp)->CANCELADO  := STOD((cArqTRB)->EK_FECANTF)
			(cArqTmp)->XML        := (cArqTRB)->EK_XMLRET
		MsUnlock()
		
		(cArqTRB)->(DBsKIP())			
	EndDo
	
	aRotina := MenuDef()
	cMarcaTR := GetMark()
	MarkBrow(cArqTmp,"MARK","CANCELADO",aCpos,,cMarcaTR,,,,,Nil )
	
	aAdd ( aTmpArea , cArqTmp )
	aAdd ( aTmpArea , cArqTRB ) 	
Return

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

		aRotina := {{ OemToAnsi(STR0016),'Processa({ || CanUUIDRet() })',0 ,1 }}
		
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³CanUUIDRet³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Procesa los folios fiscales seleccionados                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CanUUIDRet()
Local aRetCanc := {}

	dbSelectArea(cArqTmp)
	(cArqTmp)->(dbGoTop())	
	ProcRegua(Reccount())
	Do While !(cArqTmp)->(EOF())
		IncProc()
		If IsMArk("MARK",cMarcaTR,lInverte)
			aAdd(aRetCanc, {Alltrim((cArqTmp)->XML), Alltrim((cArqTmp)->UUID), "", (cArqTmp)->FILIAL, (cArqTmp)->PROVEEDOR, (cArqTmp)->SUCURSAL})
		EndIf
		
		RecLock(cArqTmp, .F.)
		Replace MARK With ""
		MsUnLock()
		(cArqTmp)->(dbSkip())
	EndDo
	
	If Len(aRetCanc) > 0
		XmlCancRet(cRutaXML, aRetCanc)
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³XmlCancRet³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Cancelacion de los folios fiscales                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function XmlCancRet( cRutaSrv , aRecibos )
Local aArea    := GetArea()
Local cRutaSmr := &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))	// Ruta donde reside el ejecutable de timbrado
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
Local cLogWS   := SuperGetmv( "MV_CFDILOG" , .F. , "LOG" )					// Tipo de log en consumo del servicio web: LOG (default), LOGDET (detallado), NOLOG (ninguno)
Local cRutaCFDI:= cRutaSmr + "Recibos\"
Local cNameCFDI:= ""
Local cParametros := ""
Local cRutina  := "Timbrado" + Trim(cCFDiPAC) + ".exe "
Local cPatron  := ""
Local cIniFile := "TimbradoCFDi.ini"
Local cBatch   := "Timbrado.bat"
Local nHandle  := 0
Local cProxy   := "[PROXY]"
Local nLoop    := 0
Local nOpc     := 0
Local lDeMenu  := ( ( Alltrim(FunName()) == "CANCTFD" ) .Or. !( Alltrim(FunName()) == "RPC" ) )
Local aVacio   := {}
Local cResultado := ""
Local aAreaSEK := SEK->(GetArea())
Local nIndice  := SEK->(RETORDEM("SEK","EK_FILIAL+EK_FORNECE+EK_LOJA+EK_UUID"))

	DbSelectArea("SEK")
	SEK->(DbSetORder(nIndice))
	
	If Len( aRecibos ) < 1 .Or. Len( aRecibos[1] ) < 3
		Return aVacio
	Endif

	If Empty(cRutaSrv) .Or. Empty(cRutaSmr) .Or. Empty(cCFDiUsr) .Or. Empty(cCFDiCon) .Or. Empty(cCFDiPAC) .Or. ;
	   Empty(cCFDiPub) .Or. Empty(cCFDiPri) .Or. Empty(cCFDiCve)
		If lDeMenu
			Aviso( STR0003 , STR0023, {STR0004} )  //Existen parámetros sin definir del proceso de timbrado.
		Else
			Conout( ProcName(0) + ": " + STR0023 )
		Endif
		Return aVacio
	Endif

	// Valida ruta de alojamiento del ejecutable de timbrado
	If !( cRutaSmr == Strtran( cRutaSmr , " " ) )
		If lDeMenu
			Aviso( STR0010 , STR0022, {STR0012} )  //La ruta del ejecutable de timbrado no es válida
		Else
			Conout( ProcName(0) + ": " + STR0022 )
		Endif
		Return aVacio
	Endif


	If !File( cRutaSmr + cRutina )
		If lDeMenu
			Aviso( STR0003 , STR0021 + " " + cRutaSmr + cRutina, {STR0004} )  //No existe el ejecutable para acceder al servicio web:
		Else
			Conout( ProcName(0) + ": " + STR0021 + " " + cRutaSmr + cRutina )
		Endif
		Return aVacio
	Endif

	nHandle	:= FCreate( cRutaSmr + cIniFile )

	If nHandle == -1
		If lDeMenu
			Aviso( STR0003 , STR0020 + cRutaSmr, {STR0004} )  //"No es posible crear archivo temporal en la ruta " + cRutaSmr
		Else
			Conout( ProcName(0) + ": " + STR0020 + cRutaSmr )
		Endif
		Return aVacio
	Endif

	If lDeMenu
		ProcRegua( Len(aRecibos) )
	Endif

	FWrite( nHandle, "[RECIBOS]" + CRLF )

	// Copiar archivos .xml del servidor a la ruta del smartclient o la establecida (StartPath...\CFD\RECIBOS\xxx...xxx.XML a x:\totvs\protheusroot\bin\smartclient)
	MakeDir( cRutaCFDI )
	
	For nLoop := 1 to Len( aRecibos ) 
		cNameCFDI := aRecibos[nLoop , 1 ]
	
		If File( cRutaCFDI + cNameCFDI )
			FErase( cRutaCFDI + cNameCFDI )
		Endif
	
		If File( cRutaCFDI + cNameCFDI + ".out" )
			FErase( cRutaCFDI + cNameCFDI )
		Endif
	
		CpyS2T( cRutaSrv + cNameCFDI , cRutaCFDI )
	
		FWrite( nHandle, cNameCFDI + CRLF )
	
		If lDeMenu
			IncProc()
		Endif
	Next nLoop

	fClose( nHandle )

	// Parámetros para el Proxy Server
	cProxy += "[" + If( lProxySr , "1" , "0" ) + "]"
	cProxy += "[" + cProxyIP + "]"
	cProxy += "[" + lTrim( Str( nProxyPt ) ) + "]"
	cProxy += "[" + If( lProxyAW , "1" , "0" ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyUr ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyPw ) + "]"
	cProxy += "[" + If( lProxyAW , "" , cProxyDm ) + "]"
	
	// parametros: PAC, Usuario, Password, Factura.xml, Ambiente,
	cParametros := cCFDiUsr + " " + cCFDiCon + " " + cIniFile + " " +cCFDiAmb +  " " 
	//             Archivo.cer, Archivo.key, ClaveAutenticacion, UUID, Timbrar/Cancelar
	cParametros += cCFDiPub + " " + cCFDiPri + " " + cCFDiCve + " . C "
	//			   Proxy, log
	cParametros += cProxy + " " + cLogWS
	
	If nCFDiCmd < 0 .Or. nCFDiCmd > 10
		nCFDiCmd := 0
	Endif
	
	If nCFDiCmd == 3 .Or. nCFDiCmd == 10
		nHandle	:= FCreate( cRutaSmr + cBatch )
		If nHandle == -1
			If lDeMenu
				Aviso( STR0003 , STR0020 + cRutaSmr, {STR0004} )  //"No es posible crear archivo temporal en la ruta " + cRutaSmr
			Else
				Conout( ProcName(0) + ": " + STR0020 + cRutaSmr )
			Endif
			Return aVacio
		Endif
		
		FWrite( nHandle, cRutaSmr + cRutina + Trim(cParametros) + CRLF )
		FWrite( nHandle, "Pause" + CRLF )
		fClose( nHandle )
		nOpc := WAITRUN( cRutaSmr + cBatch, nCFDiCmd )
	
	Else
		// Ejecuta cliente de servicio web
		nOpc := WAITRUN( cRutaSmr + cRutina + Trim(cParametros), nCFDiCmd )	// SW_HIDE
	Endif
	
	If lDeMenu
		ProcRegua(Len(aRecibos))
	Endif
	
	For nLoop := 1 to Len( aRecibos )
		If lDeMenu
			IncProc( STR0019 + Alltrim(Str(nLoop)) + "/" + Alltrim(Str(Len(aRecibos))) ) // Verificando cancelación de timbres fiscales de recibos...
		Endif
	
		cNameCFDI := aRecibos[nLoop , 1 ]
	
		If nOpc == 0 .And. File( cRutaCFDI + cNameCFDI + ".out" )
			cResultado := ""
			If ChecaCancTF(cRutaCFDI + cNameCFDI + ".out", @cResultado)
				If SEK->(DbSeek(aRecibos[nLoop,4] + aRecibos[nLoop,5] + aRecibos[nLoop,6] + aRecibos[nLoop,2]))
					Do While !SEK->(EOF()) .And. SEK->(EK_FILIAL+EK_FORNECE+EK_LOJA+EK_UUID) == aRecibos[nLoop,4] + aRecibos[nLoop,5] + aRecibos[nLoop,6] + aRecibos[nLoop,2]
						If SEK->(RecLock("SEK", .F.))
							Replace SEK->EK_FECANTF With IIf(cFechCanc <> "", STOD(cFechCanc), Date())
							SEK->(MsUnlock())
						EndIf
						SEK->(dbSkip())
					EndDo
				EndIf
				dbSelectArea(cArqTmp)
				If (cArqTmp)->(dbSeek(aRecibos[nLoop,4] + aRecibos[nLoop,5] + aRecibos[nLoop,6] + aRecibos[nLoop,2]))
					If (cArqTmp)->(RecLock(cArqTmp, .F.))
						Replace (cArqTmp)->CANCELADO With IIf(cFechCanc <> "", STOD(cFechCanc), Date())
						(cArqTmp)->(MsUnlock())
					EndIf
				EndIf
				cMensaje := ""
				//Copiar respuesta del WS al servidor
				Frename( cRutaCFDI + cNameCFDI + ".out" , cRutaCFDI + cNameCFDI + ".canc" )
				CpyT2S(cRutaCFDI + cNameCFDI + ".canc" , cRutaSrv)
			Else
				cMensaje := If( Empty(cResultado) , STR0018 , cResultado )
			Endif
	
		Else
			cMensaje := STR0017
		Endif
	
		aRecibos[ nLoop , 3 ] := cMensaje
	
		If !lDeMenu .And. !Empty( cMensaje )
			Conout( ProcName(0) + ": " + cMensaje + " " + cNameCFDI )
		Endif
	
		// Eliminar temporales
		Ferase( cRutaCFDI + cNameCFDI )
		Ferase( cRutaCFDI + cNameCFDI + ".out" )
		Ferase( cRutaCFDI + cNameCFDI + ".canc" )
	Next nLoop
	
	GrabaLog( cRutaSmr + "Errores\", aRecibos )
	
	SEK->(RestArea(aAreaSEK))
	RestArea(aArea)

Return aRecibos

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

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03) .Or. Empty(MV_PAR04) .Or. Empty(MV_PAR05)
			Aviso( OemToAnsi(STR0003), OemToAnsi(STR0005), {STR0004} )
			lOK := .F.
	EndIf
Return lOK

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³GetVendor ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Proveedores seleccionados                                  ³±±
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa    ³ObtPeriodo  ³ Autor ³ Luis Samaniego      ³ Fecha ³21/05/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³Periodos                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtPeriodo(cNomXML)
Local nloop    := 0
Local cPeriodo := "" 

	If subStr(cNomXML,len(cNomXML),1) != "_"
		cNomXML += "_"
	EndIf

	If cNomXML != "_"
		For nloop := 1 to len(cNomXML)
			If Alltrim(Str(nLoop)) $ "3|4"
				cPeriodo += Strzero(Val(Alltrim(Substr(cNomXML,1,At("_",cNomXML)-1))), 2) + " "
			ElseIf Alltrim(Str(nLoop)) $ "5"
				cPeriodo += Strzero(Val(Alltrim(Substr(cNomXML,1,At("_",cNomXML)-1))), 4) + " "
			EndIf
			cNomXML := Substr(cNomXML,At("_",cNomXML)+1,Len(cNomXML)-at("_",cNomXML))
			If  Len(cNomXML) == 0
				Exit
			EndIf
		Next nloop
	EndIF
	
	cPeriodo := Alltrim(cPeriodo)
Return cPeriodo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ GrabaLog ³ Autor ³ Alberto Rodriguez    ³ Fecha³ 09/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Graba log de recibos no timbrados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ GrabaLog( cRuta , aRecibos )                              ³±±
±±³           ³ [x,1] - Nombre del archivo xml                            ³±±
±±³           ³ [x,3] - mensaje de error                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ XmlCancRet                                                ³±±
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
			If !Empty( aRecibos[nLoop,3] )
				FWrite(nHandle, aRecibos[nLoop,1] + " " + aRecibos[nLoop,3] + CRLF)
			Endif
		Next
	
		FClose(nHandle)
		lRet := .T.
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ChecaCancTF ºAutor  ³ Alberto Rodriguez  º Data ³  18/08/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrip.  ³ Valida si el timbre fiscal se canceló                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ ChecaCancTF( cArchivo , @cMensaje)                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ XmlCancRet()		 	                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ChecaCancTF( cFile , cResultado )
Local nHandle 	:= 0
Local aInfoFile	:= {}
Local nSize		:= 0
Local nRegs		:= 0
Local nFor		:= 0
Local cBuffer	:= ""
Local cLine		:= ""
Local cString	:= ""
Local lRet      := .F.

	Begin Sequence
	   	nHandle := fOpen(cFile)
	
		If  nHandle <= 0
			cResultado := STR0024  //"No fue posible abrir el archivo .out"
			Break
		EndIf
	
		aInfoFile := Directory(cFile)
		nSize := aInfoFile[ 1 , 2 ]
		nRegs := Int(nSize/2048)
	
		For nFor := 1 to nRegs
			fRead( nHandle , @cBuffer , 2048 )
			cLine += cBuffer
		Next
	
		If nSize > nRegs * 2048
			fRead( nHandle , @cBuffer , (nSize - nRegs * 2048) )
			cLine += cBuffer
		Endif
	
		fClose(nHandle)
	End Sequence

	If Substr(cLine,1,1) == "("
		cLine := Substr(cLine,2)
		cLine := Strtran( cLine , ")" , " " , 1 , 1 )
	EndIF

	cBuffer := Upper(cLine)

	If ( "UUID CANCELADO" $ cBuffer ) .Or. ( "STATUSUUID>201" $ cBuffer ) .Or. ( "STATUSUUID>202" $ cBuffer ) .Or. ;
		( "SE REPORTARA" $ cBuffer .And. "CANCELADO" $ cBuffer) .Or. ( "PREVIAMENTE" $ cBuffer .And. "CANCELADO" $ cBuffer) .Or. ("CON EXITO" $ cBuffer)
		lRet := .T.
		GetFecha(cBuffer) 
	Else
		cString	:= Substr( cLine , 1 , 4 )
		If Empty(cLine) .Or. ( "ERROR" $ cBuffer ) .Or. ( "FAILED" $ cBuffer ) .Or. ( "FAIL " $ cBuffer ) .Or. ( "EXCEPTION" $ cBuffer ) .Or. ; 
		( "EXCEPCION" $ cBuffer ) .Or. ( "EXCEPCIóN" $ cBuffer ) .Or. ( "EXCEPCIÓN" $ cBuffer )  .Or. ( Val(cString) > 0 ) .Or. ;
		( "CANCELED" $ cBuffer .And. "FALSE" $ cBuffer ) .Or. ("NO DECLARADA" $ cBuffer)
			// Error 
		Else
			lRet := .T.
		Endif
	Endif

	cResultado := Alltrim(cLine)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GetFecha    ºAutor  ³ Alberto Rodriguez  º Data ³  18/08/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrip.  ³ Valida si el timbre fiscal se canceló                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ ChecaCancTF( cArchivo , @cMensaje)                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ChecaCancTF()                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetFecha(cXml) 
Local nPosFc := At( "FECHA" , cXml)
Local nPosDt := At( "DATE" , cXml)
	
	cFechCanc:= ""
	
	If nPosFc > 0
		cFechCanc := Strtran(Substr(cXml,nPosFc+ 7,10),"-")
	ElseIf nPosDt > 0
		cFechCanc := Strtran(Substr(cXml,nPosDt+ 6,10),"-")		
	EndIf
	
Return

Static function VldSIX()
Local lSIX := .T.
	If RETORDEM("SEK","EK_FILIAL+EK_FORNECE+EK_LOJA+EK_UUID") <= 1
		lSIX := .F.
	EndIf
Return lSIX
