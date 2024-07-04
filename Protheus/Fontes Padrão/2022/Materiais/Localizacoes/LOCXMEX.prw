#include 'protheus.ch'
#include 'LOCXMEX.CH'
#Include "FWMVCDEF.CH"
#INCLUDE 'FWLIBVERSION.CH'
//Array aCfgNf
#Define SnTipo      1
#Define SlFormProp  3
#Define SAliasHead  4
#Define ScEspecie   8
#Define ScTipoDoc  10
#Define SaCposBr   26

/*/{Protheus.doc} LXMexAcc
Agrega acciones para rutinas de generación de notas fiscales (LOCXNF) para el país México
@type
@author luis.enriquez
@since 27/02/2020
@version 1.0
@param/@return aRotina, arreglo, Arregló con acciones
@example
LXMexAcc(@aRotina)
@see (links_or_references)
/*/
Function LXMexAcc(aRotina)
	If (cFunName$ "MATA101N") .Or. (cFunName == "MATA466N" .And. nNFTipo == 7)
		If cFunName == "MATA101N"
			If (SF1->(FieldPos("F1_RUTDOC")) >0)
				aAdd(aRotina,{OemToAnsi(STR0001),"MT459VDOC(SF1->F1_RUTDOC)",0,5,0,NIL}) //"Visualizar PDF/XML"
			EndIf
		ElseIf cFunName == "MATA466N"
			If (SF2->(FieldPos("F2_RUTDOC")) >0)
				aAdd(aRotina,{OemToAnsi(STR0001),"MT459VDOC(SF2->F2_RUTDOC)",0,5,0,NIL}) //"Visualizar PDF/XML"
			EndIf
		Endif
	 	aAdd(aRotina,{OemToAnsi(STR0002),"LXList69B()",0,5,0,NIL}) //"Cargar Listado 69-B"
	EndIf
Return Nil

/*/{Protheus.doc} LeerXML
Lee el archivo XML para obtener la informacion para el país México
@type
@author laura.medina
@since 02/07/2015
@version 1.0
@example
LeerXML()
@see (links_or_references)
/*/
Function LeerXML()
	Local _cErrMsg := ""
	Local _cWrnMsg := ""
	Local _cCert   := ""	// Certificado
	Local _dFchTim := ""	// Fecha timbrado
	Local lRet     := .T.	// Nodo invalido
	Local nCar 	 := 0
	Local aCarEsp  := {}
	Local nPosFTim := 0
	Local nPosRDoc	:= 0
	Local cDato := ""
	Local cCRLF := (chr(13)+chr(10))
	Local cFunName	:= AllTrim(FunName())

	_cRFC 		:= ""	// RFC Proveedor
	_cRFCRec	:= ""   // RFC Receptor (SM0)
	cPathXML 	:= ""   // Path XML (local)

	_oXml := XmlParserFile( cPathSrv, "_", @_cErrMsg, @_cWrnMsg )

	//Uso de Caracteres especiales amperson en RFC
	Aadd(aCarEsp,{"&","&amp;"})
	Aadd(aCarEsp,{"&","&#38;"})

	If  (_oXml == NIL ) .Or. (!Empty(_cErrMsg) .or. !Empty(_cWrnMsg) )
		MsgStop(STR0017) //"El documento XML es invalido, verifique!"
		Return(.F.)
	Else
		If XmlChildEx(_oXml, "_CFDI_COMPROBANTE") <> Nil
			If XmlChildEx(_oXml:_CFDI_COMPROBANTE, "_CFDI_COMPLEMENTO") <> Nil
				If 	XmlChildEx(_oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO, "_TFD_TIMBREFISCALDIGITAL") <> Nil
					If XmlChildEx(_oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL, "_UUID") <> Nil
						_cUUID := _oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT   //Obtener UUID
					Else
						cDato += STR0018 + cCRLF //"-Elemento UUID (nodo tfd:TimbreFiscalDigital)"
					EndIf
					If XmlChildEx(_oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL, "_NOCERTIFICADOSAT") <> Nil
						_cCert := _oXML:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_NOCERTIFICADOSAT:TEXT  //Obtener Certificado
					Else
						cDato += STR0019 + cCRLF //"-Elemento Número de Certificado SAT (nodo tfd:TimbreFiscalDigital)"
					EndIf
					If XmlChildEx(_oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL, "_FECHATIMBRADO") <> Nil
						_dFchTim:= _oXml:_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT     //Obtener Fecha Timbrado
						_dFchTim:= IIF(!Empty(_dFchTim),Ctod(substr(_dFchTim,9,2)+'/'+substr(_dFchTim,6,2)+'/'+substr(_dFchTim,3,2)),CTOD("//"))
					Else
						cDato += STR0020 + cCRLF //"-Elemento Fecha de Timbrado (nodo tfd:TimbreFiscalDigital)"
					EndIf
				Else
					cDato += STR0021 + cCRLF //"-Nodo Timbre Fiscal (tfd:TimbreFiscalDigital)"
				EndIf
			Else
				cDato += STR0034 + cCRLF //"-Nodo Complemento (cfdi:Complemento)"
			EndIf
			If XmlChildEx(_oXml:_CFDI_COMPROBANTE, "_CFDI_EMISOR") <> Nil
				If XmlChildEx(_oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR, "_RFC") <> Nil
					_cRFC := _oXml:_CFDI_COMPROBANTE:_CFDI_EMISOR:_RFC:TEXT //RFC Emisor
					For nCar := 1 To Len(aCarEsp)
	            		_cRFC:= StrTran(_cRFC, aCarEsp[nCar,2] , aCarEsp[nCar,1] )
	        		Next nCar
	        	Else
					cDato += STR0022 + cCRLF //"-Elemento RFC del Emisor (nodo cfdi:Emisor)"
				EndIf
			Else
				cDato += STR0023 + cCRLF //"-Nodo de datos del Emisor (cfdi:Emisor)"
			EndIf
			If XmlChildEx(_oXml:_CFDI_COMPROBANTE, "_CFDI_RECEPTOR") <> Nil
				If XmlChildEx(_oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR, "_RFC") <> Nil //RFC Receptor
					_cRFCRec := _oXml:_CFDI_COMPROBANTE:_CFDI_RECEPTOR:_RFC:TEXT
					For nCar := 1 To Len(aCarEsp)
	            		_cRFCRec:= StrTran(_cRFCRec, aCarEsp[nCar,2] , aCarEsp[nCar,1] )
	        		Next nCar
	        	Else
					cDato += STR0024 + cCRLF //"-Elemento RFC del Receptor (nodo cfdi:Receptor)"
				EndIf
			Else
				cDato += STR0025 + cCRLF //"-Nodo de datos del Receptor (cfdi:Receptor)"
			EndIf
		Else
			cDato += STR0026 + cCRLF //"-Nodo Comprobante (cfdi:Comprobante)"
		EndIf
	EndIf

	IIf(Empty(_cRFC), cDato += STR0033 + cCRLF,)    //"-El elemento RFC del nodo Emisor se encuentra vacío."
	IIf(Empty(_cRFCRec), cDato += STR0050 + cCRLF,) //"-El elemento RFC del nodo Receptor se encuentra vacío."
	IIf(Empty(_cUUID), cDato += STR0051 + cCRLF,)   //"-El Elemento UUID del nodo TimbreFiscalDigital se encuentra vacío."
	IIf(Empty(_dFchTim), cDato += STR0052 + cCRLF,) //"-El Elemento Timbre Fiscal del nodo TimbreFiscalDigital se encuentra vacío."
	IIf(Empty(_cCert), cDato += STR0053 + cCRLF,)   //"-El Elemento No. Certificado SAT del nodo TimbreFiscalDigital se encuentra vacío."

	If Empty(cDato)
		If cFunName == "MATA447"
			M->RSE_UUID   	:= _cUUID
			nPosFTim := aScan(aHeader, { |x,y| x[2] == "RSE_FECTIM" })
			nPosRDoc := aScan(aHeader, { |x,y| x[2] == "RSE_RUTDOC" })
			If nPosFTim > 0
				aCols[n,nPosFTim] := _dFchTim
			EndIf
			If nPosRDoc > 0
				aCols[n,nPosRDoc] := _cArq
			EndIf
		ElseIf cFunName $ "MATA466N"
			M->F2_UUID   	:= _cUUID
			M->F2_FECTIMB	:= _dFchTim
			M->F2_TIMBRE	:= _cCert
			cPathXML        := SUBSTR(cPathSrv,1,RAT(".XML",UPPER(cPathSrv))-1)
		Else
			M->F1_UUID   	:= _cUUID
			M->F1_FECTIMB	:= _dFchTim
			M->F1_TIMBRE	:= _cCert
			cPathXML        := SUBSTR(cPathSrv,1,RAT(".XML",UPPER(cPathSrv))-1)
		EndIf
	Else
		MsgStop(STR0027 + cCRLF + cDato) //"El XML no tiene la estructura necesaria para obtener los datos:"
		lRet := .F.
	EndIf
Return(lRet)

/*/{Protheus.doc} LxVldUUID
Validaciones del campo de UUID, en el modulo de Factura de entrada.

@type Function
@author Marco Augusto González Rivera
@since 30/06/2021
@version 2.0
@example LxVldUUID()

/*/
Function LxVldUUID()
	Local _aArea  	:= GetArea()
	Local lRet		:= .T.
	Local cProCli 	:= ""
	Local cCGC		:= ""
	Local cFunName  := AllTrim(funname())
	Local aDatosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CGC"} )
	Local cFilMB0   := xFilial("MB0")
	Local cRFCAux   := ""
	Local nTamCGC   := ""
	Local cAviso    := ""
	Local cCRLF     := (chr(13)+chr(10))
	Local lM466N	:= (cFunName == "MATA466N" .And. nNFTipo == 7)
	//Local cTabSF	:= IIf(lM466N, "SF2", "SF1")
	Local cAliSF	:= IIf(lM466N, "F2", "F1")
	//Local nOrderSF	:= IIf(lM466N, 15, 9) //F2_FILIAL + F2_UUID //F1_FILIAL + F1_UUID
	Local lPedim	:= (cFunName == "MATA447")
	Local cDoc      := ""
	Local cSerie    := ""
	Local cEspecie  := ""

	If IIf(lPedim, .F., !Empty(Replace(M->&(cAliSF+"_UUID"),"-",""))) //NF generada desde pedimentos no valida XML
		If Empty(Replace(_cUUID,"-",""))
			MsgStop(STR0056)//"¡Archivo no seleccionado!"
			Return .F.
		ElseIf Replace(M->&(cAliSF+"_UUID"),"-","") <> Replace(_cUUID,"-","")
			_cUUID := ""
			MsgStop(STR0057)//"El UUID del documento seleccionado no corresponde con el UUID informado, seleccione el archivo nuevamente."
			Return .F.
		ElseIf DupUUID(M->&(cAliSF+"_UUID"),@cDoc,@cSerie,@cEspecie) //verifica que uuid no exista en la tabla SF1-SF2
			_cUUID := ""
			MsgStop(STR0061 +cCRLF+ STR0060+": "+Alltrim(cDoc) +cCRLF+ STR0058+ ": "  +Alltrim(cSerie) +cCRLF +STR0059+": "+ AllTrim(cEspecie) ) //"El Folio Fiscal ya fue utilizado en el siguiente documento: "
			Return .F.
		EndIf
		If !ExisteAlias("MB0") .Or. !ChkVazio("MB0",.F.)
			MsgAlert(STR0049) //"No existe la tabla Listado 69-B (MB0) o no contiene registros, ejecute la acción Cargar Listado 69-B desde Otras acciones de la rutina de Facturas de Entrada (MATA101N)"
			Return .F.
		EndIf

		If nNFTipo != 12
			cCGC	:= Alltrim(SA2->A2_CGC)
			cProCli := STR0029 + " " + Alltrim(SA2->A2_COD) + "-" + Alltrim(SA2->A2_LOJA) + " (" + cCGC + ")" //"Proveedor"
		Else
			cCGC	:= Alltrim(SA1->A1_CGC)
			cProCli := STR0030 + " " + Alltrim(SA1->A1_COD) + "-" + Alltrim(SA1->A1_LOJA)+ " (" + cCGC + ")" //"Cliente"
		EndIf
		If !Empty(_cRFCRec)
			If lRet .And. !(Alltrim(aDatosSM0[1][2]) == Alltrim(_cRFCRec))
				MsgStop(StrTran( STR0031, '###', Alltrim(aDatosSM0[1][2]) ) + Alltrim(_cRFCRec) + ")") //"El RFC de la empresa (###) no coincide con el RFC del Receptor del documento XML ("
				lRet	:= .F.
			EndIf
		EndIf
		If !Empty(_cRFC)
			If lRet .And. !(cCGC == Alltrim(_cRFC))
				MsgStop(StrTran( STR0032, '###', cCGC ) + Alltrim(_cRFC) + ")") //"El RFC del Proveedor (###) no coincide con el RFC del Receptor del documento XML ("
				lRet	:= .F.
			EndIf
			If lRet
				nTamCGC   := TamSX3("MB0_CGC")[1]
				cRFCAux := Padr(_cRFC,nTamCGC," ")
				dbSelectArea("MB0")
				MB0->(dbSetOrder(1)) //MB0_FILIAL + MB0_CGC
				If MB0->(DbSeek(cFilMB0 + cRFCAux))
					Do While MB0->(!Eof()) .And. MB0->MB0_FILIAL + MB0->MB0_CGC == cFilMB0 + cRFCAux
						cAviso += STR0036 + Upper(Alltrim(MB0->MB0_STATUS)) + cCRLF + ; //"Situación: "
						   	      STR0037 + IIf(!Empty(MB0->MB0_FECPRE),Dtoc(MB0->MB0_FECPRE),"") + ;     //" Fec. Pres.: "
						   	      STR0038 + IIf(!Empty(MB0->MB0_FECDES),Dtoc(MB0->MB0_FECDES),"") + ;     //" Fec. Desv.: "
						   	      STR0039 + IIf(!Empty(MB0->MB0_FECDEF),Dtoc(MB0->MB0_FECDEF),"") + ;     //" Fec. Def.: "
						   	      STR0040 + IIf(!Empty(MB0->MB0_FECSFA),Dtoc(MB0->MB0_FECSFA),"") + cCRLF //" Fec. Sent. Fav.: "
						MB0->(DbSkip())
					EndDo
					lRet := MsgYesNo(StrTran( STR0054, '###', _cRFC ) + cCRLF + cAviso + cCRLF + STR0035) //"El RFC del Emisor (###) existe en el listado de contribuyentes que desvirtuaron la presunción de inexistencia de operaciones ante el SAT: " //"¿Desea continuar?"
				EndIf
			EndIf
		EndIf
	EndIf
	If IIf(lPedim, .F., lRet .And. (Empty(Replace(M->&(cAliSF+"_UUID"),"-",""))))
		M->&(cAliSF + "_FECTIMB") := CTOD("//")
		M->&(cAliSF + "_TIMBRE")  := SPACE(TAMSX3(cAliSF+"_TIMBRE")[1])
		cPathXML := SPACE(TAMSX3(cAliSF+"_RUTDOC")[1])
	EndIf
	RestArea( _aArea )
Return lRet


/*/{Protheus.doc} DupUUID
Verifica que el valor del Folio Fiscal (UUID) cargado
no se encuentre en otro documento(Factura entrada, NCP y NDP) ya registrado.
@type
@author eduardo.manriquez
@since 09/11/2020
@version 1.0
@param _cUUID, caracter, Folio Fiscal de archivo cargado.
@param cDoc, caracter, Número de Doc donde se uso el folio Fiscal de archivo cargado.
@param cSerie, caracter, Serie del Documento
@param cEspecie, caracter, Especie del Documento
@return lDup,lógico, .T. cuando el Folio Fiscal (UUID) se encuentro en otro documento
@example
DupUUID(_cUUID)
@see (links_or_references)
/*/

Function DupUUID(_cUUID,cDoc,cSerie,cEspecie)
	Local lDup        := .F.
	Local aArea       := GetArea()
	Local cSfxUUID    := GetNextAlias()

	Default _cUUID    := ""
	Default cDoc      := ""
	Default cSerie    := ""
	Default cEspecie  := ""


	BeginSQL Alias cSfxUUID
		SELECT F1_UUID,F1_DOC,F1_SERIE,F1_ESPECIE
		FROM %Table:SF1% SF1
		WHERE SF1.F1_UUID = %Exp:_cUUID% AND SF1.F1_ESPECIE IN ('NDP','NF ')
		AND SF1.%NotDel%
	EndSQL

	(cSfxUUID)->(DBGoTop())

	While (cSfxUUID)->(!Eof())
		cDoc     := (cSfxUUID)->F1_DOC
		cSerie   := (cSfxUUID)->F1_SERIE
		cEspecie := (cSfxUUID)->F1_ESPECIE

		(cSfxUUID) ->(dbSkip())
	EndDo

	(cSfxUUID) ->(dbCloseArea())

	if !Empty(cDoc)
		lDup := .T.
	Else
		cSfxUUID := GetNextAlias()
		BeginSQL Alias cSfxUUID
			SELECT F2_UUID,F2_DOC,F2_SERIE,F2_ESPECIE
			FROM %Table:SF2% SF2
			WHERE SF2.F2_UUID = %Exp:_cUUID% AND SF2.F2_ESPECIE = 'NCP'
			AND SF2.%NotDel%
		EndSQL

		(cSfxUUID)->(DBGoTop())

		While (cSfxUUID)->(!Eof())
			cDoc     := (cSfxUUID)->F2_DOC
			cSerie   := (cSfxUUID)->F2_SERIE
			cEspecie := (cSfxUUID)->F2_ESPECIE

			(cSfxUUID) ->(dbSkip())
		EndDo

		if !Empty(cDoc)
			lDup := .T.
		Endif

		(cSfxUUID) ->(dbCloseArea())

	Endif
	RestArea(aArea)

Return lDup


/*/{Protheus.doc} LXList69B
Asistente para proceso de carga de la tabla Listado 69-B (MB0)
@type
@author luis.enriquez
@since 03/03/2020
@version 1.0
@example
LXList69B()
@see (links_or_references)
/*/
Function LXList69B()
	Local aSays := {}
	Local aButtons := {}
	Local cPerg    := "M10169B"

	Private cRutaCSV := ""
	Private cArchivo := "Listado69B.csv"

	If Pergunte(cPerg,.F.)
		cRutaCSV := MV_PAR01
	EndIf

	If ExisteAlias("MB0")
		AADD(aSays,OemToAnsi(STR0003)) //"Esta función tiene como objetivo cargar el listado de contribuyentes que desvirtuaron"
		AADD(aSays,OemToAnsi(STR0004)) //"la presunción de inexistencia de operaciones ante el SAT, a través de la emisión de "
		AADD(aSays,OemToAnsi(STR0005)) //"facturas  o comprobantes fiscales. (Artículo 69-B del Código Fiscal de la Federación)"
		AADD(aSays,OemToAnsi(""))
		AADD(aSays,OemToAnsi(STR0006)) //"Importante: Cada que se ejecute el proceso se actualizara el listado por completo de"
		AADD(aSays,OemToAnsi(STR0007 + cArchivo)) //"acuerdo al contenido del archivo "
		AADD(aSays,OemToAnsi(""))
		AADD(aSays,OemToAnsi(STR0008 + cRutaCSV) ) //"Ruta del archivo: "

		AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
		AADD(aButtons, { 1,.T.,{|o| nOpca := 1,If(LXCarCSV(),FechaBatch(),nOpca:=0) }} )
		AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

		FormBatch(STR0009, aSays, aButtons) //"Carga del Listado 69-B"
	Else
		MsgAlert(STR0055) //"No existe creada la tabla Listado 69-B (MB0).
		Return .F.
	EndIf
Return Nil

