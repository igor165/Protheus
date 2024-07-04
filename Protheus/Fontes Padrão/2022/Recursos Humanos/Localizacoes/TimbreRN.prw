#include "TimbreRN.ch"
#include "protheus.ch"
#include "rwmake.ch"
#include "shell.ch"
#include "xmlxfun.ch"
#include "fileio.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n  �TimbreRecNom� Autor � Alberto Rodriguez    � Fecha� 17/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Timbrado de CFDi con complemento de recibo de n�mina      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxis   � TimbreRecNom()  		                                  ���
�������������������������������������������������������������������������Ĵ��
���        ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ���
�������������������������������������������������������������������������Ĵ��
���Programador � Fecha  �Llamado� Motivo de la Actualizaci�n              ���
�������������������������������������������������������������������������Ĵ��
���Alberto Rdz �04/03/14�TIJRXZ �"CFDi:Error" en WS de Tralix             ���
���Alberto Rdz �24/03/14�       �Respetar ruta del parametro MV_CFDRECN   ���
���L Samaniego �25/04/14�TPJTSG �Se modifico para que se permita reimpri- ���
���            �        �       �mir los recibos de nomina, aunque ya     ���
���            �        �       �esten timbrados.                         ��� 
���L Samaniego �28/04/14�TPJTSG �Cambio en funcion ValidaRecibo()         ���
���            �        �       �1- Timbrado, 2- No timbrado, 3- Con error���
���L Samaniego �06/05/14�TPLOPZ �Se modifica para mostrar barra de avance.���
���            �        �       �                                         ���
���Marco A Glez�13/05/19�DMINA- �Se agrega punto de entrada G884GENTAB,   ���
���            �        � 6526  �para el llenado de una tabla de usuario, ���
���            �        �       �con informacion correspondiente a recibos���
���            �        �       �de nomina timbrados.                     ���
���Ver�nica F. �16/12/20�DMINA- �Se modifica la funci�n TimbreRecNom()    ���
���            �        �10662  �para que ya no realice el guardado del   ���
���            �        �       �archivo XXXX_original.xml                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TimbreRecNom()
Local cRutaXML		:= &(SuperGetmv( "MV_CFDRECN" , .F. , "'cfd\recibos\'" ))
Local cRutaLog		:= &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" )) + "Errores\"
Local cDeFil		:= ""
Local cAFil			:= ""
Local cDeMat		:= ""
Local cAMat			:= ""
Local nLenPat		:= 0
Local nLenMat		:= 0
Local aTimbrar		:= {}
Local nTimbres		:= 0
Local nErrores		:= 0
Local cMensaje		:= ""
Local nLoop			:= 0
Local lRet			:= .F. 
Local aRecibos		:= {}
Local aParam		:= {}
Local aRecXML		:= {}

//Variables utilizadas en el nuevo proceso de  cancelaci�n
Local cNomCFDCan	:= ""
Local aRecACance	:= {}
Local cDirACance	:= cRutaXML + "cancelar\" //Directorio que almacena los recibos pendientes a cancelar antes el SAT
Local nIteracion	:= 0
Local cNameCFDI		:= ""
Local cUUIDRelac	:= ""
Local nRecCancel	:= 0
Local nErrRecCan	:= 0
Local nRecnoRecC	:= 0

Private nLenFil		:= 0
Private cPatron		:= ""
Private aLog		:= {}

Private cUUID		:= ""
Private cFechaTim	:= ""
Private cRFCTim		:= ""   
Private cTotalTim	:= ""

// Utilizar grupo de preguntas de recibos de n�mina (IMPRECXML) para obtener la lista de archivos a procesar
//Pergunte("IMPRECXML", .F. )	// Comentar en la liberaci�n

cPatron := Trim(MV_PAR01)	// Proceso
cPatron += Trim(MV_PAR02)	// Procedimiento
cPatron += Trim(MV_PAR03)	// Periodo
cPatron += Trim(MV_PAR04)	// Numero de pago
cDeFil  := Trim(MV_PAR06)	// De filial
cAFil   := Trim(MV_PAR07)	// A filial
cDeMat  := Trim(MV_PAR08)	// De matricula
cAMat   := Trim(MV_PAR09)	// A matricula

nLenPat := Len(cPatron)
nLenFil := Len( xFilial("SRA") )

aRecibos := aClone(aArchivos)

If Len( aRecibos ) == 0
	Aviso( OemToAnsi(STR0001), OemToAnsi(STR0003), {STR0002})  // No se enontraron recibos para timbrar
Else
	ProcRegua(Len(aRecibos))
	For nLoop := 1 to Len(aRecibos)
		If aRecibos[nLoop] <> NIL
			aRecibos[nLoop,1]+=".xml"
			IncProc(STR0019) //"Preparando recibos para timbrar... "
			nLenMat := Rat( ".xml" , Lower(aRecibos[nLoop,1]) ) - At( "_" , aRecibos[nLoop,1] ) -  nLenFil - 1
			If (Substr(aRecibos[nLoop,1], nLenPat + 2 , nLenFil) >= cDeFil .And. Substr(aRecibos[nLoop,1], nLenPat + 2 , nLenFil) <= cAFil ) .And. (Substr(aRecibos[nLoop,1], nLenPat + 2 + nLenFil , nLenMat) >= cDeMat .And. Substr(aRecibos[nLoop,1], nLenPat + 2 + nLenFil , nLenMat ) <= cAMat ) .And. !("_original" $ Lower(aRecibos[nLoop,1]))
				//Se modifica la validaci�n para informar recibos timbrados o no timbrados.
				If !ValidaRecibo( cRutaXML + aRecibos[nLoop,1], aRecXML) .And. AT("ORIGINAL",aRecibos[nLoop,1]) == 0 
					/*
					 * 1 = Nombre XML.
					 * 2 = Contiene timbrado o error encontrado.
					 * 3 = UUID Relacionado
					 * 4 = Error en cancelaci�n
					 */
					aAdd( aTimbrar , { aRecibos[nLoop,1] , "", "" , ""} )
				Else
					aAdd( aLog , { aRecibos[nLoop,1] , 1} )
				EndIf
			Endif
		EndIf
	Next nLoop

	If Len( aTimbrar ) == 0
		Aviso( OemToAnsi(STR0001), OemToAnsi(STR0003), {STR0002})  // No se encontraron recibos para timbrar
	Else
		lRet := CFDiRecNom( aTimbrar )
		aEval(aTimbrar, {|x, y| IIf( Empty(x[2]) .Or. Substr(x[2], 1, 1 ) == "*", ++nErrores, ++nTimbres)})

		If lPEGenTab
			aParam := {cProcesso, cRoteiro, cPeriodo, Semana, aTimbrar}
			ExecBlock("G884GENTAB", .F., .F., aParam)
		EndIf

		If nTimbres > 0 .And. lEnvCanAnt .And. lSusRecAnt

			For nIteracion := 1 To Len(aTimbrar)
				If aTimbrar[nIteracion][2] == "Timbrado"
					cNameCFDI 	:= aTimbrar[nIteracion][1]
					cUUIDRelac	:= aTimbrar[nIteracion][3]

					nRecnoRecC := FGetRIWRco(cUUIDRelac)

					If nRecnoRecC > 0
						//Se obtiene nombre de XML a Cancelar.
						cNomCFDCan := SubStr(cNameCFDI, 1, AT(".", cNameCFDI) - 1) + "_" + AllTrim(Str(nRecnoRecC)) + ".XML"
						
						//Se forma arreglo para cancelaci�n.
						aAdd(aRecACance, {cNomCFDCan, cUUIDRelac, ""})
					EndIf
				EndIf

			Next nIteracion

			If Len(aRecACance) > 0
				CancTimbreRN(cDirACance, aRecACance)
			EndIf

			aEval(aRecACance, {|x, y| IIf( !Empty(x[3]), ++nErrRecCan, ++nRecCancel)})

		EndIf
		
		If nTimbres == 0
			cMensaje += STR0004 + CRLF  //"No se timbr� ning�n recibo."
		ElseIf nTimbres == 1
			cMensaje += STR0005 + CRLF	// "Se gener� 1 timbre fiscal."
		ElseIf nTimbres > 1
			cMensaje += Strtran(STR0006, "#nTimbres#", lTrim(Str(nTimbres))) + CRLF //"Se generaron #nTimbres# timbres fiscales."
		Endif
		If nErrores > 0
			cMensaje += Strtran(STR0015, "#nErrores#", lTrim(Str(nErrores))) + CRLF // Se obtuvieron #nErrores# recibos con problemas.
		Endif
		
		If lSusRecAnt .And. lEnvCanAnt //Si se seleccion� cancelar y sustituir recibos anteriores
			If nRecCancel == 0
				cMensaje += STR0022 + CRLF  //"No se anularon timbres fiscales."
			ElseIf nRecCancel == 1
				cMensaje += STR0023 + CRLF	//"Se anul� 1 timbre fiscal."
			ElseIf nRecCancel > 1
				cMensaje += Strtran(STR0024, "#nRecCancel#", lTrim(Str(nRecCancel))) + CRLF //"Se anularon #nRecCancel# timbres fiscales."
			Endif
			If nErrRecCan > 0
				cMensaje += CRLF + Strtran(STR0025 + CRLF + ; //"Se obtuvieron #nErrRecCan# recibos con problemas de cancelaci�n."
				STR0026, "#nErrRecCan#", lTrim(Str(nErrRecCan))) + CRLF //"Verifique el problema y realice la cancelaci�n nuevamente desde la rutina Cancelaci�n Recibo N�mina (CANCTFD)."
			Endif
		EndIf
		
		If nErrores > 0 .Or. nErrRecCan > 0
			cMensaje += CRLF + STR0018 + CRLF + cRutaLog //"Consulte el log en la carpeta:"
		EndIf

		MsgInfo(cMensaje, STR0001) //"CFDi - Complemento N�mina"
		
		lRet := (nTimbres > 0)

	Endif

Endif

Return lRet

/*/
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o    �ValidaRecibo� Autor � Alberto Rodriguez         � Data �  18/08/14  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Valida si el CFDi est� timbrado                                    ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe   � ValidaRecibo( cArchivo )                                           ���
���������������������������������������������������������������������������������Ĵ��
���Uso       � TIMBRERN/CANCTFD/GPER884/IMPRECXML                                 ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
/*/
Function ValidaRecibo(cArchivo, aTimbre)
Local oXml			:= Nil
Local cXML			:= ""
Local cError		:= ""
Local cDetalle		:= ""
Local lRet			:= .F.
Local cFechaTimb	:= ""