/*/{Protheus.doc} LXCarCSV
Proceso de descarga de archivo Listado69B.csv para llenado de la tabla Listado 69-B (MB0)
@type
@author luis.enriquez
@since 03/03/2020
@version 1.0
@example
LXCarCSV()
@see (links_or_references)
/*/
Function LXCarCSV()
	Local nOpc := 0
	Local lRet := .T.
	Local cRutaSMR := &("GetClientDir()")
	Local cRutina := "DescargaCSV.exe "
	Local cURL    := GetMV("MV_WSRTSS",.F.,"http://omawww.sat.gob.mx/cifras_sat/Documents/Listado_Completo_69-B.csv")
	Local cPos    := GetMV("MV_IDCBAJA",.F.,"")
	Local cPath   := ""
	Local cParam  := ""
	Local cQuery  := ""
	Local cCRLF   := (chr(13)+chr(10))

	Private aPos := {}

    cRutaCSV := MV_PAR01

    If !Empty(cPos)
		aPos := StrTokArr(cPos, "|")
    EndIf
	If Len(aPos) < 6
	 	//"No se tienen configuradas todas las posiciones para los datos a actualizar a partir del archivo Listado69B.cvs (MV_IDCBAJA):"
	 	//"-RFC"
	 	//"-Situación"
	 	//"-Fecha Publicación de Presunto"
	 	//"-Fecha Publicación de Desvirtuado"
	 	//"-Fecha Publicación de Definitivo"
	 	//"-Fecha Publicación de Sentencia Favorable"
		MsgAlert(STR0042 + cCRLF + STR0043 + cCRLF + STR0044 + cCRLF + STR0045 + cCRLF + STR0046 + cCRLF + STR0047 + cCRLF + STR0048)
		Return .F.
	EndIf
    If !Empty(cRutaCSV)
    	cParam := Trim(cURL) + " " + cRutaCSV + " " + cArchivo

	    cPath := Alltrim(cRutaCSV) + Alltrim(cArchivo)

		If ChkVazio("MB0",.F.)
			lRet := MsgYesNo(STR0010) //"Existe información en el listado 69-B. ¿Desea continuar para cargar nuevamente?"
		EndIf
		If lRet
			If File( cRutaSMR + cRutina ) //Ejecutable
				If !Empty(cURL)
					Processa( {|| nOpc := WAITRUN( cRUTASMR + cRutina + cParam, 0 )},STR0011, , .T. ) //"Descargando el Listado 69-B..."
				Else
					MsgAlert(STR0041) //"No se tiene configurada la URL para descarga del archivo Listado69b.csv (MV_WSRTSS)."
					Return .F.
				EndIf
			EndIf
			If File(Alltrim(cPath)) //Archivo .csv
				cQuery := "DELETE FROM " + RetSqlName("MB0")
				TcSqlExec(cQuery)
				Processa( {|| LXGravaMB0(cPath)},STR0012, , .T. ) //"Actualizando el Listado 69-B..."
			Else
				MsgAlert(STR0013 + cPath) //"No se encontró el archivo: "
			EndIf
		Else
			Return lRet
		EndIf
	Else
		MsgAlert(STR0014) //"No se indicó el parámetro con la ruta que contiene el archivo .CSV"
    EndIf
Return lRet

/*/{Protheus.doc} LXGravaMB0
Llenado de la tabla Listado 69-B (MB0) leyendo líneas del archivo Listado69B.csv
@type
@author luis.enriquez
@since 03/03/2020
@version 1.0
@param cFile, caracter, Ruta donde se localiza el archivo Listado69B.csv
@example
LXGravaMB0(cPath)
@see (links_or_references)
/*/
Function LXGravaMB0(cFile)
	Local nHandle  := 0
	Local nFor     := 0
	Local nX       := 0
	Local cLinea   := ""
	Local aLinea   := {}
	Local cSepara  := ","
	Local cFilMB0  := xFilial("MB0")
	Local cSitua   := ""
	Local nCarIni  := 0
	Local nCarFin  := 0
	Local nTamSta  := TamSX3("MB0_STATUS")[1]
	Local lInserta := .T.
	Local nA       := 0
	Local nTotCar  := 0
	Local nResid   := 0

	nHandle := FT_FUse(cFile)
	If nHandle != -1
		FT_FGoTop()
		nFor := FT_FLastRec()
		ProcRegua(nFor)

		While !FT_FEOF()
			IncProc(Str(nX))
			aLinea := {}
			cSitua := ""
			nTotCar := 0
			lInserta := .T.
			lContinua := .T.
			nResid := 0

			cLinea := cLinea + FT_FREADLN()

			For nA := 1 To Len(cLinea)
				If SubStr(cLinea, nA, 1) == '"'
					nTotCar++
				EndIf
			Next nA

		    nResid := nTotCar/2
		    nResid := nResid - Int(nResid)
		    If nResid > 0
		    	lInserta := .F.
		    EndIf

			If lInserta
				//Tratamiento comilla
				cLinea := StrTran( cLinea, '""', '' )
				nCarIni := At('"',cLinea)
				If nCarIni > 0
					cLinAux := SubStr(cLinea,nCarIni+1,Len(cLinea))
					nCarFin := At('"',cLinAux)
					cLinAux := SubStr(cLinea,nCarIni,nCarFin)
					cLinAux2 := cLinAux
					cLinAux := StrTran( cLinAux, ',', '!#' )
					cLinea := StrTran( cLinea, cLinAux2, cLinAux )
				EndIf

				aLinea := Separa(cLinea,cSepara)

				If !(Alltrim(aLinea[Val(aPos[2])]) $ "Definitivo|Desvirtuado|Presunto|Sentencia Favorable|")
					lContinua := .F.
				EndIf

				If  Empty(aLinea) .Or. At("XXXXXXXXXXXX",cLinea) > 0 .Or. !lContinua
					cLinea := ""
					FT_FSKIP()
					Loop
				EndIf

				RecLock('MB0',.T.)
					MB0->MB0_FILIAL := cFilMB0
					MB0->MB0_CGC    := aLinea[Val(aPos[1])] //RFC
					MB0->MB0_STATUS := Substr(aLinea[Val(aPos[2])],1,nTamSta) //Situación
					MB0->MB0_FECPRE := Ctod(aLinea[Val(aPos[3])]) //Fec. publicación Presunto SAT
					MB0->MB0_FECDES := Ctod(aLinea[Val(aPos[4])]) //Fec. publicación Desvirtuado SAT
					MB0->MB0_FECDEF := Ctod(aLinea[Val(aPos[5])]) //Fec. publicación Definitivo SAT
					MB0->MB0_FECSFA := Ctod(aLinea[Val(aPos[6])]) //Fec. publicación Sentencia Favorable SAT
				MB0->(MsUnLock())
				cLinea := ""
				nX++
			EndIf
			FT_FSKIP()
		EndDo
		FT_FUSE()
	Else
		MsgAlert(STR0015 + cFile) //"No se puede leer el archivo "
	EndIf

	APMSGINFO(STR0016 + Str(nX)) //"Registros insertados:"
Return