Default cArchivo	:= ""
Default aTimbre		:= {}

If Substr(cArchivo,1,1) == IIf( IsSrvUnix() , "/" , "\" )
	cArchivo := Substr(cArchivo,2)
Endif

oXml := XmlParserFile( cArchivo , "", @cError, @cDetalle)

If ValType(oXml) == "O"
	SAVE oXml XMLSTRING cXML
	/*
	 * aTimbre[1] = UUID
	 * aTimbre[2] = Fecha Timbrado
	 * aTimbre[3] = Fecha/Hora Timbrado
	 * aTimbre[4] = UUID Relacionado
	 */
	aTimbre := {"", "", "", ""}

	If At( "CFDI:COMPROBANTE " , Upper(cXml) ) > 0
		aTimbre[1] := oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_NOMBRE:TEXT
		If At( "TFD:TIMBREFISCALDIGITAL " , Upper(cXml) ) > 0
			aTimbre[2] := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
			cFechaTimb := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT
			aTimbre[3] := SubStr(cFechaTimb,9,2) + "-" + SubStr(cFechaTimb,6,2) + "-" + SubStr(cFechaTimb,1,4) + " " + SubStr(cFechaTimb,12,8) //Fecha (Dia - Mes - A�o) + Hora

			If XmlChildEx(oXml:_CFDI_COMPROBANTE,"_CFDI_CFDIRELACIONADOS") <> Nil
				aTimbre[4] := oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS:_CFDI_CFDIRELACIONADO:_UUID:TEXT
			EndIf

		Endif
		lRet := !Empty(aTimbre[2])
	Endif
Endif

FreeObj(oXml)
oXml := Nil

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    �CFDiRecNom� Autor � Alberto Rodriguez    � Fecha� 17/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Timbrado de CFDi con complemento de recibo de n�mina      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxis   � CFDiRecNom( aRecibos )	                                  ���
���           � aRecibos - Lista de archivos a procesar                   ���
���           � [x,1] - Nombre del archivo xml                            ���
���           � [x,2] - Regresa UUID o mensaje de error (*)               ���
���           � [x,3] - UUID a Sustituir                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso        � TimbreRecNom    		                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CFDiRecNom( aRecibos )
Local aArea			:= GetArea()
Local cRutaSrv		:= &(SuperGetmv( "MV_CFDRECN" , .F. , "'cfd\recibos\'" ))	// Ruta donde se encuentran los recibos .xml (servidor)
Local cRutaSmr		:= &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))	// Ruta local en donde se procesar�n los archivos
Local cCFDiUsr		:= SuperGetmv( "MV_CFDI_US" , .F. , "" )						// Usuario del servicio web
Local cCFDiCon		:= SuperGetmv( "MV_CFDI_CO" , .F. , "" )						// Contrase�a del servicio web
Local cCFDiPAC		:= SuperGetmv( "MV_CFDI_PA" , .F. , "" )						// Rutina a ejecutar (PAC)
Local cCFDiAmb		:= SuperGetmv( "MV_CFDI_AM" , .F. , "T" )					// Ambiente (Teste o Produccion)
Local cCFDiPub		:= SuperGetmv( "MV_CFDI_CE" , .F. , "" )						// Archivo de llave p�blica (.cer)
Local cCFDiPri		:= SuperGetmv( "MV_CFDI_PR" , .F. , "" )						// Archivo de llave privada (.key)
Local cCFDiCve		:= SuperGetmv( "MV_CFDI_CL" , .F. , "" )						// Clave de llave privada para autenticar WS
Local nCFDiCmd		:= SuperGetmv( "MV_CFDICMD" , .F. , 0 )						// Mostrar ventana de comando del Shell: 0=no, 1=si
Local lProxySr		:= SuperGetmv( "MV_PROXYSR" , .F. , .F. )					// Emplear Proxy Server?
Local cProxyIP		:= SuperGetmv( "MV_PROXYIP" , .F. , "" )						// IP del Proxy Server
Local nProxyPt		:= SuperGetmv( "MV_PROXYPT" , .F. , 0 )						// Puerto del Proxy Server
Local lProxyAW		:= SuperGetmv( "MV_PROXYAW" , .F. , .F. )					// Autenticaci�n en Proxy Server con credenciales de Windows?
Local cProxyUr		:= SuperGetmv( "MV_PROXYUR" , .F. , "" )						// Usuario para autenticar Proxy Server
Local cProxyPw		:= SuperGetmv( "MV_PROXYPW" , .F. , "" )						// Clave para autenticar Proxy Server
Local cProxyDm		:= SuperGetmv( "MV_PROXYDM" , .F. , "" )						// Dominio para autenticar Proxy Server
Local cRutaCFDI		:= cRutaSmr + "Recibos\"
Local cNameCFDI		:= ""
Local cRutina		:= "Timbrado" + Trim(cCFDiPAC) + ".exe "
Local cParametros	:= ""
Local cProxy		:= "[PROXY]"
Local cIniFile		:= "TimbradoCFDi_" + cPatron + ".ini" //"TimbradoCFDi.ini"
Local cBatch		:= "Timbrado_" + cPatron + ".bat" //"Timbrado.bat"
Local nHandle		:= 0
Local nLoop			:= 0
Local nOpc			:= 0
Local lRet			:= .F.
Local aAreaRIW		:= RIW->(GetArea())
Local cUUIDRel		:= ""
Local nRecnoRIW		:= 0

Private cError		:= ""  //Contiene el numero de error
Private cDetalle	:= ""  //Contiene el detalle del error, cuando el timbre no es generado
Private lDeMenu		:= ( ( Alltrim(FunName()) == "IMPRECXML" ) .Or. !( Alltrim(FunName()) == "RPC" ) )

If Empty(cRutaSrv) .Or. Empty(cRutaSmr) .Or. Empty(cCFDiUsr) .Or. Empty(cCFDiCon) .Or. Empty(cCFDiPAC)
	If lDeMenu
		Aviso( STR0001 , STR0007, {STR0002} )  // Faltan par�metros por definir para este proceso
	Else
		Conout( ProcName(0) + ": " + STR0007 )
	Endif
	Return lRet
Endif

// Valida ruta de alojamiento del ejecutable de timbrado
If !( cRutaSmr == Strtran( cRutaSmr , " " ) )
	If lDeMenu
		Aviso( STR0001 , STR0008, {STR0002} )  // La ruta del ejecutable de timbrado no es v�lida
	Else
		Conout( ProcName(0) + ": " + STR0008 )
	Endif
	Return lRet
Endif

// Verifica la existencia del EXE de WS para timbrado
If !File( cRutaSmr + Trim(cRutina) )
	If lDeMenu
		Aviso( STR0001 , STR0009 + cRutaSmr + cRutina , {STR0002} )  // No existe el cliente de servicio web: ...exe
	Else
		Conout( STR0009 + cRutaSmr + cRutina )
	Endif
	Return lRet
Endif

// Par�metros para el Proxy Server
cProxy += "[" + If( lProxySr , "1" , "0" ) + "]"
cProxy += "[" + cProxyIP + "]"
cProxy += "[" + lTrim( Str( nProxyPt ) ) + "]"
cProxy += "[" + If( lProxyAW , "1" , "0" ) + "]"
cProxy += "[" + If( lProxyAW , "" , cProxyUr ) + "]"
cProxy += "[" + If( lProxyAW , "" , cProxyPw ) + "]"
cProxy += "[" + If( lProxyAW , "" , cProxyDm ) + "]"

// Parametros obligatorios: (1)Usuario, (2)Password, (3)Factura.xml, (4)Ambiente,
cParametros := cCFDiUsr + " " + cCFDiCon + " " + cIniFile + " " +cCFDiAmb +  " " 
// otros parametros segun el PAC: (5)Archivo.cer, (6)Archivo.key, (7)ClaveAutenticacion, (8)., (9)Timbrar/Cancelar, (10)Parametros del Proxy
cParametros += cCFDiPub + " " + cCFDiPri + " " + cCFDiCve + " . T " + cProxy

// Visualizaci�n de ventana de comando
If nCFDiCmd < 0 .Or. nCFDiCmd > 10
	nCFDiCmd := 0
Endif

// Archivo .ini con la lista de CFDi a timbrar
nHandle	:= FCreate( cRutaSmr + cIniFile )

If nHandle == -1
	If lDeMenu
		Aviso( STR0001 , STR0010 + cRutaSmr, {STR0002} )  // No es posible crear archivo temporal en la ruta ...
	Else
		Conout( ProcName(0) + ": " + STR0010 + cRutaSmr )
	Endif
	Return lRet
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
	// Quitar la Addenda para realizar el timbrado
	AddendaCFDi( cRutaCFDI , cNameCFDI , "1" )

	// Permitir hacer cambios al xml antes de timbrar
	If ExistBlock( "CFDIREC1" )
		ExecBlock( "CFDIREC1" , .F. , .F. , { cRutaCFDI + cNameCFDI } )
	Endif

	FWrite( nHandle, cNameCFDI + CRLF )
Next nLoop

fClose( nHandle )

If nCFDiCmd == 3 .Or. nCFDiCmd == 10
	nHandle	:= FCreate( cRutaSmr + cBatch )
	If nHandle == -1
		If lDeMenu
			Aviso( STR0001 , STR0011 + cRutaSmr, {STR0002} )  // No es posible crear archivo de comandos en la ruta ...
		Else
			Conout( ProcName(0) + ": " + STR0011 + cRutaSmr )
		Endif
		Return lRet
	Endif

	FWrite( nHandle, cRutaSmr + cRutina + Trim(cParametros) + CRLF )
	FWrite( nHandle, "Pause" + CRLF )
	fClose( nHandle )

	nOpc := WAITRUN( cRutaSmr + cBatch, nCFDiCmd )
Else
	// Ejecuta cliente de servicio web
	nOpc := WAITRUN( cRutaSmr + cRutina + Trim(cParametros), nCFDiCmd )	// SW_HIDE
Endif