/*/{Protheus.doc} LxCposMex
Funcion utilizada para agregar campos al encabezado de Notas Fiscales para México.

@type Function
@author Marco Augusto Gonzalez Rivera
@since 30/06/2021
@version 1.0
@param aCposNF, Array, Array con campos del encabezado de NF
@param cFunName, Character, Codigo de rutina
@param cTablaEnc, Character, Alias del encabezado de Notas Fiscales
@example LxCposMex(@aCposNF, cFunName, cTablaEnc)
/*/
Function LxCposMex(aCposNF, cFunName, cTablaEnc)
	Local cSFx := ""
	Local cSFT := ""
	Local cCFDUso := Alltrim(GetMv("MV_CFDUSO", .T., "1"))
	Local lCfdi40 := SuperGetMV("MV_CFDI40",.F.,.F.)
	Local lComExt := !(nNFTipo == 21 .And. !lCfdi40)
	Local aSX3    := {}
	If cFunName $ ("MATA101N")  .And. cTablaEnc=="SF1" .And. (nNFTipo == 10 .OR. nNFTipo == 20 .OR. nNFTipo == 12 .OR. nNFTipo == 13 .OR. nNFTipo == 14)
		If (SF1->(FieldPos("F1_UUID")) >0 .And. SF1->(FieldPos("F1_FECTIMB")) >0 .And. SF1->(FieldPos("F1_TIMBRE")) >0 )
	     	aAdd(aCposNF,{NIL,"F1_UUID",NIL,NIL,NIL,"VldUUID()",NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,"UUID","VldWhen()"})
	     	aAdd(aCposNF,{NIL,"F1_FECTIMB",NIL,NIL,NIL,"",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,"VldWhen()"})
	     	aAdd(aCposNF,{NIL,"F1_TIMBRE",NIL,NIL,NIL,"",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,"VldWhen()"})
		Endif
	EndIf
	If cFunName $ ("MATA466N")  .And. cTablaEnc=="SF2" .And. (nNFTipo == 7)
		If (SF2->(FieldPos("F2_UUID")) >0 .And. SF2->(FieldPos("F2_FECTIMB")) >0 .And. SF2->(FieldPos("F2_TIMBRE")) >0 )
	     	aAdd(aCposNF,{NIL,"F2_UUID",NIL,NIL,NIL,"VldUUID()",NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,"UUID","VldWhen(.T.)"})
	     	aAdd(aCposNF,{NIL,"F2_FECTIMB",NIL,NIL,NIL,"",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,"VldWhen(.T.)"})
	     	aAdd(aCposNF,{NIL,"F2_TIMBRE",NIL,NIL,NIL,"",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,"VldWhen(.T.)"})
		Endif
	EndIf
	If (cTablaEnc == "SF2" .And. ;
		( cFunName $ "MATA467N" .And. (nNFTipo == 1 .Or. nNFTipo == 21) ) .Or. ;
		( cFunName $ "MATA465N" .And. (nNFTipo == 1 .Or. nNFTipo == 2) ) .Or. ;
		( cFunName $ "MATA468N" )	) .Or. ;
		( cFunName $ "MATA465N" .And. nNFTipo == 4 )
		cSFx := Substr(cTablaEnc,2,2)
		cSFT := cTablaEnc
		If ((cSFT)->(FieldPos(cSFx+"_UUID")) >0 .And. (cSFT)->(FieldPos(cSFx+"_FECTIMB"))>0 .And. (cSFT)->(FieldPos(cSFx+"_TIMBRE"))>0 ) .And. cCFDUso <> "0"
			aAdd(aCposNF,{NIL,cSFx+"_UUID",NIL,NIL,NIL,"",NIL,NIL,NIL,"V",NIL,NIL,NIL,NIL,NIL,NIL,".F."})
			aAdd(aCposNF,{NIL,cSFx+"_FECTIMB",NIL,NIL,NIL,"",NIL,NIL,NIL,"V",NIL,NIL,NIL,NIL,NIL,NIL,".F."})
			aAdd(aCposNF,{NIL,cSFx+"_FECANTF",NIL,NIL,NIL,"",NIL,NIL,NIL,"V",NIL,NIL,NIL,NIL,NIL,NIL,".F."})
			aAdd(aCposNF,{NIL,cSFx+"_TIMBRE",NIL,NIL,NIL,"",NIL,NIL,NIL,"V",NIL,NIL,NIL,NIL,NIL,NIL,".F."})
		EndIf
	EndIf
	If cTablaEnc == "SF2" .And. cFunName $ "MATA467N|MATA465N|MATA462N" .And. ( nNFTipo == 1 .Or. nNFTipo == 2 .Or. nNFTipo == 21 .or. nNFTipo == 50 )
		If SuperGetMV("MV_CFDIEXP", .F., .F.) .And. lComExt
			aAdd(aCposNF,{NIL,"F2_TIPOPE",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F2_CVEPED",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F2_CERORI",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F2_NUMCER",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F2_EXPCONF",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F2_INCOTER",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F2_SUBDIV",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			If SF2->(ColumnPos("F2_OBSCE")) > 0
				aAdd(aCposNF,{NIL,"F2_OBSCE",NIL,NIL,NIL,NIL,NIL,"M", NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			EndIf
			aAdd(aCposNF,{NIL,"F2_TCUSD",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F2_TOTUSD",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F2_IDTRIB",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F2_RESIDE",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F2_TRASLA",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			If SF2->(ColumnPos("F2_CONUNI")) > 0 .And. cFunName $ "MATA467N"
				aAdd(aCposNF,{NIL,"F2_CONUNI",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			EndIf
		EndIf
		If cCFDUso <> "0"
			aAdd(aCposNF,{NIL,"F2_RELSAT" ,NIL,NIL,NIL,IIF(nNFTipo == 21 .Or. nNFTipo == 1 .Or. nNFTipo == 2 .Or. nNFTipo == 50, 'ValRetSat(M->F2_RELSAT ,"F2_RELSAT") .AND. ValidF3I("S012", M->F2_RELSAT,1,2)',NIL),NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F2_USOCFDI",NIL,NIL,NIL,IIF(nNFTipo == 21 .Or. nNFTipo == 50, 'ValRetSat(M->F2_USOCFDI,"F2_USOCFDI")',NIL),NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			//Serie de documento a Sustiuir
			If SF2->(ColumnPos("F2_SERMAN")) > 0
				aSX3 := LxSX3Cache("F2_SERMAN")
				AAdd(aCposNF,{FWX3Titulo("F2_SERMAN"),"F2_SERMAN",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
			EndIf
			//Número de documento a Sustiuir
			If SF2->(ColumnPos("F2_DOCMAN")) > 0
				aSX3 := LxSX3Cache("F2_DOCMAN")
				AAdd(aCposNF,{FWX3Titulo("F2_DOCMAN"),"F2_DOCMAN",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
			EndIf
			aAdd(aCposNF,{NIL,"F2_UUIDREL",NIL,NIL,NIL,IIF(nNFTipo == 21 .Or. nNFTipo == 50, 'ValRetSat(M->F2_UUIDREL,"F2_UUIDREL")',NIL),NIL,"M",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
		EndIf
		If  SF2->(ColumnPos("F2_TPCOMPL")) > 0 .And. cFunName == "MATA467N" .And. (nNFTipo == 1 .Or. nNFTipo == 21) .And. cCFDUso <> "0"
			//Campos que indica si el documento es para Carta Porte
			aSX3 := LxSX3Cache("F2_TPCOMPL")
			AAdd(aCposNF,{FWX3Titulo("F2_TPCOMPL"),"F2_TPCOMPL",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
		If  SF2->(ColumnPos("F2_TPDOC")) > 0 .And. (nNFTipo == 01 .Or. nNFTipo == 50 .Or. nNFTipo == 21 .Or. nNFTipo == 02) .And. cCFDUso <> "0"
			aSX3 := LxSX3Cache("F2_TPDOC")
			AAdd(aCposNF,{FWX3Titulo("F2_TPDOC"),"F2_TPDOC",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
	Elseif cTablaEnc == "SF1" .And. cFunName $ "MATA465N" .And. nNFTipo == 4
		If SuperGetMV("MV_CFDIEXP", .F., .F.)
			aAdd(aCposNF,{NIL,"F1_TIPOPE",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F1_CVEPED",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F1_CERORI",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F1_NUMCER",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F1_EXPCONF",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F1_INCOTER",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F1_SUBDIV",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			If SF1->(ColumnPos("F1_OBSCE")) > 0
				aAdd(aCposNF,{NIL,"F1_OBSCE",NIL,NIL,NIL,NIL,NIL,"M", NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			EndIf
			aAdd(aCposNF,{NIL,"F1_TCUSD",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F1_TOTUSD",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F1_IDTRIB",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F1_RESIDE",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F1_TRASLA",NIL,NIL,NIL,NIL,NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
		EndIf
		If cCFDUso <> "0"
			aAdd(aCposNF,{NIL,"F1_RELSAT",NIL,NIL,NIL,IIF(nNFTipo == 4, 'ValRetSat(M->F1_RELSAT ,"F1_RELSAT") .AND. ValidF3I("S012", M->F1_RELSAT,1,2)',NIL),NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			aAdd(aCposNF,{NIL,"F1_USOCFDI",NIL,NIL,NIL,'ValRetSat(M->F1_USOCFDI,"F1_USOCFDI") .And. ValidF3I("S013", M->F1_USOCFDI,1,3)',NIL,NIL, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
			//Serie de documento a Sustiuir
			If SF1->(ColumnPos("F1_SERMAN")) > 0
				aSX3 := LxSX3Cache("F1_SERMAN")
				AAdd(aCposNF,{FWX3Titulo("F1_SERMAN"),"F1_SERMAN",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
			//Número de documento a Sustiuir
			If SF1->(ColumnPos("F1_DOCMAN")) > 0
				aSX3 := LxSX3Cache("F1_DOCMAN")
				AAdd(aCposNF,{FWX3Titulo("F1_DOCMAN"),"F1_DOCMAN",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
			EndIf
			AAdd(aCposNF,{NIL,"F1_UUIDREL",NIL,NIL,NIL,NIL,NIL,"M",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL})
		EndIf
	EndIf
Return

/*/{Protheus.doc} LoCnta120
Validaciones Genericas para mediciones de contrato (SIGAGCT)
@type
@author Alfredo.Medrano
@since 08/07/2020
@version 1.0
@example
LoCnta120(cAct,aCab)
@see (links_or_references)
/*/
Function LoCnta120(cAcc, aCab)
Local uContent
default cAcc := ""
default aCab := {}

	If cAcc == "Grv120"
		dbSelectArea("SC5")
		If CND->(ColumnPos("CND_USOCFD")) > 0 .AND. SC5->(ColumnPos("C5_USOCFDI")) > 0
			aAdd(aCab, {"C5_USOCFDI", CND->CND_USOCFD, Nil})// USO CFDI
		Endif
		If CND->(ColumnPos("CND_RELSAT")) > 0 .AND. SC5->(ColumnPos("C5_RELSAT")) > 0
			aAdd(aCab, {"C5_RELSAT", CND->CND_RELSAT, Nil})//Relacion CFD
		Endif
		If CND->(ColumnPos("CND_UUIDRE")) > 0 .AND. SC5->(ColumnPos("C5_UUIDREL")) > 0
			aAdd(aCab, {"C5_UUIDREL", CND->CND_UUIDRE, Nil})// UUID Relacs
		Endif
		uContent := aCab
	EndIf

Return uContent

/*/{Protheus.doc} LxIntPMSPc
Funcion utilizada para retornar el proyecto y tarea informados en
integracion con PMS para Pedidos de Compra.
@type Function
@author Marco Augusto Gonzalez Rivera
@since 11/12/2020
@version 1.0
@example LxIntPMSPc()
@param cNumPC, Char, Codigo de Pedido de Compra
@param cItemPC, Char, Numero de Item
@param aRatAFN, Array, Datos de Proyecto para NF's
@param aHeader, Array, Campos de encabezado
@param nPosRat, Numerico, Posicion de campo en encabezado
@param lPreNota, Logico, Indica si los datos de la Nota son preservados
@see (links_or_references)
/*/
Function LxIntPMSPc(cNumPC, cItemPC, aRatAFN, aHeader, nPosRat, lPreNota)

	Local lRet		:= .F.
	Local aAreaTrb	:= GetArea()
	Local cFilAJ7	:= xFilial("AJ7")
	Local lMsFilAJ7	:= AJ7->(FieldPos("AJ7_MSFIL")) > 0
	Local nAcuAFN	:= 0
	Local cFilAFN	:= xFilial("AFN")
	Local cFilSD1	:= xFilial("SD1")
	Local nY		:= 0

	Default cNumPC		:= ""
	Default cItemPC		:= ""
	Default aRatAFN		:= {}
	Default aHeader		:= {}
	Default nPosRat		:= 0
	Default lPreNota	:= .F.

	DBSelectArea("AFN")

	DBSelectArea("AJ7")
	AJ7->(dbSetOrder(2)) //AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA
	lRet := AJ7->(MSSeek(cFilAJ7 + cNumPC + cItemPC))

	//Verifica si el vinculo esta en los Pedidos de Compra
	While lRet .And. AJ7->(!Eof()) .And. cFilAJ7 + cNumPC + cItemPC == AJ7->(AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC)
		If AJ7->AJ7_REVISA == PmsAF8Ver(AJ7->AJ7_PROJET)
			If !lMsFilAJ7 .Or. (lMsFilAJ7 .And. AJ7->AJ7_MSFIL == cFilAnt)
				nAcuAFN := 0

				// Busca la relacion del documento de entrada con la tarea del proyecto
				AFN->(dbSetOrder(3)) // AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD
				SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				AFN->(MSSeek(cFilAFN+AJ7->(AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA+AJ7_COD)))
				While AFN->(!Eof()) .AND. AFN->(AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_COD) == cFilAFN+AJ7->(AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA+AJ7_COD)
					// Busca en el documento de entrada el item que fue adjunto a la tarea del proyecto para obtener
					// el numero de item del pedido de compra generado
					If SD1->(MSSeek(cFilSD1+AFN->(AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_COD+AFN_ITEM)))
						//Si el item del documento de entrada fue generado a partir del proceso de Pedido de compra
						//Caso positivo, debe acumular cantidades asociadas a la tarea del proyecto.
						If (SD1->D1_PEDIDO == cNumPC .AND. SD1->D1_ITEMPC == cItemPC).And.!lPreNota
							nAcuAFN += AFN->AFN_QUANT
						EndIf
					EndIf
					AFN->(dbSkip())
				EndDo

				// Si la cantidad mostrada en la relacion del documento de entrada con la tarea del proyecto
				// fuera menos a la cantidad relacionada en el Pedido de Compra debe incluir la relacion con la diferencia
				If nAcuAFN < AJ7->AJ7_QUANT
					aADD(aRatAFN[nPosRat][2],Array(Len(aHeader)+1))
					For nY := 1 To Len(aHeader)
						Do Case
							Case Alltrim(aHeader[nY][2]) == "AFN_PROJET"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][nY] := AJ7->AJ7_PROJET
							Case Alltrim(aHeader[nY][2]) == "AFN_TAREFA"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][nY] := AJ7->AJ7_TAREFA
							Case Alltrim(aHeader[nY][2]) == "AFN_REVISA"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][nY] := AJ7->AJ7_REVISA
							Case Alltrim(aHeader[nY][2]) == "AFN_QUANT"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][nY] := AJ7->AJ7_QUANT - nAcuAFN
							Case Alltrim(aHeader[nY][2]) == "AFN_TRT"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][nY] := AJ7->AJ7_TRT
							Case Alltrim(aHeader[nY][2]) == "AFN_ALI_WT"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][nY] := "AFN"
							Case AllTrim(aHeader[nY,2]) == "AFN_REC_WT"
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][nY] := 0
							OtherWise
								aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][nY] := CriaVar(Alltrim(aHeader[nY][2]))
						EndCase
					Next nY
					aRatAFN[nPosRat][2][Len(aRatAFN[nPosRat][2])][Len(aHeader)+1] := .F.
				EndIf
			EndIf
		EndIf
		AJ7->(dbSkip())
	EndDo

	RestArea(aAreaTrb)

Return lRet

/*/{Protheus.doc} LxMxDatPro
Obtiene si el producto es material peligroso México
@type
@author luis.enríquez
@since 27/08/2021
@version 1.0
@param cCodProd, caracter, Código del producto.
@return cValor, caracter, Valor que indica si el material es peligrodo,opciones 'Si' o 'No'.
@example
LxMxDatPro(cCodProd)
@see (links_or_references)
/*/
Function LxMxDatPro(cCodProd)
	Local cValor := ""
	Local cRet   := "No"

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1)) //B1_FILIAL + B1_COD
	If SB1->(dbSeek(xFilial("SB1") + cCodProd))
		If SB1->(ColumnPos("B1_PRODSAT")) > 0
			cRet := ObtColSAT("S019",SB1->B1_PRODSAT,1,8,189,3)
			If cRet == "0,1"
				cRet := "0" //Default No Peligroso para productos "0,1"
				If SB1->(ColumnPos("B1_TPCLAS")) > 0 .And. !Empty(SB1->B1_TPCLAS)
					cRet := SB1->B1_TPCLAS
				EndIf
			EndIf
			If Empty(cRet)
				cValor := "NA"
			ElseIf cRet == "0"
				cValor := "No"
			Else
				cValor := "Si"
			EndIf
		EndIf
	EndIf
Return cValor

/*/{Protheus.doc} LxCartaPor
Realiza lalamdo de pantalla para llenado de datos necesarios para el complemento de Carta Porte CFDI 3.3 México
@type
@author luis.enríquez
@since 27/08/2021
@version 1.0
@param cAlias, caracter, Alias del documento.
@param cNumDoc, caracter, Folio del documento.
@param cSerieDoc, caracter, Serie del documento.
@param cEsp, arreglo, Especie del documento.
@param lCarPor, lógica, Indica si el documento tiene activo el campo de Carta Porte (F2_TPCOMPL='S').
@param lVldTim, lógica, Indica si realiza validación para verificar si el documento ya fue timbrado.
@example
LxCartaPor(cAlias, cNumDoc, cSerieDoc, cEsp, lCarPor, lVldTim)
@see (links_or_references)
/*/
//static oModelAct := Nil
Function LxCartaPor(cAlias, cFilDoc, cNumDoc, cSerieDoc, cEsp, lCarPor, lVldTim)

	Local cMsjVld := ""
	Local cCRLF	  := (chr(13)+chr(10))
	Local nOpcion := MODEL_OPERATION_INSERT
	Local lCommit := IIf(lVldTim,.T.,.F.)
	Local lVisual := .F.

	Private cFilDocCP := cFilDoc
	Private cNumDoCP  := cNumDoc
	Private cSerieCP  := cSerieDoc

	If FindFunction("MATA487")
		If Empty(cNumDoc) .Or. Empty(cSerieDoc)
			cMsjVld := STR0062 + cCRLF //"Para ejecutar la acción de Carta Porte:"
			If Empty(cSerieDoc)
				cMsjVld += StrTran(STR0063,"###",FWX3Titulo("F2_SERIE") + " (F2_SERIE)") + cCRLF //"-El campo ###, debe ser informado."
			EndIf
			If Empty(cNumDoc)
				cMsjVld += StrTran(STR0063,"###",FWX3Titulo("F2_DOC") + " (F2_DOC)") + IIf(!Empty(cMsjVld),cCRLF,"") ////"-El campo ###, debe ser informado."
			EndIf

			If !Empty(cMsjVld)
				MsgAlert(cMsjVld)
			EndIf
		Else
			If lCarPor
				If lVldTim
					DbSelectArea("SF2")
					SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
					If SF2->(DbSeek(xFilial("SF2") + cNumDoc + cSerieDoc))
						If !Empty(SF2->F2_UUID) .And. !Empty(SF2->F2_FECTIMB) //Valida que el documento seleccionado en el Browse contenga Timbre Fiscal.
							lVisual := .T.
						EndIf
					EndIf
				EndIf

				dbSelectArea("A1X")
				dbSetOrder(1) //A1X_FILIAL+A1X_DOC+A1X_SERIE

				If A1X->(DBSeek(xFilial("A1X")+cNumDoc+cSerieDoc))
					If lVisual
						nOpcion := MODEL_OPERATION_VIEW
					Else
						nOpcion := MODEL_OPERATION_UPDATE
					EndIf
				Else
					nOpcion := MODEL_OPERATION_INSERT
				EndIf

				If oModelAct == Nil
					oModelAct := FWLoadModel("MATA487")
					oModelAct:SetOperation(nOpcion)
					oModelAct:Activate()
				EndIf

				FWExecView(IIf(lVisual, STR0094, STR0095),"VIEWDEF.MATA487",nOpcion,/*oDlg*/,{||.T.},{||M487FAKECO(lCommit)},,,,,,oModelAct) //"Visualizar" # "CARTA PORTE"

			Else
				cMsjVld := STR0062 + cCRLF //"Para ejecutar la acción de Carta Porte:"
				cMsjVld += StrTran(STR0065,"###",FWX3Titulo("F2_TPCOMPL") + "(F2_TPCOMPL)") + cCRLF //"-El campo ### debe ser informado con el valor 'Si'."
				If !Empty(cMsjVld)
					MsgAlert(cMsjVld)
				EndIf
			EndIf
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} LxMetCarP
Metríca para verificar la cantidad de Carta Porte registrados en un mes.
@type
@author luis.enríquez
@since 08/09/2021
@version 1.0
@example
LxMetCarP()
@see (links_or_references)
/*/
Function LxMetCarP(cRotina)
	Local cIdMetric	  := ""
	Local cSubRoutine := ""
	Local lMetVal     := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
	Local lAutomato   := IsBlind()
	Local cCodEmp     := FWCodEmp()

	If lMetVal
		cSubRoutine := cRotina + cCodEmp + "-CartaPorte" + IIf(lAutomato,"-auto","")
		cIdMetric	:= "faturamento-protheus_cantidad-cartaportes-registrados-por-empresa_total"
		FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, 1, /*dDate*/, /*nLapTime*/,cRotina)
	EndIf

Return Nil

/*/{Protheus.doc} LxMxPFact
	Función que muestra los productos de Facturas creadas previamente para su selección
  	@type
  	@author Verónica Flores
  	@since 26/01/2022
  	@version 1.0
  	@param
  	@return ${return}, ${return_description}
  	@example
  	(examples)
  	@see (links_or_references)
/*/
Function LxMxPFact()
	Local cPergDF     := "MT467F"
	Local aDocs       := {}
	Local aArea       := GetArea()
	Local aTamaho     := MsAdvSize()
	Local oLbx1		  := Nil
	Local aIndx	      := {OemToAnsi(STR0066),OemToAnsi(STR0067)}   //"Factura+serie+Item+Cod producto" ## "Cod producto+Factura+serie"
	Local cIndx	      := aIndx[1]
	Local nOpc        := 0
	Local cBusca      := Space(TAMSX3("D2_DOC")[1]+TAMSX3("D2_SERIE")[1]+TAMSX3("D2_COD")[1]+TAMSX3("D2_ITEM")[1])
	Local oOk	      := LoadBitmap(GetResources(),"LBOK")
	Local oNo	      := LoadBitmap(GetResources(),"LBNO")
	Local oDlgFat     := Nil
	Local bSet15	  := {|| LxMxVldPrd(oLbx1,oDlgFat,@nOpc,aDocs)}
	Local bSet24	  := {|| nOpc:=0, oDlgFat:End()}
	Local bDialogInit := { || EnchoiceBar(oDlgFat,bSet15,bSet24,nil,nil)}
	Local nPosLbx     := 0
	Local oBoton      := Nil
	Local oBusca      := Nil
	Local oMarTodos   := Nil
	Local oDesTodos   := Nil
	Local oInvSelec   := Nil

	Private aCabsSF1  := {}
	Private aCabsSF2  := {}
	Private aItensSD1 := {}
	Private aItensSD2 := {}
	Private cTipo     := ""
	Private cSerComB  := ""
	Private cDocIniCB := ""
	Private cDocFinCB := ""

	If Pergunte(cPergDF,.T.)
		cSerDocF  := MV_PAR01
		cDocIniDF := MV_PAR02
		cDocFinDF := MV_PAR03
		cTes	  := MV_PAR04

		aDocs := LxMxProd(cSerDocF, cDocIniDF, cDocFinDF, M->F2_CLIENTE,M->F2_LOJA)

		If Len(aDocs) == 0
			Aviso(STR0068,STR0069, {STR0070}) //"Facturas" //"No hay información de las facturas solicitadas. Revise los parámetros de selección." //"ok"
			Return Nil
		Else
			DEFINE MSDIALOG oDlgFat FROM aTamaho[1],aTamaho[2] TO aTamaho[6],aTamaho[5] TITLE STR0068 PIXEL   //"Facturas"

			@ c(30),c(05) MSCOMBOBOX oIndx VAR cIndx ITEMS aIndx SIZE c(90),c(10) PIXEL OF oDlgFat
			@ c(30),c(98) BUTTON oBoton PROMPT STR0071 SIZE c(35),c(10) ;//"Buscar"
					 ACTION (oLbx1:nAT := LxMxBusCve(oLbx1,aDocs,cBusca,oIndx:nAT), ;
							oLbx1:bLine := {|| {If(aDocs[oLbx1:nAt,1],oOk,oNo),aDocs[oLbx1:nAt,2],aDocs[oLbx1:nAt,3],aDocs[oLbx1:nAt,4],;
							aDocs[oLbx1:nAt,5],aDocs[oLbx1:nAt,6],aDocs[oLbx1:nAt,7],aDocs[oLbx1:nAt,8],aDocs[oLbx1:nAt,9]}},;
							oLbx1:SetFocus()) PIXEL OF oDlgFat
			@ c(42),c(05)  MSGET oBusca VAR cBusca PICTURE "@!" SIZE c(190),c(10) PIXEL  OF oDlgFat
			@ c(58),c(05)  LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER ;
							OemToAnsi(STR0072),;    		//Check
							OemToAnsi(STR0073),;	        //Serie
							OemToAnsi(STR0074),;            //Factura
							OemToAnsi(STR0075),;	        //Item
							OemToAnsi(STR0076),;			//Cod. Prod
							OemToAnsi(STR0077),;			//Descripción
							OemToAnsi(STR0078),;	    	//Cantidad
							OemToAnsi(STR0079),;	    	//Precio
							OemToAnsi(STR0080);	   			//Importe
					  SIZE aTamaho[3] - 25,IIf(aTamaho[6]>700,(aTamaho[4] * .775)-25, IIf(aTamaho[6]<500,aTamaho[4] * .6,aTamaho[4] * .7)) OF oDlgFat ;
			          PIXEL ON DBLCLICK ((LxMxMarcaI(oLbx1,@aDocs,@oDlgFat),oLbx1:nColPos:= 1,oLbx1:Refresh())) NOSCROLL
			oLbx1:SetArray(aDocs)
			oLbx1:bLine := {|| {If(aDocs[oLbx1:nAt,1],oOk,oNo),aDocs[oLbx1:nAt,2],aDocs[oLbx1:nAt,3],aDocs[oLbx1:nAt,4],;
							aDocs[oLbx1:nAt,5],aDocs[oLbx1:nAt,6],aDocs[oLbx1:nAt,7],aDocs[oLbx1:nAt,8],aDocs[oLbx1:nAt,9]}}
			oLbx1:Refresh()

			@ aTamaho[4] * .953,c(005) BUTTON oMarTodos PROMPT STR0081 SIZE c(45),c(10) ACTION LxMxMarcaI( oLbx1 , @aDocs , @oDlgFat , "M" ) PIXEL OF oDlgFat
			@ aTamaho[4] * .953,c(055) BUTTON oDesTodos PROMPT STR0082 SIZE c(45),c(10) ACTION LxMxMarcaI( oLbx1 , @aDocs , @oDlgFat , "D" ) PIXEL OF oDlgFat
			@ aTamaho[4] * .953,c(110) BUTTON oInvSelec PROMPT STR0083 SIZE c(45),c(10) ACTION LxMxMarcaI( oLbx1 , @aDocs , @oDlgFat , "I" ) PIXEL OF oDlgFat

			ACTIVATE MSDIALOG oDlgFat ON INIT Eval(bDialogInit) CENTERED

			CursorWait()

			If nOpc == 1
				Processa({||LxMxCrgPrd(aDocs,cTes)}, STR0084 )
			EndIf

			DeleteObject(oOk)
			DeleteObject(oNo)
			CursorArrow()
			RestArea(aArea)
		EndIf
	EndIf
Return

/*/{Protheus.doc} LxMxProd
	//Carga los datos de los productos para ser mostrados.
	@author Verónica Flores
	@since 26/01/2022
	@version 1.0
	@return Nil
	@type function
/*/
Static Function LxMxProd(cSerie, cDocIni, cDocFin, cCliente,cLoja)
	Local cAliasTmp := GetNextAlias()
	Local cCampos   := ""
	Local cTablas   := ""
	Local cCond     := ""
	Local cOrder    := ""
	Local aFacturas := {}
	Local nReg 		:= 0
	Local nI		:= 0
	Local nNFDoc    := 0
	Local nNFSer    := 0
	Local nNFItem   := 0
	Local lECampo	:= SD2->(ColumnPos("D2_DESGR1")) > 0

		cCampos	:= "% SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_COD,SD2.D2_ITEM,SD2.D2_PRCVEN,SD2.D2_UM,SD2.D2_LOCAL,SB1.B1_PESO,SB1.B1_DESC,"
		cCampos += IIF(lECampo,"(SD2.D2_QUANT - SD2.D2_DESGR1) as QUANT","(SD2.D2_QUANT) as QUANT") + "%"
		cTablas := "% " + RetSqlName("SD2") + " SD2 ," + RetSqlName("SB1") + " SB1 ," + RetSqlName("SF2") + " SF2 %"
		cCond	:= "% SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
		cCond	+= " AND SF2.F2_DOC = SD2.D2_DOC"
		cCond	+= " AND SB1.B1_COD = SD2.D2_COD"
		cCond	+= " AND SD2.D2_ESPECIE = 'NF'"
		cCond   += IIF(lECampo," AND SD2.D2_QUANT > SD2.D2_DESGR1","")
		cCond	+= " AND SD2.D2_SERIE = '" + cSerie + "'"
		cCond	+= " AND SD2.D2_DOC >= '" + cDocIni + "'"
		cCond	+= " AND SD2.D2_DOC <= '" + cDocFin + "'"
		cCond	+= " AND SD2.D2_NFORI = ''"
		cCond	+= " AND SD2.D2_SERIORI = ''"
		cCond	+= " AND SD2.D2_ITEMORI = ''"
		cCond	+= " AND SF2.F2_TIPODOC = '01'"
		cCond	+= " AND SF2.F2_FECANTF = ''"
		cCond	+= " AND SD2.D_E_L_E_T_  = ' ' "
		cCond	+= " AND SF2.D_E_L_E_T_  = ' ' %"
		cOrder 	:= "% SD2.D2_SERIE, SD2.D2_DOC, SD2.D2_ITEM %"

	BeginSql alias cAliasTmp
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		ORDER BY %exp:cOrder%
	EndSql

	Count to nReg

	If nReg > 0
		dbSelectArea(cAliasTmp)
		(cAliasTmp)->(dbGotop())
		For nI:=1 to Len(aHeader)
			Do Case
				Case  Alltrim(aHeader[nI][2]) == "D2_NFORI"
					nNFDoc   := nI
				Case  Alltrim(aHeader[nI][2]) == "D2_SERIORI"
					nNFSer   := nI
				Case  Alltrim(aHeader[nI][2]) == "D2_ITEMORI"
					nNFItem  := nI
			Endcase
		Next nI

		While  (cAliasTmp)->(!EOF())
			nI := Ascan(aCols,{|x| x[nNFDoc] == (cAliasTmp)->D2_DOC .And. x[nNFSer] == (cAliasTmp)->D2_SERIE .AND. x[nNFItem] == (cAliasTmp)->D2_ITEM .AND. !x[Len(x)]})
			If nI == 0
				aAdd(aFacturas,{.F., ;                                                 //[1]Selección al cargar
								(cAliasTmp)->D2_SERIE, ;                               //[2]Serie
								(cAliasTmp)->D2_DOC, ;                                 //[3]Documento
								(cAliasTmp)->D2_ITEM, ;                                //[4]Item
								(cAliasTmp)->D2_COD, ;                                 //[5]Cod. Producto
								(cAliasTmp)->B1_DESC, ;                                //[6]Descripcion del Producto
								(cAliasTmp)->QUANT, ;                                  //[7]Cantidad
								(cAliasTmp)->D2_PRCVEN, ;                              //[8]Precio de venta
								(cAliasTmp)->QUANT * (cAliasTmp)->D2_PRCVEN, ;		   //[9]Total
								(cAliasTmp)->D2_UM,;								   //[10]Unidad Medida
								(cAliasTmp)->B1_PESO,;								   //[11]Peso
								(cAliasTmp)->D2_LOCAL})                                //[12]Local
			EndIF
			(cAliasTmp)->(dbSkip())
		EndDo
		(cAliasTmp)->( dbCloseArea())
	EndIf
Return aFacturas

/*/{Protheus.doc} LxMxVldPrd
	//Valida que hayan sido seleccionado al menos un producto para el cargado.
	@author Verónica Flores
	@since 26/01/2021
	@version 1.0
	@return Nil
	@type function
/*/
Function LxMxVldPrd(oLbx1, oDlgFat, nOpc, aItems)
	Local lRet  := .F.
	Local nPos  := 0

	nPos := aScan(aItems, {|aVal| aVal[1] == .T.} )
	If  nPos>0
		lRet := .T.
		nOpc := 1
		oDlgFat:End()
	Else
		Aviso(STR0085,STR0086,{STR0070}) //"Productos Factura" //"Es necesario selecionar al menos un producto." //"Ok"
	EndIf
Return lRet

/*/{Protheus.doc} LxMxMarcaI
	//Marca el item para la carga en la factura.
	@author Verónica Flores
	@since 26/01/2022
	@version 1.0
	@return Nil
	@type function
/*/
Function LxMxMarcaI(oLbx1,aItems,oDlgRec,cMarckTip)
	Default cMarckTip := ""
	If Empty( cMarckTip )
		aItems[oLbx1:nAt,1]:= !aItems[oLbx1:nAt,1]
	ElseIf cMarckTip == "M"
		aEval( aItems , { |x,y| aItems[y,1] := .T. } )
	ElseIf cMarckTip == "D"
		aEval( aItems , { |x,y| aItems[y,1] := .F. } )
	ElseIf cMarckTip == "I"
		aEval( aItems , { |x,y| aItems[y,1] := !aItems[y,1] } )
	EndIf
Return Nil

/*/{Protheus.doc} LxMxBusCve
	Realiza la busqueda de la clave indicada.
	@author Verónica Flores
	@since 26/01/2022
	@version 1.0
	@return Nil
	@type function
/*/
Function LxMxBusCve(oLbx1,aItems,cBusca,nIndx)
	Local nPos := 0
	cBusca := Upper(Alltrim(cBusca))
	If  nIndx == 1    //"Factura+serie+Item+Cod producto"
		nPos := aScan(aItems, {|aVal| aVal[3] + aVal[2] + aVal[4] + aVal[5] = Alltrim(cBusca)} ) // valor corto de lado derecho del '=' puede coincidir; es como softseek
	ElseIf nIndx == 2 // "Cod producto+Factura+serie"
		nPos := aScan(aItems, {|aVal| aVal[5] + aVal[3] + aVal[2] = Alltrim(cBusca)} )
	EndIf
	If  nPos == 0
		nPos := oLbx1:nAt
	EndIf
Return nPos


/*/{Protheus.doc} LxMxCrgPrd
	Realiza la carga de productos para la Factura de Traslado.
	@type  Function
	@author Verónica Flores
	@since 26/01/2022
	@version version
	@param aDocs , array , param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function LxMxCrgPrd(aDocs,cTes)
	Local nI 		  := 0
	Local cItem		  := 0
	Local nItem		  := 0
	Local nQuant	  := 0
	Local nCod		  := 0
	Local nVunit	  := 0
	Local nTotal	  := 0
	Local nNFDoc	  := 0
	Local nNFSer      := 0
	Local nNFItem     := 0
	Local nTes  	  := 0
	Local nPeso		  := 0
	Local nLocal	  := 0
	Local nLenAcols   := 0
	Default cTES	  := ""
	Default aDocs     := {}

	For nI:=1 to Len(aHeader)
		Do Case
			Case  Alltrim(aHeader[nI][2]) == "D2_UM"
				nUm      := nI
			Case  Alltrim(aHeader[nI][2]) == "D2_COD"
				nCod     := nI
			Case  Alltrim(aHeader[nI][2]) == "D2_QUANT"
				nQuant   := nI
			Case  Alltrim(aHeader[nI][2]) == "D2_ITEM"
				nItem    := nI
			Case  Alltrim(aHeader[nI][2]) == "D2_PRCVEN"
				nVunit   := nI
			Case  Alltrim(aHeader[nI][2]) == "D2_TOTAL"
				nTotal   := nI
			Case  Alltrim(aHeader[nI][2]) == "D2_NFORI"
				nNFDoc   := nI
			Case  Alltrim(aHeader[nI][2]) == "D2_SERIORI"
				nNFSer   := nI
			Case  Alltrim(aHeader[nI][2]) == "D2_ITEMORI"
				nNFItem  := nI
			Case  Alltrim(aHeader[nI][2]) == "D2_TES"
				nTES     := nI
			Case  Alltrim(aHeader[nI][2]) == "D2_PESO"
				nPeso    := nI
			Case  Alltrim(aHeader[nI][2]) == "D2_LOCAL"
				nLocal   := nI
		Endcase
	Next nI

	cItem		:= aCols[Len(aCols),nItem]
	ProcRegua(Len(aDocs))
	For nI := 1 To Len(aDocs)
		IF aDocs[nI][1] == .T.
			IncProc(STR0087 + "(" + AllTrim(aDocs[nI][3]) + "-" + AllTrim(aDocs[nI][5]) + ")") //"Actualizando items"
			nLenAcols := Len(aCols)
			If !Empty(aCols[nLenAcols,nCod])
				AAdd(aCols,Array(Len(aHeader)+1))
				nLenAcols := Len(aCols)
				cItem := Soma1(cItem)
			Endif
			aCols[nLenAcols][Len(aHeader)+1]:=.F.
			IIF(nUm      >  0  ,  aCOLS[nLenAcols][nUm     ] := aDocs[nI][10]				,)
			IIF(nCod     >  0  ,  aCOLS[nLenAcols][nCod    ] := aDocs[nI][5]				,)
			IIF(nItem    >  0  ,  aCOLS[nLenAcols][nItem   ] := cItem        				,)
			IIF(nVunit   >  0  ,  aCOLS[nLenAcols][nVunit  ] := aDocs[nI][8]				,)
			IIF(nTotal   >  0  ,  aCOLS[nLenAcols][nTotal  ] := aDocs[nI][9]				,)
			IIF(nNFDoc   >  0  ,  aCOLS[nLenAcols][nNFDoc  ] := aDocs[nI][3]				,)
			IIF(nNFSer 	 >  0  ,  aCOLS[nLenAcols][nNFSer  ] := aDocs[nI][2]				,)
			IIF(nNFItem  >  0  ,  aCOLS[nLenAcols][nNFItem ] := aDocs[nI][4]				,)
			IIF(nQuant 	 >  0  ,  aCOLS[nLenAcols][nQuant  ] := aDocs[nI][7]                ,)
			IIF(nTES 	 >  0  ,  aCOLS[nLenAcols][nTES    ] := cTes           				,)
			IIF(nPeso 	 >  0  ,  aCOLS[nLenAcols][nPeso   ] := aDocs[nI][11]  				,)
			IIF(nLocal 	 >  0  ,  aCOLS[nLenAcols][nLocal  ] := aDocs[nI][12]  				,)
			AEval(aHeader,{|x,y| If(aCols[nLenAcols][y]==NIL,aCols[nLenAcols][y]:=CriaVar(x[2]),) })
			MaColsToFis(aHeader,aCols,nLenAcols,"MT100",.T.)
			/* Ejecutar disparadores de producto	*/
			If ExistTrigger("D2_COD") // verifica si existe trigger para este campo
				RunTrigger(2,nLenAcols,,,"D2_COD")
			Endif
		EndIF
	Next nI
	oGetDados:lNewLine:=.F.
	oGetDados:obrowse:refresh()
	Eval(bDoRefresh)
	AtuLoadQt()
Return


/*/{Protheus.doc} LxMXQtdNF
	Valida la cantidad digitada no puede ser mayor a la del documento original.
	@type  Function
	@author Verónica Flores
	@since 26/01/2022
	@version 1.0
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function LxMXQtdNF()

Local aArea 	:= GetArea()
Local aAreaSD2 	:= SD2->(GetArea())
Local lRet  	:= .T.
Local nPosProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_COD"} )
Local nPosNfOri	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_NFORI"} )
Local nPosSerie	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_SERIORI"} )
Local nPosItOri	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEMORI"} )
Local cFilSD2   := xFilial("SD2")
If cPaisLoc == "MEX" .And. aCfgNF[SnTipo] == 21 //Tipo Traslado
	If M->F2_ESPECIE == "NF " .And. !Empty(aCols[N][nPosNfOri]) .And. !Empty(aCols[N][nPosSerie]) .And. !Empty(aCols[N][nPosItOri])
		dbSelectArea("SD2")
		SD2->(dbSetOrder(3))	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		If SD2->(dbSeek(cFilSD2+aCols[N][nPosNfOri]+aCols[N][nPosSerie]+LxMxCliNF(cFilSD2,aCols[N][nPosSerie],aCols[N][nPosNfOri])+aCols[N][nPosProd]+aCols[N][nPosItOri]))//+M->F2_CLIENTE+M->F2_LOJA+aCols[N][nPosProd]+aCols[N][nPosItOri])
			If M->D2_QUANT > (SD2->D2_QUANT - IIF(SD2->(ColumnPos("D2_DESGR1")) > 0 ,SD2->D2_DESGR1,0))
				Aviso(STR0088, STR0089 , {STR0070}) //"Cantidad Producto" // "La cantidad digitada es mayor a la cantidad de la Factura original"// "Ok"
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaSD2)

Return lRet

/*/{Protheus.doc} LxMxAQtDel
	Realiza la actualización de la cantidad de la Fact original cuando se elimina.
	@type  Function
	@author Verónica Flores
	@since 26/01/2022
	@version 1.0
	@param cClave  , Caracter , Es la clave para realizar la busqueda de la factura origen
	@param nCantFA , Numerico , Es la cantidad de la Factura que se esta eliminado.
	@param nTotlFA , Numerico , Es el total de la Factura que se esta eliminado.
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function LxMxAQtDel(cClave,nCantFA,nTotlFA)

Local aAreaSD2	:=	SD2->(GetArea())
Local lECampos	:=  SD2->(ColumnPos("D2_DESGR1")) > 0  .And. SD2->(ColumnPos("D2_DESGR2")) > 0
Local nTamFolio	:= GetSX3Cache("D2_NFORI","X3_TAMANHO")
Local nTamSerie := GetSX3Cache("D2_SERIORI","X3_TAMANHO")
Local nTamCod	:= GetSX3Cache("D2_COD","X3_TAMANHO") + GetSX3Cache("D2_ITEMORI","X3_TAMANHO")
Local cNumDoc   := ""
Local cSerDoc   := ""
Local cNClave	:= ""
Local cFilSD2   := xFilial("SD2")
Default cClave  := ""
Default nTotlFA := 0
Default nCantFA := 0

	cNumDoc := Substr(cClave, 0, nTamFolio)
	cSerDoc := Substr(cClave, nTamFolio + 1, nTamSerie)

	cNClave:= cNumDoc + cSerDoc + LxMxCliNF(cFilSD2,cSerDoc,cNumDoc)+ RIGHT(cClave,nTamCod)
	dbSelectArea("SD2")
	SD2->(dbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If SD2->(dbSeek(cFilSD2+cNClave)) .And. lECampos
		RecLock("SD2",.F.)
		SD2->D2_DESGR1 := Max(0,SD2->D2_DESGR1-nCantFA)
		SD2->D2_DESGR2  := Max(0,SD2->D2_DESGR2-nTotlFA)
		SD2->(MsUnlock())
	EndIf
	RestArea(aAreaSD2)

Return
/*/{Protheus.doc} LxActSF3
	Función que realiza el marcado del registro del documento(NF,NDC,NCC) en la tabla SF3
	utilizado para la cancelación CDFI.
	@type  Function
	@author eduardo.manriquez
	@since 20/02/2022
	@version 1.0
	@param cMotivo  , Caracter , Es la clave para realizar la busqueda de la factura origen
	@param cMotivo , Numerico , Es la cantidad de la Factura que se esta eliminado.
	@param cSerie , Numerico , Es el total de la Factura que se esta eliminado.
	@param cNomXml , Numerico , Es el total de la Factura que se esta eliminado.
	@param cUUID , Numerico , Es el total de la Factura que se esta eliminado.
	@return
	@example
	LxActSF3(cMotivo,cMotivo,cSerie,cNomXml,cUUID)
	@see (links_or_references)
/*/
Function LxActSF3(cMotivo,cNumDoc,cSerie,cNomXml,cUUID)
	Local aAreaSF3	:=	SF3->(GetArea())
	Local cFilSF3   := xFilial("SF3")
	Default cMotivo := ""
	Default cNumDoc := ""
	Default cSerie  := ""
	Default cNomXml := ""
	Default cUUID   := ""

	If SF3->(ColumnPos("F3_MOTIVO")) > 0 .And. SF3->(ColumnPos("F3_STATUS")) > 0 .And. SF3->(ColumnPos("F3_CNATREC")) > 0 .And. SF3->(ColumnPos("F3_CODNFE")) > 0
		dbSelectArea("SF3")
		SF3->(dbSetOrder(6)) //F3_FILIAL+F3_NFISCAL+F3_SERIE
		If SF3->(dbSeek(cFilSF3+cNumDoc+cSerie))
			RecLock("SF3",.F.)
				SF3->F3_MOTIVO := cMotivo
				SF3->F3_STATUS := "S"
				SF3->F3_CNATREC := cUUID
				SF3->F3_CODNFE := cNomXml
			MsUnlock("SF3")
		EndIf
	Endif
	RestArea(aAreaSF3)
Return Nil

/*/{Protheus.doc} LxVDocSus
	Validaciones para tipo de relación 04 - Sustitución de los CFDI Previos
	@type  Function
	@author Luis.Enríquez
	@since 20/02/2022
	@version 1.0
	@param cSerSus  , Caracter , Serie del Documento a Cancelar ante el SAT.
	@param cDocSus , Caracter , Número del Documento a Cancelar ante el SAT.
	@return cAviSus, Caracter, Descripción de validaciones.
	@see (links_or_references)
/*/
Function LxVDocSus(cSerSus, cDocSus)
	Local cAliasSF3:= xFilial("SF3")
	Local aAreaSF3 :=	SF3->(GetArea())
	Local cAliasSF := getNextAlias()
	Local cCRLF	   := (chr(13)+chr(10))
	Local lRet     := .T.
	Local cAviSus  := ""
	Local lCpoSF1  := SF1->(ColumnPos("F1_SERMAN")) > 0 .And. SF1->(ColumnPos("F1_DOCMAN")) > 0
	Local lCpoSF2  := SF2->(ColumnPos("F2_SERMAN")) > 0 .And. SF2->(ColumnPos("F2_DOCMAN")) > 0
	Local lExisDoc := .F.

	Default nNFTipo  := 0
	Default cSerSus  := ""
	Default cDocSus  := ""

	If !Empty(cDocSus)
		If (lCpoSF1 .Or. lCpoSF2)
			If (nNFTipo == 1 .Or. nNFTipo == 2 .Or. nNFTipo == 4) .And. (lCpoSF1 .Or. lCpoSF2) //Factura de Venta - Nota de Débito - Nota de Crédito
				If !Empty(cSerSus) .Or. !Empty(cDocSus)
					DbSelectArea("SF3")
					SF3->(DbSetOrder(5)) //F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT
					If SF3->(DbSeek( cAliasSF3 + cSerSus + cDocSus))
						While SF3->(!Eof()) .And. (SF3->F3_FILIAL+SF3->F3_SERIE+SF3->F3_NFISCAL) == (cAliasSF3 + cSerSus + cDocSus)
							If Alltrim(F3_ESPECIE) == Alltrim(cEspecie)
								If SF3->F3_STATUS == "S"
									lExisDoc := .T.
								EndIf
							EndIf
							SF3->(DbSkip())
						EndDo
					EndIf
					If !lExisDoc
						cAviSus += StrTran(STR0090,"###",Alltrim(cSerSus) + "-" + Alltrim(cDocSus)) + cCRLF //"- El documento ###, no se encuentra Anulado y sin solicitud de Cancelación ante el SAT."
					EndIf
				EndIf
			EndIf

			If lExisDoc
				If nNFTipo == 4
					BeginSql alias cAliasSF
						SELECT F1_SERIE AS SERIE, F1_DOC AS DOC
						FROM %table:SF1% SF1
						WHERE SF1.F1_FILIAL = %xFilial:SF1%
						AND F1_SERMAN = %exp:cSerSus%
						AND F1_DOCMAN = %exp:cDocSus%
						AND SF1.%notDel%
					EndSql
				ElseIf nNFTipo == 1 .Or. nNFTipo == 2
					BeginSql alias cAliasSF
						SELECT F2_SERIE AS SERIE, F2_DOC AS DOC
						FROM %table:SF2% SF2
						WHERE SF2.F2_FILIAL = %xFilial:SF2%
						AND F2_SERMAN = %exp:cSerSus%
						AND F2_DOCMAN = %exp:cDocSus%
						AND SF2.%notDel%
					EndSql
				EndIf

				count to nCount

				If nCount > 0
					dbSelectArea(cAliasSF)
					(cAliasSF)->(dbGoTop())

					While (cAliasSF)->(!Eof())
						cDocExt := Alltrim((cAliasSF)->SERIE) + "/" + Alltrim((cAliasSF)->DOC)
						(cAliasSF)->(dBSkip())
					EndDo
					If !Empty(cDocExt)
						cAviSus += IIf(!Empty(cAviSus),cCRLF,"") + StrTran(STR0091,"###",Alltrim(cSerSus) + "-" + Alltrim(cDocSus)) + cCRLF + STR0093 + cCRLF + cDocExt //"- El documento ### a sustituir," //"ya se encuentra asigado al documento: "
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If !Empty(cAviSus)
		lRet := .F.
		Aviso(STR0092,cAviSus,{STR0070}) //"Atención" //"Ok"
	EndIf
	RestArea(aAreaSF3)
Return lRet

/*/{Protheus.doc} LxMxCliNF
	Busca el Cliente y Tienda del item del Documento Seleccionado.
	@type  Function
	@author Verónica.Flores
	@since 13/07/2022
	@version 1.0
	@param cFilSD2  , Caracter , Filil de la Tabla SD2
	@param cSerie  , Caracter , Serie del Documento Origen a Buscar
	@param cFolio , Caracter , Número del Documento Origen a Buscar.
	@return cRet, Caracter, Cliente y Tienda del Documento.
	@see (links_or_references)
/*/
Function LxMxCliNF(cFilSD2, cSerie, cFolio)

	Local aArea 	:= GetArea()
	Local aAreaSF2 	:= SF2->(GetArea())
	Local cRet  	:= ""

	Default cFilSD2 := xFilial("SD2")
	Default cSerie  := ""
	Default cFolio  := ""

	If cPaisLoc == "MEX" .And. aCfgNF[SnTipo] == 21 //Tipo Traslado
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->(dbSeek(cFilSD2+cFolio+cSerie))
				cRet := SF2->F2_CLIENTE+SF2->F2_LOJA
			EndIf
	EndIf

	RestArea(aAreaSF2)
	RestArea(aArea)


Return cRet

/*/{Protheus.doc} LxCPAuto
	Carta Porte por rutina automática
	@type    Function
	@author  ARodriguez
	@since   15/07/2022
	@version 1.0
	@param cAlias, caracter, Alias del documento.
	@param cFilDoc, caracter, Filial del documento (SF2).
	@param cNumDoc, caracter, Folio del documento.
	@param cSerieDoc, caracter, Serie del documento.
	@param cEsp, arreglo, Especie del documento.
	@param lCarPor, lógica, Indica si el documento tiene activo el campo de Carta Porte (F2_TPCOMPL='S').
	@param lVldTim, lógica, Indica si realiza validación para verificar si el documento ya fue timbrado.
	@param aCartaPorte, arreglo, matriz con datos de cada tabla
	@return lRet, lógica, grabada con éxito
	/*/
Function LxCPAuto(cAlias, cFilDoc, cNumDoc, cSerieDoc, cEsp, lCarPor, lVldTim, aCartaPorte)
	Local oModel 	:= Nil
	Local oModelA1X := Nil
	Local oModelA1Y := Nil
	Local oModelA1Z := Nil
	Local oModelAE0 := Nil
	Local cFilA1Y	:= xFilial("A1Y")
	Local cFilA1Z	:= xFilial("A1Z")
	Local cFilAE0	:= xFilial("AE0")
	Local bCommit
	Local nX		:= 0
	Local lRet		:= .T.
	Local cLog		:= ""

	oModel := FWLoadModel("MATA487")
	oModel:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
	oModel:Activate()

	oModelA1X := oModel:GetModel('A1XMASTER')
	oModelA1Y := oModel:GetModel('A1YDETAIL')
	oModelA1Z := oModel:GetModel('A1ZDETAIL')
	oModelAE0 := oModel:GetModel('AE0DETAIL')

	// 1. Campos generales
	If aCartaPorte[1] != NIL
		oModelA1X:SetValue("A1X_FILIAL",xFilial("A1X"))
		oModelA1X:SetValue("A1X_DOC",cNumDoc)
		oModelA1X:SetValue("A1X_SERIE",cSerieDoc)

		LxArray2Model(oModelA1X, aCartaPorte[1], STR0096, 0, @cLog) // "Generales: "
	EndIf

	// 2. Ubicaciones
	If aCartaPorte[2] != NIL
		For nX := 1 to Len(aCartaPorte[2])
			If nX > 1
				oModelA1Y:AddLine()
			EndIf

			oModelA1Y:GoLine(nX)

			IIf(Empty(oModelA1Y:GetValue("A1Y_FILIAL")), oModelA1Y:SetValue("A1Y_FILIAL",cFilA1Y), )
			IIf(Empty(oModelA1Y:GetValue("A1Y_DOC")), oModelA1Y:SetValue("A1Y_DOC",cNumDoc), )
			IIf(Empty(oModelA1Y:GetValue("A1Y_SERIE")), oModelA1Y:SetValue("A1Y_SERIE",cSerieDoc), )
			IIf(Empty(oModelA1Y:GetValue("A1Y_ITEM")), oModelA1Y:SetValue("A1Y_ITEM",StrZero(nX,2)), )

			LxArray2Model(oModelA1Y, aCartaPorte[2][nX], STR0097, nX, @cLog) // "Ubicaciones: "
		Next nX
	EndIf

	// 3. Operadores
	If aCartaPorte[3] != NIL
		For nX := 1 to Len(aCartaPorte[3])
			If nX > 1
				oModelA1Z:AddLine()
			EndIf

			oModelA1Z:GoLine(nX)

			IIf(Empty(oModelA1Z:GetValue("A1Z_FILIAL")), oModelA1Z:SetValue("A1Z_FILIAL",cFilA1Z), )
			IIf(Empty(oModelA1Z:GetValue("A1Z_DOC")), oModelA1Z:SetValue("A1Z_DOC",cNumDoc), )
			IIf(Empty(oModelA1Z:GetValue("A1Z_SERIE")), oModelA1Z:SetValue("A1Z_SERIE",cSerieDoc), )
			IIf(Empty(oModelA1Z:GetValue("A1Z_ITEM")), oModelA1Z:SetValue("A1Z_ITEM",StrZero(nX,2)), )

			LxArray2Model(oModelA1Z, aCartaPorte[3][nX], STR0098, nX, @cLog) // "Operadores: "
		Next nX
	EndIf

	// 4. Propietarios/Arrendatarios
	If aCartaPorte[4] != NIL
		For nX := 1 to Len(aCartaPorte[4])
			If nX > 1
				oModelAE0:AddLine()
			EndIf

			oModelAE0:GoLine(nX)

			IIf(Empty(oModelAE0:GetValue("AE0_FILIAL")), oModelAE0:SetValue("AE0_FILIAL",cFilAE0), )
			IIf(Empty(oModelAE0:GetValue("AE0_DOC")), oModelAE0:SetValue("AE0_DOC",cNumDoc), )
			IIf(Empty(oModelAE0:GetValue("AE0_SERIE")), oModelAE0:SetValue("AE0_SERIE",cSerieDoc), )
			IIf(Empty(oModelAE0:GetValue("AE0_ITEM")), oModelAE0:SetValue("AE0_ITEM",StrZero(nX,2)), )

			LxArray2Model(oModelAE0, aCartaPorte[4][nX], STR0099, nX, @cLog) // "Propietarios/Arrendatarios: "
		Next nX
	EndIf

	bCommit := {|| FWFormCommit(oModel)}
	oModel:setCommit(bCommit)

	// Validación
	If oModel:VldData()
		// Grabar tablas
		oModel:CommitData()

	Else
		lRet := .F.
		cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])

	EndIf

	If !lRet
		// Generar log de error
		Help( , , STR0095, , cLog, 1, 0 ) // "CARTA PORTE"
	Endif

	oModel:DeActivate()
	FreeObj(oModelA1X)
	FreeObj(oModelA1Y)
	FreeObj(oModelA1Z)
	FreeObj(oModelAE0)
	FreeObj(oModel)

Return lRet

/*/{Protheus.doc} LxArray2Model
	Asigna campos a modelo, valida cada asignación y el ítem (línea del grid correspondiente).
	@type    Static Function
	@author  ARodriguez
	@since   18/07/2022
	@version 1.0
	@param   oModel, object, modelo padre/hijo
	@param   aCampos, array, campos a asignar {campo, valor}
	@param   cTabla, caracter, descripción de la tabla/grid/modelo
	@param   nReg, numeric, número de ítem; cero si es modelo padre
	@param   cLog, caracter, log de mensajes
	@return  lRet, logical, indica si hay error
/*/
Static Function LxArray2Model(oModel, aCampos, cTabla, nReg, cLog)
	Local nX	:= 0
	Local lRet	:= .T.

	For nX := 1 to Len(aCampos)
		If !oModel:SetValue(aCampos[nX][1], aCampos[nX][2])
			lRet := .F.
			cLog += cTabla + STR0101 + aCampos[nX][1] + IIf(nReg > 0, ", " + STR0075 + " " + StrZero(nReg,2), "") + CRLF // "Error al asignar el campo " ## "Item"
		EndIf
	Next

	If nReg > 0 .And. !oModel:VldLineData(.F.)
		lRet := .F.
		cLog += cTabla + STR0102 + StrZero(nReg,2) + CRLF // "Errores en la validaión del ítem "
	EndIf

Return lRet

/*/{Protheus.doc} xGrvCabMex
	Graba timbre fiscal digital
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param aCfgNF, nNFTipo, cPathXML, cFunName
	@return Nil
	/*/
Function xGrvCabMex(aCfgNF, nNFTipo, cPathXML, cFunName)
Default aCfgNF   := {}
Default nNFTipo  := 0
Default cPathXML := ""
Default cFunName := Funname()

	//factura de entrada para Mexico y actualiza nuevo folio fiscal
	If AliasInDic("CPP") //Verifica país México y que exite la Tabla CPP
		if aCfgNF[SAliasHead] == "SF1" .And. (nNFTipo == 10 .or. nNFTipo == 12 .or. nNFTipo == 13 .or. nNFTipo == 14  )//Fac Norma //Benef.//Gastos Impor/Flete //Conoc. Transporte
			If (AliasInDic("CPP") .and. (Type("cFunName")<>"U" .and. cFunName == "MATA459"))
				SF1->(RecLock("SF1",.F.))
				SF1->F1_UUID:=CPP->CPP_UUID
				SF1->F1_FECTIMB:=CPP->CPP_FECTIM
				SF1->F1_RUTDOC:=CPP->CPP_RUTDOC
				SF1->(MsUnlock())
			Elseif ( SF1->(FieldPos("F1_RUTDOC")) >0 .And. !Empty(cPathXML) ) .AND. ( SF1->(FieldPos("F1_UUID"))>0 .And. !Empty(SF1->F1_UUID) ) .AND. (Type("cFunName")<>"U" .and. cFunName == "MATA101N")
				SF1->(RecLock("SF1",.F.))
				SF1->F1_RUTDOC := cPathXML
				SF1->(MsUnlock())
				copyXML()
			Endif
		Endif
	endif
	If SF2->(FieldPos("F2_RUTDOC")) > 0 .And. nNFTipo == 7
		If !Empty(cPathXML)
			SF2->(RecLock("SF2",.F.))
			SF2->F2_RUTDOC := cPathXML
			SF2->(MsUnlock())
			copyXML()
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} xCartPorte
	Graba información de carta porte
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param oModelAct, cFunName, lLocxAuto, aCartaPorte, lRet
	@return Nil
	/*/
Function xCartPorte(oModelAct, cFunName, lLocxAuto, aCartaPorte, lRet)
Default oModelAct   := Nil
Default cFunName    := Funname()
Default lLocxAuto   := .F.
Default aCartaPorte := {}
Default lRet        := .T.

	If oModelAct <> Nil
		//Guarda resgitros para Carta Porte
		If oModelAct:lActivate
			M487COMMIT()
		EndIf
	ElseIf lLocxAuto .And. aCartaPorte != Nil .And. Len(aCartaPorte) > 0
		// NF x rutina automática con carta porte; si hay error de datos de la Carta Porte, no genera la factura
		lRet := LxCPAuto("SF2",M->F2_FILIAL,M->F2_DOC,M->F2_SERIE,M->F2_ESPECIE,.T.,.F.,aCartaPorte)
	EndIf
Return 

/*/{Protheus.doc} xGenXmlMex
	Valida si el documento fue timbrado
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param lGerarCFD, cPrefC
	@return Nil
	/*/
Function xGenXmlMex(lGerarCFD, cPrefC)
Local lGenXML     := .T.

Default lGerarCFD := .F.
Default cPrefC    := ""

	If lGerarCFD
		If cPrefC=="SF1->F1"
			lGenXML := !Empty(SF1->F1_UUID)
		ElseIf cPrefC=="SF2->F2"
			lGenXML := !Empty(SF2->F2_UUID)
		EndIf
		If !lGenXML
			MsgAlert(STR0103,STR0104)	//"El CFDI no fue generado/timbrado, el folio fiscal (UUID) en los asientos contables se grabará hasta realizar ese proceso."
		EndIf
	EndIf
Return

/*/{Protheus.doc} xItNFMex
	Graba información de campos D2_DESGR1 y D2_DESGR2 de documento origen.
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param cFilSD2
	@return Nil
	/*/
Function xItNFMex(cFilSD2)
Local nCantFA := 0
Local nTotlFA := 0

Default cFilSD2 := ""

	nCantFA := SD2 ->D2_QUANT
	nTotlFA := SD2 ->D2_TOTAL
	If SD2->( dbSeek(cFilSD2+SD2->D2_NFORI+SD2->D2_SERIORI+LxMxCliNF(cFilSD2,SD2->D2_SERIORI,SD2->D2_NFORI)+SD2->D2_COD+SD2->D2_ITEMORI) )
		RecLock("SD2",.F.)
		SD2->D2_DESGR1 := SD2->D2_DESGR1 + nCantFA
		SD2->D2_DESGR2  := SD2->D2_DESGR2  + nTotlFA
		MsUnlock("SD2")
	EndIf
Return

/*/{Protheus.doc} xVldNatMex
	Validación naturaleza 
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param aCfgNf, cNatureza, cAliasI, aCpItens, aCItens
	@return lRet
	/*/
Function xVldNatMex(aCfgNf, cNatureza, cAliasI, aCpItens, aCItens)
Local lRet := .T.

Default aCfgNf := {}
Default cNatureza := ""
Default cAliasI   := ""
Default aCpItens  := {}
Default aCItens   := {}

	If Empty(aCfgNf)
		Return lRet
	EndIf

	If aCfgNF[SnTipo] <> 20
		If !Empty(M->F1_NATUREZ)
			MaFisAlt("NF_NATUREZA",M->F1_NATUREZ)
			cNatureza:=M->F1_NATUREZ
		EndIf
	Endif

	If (aCfgNf[SnTipo] == 20)
		If Empty(MaFisRet(,"NF_NATUREZA"))
			Aviso(STR0105,STR0106,{STR0107}) //"Preencha o codigo da natureza!"###"OK"
			lRet := .F.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} NfTudOkMex
	Validaciones generales antes del grabado del documento
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param aCfgNf, aCpItens, aCitens, nLinha, nNFTipo, cAliasC, nItemSrv, lGerarCFD, OAPP, cFilAnt, cSerie, cnFiscal, cEspecie, aCabNotaOri, aCabNota, cFunName
	@return lRet
	/*/
Function NfTudOkMex(aCfgNf, aCpItens, aCitens, nLinha, nNFTipo, cAliasC, nItemSrv, lGerarCFD, OAPP, cFilAnt, cSerie, cnFiscal, cEspecie, aCabNotaOri, aCabNota, cFunName)
Local nPosRelSat := Ascan(aCfgNf[SaCposBr], {|x,y| ALLTRIM(x[2])=="F2_RELSAT"})
Local nPosUsoCFD := Ascan(aCfgNf[SaCposBr], {|x,y| ALLTRIM(x[2])=="F2_USOCFDI"})
Local nPosRelCFD := Ascan(aCfgNf[SaCposBr], {|x,y| ALLTRIM(x[2])=="F2_UUIDREL"})
Local nPosCP     := Ascan(aCabNotaOri[1], AllTrim("F2_TPCOMPL"))
Local lRet       := .T.
Local lCfdi40    := SuperGetMV("MV_CFDI40",.F.,.F.)

Default aCfgNf    := {}
Default aCpItens  := {}
Default aCitens   := {}
Default nLinha    := 0
Default nNFTipo   := 0
Default cAliasC   := ""
Default nItemSrv  := 0
Default lGerarCFD := .F.
Default OAPP      := Nil
Default cFilAnt   := ""
Default cSerie    := ""
Default cnFiscal  := ""
Default cEspecie  := ""
Default aCabNotaOri := {}

If lRet .and. Valtype(aCfgNF[SlFormProp]) == "L" .And. aCfgNF[SlFormProp] .And. (!Str(aCfgNF[SnTipo],2)$"54|64|50|60|63|")
	If lGerarCFD
		lRet := CFDChkFol( cFilAnt,cSerie,	, cnFiscal,,, cEspecie ) <> 2
	EndIf
EndIf

//Validación de Carta Porte
If lRet .And. nNFTipo == 1 .And. nPosCP > 0 .And. aCabNota[2][nPosCP] =='S' .And. nItemSrv == 0 
	lRet := .F.
	MsgAlert(StrTran(STR0114,"###",Alltrim(FWX3Titulo('B1_TIPO')))) //"Para Facturas de Tipo Normal (Ingresos) con Complemento de Carta Porte, se debe indicar al menos un Producto configurado como Servicio (Con el campo ### (B1_TIPO) igual a 'SV')"
EndIf

If lRet .And. cAliasC $ "SF2|SF1" .And. ((OAPP:CMODNAME == "SIGAFAT" .And. cFunName == "MATA467N" .And. aCfgNf[SAliasHead] == "SF2" .And. (nNFTipo == 1 .or. nNFTipo == 21) .And. SuperGetMV("MV_CFDIEXP", .F., .F.)) .Or. (OAPP:CMODNAME == "SIGAFAT" .And. cFunName == "MATA465N" .And. aCfgNf[SAliasHead] == "SF1" .And. nNFTipo == 4 .And. SuperGetMV("MV_CFDIEXP", .F., .F.)))
	lRet := ValCmObCE(cAliasC, nLinha, aCpItens, aCitens)
EndIf

//Validación para campos de Relación CDF y UsoCDFI - México. Cabecera
If lRet .And. aCfgNf[SAliasHead] $ "SF2|SF1" .And. (nNFTipo == 21 .Or. nNFTipo == 1 .Or. nNFTipo == 2 .Or. nNFTipo == 4) .And. lGerarCFD
	If nPosRelSat > 0 .And. nNFTipo == 21
		lRet := ValRetSat(&(ALLTRIM(aCfgNf[SaCposBr][nPosRelSat][2])),ALLTRIM(aCfgNf[SaCposBr][nPosRelSat][2]))
	EndIF
	If lCfdi40 .And. nPosRelCFD > 0 .And. lRet .And. nNFTipo <> 21
		lRet := ValRetSat(&(ALLTRIM(aCfgNf[SaCposBr][nPosRelCFD][2])),ALLTRIM(aCfgNf[SaCposBr][nPosRelCFD][2]))
	Endif
	If nPosUsoCFD > 0 .And. lRet
		lRet := ValRetSat(&(ALLTRIM(aCfgNf[SaCposBr][nPosUsoCFD][2])),ALLTRIM(aCfgNf[SaCposBr][nPosUsoCFD][2]))
	EndIF
	If nPosRelCFD > 0 .And. lRet .And. nNFTipo == 21
		lRet := ValRetSat(&(ALLTRIM(aCfgNf[SaCposBr][nPosRelCFD][2])),ALLTRIM(aCfgNf[SaCposBr][nPosRelCFD][2]))
	EndIF
	If cFunName == "MATA465N" .And. lRet .And. aCfgNf[ScEspecie] $ "NCC"
		lRet := ValRetSat(M->F1_USOCFDI, "F1_USOCFDI")
	EndIF
	If lRet .AND. SuperGetMV("MV_CFDIEXP", .F., .F.) .And. nNFTipo == 1 .And. SF2->(ColumnPos("F2_CONUNI")) > 0
		lRet := ValIMMEX(M->F2_CONUNI,M->F2_CLIENTE,M->F2_LOJA,"1","F2")
	EndIF
EndIf

Return lRet

/*/{Protheus.doc} LxDelNfMex
	Validaciones generales en el borrado de un documento.
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param cAlias, lCanCFDi
	@return lRet
	/*/
Function LxDelNfMex(cAlias, lCanCFDi)
Local lRet := .T.

	If AliasInDic("CPP") .And. cAlias <> "SF2" //Verifica país México y que exite la Tabla CPP
		DbSelectArea("CPP")
		CPP->(DBSETORDER(2))
		If CPP->(DbSeek(XFILIAL("CPP")+ SF1->F1_UUID))//verifica vinculacion de las tablas CPP y SF1
			RecLock("CPP",.f. ) //---BLOQUEA EL REGISTRO
			CPP->CPP_STATUS := ''  //Cambia el Estatus de la Pre-factura
			CPP->(MsUnlock())
		EndIf
	EndIf

	IF (SD1->(FieldPos("D1_PEDIM"))) >0 .AND. FUNNAME()=='MATA101N'
		lRet:= .t.
		SD1->(DBSETORDER(1))
		IF SD1->(DBSEEK(XFILIAL("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) )
			IF !EMPTY(SD1->D1_PEDIM)
				msgalert(STR0115) //"Esta factura fué generada por un pedimento!, Para eliminarla debe hacerlo desde la opción de Pedimento"
				lRet:= .f.
			ENDIF
		ENDIF
		RSE->(DBSETORDER(3))  //Si la factura ya tiene uan extraccion en un pedimento no permitira borrarla.
		IF RSE->(DBSEEK(XFILIAL("RSE")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) )
			IF RSE->RSE_EXTFAC=='EF'
				msgalert(STR0116+rsE->rsE_NUMPED+STR0117)//"Esta factura tiene extracciones en el pedimento " ## " y no permite borrarla. Eliminela del pedimento y vuelva a intentar!"
				lRet:= .f.
			ENDIF
		ENDIF
	ENDIF

	IF SF2->F2_TIPODOC=='07' .AND. (SD2->(FieldPos("D2_NUMPED"))) >0 .AND. FUNNAME()=='MATA466N'  //NCR generada por rectificacion de pedimentos Mexico
		lRet:= .t.
		SD2->(DBSETORDER(3))
		IF SD2->(DBSEEK(XFILIAL("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)) )
			IF !EMPTY(SD2->D2_NUMPED)
				msgalert(STR0118) //"Esta Nota fue generada por un pedimento de Rectificacion!, Para eliminarla debe hacerlo desde la opción de Pedimento"
				lRet:= .f.
			ENDIF
		ENDIF
	ENDIF

	IF SF1->F1_TIPODOC=='09' .AND. (SD1->(FieldPos("D1_PEDIM"))) >0 .AND. FUNNAME()=='MATA466N'  //NCR generada por rectificacion de pedimentos Mexico
		lRet:= .t.
		SD1->(DBSETORDER(1))
		IF SD1->(DBSEEK(XFILIAL("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) )
			IF !EMPTY(SD1->D1_PEDIM)
				msgalert(STR0118) //"Esta Nota fue generada por un pedimento de Rectificacion!, Para eliminarla debe hacerlo desde la opción de Pedimento"
				lRet:= .f.
			ENDIF
		ENDIF
	ENDIF

	If lRet
		Do Case
			Case cAlias == "SF2"
				If (lCanCFDi) .And. (SF2->(FieldPos("F2_TIMBRE"))) >0
					If  !Empty(SF2->F2_TIMBRE)
						If !FISA801()  //Cancelacion de la factura
							Return .F.
						Endif
					Endif
				Endif
			Case  cAlias =="SF1"
				If (lCanCFDi) .And. (SF1->(FieldPos("F1_TIMBRE"))) >0
					If  !Empty(SF1->F1_TIMBRE)
						If !FISA801()  //Cancelacion de la factura
							Return .F.
						Endif
					Endif
				Endif
		EndCase
	EndIf

Return lRet

/*/{Protheus.doc} LxUUIDRel
	Obtener documentos con UUID relacionado
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param aCols, lUUID, aFiltro, aRet, nNFOri, nItemOri, cAliasTRB, cAliasCab, cWhile, cSeek, aCposF4, cTipoDoc, cCondicao
	@return Nil
	/*/
Function LxUUIDRel(aCols, lUUID, aFiltro, aRet, nNFOri, nItemOri, cAliasTRB, cAliasCab, cWhile, cSeek, aCposF4, cTipoDoc, cCondicao)
Local cCtrl := CHR(13) + CHR(10)
Local nI    := 0
Private aFilUUID   := {}
Private cCondUUID  := ""

	DbSelectArea(cAliasTRB)
    M->F1_UUIDREL := ""
    While (cAliasTRB)->(!Eof())
    	nI := Ascan(aCols,{|x| x[nNFOri] == (cAliasTRB)->D2_DOC .AND. x[nItemOri] == (cAliasTRB)->D2_ITEM .AND. !x[Len(x)]})
		If nI == 0
			Aadd(aFiltro, (cAliasTRB)->D2_FILIAL + (cAliasTRB)->D2_DOC + (cAliasTRB)->D2_SERIE + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA + (cAliasTRB)->D2_TIPODOC)
		Else
			If !(AllTrim((cAliasTRB)->F2_UUID) $ M->F1_UUIDREL)
				M->F1_UUIDREL +=  AllTrim((cAliasTRB)->F2_UUID) + cCtrl
			EndIf
		Endif
		(cAliasTRB)->(DbSkip())
	EndDo
	(cAliasTRB)->(DbCloseArea())

	If !Empty(aFiltro)
		If lUUID
			aFilUUID  := STRTOKARR(M->F1_UUIDREL, CRLF)
			cCondUUID := "Ascan(aFilUUID,SF2->(F2_UUID)) > 0 "

			aRet := LocxF4(cAliasCab,2,cWhile,cSeek,aCposF4,,IIf(cTipoDoc =="'50'",GetDescRem(),STR0119),cCondicao,.T.,cCondUUID,,,,.F.)  // Retorn

			If (aRet <> NIL)
				If lUUID .and. ( aRet[2] != NIL .and. valtype(aRet[2]) <> "U")
					nPosUUID := aScan(aRet[1], { |x| AllTrim(x) == "F2_UUID"})
					For nI := 1 To Len(aRet[2])
						If !(alltrim(aRet[2][nI][nPosUUID]) $ M->F1_UUIDREL)
							M->F1_UUIDREL +=  alltrim(aRet[2][nI][nPosUUID]) + cCtrl
						EndIf
					Next nI
				EndIf
			EndIf
		EndIf
	EndIf

Return

/*/{Protheus.doc} xConPagMex
	Validación condición de pago
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param cCondicao, cParcela, lPParc
	@return Nil
	/*/
Function xConPagMex(cCondicao, cParcela, lPParc)
Local aParcela := {}
Local nX := 0

	aAreaSE4 := GetArea()
	DbSelectArea("SE4")
	SE4->(dbSetOrder(1)) //E4_FILIAL + E4_CODIGO
	If (SE4->(DbSeek(xFilial("SE4")+cCondicao)))
		aParcela := STRTOKARR( ALLTRIM(SE4->E4_COND) , "," )
		For nX := 1 To Len(aParcela)
			If Len(aParcela) > 1
				IF Val(aParcela[nX]) > 0
					lPParc	:= .T.
					Exit
				Else
					lPParc	:= .F.
					Loop
				EndIf
			Else
				If Val(aParcela[nX]) > 0
					lPParc	:= .T.
				Else
					lPParc	:= .F.
				EndIf
			EndIf
		Next
	Endif
	RestArea(aAreaSE4)

	cParcela := IIF( lPParc , SuperGetMV("MV_1DUP   ") , " " )

Return

/*/{Protheus.doc} xLinOkMex
	Validaciones de linea de documentos
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param cAliasI,aCposIOri,aDadosIOri,cTipDoc,nLinha
	@return lRet
	/*/
Function xLinOkMex(cAliasI,aCposIOri,aDadosIOri,cTipDoc,nLinha,lFormP,bDoRefresh,bListRefresh)
Local cTes 		:= ""
Local lRet 		:= .T.
Local nPos 		:= 0
Local nX   		:= 0
Local nAdt 		:= Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_VALADI'})
Local nTot 		:= Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_TOTAL'})
Local nTpDoc    := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_TIPODOC'})
Local nPeso     := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_PESO'}) //Peso
Local nMatPel   := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_METODO'}) //Es Material Peligoso
Local nCveMatP  := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_GRPCST'}) //Clave Material Peligoso
Local nEmbala   := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_TNATREC'}) //Código de Embalaje
Local nPrcVen   := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_PRCVEN'}) //Precio de Venta 
Local nCodPro   := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_COD'}) //Código de Producto
Local cFilSF4   := xFilial("SF4")
Local cMsgVld   := ""
Local cPrefSD   := PrefixoCpo(cAliasI)
Local cCRLF	    := (chr(13)+chr(10))
Local cProSer   := ""

If cAliasI $ "|SD2|SD1|"
	If cTipDoc == "A"
		nPos = Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_TES'})
		If nPos > 0
			For nX := 1 To Len(aDadosIOri)
				If !aDadosIOri[nX][Len(aDadosIOri[nX])]
					If cTes == ""
						cTes := aDadosIOri[nX][nPos]
						//Verificar se a tes gera duplicata e nao movimenta estoque
						DbSelectArea("SF4")
						DbSetOrder(1)
						If MsSeek(cFilSF4+cTes) .AND. (SF4->F4_ESTOQUE == "S" .OR. SF4->F4_DUPLIC == "N")
							if cAliasI == "SD1"
								Aviso(STR0120,STR0121,{STR0070}) //Atenção#"En la operacion de anticipo el TES utilizado debe afectar financiero y no movilizar stock."#OK
							else
								Aviso(STR0120,STR0122,{STR0070}) //Atenção#"Na operação de adiantamento o TES utilizado deve gerar duplicata e não movimentar estoque."#OK
							endif
							lRet := .F.
							Exit
						EndIf
					ElseIf aDadosIOri[nX][nPos] <> cTes
						if cAliasI == "SD1"
							Aviso(STR0120,STR0123,{STR0070}) //Atenção#"En la operacion de anticipo los items de la Nota de Entrada deben poseer el mismo TES."#OK
						else
							Aviso(STR0120,STR0124,{STR0070}) //Atenção#"Na operação de adiantamento os itens da Nota de Saída devem possuir o mesmo TES."#OK
						endif
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf
	If cTipDoc == "N" .AND. nAdt > 0 .AND. !aDadosIOri[nLinha][Len(aDadosIOri[nLinha])] .AND. aDadosIOri[nLinha][nAdt] > aDadosIOri[nLinha][nTot]
		Aviso(STR0120,STR0125,{STR0070}) //Atenção#"O Valor de adiantamento relacionado não deve ser superior ao valor do item."#OK
		lRet := .F.
	EndIf
	//Validaciones de Carta Porte
	If !aDadosIOri[nLinha][Len(aDadosIOri[nLinha])] .And. cTipDoc == "N" .And. SF2->(ColumnPos("F2_TPCOMPL")) > 0 .And. aDadosIOri[nLinha][nTpDoc] $ "01|21" .And. M->F2_TPCOMPL =='S'
		If nMatPel > 0 .And. aDadosIOri[nLinha][nMatPel] <> "NA"
			cProSer := STR0126 //"Producto"
			If nPeso > 0 .And. Empty(aDadosIOri[nLinha][nPeso]) //Peso
				cMsgVld += StrTran(STR0127,"###",Alltrim(FWX3Titulo(cPrefSD + '_PESO')) + " (D2_PESO)") + cCRLF //"-El valor del campo ###, es requerido."
			EndIf
			If nCveMatP > 0 .And. nEmbala > 0 
				If aDadosIOri[nLinha][nMatPel] == "Si" 
					If Empty(aDadosIOri[nLinha][nCveMatP]) //Clave de Material Peligroso 
						cMsgVld += StrTran(STR0127,"###",Alltrim(FWX3Titulo(cPrefSD + '_GRPCST')) + " (D2_GRPCST)") + cCRLF //"-El valor del campo ###, es requerido."
					EndIf
					If Empty(aDadosIOri[nLinha][nEmbala]) //Código de Embalaje
						cMsgVld += StrTran(STR0127,"###",Alltrim(FWX3Titulo(cPrefSD + '_TNATREC')) + " (D2_TNATREC)") + cCRLF //"-El valor del campo ###, es requerido."
					EndIf
				EndIf
			EndIf
		ElseIf nMatPel > 0 .And. aDadosIOri[nLinha][nMatPel] == "NA"
			cProSer := STR0128 //"Servicio"
			If aDadosIOri[nLinha][nPrcVen] == 0 //Precio de Venta 
				cMsgVld += StrTran(STR0127,"###",Alltrim(FWX3Titulo(cPrefSD + '_PRCVEN')) + " (D2_PRCVEN)") + cCRLF //"-El valor del campo ###, es requerido."
			EndIf
			If aDadosIOri[nLinha][nTot] == 0 //Total
				cMsgVld += StrTran(STR0127,"###",Alltrim(FWX3Titulo(cPrefSD + '_TOTAL')) + " (D2_TOTAL)") + cCRLF //"-El valor del campo ###, es requerido."
			EndIf
		EndIf
		If !Empty(cMsgVld)
			MsgAlert(StrTran(STR0129 + Alltrim(aDadosIOri[nLinha][nCodPro]) + ":","###",cProSer) + cCRLF + cMsgVld) //"Para Carta Porte, para el ###:"
			lRet := .F.
		EndIf
	EndIf
EndIf

If (Type("bListRefresh") != "U" .And. bListRefresh != Nil) .AND. (Type("bDoRefresh") != "U" .And. bDoRefresh != Nil)
	Eval(bDoRefresh)
	Eval(bListRefresh)
EndIf

Return lRet

/*/{Protheus.doc} xTudOkMex
	Validación naturaleza y condición de pago
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param cTipoDoc,cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1
	@return lRet
	/*/
Function xTudOkMex(cTipoDoc,cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
Local lRet			:= .T.
Local cMsg			:= ""
Local aRecnoAux	:= {}

Default cNatureza := ""
Default cCondicao := ""
Default aRecnoSE1 := {}

//Valida cond de pagto e natureza de oper. conforme tipo de nota
//"A" - Adiantamento "N" - Normal
// ED_OPERADT = 1 - Operacao de Adiantamento
// E4_CTRADT = 1 - Compensa Adiantamentos

If Trim(cNatureza) <> ""
	DbSelectArea("SED")
	DbSetOrder(1)
	MsSeek(XFilial("SED")+cNatureza)
	If cTipoDoc == "A" .AND. cPaisLoc == "MEX" .AND. SED->ED_OPERADT <> "1"
		cMsg += STR0108+CRLF //"Na Nota Fiscal de Adiantamento é necessário escolher uma Natureza que seja Operação de Adiantamento."
	ElseIf cTipoDoc <> "A" .AND. cPaisLoc == "MEX" .AND. SED->ED_OPERADT == "1"
		cMsg += STR0109+CRLF //"Escolher uma Natureza que seja Operação de Adiantamento somente é permitido para Nota Fiscal de Adiantamento."
	EndIf
ElseIf cTipoDoc == "A"
	cMsg += STR0110+CRLF //"Na Nota Fiscal de Adiantamento é necessário escolher uma Natureza que seja Operação de Adiantamento."
EndIf

If Trim(cCondicao) <> ""
	DbSelectArea("SE4")
	DbSetOrder(1)
	MsSeek(XFilial("SE4")+cCondicao)
	If cTipoDoc == "A" .AND. cPaisLoc $ "ANG|BRA|EQU|HAI|MEX" .AND. SE4->E4_CTRADT == "1"
		cMsg += STR0111+CRLF //"Na Nota Fiscal de Adiantamento não é possível utilizar uma condição de pagamento que compense adiantamentos."
	ElseIf cTipoDoc == "N" .AND. cPaisLoc $ "ANG|BRA|EQU|HAI|MEX|PER" .AND. SE4->E4_CTRADT == "1" .AND. Len(aRecnoSE1) == 0
		cMsg += STR0112+CRLF //"Quando for utilizada condição de pagamento de compensação de adiantamentos devem ser vinculados adiantamentos aos itens através do botão ações relacionadas."
	ElseIf cTipoDoc == "N" .AND. cPaisLoc $ "ANG|BRA|EQU|HAI|MEX" .AND. SE4->E4_CTRADT <> "1" .AND. Len(aRecnoSE1) > 0
		cMsg += STR0113+CRLF //"Quando forem vinculados adiantamentos é necessário utilizar uma condição de pagamento que compense adiantamentos."
	EndIf
EndIf

If cMsg <> ""
	lRet := .F.
	Aviso(STR0120,cMsg,{STR0070}) //Atenção#OK
EndIf

aRecnoAux := aRecnoSE1

Return lRet

/*/{Protheus.doc} xVldItAnt
	Asigna el valor del anticipo al campo D2_VALADI
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param Nil
	@return Nil
	/*/
Function xVldItAnt()
Local nSoma	:= 0
Local nX		:= 0

	//Apenas tipo Normal na compensação pode ter adiantamentos
	If aCfgNF[ScTipoDoc] <> "N"
		M->D2_VALADI := 0
	ElseIf Type("N") == "N"
		For nX := 1 To Len(aRecnoSE1)
			If Len(aRecnoSE1[nX]) > 3 .AND. aRecnoSE1[nX][4] == N
				nSoma += aRecnoSE1[nX][3]
			EndIf
		Next nX
		M->D2_VALADI := nSoma
	EndIf

Return .T.

/*/{Protheus.doc} xAdiantMex
	Vinculo de item de NF con anticipo.
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param cNum, cCondPagto, nTotal, aRecnoSE1, lCarregaTotal, cCodCli, cCodLoja, cNatureza
	@return Nil
	/*/
Function xAdiantMex(cNum, cCondPagto, nTotal, aRecnoSE1, lCarregaTotal, cCodCli, cCodLoja, cNatureza, aHeader)
Local nX		:= 0
Local nSoma	:= 0
Local nPos		:= 0

Default cNum          := ""
Default cCondPagto    := ""
Default nTotal        := 0
Default aRecnoSE1     := {}
Default lCarregaTotal := .F.
Default cCodCli       := ""
Default cCodLoja      := ""
Default cNatureza     := ""

	If Type("N")=="N" .AND. N > 0 .AND. MaFisFound("IT",N) .AND. !Empty(MafisRet(N,"IT_TES")) .AND. ( MafisRet(N,"IT_TOTAL") > 0 .OR. MafisRet(N,"IT_ADIANT") > 0)

		If Len(aRecnoSE1) == 0
			Alert(STR0146) //"Atenção! Após Vincular adiantamentos não será possível alterar o Cliente/Loja ou a Moeda/Taxa."
		EndIf

		//Rotina de Vinculo de Adiantamentos
		A410Adiant(cNum, cCondPagto, MafisRet(N,"IT_VALMERC"), @aRecnoSE1, lCarregaTotal, cCodCli, cCodLoja, NIL,NIL,NIL,NIL,cNatureza,MafisRet(N,"IT_TES"),N)

		//Apos o Relacionamento dos adiantamentos é necessário atualizar a matxfis e carregar o total relacionado no campo correspondente do grid de itens
		For nX := 1 To Len(aRecnoSE1)
			If Len(aRecnoSE1[nX]) > 3 .AND. aRecnoSE1[nX][4] == N
				nSoma += aRecnoSE1[nX][3]
			EndIf
		Next nX
		nPos := Ascan(aHeader,{|x| Trim(x[2]) $ "|D1_VALADI|D2_VALADI|"})
		If nPos > 0
			if FunName() == "MATA101N"
				M->D1_VALADI := nSoma
				MafisRef("IT_ADIANT","MT100",nSoma)
				aCols[N][nPos] := nSoma
				ModxAtuObj()
			else
				M->D2_VALADI := nSoma
				MafisRef("IT_ADIANT","MT100",nSoma)
				aCols[N][nPos] := nSoma
				ModxAtuObj()
			endif
		EndIf

	Else
		Aviso(STR0120,STR0130,{STR0070}) //Atenção#"Para vincular adiantamentos é necessário primeiro posicionar em um dos itens da Nota Fiscal e preencher o TES e os Valores."#OK
	EndIf

Return

/*/{Protheus.doc} LxAlqImp
	Obtiene alícuotas de impuestos
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param cTes
	@return cRet
	/*/
Function LxAlqImp(cTes)
Local cRet			:= ""
Local aTesInfo	:= TesImpInf(cTes)
Local nVal			:= 0
Local nPos			:= 0
Local cQry			:= "SELECT DISTINCT FB_CPOLVRO as CAMPO FROM "+RetSqlName("SFB")
Local nValtmp       := 0

cQry := ChangeQuery(cQry)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBSFB",.T.,.T.)
While TRBSFB->(!Eof())
	//Procura o campo do imposto nas informações da Tes
	If (nPos := AscanX(aTesInfo,{|x| Substr(x[2],-1)==TRBSFB->CAMPO})) > 0
		nVal := aTesInfo[nPos][9] // Aliquota
	Else
		nVal := 0 //Se nao encontrar aliquota, zera
	EndIf
	/* Execblock LXD2FILT después de obtener cada Aliquota	*/
	If cPaisLoc == "MEX"    //Solo para México
		If ExistBlock('LXD2FILT')
			nValtmp := ExecBlock('LXD2FILT', .F., .F., {nVal,TRBSFB->CAMPO})
			If  ValType(nValtmp) == "N"
				nVal := nValtmp
			EndIf
		EndIf
	Endif
	if FunName() == "MATA101N"
		cRet += " AND D1_ALQIMP"+TRBSFB->CAMPO+"='"+CValToChar(nVal)+"'"
	else
		cRet += " AND D2_ALQIMP"+TRBSFB->CAMPO+"='"+CValToChar(nVal)+"'"
	Endif
	TRBSFB->(DbSkip())
End
TRBSFB->(dbCloseArea())

Return cRet

/*/{Protheus.doc} xDelAdtMx
	Elimina item vinculado con anticipo.
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param nItem, aCols, aRecnoSE1, N
	@return lRet
	/*/
Function xDelAdtMx(nItem, aCols, aRecnoSE1, N, aHeader, bDoRefresh, bListRefresh)
Local nPos		:= 0
Local nX		:= 0
Local aNewSE1	:= {}
Local lRet		:= .T.
Local nOld		:= NIL

Default nItem     := 0
Default aCols     := {}
Default aRecnoSE1 := {}
Default N         := 0
Default aHeader   := {}
Default bDoRefresh := Nil
Default bListRefresh := Nil

If Len(aHeader) > 0
	nPos := Ascan(aHeader,{|x| Trim(x[2]) $ "|D1_VALADI|D2_VALADI|"})
EndIf

If nItem == 0
	For nX := 1 To Len(aCols)
		LxDelAdt(nX)
	Next nX
Else

	For nX := 1 To Len(aRecnoSE1)
		If Len(aRecnoSE1[nX]) > 3 .AND. aRecnoSE1[nX][4] != nItem
			AAdd(aNewSE1,aRecnoSE1[nX])
		EndIf
	Next nX

	aRecnoSE1 := aNewSE1

	If nPos > 0
		aCols[nItem][nPos] := 0
		If Type("N") != "U"
			nOld := N
		EndIf
		N := nItem
		MafisRef('IT_ADIANT',"MT100",0)
		If nOld != NIL
			N := nOld
		EndIf
	EndIf

	If (Type("bListRefresh") != "U" .And. bListRefresh != Nil) .AND. (Type("bDoRefresh") != "U" .And. bDoRefresh != Nil)
		Eval(bDoRefresh) //Atualiza o folder financeiro.
		Eval(bListRefresh)
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} xBaixaAdt
	Baja de valores de titulo de anticipo
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param aRegSE1,aCaixaFin
	@return Nil
	/*/
Function xBaixaAdt(aRegSE1,aCaixaFin,aCols,aHeader,cNatureza)
Local lCompra   := (FunName() == "MATA101N")
Local cHist     := ""
Local cFunOrig	:= IIf(Type("cFunName")=="C",cFunName,Upper(FunName()))  //Funcao Origem
Local aBaixa		:= {}
Local nRecSE		:= 0
Local nRec			:= 1
Local aArea		:= GetArea()
Local nPos			:= 0
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])$ "|D1_ITEM|D2_ITEM|"})
local cModalid  := IIF( !empty(MaFisRet(,"NF_NATUREZA")) , MaFisRet(,"NF_NATUREZA") , cNatureza)
Local lUsaNewKey:= TamSX3("F2_SERIE")[1] == 14
Local cSerId	:=""

if lCompra
	cHist	:= "ADT: "+M->F1_DOC+" "+M->F1_SERIE+" "
	DbSelectArea("SE2")
else
	cHist	:= "ADT: "+M->F2_DOC+" "+M->F2_SERIE+" "
	DbSelectArea("SE1")
endif
nRecSE:=Recno()

For nRec:=1 To Len(aRegSE1)
	DbGoto(aRegSE1[nRec][2])
	If Len(aRegSE1[nRec]) > 3
		cHist += cValtochar(aRegSE1[nRec][4])
	EndIf
	aBaixa := {}
	if lCompra
		AADD( aBaixa, { "E2_PREFIXO" 	, E2_PREFIXO       , Nil } )	// 01
		AADD( aBaixa, { "E2_NUM"     	, E2_NUM           , Nil } )	// 02
		AADD( aBaixa, { "E2_PARCELA" 	, E2_PARCELA       , Nil } )	// 03
		AADD( aBaixa, { "E2_TIPO"    	, E2_TIPO          , Nil } )	// 04
		AADD( aBaixa, { "E2_FORNECE"	, E2_FORNECE       , Nil } )	// 05
		AADD( aBaixa, { "E2_LOJA"    	, E2_LOJA          , Nil } )	// 06
		AADD( aBaixa, { "E2_MOEDA"    	, E2_MOEDA         , Nil }	)	// 05
		AADD( aBaixa, { "E2_TXMOEDA"	, E2_TXMOEDA       , Nil } )	// 06
		AADD( aBaixa, { "E2_ORIGEM"		, cFunOrig         , Nil } )	// 07
		AADD( aBaixa, { "E2_NATUREZ"	, cModalid         , Nil } )	// 07
		AADD( aBaixa, { "AUTMOTBX"  	, "NOR"            , Nil } )	// 08
		AADD( aBaixa, { "AUTBANCO"  	, aCaixaFin[1]     , Nil } )	// 09
		AADD( aBaixa, { "AUTAGENCIA"  	, aCaixaFin[2]     , Nil } )	// 10
		AADD( aBaixa, { "AUTCONTA"  	, aCaixaFin[3]     , Nil } )	// 11
		AADD( aBaixa, { "AUTDTBAIXA"	, dDataBase        , Nil } )	// 12
		AADD( aBaixa, { "AUTHIST"   	, cHist            , Nil } )	// 13
		AADD( aBaixa, { "AUTDESCONT" 	, 0                , Nil } )	// 14
		AADD( aBaixa, { "AUTMULTA"	 	, 0                , Nil } )	// 15
		AADD( aBaixa, { "AUTJUROS" 		, 0                , Nil } )	// 16
		AADD( aBaixa, { "AUTOUTGAS" 	, 0                , Nil } )	// 17
		AADD( aBaixa, { "AUTVLRPG"  	, aRegSE1[nRec][3] , Nil } )	// 18 //VALOR A PAGAR
		AADD( aBaixa, { "AUTVLRME"  	, aRegSE1[nRec][3] , Nil } )	// 19 //VALOR MERCANCIA
		MSExecAuto({|x,y| Fina080(x,y)},aBaixa,3)
	else
		AADD(aBaixa,{"E1_PREFIXO" 	,E1_PREFIXO		, Nil})	// 01
		AADD(aBaixa,{"E1_NUM"     	,E1_NUM			, Nil})	// 02
		AADD(aBaixa,{"E1_PARCELA" 	,E1_PARCELA		, Nil})	// 03
		AADD(aBaixa,{"E1_TIPO"    	,E1_TIPO			, Nil})	// 04
		AADD(aBaixa,{"E1_MOEDA"    	,E1_MOEDA			, Nil})	// 05
		AADD(aBaixa,{"E1_TXMOEDA"	,E1_TXMOEDA		, Nil})	// 06
		AADD(aBaixa,{"E1_ORIGEM"		,cFunOrig			, Nil})	// 07
		AADD(aBaixa,{"AUTVALREC"		,aRegSE1[nRec][3]	, Nil})	// 06
		AADD(aBaixa,{"AUTMOTBX"  	,"NOR"				, Nil})	// 07
		AADD(aBaixa,{"AUTDTBAIXA"	,dDataBase			, Nil})	// 08
		AADD(aBaixa,{"AUTDTCREDITO"	,dDataBase			, Nil})	// 09
		AADD(aBaixa,{"AUTHIST"   	,cHist				, Nil})	// 10
		AADD(aBaixa,{"AUTBANCO"  	,aCaixaFin[1]		, Nil})	// 11
		AADD(aBaixa,{"AUTAGENCIA"  	,aCaixaFin[2]		, Nil})	// 12
		AADD(aBaixa,{"AUTCONTA"  	,aCaixaFin[3]		, Nil})	// 13
		MSExecAuto({|x,y| FINA070(x,y)},aBaixa,3)
	endif

	//Grava o relacionamento dos adiantamentos na tabela FR3 para permitir o estorno da operação
	nPos := aRegSE1[nRec][4]
	if lCompra
		FaGrvFR3("P","",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,aRegSE1[nRec][3],M->F1_DOC,M->F1_SERIE,aCols[nPos][nPosItem])
	else
		cSerId:=Iif(lUsaNewKey,SerieNfId("SF2",4,"F2_SERIE",M->F2_EMISSAO,M->F2_ESPECIE,M->F2_SERIE),M->F2_SERIE) //Projeto Chave Unica - Tiago Silva
		FaGrvFR3("R","",SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,aRegSE1[nRec][3],M->F2_DOC,cSerId,aCols[nPos][nPosItem])
	endif

Next

DbGoto(nRecSE)
RestArea(aArea)

Return

/*/{Protheus.doc} VldWhenMex
	Permitir edita el Folio Fiscal/Timbre y Fecha
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param lTabla
	@return lRet
	/*/
Function VldWhenMex(lTabla)
Local _aArea	:= GetArea()
Local lRet 		:= .T.
Local cPrefSF	:= ""
Local cCliFor   := ""

Default lTabla	:= .F.

	cPrefSF := IIf(lTabla, "F2", "F1")
	cCliFor := IIf(lTabla, "F2_CLIENTE", "F1_FORNECE")

	If  Empty(M->&cCliFor) .OR. Empty(M->&(cPrefSF + "_LOJA"))
		lRet := .F.
	EndIf
	RestArea( _aArea )
Return lRet

/*/{Protheus.doc} LxUUIDMex
	Consulta especifica para los Folios Fiscales
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param Nil
	@return .T.
	/*/
Function LxUUIDMex()
Local _aArea	:= GetArea()
Local _cTipo	:= STR0133//"Arquivos XML|*.XML"
Local cFName    := ""
Private _oXML	:= NIL	// XML que sera parseado
Private cXMLPro := SuperGetMV("MV_XMLPRO",.F.,"")
Private cPathSrv:= ""

_cArq := cGetFile(_cTipo,STR0135,0,"",.F.,GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_NETWORKDRIVE,.T.,.T.) // "Selecione el arquivo XML:"

If Empty(_cArq)
	MsgStop(STR0134)//"Archivo no seleccionado!"
	Return(.F.)
Else
	If Empty(cXMLPRO)
		MsgStop(STR0131)// "Parámetro MV_XMLPRO no ha sido informado, revise por favor configuración del parámetro."
		Return .F.
	EndIf
	cFName   := ALLTRIM(Substr(_cArq,rat("\",_cArq) + 1))   //Obtener solo el nombre del archivo  (xxx.XML)
	cPathSrv := cXMLPro+"\"+cFName
	If !File(cPathSrv)
		If __CopyFile(_cArq, cPathSrv)
		 	LeerXML() //Función para obtener el UUID, Timbre y Fecha Timbrado
			fErase(cPathSrv) //Eliminar el archivo de la ruta del servidor
		Else
			MsgStop(STR0132) //"Falla en la copia del archivo XML para el RootPath de Protheus!"
			Return(.F.)
		Endif
	Else
		LeerXML() //Función para obtener el UUID, Timbre y Fecha Timbrado (cuando ya ha sido usado)
	Endif
EndIf
RestArea( _aArea )
Return( .T. )

/*/{Protheus.doc} copyXMLMex
	Copia el NF-XML a la carpeta de procesados 
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param Nil
	@return .T.
	/*/
Function copyXMLMex()
Local cPDFo   := ""
Local cPDFd   := ""

If __CopyFile(_cArq,cPathXML+".XML")
	cPDFo := Substr(_cArq,1,rat(".",_cArq)) +"pdf"
	cPDFd := cPathXML + "." +"pdf"
	IF FILE(cPDFo) // Si existe la factura en pdf, se mueve a la ruta definida junto con el xml
		If File(cPDFd)
			Ferase(cPDFd)
		EndIF
		__CopyFile(cPDFo,cPDFd)
	Endif
Else
	MsgStop(STR0136) //"¡Falla en la copia del archivo XML para el RootPath de Protheus!"
	Return(.F.)
EndIf

Return (.T.)

/*/{Protheus.doc} VldUUIDRel
	Validación UUID Relacionado
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param cUUIDREL
	@return lRet
	/*/
Function VldUUIDRel(cUUIDREL)
Local lRet    := .T.
Local aTipRel := {}
Local nLoop   := 1
Local nPosRel := 0
Local cCRLF	  := (chr(13)+chr(10))

	aTipRel := STRTOKARR(cUUIDREL, cCRLF)

	while lRet .And. (nLoop <= Len(aTipRel))
		nPosRel:=Rat(";",aTipRel[nLoop])-1
		lRet := LxVldF3I("S012",Substr(aTipRel[nLoop],1,nPosRel),1,2)
		nLoop += 1
	enddo

Return lRet

/*/{Protheus.doc} xVldF3IMex
	Valida si existe registro en catálogo
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param cCodigo,cConteudo,nPos1,nPos2
	@return lRet
	/*/
Function xVldF3IMex(cCodigo,cConteudo,nPos1,nPos2)
Local lRet := .F.
Local cTRB := ""
Local cQry := ""
Local aArea:= getArea()
Default nPos1 := 0
Default nPos2 := 0
	
	If cCodigo <> Nil .And. cConteudo <> Nil
		
		If Select("TRBF3I")>0
			TRBF3I->(dbCloseArea())
		EndIf
		
		cQry := " SELECT F3I_CODIGO,F3I_SEQUEN,F3I_CONTEU "
		cQry += " FROM " + RetsqlName("F3I") + " F3I "
		cQry += " WHERE F3I_FILIAL = '" + xFilial("F3I") + "' "
		cQry += " AND F3I_CODIGO = '" + cCodigo + "' "
		cQry +=" AND F3I.D_E_L_E_T_='' "
		
		cTRB := ChangeQuery(cQry)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRB ) ,"TRBF3I", .T., .F.)
		
		dbSelectArea( "TRBF3I" )
		TRBF3I->(dbGoTop())	
		
		While TRBF3I->(!Eof())
			If Alltrim(Substr(TRBF3I->F3I_CONTEU,nPos1,nPos2)) == Alltrim(cConteudo)
				lRet := .T.
				Exit
			EndIf
			TRBF3I->(dBSkip())
		EndDo
	EndIf
	RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} xVldRetSat
	Valida Tipo de Relacion CFD y UsoCFDI
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param cTpRel,cCpo
	@return lRet
	/*/
Function xVldRetSat(cTpRel,cCpo)
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cFunName	:= FunName()
Local lCfdi40    := SuperGetMV("MV_CFDI40",.F.,.F.)

Default cCpo	:= ""
Default cTpRel	:= ""

	If cCpo == "F2_RELSAT"
		If !EMPTY(cTpRel) .AND. nNFTipo == 21
			If ALLTRIM(cTpRel) <> "05"
				Aviso(STR0120,STR0137,{STR0070}) //Atenção#"Usar un cod. de Relacion CDF dif. de <05> puede causar errores cuando se realice el timbrado."#OK
				lRet := .F.
			EndIf
		ElseIf !EMPTY(cTpRel) .AND. (nNFTipo == 1 .Or. nNFTipo == 2) //Fatura de Venta (Normal) - Nota de Débito
			If Alltrim(cTpRel) == "04"
				Aviso(STR0120,StrTran(STR0138,"###",FWX3Titulo("F2_RELSAT") + " (F2_RELSAT)"),{STR0070}) //"Atención" //"El campo ###, no puede ser 04 - Sustitución de los CFDI Previos." //"OK"
				lRet := .F.
			EndIf
		ElseIf EMPTY(cTpRel) .AND. !EMPTY(M->F2_UUIDREL)
			If nNFTipo == 21
				Aviso(STR0120,STR0139+"("+cCpo+")",{STR0070}) //Atenção#"En la operacion de Traslado se debe informar el campo Relacion CFDI "#OK
				lRet := .F.
			EndIf
		EndIf
	ElseIf cCpo == "F2_USOCFDI"
		If !EMPTY(cTpRel)
			If lCfdi40 .And. ALLTRIM(cTpRel) <> "S01" .And. nNFTipo == 21
				Aviso(STR0120,STR0140,{STR0070}) //Atencion#"Es requerido usar el Uso de CFDI <S01> en la versión actual de CFDI para el timbrado."#OK
				lRet := .F.
			ElseIf !lCfdi40 .And. ALLTRIM(cTpRel) <> "P01" .And. nNFTipo == 21
				Aviso(STR0120,STR0141,{STR0070}) //Atenção#"Usar un cod. de Uso CDFI dif. de <P01> puede causar errores cuando se realice el timbrado."#OK
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		Else
			If cFunName == "ATFA036"
				Aviso(STR0120, STR0142, {STR0070}) //Atenção#"El campo Uso CFDI, debe ser informado. "#OK
			Else
				Aviso(STR0120, STR0142 + "(" + cCpo + ")", {STR0070}) //Atenção#"El campo Uso CFDI, debe ser informado. "#OK
			EndIf
			lRet := .F.
		EndIf
	ElseIf cCpo == "F1_USOCFDI"
		If EMPTY(cTpRel)
			Aviso(STR0120,STR0142+"("+cCpo+")",{STR0070}) //Atenção#"El campo Uso CFDI, debe ser informado. "#OK
			lRet := .F.
		EndIf
	ElseIf cCpo == "F2_UUIDREL"
		If EMPTY(cTpRel) .AND. !EMPTY(M->F2_RELSAT)
			Aviso(STR0120,STR0143+"("+cCpo+")",{STR0070}) //Atenção#"En la operacion de Traslado se debe informar el campo UUID Relac "#OK
			lRet := .F.
		EndIf
	ElseIf cCpo == "F1_RELSAT"
		If !EMPTY(cTpRel) .And. nNFTipo == 4 //Nota de Crédito
			If Alltrim(cTpRel) == "04"
				Aviso(STR0120,StrTran(STR0138,"###",FWX3Titulo("F2_RELSAT") + " (F2_RELSAT)"),{STR0070}) //"Atención" //"El campo ###, no puede ser 04 - Sustitución de los CFDI Previos." //"OK"
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} xVldIMMEX
	Validar si el cliente cuenta con Registro IMMEX
	@type  Function
	@author Arturo Samaniego
	@since 02/08/2022
	@param cImmex,cCliente,cLoja,cPropiedad,cTabla
	@return lRet
	/*/
Function xVldIMMEX(cImmex,cCliente,cLoja,cPropiedad,cTabla)
Local lRet	 := .F.
Local cCliImmex :=""

Default cImmex := ""
Default cCliente := ""
Default cLoja := ""
Default cPropiedad := ""
Default cTabla := ""

	If !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cPropiedad)
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA

		If SA1->(MsSeek(xFilial("SA1")+ cCliente + cLoja))
			cCliImmex   := SA1-> A1_CONTRBE
		EndIF

		IF cPropiedad=="1"
			If Empty(cImmex) .And. cCliImmex=="1"
				Aviso(STR0120,STR0144 + RTrim(FWX3Titulo(cTabla+"_CONUNI")) + STR0145 ,{STR0070})
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		EndIf

		If cCliImmex=="1" .And. cPropiedad="2"
			lRet := .T.
		EndIf
	EndIf
Return (lRet)

/*/{Protheus.doc} fxBaixaAdt
	Función para baja de anticipos MEX/PER.
	La función es ejecutada desde LOCXNF2, función BaixaAdt.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param  N/A
	@return lRet. .T. si se completa la baja del anticipo.
	/*/
Function fxBaixaAdt()
Local aArea    := GetArea()
Local lRet     := .T.
Local aStrFR3  := {}
Local aVetor   := {}
Local aRecFR3  := {}
Local nX       := 0
Local cCpoQry  := ""
Local cQ       := ""
Local nPosE5   := 0
Local nPosFR3  := 0
Local nBaixa   := 1	//Baixa selecionada para cancelar na rotina fina070

Private nFR3   := 0
Private aBorra := {}

		//Carrega array com titulos compensados nesta nota fiscal, da tabela de Documento X Adiantamento
		aStrFR3 := FR3->(DbStruct())
		For nX := 1 to Len(aStrFR3)
			cCpoQry += aStrFR3[nX][1] +" , "
		Next nX

		cQ	:= " SELECT "+cCpoQry+" R_E_C_N_O_ AS FR3_RECNO "
		cQ += " FROM "+RetSqlName("FR3")+" "
		cQ += " WHERE FR3_FILIAL = '"+xFilial("FR3")+"' "
		cQ += " AND FR3_CART = 'P' "
		cQ += " AND FR3_TIPO IN " + FormatIn(MVPAGANT,"/")+" "
		cQ += " AND FR3_FORNEC = '"+SF1->F1_FORNECE+"' "
		cQ += " AND FR3_LOJA = '"+SF1->F1_LOJA+"' "
		cQ += " AND FR3_DOC = '"+SF1->F1_DOC+"' "
		cQ += " AND FR3_SERIE = '"+SF1->F1_SERIE+"' "
		cQ += " AND D_E_L_E_T_= ' ' "
		cQ := ChangeQuery(cQ)

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),"TRBFR3",.T.,.T.)
		TcSetField("TRBFR3","FR3_VALOR","N",TamSX3("FR3_VALOR")[1],TamSX3("FR3_VALOR")[2])

		While TRBFR3->( !Eof() )
			//Procura uma baixa não cancelada com o Valor igual ao relacionado ao adiantamento
			DbSelectArea("SE5")
			SE5->(DbSetOrder(7))
			SE5->(DbGoTop())
			If SE5->(DbSeek(XFilial("SE5")+TRBFR3->FR3_PREFIX+TRBFR3->FR3_NUM+TRBFR3->FR3_PARCEL+TRBFR3->FR3_TIPO+SF1->F1_FORNECE+SF1->F1_LOJA))
				While SE5->(!Eof()) .AND. TRBFR3->FR3_FILIAL==SE5->E5_FILIAL
					if ALLTRIM( SUBSTR( SE5->E5_HISTOR , 6, TAMSX3("F1_DOC")[1] ) ) == ALLTRIM( TRBFR3->FR3_DOC )
						If SE5->E5_SITUACA == 'C'
							SE5->(DbSkip())
							Loop
						else
							nPosE5 := aScan( aBorra ,	{|x| x[1] == ALLTRIM( TRBFR3->FR3_DOC ) .and. x[2] == SE5->(recno()) } )
							if nPosE5 <= 0
								AADD(aBorra, {ALLTRIM( SUBSTR( SE5->E5_HISTOR , 6, TAMSX3("F1_DOC")[1] ) ),SE5->(recno())} )
							endif
							nPosFR3 := aScan( aRecFR3 ,	{|x| x == TRBFR3->FR3_RECNO } )
							if nPosFR3 <= 0
								AADD(aRecFR3 , TRBFR3->FR3_RECNO)
								AADD(aVetor, {	{"E2_PREFIXO" , TRBFR3->FR3_PREFIX , Nil } , { "E2_NUM"  , TRBFR3->FR3_NUM  , Nil }, ;
												{"E2_PARCELA" , TRBFR3->FR3_PARCEL , Nil } , { "E2_TIPO" , TRBFR3->FR3_TIPO , Nil } } )
							endif
							SE5->(DbSkip())
						EndIf
					else
						DbSkip()
					endif
				EndDo
			Else
				lRet := .F.
				Exit
			EndIf
			TRBFR3->(DbSkip())
		EndDo

		for nX := 1 to len (aBorra)
			nFR3 := nX
			MSExecAuto({|x,y| Fina080(x,y,.F.,nBaixa)},aVetor[nX],5)

			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				lRet := .F.
				Exit
			Else
				dbSelectArea("FR3")
				dbGoto(aRecFR3[nX])
				RecLock("FR3",.F.)
				DbDelete()
				MsUnlock()
			EndIf
		next

		TRBFR3->(dbCloseArea())
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} VldTipoOpe
	Función para validar el tipo de operación - complemento de comercio exterior.
	La función es ejecutada desde LOCXNF2, función ValTipoOpe.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param  nTipo: Tipo de documento. (1=NCC; 3=Ped. Venta)
	@return .T.
	/*/
Function VldTipoOpe(nTipo)
	If nTipo == 1 //Para notas de credito (NCC)
		If Empty(Alltrim(M->F1_FORNECE))
			MSGINFO(STR0147)
			M->F1_TIPOPE := ""
			Return .T.
		Else
			DBSelectArea("AI0")
			DBSetOrder(RetOrdem("AI0","AI0_FILIAL+AI0_CODCLI+AI0_LOJA"))
			If AI0->(DBSeek(xFilial("AI0") + M->F1_FORNECE + M->F1_LOJA))
				If Empty(AI0->AI0_IDFIS)
					MSGINFO(STR0148)
					M->F1_TIPOPE := ""
					Return .T.
				EndIf
			EndIf
		EndIf
	ElseIf nTipo == 3 //Para Pedidos de Venta
		If Empty(Alltrim(M->C5_CLIENTE))
			MSGINFO(STR0147)
			M->C5_TIPOPE := ""
			Return .T.
		Else
			DBSelectArea("AI0")
			DBSetOrder(RetOrdem("AI0","AI0_FILIAL+AI0_CODCLI+AI0_LOJA"))
			If AI0->(DBSeek(xFilial("AI0") + M->C5_CLIENTE + M->C5_LOJACLI))
				If Empty(AI0->AI0_IDFIS)
					MSGINFO(STR0148)
					M->C5_TIPOPE := ""
					Return .T.
				EndIf
			EndIf
		EndIf
	Else
		If Empty(Alltrim(M->F2_CLIENTE))
			MSGINFO(STR0147)
			M->F2_TIPOPE := ""
			Return .T.
		Else
			DBSelectArea("AI0")
			DBSetOrder(RetOrdem("AI0","AI0_FILIAL+AI0_CODCLI+AI0_LOJA"))
			If AI0->(DBSeek(xFilial("AI0") + M->F2_CLIENTE + M->F2_LOJA))
				If Empty(AI0->AI0_IDFIS)
					MSGINFO(STR0148)
					M->F2_TIPOPE := ""
					Return .T.
				EndIf
			EndIf
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} xLinComExt
	Función para validación de linea complemento de comercio exterior (MEX).
	La función es ejecutada desde LOCXNF2, función ValLinCO.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param  nTipoNF: Tipo de documento.
			nCanAdu: Posición campo Cantidad
			nUniAdu: Posición campo Unidad
			nValAdu: Posición campo Valor
			nUsdAdu: Posición campo Valor en dolares (USD).
			aDadosI: Items de documento.
			nLinha: Número de item del documento.
			nFracca: Posición campo Fracción arancelaria
	@return .T. si cumple con las condiciones, caso contrario .F.
	/*/
Function xLinComExt(nTipoNF, nCanAdu, nUniAdu, nValAdu, nUsdAdu, aDadosI, nLinha, nFracca)
	If !Empty(aDadosI[nLinha][nCanAdu])
		If Empty(aDadosI[nLinha][nUniAdu])
			MSGINFO(STR0149)
			Return .F.
		EndIf

		If aDadosI[nLinha][nUniAdu] == "99"
			If !Empty(aDadosI[nLinha][nFracca])
				MSGINFO(STR0150)
				Return .F.
			EndIf
			If aDadosI[nLinha][nUsdAdu] > 0
				MSGINFO(STR0151)
				Return .F.
			EndIf
		Else
			If aDadosI[nLinha][nValAdu] <= 0
				MSGINFO(STR0152)
				Return .F.
			EndIf
			If (Abs(Round((aDadosI[nLinha][nValAdu] * aDadosI[nLinha][nCanAdu]),2) - aDadosI[nLinha][nUsdAdu]) > 0.01) .And. aDadosI[nLinha][nUsdAdu] != 1
				MSGINFO(STR0153)
				Return .F.
			EndIf

		EndIf
	ElseIf !Empty(aDadosI[nLinha][nUniAdu]) .Or. !Empty(aDadosI[nLinha][nValAdu]) .Or. !Empty(aDadosI[nLinha][nUsdAdu])
		MSGINFO(STR0154)
		Return .F.
	EndIf
Return .T.

/*/{Protheus.doc} xTesTrasdo
	Validación de TES para documentos de traslado.
	La función es ejecutada desde LOCXNF2, función LxTesTras.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param  cTes: Código de TES
	@return lRet: .T. si la TES es valida.
	/*/
Function xTesTrasdo(cTes)
Local lRet  	:= .T.
Local aArea 	:= GetArea()
Local cFilSF4	:= xFilial("SF4")

Default cTes 		:= ""

	If !Empty(cTes)
		//Verificar se a tes gera duplicata e nao movimenta estoque
		DbSelectArea("SF4")
		SF4->(DbSetOrder(1)) //F4_FILIAL + F4_CODIGO
		If SF4->(MsSeek(cFilSF4+cTes))
			IF (SF4->F4_ESTOQUE == "S")
				Aviso(STR0120,STR0161,{STR0070}) //Atenção#"En la operacion de Traslado la TES utilizada no debe afectar Stock."#OK
				lRet := .F.
			EndIf
			If (SF4->F4_DUPLIC == "S") .AND. lRet
				Aviso(STR0120,STR0160,{STR0070}) //Atenção#"En la operacion de Traslado la TES utilizada no debe afectar Financiero."#OK
				lRet := .F.
			EndIf
		Else
			Aviso(STR0120,STR0162,{STR0070}) //Atenção#"Llene el campo de la TES. "#OK
			lRet := .F.
		EndIf
	EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc} xVldTesAdi
	Función para verificar si tiene anticipo asociado. La función es ejecutada después de cambiar la TES.
	La función es ejecutada desde LOCXNF2, función LxTesAdi.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param  N: Número de item de NF que está siendo editado.
	@return lRet: .T. si no tiene anticipo asociado o es eliminado la asociación del anticipo.
	/*/
Function xVldTesAdi(N)
Local lRet := .T.

Default N := 0

If N <> 0
	If MafisRet(N,'IT_ADIANT') > 0
		If 1 == Aviso(STR0120,STR0163,{STR0164,STR0165}) //Atenção#"Após vincular adiantamentos se o TES for alterado é necessário remover os adiantamentos. Deseja remover os adiantamentos e alterar o TES ?"#SIM#NAO
			LxDelAdt(N, aCols, aRecnoSE1, N, aHeader, bDoRefresh, bListRefresh)
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} xVldCmObCE
	Valida campos de encabezado de documento fiscal, para complemento de comercio exterio.
	La función es ejecutada desde LOCXNF2, función ValCmObCE.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param  cAliasC: Alias de tabla SF1/SF2.
			nLinha: Número de ítem del documento fiscal.
			aDadosI: Nombre de campos de ítems (aHeader).
			aDadosD: Información de ítems (aCols).
	@return .T. si la información está completa, caso contrario .F.
	/*/
Function xVldCmObCE(cAliasC, nLinha, aDadosI, aDadosD)
Local nSumaUSDLin := 0
Local nContDatA   := 0
Local nI          := 0
Local nX          := 0
Local cCampo      := ""
Local nCanAdu     := 0
Local nUsdAdu     := 0
Local nFracca     := 0    
Local nTpoProd    := 0   
Local cPrefNF     := ""
Local cTipoIt     := ""
Local nServ       := 0
Local cCFDUso     := SuperGetMV("MV_CFDUSO", .F., "1") 
Local lCfdi40     := SuperGetMV("MV_CFDI40",.F.,.F.)
Local cPrefSF     := ""

Default cAliasC := ""
Default nLinha  := 0
Default aDadosI := {}
Default aDadosD := {}

	If cAliasC == "SF2"
		cPrefNF := "M->F2_"
		cTipoIt := "D2_"
		cPrefSF := "F2_"
	ElseIf cAliasC == "SF1"
		cPrefNF := "M->F1_"
		cTipoIt := "D1_"
	EndIf

	For nX := 1 To Len(aDadosI)
		cCampo := AllTrim(aDadosI[nx])
		Do Case
			Case cCampo == cTipoIt + "CANADU"
				nCanAdu := nX
			Case cCampo == cTipoIt + "USDADU"
				nUsdAdu := nX
			Case cCampo == cTipoIt + "FRACCA"
				nFracca := nX
		EndCase
	Next nx

	If Empty(&(cPrefNF+"TIPOPE")) .And. (!Empty(&(cPrefNF+"CVEPED")) .Or. !Empty(&(cPrefNF+"CERORI")) .Or. !Empty(&(cPrefNF+"NUMCER")) .Or. !Empty(&(cPrefNF+"EXPCONF")) .Or. !Empty(&(cPrefNF+"INCOTER")) .Or. !Empty(&(cPrefNF+"SUBDIV")) .Or. !Empty(&(cPrefNF+"OBSERV")) .Or. !Empty(&(cPrefNF+"TCUSD")) .Or. !Empty(&(cPrefNF+"TOTUSD")))
		MSGINFO(STR0166)
		Return .F.
	EndIf

	If !Empty(&(cPrefNF+"TIPOPE"))
		If &(cPrefNF+"TIPOPE") == "A"
			If !Empty(&(cPrefNF+"CVEPED")) .Or. !Empty(&(cPrefNF+"CERORI")) .Or. !Empty(&(cPrefNF+"NUMCER")) .Or. !Empty(&(cPrefNF+"EXPCONF")) .Or. !Empty(&(cPrefNF+"INCOTER")) .Or. !Empty(&(cPrefNF+"SUBDIV")) .Or. !Empty(&(cPrefNF+"TCUSD")) .Or. !Empty(&(cPrefNF+"TOTUSD"))
				MSGINFO(STR0167 + CRLF + STR0168 + CRLF + STR0169 + CRLF + STR0170 + CRLF + STR0171 + CRLF + STR0172 + CRLF +;
				STR0173 + CRLF + STR0174 + CRLF + STR0175 + CRLF + STR0176)
				Return .F.
			EndIf
		ElseIf &(cPrefNF+"TIPOPE") $ "1|2"
			If Empty(&(cPrefNF+"CVEPED")) .Or. Empty(&(cPrefNF+"CERORI")) .Or. Empty(&(cPrefNF+"INCOTER")) .Or. Empty(&(cPrefNF+"SUBDIV")) .Or. Empty(&(cPrefNF+"TCUSD")) .Or. Empty(&(cPrefNF+"TOTUSD"))
				MSGINFO(STR0177 + CRLF + STR0168 + CRLF + STR0169 + CRLF + STR0172 + CRLF + STR0173 + CRLF + STR0174 + CRLF +;
				STR0175 + CRLF + STR0176)
				Return .F.
			EndIf
			//Motivo de Traslado debe informarse para Facturas de Tipo Traslado (21)
			If aCfgNF[SnTipo] == 21
				If lCfdi40 .And. (cAliasC)->(ColumnPos(cPrefSF + "TRASLA")) > 0 .And. Empty(&(cPrefNF + "TRASLA")) .And. cCFDUso <> "0"
					MsgInfo(StrTran(STR0182,"###", FWX3Titulo(cPrefSF + "TRASLA") + "(" + cPrefSF + "TRASLA" + ")"), STR0092) //"Para Documentos de tipo Traslado con Complemento de Comercio Exterior, es necesario informar el campo ###." //"Atención"
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If &(cPrefNF+"CERORI") == "1" .And. Empty(&(cPrefNF+"NUMCER"))
		MSGINFO(STR0178)
		Return .F.
	EndIf

	If &(cPrefNF+"CERORI") == "0" .And. !Empty(&(cPrefNF+"NUMCER"))
		MSGINFO(STR0179)
		Return .F.
	EndIf

	nI := 0 //Varrendo todos os itens
	For nI := 1 to IIf(nLinha>0, nLinha, Len(aDadosD))
		If !Empty(aDadosD[nI][nCanAdu])
			nSumaUSDLin += aDadosD[nI][nUsdAdu]
			nContDatA += 1
		EndIf
	Next nI

	If nContDatA != 0 .And. nContDatA != nLinha
		MSGINFO(STR0180)
		Return .F.
	EndIf

	If (Abs(nSumaUSDLin - &(cPrefNF+"TOTUSD")) > 0.01) .And. nSumaUSDLin != 0
		MSGINFO(STR0181)
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} LxMxHab
	Bloquea el campo si la Condición de pago es "99"
	@type  Function
	@author Verónica.Flores
	@since 15/09/2022
	@version 1.0
	@param cAlias  , Caracter , Alias del campo Forma de Pago F2/C5
	@param lDocSal , Logico , Si es un documento de Salida
	@return lRet, , Logico, Si se bloqueara el Campo
	@see (links_or_references)
/*/
Function LxMxHab(cAlias,lDocSal)
    Local cFormaP	 := ""
	Local lRet		 := .T.
	Default cAlias 	 := ""
	Default lDocSal	 := .T.

	cAlias := AllTrim(cAlias)

	If lDocSal
		If cAlias $ "F2"
			cFormaP := LxMxFPago(xFilial("AI0"),M->F2_CLIENTE,M->F2_LOJA,M->cCondicao,cAlias)
		Else
			cFormaP := LxMxFPago(xFilial("AI0"),M->C5_CLIENTE,M->C5_LOJACLI,M->C5_CONDPAG,cAlias)		
		EndIf
	EndIf		

	lRet :=IIF(cFormaP == "99",.F.,.T.)

Return lRet

/*/{Protheus.doc} LxMxFPago
	Indica la Condición de pago al Documento
	@type  Function
	@author Verónica.Flores
	@since 15/09/2022
	@version 1.0
	@param cAlias  , Caracter , Alias de la tabla AI0
	@param cCliente  , Caracter , Código del Cliente
	@param cLoja  , Caracter , Código de la Tienda
	@param cCondPag  , Caracter , Código de la Condición de Pago
	@param cAlias  , Caracter , Alias del campo Forma de Pago F2/C5
	@return cFormaP, Caracter, Condición de Pago para el documento
	@see (links_or_references)
/*/
Function LxMxFPago(cFilAI0,cCliente,cLoja,cCondPag,cAlias)

	Local aArea 	 := GetArea()
	Local aAreaAI0 	 := AI0->(GetArea())
	Local cFormaP	 := ""
	Default cFilAI0	 := xFilial("AI0")
	Default cCondPag := ""
	Default cCliente := ""
	Default cLoja    := ""
	Default cAlias   := ""

	If !Empty(cCliente) .And. !Empty(cLoja)

		If cAlias $ "F2" .And. Empty(cCondPag)
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			If SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
				cCondPag := SA1->A1_COND
			EndIf
		EndIf
			
		If !Empty(cCondPag)
			dbSelectArea("SE4")
			SE4->(dbSetOrder(1)) //E4_FILIAL+E4_CODIGO
			If SE4->(dbSeek(xFilial("SE4")+cCondPag))
				If SE4->E4_MPAGSAT $ "PPD|PID"
					cFormaP := "99"
					M->&(cAlias+"_TPDOC") := cFormaP
				EndIf
			EndIf
		EndIf
		If Empty(cFormaP) .and. Alltrim(M->&(cAlias+"_TPDOC"))== "" 
			dbSelectArea("AI0")
			AI0->(dbSetOrder(1)) //AI0_FILIAL+AI0_CODCLI+AI0_LOJA
			If AI0->(dbSeek(cFilAI0+cCliente+cLoja))
				cFormaP := AllTrim(AI0->AI0_MPAGO)
				M->&(cAlias+"_TPDOC") := cFormaP
			EndIf
		EndIf
			
	EndIf	

	RestArea(aAreaAI0)
	RestArea(aArea)

Return cFormaP