ProcRegua(Len(aRecibos))
For nLoop := 1 to Len( aRecibos )
	IncProc(STR0020 + Alltrim(Str(nLoop)) + "/" + Alltrim(Str(Len(aRecibos)))) //"Actualizando recibos con el timbre fiscal "
	cNameCFDI := aRecibos[nLoop , 1 ]

	If nOpc > 0 .Or. !File( cRutaCFDI + cNameCFDI + ".out" )
		Conout( ProcName(0) + ": " + STR0012 + cNameCFDI )
		aRecibos[ nLoop , 2 ] := "*" + STR0012
	Else
		// Copia respuesta del WS al servidor
		CpyT2S( cRutaCFDI + cNameCFDI + ".out" , cRutaSrv )

		//Validar si se genero el timbre y si es asi se debe actualizar el campo F2_TIMBRE
		If LeeXMLOut( cRutaSrv, cRutaCFDI, cNameCFDI, @cError, @cDetalle, @cUUIDRel)
		
			If RIW->(FieldPos("RIW_UUID")) > 0
				If RIW->(RecLock( "RIW" , .T.)) 
					RIW->RIW_FILIAL	:= Substr(cNameCFDI, At( "_" , cNameCFDI) +1, nLenFil)
					RIW->RIW_PROCES	:= Trim(MV_PAR01)
					RIW->RIW_ROTEIR	:= Trim(MV_PAR02)
					RIW->RIW_NUMPAG	:= Trim(MV_PAR04)
					RIW->RIW_PER 	:= Trim(MV_PAR03)
					RIW->RIW_UUID	:= cUUID
					RIW->RIW_RFC	:= cRFCTim
					RIW->RIW_VALOR	:= Val(cTotalTim)
					RIW->RIW_FECTIM := STOD(cFechaTim)
					RIW->(MSUnlock())
				EndIf
				//Actualiza el motivo en el registro a sustituir si aplica
				If lSusRecAnt
					nRecnoRIW := FGetRIWRco(cUUIDRel)
					If nRecnoRIW > 0
						RIW->(DBGoTo(nRecnoRIW))
						If RIW->(ColumnPos("RIW_MOTIVO")) .And. RIW->(ColumnPos("RIW_IDSUST"))
							RIW->(RecLock("RIW", .F.)) 
							RIW->RIW_MOTIVO := cMotivCanc //Motivo de Cancelaci�n, asignada en funci�n R030Imp() de GPER884.
							RIW->RIW_IDSUST := cUUID
							RIW->(MSUnlock())
						EndIf
					EndIf
				EndIf
				RIW->(RestArea(aAreaRIW))
			EndIf
			// Nuevo CFDi en el Remote
			Ferase( cRutaCFDI + cNameCFDI )
			Frename( cRutaCFDI + cNameCFDI + ".timbre" , cRutaCFDI + cNameCFDI )
			// Copia CFDi timbrado al servidor
			CpyT2S( cRutaCFDI + cNameCFDI, cRutaSrv )
			// Restaurar Addenda en el CFDi ya timbrado
			AddendaCFDi( cRutaSrv , cNameCFDI , "2" )
			// Permitir hacer cambios al CFDi timbrado
			If ExistBlock( "CFDIREC2" )
				ExecBlock( "CFDIREC2" , .F. , .F. , { cRutaCFDI + cNameCFDI } )
			Endif
			// Flag de proceso correcto
			aRecibos[ nLoop , 2 ] := "Timbrado"
			aRecibos[ nLoop , 3 ] := cUUIDRel //Se env�a UUID del Recibo anterior.
			lRet := .T.
		Else
			Conout( ProcName(0) + ": " + STR0013 + cNameCFDI + CRLF + cError + If( Empty(cDetalle), "", " - " ) + cDetalle )
			aRecibos[ nLoop , 2 ] := "*" + If( !Empty(cError), cError + If( Empty(cDetalle), "", " - " ) + cDetalle, STR0013)
		Endif
	Endif

	// Eliminar temporales
	Ferase( cRutaCFDI + cNameCFDI )
	Ferase( cRutaCFDI + cNameCFDI + ".out" )
Next nLoop

RestArea(aArea)

GrabaLog( cRutaSmr + "Errores\", aRecibos )

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � LeeXMLOut� Autor � Alberto Rodriguez    � Data � 18/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Valida si el archivo .OUT obtenido del WS contiene TFD    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxis   � LeeXMLOut( ruta , archivo , @error , @detalle )           ���
�������������������������������������������������������������������������Ĵ��
���Uso        � CFDiRecNom                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function LeeXMLOut(cRutaSrv, cRuta, cNombre, cError, cDetalle, cUUIDRel)
Local oXML			:= Nil
Local cXML			:= ""
Local cArchiOUT		:= cRutaSrv + cNombre + ".out"   //Archivo recibido del servicio web
Local cTimbre		:= ""
Local lRet			:= .F.
Local cFilSRA		:= xFilial("SRA")

Default cRutaSrv	:= ""
Default cRuta		:= ""
Default cNombre		:= ""
Default cError		:= ""
Default cDetalle	:= ""
Default cUUIDRel	:= ""

cUUID 		:= ""
cFechaTim 	:= ""
cRFCTim 	:= ""   
cTotalTim 	:= ""
cUUIDRel	:= ""

If Substr(cArchiOUT,1,1) == IIf( IsSrvUnix() , "/" , "\" )
	cArchiOUT := Substr(cArchiOUT,2)
Endif

oXml := XmlParserFile(cArchiOUT, "", @cError, @cDetalle )

If valType(oXml) == "O"				//Es un objeto
	SAVE oXml XMLSTRING cXML

	If AT( "ERROR" , Upper(cXML) ) > 0	// El archivo tiene errores
		If AT( "CFDI:ERROR" , Upper(cXML) ) > 0
			If 	ValType(oXml:_CFDI_ERROR) == "O"
				cError := oXml:_CFDI_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_CFDI_ERROR:_CFDI_DESCRIPCIONERROR:TEXT
			Endif
		ElseIf 	ValType(oXml:_ERROR) == "O"
			cError := oXml:_ERROR:_CODIGO:TEXT
			cDetalle := oXml:_ERROR:_DESCRIPCIONERROR:TEXT
	    Endif
	Else							// Obtener timbre
		// <ARL 14/11/2011> sefactura... <ARL 05/01/2011> Cambio (correccion) del PAC; v3.2 CFDi y v2.2 CFD
		If At( "CFDI:COMPROBANTE " , Upper(cXml) ) > 0
			// Se recibe todo el CFDi con el certificado del SAT (TFD)
			If At( "TFD:TIMBREFISCALDIGITAL " , Upper(cXml) ) > 0
				cTimbre 	:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
				cUUID	:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
				cFechaTim := Strtran(Substr(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT,1,10), "-")
				cRFCTim	:= oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RFC:TEXT   
				cTotalTim := oXml:_CFDI_COMPROBANTE:_TOTAL:TEXT

				If XmlChildEx(oXml:_CFDI_COMPROBANTE,"_CFDI_CFDIRELACIONADOS") <> Nil
					cUUIDRel := oXml:_CFDI_COMPROBANTE:_CFDI_CFDIRELACIONADOS:_CFDI_CFDIRELACIONADO:_UUID:TEXT
				EndIf
			ElseIf At( "TIMBREFISCALDIGITAL:TIMBREFISCALDIGITAL " , Upper(cXml) ) > 0
				// Version anterior a 2012 de sefactura
				cTimbre := oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TIMBREFISCALDIGITAL_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
				cUUID 		:= oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
				cFechaTim 	:= Strtran(Substr(oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT,1,10), "-")
				cRFCTim 	:= oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RFC:TEXT   
				cTotalTim 	:= oXml:_CFDI_COMPROBANTE:_TOTAL:TEXT
			Endif
			If !Empty( cTimbre )
				lRet := AddTimbre2(cRuta, cNombre, cXml)
			Endif
		ElseIf At( "TFD:TIMBREFISCALDIGITAL " , Upper(cXml) ) > 0
			// Se recibe solo el certificado
			//cTimbre := oXml:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT					
			lRet := AddTimbre(cRuta, cNombre, cXml)
		Endif
		// <\ARL>
	Endif
Else // Regresar contenido del archivo como texto del error (sefactura no regresa formato xml)
	cError := If(Empty(cError), "", cError + CRLF) + MemoRead( cRuta + cNombre + ".out")
Endif

If Empty(cUUIDRel)
	cUUIDRel := FGetMovRIW(cFilSRA, cRFCTim)
EndIf

FreeObj(oXml)
oXml := Nil

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � AddTimbre� Autor � Alberto Rodriguez    � Data � 18/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Integra timbre fiscal en CFDi (temporales)                ���
���           � El WS devuelve solo TFD                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxis   � AddTimbre( ruta , archivo , oXML )                        ���
�������������������������������������������������������������������������Ĵ��
���Uso        � LeeXMLOut                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function AddTimbre(cRutaXML, cArchivo, cTimbre)
Local cFile		:= cRutaXML + cArchivo
Local nHandle	:= 0
Local aInfoFile	:= {}
Local nSize		:= 0
Local cXML		:= ""
Local nIni		:= 0
Local cUTF8		:= Chr(239) + Chr(187) + Chr(191)
Local lRet		:= .F.
Local oXml2
Local cRutaSrv := &(SuperGetmv( "MV_CFDRECN" , .F. , "'cfd\recibos\'" ))

cUUID 		:= ""
cFechaTim 	:= ""
cRFCTim 	:= ""   
cTotalTim 	:= ""

// Leer xml's como string
Begin Sequence
   
	// xml enviado a timbrar
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
/*
	// xml recibido con timbre
	If !( File( cFile + ".out" ) )
		Break
	EndIf

	nHandle 	:= fOpen( cFile + ".out" )

	If nHandle <= 0
		Break
	EndIf

	aInfoFile	:= Directory( cFile + ".out" )
	nSize		:= aInfoFile[ 1 , 2 ]
	cTimbre		:= fReadStr( nHandle , nSize )
	fClose( nHandle )

	nIni := At( "</cfdi:Comprobante>" , cXML)
*/
	nIni := At( "</cfdi:Complemento>" , cXML)

	If nIni == 0
		//If lDeMenu
		//	Aviso( STR0001 , OemToAnsi( STR0014 + CRLF + cArchivo + ".out" ), {STR0002} ) // Archivo XML no v�lido
		//Else
			Conout( ProcName(0) + ": " + STR0014 + " " + cArchivo + ".out" )
		//Endif
		Break
	EndIf

	// Inserta nodo del timbre fiscal
/*
	cXML := Substr(cXML, 1, nIni-1) + ;
			Space(4) + "<cfdi:Complemento>" + CRLF + ;
			Space(8) + cTimbre + CRLF + ;
			Space(4) + "</cfdi:Complemento>" + CRLF + ;
			Substr(cXML, nIni)
*/
	cXML := Substr(cXML, 1, nIni-1) + ;
			Space(8) + cTimbre + CRLF + ;
			Substr(cXML, nIni)

	// Codificacion UTF-8
	If Substr(cXML,1,1) == "<"
		cXML := Strtran( cXML , cUTF8 )
		cXML := cUTF8 + cXML // EncodeUTF8( cXML )
	Endif
	// Graba el xml actualizado
	If ( nHandle := fCreate( cFile + ".timbre" ) ) <> -1 
		If fWrite( nHandle , cXML ) == Len(cXML)
			lRet := .T.
		Endif
		fClose( nHandle )
	Endif

	// CREAR Y ESCRIBIR VARIABLES DESDE EL XML
	CpyT2S( cFile + ".timbre", cRutaSrv )
	oXml2 := XmlParserFile(cRutaSrv + cArchivo +  ".timbre", "", @cError, @cDetalle )
	cTimbre 	:= oXml2:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT
	cUUID 		:= oXml2:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT
	cFechaTim 	:= Strtran(Substr(oXml2:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT,1,10), "-")
	cRFCTim 	:= oXml2:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RFC:TEXT   
	cTotalTim 	:= oXml2:_CFDI_COMPROBANTE:_TOTAL:TEXT
	Ferase( cRutaSrv + cArchivo +  ".timbre" )

End Sequence

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    �AddTimbre2� Autor � Alberto Rodriguez    � Data � 18/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Integra timbre fiscal en CFDi (temporales)                ���
���           � El WS devuelve TFD integrado en CFDi                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxis   � AddTimbre( ruta , archivo , oXML )                        ���
�������������������������������������������������������������������������Ĵ��
���Uso        � LeeXMLOut                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function AddTimbre2(cRutaXML, cArchivo, cXML)
Local cFile		:= cRutaXML + cArchivo + ".out"
/*
Local nHandle	:= 0
Local aInfoFile	:= {}
Local nSize		:= 0
*/
Local nIni		:= 0
Local lRet		:= .F.

// Leer xml recibido como string
Begin Sequence
/*
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
*/
	nIni		:= At( ":TimbreFiscalDigital " , cXML)

	If nIni == 0
		//If lDeMenu
		//	Aviso( STR0001 , OemToAnsi( STR0014 + CRLF + cArchivo + ".out" ), {STR0002} ) // Archivo XML no v�lido
		//Else
			Conout( ProcName(0) + ": " + STR0014 + " " + cArchivo + ".out" )
		//Endif
		Break
	EndIf

	// Graba copia del xml recibido
	lRet := __CopyFile( cFile , cRutaXML + cArchivo + ".timbre" )

End Sequence

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �AddendaCFDi�Autor � Alberto Rodriguez     � Data � 09/12/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manejo de Addenda para timbrar xml			              ���
���          � Las funciones de tratamiento de xml alteran el formato!!!  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AddendaCFDi( cRutaSmartclient, cArchivoXML, cOpcion )      ���
���          � cOpcion 1-Elimina, 2-Restaura                              ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function AddendaCFDi(cRutaXML, cArchivo, cOpcion)
Local cFile := If( cOpcion == "1" , cArchivo , Substr(cArchivo, 1, AT( "." , cArchivo)-1) + "_original.xml" )
Local aXML	:= {}
Local aAddenda := {}
Local cEtiq1:= "<cfdi:Addenda"
Local cEtiq2:= "</cfdi:Addenda>"
Local cFin	:= "</cfdi:Comprobante>"
Local nIni	:= 0
Local nFin	:= 0
Local nLoop	:= 0
Local lRet	:= .F.

// Leer xml recibido como string
aXML := File2Array( cRutaXML + cFile )

If Len(aXML) > 0
	nIni := aScan( aXML , {|x| cEtiq1 $ x } )

	If nIni > 0
		// Hace copia de la Addenda
		For nLoop := nIni To Len(aXML)
			aAdd( aAddenda , aXML[nLoop] )
			If cEtiq2 $ aXML[nLoop]
				nFin := nLoop
				Exit
			Endif
		Next

		If cOpcion == "1"
			// Extrae la Addenda del xml
			If nFin == 0
				// Indica que el elemento Addenda termina en la misma l�nea del xml: "... />" puede haber espacios los caracteres
				nFin := nIni
			Endif
			
			// Elimina la Addenda
			For nLoop := nFin To nIni Step -1
				aDel( aXML , nLoop )
				aSize( aXML , Len(aXML)-1 )
			Next

			// Codificacion UTF-8
			If Substr(aXML[1], 1, 1) == "<"
				aXML[1] := EncodeUTF8( aXML[1] )
			Endif

			// Graba el xml actualizado
			lRet := Array2File( cRutaXML + cFile , aXML )
		Endif

		If cOpcion == "2" .And. Len(aAddenda) > 0
			aSize( aXML , 0 )
			aXML := File2Array( cRutaXML + cArchivo )

			If Len(aXML) > 0
				// Integra la Addenda en el xml timbrado
				For nLoop := Len(aXML) To 1 Step -1
					If cFin $ aXML[nLoop]
						nIni := nLoop
						Exit
					Endif
				Next

				// Como viene el xml? formateado o todo seguido
				If !( cFin == Alltrim( aXML[nIni] ) )
					// La l�nea donde se encuentra la etiqueta de cierre de documento contiene m�s definiciones ==> partirla
					aSize( aXML , Len(aXML) + 1 )
					nFin := At( cFin , aXML[nIni] )
					aXML[nIni + 1] := Substr( aXML[nIni] , nFin )
					aXML[nIni] := Substr( aXML[nIni] , 1 , nFin - 1 )
					++nIni
				Endif

				// Inserta la Addenda
				For nLoop := 1 To Len(aAddenda)
					aSize( aXML , Len(aXML)+1 )
					aIns( aXML , nIni + nLoop - 1 )
					aXML[nIni + nLoop - 1] := aAddenda[nLoop]
				Next

				// Graba el xml final
				lRet := Array2File( cRutaXML + cArchivo , aXML )
			Endif
		Endif

	Endif
Endif

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �File2Array�Autor  � Alberto Rodriguez     � Data � 12/12/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Lee un archivo de texto y deja el contenido en un arreglo  ���
���          � Sin CR + LF                                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � File2Array( cArchivo, aDatos )                             ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function File2Array( cFile )
Local nHandle		:= 0
Local aInfoFile		:= {}
Local nSize			:= 0
Local nTamChr		:= 0
Local nPosFimLinha	:= 0
Local aFile 		:= {}
Local cLine			:= ""
Local cImpLine		:= ""
Local cAuxLine		:= ""

Begin Sequence
   
	IF !( File( cFile ) )
		Break
	EndIF

	nHandle 	:= fOpen( cFile )
	If nHandle <= 0
		Break
	EndIf
	aInfoFile	:= Directory( cFile )
	nSize		:= aInfoFile[ 1 , 2 ]

	/*/
	��������������������������������������������������������������Ŀ
	� Extrai uma linha "FISICA" de texto (pode conter varias linhas�
	� logicas)											           �
	����������������������������������������������������������������/*/
	cLine	:= fReadStr( nHandle , nSize )

	/*/
	��������������������������������������������������������������Ŀ
	� Gerar o Array para a GetDados       						   �
	� Verifica a Existencia de CHR(13)+CHR(10) //Carriage Return e �
	� Line Feed na linha extraida do texto Se ambos existirem, esta�
	� mos trabalhando em ambiente Windows. Caso contrario, estamos �
	� em ambiente Linux e somente teremos o CHR(10) para indicar o �
	� final da linha 											   �
	����������������������������������������������������������������/*/
	If (nPosFimLinha	:=	At( CRLF , cLine ) ) == 0
		nPosFimLinha	:=	At( Chr(10) , cLine )
		nTamChr := 1
	Else
		nTamChr := 2
	EndIf

	cImpLine := Substr( cLine, 1, nPosFimLinha - 1 )
	cAuxLine := Substr( cLine, nPosFimLinha+nTamChr, nSize )

	If Len( cImpLine ) > 0
		aAdd( aFile, cImpLine )
	Else
		aAdd( aFile, cLine )
	EndIf

	While nPosFimLinha <> 0
		If nTamChr == 1
			nPosFimLinha	:=	At( Chr(10) , cAuxLine )
		Else
			nPosFimLinha	:=	At( CRLF , cAuxLine )
		EndIf

		If nPosFimLinha <> 0
			cImpLine := Substr( cAuxLine, 1, nPosFimLinha - 1 )
			cAuxLine := Substr( cAuxLine, nPosFimLinha+nTamChr, nSize )
			aAdd( aFile, cImpLine )			
		ElseIf Len(cAuxLine) > 0
			aAdd( aFile, cAuxLine )			
		EndIf
	EndDo
	
	fClose( nHandle )

End Sequence

Return( aFile )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Array2File�Autor  � Alberto Rodriguez     � Data � 12/12/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Graba un arreglo en un archivo de texto agregando CR + LF  ���
���          � al final de cada l�nea                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Array2File( cArchivo, aDatos )                             ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Array2File(cArchivo, aDatos)
Local nHandle	:= FCreate(cArchivo)
Local nLoop		:= 0
Local lRet		:= .F.

If !(nHandle == -1)
	For nLoop := 1 to Len(aDatos)
		FWrite(nHandle, aDatos[nLoop] + CRLF)
	Next
   FClose(nHandle)
   lRet := .T.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n    � GrabaLog � Autor � Alberto Rodriguez    � Fecha� 19/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Graba log de recibos no timbrados                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxis   � GrabaLog( cRuta , aRecibos )                              ���
���           � [x,1] - Nombre del archivo xml                            ���
���           � [x,2] - *mensaje de error                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso        � CFDiRecNom       		                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GrabaLog(cRuta , aRecibos)
Local cArchivo  := DtoS(dDataBase) + Strtran(Time(), ":") + ".log"
Local nHandle	:= FCreate(cRuta + cArchivo)
Local nLoop		:= 0
Local lRet		:= .F.

If !(nHandle == -1)
	For nLoop := 1 to Len(aRecibos)
		If Substr( aRecibos[nLoop,2] , 1 , 1 ) == "*"
			FWrite(nHandle, aRecibos[nLoop,1] + " " + Substr( aRecibos[nLoop,2] , 2 ) + CRLF)
		Endif
	Next
	For nLoop := 1 to Len(aLog)
		If aLog[nLoop,2]  == 3
			FWrite(nHandle, aLog[nLoop,1] + " " + STR0021 + CRLF) //" - Estructura inv�lida (Error)"
		Endif
	Next
	FClose(nHandle)
	lRet := .T.
EndIf

Return lRet
