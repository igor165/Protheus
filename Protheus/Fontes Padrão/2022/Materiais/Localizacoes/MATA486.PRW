#INCLUDE "protheus.ch"
#include "FILEIO.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "MATA486.CH"
#INCLUDE "FWLIBVERSION.CH"

/*/{Protheus.doc} MATA486
Rutina de Documentos electrónicos. Contiene la funcionalidad para transmitir docmentos en formato xml
a TSS.
@type
@author mayra.camargo
@since 14/06/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
³Programador  ³ Data   ³   BOPS   ³            Motivo da Alteracao
³A. Rodriguez ³10/10/18³DMINA-4582³Auto-retenciones en atributo de información adicional.
³             ³        ³          ³Motivo NDC/NCC. COL
³M.Camargo    ³26/10/18³DMINA-4575³Modificaciones validaciones catálogos perú por implementación UBL2.1.
³Luis Enríquez³31/10/18³DMINA-4669³Se agrega funcionalidad para comprabantes de retención (FE Ecuador)
³Luis Enríquez³07/11/18³DMINA-4996³Corrección consulta de comprabantes de retención (FE Ecuador)
³Luis Enríquez³13/11/18³DMINA-5100³Se elimina codificación XML retornado por proveedor teconolico (FE Colombia)
³A. Rodriguez ³31/01/19³DMINA-5743³Validaciones factura de exportación vs mercancías/servicios.
³A. Rodriguez ³15/02/19³DMINA-5484³Creación de PE M486CEXT pra campos extensibles.
³Luis Enríquez³21/02/19³DMINA-5746³Se agrega funcionalida para comunicado de baja de documentos electrónicos.
³A. Rodriguez ³19/03/19³DMINA-6080³Visualizar mensajes si falla generación de XML y si el método enviar del WS regresa falso.
³Marco A. Glez³09/04/19³DMINA-6480³Transmitir una Factura de Exportación (Cliente con A1_EST = EX) para Colombia.
³A. Rodriguez ³12/04/19³DMINA-6363³Réplica de DMINA-5959: Transferir XML del portal de TFHKA
³Marco A. Glez³29/04/19³DMINA-6288³Correcciones para la correcta generación del nodo <cac:InvoiceDocumentReference>
³             ³        ³          ³cuando se relacionen mas de un documento diferente en NCC y NDC (FE Colombia).
³M.Camargo    ³24/05/19³DMINA-6684³Implementación Integración OSE TCI para transmisión de NF, NDC, NCC y Cer. de Ret.
³Luis Enríquez³        ³          ³Ajustes para integración OSE TCI para comunicado de baja.
³M.Camargo    ³06/06/19³DMINA-6777³Ajuste localizacion de preguntas mv_par03 en adelante para que no afecten a peru.
³M.Camargo    ³06/06/19³DMINA-7000³Integración RSM Peru.
³M.Camargo    ³13/08/19³DMINA-7279³Modificación validacion comunicado de baja de 3 a 7 días.
³Luis Enríquez³19/08/19³DMINA-7002³Integración transmisión The Factory HKA model Validación Previa.
³M.Camargo    ³03/09/19³DMINA-7285³Correcciones comunicado de Baja. Atualizacion parámetro MV_IDCBAJA.
³M.Camargo    ³30/10/19³DMINA-7570³Se agrega título de la rutina y se realiza corrección de filtrado después de comunicado de baja de NNC's'.
³Luis Enríquez³28/11/19³DMINA-7405³Se activa funcionalidad de transmisión electrónica de Liquidaciones de Compra..
³Alf. Medrano ³04/12/19³DMINA-5912³Se realizan adecuaciones a las funciones MATA486, MATA486B, M486PROCTRAN, M486VLDDOC, M486MONDOC, M486SHOWMON,
³             ³        ³          ³M486GETINF, M486LEYEND, REFRESH, M486VLDCLI, M486BRWSFX, MENUDEFT  para Fac. Electrónica Bolivia.
³Luis Enríquez³06/02/19³DMINA-8044³Se agrega validación para campos F2_UUIDREL, se crea la función M486VLDCAT (COL).
³Luis Enríquez³06/02/19³DMINA-7985³Se realizan modificaciones para agrupar por certificado de retención para generera un solo XML (PER)
³Alf. Medrano ³20/04/20³DMINA-5912³Se agregan actualizaciones a las funciones, M486CORES, M486PROCTRAN, M486VLDDOC, M486SHOWMON, M486GETINF,
³             ³        ³          ³M486LEYEND, M486BRWSFX y getStatus. Factura Electrónica Bolivia.
³ARodriguez   ³14/07/20³DMINA-9425³Cambio de la clase DescargaXML por GenerarContenedor
³Luis Enríquez³06/10/20³DMINA-9971³Se realiza corrección de actualización de estatus de transmisión de comunicado de baja con RSM, para espera de procesamiento. (PER)
³Luis Enríquez³18/10/20³DMINA-10417³Se realiza auste para que en cert. de ret. la visualización de NCP sea usando la tabla SF2, y que para la generación
³             ³        ³           ³del XML se haga también fltrado por FE_SERIE2, adicional se incluyen asutes para los issues DMINA-10236 y DMINA-10299. (PER-COL-EQU)
³ Marco/Luis  ³21/10/20³DMINA-10299³Modificacion para correcta actualización de información en SFE para Ecuador.
³Marco A. Glez³18/11/20³DMINA-9912 ³Se agrega el contenido de Reglas de Validación al log de errores. (COL)  
³Luis Enríquez³26/12/20³DMINA-10666³Se realiza corrección de error.log al transmitir NCC, validación del documento relacionado a NCC al transmitir, actualización
³             ³        ³DMINA-10666³de estatus de transmisión electrónicapara NF, NCC y NDC, y se realiza corrección de filtrado para que solo se visualicen NF al entrar a MATA467N.                                 
³Oscar G.     ³26/01/21³DMINA-10917³Se ajusta impresion al log de errores mediante opcion spool. (COL) 
³Luis Enríquez³03/02/21³DMINA-10845³Se activa validación para funcionalidad de Forma de Pago para NF y NCC Fact. Electrónica. (PER)
³Luis Enríquez³11/03/21³DMINA-11442³Se actualiza campo Status Trans (F1/F2_FLFTXT) con valor 1 cuando se retorna código 114 de respuesta de la transmisión. (PER)
³Marco A. Glez³07/04/21³DMINA-11817³Se retira llamada de funcion WSNFEColProd() ya que el fuente que la contiene ha quedado obsoleto. (COL)
³Diego A. Rive³16/02/22³DMINA-14556³Creación de PE M486OPMNU para opción adicional en menú.
/*/
Function MATA486()
	Local aArea			:= getArea()
	Local cHelp 		:= ""
	Private cFiltro		:= ''
	Private cAliasB		:= 'SF2'
	Private aIndArqE	:= {}
	Private bFiltraBrw
	Private aRotina		:= {}
	Private nTDTras		:= 0
	Private cSerie		:= ""
	Private cEstatus    	:= ""
	Private dFecIni     	:= CTOD("  /  /  ")
	Private dFecFin     	:= CTOD("  /  /  ")
	Private cModelo		:= ""
	Private cMSerie		:= ""
	Private cMFacIn		:= ""
	Private cMFacFi		:= ""
	Private nTipoDoc	:= 1
	Private cEspecie	:= ""
	Private nTamEsp		:= TamSX3("F1_ESPECIE")[1]
	Private nTamDoc		:= TamSX3("F1_DOC")[1]
	Private cCRLF		:= (chr(13)+chr(10))
	Private cPergFac	:= ""
	Private _lCerRet	:= .F.
	Private  cPerg		:= "MATA486"
	Private cTipDocto	:=  ""
	Private lm486b		:= .F.
	Private cMVCFDIUS   := SuperGetMV("MV_CFDI_US",,"")
	Private cMVCFDICO   := SuperGetMV("MV_CFDI_CO",,"")
	Private cMVCFDIPA   := SuperGetMV("MV_CFDI_PA",,"")
	Private cMVCFDIAM   := SuperGetMV("MV_CFDI_AM",,"")
	Private cMVCFDICVE  := SuperGetMV("MV_CFDICVE",,"")
	Private cMVCFDIPX   := SuperGetMV("MV_CFDI_PX",,"")
	Private cMVPROVFE	:= SuperGetMV("MV_PROVFE",,"")
	Private cMVCFDDOCS	:= SuperGetMV("MV_CFDDOCS",,"")
	Private cCadastro   := STR0307 //"Documentos Electrónicos - "

	//Inicialización de preguntas
	MV_PAR03 := ""
	MV_PAR04 := CTOD("//")
	MV_PAR05 := CTOD("//")

	If cPaisLoc == "COL" .And. !fVaidaParms()
		Return
	EndIf

	If cPaisLoc == "EQU"
		If !ValParEq()
			Return
		EndIf
	EndIf

	If Empty(SuperGetMV("MV_CFDIAMB",,""))
		PutMvPar("MV_CFDIAMB","2")
	EndIf

	If Pergunte(cPerg,.T.)
		nTDTras	:= MV_PAR01
		cSerie	:= MV_PAR02

		If cPaisLoc $ "PAR|EQU" .and. nTDTras == 4
			nTDTras := 5
		ElseIf cPaisLoc=="COL" 
			If nTDTras == 4
				nTDTras := 6
			ElseIf nTDTras == 5 
				If  MV_PAR06 == 1
					cHelp := STR0422  +  chr(10)   //"Si el Tipo de Documento es Nota de Ajuste, debe seleccionar el Tipo de Nota de Ajuste : "
					cHelp +=  STR0423 +  chr(10) + STR0424//"Débito // Crédito"
					Help(" ",1,"MATA486",,cHelp,1,0)
					Return
				ElseIf MV_PAR06 == 2
					nTDTras:= 8 // Nota Ajuste Débito 
				ElseIf MV_PAR06 == 3
					nTDTras := 9 // Nota Ajuste Crédito
				Endif
			EndIf
		ElseIf (cPaisLoc=="PAR" .and. nTDTras == 5)
			nTDTras := 7 //para RTS paraguay
		EndIf
		If cPaisLoc $ "COL|BOL|EQU|PAR|PER"
			If !Empty(MV_PAR03)
				cEstatus := MV_PAR03
			EndIf
			If !Empty(MV_PAR04)
				dFecIni := MV_PAR04
			EndIf
			If !Empty(MV_PAR05)
				dFecFin := MV_PAR05
			EndIf
		EndIf
		aRotina := MENUDEFT()
		M486BRWSFX()
	EndIf

	RestArea(aArea)
Return

/*/{Protheus.doc} MATA486B
Rutina de Transmisión electrónica exclusiva de comprobantes de Retención Electrónicos
@type function
@author mayra.camargo
@since 14/07/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function MATA486B()
	Local aArea 		:= getArea()
	Private cFiltro 	:= ''
	Private cAliasB 	:= 'SFE'
	Private aIndArqE	:= {}
	Private bFiltraBrw
	Private aRotina 	:= {}
	Private nTDTras  	:= 0
	Private cSerie		:= ""
	Private cModelo	:= ""
	Private cMSerie	:= ""
	Private cMFacIn	:= ""
	Private cMFacFi	:= ""
	Private cEspecie	:= ""
	Private nTamEsp  	:= TamSX3("F1_ESPECIE")[1]
	Private nTamDoc 	:= TamSX3("F1_DOC")[1]
	Private cCRLF		:= (chr(13)+chr(10))
	Private cPergFac 	:= ""
	Private _lCerRet	:= .F.
	Private  cPerg		:= "MATA486"
	Private cTipDocto	:=  ""
	Private lm486b		:= .T.
	Private cMVCFDIUS	:= SuperGetMV("MV_CFDI_US",,"")
	Private cMVCFDICO 	:= SuperGetMV("MV_CFDI_CO",,"")
	Private cMVCFDIPA 	:= SuperGetMV("MV_CFDI_PA",,"")
	Private cMVCFDIAM 	:= SuperGetMV("MV_CFDI_AM",,"")
	Private cMVCFDICVE	:= SuperGetMV("MV_CFDICVE",,"")
	Private cMVCFDIPX 	:= SuperGetMV("MV_CFDI_PX",,"")
	Private cMVPROVFE	:= SuperGetMV("MV_PROVFE",,"")
	Private cMVCFDDOCS	:= SuperGetMV("MV_CFDDOCS",,"")
	Private cCadastro	:= ""
	If !(cPaisLoc $ "PER|EQU")
		Help( STR0150, 1, "MATA486" ) //  "Función no Disponible para Este país"
		Return
	EndIF

	_lCerRet 	:= .T.

	aRotina := MENUDEFT()

	M486BRWSFE()
	RestArea(aArea)
Return

/*/{Protheus.doc} MENUDEFT
Genera Menu para rutina MATA486
@type method
@author mayra.camargo
@since 22/06/2017
@version 1.0
@example
menufdef()
@see (links_or_references)
/*/
Static Function MENUDEFT()
	Local aRotina  := {}
	Local aOpcAdi := {}
	Local nX       := 0

	If cPaisLoc == "PER" .And. SuperGetMV("MV_PROVFE",,"") == "TSS"
		aAdd(aRotina, {STR0002 ,"M486CFGWZD"		,0,3,0,.F.}) //Configuracion
		aAdd(aRotina, {STR0003 ,"M486CFGAMB"		,0,1,0,.F.}) //Ambiente
	EndIf
	aAdd(aRotina, {IIf(cPaisLoc == "EQU", STR0174, STR0004) ,"M486TRANSNF"		,0,1}) //Enviar //Transmitir
	If cPaisLoc == "BOL" .and. FindFunction("M486MNDCBO")
		aAdd(aRotina, {STR0005 ,"M486MNDCBO(.F.)"	,0,1}) //Monitor
	ElseIf cPaisLoc $ "PER|BOL" .Or. SuperGetMV("MV_PROVFE",,"") == "TSS" .Or. (cPaisLoc == "EQU" .Or. SuperGetMV("MV_PROVFE",,"") == "STUPENDO") ;
		.Or. (cPaisLoc == "COL" .Or. SuperGetMV("MV_PROVFE",,"") == "DFACTURA")
		aAdd(aRotina, {STR0005 ,"M486MONDOC(.F.)"	,0,1}) //Monitor
	EndIf
	If (funname() $ "MATA486")
		If ExistBlock("M486PDFGEN")
			aAdd(aRotina, {STR0006 ,"ExecBlock('M486PDFGEN',.F.,.F.,{})"		,0,1}) //Imprimir PDF
		Else
			If (cPaisLoc <> "EQU" .And. cMVPROVFE <> "STUPENDO")
				aAdd(aRotina, {IIf(cPaisLoc $ "COL|PER",STR0406,STR0006),"M486IMPPDF"		,0,1}) //"Imprimir PDF / Envío por Email" //"Imprimir PDF"
			EndIf
		EndIf
		If cPaisLoc == "COL"
			aAdd(aRotina, {STR0221 ,"M486RECXML"	,0,1}) //Recupera XML
		EndIf
	EndIf
	If cPaisLoc == "PER"
		If Type("nTDTras") <> "U"
			If nTDTras == 1 .Or. nTDTras == 2 .Or. nTDTras == 3 .Or. (_lCerRet .And. SuperGetMV("MV_PROVFE",,"") $ "TCI|TSS")
				aAdd(aRotina, {IIf(_lCerRet,STR0366,STR0194),"M486CBAJA()"		,0,1}) //"Resumen Diario de Reversión" //"Comunica baja"
			EndIf
			If cMVPROVFE $ "TCI|TSS" .And. (nTDTras == 2 .Or. nTDTras == 3 .Or. nTDTras == 4) .And. FindFunction("M486RDXML")
				aAdd(aRotina, {STR0343 ,"M486CBAJA(.T.)"		,0,1}) //"Resumen Diario"
			EndIf
		EndIf
		If cMVPROVFE == "TSS" 
			aAdd(aRotina, {STR0420 ,"M486GETXML(cEspecie, _lCerRet)"	,0,1}) //"Recupera XML/PDF"
		EndIf
	EndIf
	If cPaisLoc == "BOL"
		If Type("nTDTras") <> "U"
			If nTDTras == 1 .Or. nTDTras == 2 .Or. nTDTras == 3
				aAdd(aRotina, {STR0319 ,"M486XFBOLB()"		,0,1}) //"Anulación Fac. Electrónica"
			EndIf
		EndIf
	EndIf
	If cPaisLoc == "PAR" .and. FindFunction("M486CANCDE") .and. cEstatus == "5"
		aAdd(aRotina, {STR0319 ,"M486CANCDE(nTDTras)"		,0,1}) //"Anulación Fac. Electrónica"
	EndIf
	If cPaisLoc $ "PER|COL|EQU" .and. ExistBlock("M486OPMNU")
		aOpcAdi:= ExecBlock("M486OPMNU",.F.,.F.)
		FOR nX := 1 to Len(aOpcAdi)
			aAdd(aRotina, aOpcAdi[nX])
		NEXT nX
	EndIf
	If cPaisLoc == "PAR" .And. FindFunction("M486FILPAR") .And. ALLTRIM(SuperGetMV("MV_TIPTRAN",,"S")) == "A"
		aAdd(aRotina, {STR0005 ,"M486FILPAR(.F.)"	,0,1}) 
	ENDIF
	aAdd(aRotina, {STR0007 ,"M486VISNFE"		,0,1}) //Visualizar
	aAdd(aRotina, {STR0068 ,"M486LEYEND"		,0,1}) //Leyenda
	aAdd(aRotina, {STR0008 ,"PesqBrw"			,0,1}) //Buscar
Return aRotina

/*/{Protheus.doc} M486CORES
Retorna array con colores dependiento del tipo de documento
@type function
@author mayra.camargo
@since 22/06/2017
@version 1.0
@param nType, numérico, (Tipo de documento 1 para documentos en sf2, 2 para documentos en sf1 y 3 para comp de ret)
@return aCores
@example
(examples)
@see (links_or_references)
/*/
Static Function M486CORES(nType)
	Local aCores := {}
	Default nType := 1

	If nType == 1
		aCores :={{"F2_FLFTEX==' ' .or. F2_FLFTEX=='0'",'BR_CINZA' },;		    //No transmitida
						{"F2_FLFTEX=='6'",'BR_VERDE'},;						    //Documento autorizado
						{"F2_FLFTEX=='5' .OR. F2_FLFTEX=='3'",'BR_VERMELHO'},;  //Documento rechazado
						{"F2_FLFTEX=='4' .OR. F2_FLFTEX=='2'",'BR_AMARELO'},;   //Aguardando procesamiento
						{"F2_FLFTEX=='1'",'BR_AZUL'},;                          //Recibido por TSS
						{"F2_FLFTEX=='7'",'BR_PINK'},;                          //Aguardando procesamiento - Comunicado de baja
					    {"F2_FLFTEX=='8'",'BR_LARANJA'}}                        //Documento autorizado - Comunicado de baja
					    IIF(cPaisLoc == "BOL", aAdd(aCores, {"F2_FLFTEX=='9'",'BR_PRETO'}), )//Anulación Rechazada
	ElseIf nType == 2
		aCores  :={{"F1_FLFTEX==' ' .or. F1_FLFTEX=='0'",'BR_CINZA' },;	        //No transmitida
						{"F1_FLFTEX=='6'",'BR_VERDE'},;							//Documento autorizado
						{"F1_FLFTEX=='5' .OR. F1_FLFTEX=='3'",'BR_VERMELHO'},;	//Documento rechazado
						{"F1_FLFTEX=='4' .OR. F1_FLFTEX=='2'",'BR_AMARELO'},;	//Aguardando procesamiento
						{"F1_FLFTEX=='1'",'BR_AZUL'},;						    //Recibido por TSS
						{"F1_FLFTEX=='7'",'BR_PINK'},;                          //Aguardando procesamiento - Comunicado de baja
					    {"F1_FLFTEX=='8'",'BR_LARANJA'}}                        //Documento autorizado - Comunicado de baja
	ElseIf nType == 3
		aCores:={{"FE_STATUS==' ' .or. FE_STATUS=='0'",'BR_CINZA' },;		    //No transmitida
					{"FE_STATUS=='6'",'BR_VERDE'},;								//Documento autorizado
					{"FE_STATUS=='5' .OR. FE_STATUS=='3' ",'BR_VERMELHO'},;		//Documento rechazado
					{"FE_STATUS=='4'",'BR_AMARELO'},;							//Aguardando procesamiento
					{"FE_STATUS=='1'",'BR_AZUL'},;                              //Recibido por TSS
					{"FE_STATUS=='7'",'BR_PINK'},;                              //Aguardando procesamiento - Res. Diario Reversión
					{"FE_STATUS=='8'",'BR_LARANJA'}}                            //Documento autorizado - Res. Diario Reversión							
	EndIf

Return aCores

/*/{Protheus.doc} M486CFGWZD
Crea el wizard de configuración para integrar Protheus con TSS
@type function
@author mayra.camargo
@since 06/07/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486CFGWZD()
	Local oWizard
	Local cURL      := Space(250) //Parametro que almacena la url de TSS
	Local cCert     	:= Space(250)
	Local cPassWord 	:= Space(24)
	Local cCombo    	:= ""
	Local aTexto    	:= {}
	Local oCombo		:= Nil
	Local aCombo 		:= {}

	Private cMensaje := STR0012 //Concluyó con éxito la configuración de la integración del Protheus al Totvs Services

	If PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0

		aadd(aTexto,{})
		aadd(aCombo,STR0036) //"1-Produccion"
		aadd(aCombo,STR0037) //"2-Homologacion"

		cCombo := aCombo[2]
		aTexto[1] := STR0013+CHR(13)+CHR(10) //"Esta rutina tiene como objetivo ayudarlo en la configuracion de la integración del Protheus con el servicio Totvs Services. "
		aTexto[1] += STR0014//"El primer paso es configurar la conexión del Protheus con el servicio."

		aadd(aTexto,{})
		aTexto[2] := STR0012 //"Concluyó con éxito la configuración de la integración del Protheus al Totvs Services"
		oWizard = APWizard():New(STR0015, STR0016, STR0017, aTexto[1],; //Atención //"Siga atentamente los pasos para la configuración de la transmisión eletrónica." //"Asistente de configuración para la transmisión electrónica"
											 {|| .T.}, {|| .T.}, , , , )
		oWizard:NewPanel( STR0017, "", /*<bBack>*/, {|| M486VLDCFG(cUrl, cCert, cPassWord,cCombo)}, {|| .T.}, ,  ) //"Asistente de configuración para la transmisión electrónica"
		@ 010,010 SAY STR0018 SIZE 270,010 PIXEL OF oWizard:oMPanel[2] //"Informe la URL del servidor Totvs Services"
		@ 025,010 GET cURL SIZE 270,010 PIXEL OF oWizard:oMPanel[2]

		@ 045,010 SAY STR0019 SIZE 270,010 PIXEL OF oWizard:oMPanel[2] //"Informe el nombre del archivo del certificado digital"
		@ 055,010 GET cCert SIZE 240,010 PIXEL OF oWizard:oMPanel[2]
		TButton():New( 055,250,STR0047,oWizard:oMPanel[2],{||cCert := cGetFile(STR0048,STR0049,0,"",.T.,GETF_LOCALHARD),.T.},29,12,,oWizard:oMPanel[2]:oFont,,.T.,.F.,,.T., ,, .F.) //"Drive: " //"Archivos(.PFX)|*.PFX|Archivos(.P12)|*.P12" //"Seleccione el certificado"
		@ 075,010 SAY STR0020 SIZE 270,010 PIXEL OF oWizard:oMPanel[2] //"Informe la contraseña del archivo digital"
		@ 075,110 GET cPassWord SIZE 060,010 PIXEL OF oWizard:oMPanel[2] PASSWORD
		@ 095,010 SAY STR0003 SIZE 270,010 PIXEL OF oWizard:oMPanel[2] //AmbienteMV_
		@ 095,110 COMBOBOX oCombo VAR cCombo ITEMS aCombo  SIZE 165,013 PIXEL OF oWizard:oMPanel[2]

		oWizard:NewPanel( STR0017, "", {|| .T.}, {|| .T.}, {|| .T.}, ,  ) //"Asistente de configuración para la transmisión electrónica"
		@ 010,010 SAY cMensaje SIZE 270,100 PIXEL OF oWizard:oMPanel[3]
		oWizard:Activate()
	Else
		Help( "", 1, "SEMPERM" )
	EndIf
Return

/*/{Protheus.doc} ContParam
Obtiene el contenido del parametro indicado
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param cParam, character, Nombre del parámetro en SX6
@return cRet, Contenido del parámetro
@example
(examples)
@see (links_or_references)
/*/
Static Function ContParam(cParam)
	Local cRet := Padr(GetmV(cParam,,""),250)
Return cRet

/*/{Protheus.doc} M486VLDCFG
(long_description)
@type function
@author mayra.camargo
@since 06/07/2017
@version 1.0
@param cUrl, character, (URL de conexion a TSS)
@param cCert, character, (Certificado digital)
@param cPass, character, (Password del Certificado)
@param cCombo, character, (mbiente)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486VLDCFG(cUrl, cCert, cPass, cCombo)
	Local lRet := .F.
	Local nH   := 0
	Local cEnt    := ""

	CursorWait()
	If Empty(cUrl)
		MsgAlert(STR0021) //"Ingresa una URL"
	ElseIf Empty(cPass)
		MsgAlert(STR0022) //"Ingresa la contraseña del certificado digital"
	ElseIf Empty(cCert)
		MsgAlert(STR0023) //"Selecciona el certificado digital"
	Else
		nH := fopen(cCert, FO_READ)
		If nH == -1
			MsgAlert(STR0030) //"El archivo especificado no existe"
		Else
			PutMvPar("MV_WSRTSS", cUrl) //Parametro que almacena la url de TSS
			If cPaisLoc == "PER"
				cEnt := GetIdEnt()
				If !Empty(cEnt)
					RegEmp(cEnt,cCert,cPass,cURl)
					m486AMB(cURL,SubStr(cCombo,1,1),cEnt)
					lRet := .T.
				EndIf
			ElseIf cPaisLoc == "COL"
				cURl := ALLTRIM(cURl)
			    // Se registra en el parámetro al ambiente configurado
				PutMvPar("MV_CFDIAMB",SubStr(cCombo,1,1))
				M486REGEMP(cCert,cPass,cURl)
				lRet := .T.
			EndIf
		EndIf
	EndIf
	CursorArrow()
Return lRet

/*/{Protheus.doc} GetIdEnt
Obtiene el código de la entidad a enviar para TSS
@type function
@author mayra.camargo
@since 06/07/2017
@version 1.0
@return ${cIdEnt}, ${Id de la entidad recuperado de TSS}
@example
(examples)
@see (links_or_references)
/*/
Static Function GetIdEnt()
	Local aArea  := GetArea()
	Local cIdEnt := ""
	Local cURL   := ContParam("MV_WSRTSS") //Parametro que almacena la url de TSS
	Local oWs

	If !Empty(cFilAnt)
		SM0->(dbSetOrder(1))
		SM0->( dbSeek(cEmpAnt + cFilAnt ) )
	Endif

	oWs:=WSNFECFGLOC():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:_URL       := AllTrim(cURL)+"/NFECFGLOC.apw"
	oWS:oWSEMPRESA:cBAIRRO		:= SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cCIDADE     	:= SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCOD_PAIS   	:= fGetPais() //funcion para obtener el pais
	oWS:oWSEMPRESA:cCODFIL 	   := FWGETCODFILIAL
	oWs:oWSEMPRESA:cCODPROVINC  := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCOMPL      	:= FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cCP        	:= SM0->M0_CEPENT
	oWs:oWSEMPRESA:cCUIT      	:= ""
	oWs:oWSEMPRESA:cDDN        := ""
	oWS:oWSEMPRESA:cDESCPROVINC	:= SM0->M0_CIDENT
	oWS:oWSEMPRESA:cEMAIL      	:= ""
	oWS:oWSEMPRESA:cENDERECO   	:= FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cFANTASIA   	:= SM0->M0_NOME
	oWS:oWSEMPRESA:cFAX        := AllTrim(FisGetTel(SM0->M0_FAX)[3])
	oWS:oWSEMPRESA:cFONE       := Alltrim(FisGetTel(SM0->M0_TEL)[3])
	oWS:oWSEMPRESA:cINSCRPROVI 	:= SM0->M0_INSC
	oWS:oWSEMPRESA:cNOME       	:= SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWs:oWSEMPRESA:cREGMUN     	:= ""
	oWs:oWSEMPRESA:cRUC        := SM0->M0_CGC

	If oWS:ADMEMPLOC()
		cIdEnt  := oWS:cADMEMPLOCRESULT
	Else
		cMensaje := GetWSCError()
		If "WSCERR044" $ cMensaje
			cMensaje := STR0132 // "Imposible establecer conexión con Totvs Services Server. TSS Offline."
		Else
			cMensaje := STR0031 + GetWSCError()//"Error en la configuración de la Integración del Protheus al Totvs Services"
		EndIf
		MsgAlert(cMensaje)
	EndIf

	oWs := Nil
	DelClassIntF()
	RestArea(aArea)
Return(cIdEnt)

/*/{Protheus.doc} M486REGEMP
Función encargada de registrar las empresas en TSS y enviar el certificado digital
@type function
@author mayra.camargo
@since 20/06/2018
@version 1.0
@param cArq, Caracter, Archivo con certificado digital
@param cSenha, Contraseña del certificado digital
@param cUrl, URL de la API REST de TSS
@return a
(examples)
@see (links_or_references)
/*/
Static function M486REGEMP(cArq,cSenha,cUrl)
	Local lRet 			:= .T.
	Local oRestClient 	:= FWRest():New(cUrl)
	Local cJSON 		:= ""
	Local aHeader 		:= {}
	Local cBase64 		:= Encode64(FsLoadTXT(cArq))
	Local oObj			:= Nil
	Local cHost			:= fGetHost(cUrl)
	Local cIdSoft		:= ALLTRIM( GETNEWPAR( "MV_ID_SOFT" , "dc82b3d3-3ab3-4825-bb2c-f3b255650849" ) )//
	Local cPWD			:= ALLTRIM( GETNEWPAR( "MV_ID_PWD" , "2845850b92ca972474c8a721a7317394261f3f4cb54acbd57142c1990d1cd11b") )

	cSenha := Encode64(ALLTRIM(cSenha))
	// Aquí va el consumo de la API REST para registro de empresa
	// http://localhost:8443/api/tss
	aAdd(aHeader,"Content-Type: application/json")
	aAdd(aHeader,"UserName: " + cMVCFDIUS )
	oRestClient:setPath("/companies/v1/location/colombia/")

	cJSON := '{'
 	cJSON += '"nit": "'+SM0->M0_CGC+'",'
 	cJSON += '"branch": "'+FWGETCODFILIAL+'",'
  	cJSON += '"codeProv": "'+ SM0->M0_ESTENT +'",'
  	cJSON += '"insProv": "'+SM0->M0_INSC+'",'
  	cJSON += '"country": "CO",'
  	cJSON += '"user": "'+cIdSoft+'",'
  	cJSON += '"password": "'+cPWD+'",'
 	cJSON += '"certificates": { '
   	cJSON +=   '"a1": { '
	cJSON +=      ' "certificate": "' + cBase64 +'",'
	cJSON +=      ' "password": "'+ cSenha +'"'
	cJSON +=  '} '
	cJSON +=  '}'
	cJSON +=  '}'

   	oRestClient:SetPostParams(cJSON)

	If oRestClient:Post(aHeader)
		If FWJsonDeserialize(oRestClient:GetResult(),@oObj)
			If oObj <> Nil
			 	If AttIsMemberOf(oObj,"CompanyId")
			 		MsgAlert(oObj:MESSAGE)
			 		PutMvPar("MV_COMPID", oObj:CompanyId)
			 		cMensaje := STR0012 // "Concluyó con éxito la configuración de la integración del Protheus al Totvs Services"
			 		lRet := .T.
			 	Else
			 		//Aqui se tiene que hacer un PUT FALTA IMPLEMENTAR
			 		MsgAlert(STR(oObj:CODE) + " - " + oObj:MESSAGE)
			 		cMensaje := STR(oObj:CODE) + " - " + oObj:MESSAGE
			 		lRet := .F.
			 	EndIf
			Else
				MsgAlert(STR0161) // "Error Desconocido"
			EndIf
		Endif
	Else
		IF FWJsonDeserialize(oRestClient:GetResult(),@oObj)
			If oObj:Code == 40501
				MsgAlert(oObj:Message)
				cMensaje := STR0012 // "Concluyó con éxito la configuración de la integración del Protheus al Totvs Services"
				lRet := .T.
			Else
				cMensaje := STR0031 // "Error en la configuración de la Integración del Protheus al Totvs Services"
				lRet := .F.
			EndIf
		Else
			MsgAlert(STR0156 + oRestClient:GetLastError()) // "No se pudo realizar registro de la Entidad en TSS. Error : "
			lRet := .F.
		EndIf
	Endif
	oRestClient := Nil
	oObj := Nil
Return lRet

/*/{Protheus.doc} RegEmp
Registra en TSS el certificado digital de la Entidad
@type function
@author mayra.camargo
@since 06/07/2017
@version 1.0
@param cIdEnt, character, (Id de la Entidad TSS)
@param cArq, character, (Nombre del certificado digital)
@param cSenha, character, (Contraseña del certificado digital)
@param cUrl, character, ( url de los servicios TSS)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function RegEmp(cIdEnt,cArq,cSenha,cUrl)

	Local cBase64 := ""
	Default cArq    := ""
	Default cSenha  	:= ""
	Default cURL		:= ""

	cBase64 := FsLoadTXT(cArq)

	If !Empty(cIdEnt)
		oWS := WSTSSWSSUNAT():NEW()
		oWs:cUSERTOKEN:= "TOTVS"
		oWs:cIDENT	:= cIdEnt
		oWs:cCertificate := cBase64
		oWs:cPASSWORD    := AllTrim(cSenha)
		oWS:_URL		:=  AllTrim(cURL) + "/TSSWSSUNAT.apw"
		If oWs:CertPfx()
			Aviso(STR0015,oWS:cCERTPFXRESULT,{"OK"},3) // "Atención"
			cMensaje := STR0018 + CHR(13)+CHR(10) + oWS:cCERTPFXRESULT//  "Concluyó con éxito la configuración de la integración del Protheus al Totvs Services" +
		Else
			cMensaje := STR0031 + CHR(13)+CHR(10) +  GetWscError()//"Error en la configuración de la Integración del Protheus al Totvs Services"
			Aviso(STR0015,IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3) // "Atención"
		EndIf
	EndIf
Return

/*/{Protheus.doc} FsLoadTXT
Lee certificado digital y convierte para enviar a tss
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param cFileImp, character, Nombre del archivo a ser leido
@return cRet}, Texto con el contenido del archivo leido
@example
(examples)
@see (links_or_references)
/*/
Static Function FsLoadTXT(cFileImp, lLocal)
	Local cTexto     := ""
	Local cNewFile   := ""
	Local cExt       := ""
	Local cStartPath := GetSrvProfString("StartPath","")
	Local nHandle    := 0
	Local nTamanho   := 0

	Default lLocal := .T.
	cStartPath := StrTran(cStartPath,"/","\")
	cStartPath +=If(Right(cStartPath,1)=="\","","\")
	If lLocal
		CpyT2S(cFileImp,cStartPath)
		SplitPath(cFileImp,/*cDrive*/,/*cPath*/, @cNewFile,cExt)
		cNewFile := cNewFile+cExt
	Else
		cNewFile := cFileImp
	EndIf

	nHandle := FOpen(cNewFile)
	If nHandle > 0
		nTamanho := Fseek(nHandle,0,FS_END)
		FSeek(nHandle,0,FS_SET)
		FRead(nHandle,@cTexto,nTamanho)
		FClose(nHandle)
		IF lLocal
			FErase(cNewFile)
		EndIf
	EndIf

	cTexto := Strtran(cTexto,Chr(239) + Chr(187) + Chr(191) , "")	// Quita códificación UTF-8
Return(cTexto)

/*/{Protheus.doc} M486CfgAmb
Configura el ambiente utilizado en el TSS
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486CfgAmb()
	Local aPerg  := {}
	Local aCombo1:= {}
	Local cCombo1:= ""
	Local cCombo2:= ""
	Local cCombo3:= ""
	Local cCombo4:= ""
	Local cCombo5:= ""
	Local cIdEnt := ""
	Local cURL   := ContParam("MV_WSRTSS") //Parametro que almacena la url de TSS
	Local nTempo := 0
	Local cParNfePar := SM0->M0_CODIGO+SM0->M0_CODFIL+"NFEPERU"
	Private cMensaje := ""

	aadd(aCombo1,STR0036) //"1-Produccion"
	aadd(aCombo1,STR0037) //"2-Homologacion"

	cIdEnt := GetIdEnt()
	cCombo1 := GetAmbien(cIdEnt)


	If SubStr(cCombo1,1,1) == "1"
		cCombo1 := STR0036 //"1-Produccion"
	else
		cCombo1 := STR0037 // "2-Homologacion"
	Endif

	aadd(aPerg,{2,STR0038,cCombo1,aCombo1,120,".T.",.T.,".T."}) //¿Ambiente

	aParam := {SubStr(cCombo1,1,1),SubStr(cCombo2,1,1),cCombo3,cCombo4,cCombo5,nTempo}
	If ParamBox(aPerg,STR0039,aParam,,,,,,,cParNfePar,.F.,.F.) //"Configuración Ambiente de Transmisión Electrónica"
		m486AMB(cURL,aParam[1],cIdEnt)
	EndIf
Return

/*/{Protheus.doc} M486AMB
(long_description)
@type
@author mayra.camargo
@since 22/06/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static function M486AMB(cURL,cAmb,cIdEnt)
	Local lRet := .F.
	Local oWS	:= Nil

	oWS :=  WSNFECFGLOC():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nAmbiente  := Val(cAmb)
	oWS:_URL       :=  AllTrim(cURL)+"/NFECFGLOC.apw"
	If oWS:CFGAMBLOC()
		cAmbien := oWS:CCFGAMBLOCRESULT
		If val(cAmbien) == 1
			MsgAlert(STR0040+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0036) //"Ambiente Configurado:" //"1-Producción"
			cMensaje += STR0040+CHR(13)+CHR(10) +CHR(10)+STR0036
		Else
			MsgAlert(STR0040+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0037) //"Ambiente Configurado:" //"2-Homologación"
			cMensaje += CHR(13)+ CHR(10) + STR0040+ STR0037
		EndIf
		lRet := .T.
	Else
		MsgAlert(GetWSCError())
	EndIf
	oWS := Nil

Return lRet

/*/{Protheus.doc} GetAmbien
Obtiene el ambiente que esta utilizando el TSS
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param cIdEnt, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GetAmbien(cIdEnt)
	Local oWs := WSNFECFGLOC():New()
	Local cAmbiente := ""
	Local cURL      := ContParam("MV_WSRTSS") //Parametro que almacena la url de TSS

	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nAmbiente  := 0
	oWS:_URL       := AllTrim(cURL)+"/NFECFGLOC.apw"
	If oWS:CFGAMBLOC()
		cAmbiente := oWS:CCFGAMBLOCRESULT
		If val(cAmbiente) == 1
			cAmbiente := STR0036 //"1-Producción"
		Else
			cAmbiente := STR0037 //"2-Homologación"
		EndIf
	Else
		MsgAlert(GetWSCError())
	EndIf
Return cAmbiente

/*/{Protheus.doc} M486TRANSNF
Detona el proceso de transmisión a TSS de los documentos informados en aprámetros
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486TRANSNF()
	Local cSerie := space(3)
	Local cFacIn := space(13)
	Local cFacFi := space(13)

	Private cLog:=""
	Private aTrans := {}
	Private aError := {}

	If Pergunte(cPergFac,.T. )
		Pergunte(cPergFac, .F.)
		If !_lCerRet
			cSerie:= MV_PAR01
			cFacIn := MV_PAR02
			cFacFi := MV_PAR03
		Else
			If cPaisLoc == "EQU"
				cFacIn := MV_PAR01
				cFacFi := MV_PAR02
			Else
				cSerie := MV_PAR01
				cFacIn := MV_PAR02
				cFacFi := MV_PAR03
			EndIf
		EndIf
		M486PROCTRAN(cSerie, cFacIn, cFacFi)
	EndIf
Return

/*/{Protheus.doc} M486PROCTRAN
Realiza la llamada funciones de validacion de documentos. Después transmite hacia TSS y llama generación de log de errores.
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param cSerie, character, (Descrição do parâmetro)
@param cFacIn, character, (Descrição do parâmetro)
@param cFacFi, character, (Descrição do parâmetro)
@param nGuardar, numérico, Guardar xml en 1-ruta de prptheus_data, 2-carpeta local
@param cRuta, caracter, Carpeta donde se guardará el xml
@param nAmb, numérico, (Descrição do parâmetro)
@param cMod, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486PROCTRAN(cSerie, cFacIn, cFacFi, nGuardar, cRuta, nAmb, cMod)
	Local lRet 	:= .T.
	Local oWs		:= Nil
	Local nX 		:= 0
	Local nI        := 0
	Local aFact 	:= {}
	Local aError    := {}
	Local aTrans	:= {}
	Local cIdEnt	:= ""
	Local cAmb		:= 1
	Local cUrl		:= GetNewPar("MV_WSRTSS","")
	Local cMsgLog	:= STR0100 // "¿Desea visualizar log de Transmisión?"
	Local nTotDoc	:= 0
	Local lGerarCFD := .F.
	Local aGerarCFD := {}
	Local cQuery    := ""
	Local cAliasRet := CriaTrab(Nil, .F.)
	Local lRecuperaXml := IsInCallStack("M486RECXML")
	Local lTSS	    := .F.
	Local lRetSal	:= .T.
	Local cCtrl     := (chr(13)+chr(10))
	Local cMsgVld   := ""
	Local cSubRutina:= ""
	Local cTxtAuto  := IIf(isBlind(), "_auto", "")
	Local aM486EBOL	:= {}
	Local aNoEnv    := {}
	Local lDocSopor	:= (cPaisLoc=="COL" .AND. nTDTras == 6)

	Private cCRet   := ""
	Private aDocAct := {}
	Private cProvFE := SuperGetMV("MV_PROVFE",,"")

	Default cSerie	:= ""
	Default cFacIn	:= ""
	Default cFacFi  := ""
	Default cMod	:= ""

	CURSORWAIT()

	lTSS := cProvFE == "TSS"  .Or. Empty(cProvFE)

	// Valida que exista configuración de conexión a TSS
	If Empty(cURL) .And. lTSS  .And. !(cPaisLoc $ "BOL|PAR")
		MsgAlert(STR0131) // "No se realizó la Configuración de conexión con TSS. Ejecute opción Configuración"
		CURSORARROW()
		Return .F.
	EndIf

	If cPaisLoc == "COL" .And. SuperGetMV("MV_PROVFE",,"") == "TSS"
		__CompanyId := GetNewPar("MV_COMPID","")
		If Empty(__CompanyId)
			MsgAlert(STR0131) // "No se realizó la Configuración de conexión con TSS. Ejecute opción Configuración"
			CURSORARROW()
			Return .F.
		EndIf
	EndIf

	//Validación de datos de empresa (SIGAMAT)
	If cPaisLoc == "EQU"
		lRet := M486VSM0EQ()
	Else
		If !(cPaisLoc == "COL" .or. (cPaisLoc == "BOL" .and. "VULCAN" $ cProvFE))
			lRet := M486VSM0()
		EndIf
	EndIf

	If !lRet
		CURSORARROW()
		Return .F.
	EndIf

	If cPaisLoc == "PER" .And. lTSS
		cIdEnt := GetIdEnt()
		If Empty(cIdEnt)
			MsgAlert(STR0133) // "Imposible recuperar Id entidad en TSS"
			CURSORARROW()
			Return .F.
		EndIf
	ElseIf cPaisLoc == "PER" .And. !lTSS
		lGerarCFD := M486VldPar()
		If !lGerarCFD
			CURSORARROW()
			Return .F.
		EndIf
	ElseIf cPaisLoc $ "COL|EQU|BOL|PAR"
		If FindFunction("CFDVerific")
			aGerarCFD := CFDVerific()
		Endif
		If Len(aGerarCFD) > 0
			If Empty(aGerarCFD[2])
				lGerarCFD := .T.
			EndIf
		EndIf

		If !lGerarCFD
			If cPaisLoc== "COL" .And. cProvFE == "DFACTURA"
				If !Empty(aGerarCFD[2])
					cMsgVld := STR0143 + cCtrl //"Verificar las siguientes configuraciones necesarias para Facturación Electrónica:"
					For nI := 1 To Len(aGerarCFD[2])
						cMsgVld += "-" + aGerarCFD[2][nI][2] + cCtrl
					Next nI
				EndIf
				If !Empty(cMsgVld)
					MsgAlert(cMsgVld)
				EndIf
			Else
				MsgAlert(STR0154 + chr(10) + chr(13) + STR0155) // "No se han realizado las onfiguraciones de Parámetros para generación de XML. " " La operación no puede continuar"
			EndIf			
			CURSORARROW()
			Return .F.
		EndIf

	EndIf

	// Valida datos rango de facturas
	If !_lCerRet
		Processa({|lEnd| lRet := M486VLDDOC(cFacIn,cFacFi,cSerie,@aFact,@aError,@nTotDoc,lRecuperaXml)},STR0087) // Realizando validación documentos ...
	ElseIf cPaisLoc $ "PER|EQU" .and. _lCerRet
		Processa({|lEnd| lRet := M486VLDCR(cFacIn,cFacFi,cSerie,@aFact,@aError,@nTotDoc)},STR0087) // Realizando validación documentos ...
	EndIF

	If len(aError) == 0 .and. len(aFact) == 0
		MsgAlert(STR0053) // "No se Encontraron registros con los parámetros establecidos"
		CURSORARROW()
		Return .F.
	EndIF

	If len(aFact) > 0 // Realiza envió de documentos a TSS /OSE
		If cPaisLoc == "PER"
			If lTSS
				Processa({|lEnd| lRet := M486SENDDOC(aFact,@aError,cUrl,@aTrans)},STR0101) //"Transmitiendo Documentos..."
			Else
				Processa({|lEnd| lRet := M486GENDOC(aFact,@aError,@aTrans)},STR0101) //"Transmitiendo Documentos..."
			EndIf

		ElseIf cPaisLoc == "COL" .AND. lGerarCFD
			If !lRecuperaXml
				Processa({|lEnd| lRet := M486GERXML(aFact,@aError)} ,STR0146) // Generando Documentos XML
				If SuperGetMV("MV_PROVFE",,"") == "TSS"
					Processa({|lEnd| lRet := M486SENDXML(aFact,@aError,cUrl,@aTrans)},STR0101) //"Transmitiendo Documentos..."
				Else
					Processa({|lEnd| lRet := M486SENDPT(aFact,@aError,cUrl,@aTrans,@aNoEnv)},STR0101) //"Transmitiendo Documentos..."
				EndIf
			Else
				Processa({|lEnd| lRet := M486BajaXML(aFact,@aError,cUrl,@aTrans,nGuardar,cRuta)},STR0324) //"Descargando archivos XML y PDF..."
			EndIf
			lRet := .T.

		ElseIf cPaisLoc == "EQU" .AND. lGerarCFD
			If _lCerRet
				cFacIn := MV_PAR01
				cFacFi := MV_PAR02
				cArqIni := &(GetNewPar("MV_CFDFTCR",""))

				cQuery += "SELECT DISTINCT(SFE.FE_NROCERT),SFE.FE_FORNECE,SFE.FE_LOJA,SFE.FE_NFISCAL,SFE.FE_SERIE
			    cQuery += "FROM " + RetSqlName("SFE") + " SFE "
				cQuery += "WHERE SFE.FE_FILIAL = '" + xFilial("SFE") + "' "
				cQuery += "AND SFE.FE_NROCERT BETWEEN '" + cFacIn + "' AND '" + cFacFi + "' "
				cQuery += "AND SFE.D_E_L_E_T_ = ''"

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasRet, .T., .T.)

				count to nCount

				(cAliasRet)->(dbGoTop())
				While (!(cAliasRet)->(EOF()))
					dbSelectAre("SF1")
					dbSetOrder(1) //F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
					If dbSeek(xFilial("SF1") + (cAliasRet)->FE_NFISCAL + (cAliasRet)->FE_SERIE + (cAliasRet)->FE_FORNECE + (cAliasRet)->FE_LOJA)
						cCRet := (cAliasRet)->FE_NROCERT
						Processa({|| ProcNorma(cArqIni,,&(GetNewPar("MV_CFDDOCS","")))})
						If SuperGetMV("MV_PROVFE",,"") == "STUPENDO"
							Processa({|lEnd| lRet := M486SENDST(aFact,@aError,@aTrans, cEspecie)},STR0101) //Transmitiendo Documentos...
						EndIf
					Else
						aAdd(aError, {"", (cAliasRet)->FE_SERIE, (cAliasRet)->FE_NFISCAL, (cAliasRet)->FE_FORNECE, (cAliasRet)->FE_LOJA, STR0190}) //"Documento no procesado - No existe registro en tabla SF1 - Encabezado de Fact. de Entrada."
						aAdd(aTrans, {"", (cAliasRet)->FE_SERIE, (cAliasRet)->FE_NFISCAL, (cAliasRet)->FE_FORNECE, (cAliasRet)->FE_LOJA, STR0190}) //"Documento no procesado - No existe registro en tabla SF1 - Encabezado de Fact. de Entrada."
					EndIf
					(cAliasRet)->(dbSkip())
				EndDo
				(cAliasRet)->(dbCloseArea())

			Else
				Processa({|lEnd| lRet := M486GERXML(aFact,@aError)} ,STR0146) // Generando Documentos XML
				If SuperGetMV("MV_PROVFE",,"") == "STUPENDO"
					Processa({|lEnd| lRet := M486SENDST(aFact,@aError,@aTrans, cEspecie)},STR0101) //Transmitiendo Documentos...
				EndIf

			EndIf
		ElseIf cPaisLoc == "BOL" .AND. lGerarCFD
			If "VULCAN" $ cProvFE
				Processa({|lEnd| lRet := M486VULFAC(aFact, @aError,@aTrans,cEspecie)}, "") //
			ElseIf ExistBlock("M486EBOL")
				aM486EBOL := ExecBlock("M486EBOL",.F.,.F.,{aFact, cEspecie})
				If ValType(aM486EBOL) == "A"
					If Len(aM486EBOL) > 0
						aError := aM486EBOL[1]
					EndIf
					If Len(aM486EBOL) > 1
						aTrans := aM486EBOL[2]
						M486UPDB(aTrans, cEspecie)
					EndIf
				EndIf
			ElseIf !lRecuperaXml
				Processa({|lEnd| lRet := M486BOLXML(aFact,@aError)} ,STR0146) // Generando Documentos XML
				Processa({|lEnd| lRet := M486XFUNBOL(aFact, @aError,@aTrans,"T",,@lRetSal )},STR0101) //"Transmitiendo Documentos..."
			EndIf
		ElseIf cPaisLoc == "PAR" .AND. lGerarCFD
			If FindFunction("M486XMLPAR")
				Processa({|lEnd| lRet := M486XMLPAR(aFact,@aError)} ,STR0146) // Generando Documentos XML
			EndIf
			Processa({|lEnd| lRet := M486FPAREN(aFact, "T", @aError, @aTrans)},STR0101) //"Transmitiendo Documentos..."
		EndIf
	EndIF

	//Actualización de estatus de documentos transmitidos previamente
	If (cPaisLoc == "COL" .And. Len(aDocAct) > 0)
		Processa({|lEnd| lRet := M486UPDST(aDocAct)},STR0341) //Actualizando estatus de documentos electrónicos transmidos previamente...
	EndIf

	If len(aTrans)>0 .And. !lRecuperaXml .and. !(cPaisLoc $ "PAR|BOL") .And. IIf(cPaisLoc == "PER" .And. cMVPROVFE == "TCI",.F.,.T.) // Actualiza estatus
		If !_lCerRet
			Processa({|lEnd| lRet := M486UPDST(aTrans)},STR0079) // Actualizando información en Protheus
		Else
			Processa({|lEnd| lRet := M486UPDSFE(aTrans)},STR0079) // Actualizando información en Protheus
		EndIf
	EndIF

	CURSORARROW()

	If len(aError) <> len(aTrans)
		cMsgLog := IIf(!lRecuperaXml, STR0052, STR0226) + cCRLF + STR0100	// "Ocurrieron inconvenientes al momento de la transmisión" // "¿Desea visualizar log de Transmisión?"
	Else
		If lRetSal
			cMsgLog := IIf(!lRecuperaXml, STR0055, STR0227) + cCRLF + STR0100	// "Transmisión a TSS exitosa" // "¿Desea visualizar log de Transmisión?"
		EndIf
	EndIf
	If len(aTrans) > 0 .And. LibMetric()	//Valida la fecha de la LIB para utilizacion en Telemetria
		// Metrica de control documentos transmitidos exitosamente.
		cSubRutina := "transmision_electronica-exitosa-" + cPaisLoc + "-" + IIf(lDocSopor,"Doc_Sop",Alltrim(cEspecie)) + cTxtAuto 
		FwCustomMetrics():setSumMetric(cSubRutina, "faturamento-protheus_cantidad-de-documentos-transmitidos-por-pais-por-empresa-por-tipo_total", len(aTrans), /*dDateSend*/, /*nLapTime*/, "MATA486")
	EndIf
	If lRetSal
		If MsgYESNO(cMsgLog)
			M486GENLOG(aError,nTotDoc,len(aTrans),aNoEnv)
		EndIf
	Endif

	If SuperGetMV("MV_PROVFE",,"") == "TSS" .Or. (cPaisLoc == "EQU" .And. SuperGetMV("MV_PROVFE",,"") == "STUPENDO")
		If len(aTrans) > 0
			If MsgYesNo(STR0103) // "¿Desea consultar los documentos Transmitido en el Monitor?"
				M486MONDOC(.T.,aTrans)
				lRet := .T.
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} M486VLDDOC
Obtiene los documentos dentro del rango informado por el usuario, realiza llamada a funciones que
validan los datos del documento, si pasa las validaciones las agrega al array aFact, de lo contrario
genera un registro en aError.
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param cFacIn, character, (Documento inicial)
@param cFacFi, character, (Documento final)
@param cSerie, character, (Serie del documento
@param aFact, array, (Array con lso documentos que pasan todas las validaciones)
@param aError, array, (Array con los documentos que contienen errores)
@param nTotal, numérico, (Total de documentos que serán procesados con y sin errores.)
@param lRecuperaXml, lógica, .T. = proceso de recuperar XML
@return $lRet, ${ .T. Si todo está ok}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486VLDDOC(cFacIn,cFacFi,cSerie,aFact,aError,nTotal,lRecuperaXml)
	Local cQuery		:= ""
	Local nCount		:= 0
	Local nCont			:= 0
	Local cXml			:= ""
	Local lRet			:= .T.
	Local lValCli		:= .F.
	Local lValDet		:= .F.
	Local lValFec		:= .T.
	Local lValSer		:= .T.
	Local lPtoEst		:= .T.
	Local lDocRel		:= .T.
	Local lGRem			:= .T.
	Local aDocRel		:= {}
	Local dFchAux		:= CTOD(" / / ")
	Local lValSta		:= .T.
	Local lLiqCom		:= .F.
	Local cFilSF		:= xFilial("SF2")
	Local cSpaceStat	:= Space(TamSX3("F2_FLFTEX")[01])
	Local cFiltDocs		:= ""
	Local cEspDoc       := AllTrim(cEspecie)
	Local cSerRel       := ""
	Local cDocRel       := ""
	Local cFilSE4       := xFilial("SE4")
	Local lTipoPago     := SE4->(ColumnPos("E4_MPAGSAT")) > 0
	Local aDocSop 		:= {}
	Local cQryGr        := ""
	
	Private cTempF := CriaTrab(Nil, .F.)
	Private lExporta := .F.
	
	If cPaisLoc == "EQU"
		Do Case
			Case cEstatus == "1" //0=No Enviado
				cFiltDocs :=  "IN ('0', '" + cSpaceStat + "') "
			Case cEstatus == "2" //1=Enviado
				cFiltDocs :=  "IN ('1') "
			Case cEstatus == "3" //4=Esperando procesamiento
				cFiltDocs :=  "IN ('4', '2') "
			Case cEstatus == "4" //5=Rechazado
				cFiltDocs :=  "IN ('5', '3') "
			Case cEstatus == "5" //6=Autorizado
				cFiltDocs :=  "IN ('6') "
			Otherwise
				cFiltDocs := "<> '6' "
		EndCase
	EndIf

	If nTipoDoc == 0
		cQuery := "SELECT F1_FORNECE CLIFOR, F1_LOJA TIENDA, F1_DOC DOC, F1_SERIE SERIE, F1_ESPECIE ESPECIE, F1_EMISSAO EMISSAO, F1_FILIAL FILIAL "
		If SF1->(ColumnPos("F1_SERIE2"))
			cQuery += ", F1_SERIE2 SERIE2 "
		EndIf
		If SF1->(ColumnPos("F1_SECSRI"))
			cQuery += ", F1_SECSRI SECSRI "
		EndIf
		If SF1->(ColumnPos("F1_PTOEMIS"))
			cQuery += ", F1_PTOEMIS PTOEMIS "
		EndIf
		If SF1->(ColumnPos("F1_ESTABL"))
			cQuery += ", F1_ESTABL ESTABL "
		EndIf
		If SF1->(ColumnPos("F1_MOTIVO"))
			cQuery += ", F1_MOTIVO MOTIVO "
		EndIf
		If SF1->(ColumnPos("F1_FLFTEX"))
			cQuery += ", F1_FLFTEX STATUS "
		EndIf
		if cPaisLoc =="BOL"
			If SF1->(ColumnPos("F1_TIPNOTA"))
				cQuery += ", F1_TIPNOTA TIPDOC "
			EndIf
		EndIf
		If lTipoPago .And. SF1->(ColumnPos("F1_COND"))
			cQuery += ", F1_COND CONDPAGO "
		EndIf
		if cPaisLoc =="PAR"
			cquery += ", F1_COND COND "
			If SF1->(ColumnPos("F1_UUID"))
				cQuery += ", F1_UUID UUID "
			EndIf
			cQuery+= ", F1_ESPECIE ESPECIE "
		EndIf
		cQuery += "FROM "+RetSqlName("SF1")+" SF1 "
		cQuery += "WHERE F1_SERIE = '"+cSerie+"' AND F1_ESPECIE = '"+IIf(cPaisLoc == "COL" .AND. nTDTras == 6,'NF',cEspecie)+"' AND F1_DOC BETWEEN '"+cFacIn+"' AND '"+cFacFi+"' AND D_E_L_E_T_ = '' "
		cQuery += "AND F1_FLFTEX " + IIf(!lRecuperaXml, iif(cPaisLoc=="BOL", "NOT IN ('6','8','1') ", IIf(cPaisLoc == "EQU", cFiltDocs, IIF((cPaisLoc == "PAR" )," NOT IN ( '8','6','4') "," <> '6' "))), "IN ('1','6') ")
		If cPaisLoc == "COL" 
			If SF1->(ColumnPos("F1_SOPORT")) .AND. nTDTras == 6 //lDocSop
				cQuery += " AND F1_SOPORT = 'S' "
			ElseIf  SF1->(ColumnPos("F1_MARK")) .AND. nTDTras == 8 // NDP Ajuste
				cQuery += " AND F1_MARK = 'S' "
			EndIf	
		EndIf

	Else
		cQuery := "SELECT F2_CLIENTE CLIFOR, F2_LOJA TIENDA, F2_DOC DOC, F2_SERIE SERIE , F2_ESPECIE ESPECIE ,F2_EMISSAO EMISSAO, F2_FILIAL FILIAL"
		If SF2->(ColumnPos("F2_SERREF")) > 0
			cQuery += ", F2_SERREF SERREF "
		EndIf
		If SF2->(ColumnPos("F2_NFREF")) > 0
			cQuery += ", F2_NFREF NFREF "
		EndIf		
		If SF2->(ColumnPos("F2_SERIE2")) > 0
			cQuery += ", F2_SERIE2 SERIE2 "
		EndIf
		If SF2->(ColumnPos("F2_SECSRI")) > 0
			cQuery += ", F2_SECSRI SECSRI "
		EndIf
		If SF2->(ColumnPos("F2_PTOEMIS")) > 0
			cQuery += ", F2_PTOEMIS PTOEMIS "
		EndIf
		If SF2->(ColumnPos("F2_ESTABL")) > 0
			cQuery += ", F2_ESTABL ESTABL "
		EndIf
		If SF2->(ColumnPos("F2_MOTIVO")) > 0
			cQuery += ", F2_MOTIVO MOTIVO "
		EndIf
		If SF2->(ColumnPos("F2_TIPONF")) > 0
			cQuery += ", F2_TIPONF TIPONF "
		EndIf
		If SF2->(ColumnPos("F2_FLFTEX")) > 0
			cQuery += ", F2_FLFTEX STATUS "
		EndIf
		If cPaisLoc == "EQU" .and. SF2->(ColumnPos("F2_TPVENT")) > 0
			cQuery += ", F2_TPVENT LIQCOM "
		EndIf
		if cPaisLoc =="BOL"
			If SF2->(ColumnPos("F2_TPDOC"))
				cQuery += ", F2_TPDOC TIPDOC "
			EndIf
		EndIf
		If lTipoPago .And. SF2->(ColumnPos("F2_COND"))
			cQuery += ", F2_COND CONDPAGO "
		EndIf
		If cPaisLoc == "PAR"
			cquery += ", F2_COND COND, F2_VALBRUT TOTAL "
			If SF2->(ColumnPos("F2_UUID"))
				cQuery += ", F2_UUID UUID "
			EndIf
		EndIf
		//Guías de remisión
		If Iif(cPaisLoc $ "EQU|PAR",cEspDoc $ "RFN|RTS|RCD",cEspDoc == "RFN")
			cQuery += ", R_E_C_N_O_ F2RECNO "
		EndIf
		cQryGr := Iif(cPaisLoc $ "EQU" .And. cEspDoc $ "RFN|RTS|RCD", "F2_ESPECIE IN ('RFN','RTS','RCD')","F2_ESPECIE = '"+cEspecie+"'")
		cQryGr := Iif(cPaisLoc $ "PAR" .And. "RTS" $ cEspDoc, "F2_ESPECIE ='RTS'","F2_ESPECIE = '"+cEspecie+"'")
		cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
		cQuery += "WHERE F2_SERIE = '"+cSerie+ "' AND "+ cQryGr +" AND F2_DOC BETWEEN '"+cFacIn+"' AND '"+cFacFi+"' AND D_E_L_E_T_ = '' "
		cQuery += "AND F2_FLFTEX " + IIf(!lRecuperaXml, iif(cPaisLoc=="BOL", "NOT IN ('6','8','1') ", IIf(cPaisLoc == "EQU", cFiltDocs, IIF((cPaisLoc == "PAR")," NOT IN ( '8','6','4') "," <> '6' "))), "IN ('1','6') ")
		If cPaisLoc == "COL" .AND. SF2->(ColumnPos("F2_MARK")) .AND. nTDTras == 9 // NCP Ajuste
			cQuery += " AND F2_MARK = 'S' "	
		EndIf
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)
	TCSetField(cTempF,"EMISSAO","D")
	count to nCount

	lRet := nCount > 0
	(cTempF)->(dbGoTop())
	While (!(cTempF)->(EOF()))
		nCont++
		IncProc(STR0059) //"Procesando"

		//limpia folio para documentos relacionados					
		cSerRel := ""
		cDocRel := ""

		// Valida datos del Cliente
		If cPaisLoc == "EQU"
			lValCli := M486VLDCE((cTempF)->CLIFOR, (cTempF)->TIENDA,(cTempF)->DOC,(cTempF)->SERIE,AllTrim((cTempF)->ESPECIE),@aError) // Valida los datos del cliente del documento en cuestion
		ElseIf cPaisLoc == "COL" .And. (nTDTras == 6 .OR. nTDTras == 8 .OR. nTDTras == 9)
			aDocSop := M486ClieDS((cTempF)->CLIFOR, (cTempF)->TIENDA)
			lValCli := M486VLDCLI(aDocSop[1], aDocSop[2],(cTempF)->DOC,(cTempF)->SERIE,@aError) // Valida los datos del cliente del documento en cuestion
		Else
			IF (cPaisLoc=="PAR") .AND. (ALLTRIM((cTempF)->ESPECIE)=="RTS")
				lValCli := M486VLDPRO((cTempF)->CLIFOR, (cTempF)->TIENDA,(cTempF)->DOC,(cTempF)->SERIE,'',@aError,ALLTRIM((cTempF)->ESPECIE)) // Valida los datos del cliente del documento en cuestion
			ELSE
				lValCli := M486VLDCLI((cTempF)->CLIFOR, (cTempF)->TIENDA,(cTempF)->DOC,(cTempF)->SERIE,@aError) // Valida los datos del cliente del documento en cuestion
			ENDIF
		EndIf

		If cPaisLoc == "PER"
			// Valida  fecha de emisión no mayor a 7 días anteriores a la fecha de transmisión
			dFchAux := ddatabase - 7
			If !((cTempF)->EMISSAO >= dFchAux .and. (cTempF)->EMISSAO <= ddatabase)
				aAdd(aError, {(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA, STR0088}) // "Fecha de emisión fuera de rango. Debe ser hasta 7 días anteriores al afecha de emisión."
				lValFec := .F.
			EndIf
			If (cTempF)->STATUS == "7" .Or. (cTempF)->STATUS == "8"
				aAdd(aError, {(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA, STR0195}) //"Documento en proceso de comunicado de baja."
				lValSta := .F.
			EndIf
			If cEspDoc == "RFN"
				lGRem := M486VLDRFN(@aError, (cTempF)->F2RECNO)
			EndIf

			//Validaciones de Tipo de Pago
			If lValSta .And. lTipoPago .And. ((cEspDoc == "NF" .And.  Substr((cTempF)->SERIE2,1,1) $ 'F') .Or. cEspDoc == "NCC")
				If !(M486TPPAG(cFilSE4, (cTempF)->CONDPAGO) $ "1|2")					 
					aAdd(aError, {(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA, StrTran(STR0332, '###', Alltrim(FWX3Titulo("E4_MPAGSAT")))}) //"En necesario informar el campo ### (E4_MPAGSAT) en la Condición de Pago 1-Contado o 2-Crédito"
					lValSta := .F.				
				EndIf
			EndIf
		EndIF

		// Se valida que tenga contenido serie 2
		If cPaisLoc $ "PER|COL" .and. Empty((cTempF)->SERIE2)
			aAdd(aError, {(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA, STR0025}) // "Documento sin Serie 2"
			lValSer := .F.
		EndIf
		
		If cPaisLoc == "EQU"
			// Se valida que tenga punto de emisión y establecimiento
			If(Empty((cTempF)->PTOEMIS) .Or. Empty((cTempF)->ESTABL))
				aAdd(aError, {(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA, STR0177}) //"El punto de emisión y punto de establecimiento son requeridos."
				lPtoEst := .F.
			EndIf

			// Se valida que tenga motivo
			If cEspDoc $ "NDC|NCC"
				If cEspDoc == "NDC"
					cSerRel := (cTempF)->SERREF
					cDocRel := (cTempF)->NFREF
				ElseIf cEspDoc == "NCC"
					cSerRel := (cTempF)->SERIE
					cDocRel := (cTempF)->DOC
				EndIf
				If Empty((cTempF)->MOTIVO)
					aAdd(aError, {(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA, STR0178}) //"El motivo del documento es requeriedo."
					lPtoEst := .F.
				EndIf
				//Valida documento relacionado autorizado
				aDocRel := fObtDocRef((cTempF)->FILIAL, cDocRel, cSerRel, (cTempF)->CLIFOR, (cTempF)->TIENDA)
				If Alltrim(aDocRel[6]) <> "6" .Or. Empty(aDocRel[7])
					aAdd(aError, {(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA, STR0183}) //"El documento relacionado no se encuentra autorizado."
					lDocRel := .F.
				EndIf
			EndIf

		EndIf

		//Valida datos DETALLE y TES
		If cPaisLoc == "PER|COL"
			lValDet := M486VLDDET((cTempF)->CLIFOR, (cTempF)->TIENDA,(cTempF)->DOC,(cTempF)->SERIE,@aError)
		ElseIf cPaisLoc == "EQU"
			lValDet := M486VDDEQ()
		ElseIf cPaisLoc == "PAR"
			lValDet := M486VLDPAR()
			If POSICIONE("SE4",1,XFILIAL("SE4") + (cTempF)->COND, "E4_BXTITAV") == "1" .and. AllTrim(cEspecie) == "NF"
				lValDet := M486VLDPAGOS((cTempF)->CLIFOR, (cTempF)->TIENDA,(cTempF)->DOC,(cTempF)->SERIE,@aError,nTipoDoc, (cTempF)->TOTAL)
			EndIf
		Else
			lValDet := .T.
		EndIf

		// Si pasó todas las validaciones se agrega a array Facturas
		lRet := lValCli .and. lValDet .and. lValFec	 .and. lValSer .And. lPtoEst .And. lDocRel .And. lValSta .And. lGRem

		If lRet .And. cPaisLoc == "COL" .And. cEspDoc $ "NF"
			If SF2->(ColumnPos("F2_UUIDREL")) > 0
				//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
				cUUID := Posicione("SF2",1,cFilSF + (cTempF)->DOC + (cTempF)->SERIE + (cTempF)->CLIFOR + (cTempF)->TIENDA,"F2_UUIDREL")
				lRet := M486VLDDR(cUUID,.F.,@aError)
			EndIf
		EndIf
		If lRet
		 	If cPaisLoc == "EQU"
		 		If cEspDoc $ "NF" .And. SF2->(ColumnPos("F2_TPVENT")) > 0
		 			lLiqCom := (cTempF)->LIQCOM == "1"
		 		EndIf

		 		aAdd(aFact,{(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR,(cTempF)->TIENDA,(cTempF)->EMISSAO,(cTempF)->FILIAL,.F.,"",(cTempF)->SECSRI, (cTempF)->SECSRI, lLiqCom})
			Elseif cPaisLoc =="BOL"
		 		aAdd(aFact,{(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR,(cTempF)->TIENDA,(cTempF)->EMISSAO,(cTempF)->FILIAL,.F.,"",(cTempF)->STATUS, (cTempF)->TIPDOC})
			ElseIf cPaisLoc == "PAR"
				aAdd(aFact,{(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR,(cTempF)->TIENDA,(cTempF)->EMISSAO,(cTempF)->FILIAL,.F.,"",(cTempF)->SERIE2, cEspecie ,(cTempF)->UUID})
			Else
		 		aAdd(aFact,{(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR,(cTempF)->TIENDA,(cTempF)->EMISSAO,(cTempF)->FILIAL,.F.,"",(cTempF)->SERIE2})
		 	EndIf
		EndIf

		(cTempF)->(dbSkip())
	EndDo
	nTotal := nCount
	(cTempF)->(dbCloseArea())
Return lRet

/*/{Protheus.doc} fWriteXml
(Función que escribe el archivo xml en una carpeta dada)
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param cTexto, character, (contenido del archivo a escribir)
@param cFile, character, (nombre del archivo a escribir)
@param lAut, boolean, (si T indica que se consulta documento autorizado)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function fWriteXml(cTexto, cFile, lAut, lCBaja, lResDia)
	Local cPath	    := getMV("MV_CFDDOCS")
	Local cPathFile := ""
	Local nHdl
  	Local nRet		:= 0
	Local cRutAdic	:= ""
	Default lCBaja := .F.
	Default lResDia:= .F.

	If lCBaja .And. !_lCerRet
		cRutAdic := "ComunicadoBaja\"
	ElseIf lResDia .Or. (lCBaja .And. _lCerRet)
		cRutAdic := "ResumenDiario\"
	EndIf

	cPathFile := IIf(lAut, &(cPath) + "autorizados\" + cFile, &(cPath) + cRutAdic + cFile)
	Ferase(cPathFile)
	nHdl :=	fCreate(cPathFile,,,.F.)
	If (nHdl >= 0)
		fWrite(nHdl,cTexto)
		fClose(nHdl)
		If cPaisLoc == "PER"
			//Descomprime archivo .zip
			If lAut .and. cMVPROVFE == "RSM" .and. getBuild() >= "7.00.131227A"
				nRet := &('FUnZip(cPathFile, &(cPath) + "autorizados\",)')
			EndIf
		EndIf
	Else
		conout(StrTran(STR0342, '###', Alltrim(cPathFile)) + ":" + Str(Ferror())) //"Error en la creación del archivo ### "
	EndIf
Return

/*/{Protheus.doc} M486MONDOC
Función para visualizar los documentos que han sido transmitidos al TSS
@type function
@author mayra.camargo
@since 07/07/2017
@version 1.0
@param lAut, BOOLEAN, (Si s ejecutado de manera automática)
@param aDocs, array, Array con los documentos a ser monitoreados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486MONDOC(lAut,aDocs)
	Local aArea		:= getArea()
	Local cIdEnt	:= ""

	Local cUrl		:= ""
	Local cTKNEmp   := ''
	Local cTKNPas   := ''
	Local cDocIni	:= ''
	Local cDocFin	:= ''
	Local cDocSer	:= ''
	Local lMonitor  := IIf(cPaisLoc == "EQU" .And. SuperGetMV("MV_PROVFE",,"") == "STUPENDO" .OR. cPaisLoc == "BOL", .T., .F.)
	Local cProvFE   := SuperGetMV("MV_PROVFE",,"")
	Local aObs := {}
	Private aItems	:= {}

	Default lAut	:= .F.
	Default adocs	:= {}

	If cPaisLoc =="PER" .And. (Alltrim(cProvFE) == "TSS" .Or. EMPTY(Alltrim(cProvFE)))
		cUrl := GetNewPar("MV_WSRTSS","")
	ElseIf cPaisLoc =="EQU" .And. Alltrim(cProvFE) == "STUPENDO"
		cUrl := M486GETPAR(2)
	ElseIf cPaisLoc =="COL" .And. Alltrim(cProvFE) == "DFACTURA"
		cUrl    := GetNewPar("MV_WSRTSS","")  //URL de ws
		cTKNEmp := GetNewPar("MV_TKN_EMP","") //Token empresa
		cTKNPas := GetNewPar("MV_TKN_PAS","") //Token password
	EndIf

	// Valida que exista configuración de conexión a TSS
	If Empty(cURL) .And. Alltrim(cProvFE) == "TSS"
		MsgAlert(STR0131) // "No se realizó la Configuración de conexión con TSS. Ejecute opción Configuración"
		Return
	EndIf

	If cPaisLoc == "PER" .And. (Alltrim(cProvFE) == "TSS" .Or. EMPTY(Alltrim(cProvFE)))
		cIdEnt := GetIdEnt()
	ElseIf !cPaisLoc $ "PER|BOL"
		cIdEnt :=  GetNewPar("MV_COMPID","")
	EndIf

	IF !Empty(cIdEnt) .Or. lMonitor
		If !lAut
			If Pergunte(cPergFac, .T.)
				cDocSer 	:= MV_PAR01
				cDocIni 	:= MV_PAR02
				cDocFin 	:= MV_PAR03
				If !_lCerRet
					Processa({|lEnd| aDocs := M486GETINF(cDocSer,cDocIni,cDocFin)}, STR0148) // "Obteniendo Información"
				ElseIf cPaisLoc $ "PER|EQU"
					If cPaisLoc == "EQU"
						cDocIni 	:= MV_PAR01
						cDocFin 	:= MV_PAR02
					EndIf
					aDocs := M486GETCR(cDocSer,cDocIni,cDocFin)
				EndIf
			Else
				Return
			EndIf
		EndIF
		If len(aDocs) > 0
			If cPaisLoc == "BOL"
				// Obtiene datos SIN para los documentos contenidos en aDocs
				Processa({|lEnd| aItems:= M486GETSIN(aDocs,@aObs)},STR0315)	//"Consultando al SIN... aguarde..."
				If len(aItems)>0
					M486MonBo(aItems,aDocs,aObs) // Abre monitor con parámetros dados
				EndIf
			Else
				// Obtiene datos de TSS para los documentos contenidos en aDocs
				Processa({|lEnd| aItems:= M486GETTSS(aDocs,cIdEnt,cURL)}, IIf(cPaisLoc == "EQU", STR0176 + Alltrim(SuperGetMV("MV_PROVFE",,"")), STR0149))	//"Consultando TSS ... aguarde..." //"Consultando con "
				If len(aItems)>0
					M486SHOWMON(aItems,aDocs,aObs) // Abre monitor con parámetros dados
				EndIf
			EndIf
		Else
			MsgAlert(STR0054)//"No hay documentos dentro de los rangos especificados"
		EndIf
	ElseIf cPaisLoc == "PER" .And. !(Alltrim(cProvFE) == "TSS" .Or. EMPTY(Alltrim(cProvFE)))

		If !lAut
			If Pergunte(cPergFac, .T.)
				cDocSer 	:= MV_PAR01
				cDocIni 	:= MV_PAR02
				cDocFin 	:= MV_PAR03
				If !_lCerRet
					Processa({|lEnd| aDocs := M486GETSFX(cDocSer,cDocIni,cDocFin)}, STR0148) //"Obteniendo Información"
				Else
					Processa({|lEnd| aDocs := M486GETCR(cDocSer,cDocIni,cDocFin)}, STR0148) //"Obteniendo Información"
				EndIf
				If len(aDocs) > 0
					If len(aDocs)>0
						M486SHOWMON(aDocs,aDocs) // Abre monitor con parámetros dados
					EndIf
				Else
					MsgAlert(STR0054) //"No hay documentos dentro de los rangos especificados"
				EndIf

			Else
				Return
			EndIf
		EndIF
	ElseIf cPaisLoc == "COL" .And. cMVPROVFE == "DFACTURA"
		If !lAut
			If Pergunte(cPergFac, .T.)
				cDocSer 	:= MV_PAR01
				cDocIni 	:= MV_PAR02
				cDocFin 	:= MV_PAR03
				If !_lCerRet
					Processa({|lEnd| aDocs := M486GETINF(cDocSer,cDocIni,cDocFin)}, STR0148) // "Obteniendo Información"
				EndIf
			Else
				Return
			EndIf
		EndIf
		If len(aDocs) > 0
			// Obtiene datos de TSS para los documentos contenidos en aDocs
			Processa({|lEnd| aItems:= M486EDODOC(aDocs, cUrl, cTKNEmp, cTKNPas, cEspecie)}, STR0176 + Alltrim(SuperGetMV("MV_PROVFE",,""))) //"Consultando con "
			If len(aItems)>0
				M486SHOWMON(aItems,aDocs) // Abre monitor con parámetros dados
			EndIf
		Else
			MsgAlert(STR0054)//"No hay documentos dentro de los rangos especificados"
		EndIf
	EndIf
	RestArea(aArea)
Return

/*/{Protheus.doc} M486SHOWMON
Muestra pantalla gráfica del monitor
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param aItems, array, (Array con los items que serán mostrados en el monitor)
@param aDocs, array, (Array original con los datos de los documentos a consultar)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486SHOWMON(aItems,aDocs,aObs )

	Local oDlg, oList, oButton1, oButton2, oButton3, oButton4
	Local lTSS := SuperGetMV("MV_PROVFE",,"") == "TSS"  .or. Empty(SuperGetMV("MV_PROVFE",,""))
	Local oButton6 := Nil
	default aObs := {}
	DEFINE MSDIALOG oDlg FROM 0,0 TO 400,1000 PIXEL TITLE STR0005 //Monitor

			If cPaisLoc == "COL" .And. cMVPROVFE == "DFACTURA"
				@ 10,10 LISTBOX oList FIELDS;
					HEADER "", STR0060, STR0061, STR0064, STR0302; //Documento //Ambiente //Mensaje //CUFE
				SIZE 480,130 OF oDlg PIXEL
			Else
				@ 10,10 LISTBOX oList FIELDS;
			        HEADER "", STR0060, STR0061, STR0062, IIf(cPaisLoc == "EQU",STR0175,STR0063), STR0064, STR0065; //Documento //Ambiente //Fch. Aut //Hr. Aut //Mensaje //Recomendacion //"Cod. Estado"
				SIZE 480,130 OF oDlg PIXEL
			EndIf
			oList:SetArray(aItems)
			If len(aItems) > 0
				If cPaisLoc == "COL" .And. cMVPROVFE == "DFACTURA"
					oList:bLine := {|| {GetStatus(aItems[oList:nAt,1]),aItems[oList:nAt,2],aItems[oList:nAt,3],aItems[oList:nAt,4],aItems[oList:nAt,5]}}
				Else
					oList:bLine := {|| {GetStatus(aItems[oList:nAt,1]),aItems[oList:nAt,2],aItems[oList:nAt,3],aItems[oList:nAt,4],aItems[oList:nAt,5],aItems[oList:nAt,6],aItems[oList:nAt,7]}}
				EndIf
			EndIf

			If cPaisLoc == "PER"
				oButton0 := TButton():New(170, 230,STR0068,oDlg,{||Leyenda()},30,11,,,,.T.)                                                    //Leyenda
				oButton1 := TButton():New(170, 270,STR0107,oDlg,{||Schema(oList:nAt, oList)},30,11,,,,.T.) 									   //"XML Envio"
				oButton2 := TButton():New(170, 310,IIF(cPaisLoc =="PER",IIF(lTSS,STR0106,"CDR"),STR0145),oDlg,{||Schema(oList:nAt, oList, .t.)},30,11,,,,.T.)  //"XML SUNAT" "XML DIAN"
			EndIf
			If ( !( cPaisLoc == "PER" .And. !lTSS) .Or. (cPaisLoc == "COL" .And. cMVPROVFE == "DFACTURA") )
				oButton4 := TButton():New(170, 350,STR0069,oDlg,{||Refresh(oList,aDocs)},30,11,,,,.T.) 											//Refresh
				oButton3 := TButton():New(170, 390,STR0066,oDlg,{||Processa({|lEnd| ActCertif(aItems)},STR0089),oDlg:End()},30,11,,,,.T.) 		//Ok
			EndIf
			//Errores - COL
			If (cPaisLoc == "COL" .And. cMVPROVFE == "DFACTURA") 
				oButton6 := TButton():New(170, 310,STR0330,oDlg,{||Schema(oList:nAt, oList)},30,11,,,,.T.) 							    //"Errores"
			EndIf
			//Rechazos - EQU
			If (cPaisLoc == "EQU" .And. cMVPROVFE == "STUPENDO") .And. FindFunction("M486RECHEQU")
				oButton6 := TButton():New(170, 310,STR0331,oDlg,{||M486RECHEQU(oList:nAt, oList)},30,11,,,,.T.) 							//"Rechazo"
			EndIf
			oButton5 := TButton():New(170, 430,STR0105,oDlg,{||oDlg:End()},30,11,,,,.T.) 													//"Salir"

	ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} M486GETTSS
  Obtiene información de los documentos de TSS
  @type
  @author mayra.camargo
  @since 29/06/2017
  @version 1.0
  @param aDocs, array, Documentos a Consultar
  @param cIdEnt, character, Entidad de TSS
  @param cURL, character, url de conecxion
  @return aRet, Array con la informaicón que será mostrada en el monitor
  @example
  (examples)
  @see (links_or_references)
  /*/
 Static Function M486GETTSS(aDocs,cIdEnt,cURL)
	Local aRet		:= {}
	Local oWS		:= Nil
	Local nI		:= 0
	Local cXML		:= ""
	Local cErro		:= ""
	Local cWarning	:= ""
	Local cMsg		:= ""
	Local cRecom	:= ""
	Local oRestClient := Nil
	Local oObj		:= Nil
	Local aHeader 	:= {}
	Local cHost		:= ""
	Local oXml		:= Nil
	Local cRespDian	:= ""
	Local cError	:= ""
	Local lWr		:= .F.
	Local nEstado   := 0
	Local nTamDoc 	:= TamSX3("F2_DOC")[1]
	Local cAliasSF 	:= IIf(!Empty(nTDTras), IIf(nTDTras == 3 .Or. (cPaisLoc $ "EQU|COL" .And. nTDTras == 6),"SF1","SF2"), "")
	Local cPreSF    := IIf(!Empty(nTDTras), IIf(nTDTras == 3 .Or. (cPaisLoc $ "EQU|COL" .And. nTDTras == 6),"F1_","F2_"), "")
	Local cClave    := ""
	Local cPtoEmis  := ""
	Local cEstabl   := ""
	Local nSecSri   := 0
	Local cFecAut   := ""
	Local cTipDoc   := ""

	Default aDocs  := {}
	Default cURL   := IIf(cPaisLoc == "EQU", RTRIM(GETMV("MV_WSURL02")), RTRIM(GETMV("MV_WSRTSS")))
	Default cIdEnt := IIf(cPaisLoc == "COL", GetNewPar("MV_COMPID",""), "")

	CURSORWAIT()
	IF cPaisLoc == "PER"
		oWS := WSTSSWSSUNAT():NEW()
		oWs:cUSERTOKEN:= "TOTVS"
		oWs:cIDENT		:= cIdEnt
		oWS:cMODELO 	:= cModelo
		oWS:_URL		:= cURL + "/TSSWSSUNAT.apw"

		For nI:= 1 to len(aDocs)
			oWS:cIdDoc := aDocs[nI,2] +aDocs[nI,3]
			If oWs:ConsultaDoc()
				aAdd(aRet, {oWS:OWSCONSULTADOCRESULT:nStatus,;
							 oWS:OWSCONSULTADOCRESULT:cIdDoc,;
							 IIf(oWS:OWSCONSULTADOCRESULT:nAmbiente==1,STR0036,STR0037),;
							 oWS:OWSCONSULTADOCRESULT:dFechaAut,;
							 oWS:OWSCONSULTADOCRESULT:cHoraAut,;
							 Alltrim(oWS:OWSCONSULTADOCRESULT:cMensaje),;
							 oWS:OWSCONSULTADOCRESULT:cRecomend}) //Produccion //Homologacion
				If oWS:OWSCONSULTADOCRESULT:nStatus == 6
						cXML := oWS:OWSCONSULTADOCRESULT:cXML
						If !Empty(cXML)
							cNameFile := alltrim(Substr((oWS:OWSCONSULTADOCRESULT:cIdDoc),1,3)) + alltrim(substr((oWS:OWSCONSULTADOCRESULT:cIdDoc),4)) + alltrim(cEspecie)
							fWriteXml(cXml,cNameFile + "-ok.xml",.T.)
						EndIf
				EndIF
			Else
				MsgAlert(GetWSCError())
			EndIf

		Next nI
	ElseIf cPaisLoc == "COL"
		cHost := fGetHost(cURL)
		// Aquí va el consumo de la API REST para consulta de documentos
		aAdd(aHeader,"Content-Type: application/json")
		aAdd(aHeader,"Host: " + cHost )

		oRestClient := FWRest():New(cUrl)
		For nI:= 1 to len(aDocs)
			// Posiciobn 6 URI
			oRestClient:setPath("/colombia/v1/emission/invoices/" +aDocs[nI,6] )
			If oRestClient:get(aHeader)
				If FWJsonDeserialize(oRestClient:GetResult(),@oObj)
					If oObj<> Nil
						If oObj:STATUS == "3"	// Error de Esquema
							cRecom := STR0157//"Corregir y reenviar documento."
						ElseIf (oObj:STATUS $ "4|2")
							cRecom := STR0158 //"Espere procesamiento del Documento"
						ElseIf oObj:STATUS=="6"
							cRecom := STR0159 //"Documento Autorizado. Enviar a Receptor"
						ElseIf oObj:Status == "5" // Rechazo DIAN
							cMsg := STR0160 // "Rechazo DIAN - Observaciones"
							cRecom:= STR0163 + STR0157//"Corregir y Reenviar documento."
							If !Empty(oObj:RETDOCUMENT)
								cRespDian :=  DECODE64(oObj:RETDOCUMENT)
								cRespDian:= encodeutf8(cRespDian)
							EndIF
						Endif

						// Se agrega el registro a 	array de monitor
						aAdd(aRet, {Val(oObj:Status),;
							 oObj:ID,;
							 IIf(oObj:AMBIENT==1,STR0036,STR0037),;
							 STOD(STRTRAN(oObj:INPUTDATE,"-","")),;
							 oObj:INPUTHOUR,;
							 cMsg,;
							 cRecom})
						If oObj:Status $ "6|5"
							If oObj:Status == "6"
								cXML := oObj:Document
								lWr := .T.
							Else
								cXML := cRespDian
								lWr := .F.
							EndIf
							If !Empty(cXML)
								cNameFile := alltrim(Substr((oObj:ID),1,3)) + alltrim(substr((oObj:ID),4)) + alltrim(cEspecie)
								fWriteXml(cXml,cNameFile + "-ok.xml",lWr)
							EndIf
						EndIF
					EndIf
				EndIf
			Else
				MsgAlert(oRestClient:GetLastError())
			EndIf
			oObj := nIL
		Next nI
		oRestClient:= Nil
	ElseIf cPaisLoc == "EQU"
		If SuperGetMV("MV_PROVFE",,"") == "STUPENDO"
			If Alltrim(cEspecie) == "NF" //Factura de Venta
				cTipDoc := "01"
			ElseIf Alltrim(cEspecie) == "NCC" //Nota de Crédito
				cTipDoc	:= "04"
			ElseIf Alltrim(cEspecie) == "NDC" //Nota de Débito
				cTipDoc := "05"
			ElseIf Alltrim(cEspecie) == "RET" //Nota de Débito
				cTipDoc := "07"
			ElseIf Alltrim(cEspecie) $ "RFN|RTS|RCD"
				cTipDoc := "06"
			EndIf

			For nI:= 1 to len(aDocs)
				cClave := aDocs[nI,1] + aDocs[nI,3] + aDocs[nI,2] + aDocs[nI,4] + aDocs[nI,5]
				If Alltrim(cEspecie) == "NF" .And. aDocs[nI,7]
					cTipDoc := "03"
				ElseIf Alltrim(cEspecie) == "NF"
					cTipDoc := "01"
				EndIf
				If !_lCerRet
					dbSelectArea(cAliasSF)
					//F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
					//F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
					(cAliasSF)->(dbSetOrder(1))
					If (cAliasSF)->(dbSeek(cClave))
						cPtoEmis := (cAliasSF)->&(cPreSF + "PTOEMIS")
						cEstabl  := (cAliasSF)->&(cPreSF + "ESTABL")
						nSecSri  := (cAliasSF)->&(cPreSF + "SECSRI")
					EndIf
				Else
					cEstabl  := Substr(Alltrim(SM0->M0_DSCCNA),1,3)
					cPtoEmis := Substr(Alltrim(SM0->M0_DSCCNA),4,3)
					nSecSri  := Alltrim(Substr(aDocs[nI,3],(TamSX3("FE_NROCERT")[1]-8),9))
				EndIf

				If Alltrim(cEspecie) == "RET"
					cNomDocXML := "RET" + Alltrim(SM0->M0_DSCCNA) + aDocs[nI,3] + ".XML"
				Else
					cNomDocXML := M486NOMARC(aDocs[nI,1], aDocs[nI,3], aDocs[nI,2], aDocs[nI,4], aDocs[nI,5]) + ".XML"
				EndIf

				oWS := WSConsultaDocumentoSoap():NEW()
				oWS:cRucEmpresa := Alltrim(SM0->M0_CGC)
				oWS:cTipoDocumento   := cTipDoc
				oWS:cEstablecimiento := cEstabl
				oWS:cPtoEmision      := cPtoEmis
				oWS:cSecuencial      := Alltrim(Substr(aDocs[nI,3],(nTamDoc-8),9))
				oWS:cNombreArchivo   := cNomDocXML
				oWS:_URL		     := cURL

				If oWS:wsConsultaDocumento()
					cMsj := oWS:cDetalle
					If oWS:cEstado == "1"          //1.Iniciado
						nEstado := 1
						If Empty(cMsj)
							cMsj := STR0318 //"En proceso"
						EndIf
					ElseIf oWS:cEstado $ "3|8|9|"  //3.Recibido 8.Sin respuesta del SRI 9.En procesamiento
						nEstado := 4
						If Empty(cMsj)
							cMsj := STR0073 //"Esperando procesamiento"
						EndIf
					ElseIf oWS:cEstado $ "2|4|0|-2|-1|"  //2.Rechazado 4.Negado
						nEstado := 5
						If Empty(cMsj)
							cMsj := STR0074 //"Documento rechazado"
						EndIf
					ElseIf oWS:cEstado == "5"    //Autorizado
						If oWS:wsConsultaDocumentoFechaAut()
							cFecAut := Ctod(Substr(oWS:cFechaAutorizacion,1,10))
							nEstado := 6
							If Empty(cMsj)
								cMsj := STR0075 //"Documento autorizado"
							EndIf
						Else
							cMsj := GetWSCError()
						EndIf
					EndIf

					aAdd(aRet, {nEstado,;
					Alltrim(aDocs[nI,2]) + "-" + aDocs[nI,3],;
					IIf(SuperGetMV("MV_CFDIAMB",.F.,"1") == "2", "Producción", "Pruebas"),;
					cFecAut,;
					oWS:cNumAutorizacion,;
					cMsj,;
					"", ;
					aDocs[nI,3], ; //Documento
					aDocs[nI,2], ; //Serie
					aDocs[nI,4], ; //Cliente
					aDocs[nI,5], ; //Loja
					oWS:cEstado})  //Status Stupendo
				Else
					cMsj := GetWSCError()
					MsgAlert(cMsj,STR0015) //"Atención"
				EndIf
				oWS := Nil
			Next nI
		EndIf
	EndIf
	CURSORARROW()
Return aRet

/*/{Protheus.doc} M486GETINF
Consulta información  a TSS sobre los documentos contenidos en el rango dado
@type function
@author mayra.camargo
@since 29/06/2017
@version 1.0
@param cSerie, character, Serie de los documentos
@param cFacIni, character, Número inicial
@param cFacFin, character, número final
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static function M486GETINF(cSerie,cFacIn,cFacFi)
	Local aRet     := {}
	Local aArea    := getArea()
	Local cTempF   := CriaTrab(Nil, .F.)
	Local lExisLQ  := SF2->(ColumnPos("F2_TPVENT")) > 0
	Local lLiqCom  := .F.
	Local cQryGr   := ""

	If nTipoDoc == 0
		cQuery := "SELECT F1_FILIAL FILIAL,F1_FORNECE CLIFOR, F1_LOJA TIENDA, F1_DOC DOC, F1_SERIE SERIE "
		If SF1->(ColumnPos("F1_SERIE2"))
			cQuery += ", F1_SERIE2 SERIE2 "
		EndIf
		If cPaisLoc == "COL"
			cQuery += ", F1_FLFTEX STATUS, F1_UUID CUFE "
		EndIf
		If cPaisLoc == "PER"
			If SF1->(ColumnPos("F1_IDCBAJA"))
				cQuery += ", F1_IDCBAJA IDCBAJA "
			EndIf
		EndIf
		If cPaisLoc == "BOL"
			If SF1->(ColumnPos("F1_UUID"))
				cQuery += ", F1_FLFTEX STATUS, F1_UUID UUID, F1_UUIDC UUIDC, F1_CODDOC CODDOC, F1_TIPNOTA TIPDOC, F1_NUMAUT NUMAUT "
			EndIf
			If SF1->(ColumnPos("F1_CODAUT"))
				cQuery += ", F1_CODAUT CODMOTC "
			EndIf
		EndIf
		cQuery += "FROM "+RetSqlName("SF1")+" SF1 "
		cQuery += "WHERE F1_SERIE = '"+cSerie+"' AND F1_ESPECIE = '"+IIf(cPaisLoc == "COL" .AND. nTDTras == 6,'NF',cEspecie)+"' AND F1_DOC BETWEEN '"+cFacIn+"' AND '"+cFacFi+"' AND D_E_L_E_T_ = '' "
		If cPaisLoc == "COL"  
			If nTDTras == 6 .AND. SF1->(ColumnPos("F1_SOPORT"))//lDocSop
				cQuery += "AND F1_SOPORT = 'S' "
			ElseIf nTDTras == 8 .AND. SF1->(ColumnPos("F1_MARK"))// NDP Ajuste
				cQuery += "AND F1_MARK = 'S' "
			EndIf
		EndIf
		If cPaisLoc == "BOL"
			cQuery += "AND F1_FLFTEX IN('1','4','5','7') " // 1=Recepción procesada, 4= Recepcion Pendiente, 5=Recepción observada, 7=Anulación pendiente confirmación
			cQuery += "AND F1_UUID <> '' AND (F1_CODDOC <>'' OR F1_NUMAUT <>'') "
		Else
			If !(cPaisLoc == "PER")
				cQuery += "AND F1_FLFTEX <> ' ' "
			EndIf
		Endif
		If cPaisLoc == "PER"
			If SF1->(ColumnPos("F1_IDCBAJA"))
				cQuery += "AND F1_IDCBAJA = ' ' "
			EndIf
		EndIf
	Else
		cQuery := "SELECT F2_FILIAL FILIAL, F2_CLIENTE CLIFOR, F2_LOJA TIENDA, F2_DOC DOC, F2_SERIE SERIE "
		If SF2->(ColumnPos("F2_SERIE2"))
			cQuery += ", F2_SERIE2 SERIE2 "
		EndIf
		If cPaisLoc == "COL"
			cQuery += ", F2_FLFTEX STATUS, F2_UUID CUFE "
		EndIf
		If cPaisLoc == "PER"
			If SF1->(ColumnPos("F2_IDCBAJA"))
				cQuery += ", F2_IDCBAJA IDCBAJA "
			EndIf
		EndIf
		If cPaisLoc == "EQU"
			If lExisLQ
				cQuery += ", F2_TPVENT LIQCOMP "
			EndIf
		EndIf
		If cPaisLoc == "BOL"
			If SF2->(ColumnPos("F2_UUID"))
				cQuery += ", F2_FLFTEX STATUS, F2_UUID UUID, F2_UUIDC UUIDC, F2_CODDOC CODDOC, F2_TPDOC TIPDOC, F2_NUMAUT NUMAUT"
			EndIf
			If SF2->(ColumnPos("F2_CODAUT"))
				cQuery += ", F2_CODAUT CODMOTC "
			EndIf

		EndIf
		cQryGr := Iif(cPaisLoc $ "EQU" .And. cEspecie $ "RFN|RTS|RCD", "F2_ESPECIE IN ('RFN','RTS','RCD')","F2_ESPECIE = '"+cEspecie+"'")
		cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
		cQuery += "WHERE F2_SERIE = '"+cSerie+"' AND "+cQryGr+" AND F2_DOC BETWEEN '"+cFacIn+"' AND '"+cFacFi+"' AND D_E_L_E_T_ = '' "
		If cPaisLoc == "BOL"
			cQuery += "AND F2_FLFTEX IN('1','4','5','7') " // 1=Recepción procesada, 4= Recepcion Pendiente,5=Recepción observada, 7=Anulación pendiente confirmación
			cQuery += "AND F2_UUID <> '' AND (F2_CODDOC <>'' OR F2_NUMAUT <> '') "
		Else
			If !(cPaisLoc == "PER")
				cQuery += "AND F2_FLFTEX <> ' ' "
			EndIf
		Endif

		If cPaisLoc == "PER"
			If SF2->(ColumnPos("F2_IDCBAJA"))
				cQuery += "AND F2_IDCBAJA = ' ' "
			EndIf
		EndIf
		If cPaisLoc == "COL" .AND. SF2->(ColumnPos("F2_MARK")) .AND. nTDTras == 9 // NCP Ajuste
			cQuery += "AND F2_MARK = 'S' "
		EndIf
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)
	count to nCount

	(cTempF)->(dbGoTop())
	While (!(cTempF)->(EOF()))
		If cPaisLoc $ "PER"
			aAdd(aRet, {(cTempF)->FILIAL,(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA})
		ElseIf cPaisLoc $ "EQU"
			If Alltrim(cEspecie) == "NF" 
				If (cTempF)->LIQCOMP == "1"
					lLiqCom  := .T.
				EndIf
			EndIf
			aAdd(aRet, {(cTempF)->FILIAL,(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA,,IIf(lExisLQ .And. lLiqCom,.T.,.F.)})
		ElseIf cPaisLoc == "COL"
			aAdd(aRet, {(cTempF)->FILIAL,(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA,(cTempF)->SERIE2,(cTempF)->STATUS, (cTempF)->CUFE})
		ElseIf cPaisLoc == "BOL"
			aAdd(aRet, {(cTempF)->FILIAL,(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA, (cTempF)->UUID,(cTempF)->STATUS,IIF(EMPTY((cTempF)->UUIDC), "000000",(cTempF)->UUIDC ), IIF(EMPTY((cTempF)->CODDOC), IIF(EMPTY((cTempF)->NUMAUT), "000000",(cTempF)->NUMAUT),(cTempF)->CODDOC),  IIF(EMPTY((cTempF)->CODMOTC), "000000",(cTempF)->CODMOTC), (cTempF)->TIPDOC  })
		EndIf
		(cTempF)->(dbSkip())
	EndDo
	(cTempF)->(dbcloseArea())

	RestArea(aArea)
Return aRet

/*/{Protheus.doc} M486VisNFE
Función para visualizar las facturas/notas de credito/debito/Boletas de Venta
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486VisNFE()
	Local nTpDocC  := 0
	Private aCfgNF := {}
	Private lDocSp := .F.

	If !_lCerRet
		If nTDTras == 3
			nTipo := 4
		 	aCfgNF := MontaCfgNf(4,{.T.,.f.,.f.,.f.,.f.},.T.)
			LocxDlgNF(aCfgNF,2)
		ElseIf nTDTras == 6
			nTipo := 10 //Doc. Soporte
			lDocSp := .T. 
			aCfgNF := MontaCfgNf(10,{.T.,.f.,.f.,.f.,.f.},.T.)
			LocxDlgNF(aCfgNF,2)
		ElseIf nTDTras == 8
			nTipo := 23 //NDP Ajuste
			lDocSp := .T. 
			aCfgNF := MontaCfgNf(23,{.T.,.f.,.f.,.f.,.f.},.T.)
			LocxDlgNF(aCfgNF,2)
		ElseIf nTDTras == 9
			nTipo := 22  //NCP Ajuste
			lDocSp := .T. 
			aCfgNF := MontaCfgNf(22,{.T.,.f.,.f.,.f.,.f.},.T.)
			LocxDlgNF(aCfgNF,2)
		Else
		 	nTipo := Iif(SF2->F2_TIPO=="N",1,2)
		 	aCfgNF := MontaCfgNf(Iif(SF2->F2_TIPO=="N",1,2),{.T.,.f.,.f.,.f.,.f.},.T.)
		 	LocxDlgNF(aCfgNF,2)
		EndIf
	Else
		If Alltrim((cAliasB)->FE_ESPECIE) $ "NF|NDP"
			dbSelectArea("SF1")
			SF1->(dbSetOrder(1)) //F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
			If SF1->(MsSeek(xFilial("SF1")+(cAliasB)->FE_NFISCAL+(cAliasB)->FE_SERIE+(cAliasB)->FE_FORNECE+(cAliasB)->FE_LOJA))
				nTpDocC := IIf(Alltrim((cAliasB)->FE_ESPECIE) == "NF",10,9)
				aCfgNF := MontaCfgNf(nTpDocC,{.T.,.f.,.f.,.f.,.f.},.T.)
			EndIf
		ElseIf Alltrim((cAliasB)->FE_ESPECIE) == "NCP"
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1)) ////F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
			If SF2->(MsSeek(xFilial("SF2")+(cAliasB)->FE_NFISCAL+(cAliasB)->FE_SERIE+(cAliasB)->FE_FORNECE+(cAliasB)->FE_LOJA))
				aCfgNF := MontaCfgNf(7,{.T.,.f.,.f.,.f.,.f.},.T.)
			EndIf
		EndIf
		
		If Len(aCfgNF) > 0
			LocxDlgNF(aCfgNF,2)
		Else
			MsgAlert(STR0328, STR0015) //"No se puede visualizar el documento, no se cargó la configuración para desplegar la pantalla" //"Atención"
		EndIf
	EndIf

	bFiltraBrw := {|| FilBrowse(cAliasB,@aIndArqE,@cFiltro) }
	Eval(bFiltraBrw)
Return

/*/{Protheus.doc} M486ACTMNL
Funcion para visualizar los documentos que han sido retornados por la SUNAT al TSS y que fueron correctamente
aprobados
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486ACTMNL()
	Local lCont := MsgYesNo(STR0070,STR0015) //"Este proceso actualiza los certificados de los documentos autorizados, ¿Continuar?" //"Atención"

	If lCont
		Processa({|lEnd| ActCertif()})
	EndIf
Return

/*/{Protheus.doc} ActCertif
Función para actualizar información a protheus de los documentos aprobados por la sunat
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param aDocs, array, (Array con información de los documentos obtenida de TSS)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ActCertif(aDocs, lMsg)
	Local aArea := getArea()
	Local oWs
	Local oXml
	Local nX        := 0
	Local nY        := 0
	Local cErro 	:= ""
	Local cXml 	    := ""
	Local cNumaut	:= IIF(!_lCerRet,IIF(nTDTras!=3,"F2_NUMAUT","F1_NUMAUT"), "FE_NUMAUT")
	Local cSecSRI   := IIF(!_lCerRet,IIF(nTDTras!=3, "F2_SECSRI", "F1_SECSRI"), "")
	Local cFecaut	:= IIF(!_lCerRet,IIF(nTDTras!=3,"F2_FECAUT","F1_FECAUT"), "FE_FECAUT")
	Local cFlftex	:= IIF(!_lCerRet,IIF(nTDTras!=3,"F2_FLFTEX","F1_FLFTEX"), "FE_STATUS")
	Local cUUID	    := IIF(!_lCerRet,IIF(nTDTras!=3,"F2_UUID","F1_UUID"), "FE_UUID")
	Local cAlia 	:= IIF(!_lCerRet,IIF(nTDTras!=3,"SF2","SF1"), "SFE")
	Local cFil  	:= xFilial(cAlia)
	Local lTSS      := SuperGetMV("MV_PROVFE",,"") == "TSS" .Or. Empty(SuperGetMV("MV_PROVFE",,""))
	Local cIdEnt 	:= IIF(cPaisLoc == "PER" .And. lTSS,GetIdEnt(),"")
	Local lAut 	    := .F.
	Local cNameFile := ""
	Local cPref 	:= IIF(cAlia == "SF1","F1","F2")
	Local nPos		:= 0
	Local aRet 		:= {}
	Local nTamDoc	:= TamSX3(cPref + "_DOC")[1]
	Local nTamSer	:= TamSX3(cPref + "_SERIE")[1]
	Local cClave	:= ""
	Default lMsg 	:= .T.

	ProcRegua(len(aDocs))
	For nX := 1 to len(aDocs)
		IncProc()
		If !_lCerRet
			If cPaisLoc == "PER"
				cClave := cFil+ Substr(aDocs[nX,2],nTamSer + 1, nTamDoc) + Substr(aDocs[nX,2],1, nTamSer)
			ElseIf cPaisLoc == "COL"
				cClave := cFil + aDocs[nX,7] + aDocs[nX,6]
			ElseIf cPaisLoc == "EQU"
				cClave := cFil + aDocs[nX,8] + aDocs[nX,9] + aDocs[nX,10] + aDocs[nX,11]
			EndIF

			dbSelectArea(cAlia)
			//F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
			//F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
			(cAlia)->(dbSetOrder(1))

			If (cAlia)->(dbSeek(cClave))
				If (cAlia)->&(cFlftex) <> "6" //Si el registro fue autorizado previamente ya no se actualiza status
					RecLock(cAlia,.F.)
					(cAlia)->&(cFlftex) := Alltrim(Str(aDocs[nX,1])) //STATUS

					If cPaisLoc == "COL" .And. cMVPROVFE == "DFACTURA" .And. !Empty(aDocs[nX,5])
						(cAlia)->&(cUUID) := Alltrim(aDocs[nX,5]) //CUFE
					ElseIf !Empty(aDocs[nX,4])
						(cAlia)->&(cFecaut) := aDocs[nX,4]
					EndIf

					If cPaisLoc == "EQU"
						(cAlia)->&(cNumaut) := aDocs[nX,5]
						If !Empty(cSecSRI) .And. aDocs[nX,12] $ "-1|0|4"
							(cAlia)->&(cSecSRI) += 1
						EndIf
					EndIf
					(cAlia)->(MsUnlock())
				EndIF
			EndIf
		Else
			M486SFE(Substr(AllTrim(aDocs[nX,2]),(Len(Alltrim(aDocs[nX,2])) + 1) - TamSX3("FE_NROCERT")[1],TamSX3("FE_NROCERT")[1]),STR(aDocs[nX,1],1),aDocs[nX,4],,aDocs[nX,1] == 6)
		EndIF
	Next nX
	If lMsg
		MsgInfo(STR0090, STR0015) // "Proceso finalizado" "Atención."
	EndIf
	RestArea(aArea)
Return

/*/{Protheus.doc} M486SFE
ACTUALIZA REGISTROS DE SFE al ser transmitidos o al consultar.
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param cNcert, character, (Número de Certificado)
@param cStatuS, character, (Estatus )
@param cFecAut, character, (Fecha de Autorización)
@param cNumA, character, (Número de Autorización)
@param lAut, ${param_type}, (True si el documento fue autorizado.)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486SFE(cNcert,cStatuS,cFecAut,cNumA,lAut)
	Local aArea         := getArea()
	Local lRet          := .F.
	Local cItem         :=  "1"
	Local cClave        := ""

	DEFAULT cNCert 	    := ""
	DEFAULT cStatus 	:= "0"
	DEFAULT CFecAut 	:= " / / "
	DEFAULT cNumA	    := ""
	DEFAULT lAut        := .F.

	dbSelectArea("SFE")
	SFE->(dbSetOrder(1)) //FE_FILIAL + FE_NROCERT + STR(FE_ITEM,3)

	If cPaisLoc == "EQU"
		cClave := xFilial("SFE") + cNCert
	Else
		cClave := xFilial("SFE") + cNCert + cItem
	EndIf

	If SFE->(dbSeek(cClave))
		While SFE->(!EOF()) .AND. SFE->(FE_FILIAL+FE_NROCERT) == xFilial("SFE") + cNCert
			If SFE->FE_STATUS <> "6"
				// Actualizar SFE
				RecLock("SFE",.F.)
					If lAut
						SFE->FE_FECAUT:= cFecAut
					EndIf
					SFE->FE_STATUS := cStatus
				SFE->(MsUnlock())
			EndIF
			lRet := .T.
			SFE->(dbSkip())
		EndDo
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} Leyenda
Genera ventana con leyenda y significado de los estatus
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Leyenda()

	BrwLegenda(OemToAnsi(STR0071),OemToAnsi(STR0068),{;//"Transmision Electrónica de Documentos" //Leyenda
		            {"BR_AZUL",OemToAnsi(STR0072)},;//"Recibido"
		            {"BR_AMARELO",OemToAnsi(STR0073)},;//"Esperando procesamiento"
		            {"BR_VERMELHO",OemToAnsi(STR0074)},;//"Documento rechazado"
		            {"BR_VERDE",OemToAnsi(STR0075)};//"Documento autorizado"
		            })
Return

/*/{Protheus.doc} Leyenda
Genera ventana con leyenda y significado de los estatus
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function LeyendaCB()

	BrwLegenda(OemToAnsi(STR0071),OemToAnsi(STR0198),{;  //"Comunicado de baja" //Leyenda
		            {"BR_VERMELHO",OemToAnsi(STR0219)},; //"No permite comunicado baja"
		            {"BR_VERDE",OemToAnsi(STR0220)};    //"Disponible p/comunicado baja"
		            })

Return

/*/{Protheus.doc} M486LEYEND
Exhibe los estatus del browse princiupal
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486LEYEND()
	Local aColors := {}

	aColors := {{"BR_CINZA",OemToAnsi(STR0077)},; //"No Transmitida"
        {"BR_AZUL",OemToAnsi(STR0072)},;		  //"Recibido"
        {"BR_AMARELO",OemToAnsi(STR0073)},;		  //"Esperando procesamiento"
        {"BR_VERMELHO",OemToAnsi(STR0074)},;	  //"Documento rechazado"
        {"BR_VERDE",OemToAnsi(STR0075)}}		  //"Documento autorizado"

    If cPaisLoc == "BOL"
    	aAdd(aColors, {"BR_PINK",OemToAnsi(STR0321)}) //"Anulación pendiente"
    	aAdd(aColors, {"BR_LARANJA",OemToAnsi(STR0322)}) //"Anulación confirmada"
    	aAdd(aColors, {"BR_PRETO",OemToAnsi(STR0323)}) //"Anulación rechazada"
    EndIf
    If cPaisLoc == "PER"
		If _lCerRet
			aAdd(aColors, {"BR_PINK",OemToAnsi(STR0374)}) //"Esperando procesamiento - Res. Diario de Reversión"
			aAdd(aColors, {"BR_LARANJA",OemToAnsi(STR0375)}) //"Documento autorizado - Res. Diario de Reversión"		
		Else
			aAdd(aColors, {"BR_PINK",OemToAnsi(STR0303)}) //"Esperando procesamiento - comunicado de baja"
			aAdd(aColors, {"BR_LARANJA",OemToAnsi(STR0304)}) //"Documento autorizado - comunicado de baja"
		EndIf
    EndIf

	BrwLegenda(OemToAnsi(STR0071), OemToAnsi(STR0068), aColors)//"Transmision Electrónica de Documentos" //"Leyenda"
Return

/*/{Protheus.doc} Refresh
Refresca datos en pantalla del monitor
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param oList, objeto, (Objeto del listbox )
@param aDocs, array, (array original de los documentos consultados.)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Refresh(oList,aDocs)
	Local aItems := {}
	Local cIdEnt := IIF(cPaisLoc == "PER",GetIdEnt(),GetNewPar("MV_COMPID","") )
	Local cURL   := ""
	Local cTKNEmp := ""
	Local cTKNPas := ""

	If cPaisLoc == "COL" .And. cMVPROVFE == "DFACTURA"
		cURL    := GetNewPar("MV_WSRTSS","")  //URL de ws
		cTKNEmp := GetNewPar("MV_TKN_EMP","") //Token empresa
		cTKNPas := GetNewPar("MV_TKN_PAS","") //Token password

		Processa({|lEnd| aItems:= M486EDODOC(aDocs, cUrl, cTKNEmp, cTKNPas)}, STR0176 + Alltrim(SuperGetMV("MV_PROVFE",,""))) //"Consultando con "

		oList:SetArray(aItems)
		oList:bLine := {|| {GetStatus(aItems[oList:nAt,1]),aItems[oList:nAt,2],aItems[oList:nAt,3],aItems[oList:nAt,4],aItems[oList:nAt,5]}}
	Else
		If cPaisLoc =="PER"
			cURL := RTRIM(GETMV("MV_WSRTSS"))
		ElseIf cPaisLoc =="EQU" .And. Alltrim(cMVPROVFE) == "STUPENDO"
			cURL := M486GETPAR(2)
		EndIf

	If cPaisLoc != "BOL"
		Processa({|lEnd| aItems:= M486GETTSS(aDocs,cIdEnt,cURL)}, IIf(cPaisLoc == "EQU", STR0176 + SuperGetMV("MV_PROVFE",,""),STR0149))	//"Consultando TSS ... aguarde..."
	EndIf

		oList:SetArray(aItems)
		oList:bLine := {|| {GetStatus(aItems[oList:nAt,1]),aItems[oList:nAt,2],aItems[oList:nAt,3],aItems[oList:nAt,4],aItems[oList:nAt,5],aItems[oList:nAt,6],aItems[oList:nAt,7]}}
	EndIf
	oList:Refresh()
Return

/*/{Protheus.doc} GetStatus
Obtiene el icono del status de los documentos mostrados en la opción monitor
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param nStatus, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GetStatus(nStatus)
	Local oStatus
	If nStatus == 1
		oStatus := LoadBitmap(GetResources(), "BR_AZUL")
	ElseIf nStatus == 4 .or. nStatus == 2
		oStatus := LoadBitmap(GetResources(), "BR_AMARELO")
	ElseIf nStatus == 5 .or. nStatus == 3
		oStatus := LoadBitmap(GetResources(), "BR_VERMELHO")
	ElseIf nStatus == 6
		oStatus := LoadBitmap(GetResources(), "BR_VERDE")
	ElseIf cPaisLoc == "BOL" .and. nStatus == 9
		oStatus := LoadBitmap(GetResources(), "BR_PRETO")
	ElseIf cPaisLoc == "BOL" .and. nStatus == 8
		oStatus := LoadBitmap(GetResources(), "BR_LARANJA")
	EndIf
Return oStatus

/*/{Protheus.doc} Schema
Muestra el xml retornado por Signature para las facturas autorizadas
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param nLin, numérico, (Línea del listbox en el que se visualizará el XML)
@param oList, objeto, (Objeto con los items del listbox
@param lAut, boolean, Indica si el documento consultado será autorizado o no
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Schema(nLin, oList, lAut)

	Local cPath		:= (getMV("MV_CFDDOCS"))
	Local cSchema	:= ""
	Local cFile		:= ""
	lOCAL cTit		:= ""
	Local cPref		:= IIF( Alltrim(cEspecie) == "NF" , "f" , IIF( Alltrim(cEspecie) == "NCC" , "c" , IIF(Alltrim(cEspecie) == "NDC", "d" , "f" ) ) )
	Local cFact		:= ""
	Local oXml		:= Nil
	Local cError	:= ""
	Local cWarning	:= ""
	Local lTSS	    := SuperGetMV("MV_PROVFE",,"") == "TSS" .Or. Empty(SuperGetMV("MV_PROVFE",,""))
	Local cMod	    := "01"
	Local nTamDoc	:= TamSX3("F2_DOC")[1]
	Local aDoc      := {}
	Local cFactHex  := ""
	Local nX        := 0
	Local cCtrl     := (chr(13)+chr(10))

	Default lAut := .F.

	CURSORWAIT()
	If oList:aArray[nLin,1] == 6 .and. lAut
		If lTSS	.Or. cPaisLoc <> "PER"
			cFile += "autorizados\" + alltrim(Substr((oList:aArray[nLin,2]),1,3)) + alltrim(substr((oList:aArray[nLin,2]),4)) + alltrim(cEspecie)+"-ok.xml"
			cTit := STR0104 //"XML Autorizado"
		Else
			cMod := getModelo(cModelo)
			If !_lCerRet
				cFile := "autorizados\R-" + Alltrim(SM0->M0_CGC)+ "-" + cMod+ "-" + alltrim(Substr(oList:aArray[nLin,2],len(oList:aArray[nLin,2])-3)) + "-"+ strZero(val(substr(oList:aArray[nLin,2],4,nTamDoc)),8) +".xml"
			Else
				cFile := "autorizados\R-" + Alltrim(SM0->M0_CGC)+ "-" + cMod+ "-" + alltrim(Substr(oList:aArray[nLin,2],1,4)) + "-"+ strZero(val(substr(oList:aArray[nLin,2],5)),8) +".xml"
			EndIf
			cTit := STR0233 //"CDR"
		EndIf
	ElseIf cPaisLoc == "COL" .and. cMVPROVFE == "DFACTURA"
			If oList:aArray[nLin,1] == 5
				aDoc := StrTokArr(oList:aArray[nLin,2], "-")
			    cFactHex := M486XHEX(ALLTRIM( substr( aDoc[2] , 4 , Len(aDoc[2]) - 3 ) ),10)
			    cFile := Lower('face') + '_' + cPref + PADR( Alltrim(SM0->M0_CGC) , 10 , "0" ) + cFactHex + '.xml.out'
				oXML := XmlParserFile( &cPath + "\"+ cFile, "_", @cError, @cWarning )
				If oXML <> Nil
					cSchema := Alltrim(oXML:_RESPONSE:_STATUS:TEXT) + "-" + Alltrim(oXML:_RESPONSE:_ERROR:TEXT) + cCtrl
					If XmlChildEx(oXML:_RESPONSE, "_MESSAGE") <> Nil
						If ValType(oXML:_RESPONSE:_MESSAGE:_DESCRIPTION) == "A"
							For nX := 1 To Len(oXML:_RESPONSE:_MESSAGE:_DESCRIPTION)
								cSchema += oXML:_RESPONSE:_MESSAGE:_DESCRIPTION[nX]:TEXT + cCtrl
							Next nX
						Else
							cSchema += oXML:_RESPONSE:_MESSAGE:_DESCRIPTION:TEXT + cCtrl
						EndIf
					EndIf
				Else
					MsgAlert(STR0305 + &cPath) //"No existe archivo .out en la carpeta "
					CursorArrow()
					Return
				EndIf
				cTit := STR0162 //"Observaciones"
			Else
				MsgAlert(STR0306) //"Opción válida solo para documentos rechazados."
				CursorArrow()
				Return
			EndIf
	ElseIf !lAut
		If cPaisLoc == "PER" .And. !lTSS
			cMod := getModelo(cModelo)
			If !_lCerRet
				cFile :=  Alltrim(SM0->M0_CGC)+ "-" + cMod+ "-" + alltrim(Substr(oList:aArray[nLin,2],len(oList:aArray[nLin,2])-3)) + "-"+ strZero(val(substr(oList:aArray[nLin,2],4,nTamDoc)),8) +".xml"
			Else
				cFile :=  Alltrim(SM0->M0_CGC)+ "-" + cMod+ "-" + alltrim(Substr(oList:aArray[nLin,2],1,4)) + "-"+ strZero(val(substr(oList:aArray[nLin,2],5)),8) +".xml"
			EndIf
		Else
			cFact := Lower(PADR(ALLTRIM(substr(oList:aArray[nLin,2], len(xFilial("SF2"))+8 , TamSX3("F2_DOC")[1] )) , 10 , "0" ))
			cFile := Lower('face') + '_' + cPref + PADR( Alltrim(SM0->M0_CGC) , 10 , "0" ) + cFact + '.xml'
		EndIF
		cTit := STR0076 //"XML Enviado a"
	Else
		If cPaisLoc == "PER"
			MsgAlert(STR0091)// "Opción Válida solo para documentos Autorizados."
			CursorArrow()
			Return
		EndIf
	EndIF

	If cPaisLoc == "PER" .And. !Empty(cFile)
		cSchema:= fReadfile(cPath,cFile)
		cSchema := strtran(cSchema,chr(13) + chr(10), "")
	EndIF
	CursorArrow()
	Aviso(cTit,alltrim(cSchema),{"Ok"},3)
Return

/*/{Protheus.doc} M486VLDCR
Obtiene los comprobantes de retención dentro del rango informado y realiza las validaciones correspondientes
antes de enviar a TSS
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param cFacIn, character, (Descrição do parâmetro)
@param cFacFi, character, (Descrição do parâmetro)
@param cSeriec, character, (Descrição do parâmetro)
@param aFact, array, (Descrição do parâmetro)
@param aError, array, (Descrição do parâmetro)
@param nTotal, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486VLDCR( cFacIn, cFacFi, cSeriec, aFact,aError,nTotal)
	Local cQuery        := ""
	Local cTempF        := getNextAlias()
	Local nCount        := 0
	Local nCont         := 0
	Local nPos			 := 0
	Local cXml          := ""
	Local lRet 		    := .T.
	Local lValFec		:= .T.
	Local lVldPro		:= .T.
	Local lValSerie2	:= .T.
	Local lEstPtoE      := .T.
	Local cIdCerRet 	:= ""
	Local cCampos       := ""
	Local cCond         := "% SFE.FE_NROCERT BETWEEN '" + cFacIn + "' AND '" + cFacFi + "' AND SFE.D_E_L_E_T_= ' '"

	If cPaisLoc == "PER"
		cCampos := "% SFE.FE_NROCERT,SFE.FE_FORNECE,SFE.FE_LOJA,SFE.FE_NFISCAL,SFE.FE_SERIE, FE_EMISSAO, SFE.R_E_C_N_O_ RECNUM , SFE.FE_SERIE2 %"
		cCond += " AND SFE.FE_SERIE2 = '" + cSeriec + "'"
	ElseIf cPaisLoc == "EQU"
		cCampos := "% DISTINCT SFE.FE_NROCERT, SFE.FE_NFISCAL, SFE.FE_SERIE, SFE.FE_FORNECE, SFE.FE_LOJA, FE_EMISSAO %"
	EndIf

	cCond += " %"

	BEGINSQL ALIAS cTempF
		SELECT %Exp:cCampos%
		FROM %Table:SFE% SFE
		WHERE %Exp:cCond%
	ENDSQL

	TCSetField(cTempF,"FE_EMISSAO","D")
	count to nCount

	lRet := nCount > 0
	(cTempF)->(dbGoTop())
	While (!(cTempF)->(EOF()))
		nCont++
		IncProc(STR0059) //"Procesando"

		If cPaisLoc == "PER"
			lVldPro := M486VLDPRO((cTempF)->FE_FORNECE, (cTempF)->FE_LOJA,(cTempF)->FE_NFISCAL,(cTempF)->FE_SERIE2,(cTempF)->FE_NROCERT,@aError) // Valida los datos del cliente del documento en cuestion

			// Valida  fecha de emisión no mayor a 7 días anteriores a la fecha de transmisión
			dFchAux := ddatabase - 7
			If !((cTempF)->FE_EMISSAO >= dFchAux .and. (cTempF)->FE_EMISSAO <= ddatabase)
				aAdd(aError, {(cTempF)->FE_SERIE2,(cTempF)->FE_NROCERT,(cTempF)->FE_FORNECE, (cTempF)->FE_LOJA, STR0088}) // "Fecha de emisión fuera de rango. Debe ser hasta 7 días anteriores al afecha de emisión."
				lValFec := .F.
			Else
				lValFec := .T.
			EndIf

			cIdCerRet := (cTempF)->FE_SERIE2+(cTempF)->FE_NROCERT

			//Valida campo FE_SERIE 2 que no esté vacío
			If Empty((cTempF)->FE_SERIE2)
				aAdd(aError, {(cTempF)->FE_SERIE2,(cTempF)->FE_NROCERT,(cTempF)->FE_FORNECE, (cTempF)->FE_LOJA, STR0108}) //  "Falta informar Serie 2 que será informada a la SUNAT(FE_SERIE2)"
				lValSerie2 := .F.
			Else
				lValSerie2 := .T.
			EndIf
			nPos := Ascan(aFact,{|x| x[1] == (cTempF)->FE_SERIE2 .and. x[2] == (cTempF)->FE_NROCERT} )
			If nPos != 0
				nCont -= 1
			EndIf
		ElseIf cPaisLoc == "EQU"
			lVldPro := M486VPROEQ((cTempF)->FE_FORNECE, (cTempF)->FE_LOJA, (cTempF)->FE_NFISCAL, (cTempF)->FE_NROCERT, @aError) // Valida los datos del cliente del documento en cuestion

			//Establecimiento y Punto de Emisión por sucursal
			If Empty(SM0->M0_DSCCNA)
				aAdd(aError ,{"", (cTempF)->FE_NROCERT, (cTempF)->FE_FORNECE, (cTempF)->FE_LOJA, STR0188}) // "Información no válida en registro sucursal Establecimiento y Pto. de Emisión (M0_DSCCNA - Actividad Económica)."
	 			lEstPtoE := .F.
			EndIf
		EndIf

		lRet := lVldPro .and. lValFec .and. lValSerie2 .And. lEstPtoE
		If lRet
			If nPos == 0
				aAdd(aFact,{IIf(cPaisLoc == "EQU", "", (cTempF)->FE_SERIE2),(cTempF)->FE_NROCERT,(cTempF)->FE_FORNECE, (cTempF)->FE_LOJA,(cTempF)->FE_NFISCAL,(cTempF)->FE_SERIE,(cTempF)->FE_EMISSAO})
			EndIf
		EndIf
		(cTempF)->(dbSkip())
	EndDo
	nTotal := nCont
	(cTempF)->(dbCloseArea())
Return lRet

/*/{Protheus.doc} M486UPDST
Actualiza estatus de documentos electrónicos.
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param aTrans, array, (Array con lso documentos que fueron aceptados en TSS)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486UPDST(aTrans)
	Local cStatus	:= "1"
	Local aArea	:= getArea()
	Local nI := 0

	For nI := 1 to len(aTrans)
		If nTipoDoc == 0
			cClave :=  aTrans[nI,1] + aTrans[nI,4]+aTrans[nI,5]+aTrans[nI,3]+aTrans[nI,2]
			dbSelectArea("SF1")
			SF1->(dbSetOrder(2))// F1_FILIAL+F1_CLIENTE+F1_LOJA+F1_DOC
			If SF1->(dbSeek(cClave))
				If cPaisLoc <> "COL"
					RecLock("SF1",.F.)
						SF1->F1_FLFTEX := cStatus
					SF1->(MsUnlock())
				Else
					RecLock("SF1",.F.)
						SF1->F1_FLFTEX  := aTrans[nI,7]
						If SuperGetMV("MV_PROVFE",,"") == "TSS"
							SF1->F1_URI		:= aTrans[nI,6]
						Else
							SF1->F1_UUID	:= aTrans[nI,6]
						EndIf
					SF1->(MsUnlock())
				EndIf
			EndIF
		Else
			cClave := aTrans[nI,1] + aTrans[nI,4]+aTrans[nI,5]+aTrans[nI,3]+aTrans[nI,2]
			dbSelectArea("SF2")
			SF2->(dbSetOrder(2)) // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
			If SF2->(dbSeek(cClave))
				If cPaisLoc <> "COL"
					RecLock("SF2",.F.)
						SF2->F2_FLFTEX := cStatus
					SF2->(MsUnlock())
				Else
					RecLock("SF2",.F.)
						SF2->F2_FLFTEX := aTrans[nI,7]
						If SuperGetMV("MV_PROVFE",,"") == "TSS"
							SF2->F2_URI		:= aTrans[nI,6]
						Else
							SF2->F2_UUID	:= aTrans[nI,6]
						Endif
					SF2->(MsUnlock())
				EndIF
			EndIF
		EndIf
	Next nI
	RestArea(aArea)
Return .t.

/*/{Protheus.doc} fGetPais
Retorna código de pais segun IS0-3166
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fGetPais()
	Local cPais := ""

	If cPaisLoc == "EQU"
		cPais := "218"
	Elseif cPaisLoc == "PER"
		cPais := "604"
	ElseIf cPaisLoc == "CHI"
		cPais := "152"
	ElseIf cPaisLoc == "COL"
		cPais := "170"
	Endif
return cPais

/*/{Protheus.doc} M486VSM0
Valida que estén registrados datos en SM0
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@return LrET, Verdadero si los datos validados se encuentran en sigamat
@example
(examples)
@see (links_or_references)
/*/
Static Function M486VSM0()
	Local lRet := .T.
	Local cMsg := ""
	Local cCve	:= ""

	If Empty(SM0->M0_BAIRENT)
		cMsg += STR0136 + " (M0_BAIRENT)." + CHR(13) + CHR(10) // "-Barrio"
	ElseIf Empty(SM0->M0_ENDENT)
		cMsg += STR0139 + " (M0_ENDENT)." + CHR(13) + CHR(10) // "-Dirección Fiscal"
	ElseIf Empty(SM0->M0_CIDENT)
		cMsg += STR0137 + " (M0_CIDENT)." + CHR(13) + CHR(10) // "Ciudad Fiscal/Entrega"
	ElseIf Empty(SM0->M0_CEPENT)
		cMsg += STR0086 + " (M0_CEPENT)." + CHR(13) + CHR(10) // "CP Fiscal/Entrega"
	ElseIf Empty(SM0->M0_CGC)
 		cMsg += IIf(cPaisLoc=="PER", STR0113, "-NIT") + " (M0_CGC)." + CHR(13) + CHR(10) // "-RUC"
 	ElseIf Empty(SM0->M0_DSCCNA)
 		cMsg += IIF(cPaisLoc=="PAR",STR0258,STR0239 + " (M0_DSCCNA).") + CHR(13) + CHR(10) //STR0258 "-Actividad Económica de la Empresa" STR0239 "Dato de Local Anexo (M0_DSCCNA)."
	ElseIf Empty(SM0->M0_NOME) .OR. Empty(SM0->M0_NOMECOM)
		cMsg += STR0114 + " (M0_NOME o M0_NOMECOM)." + CHR(13) + CHR(10) // "-Nombre de la Empresa"
	EndIF

	// PARAGUAY SE VALIDA QUE ESTÉ LLENOS LOS DATOS ADICIONALES EN LA TABLA S030
	If cPaisLoc == "PAR"
		// Ciudad
		cCve := ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 23,4)
		If Empty(cCVE)
			cMsg += STR0246 + STR0247 + CHR(13) + CHR(10) // "-Código de Ciudad de la Empresa " " Tabla S030- Datos adicionales empresa"
		Else
			lRet := ValidCat("S012", cCve,48,4)
			If !lRet 
				cCve := STRTRAN(STR0248,"#COD#",cCve)
				cCve += STRTRAN(STR0248,"#TABLA#","S012")
				cCve += STRTRAN(STR0248,"#CAMPO#",STR0249) // "CIUDAD"
				cMsg += cCve + CHR(13) + CHR(10) // ""El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO# tabla S030. "
			EndIf
		EndIf		
		// Departamento
		cCve := ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 18,2) 
		If Empty(cCVE)
			cMsg += STR0250 + STR0247 + CHR(13) + CHR(10) // "-Código de Departamento de la Empresa " " Tabla S030- Datos adicionales empresa"
		Else
			lRet := ValidCat("S003", cCve,1,2)
			If !lRet 
				cCve := STRTRAN(STR0248,"#COD#"		,cCve)
				cCve += STRTRAN(STR0248,"#TABLA#"	,"S030")
				cCve += STRTRAN(STR0248,"#CAMPO#"	,STR0253) 	// "CODIGO DEPARTAMENTO"
				cMsg += STR0248 + CHR(13) + CHR(10) 		// ""El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO# tabla S030. "
			EndIf
		EndIf	
		// Distrito
		cCve := ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 20,3)
		If Empty(cCVE)
			cMsg += STR0251 + STR0247 + CHR(13) + CHR(10) // "-Código de Distrito de la Empresa " " Tabla S030- Datos adicionales empresa"
		Else
			lRet := ValidCat("S031", cCve,1,3)
			If !lRet 
				cCve := STRTRAN(STR0248,"#COD#",cCve)
				cCve += STRTRAN(STR0248,"#TABLA#","S030")
				cCve += STRTRAN(STR0248,"#CAMPO#",STR0254) 	// "CODIGO DISTRITO"
				cMsg += STR0248 + CHR(13) + CHR(10) 		// "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO# tabla S030. "
			EndIf
		EndIf
		
		// Tipo de Regimen
		cCve :=  ObtColSAT("S030",SUBSTR(SM0->M0_CGC,1,10) , 1, 10, 17,1)
		If Empty(cCVE)
			cMsg += STR0252 + STR0247 + CHR(13) + CHR(10) // "-Código de Tipo de Régimen de la Empresa " " Tabla S030- Datos adicionales empresa"
		Else
			lRet := ValidCat("S001", cCve,1,1)
			If !lRet 
				cCve := STRTRAN(STR0248,"#COD#",cCve)
				cCve += STRTRAN(STR0248,"#TABLA#","S030")
				cCve += STRTRAN(STR0248,"#CAMPO#",STR0255) 	// "TIPO DE REGIMEN"
				cMsg += STR0248 + CHR(13) + CHR(10) 		// ""El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO# tabla S030. "
			EndIf
		EndIf
	EndIf
	
	If !Empty(cMsg)
		cMsg := STR0094 + CHR(13) + CHR(10) + cMsg // "Complete datos del Emisor: "
		cMsg += STR0114 + CHR(13) + CHR(10) + SM0->M0_NOMECOM // "-Nombre de la Empresa"
		MsgInfo(cMsg,STR0093) //  "Atención"
		lRet := .F.
	EndIF
Return lRet

/*/{Protheus.doc} M486VLDCLI
Valida que estén registrados los datos obl para el cliente
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param cCodCli, character, (Codigo de Cliente)
@param cCodLoj, character, (tIENDA)
@param cDocumento, character, (Documento)
@param cSerDoc, character, (Serie del Documento)
@param aError, array, (array que guarda los errores del documento)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486VLDCLI(cCodCli, cCodLoj,cDocumento,cSerDoc,aError)
 	Local lRet		:= .T.
 	Local aArea		:= GetArea()
 	Local cCodERP	:= ""
 	Local cCodTD	:= ""
	Local cProvFE 	:= 	SuperGetMV("MV_PROVFE",,"")

 	dbSelectArea("SA1")
 	SA1->(DBSETORDER(1)) //A1_FILIAL+A1_COD+A1_LOJA

 	If SA1->(dbSeek(xFilial("SA1")+cCodCli+cCodLoj))
 		If Empty(SA1->A1_TIPDOC)
 			aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj,STR0117}) // "Información faltante registro cliente Tipo de documento de Identificación del Cliente(A1_TIPDOC)"
 			lRet := .F.
 		ElseIf cPaisLoc == "PER"
 			lRet := ValidCat("S006", SA1->A1_TIPDOC,1,1)     //M486VALSX5("XN"+SA1->A1_TIPDOC)
 			If !lRet
 				aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj,STR0124 + SA1->A1_TIPDOC}) //"No existe registro en Catálogo S006 para Tipo de Documento: "
 				lRet := .F.
 			EndIF
 		EndIF
 		If Empty(SA1->A1_NOME)
 			aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj,STR0118}) // "Información faltante registro cliente Nombre del Cliente"
 			lRet := .F.
 		EndIf
 		If Empty(SA1->A1_PAIS)
 			aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0119})// "Información faltante registro cliente País"
 			lRet := .F.
 		Else
 			If cPaisLoc $ "PER|BOL|PAR"
 				cCodTD := "YA_CODERP"
 			ElseIf cPaisLoc == "COL"
 				cCodTD := "YA_CCEDIAN"
 			EndIf
 			cCodERP := POSICIONE("SYA",1,XFILIAL("SYA")+SA1->A1_PAIS,cCodTD)
 			If Empty(cCodERP)
 				aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, Strtran(STR0138,"#PAIS#",cCodERP) + SA1->A1_PAIS})// "No exite código de País(#PAIS#) en SYA para País: "
 				lRet := .F.
 			Else
 				If cPaisLoc == "PER"
 					lRet := ValidCat("S004", cCodERP,1,2)
 				ElseIf cPaisLoc == "COL"
 					lRet := ValidF3I("S008", cCodERP,1,2)
 				ElseIf cPaisLoc == "BOL"
 					lRet := ValidCat("S010", cCodERP,1,4)
 				ElseIf cPaisLoc == "PAR"
 					lRet := ValidCat("S005",cCodERP,1,3)
 				EndIf

 				If !lRet
 					aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0067 + cCodERP })// "No existe registro de código internacional de país: "
 					lRet := .F.
 				EndIF
 			EndIf
 		EndIf
 		If Empty(SA1->A1_END)
 			aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0121}) // "Información faltante registro del cliente - Dirección(A1_END)"
 			lRet := .F.
 		EndIf
 		If Empty(SA1->A1_BAIRRO) .and. !(cPaisLoc == "BOL" .and. "VULCAN" $ cProvFE)
 			aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0120}) // "Información faltante registro del cliente - Distrito(A1_BARRIO)"
 			lRet := .F.
 		EndIf
		If Empty(SA1->A1_MUN)
 			aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0123}) // "Información faltante registro del cliente - Provincia(A1_MUN)"
 			lRet := .F.
 		EndIf
 		If Empty(SA1->A1_CEP) .and. !(cPaisLoc == "BOL" .and. "VULCAN" $ cProvFE)
 			aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0080}) // "Información faltante registro del cliente - Codigo Postal(A1_CEP)"
 			lRet := .F.
 		EndIf
 		If !(cPaisLoc $ "BOL|PAR") .AND. ( Empty(SA1->A1_CGC)  .and.  Empty(SA1->A1_PFISICA))
 			lRet := .F.
 			aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0122}) // Información faltante registro cliente RUC (A1_CGC)
 		ElseIf cPaisLoc == "PAR" // Validar que esté lleno ruc dependiendo del campo A1_TIPDOC
 			If (Empty(SA1->A1_TIPDOC) .and. Empty(SA1->A1_CGC)) .OR. (Empty(SA1->A1_TIPDOC) .and. Empty(SA1->A1_CGC))
 				aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0122}) // "Información faltante registro del cliente - No. de documento de identificación (A1_CGC o A1_PFISICA)"
 				lRet := .F.
 			ElseIf !Empty(SA1->A1_TIPDOC) .AND. Empty(SA1->A1_NIF)
 				aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj,STR0122}) // "Información faltante registro del cliente - No. de documento de identificación (A1_CGC o A1_PFISICA)"
 				lRet := .F.
 			EndIf 		 		
 			If Empty(SA1->A1_NUM)
 				lRet := .F.
 				aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj,STR0241}) // "Información faltante registro del cliente - No. de documento de Casa(A1_NUM)" 				 			 
 			EndIf
 			
 			If Empty(SA1->A1_DEPTO)
 				lRet := .F.
 				aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj,STR0243}) // "Información faltante registro del cliente - Código Departament (A1_DEPTO)"
 			Else
 				lRet := ValidCat("S003",SA1->A1_DEPTO,1,2)
 				If !lRet
 					cCodERP := STRTRAN(STR0242,"#CAMPO#","(A1_DEPTO)")
 					cCodERP := STRTRAN(STR0242,"#TABLA#","S003")
 					cCodERP := STRTRAN(STR0242,"#CCOD#", SA1->A1_DEPTO)
 					aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj,cCodERP}) // "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 				EndIf
 			EndIF
 			If Empty(SA1->A1_DISTR)
 				lRet := .F.
 				aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj,STR0244}) // "Información faltante registro del cliente - Código Distrito (A1_DISTR)"
 			Else
 				lRet := ValidCat("S031", SA1->A1_DISTR,1,3)
 				If !lRet
 					cCodERP := STRTRAN(STR0242,"#CAMPO#","(A1_DISTR)") 		//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 					cCodERP := STRTRAN(STR0242,"#TABLA#","S031")			//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 					cCodERP := STRTRAN(STR0242,"#CCOD#" , SA1->A1_DISTR)	//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 					
 					aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj,cCodERP}) //  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 				EndIf
 			EndIf
 			
 			If Empty(SA1->A1_CIUDAD)
 				lRet := .F.
 				aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj,STR0245}) // "Información faltante registro del cliente - Código Ciudad (A1_CIUDAD)"
 			Else
 				lRet := ValidCat("S012", SA1->A1_CIUDAD,48,4)
 				If !lRet
 					cCodERP := STRTRAN(STR0242,"#CAMPO#","(A1_CIUDAD)") 	//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 					cCodERP := STRTRAN(STR0242,"#TABLA#","S012")		//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 					cCodERP := STRTRAN(STR0242,"#CCOD#" , SA1->A1_CIUDAD)	//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#" 					
 					aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj,cCodERP}) //  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 				EndIf
 			EndIF
 		EndIf
 		If Alltrim(SA1->A1_EST) == "EX"
 			lExporta := .T.
 		EndIf
 		If cPaisLoc == "COL"
 			If Empty(M486RESOBL(SA1->A1_COD,SA1->A1_LOJA,"T"))
 				lRet := .F.
 				aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, "Información faltante registro del cliente - Tributos DIAN"}) //
 			EndIf
 		EndIf
 	Else
 		lRet := .F.
 		aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0116}) // "Cliente sin registro"
 	EndIf
 	RestArea(aArea)
Return lRet

/*/{Protheus.doc} M485VLDPRO
Valida que estén registrados los datos obl para el proveedor
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param cCodPro, character, (Codigo del proveedor)
@param cCodLoj, character, (Tienda)
@param cDocumento, character, (Número de documento)
@param cSerDoc, character, (Serie dle documento que genera el CR)
@param cCert, character, (Número de Comprobante)
@param aError, array, (Array con los errores del documento)
@return lógico, Verdadero si pasa todas las validaciones
@example
(examples)
@see (links_or_references)
/*/
Static Function M486VLDPRO(cCodPro, cCodLoj,cDocumento,cSerDoc,cCert,aError,cEspecie)
 	Local lRet 	:= .T.
 	Local aArea 	:= GetArea()
	
	DEFAULT cCodPro:=''
	DEFAULT cCodLoj:=''
	DEFAULT cDocumento:=''
	DEFAULT cSerDoc:=''
	DEFAULT cCert:=''
	DEFAULT aError:={}
	DEFAULT cEspecie:=""

 	dbSelectArea("SA2")
 	SA2->(DBSETORDER(1)) //A1_FILIAL+A1_COD+A1_LOJA
    
 	If SA2->(dbSeek(xFilial("SA2")+cCodPro+cCodLoj))
	 	IF cPaisLoc<>"PAR"
			If Empty(SA2->A2_TIPDOC)
				aAdd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj,STR0126}) // "Información faltante registro proveedor - Tipo de documento de Identificación del Proveedor(A2_TIPDOC)"
				lRet := .F.
			Else
				lRet := ValidCat("S006", SA2->A2_TIPDOC,1,1)
				If !lRet
					aAdd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj,STR0124 + SA2->A2_TIPDOC}) //"No existe registro en SX5 - XD para Tipo de Documento: "
					lRet := .F.
				EndIF
			EndIF
		ENDIF
 		If Empty(SA2->A2_NOME)
 			aAdd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj,STR0127}) //  "Información faltante registro proveedor - Nombre del Proveedor"
 			lRet := .F.
 		EndIf
		IF (Empty(SA2->A2_CGC))
	 			lRet := .F.
	 			aAdd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj, STR0128}) //"Información faltante registro proveedor - RUT del Proveedor(A2_CGC)"
 		EndIf

 		If Empty(SA2->A2_PAIS)
 			aAdd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj, STR0129})// "Información faltante registro Proveedor - País"
 			lRet := .F.
 		Else
 			cCodERP := POSICIONE("SYA",1,XFILIAL("SYA")+SA2->A2_PAIS,"YA_CODERP")
 			If Empty(cCodERP)
 				aAdd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj, STR0134})// "No exite código de País(YA_CODERP) en SYA para País: "
 				lRet := .F.
 			Else
				If cPaisLoc <> "PAR"
					lRet := ValidCat("S004", cCodERP,1,2)
				ELSE
 					lRet := ValidCat("S005",cCodERP,1,3)
 				EndIf
 				If !lRet
 					aAdd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj, STR0067 + cCodERP })// "No existe registro en SX5 - XU para País: "
 					lRet := .F.
 				EndIF
 			EndIf
 		EndIf
 		If Empty(SA2->A2_END)
 			aAdd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj, STR0029}) // "Información faltante registro del proveedor - Dirección(A2_END)"
 			lRet := .F.
 		EndIf
 		If Empty(SA2->A2_BAIRRO)
 			aAdd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj, STR0028}) // "Información faltante registro del proveedor - Distrito(A2_BARRIO)"
 			lRet := .F.
 		EndIf
		If Empty(SA2->A2_MUN)
 			aAdd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj, STR0027}) // "Información faltante registro del proveedor - Provincia(A2_MUN)"
 			lRet := .F.
 		EndIf
 		If Empty(SA2->A2_CEP)
 			aAdd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj, STR0056}) // "Información faltante registro del proveedor - Codigo Postal(A2_CEP)"
 			lRet := .F.
 		EndIf
 	Else
 		lRet := .F.
 		aadd(aError ,{cSerDoc,cCert,cCodPro,cCodLoj, STR0125}) // "Proveedor sin registro"
 	EndIf

	IF cPaisLoc=="PAR" .AND. cEspecie=="RTS"
	 	If Empty(SA2->A2_DEPTO)
 				lRet := .F.
 				aAdd(aError ,{cSerDoc,cDocumento,cCodPro,cCodLoj,STR0243}) // "Información faltante registro del cliente - Código Departament (A1_DEPTO)"
 			Else
 				lRet := ValidCat("S003",SA2->A2_DEPTO,1,2)
 				If !lRet
 					cCodERP := STRTRAN(STR0242,"#CAMPO#","(A2_DEPTO)")
 					cCodERP := STRTRAN(STR0242,"#TABLA#","S003")
 					cCodERP := STRTRAN(STR0242,"#CCOD#", SA2->A2_DEPTO)
 					aAdd(aError ,{cSerDoc,cDocumento,cCodPro,cCodLoj,cCodERP}) // "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 				EndIf
 			EndIF
 			If Empty(SA2->A2_DISTR)
 				lRet := .F.
 				aAdd(aError ,{cSerDoc,cDocumento,cCodPro,cCodLoj,STR0244}) // "Información faltante registro del cliente - Código Distrito (A1_DISTR)"
 			Else
 				lRet := ValidCat("S031", SA2->A2_DISTR,1,3)
 				If !lRet
 					cCodERP := STRTRAN(STR0242,"#CAMPO#","(A2_DISTR)") 		//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 					cCodERP := STRTRAN(STR0242,"#TABLA#","S031")			//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 					cCodERP := STRTRAN(STR0242,"#CCOD#" , SA2->A2_DISTR)	//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 					
 					aAdd(aError ,{cSerDoc,cDocumento,cCodPro,cCodLoj,cCodERP}) //  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 				EndIf
 			EndIf
 			
 			If Empty(SA2->A2_CIUDAD)
 				lRet := .F.
 				aAdd(aError ,{cSerDoc,cDocumento,cCodPro,cCodLoj,STR0245}) // "Información faltante registro del cliente - Código Ciudad (A1_CIUDAD)"
 			Else
 				lRet := ValidCat("S012", SA2->A2_CIUDAD,48,4)
 				If !lRet
 					cCodERP := STRTRAN(STR0242,"#CAMPO#","(A2_CIUDAD)") 	//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 					cCodERP := STRTRAN(STR0242,"#TABLA#","S012")		//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 					cCodERP := STRTRAN(STR0242,"#CCOD#" , SA2->A2_CIUDAD)	//  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#" 					
 					aAdd(aError ,{cSerDoc,cDocumento,cCodPro,cCodLoj,cCodERP}) //  "El código #COD# no se encuentra en el Catálogo #TABLA# para el campo #CAMPO#"
 				EndIf
 			EndIF
	ENDIF
 	RestArea(aArea)
 Return lRet

 /*/{Protheus.doc} M486BRWSFE
 Genera browse con comprobantes de retención
 @type define
 @author mayra.camargo
 @since 22/06/2017
 @version 1.0
 /*/
Static Function M486BRWSFE()
	Local aCampos	:= {}
	Local aCores	:= {}
	Local cFiltro	:= ""

	cTipDocto := STR0044 // Comprobante de Retención
	// Comprobantes de Retención
	dbselectArea("SFE")
	_lCerRet 	:= .T.
	cPergFac 	:= IIf(cPaisLoc == "EQU", "MATA486D", "MATA486F")
	cEspecie    := IIf(cPaisLoc == "EQU", "RET", "")
	cModelo 	:= "S7"

	aCampos :=	{	{STR0092,	"FE_SERIE2"},;
								{STR0081,	"FE_NROCERT"},;
								{STR0082,	"FE_EMISSAO"},;
								{STR0083, 	"FE_FORNECE"},;
								{STR0084,	"FE_LOJA"}	,;
								{STR0085,	"FE_SERIEC"}}
	cAliasB := "SFE"
	cCadastro += cTipDocto
	aCores := M486CORES(3)
	bFiltraBrw := {|| FilBrowse(cAliasB,@aIndArqE,@cFiltro) }
	Eval(bFiltraBrw)
	MBrowse(,,,,cAliasB,,,,,,aCores,,,,,,,,)
Return

/*/{Protheus.doc} M486BRWSFX
Función para llenar Browse principal dependiendo del tipo de documento.
@type function
@author mayra.camargo
@since 22/06/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486BRWSFX()
	Local aCampos 	:= {}
	Local aCores 	:= {}
	Local cFLFTEX   := IIf(nTDTras == 3 .Or. nTDTras == 6 .Or. nTDTras == 8, "F1_FLFTEX", "F2_FLFTEX")
	Local cEMISSAO  := IIf(nTDTras == 3 .Or. nTDTras == 6 .Or. nTDTras == 8, "F1_EMISSAO", "F2_EMISSAO")
	Local cSpace    := Space(TamSX3("F2_FLFTEX")[01])

	If nTDTras == 1 // Factura Venta
		If cPaisLoc = "PER"
			cFiltro := "F2_ESPECIE = 'NF' .AND. F2_SERIE = '"+MV_PAR02+"'"
			cFiltro += " .AND. 'F' $ SubStr(F2_SERIE2,1,1) "
		ElseIf cPaisLoc $ "COL|EQU|BOL|PAR"
			cFiltro := "F2_ESPECIE = 'NF' .AND. F2_SERIE = '"+MV_PAR02+"'"
		EndIf
		cModelo := "S1"
		cPergFac := "MATA486A"
		cEspecie := Padr("NF",nTamEsp)
		cTipDocto := STR0032 // "Factura de Venta"
	ElseIf nTDTras == 3 // Nota de Crédito al cliente
		nTipoDoc:= 0
		cEspecie:= Padr("NCC", nTamEsp)
		cAliasB := 'SF1'
		cPergFac:= "MATA486C"
		cFiltro := "F1_ESPECIE = 'NCC' .AND. F1_SERIE = '"+MV_PAR02+"'"
		cModelo := "S4"
		cTipDocto := STR0033 // "Nota de Crédito"
	ElseIf nTDTras == 2 // Nota Débito al Cliente
		cEspecie := Padr("NDC", nTamEsp)
		cFiltro := "F2_ESPECIE = 'NDC' .AND. F2_SERIE = '"+MV_PAR02+"'"
		cModelo := "S5"
		cPergFac := "MATA486B"
		cTipDocto := STR0041 // "Nota de Dédito"
	ElseIf nTDTras == 4 // Boleta de Venta
		cFiltro := "F2_ESPECIE = 'NF' .AND. F2_SERIE = '"+MV_PAR02+"'"
		cFiltro += " .AND. 'B' $ SubStr(F2_SERIE2,1,1) "
		cModelo := "SD"
		cPergFac := "MATA486D"
		cEspecie := Padr("NF",nTamEsp)
		cTipDocto := STR0042 // "Boleta de Venta"
	ElseIf nTDTras == 5 // Guia Remision
		cEspecie := Iif(cPaisLoc $ "EQU","RFN|RTS|RCD",Padr("RFN", nTamEsp))
		cFiltro := "F2_ESPECIE = 'RFN' "+Iif(cPaisLoc $ "EQU",".Or. F2_ESPECIE = 'RTS' .Or. F2_ESPECIE ='RCD'","")+".AND. F2_SERIE = '"+MV_PAR02+"'"
		cModelo := "S6"
		cPergFac := "MATA486E"
		cTipDocto := STR0043 //"Guia Remisión"
	ElseIf cPaisLoc =="COL" .AND. nTDTras == 6 // Documento Soporte
		nTipoDoc:= 0
		cEspecie:= Padr("NCC", nTamEsp) //Para tratamiento sobre SF1
		cAliasB := 'SF1'
		cPergFac:= "MATA486I"
		cFiltro := "F1_ESPECIE = 'NF' .AND. F1_SERIE = '"+MV_PAR02+"'"
		cFiltro += " .AND. F1_SOPORT = 'S'"
		cModelo := "S1"//"S4"
		cTipDocto := STR0352 // "Documento Soporte"
	ElseIf cPaisLoc =="PAR" .AND. nTDTras == 7 // RTS

		cEspecie := Padr("RTS", nTamEsp)
		cFiltro := "F2_ESPECIE = 'RTS' .AND. F2_SERIE = '"+MV_PAR02+"'"
		cModelo := "S6"
		cPergFac := "MATA486E"
		cTipDocto :=STR0376 //"Guía RTS" //"Remisión Transferencia entre sucursales(RTS)"

	ElseIf cPaisLoc =="COL" .AND. nTDTras == 8 // Nota Débito al Cliente
		nTipoDoc:= 0
		cEspecie := Padr("NDP", nTamEsp)
		cFiltro := "F1_ESPECIE = 'NDP' .AND. F1_SERIE = '"+MV_PAR02+"' .AND. F1_MARK = 'S'" 
		cAliasB := 'SF1'
		cModelo := "S5"
		cPergFac := "MATA486J"
		cTipDocto := STR0425 + STR0423 // "Nota de Ajuste" // "Débito"
	ElseIf cPaisLoc =="COL" .AND. nTDTras == 9 // Nota de Crédito al cliente
		nTipoDoc:= 1
		cEspecie:= Padr("NCP", nTamEsp) 
		cAliasB := 'SF2'
		cPergFac:= "MATA486J"
		cFiltro := "F2_ESPECIE = 'NCP' .AND. F2_SERIE = '"+MV_PAR02+"' .AND. F2_MARK = 'S'" 
		cModelo := "S4"
		cTipDocto := STR0425 + STR0424 // "Nota de Ajuste" // "Crédito" 
	Endif
	If !Empty(cEstatus)
		Do Case
			Case cEstatus == "1" //0=No Enviado
				cFiltro += " .AND. (" + cFLFTEX + " = '0' .OR. " + cFLFTEX + " = '" + cSpace +"')"
			Case cEstatus == "2" //1=Enviado a TSS
				cFiltro += " .AND. " + cFLFTEX + " = '1'"
			Case cEstatus == "3" //4=Esperando procesamiento
				cFiltro += " .AND. (" + cFLFTEX + " = '4' .OR. " + cFLFTEX + " = '2')"
			Case cEstatus == "4" //5=Rechazado
				cFiltro += " .AND. (" + cFLFTEX + " = '5' .OR. " + cFLFTEX + " = '3')"
			Case cEstatus == "5" //6=Autorizado
				cFiltro += " .AND. " + cFLFTEX + " = '6'"
			Case cPaisLoc == "BOL" .AND. cEstatus == "6" //9=Anulacion rechazada
				cFiltro += " .AND. " + cFLFTEX + " = '9'"
			Case cPaisLoc == "BOL" .AND. cEstatus == "7" //7=Anulacion rechazada
				cFiltro += " .AND. " + cFLFTEX + " = '7'"
			Case cPaisLoc == "BOL" .AND. cEstatus == "8" //8=Anulacion rechazada
				cFiltro += " .AND. " + cFLFTEX + " = '8'"
		EndCase
	EndIf
	If !Empty(dFecIni)
		cFiltro += " .AND. DTOS(" + cEMISSAO + ") >= '" + Dtos( dFecIni ) + "' "
	EndIf
	If !Empty(dFecFin)
		cFiltro += " .AND. DTOS(" + cEMISSAO + ") <= '" + Dtos( dFecFin ) + "' "
	EndIf
	
	cCadastro += cTipDocto
	aCores := M486CORES(IIF(cAliasB == "SF2",1,2))
	bFiltraBrw := {|| FilBrowse(cAliasB,@aIndArqE,@cFiltro) }
	Eval(bFiltraBrw)
		MBrowse(,,,,cAliasB,,,,,,aCores,,,,,,,,)
Return

/*/{Protheus.doc} M486VLDDET
(long_description)
@type function
@author mayra.camargo
@since 06/07/2017
@version 1.0
@param cCodCli, character, (Codigo de cliente)
@param cCodLoj, character, (Tienda del cliente)
@param cDocumento, character, (Numero de documento a validar)
@param cSerDoc, character, (Serie del documento a validar)
@param aError, array, (array que guardará los errores del documento)
@return lRet, Si todo está ok con el documento retorna true}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486VLDDET(cCodCli, cCodLoj,cDocumento,cSerDoc,aError)
	Local aArea	:= getArea()
	Local nPos 	:= 0
	Local aTES 	:= {}
	Local cUM		:= ""
	Local lRet 	:= .T.
	Local nI		:= 0
	Local lMercancias := .F.
	Local lServicios := .F.
	Local lIGV := .F.

	If cPaisLoc == "PER|COL"
		If nTipoDoc == 0 // SD1
			DBSELECTAREA("SD1")
			SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_CLIENTE+D1_LOJA

			If SD1->(dbSeek(xfilial("SD1")+cDocumento+cSerDoc + cCodCli+cCodLoj, .T.)) //
				While SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == xfilial("SD1")+cDocumento+cSerDoc + cCodCli+cCodLoj  //
					If len(aTES) > 0
						nPos := aScan(aTES, { |x| x == SD1->D1_TES  })
						If nPos == 0
							aAdd(aTES,SD1->D1_TES)
						EndIf
					Else
						aAdd(aTES,SD1->D1_TES)
					EndIF
					dbSelectArea("SB1")
					SB1->(dbGoTop())
					SB1->(dbsetorder(1)) // B1_FILIAL+B1_COD
					If SB1->(Dbseek(xFilial("SB1")+SD1->D1_COD))
						If Empty(SB1->B1_UM)
							aadd(aError ,{cSerDoc,cDocumento, STR0141 + SB1->B1_COD + "-" + STR0142 + SD1->D1_ITEM + STR0143}) // "Producto" "ITEM" "Sin Unidad de Medida(B1_UM)"
							lRet := .F.
						Else
							cUM:= POSICIONE("SAH",1,xFilial("SAH") + SB1->B1_UM,"AH_COD_CO")
							If Empty(cUM)
								aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0141 + SB1->B1_COD + "-" + STR0142 + SD1->D1_ITEM + STR0144}) // "Producto" "ITEM""Sin Unidad de Medida SUNAT(AH_COD_CO)"
								lRet := .F.
							EndIf
						EndIf
					Else
						aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0140 + SB1->B1_COD}) // "Producto sin registro Código: "
						lRet := .F.
					EndIF
					SD1->(dbSkip())
				EndDo
			EndIf
		Else // SD2
			DBSELECTAREA("SD2")
			SD2->(dbSetOrder(3)) //  D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_ITEM
			If SD2->(dbSeek(xfilial("SD2")+cDocumento+cSerDoc + cCodCli+cCodLoj,.F.))
				While SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA == xfilial("SD2")+cDocumento+cSerDoc + cCodCli+cCodLoj  //
					If len(aTES) > 0
						nPos := aScan(aTES, { |x| x == SD2->D2_TES  })
						If nPos == 0
							aAdd(aTES,SD2->D2_TES)
						EndIf
					Else
						aAdd(aTES,SD2->D2_TES)
					EndIF
					dbSelectArea("SB1")
					SB1->(dbGoTop())
					SB1->(dbsetorder(1)) // B1_FILIAL + B1_COD
					If SB1->(Dbseek(xFilial("SB1")+SD2->D2_COD))
						If Empty(SB1->B1_UM)
							aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0141 + SB1->B1_COD + "-" + STR0142 + SD2->D2_ITEM + STR0143}) // "Producto" "ITEM" "Sin Unidad de Medida(B1_UM)"
							lRet := .F.
						Else
							cUM:= POSICIONE("SAH",1,xFilial("SAH") + SB1->B1_UM,"AH_COD_CO")
							If Empty(cUM)
								aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0141 + SB1->B1_COD + "-" + STR0142 + SD2->D2_ITEM + STR0144}) // "Producto" "ITEM""Sin Unidad de Medida SUNAT(AH_COD_CO)"
								lRet := .F.
							EndIf
						EndIf
						If Alltrim(SB1->B1_PRODSAT) >= "70101500" .And. Alltrim(SB1->B1_PRODSAT) <= "94139999"
							lServicios := .T.
						ElseIf !Empty(SB1->B1_PRODSAT)
							lMercancias := .T.
						EndIf
					Else
						aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0140 + SB1->B1_COD}) // "Producto sin registro Código: "
						lRet := .F.
					EndIF
					SD2->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	// Procesamiento de TES
	If len(aTES) > 0
		dbSelectArea("SFC")
		SFC->(dbSetOrder(1)) //FC_FILIAL+FC_TES+FC_SEQ+FC_IMPOSTO

		For nI := 1  to len(aTES)
			If SFC->(dbSeek(xFilial("SFC") + aTES[nI]))
				If cPaisLoc == "PER"
					If "IGV" $ SFC->FC_IMPOSTO
						If empty(SFC->FC_TIPOIGV)
							aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0095 + SFC->FC_IMPOSTO + STR0096 + SFC->FC_TES}) //"Debe configurar Código de Afectación(FC_TIPOIGV) para impuesto ""-TES "
							lRet := .F.
						Else
							lRet := ValidCat("S007", SFC->FC_TIPOIGV,1,2)
							If !lRet
								aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0098+ SFC->FC_IMPOSTO + STR0096 + SFC->FC_TES}) //"No existe Código de Afectación(FC_TIPOIGV) registrado en Tabla XR: "
								lRet := .F.
							EndIf
						EndIf
					ElseIf "ISC" $ SFC->FC_IMPOSTO
						If Empty(SFC->FC_TIPOISC)
							aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0097+ SFC->FC_IMPOSTO + STR0096 + SFC->FC_TES}) // "Debe configurar Sistema de Cálculo ISC(FC_TIPOISC) para impuesto "
							lRet := .F.
						Else
							lRet := ValidCat("S008", SFC->FC_TIPOISC,1,2)
							If !lRet
								aadd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0099+ SFC->FC_IMPOSTO + STR0096 + SFC->FC_TES}) //"No existe Código de Sistema de Cálculo ISC(FC_TIPOSC) registrado en Tabla XT: "
								lRet := .F.
							EndIf
						EndIf
					EndIF
					If ("IGV" $ SFC->FC_IMPOSTO .Or. "IGI" $ SFC->FC_IMPOSTO)
						lIGV := .T.
					EndIF
				ElseIf cPaisLoc == "COL"
					//Validaciones a impuestos de la TES
					lRet := .T.
				EndIf
			EndIf
		Next nI

	EndIf

	If cPaisLoc == "PER" .And. Alltrim(cEspecie) == "NF" .And. lExporta
		If lMercancias .And. lServicios
			aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0191}) //"Factura de exportación: Solo debe incluir Mercancías o Servicios pero no ambos tipos de productos."
			lRet := .F.
		EndIf
		If Alltrim((cTempF)->TIPONF) == "0200"
			// Cátalogo S051: código 0200 == Exportación Mercancías, (0201 <= códigos <= 0208) == Exportación Servicios
			If lIGV
				aAdd(aError ,{cSerDoc,cDocumento,cCodCli,cCodLoj, STR0192}) //"Factura de exportación: En productos de Mercancías no aplica IGV gravado."
				lRet := .F.
			EndIf
		EndIF
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} ${M486SENDDOC}
Reliza la transmisión de documentos en formato XML para el TSS
@type
@author mayra.camargo
@since 29/06/2017
@version 1.0
@param aFact, Array, Array con lso documentos que pasaron las validaciones
@param aError, Array, Array con los registros de error de los documentos
@param cURL, caracter, URL de los WS de TSS
@param aTrans, Array, Array con los documentos que serán enviados a TSS
@return cMod, Caracter, Modelo que será enviado a TSS
@example
(examples)
@see (links_or_references)
/*/
Static Function M486SENDDOC(aFact,aError,cURL,aTrans,cMod,lComBaja,lResDia)
	Local aArea    := getArea()
	Local lRet 	   := .T.
	Local oWS	   := Nil
	Local cXML 	   := ""
	Local nI	   := 0
	Local cIdEnt   := GetIdEnt()
	Local cFilTab  := IIf(Alltrim(cEspecie) $ "NF|NDC", xFilial("SF2"), xFilial("SF1"))
	Local dFecGen  := dDataBase
	Local cIdCB    := ""
	Local aIdCBaja := {}
	Local cNomXML  := ""
	Local lOk      := .F.
	Local oRestClient := Nil
	Local cAliasSF := IIf(!Empty(nTDTras), IIf(nTDTras != 3,"SF2","SF1"), "")
	Local cPreSF   := IIf(!Empty(nTDTras), IIf(nTDTras != 3,"F2_","F1_"), "")
	Local lConDoc  := .F. //Bandera para consultar documento
	Local aDocAct  := {}
	Local cIdXMLCB  := ""
	Local lResDRev  := _lCerRet
	Local cParamB   := ""
	Local cFilSFE   := xFilial("SFE")

	Default cMod	 := IIF(IsMemVar("cModelo"), cModelo, "S1")
	Default cURL     := ContParam("MV_WSRTSS") //Parametro que almacena la url de TSS
	Default lComBaja := .F. //Envío de comunicado de baja
	Default lResDia  := .F. //Envío de comunicado de baja

	If lResDia .Or. (lComBaja .And. lResDRev) //Resumen Diario o Resumen Diario de Devolución
		If lComBaja .And. lResDRev
			cIdCB := GetMV("MV_IDRDREV",,"") //Consecutivo Resumen Diario de Devolución
			cParamB := "MV_IDRDREV
		Else
			cIdCB := GetMV("MV_IDREDIA",,"") //Consecutivo Resumen Diario
		EndIf
	ElseIf lComBaja .And. !lResDRev
		cIdCB := GetMV("MV_IDCBAJA",,"") //Consecutivo Comunicado Baja
		cParamB := "MV_IDCBAJA"
	EndIf

	If !Empty(cIdEnt)
		oWS := WSTSSWSSUNAT():NEW()
		oWs:cUSERTOKEN:= "TOTVS"
		oWs:cIDENT	:= cIdEnt
		oWS:_URL		:= cUrl + "/TSSWSSUNAT.apw"
		oWS:cMODELO 	:= IIf(lComBaja .or. lResDia, "SE", cModelo)
		For nI:= 1 to len(aFact)
			// Dependiendo del modelo se genera el XML
			If lResDia //Resumen Diario
				//Obtener consecutivo del parámetro
				aIdCBaja := StrTokArr(cIdCB, "-")
				If Len(aIdCBaja) < 3 .Or. aIdCBaja[2] <> dtos(dFecGen)
					cIdXMLCB := "RC-" + dtos(dFecGen) + "-1"
				Else
					cIdXMLCB := "RC-" + dtos(dFecGen) + "-" + Alltrim(Str(Val(aIdCBaja[3]) + 1))
				EndIf
				PutMv("MV_IDREDIA",cIdXMLCB)
				cXML	:= M486RDXML(cFilTab, aFact[nI,1], aFact[nI,4], aFact[nI,3], aFact[nI,2], cEspecie, cIdXMLCB)
			ElseIf cMod $ "S1|SD" // Factura| Boleta de Venta
				If alltrim(cEspecie) == "NF" .and. ExistBlock("M486PENF")
					cXML	:= ExecBlock("M486PENF",.F.,.F.,{cFilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie})
				Else
					cXML	:= M486NFXML(cFilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie)
				EndIf
			ElseIf cMod $ "S4" //  | Nota de Crédito
				If alltrim(cEspecie) == "NCC" .and. ExistBlock("M486PENC")
					cXML	:= ExecBlock("M486PENC",.F.,.F.,{cfilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie})
				Else
					cFilTab:= xFilial("SF1")
					cXML	:= M486NCCXML(cFilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie)
				EndIf
			ElseIf cMod $ "S5" //  | Nota de Débito
				If alltrim(cEspecie) == "NDC" .and. ExistBlock("M486PEND")
					cXML	:= ExecBlock("M486PEND",.F.,.F.,{cFilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie})
				Else
					cXML	:= M486NDCXML(cFilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie)
				EndIf
			ElseIf cMod $ "S7" //  | Comprobante Retención
				If ExistBlock("M486PECR")
					cXML	:= ExecBlock("M486PECR",.F.,.F.,{cFilTab, aFact[nI,2], aFact[nI,5], aFact[nI,6], aFact[nI,3], aFact[nI,4]})
				Else
					cFilTab:= xFilial("SFE")
					cXML	:= M486CERXML(cFilTab, aFact[nI,2], aFact[nI,5], aFact[nI,6], aFact[nI,3], aFact[nI,4], aFact[nI,1])
				EndIf
			ElseIf cMod $ "S6" //  | Guía Remisión
				If alltrim(cEspecie) == "RNF" .and. ExistBlock("M486PEGR")
					cXML	:= ExecBlock("M486PEGR",.F.,.F.,{cFilTab, aFact[nI,1],aFact[nI,2], aFact[nI,3], aFact[nI,4],cEspecie})
				Else
					cXML	:= M486RNFXML(cFilTab, aFact[nI,1],aFact[nI,2], aFact[nI,3], aFact[nI,4],,)
				EndIf
			ElseIf lComBaja //  | Comunicado de Baja
				//Obtener consecutivo del parámetro
				aIdCBaja := StrTokArr(cIdCB, "-")
				If Len(aIdCBaja) < 3 .Or. aIdCBaja[2] <> dtos(dFecGen)
					cIdXMLCB := IIf(lResDRev,"RR-","RA-") + dtos(dFecGen) + "-1"
				Else
					cIdXMLCB := IIf(lResDRev,"RR-","RA-") + dtos(dFecGen) + "-" + Alltrim(Str(Val(aIdCBaja[3]) + 1))
				EndIf
				PutMv(cParamB,cIdXMLCB)
				cXML	:= M486CBXML(cFilTab, aFact[nI,1], aFact[nI,4], aFact[nI,3], aFact[nI,2], cEspecie, cMotivoCB, cIdXMLCB)
			EndIf

			If Empty(cXML) // Si no se generá el XML se regsitra un error
				aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], STR0115}) // "No se pudo generar XML."
			Else // Se realiza envío a TSS
				oWS:cIDDOC 	:= IIf(lComBaja .or. lResDia , Alltrim(cIdXMLCB) + "/" + Alltrim(aFact[nI,1] + aFact[nI,2]), aFact[nI,1] + aFact[nI,2])
				oWS:cXML	:= Encode64(cXML)

				If lComBaja .Or. lResDia
					cNomXML := Alltrim(SM0->M0_CGC) + "-" + cIdXMLCB
				Else
					cNomXML := alltrim(aFact[nI,1]) + alltrim(aFact[nI,2]) + alltrim(cEspecie)
				EndIf

				//  Se escribe XML
				fWriteXml(cXml, cNomXML + ".xml", ,lComBaja,lResDia)

				//Consulta documento
				If oWs:ConsultaDoc()
					If oWS:OWSCONSULTADOCRESULT:nStatus == 6 
							lConDoc := .T.
							cXML := oWS:OWSCONSULTADOCRESULT:cXML
							If !Empty(cXML)
								cNameFile := alltrim(Substr((oWS:OWSCONSULTADOCRESULT:cIdDoc),1,3)) + alltrim(substr((oWS:OWSCONSULTADOCRESULT:cIdDoc),4)) + alltrim(cEspecie)
								fWriteXml(cXml,cNameFile + "-ok.xml",.T.)
								If oWS:OWSCONSULTADOCRESULT:cCodigo == "0"
									aAdd(aTrans, {cFilTab,aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4]})
									aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0055}) // "Transmisión a TSS exitosa"
								EndIf
							EndIf
					EndIF
				EndIf

				If !lConDoc
					If oWS:SendDoc()
						If oWS:oWSSendDocResult:lHasError
							aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],oWS:oWSSendDocResult:OwsError:cCodigo + "-" + oWS:oWSSendDocResult:OwsError:cDescrip   })
							If oWS:oWSSendDocResult:OwsError:cCodigo == "006"
								aAdd(aDocAct, {aFact[nI,6],aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],"","1"})
							EndIf
						Else
							If (lComBaja .or. lResDia) .And. !lResDRev
								RecLock(cAliasSF,.F.)
									(cAliasSF)->&(cPreSF + "IDCBAJA") := cIdXMLCB
								(cAliasSF)->(MsUnlock())
							EndIf
							aAdd(aTrans, {cFilTab,aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4]})
							//Borrado de registros en protheus por comunicado de baja - PERU
							If lComBaja .or. lResDia
								If oWs:ConsultaDoc()
								If lResDRev
									M486ASTASFE(cFilSFE, aFact[nI][2], oWS:OWSCONSULTADOCRESULT:nStatus,oWS:OWSCONSULTADOCRESULT:dFechaAut,cIdXMLCB)
								Else
									M486ACTSTA(cEspecie, oWS:OWSCONSULTADOCRESULT:nStatus, oWS:OWSCONSULTADOCRESULT:dFechaAut, aFact[nI,1], aFact[nI,2])
								EndIF
									If oWS:OWSCONSULTADOCRESULT:nStatus == 6
										lOk := .T.
									EndIf
								Else
									MsgAlert(STR0196) //"Error Documento de comunicado de baja no consultado."
									lOk := .F.
								EndIf

								If lOk
									//Baja automatica
									If lResDRev
										M486BAJACR(aFact[nI][2])
									Else
										M486AUTOCB(cEspecie)
									EndIf
									aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], IIf(lResDia,STR0344 + oWS:OWSCONSULTADOCRESULT:cMensaje,IIf(_lCerRet, STR0367 + oWS:OWSCONSULTADOCRESULT:cMensaje,STR0197))}) //"Resumen Diario ante la SUNAT y anulado del documento con éxito." ## "Resumen Diario de Reversión ante la SUNAT y borrado de Comprobante de Retención realizado con éxito." ## "Comunicado de baja ante la SUNAT y anulado del documento con éxito."
								EndIf
							Else
								aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0055}) // "Transmisión a TSS exitosa"
							EndIf
						EndIF
					Else
						aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4], GetWSCError()})
					EndIf
				EndIf
			EndIF
		Next nI
	Else
		MsgAlert(STR0102) // "Imposible Realizar Transmisión de Documentos a TSS"
		lRet := .F.
	EndIF
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} fReadfile
Lee archivo XML
@type function
@author mayra.camargo
@since 06/07/2017
@version 1.0
@param cPath, character, (Ruta del archivo)
@param cFile, character, (Nombre del archivo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static function fReadfile(cPath,cFile)
	Local cTexto     := ""
	Local cNewFile   := ""
	Local cExt       := ""
	Local nHandle    := 0
	Local nTamanho   := 0

	cNewFile := &(cPath) + cFile
	nHandle := FOpen(cNewFile)
	If nHandle > 0
		nTamanho := Fseek(nHandle,0,FS_END)
		FSeek(nHandle,0,FS_SET)
		FRead(nHandle,@cTexto,nTamanho)
		FClose(nHandle)
	EndIf
Return cTexto

/*/{Protheus.doc} ${M486GENLOG}
Genera log de la transmisión electrónica
@type
@author mayra.camargo
@since 06/07/2017
@version 1.0
@param aErrores Array con errores presentados durante transmision
@param nFact Total de documentos procesados
@param nTrans Total de Documentos Transmitidos
@param aNoEnv Arreglo de documentos no enviado por Email al Transmitir (Colombia)
@return
@example
(examples)
@see (links_or_references)
/*/
function M486GENLOG(aErrores,nFact,nTrans,aNoEnv)
	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
	Local cTamanho	:= "M"
	Local cTitulo	:= STR0046 //"LOG  de DIOT"
	Local nX		:= 1
	Local aNewLog	:= {}
	Local nTamLog	:= 0
	Local aLogTitle	:={IIF(!_lCerRet,STR0045,STR0026),STR0051}   // "Documento       Serie  Proveedor  Tienda  Detalle"
	Local aLog		:={}
	Local aLogRes	:= {}
	Local aLognEnv  := {}
	Local cDetalle 	:= ""
	Local nPos 		:= 1
	Local nC		:= 0
	Local cDocto	:= ""
	Local cDocTmp	:= ""
	Local cInfoDoc	:= ""
	Local nCanEnv   := 0
	Local cAvisoE   := ""
	Local lCpoRec   := AI0->(ColumnPos("AI0_RECE")) > 0

	Private wCabec1 := STR0050 + cTipDocto //"Tipo de Documento Transmitido: "

	Default aNoEnv := {}

	nCanEnv := Len(aNoEnv)

	If cPaisLoc <> "COL"
		ASORT(aErrores, , , { | x,y | x[1] + x[2]  > y[1] + y[2] } )
	EndIf
	For nx:=1 to len(aErrores)
        cDetalle := ""
      	nPos := 1
		cDocto	:=	aErrores[nx,2] + space(14 - len(aErrores[nx,2]))+ sPace(2) + ; // Documento
	    			aErrores[nx,1] + Space(4) +; // Serie
	    			aErrores[nx,3] + Space(4)+;  // Proveedor
	    			aErrores[nx,4] + space(4) // Tienda

		cInfoDoc := IIf(cDocTmp == cDocto, Space(Len(cDocto)), cDocto)

		If len(aErrores[nx,5]) > 84
			For nC:= 1 to (len(aErrores[nx,5])/84) + 1
				cDetalle := SUBSTR(aErrores[nx,5],nPos,84)
				nPos += 84
				aadd(aLog,cInfoDoc + cDetalle ) // Detalle
			Next nC
		Else
			aadd(aLog,cInfoDoc + aErrores[nx,5] ) // Detalle
		EndIF

		cDocTmp := cDocto
	next

	aAdd(aLogRes," ")
	aadd(aLogRes,STR0024 + Transform(nFact,"9999"))				// "Documentos procesados:   "
	aadd(aLogRes,STR0058 + Transform(nFact- nTrans,"9999"))		// "Documentos con error:    "
	aadd(aLogRes,STR0057 + Transform(nTrans,"9999"))			// "Documentos transmitidos: "
	If nCanEnv > 0
		aadd(aLogRes,STR0407 + Transform(nCanEnv,"9999"))	// "Documentos no enviados por email:"
	EndIf

	aNewLog		:= aClone(aLog)
	nTamLog		:= Len( aLog)
	aLog := {}

	If !Empty( aNewLog )
		aAdd( aLog , aClone( aNewLog ) )
	Endif

	aAdd(aLog, aLogRes)

	If nCanEnv > 0
		cAvisoE := StrTran(STR0408, '###',RTrim(FWX3Titulo("A1_EMAIL"))) //"Documentos no envíados por mail, campo ### (A1_EMAIL)"
		If lCpoRec //Email especial para Recepción (Definido ante la DIAN)
			cAvisoE += StrTran(STR0409, '###',RTrim(FWX3Titulo("AI0_RECE"))) //" o campo ### (AI0_RECE)",
		EndIf
		cAvisoE += STR0410 + IIf(lCpoRec,"s","") //" del Cliente vacío"
		aadd(aLogTitle,cAvisoE)
		aadd(aLognEnv,)
		For nX := 1 To nCanEnv
			aadd(aLognEnv,STR0346 + Alltrim(aNoEnv[nX][1]) + "-" + Alltrim(aNoEnv[nX][2]) + " / " + STR0411 + Alltrim(aNoEnv[nX][3]) + "-" + Alltrim(aNoEnv[nX][4])) //"Documento:" //"Cliente:"
		Next nX
		aAdd(aLog, aLognEnv)  
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
	MsAguarde( { ||fMakeLog( aLog ,aLogTitle , , .t. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},STR0015) // "Generando Log de errores..."
Return

/*/{Protheus.doc} M486UPDSFE
Atcualiza tabla SFE
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param aComRet, array, Array con los comprobantes de retención a actualizar
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486UPDSFE(aComRet)
	Local nI := 0
	Default aComRet := {}

	For nI := 1 to len(aComRet)
		M486SFE(aComRet[nI,3],"1",,,.F.)
	Next nI
Return .T.

/*/{Protheus.doc} M486GETCR
Obtiene los datos de los comprobantes de retención para consulta en TSS
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@param cSerieC, character, (Serie a 4 caracteres
@param cFacIn, character, (Comporbante inicial)
@param cFacFi, character, (Comprobante final)
@return aRet, array con los comprobantes dentro del rango especificado para consultar a TSS
@example
(examples)
@see (links_or_references)
/*/
Static function M486GETCR(cSerieC,cFacIn,cFacFi)
	Local cTempF 	:= getNextAlias()
	Local nCount 	:= 0
	Local nCont  	:= 0
	Local cXml  	:= ""
	Local aRet 	 	:= {}
	Local lTSS	 	:= SuperGetMV("MV_PROVFE",,"") == "TSS" .Or. Empty(SuperGetMV("MV_PROVFE",,""))
	Local cSts   	:= ""
	Local aError	:={}
	Local cNomXML 	:= ""
	Local cCodDoc 	:= ""
	Local cRec      := ""
	Local lCpoIDRes := SFE->(ColumnPos("FE_GRPTRIB")) > 0 

	If cPaisLoc == "EQU"
		BEGINSQL ALIAS cTempF
				SELECT DISTINCT SFE.FE_FILIAL FILIAL, SFE.FE_NROCERT DOC,SFE.FE_FORNECE CLIFOR, SFE.FE_LOJA TIENDA
				FROM %Table:SFE% SFE
				WHERE SFE.FE_FILIAL=%exp:xFilial("SFE")%
					AND SFE.FE_NROCERT BETWEEN %exp:cFacIn% AND %exp:cFacFi%
					AND SFE.%notDel%
		ENDSQL
	Else
		cCond	:= "% SFE.FE_FILIAL = '" + xFilial("SFE") + "'"
		cCond	+= " AND SFE.FE_NROCERT >= '" + cFacIn + "'"
		cCond	+= " AND SFE.FE_NROCERT <= '" + cFacFi + "'"
		cCond	+= " AND SFE.FE_SERIE2 = '" + cSerieC + "'"
		cCond	+= " AND SFE.FE_STATUS <> ' '"
		cCond	+= " AND SFE.D_E_L_E_T_  = ' ' "
		If lCpoIDRes
			cCond	+= " AND SFE.FE_GRPTRIB= ' ' "
		EndIf
		cCond += " %"
		BEGINSQL ALIAS cTempF
				SELECT SFE.FE_FILIAL FILIAL, SFE.FE_NROCERT DOC,SFE.FE_FORNECE CLIFOR,SFE.FE_LOJA TIENDA,SFE.FE_NFISCAL DOCORI,SFE.FE_SERIE SERIE,
						SFE.FE_SERIE2 SERIE2, SFE.R_E_C_N_O_ RECNUM, SFE.FE_STATUS AS STATUS, SFE.FE_FECAUT AS FECAUT
				FROM %Table:SFE% SFE
				WHERE %exp:cCond%
		ENDSQL
	EndIf

	count to nCount
	lRet := nCount > 0
	(cTempF)->(dbGoTop())
	While (!(cTempF)->(EOF()))
		If cPaisLoc == "EQU"
			aAdd(aRet, {(cTempF)->FILIAL,"",(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA})
		Else
			If lTSS
				aAdd(aRet, {(cTempF)->FILIAL,(cTempF)->SERIE2,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA})
			Else
				If cPaisLoc == "PER" .and. cMVPROVFE $ "RSM"
					cCodDoc := getModelo(cModelo)
					cNomXML := Alltrim(SM0->M0_CGC) + "-" + cCodDoc + "-" + alltrim((cTempF)->SERIE2) + "-" +  STRZERO(VAL((cTempF)->DOC),8)
					M486CONSRSM(@aError,{(cTempF)->SERIE2,(cTempF)->DOC,(cTempF)->CLIFOR,(cTempF)->TIENDA},@aRet,cNomXML,(cTempF)->FILIAL)
					ActCertif(aRet,.f.)
				Else
					cSts := (cTempF)->STATUS
					cMes := STR0234 //"Transmitido"
					If cSts == "6"
						cMes := STR0235 //"Autorizado"
						cRec := STR0236 //"Distribuir o enviar a Cliente."
					ElseIf  cSts == "5"
						cMes :=  STR0237 //"Rechazado"
						cRec := STR0238 //"Corregir y reenviar. Revise CDR para observaciones."
					EndIf
					aAdd(aRet, {Val((cTempF)->STATUS),(cTempF)->SERIE2 + (cTempF)->DOC,IIf(cMVCFDIAM == "P",STR0036,STR0037),(cTempF)->FECAUT,TIME(),cMes,cRec}) //"1-Produccion" //"2-Homologacion"
				EndIf
			EndIf
		EndIf
		(cTempF)->(dbSkip())
	EndDo
	(cTempF)->(dbCloseArea())
Return aRet

/*/{Protheus.doc} M486IMPPDF
Función que detona funcionalidad para imprimir los documentos en PDF
@type function
@author mayra.camargo
@since 10/07/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486IMPPDF()
	If cPaisLoc == "PER"
		M486XMLPDF(cEspecie)
	ElseIf cPaisLoc == "COL"
		M486PDFCOL(cEspecie)
	ElseIf cPaisLoc == "PAR"
		M486PDFPAR(cEspecie)
	ElseIf cPaisLoc == "BOL"
		M486BLVPDF(cEspecie)
	EndIf
Return
/*/{Protheus.doc} fGetHost
Obtiene Host para envío API REST
@type
@author mayra.camargo
@since 11/07/2018
@version 1.0
@param cHost, caracter, URL de la API REST
@return cRet, cadena con Host
@example
(examples)
@see (links_or_references)
/*/
Static Function fGetHost(cHost)
	Local cRet := ""
	cHost := STRTRAN(cHost, "http://", "")
	cHost := STRTRAN(cHost, "https://", "")
	cHost := SUBSTR(cHost, 1,at("/",cHost))
	cRet := cHost
Return cRet

/*/{Protheus.doc} M486GERXML
Detona generación de XML
@type
@author mayra.camargo
@since 11/07/2018
@version 1.0
@param aFact, array, Array con los documentos de los cuales se generarán los XML
@param aError, array, Array con Errores
@return lRet, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486GERXML(aFact,aError)

	Local nI := 0
	Local lRet := .F.
	ProcRegua(len(aFact))
	For nI := 1 to len(aFact)
		IncProc()
		lRet := CFDGerXML(cEspecie,aFact[nI,3],aFact[nI,4],aFact[nI,2],aFact[nI,1],.F.)
		aFact[nI,7] := lRet
		If !lRet // Si No se generó XML, se agrega Error a Log
			aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0147  }) // "Error al Generar XML"
		EndIf
	Next nI
Return lRet

/*/{Protheus.doc} M486SENDXML
  Función que envía los documentos a TSS
  @type
  @author mayra.camargo
  @since 11/07/2018
  @version 1.0
  @param aFact, array, Array con Documentos a Enviar
  @param aError, array, Array con Errores en generación o Trasmisión
  @param cUrl, character, URL DE API REST para envío de doucmentos a TSS
  @param aTrans, array, Array que gaurda los documentos exitosamente enviados a TSS
  @return ${return}, ${return_description}
  @example
  (examples)
  @see (links_or_references)
  /*/

Static Function M486SENDXML(aFact,aError,cUrl,aTrans)
	Local lRet := .T.
	Local nI := 0
	Local cXMLFile := ""
	Local cNameXML := ""
	Local cPref		:= ALLTRIM(cEspecie)
	Local cFact		:= ""
	Local cDocs 	:= GetNewPar("MV_CFDDOCS","")
	Local cJson		:= ""
	Local cFile		:= ""
	Local oObj		:= Nil
	Local oRestClient := Nil
	Local aHeader 		:= {}
	Local cHost 	:= fGetHost(cUrl)
	Local cUri		:= ""
	Local nPosLoc 	:= 0
	Local cIdEnt	:= GetNewPar("MV_COMPID","")
	Local cAmb		:= GetNewPar('MV_CFDIAMB',"")
	Local cDocKey	:= ""


	// Aquí va el consumo de la API REST para ennvío de documentos
	aAdd(aHeader,"Content-Type: application/json")
	aAdd(aHeader,"Host: " + cHost )

	cPref := IIF(cPref == "NF" , "f" , IIF(cPref == "NCC" , "c" , IIF(cPref == "NDC", "d" , "f" ) ) )
	//Carga XML en el arreglo
	For nI:= 1 to len(aFact)
		oRestClient 	:= FWRest():New(cUrl)
		oRestClient:setPath("/colombia/v1/emission/invoices")

		cFact:= M486XHEX(ALLTRIM( substr( aFact[nI,2] , 4 , Len(aFact[nI,2]) - 3 ) ),10)
		cNameXML := &(cDocs) + Lower('face') + '_' + cPref + PADR( Alltrim(SM0->M0_CGC) , 10 , "0" ) + cFact + '.xml'
		cXMLFile := FsLoadTXT(cNameXML,.F.)
		If !Empty(cXMLFile)
			cXMLFile := Encode64(cXMLFile)
			cJson := '{ '
			cJson += 	'"companyId":"' + cIdEnt + '",'
			cJson += 	'"country":"CO" ,'
			cJson += 	'"ambient":"' + cAmb + '",'
      		cJson +=   '"id":"' + aFact[nI,6]+ aFact[nI,1]+ aFact[nI,2]+ aFact[nI,3]+ aFact[nI,4] + '",'
      		cJson +=   '"document":"'+cXMLFile +'"'
    		cJson += '}'

			// Realiza envío jSon Api REST TSS
			oRestClient:SetPostParams(cJson)
			If oRestClient:Post(aHeader)
				nPosLoc := aScan(oRestClient:oResponseH:aHeaderFields,{ |x,y| x[1] == "location"  })
				If nPosLoc > 0
					cUri := "http://" + strtran(oRestClient:oResponseH:aHeaderFields[nPosLoc,2],chr(13),"")
				Else
					cUri := ""
				EndIf

				If cUri <> ""
					// Una vez obtenido el URI para consulta, se debe realizar una petición para conocer el Procole del Documento
					oRestClient := FWRest():New(cURL)
				   	cUri := "/" + strtran(cUri, cURL, "")
					oRestClient:setPath(cUri)
				   	If oRestClient:get(aHeader)
				   		If FWJsonDeserialize(oRestClient:GetResult(),@oObj)
				   			If oObj:DocumentKey <> Nil
				   				cDocKey := oObj:DocumentKey
							Else
								cDocKey := STRTRAN(oObj:MESSAGE,"the document already exists for key ","")
							EndIf
							aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0055})
							aAdd(aTrans, {aFact[nI,6],aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4], cDocKey})
						EndIf
					Else
						aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0153 + oRestClient:GetLastError()  }) // "No se pudo realizar envío a TSS - "
					EndIf
				Else
					aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], STR0152}) // "No se pudo recuperar DocKey para Consulta "
				EndIf

			Else
				If oRestClient:oResponseH:cStatusCode <> "202"
					aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], STR0153 + oRestClient:GetLastError()  }) // "No se pudo realizar envío a TSS - "
				Else // El código 202 corresponde a documento aceptado

					nPosLoc := aScan(oRestClient:oResponseH:aHeaderFields,{ |x,y| x[1] == "location"  })
					If nPosLoc > 0
						cUri := "http://" + strtran(oRestClient:oResponseH:aHeaderFields[nPosLoc,2],chr(13),"")
					Else
						cUri := ""
					EndIf

					If cUri <> ""
						// Una vez obtenido el URI para consulta, se debe realizar una petición para conocer el Procole del Documento
						oRestClient := FWRest():New(cURL)
					   	cUri := "/" + strtran(cUri, cURL, "")
						oRestClient:setPath(cUri)
					   	If oRestClient:get(aHeader)
					   		If FWJsonDeserialize(oRestClient:GetResult(),@oObj)
					   			If oObj:DocumentKey <> Nil
					   				// Se obtiene Clave del Documento en TSS
					   				cDocKey := oObj:DocumentKey
								Else
									// Si ya fue enviado anteriormente, se obtiene el Dockey
									cDocKey := STRTRAN(oObj:MESSAGE,"the document already exists for key ","")

									// Se realiza PUT
									cJson := '{ '
									cJson +=   	' "document":"'+cXMLFile +'" '
						    		cJson += '}'
									// Deberá realizar PUT para actualizar XML en TSS ya que ya existe.
									oRestClient := FWRest():New(cURL)
									cUri := "/colombia/v1/emission/invoices/"+cDockey
									oRestClient:setPath(cUri)
									If !oRestClient:PUT(aHeader)
										If oRestClient:oResponseH:cStatusCode $ "201|202|400"
											aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0055})
											aAdd(aTrans, {aFact[nI,6],aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4], cDocKey})
										Else
											aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0153 + oRestClient:GetLastError()  }) // "No se pudo realizar envío a TSS - "
										EndIF
									Else
										aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0153 + oRestClient:GetLastError()  }) // "No se pudo realizar envío a TSS - "
									EndIf
								EndIf
							EndIf
						Else
							If oRestClient:oResponseH:cStatusCode $ "201|202"
								If FWJsonDeserialize(oRestClient:GetResult(),@oObj)
						   			If oObj:DocumentKey <> Nil
						   				// Se obtiene Clave del Documento en TSS
						   				cDocKey := oObj:DocumentKey
									Else
										// Si ya fue enviado anteriormente, se obtiene el Dockey
										cDocKey := STRTRAN(oObj:MESSAGE,"the document already exists for key ","")
									EndIf
									aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0055})
									aAdd(aTrans, {aFact[nI,6],aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4], cDocKey})
								EndIf
							Else
								aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0153 + oRestClient:GetLastError()  }) // "No se pudo realizar envío a TSS - "
							EndIf
						EndIf
					Else
						aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], STR0152}) // "No se pudo recuperar DocKey para Consulta "
					EndIf
				EndIf
			Endif
		Else
			aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],STR0151  }) // "Error al leer XML para envío"
		EndIf
		oRestClient := Nil
		oObj := Nil
	Next nI
	oRestClient := Nil
Return lRet

Static Function fGenObs(oXML)
	Local cRet     := ""
	Local nI       := 0
	Local nX       := 0
	Local cValFunc := ""
	Local cEnc	   := ""
	Default oXML   := Nil

	If oXML <> Nil
		cEnc += oXML:_NS3_CONSULTARESULTADOVALIDACIONDOCUMENTOSRESPUESTA:_NS3_DOCUMENTORECIBIDO:_NS3_DATOSBASICOSDOCUMENTO:_NS3_CUFE:TEXT + (chr(13)+chr(10))
		cEnc += oXML:_NS3_CONSULTARESULTADOVALIDACIONDOCUMENTOSRESPUESTA:_NS3_DOCUMENTORECIBIDO:_NS3_DATOSBASICOSDOCUMENTO:_NS3_DESCRIPCIONESTADO:TEXT + (chr(13)+chr(10))
		cEnc += oXML:_NS3_CONSULTARESULTADOVALIDACIONDOCUMENTOSRESPUESTA:_NS3_DOCUMENTORECIBIDO:_NS3_DATOSBASICOSDOCUMENTO:_NS3_EMISOR:TEXT + (chr(13)+chr(10))
		cEnc += oXML:_NS3_CONSULTARESULTADOVALIDACIONDOCUMENTOSRESPUESTA:_NS3_DOCUMENTORECIBIDO:_NS3_DATOSBASICOSDOCUMENTO:_NS3_ESTADODOCUMENTO:TEXT + (chr(13)+chr(10))
		cEnc += oXML:_NS3_CONSULTARESULTADOVALIDACIONDOCUMENTOSRESPUESTA:_NS3_DOCUMENTORECIBIDO:_NS3_DATOSBASICOSDOCUMENTO:_NS3_FECHAHORAEMISION:TEXT + (chr(13)+chr(10))
		cEnc += oXML:_NS3_CONSULTARESULTADOVALIDACIONDOCUMENTOSRESPUESTA:_NS3_DOCUMENTORECIBIDO:_NS3_DATOSBASICOSDOCUMENTO:_NS3_NUMERODOCUMENTO:TEXT + (chr(13)+chr(10))
		cEnc +=  (chr(13)+chr(10))
		cEnc += STR0164 +  (chr(13)+chr(10)) // "OBSERVACIONES: "
		For nI := 1 to len(oXML:_NS3_CONSULTARESULTADOVALIDACIONDOCUMENTOSRESPUESTA:_NS3_DOCUMENTORECIBIDO:_NS3_VERIFICACIONFUNCIONAL:_NS3_VERIFICACIONDOCUMENTO)
			cValFunc += oXML:_NS3_CONSULTARESULTADOVALIDACIONDOCUMENTOSRESPUESTA:_NS3_DOCUMENTORECIBIDO:_NS3_VERIFICACIONFUNCIONAL:_NS3_VERIFICACIONDOCUMENTO[nI]:_NS3_CODIGOVERIFUNC:TEXT  + " - "
			cValFunc += oXML:_NS3_CONSULTARESULTADOVALIDACIONDOCUMENTOSRESPUESTA:_NS3_DOCUMENTORECIBIDO:_NS3_VERIFICACIONFUNCIONAL:_NS3_VERIFICACIONDOCUMENTO[nI]:_NS3_DESCRIPCIONVERIFUNC:TEXT  + "-"
			cValFunc += oXML:_NS3_CONSULTARESULTADOVALIDACIONDOCUMENTOSRESPUESTA:_NS3_DOCUMENTORECIBIDO:_NS3_VERIFICACIONFUNCIONAL:_NS3_VERIFICACIONDOCUMENTO[nI]:_NS3_VERIFICACIONREALIZADA:TEXT  + (chr(13)+chr(10)) + (chr(13)+chr(10))
		Next nI
		cRet := cEnc + cValFunc
	EndIf

Return cRet

Static Function fVaidaParms()
Local cProvFE	:= ""
Local cURLWS    := SuperGetMV("MV_WSRTSS",,"")
Local cMsj		:= ""
Local lRet		:= .T.

If Empty(cProvFE:=SuperGetMV("MV_PROVFE",,""))
	cMsj += "MV_PROVFE - " + STR0167 + CRLF	// Identifica el Facturador Electrónico o el Proveedor Tecnológico
EndIf
If Empty(cURLWS)
	cMsj += "MV_WSRTSS - " + STR0240 + CRLF	// "Identifica la URL de los WS de The Factory HKA de fact. elctrónica Val. Previa"
EndIf

If (Empty(cProvFE) .Or. cProvFE == "TSS") .And. (Empty(SuperGetMV("MV_ID_SOFT",,"")) .Or. Empty(SuperGetMV("MV_ID_PWD",,"")))
	cMsj += STR0168 + CRLF
	cMsj += "MV_ID_SOFT - " + STR0169 + CRLF	// Identificador de la habilitación de software
	cMsj += "MV_ID_PWD - " + STR0170 + CRLF	// Password de la habilitación como software
EndIf

If (Empty(cProvFE) .Or. !(cProvFE == "TSS")) .And. (Empty(SuperGetMV("MV_TKN_EMP",,"")) .Or. Empty(SuperGetMV("MV_TKN_PAS",,"")))
	cMsj += STR0171 + CRLF
	cMsj += "MV_TKN_EMP - " + STR0172 + CRLF	// Token Empresa
	cMsj += "MV_TKN_PAS - " + STR0173 + CRLF	// Token Password
EndIf

If !Empty(cMsj)
	cMsj := STR0166 + CRLF + cMsj// Antes de transmitir facturas, debe configurar los parámetros necesarios.
	MsgStop( cMsj )
	lRet := .F.
Endif

Return lRet

/*/{Protheus.doc} M486SENDPT
  Función que envía los documentos a Proveedor Tecnológico
  @type
  @author luis.enriquez
  @since 01/08/2018
  @version 1.0
  @param aFact, array, Array con Documentos a Enviar
  @param aError, array, Array con Errores en generación o Trasmisión
  @param cUrl, character, URL DE API REST para envío de doucmentos a TSS
  @param aTrans, array, Array que gaurda los documentos exitosamente enviados a TSS
  @return ${return}, ${return_description}
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function M486SENDPT(aFact,aError,cUrl,aTrans,aNoEnv)
	Local lRet      := .T.
	Local nI        := 0
	Local cDocs 	:= GetNewPar("MV_CFDDOCS","")
	Local cPref		:= ALLTRIM(cEspecie)
	Local cFact		:= ""
	Local cAviso    := ""
	Local cError    := ""
	Local nX        := 0
	Local nY        := 0
	Local cTipoPer  := ""
	Local cResXML   := ""
	Local cDocXML   := ""
	Local cAmbiente := SUPERGETMV("MV_CFDIAMB",.F.,"2")
	Local oWS
	Local oWSDet
	Local oWSImpDet
	Local cInfoAd   := ""
	Local oWSCamposExt
	Local cMoedaOri		:= ""
	Local cTxMoeda		:= ""
	Local cTipoFE       := SuperGetMV("MV_TIPOFE",,"")
	Local cCodSta       := ""
	Local cCUFE         := ""
	Local nLenVlDian	:= 0
	Local nTamAError	:= 0
	Local lDocSopor		:= cPaisLoc=="COL" .AND. nTDTras == 6
	Local lNotaAjus		:= cPaisLoc=="COL" .AND. (nTDTras == 8 .OR. nTDTras == 9) //NCP Ajuste
	Local lNoEnv        := .F.
	Local oObj          := Nil //Objeto de Grupo de Preguntas
	Local aX1Pre        := {}	
	Local lMailAut      := .F.
	Local cFilSA1       := xFilial("SA1")
	Local cFilAI0       := xFilial("AI0")
	
	Private cMoeDoc		:= ""

	oObj := FWSX1Util():New()
	oObj:AddGroup("MATA486")
	oObj:SearchGroup()
	aX1Pre := oObj:GetGroup("MATA486")

	If Len(aX1Pre[2]) >= 6 //Si existe pregunta de Envío de email automático durante transmisión
		lMailAut := MV_PAR06 == 1
	End

	dbSelectArea("SF1")
	dbSetOrder(1)	// F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

	dbSelectArea("SF2")
	dbSetOrder(1)	// F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

	cPref := IIf(cPref == "NF" .or. lDocSopor, "f" , IIF(cPref == "NCC" , "c" , IIF(cPref == "NDC", "d" , IIF(lNotaAjus, "n", "f") ) ) )

	If cPref $ "f|n" //Factura de Venta //Nota Ajuste 
		aOpcDoc := {"_FE_INVOICE","_FE_INVOICELINE","_CBC_INVOICEDQUANTITY","_FE_ITEM","_FE_PRICE","_FE_LEGALMONETARYTOTAL"}
	ElseIf cPref == "c" //Nota de Credito
		aOpcDoc := {"_FE_CREDITNOTE","_CAC_CREDITNOTELINE","_CBC_CREDITEDQUANTITY","_CAC_ITEM","_CAC_PRICE","_CAC_LEGALMONETARYTOTAL"}
	ElseIf cPref == "d" //Nota de Debito
		aOpcDoc := {"_FE_DEBITNOTE","_CAC_DEBITNOTELINE","_CBC_DEBITEDQUANTITY","_CAC_ITEM","_CAC_PRICE","_CAC_REQUESTEDMONETARYTOTAL"}
	EndIf

	//Carga XML en el arreglo
	For nI:= 1 to len(aFact)
		cFact   := M486XHEX(ALLTRIM( substr( aFact[nI,2] , 4 , Len(aFact[nI,2]) - 3 ) ),10)
		cDocXML := Lower('face') + '_' + cPref + PADR( Alltrim(SM0->M0_CGC) , 10 , "0" ) + cFact

		If cTipoFE == "1" //Facturación Electrónica Validación - Previa
			oWS := M486XMLHKA(cPref, aFact, nI, @aError, lMailAut, @lNoEnv, cFilSA1, cFilAI0)
		Else //Facturación Electrónica Validación - Posterior
			cNameXML := &(cDocs) + Lower('face') + '_' + cPref + PADR( Alltrim(SM0->M0_CGC) , 10 , "0" ) + cFact + '.xml'

			oXML := XmlParserFile( cNameXML, "_", @cAviso,@cError )

			If oXML <> Nil
				cTipoPer := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_CBC_ADDITIONALACCOUNTID:TEXT")
				cMoeDoc  :=	&("oXml:" + aOpcDoc[1] + ":_CBC_DOCUMENTCURRENCYCODE:TEXT")

				If cAmbiente == "2"
					oWS := WSNFECol():NEW()
				EndIf
				oWS:ctokenEmpresa  := SuperGetMV("MV_TKN_EMP",,"") // Token empresa
				oWS:ctokenPassword := SuperGetMV("MV_TKN_PAS",,"") // Token password
				oWS:cadjuntos      := "0"

				//Factura_General
				oWS:oWSfactura:cconsecutivoDocumento := &("oXml:" + aOpcDoc[1] + ":_CBC_ID:TEXT")
				If cPref $ "c|d"
					If ValType(&("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE")) == "A"
						For nX := 1 To Len(&("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE"))
							oWS:oWSfactura:cconsecutivoDocumentoModificado := &("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE[" + Str(nX) + "]:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ID:TEXT")
							oWS:oWSfactura:cfechaEmisionDocumentoModificado := &("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE[" + Str(nX) + "]:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ISSUEDATE:TEXT") + " " + ;
																				&("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE[" + Str(nX) + "]:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ISSUETIME:TEXT")
							oWS:oWSfactura:cmotivoNota := &("oXml:" + aOpcDoc[1] + ":_CAC_DISCREPANCYRESPONSE:_CBC_RESPONSECODE:TEXT")
							oWS:oWSfactura:cuuidDocumentoModificado := &("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE[" + Str(nX) + "]:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_UUID:TEXT")
						Next nX
					Else
						oWS:oWSfactura:cconsecutivoDocumentoModificado := &("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ID:TEXT")
						oWS:oWSfactura:cfechaEmisionDocumentoModificado := &("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ISSUEDATE:TEXT") + " " + ;
						                                             &("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ISSUETIME:TEXT")
						oWS:oWSfactura:cmotivoNota := &("oXml:" + aOpcDoc[1] + ":_CAC_DISCREPANCYRESPONSE:_CBC_RESPONSECODE:TEXT")
						oWS:oWSfactura:cuuidDocumentoModificado := &("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_UUID:TEXT")
					EndIf
				EndIf

				oWS:oWSfactura:cestadoPago := "3"
				oWS:oWSfactura:cfechaEmision := &("oXml:" + aOpcDoc[1] + ":_CBC_ISSUEDATE:TEXT") + " " + &("oXml:" + aOpcDoc[1] + ":_CBC_ISSUETIME:TEXT")
				oWS:oWSfactura:cfechaVencimiento := &("oXml:" + aOpcDoc[1] + ":_CAC_PAYMENTTERMS:_CAC_SETTLEMENTPERIOD:_CBC_ENDDATE:TEXT") + " " + &("oXml:" + aOpcDoc[1] + ":_CBC_ISSUETIME:TEXT")
				If XmlChildEx(&("oXml:" + aOpcDoc[1]), "_CAC_ADDITIONALITEMIDENTIFICATION") <> Nil
					oWS:oWSfactura:cicoterms := &("oXml:" + aOpcDoc[1] + ":_CAC_ADDITIONALITEMIDENTIFICATION:_CBC_ID:TEXT")
				Endif
				oWS:oWSfactura:cimporteTotal := &("oXml:" + aOpcDoc[1] + ":_FE_LEGALMONETARYTOTAL:_CBC_PAYABLEAMOUNT:TEXT")
				oWS:oWSfactura:cmoneda       := &("oXml:" + aOpcDoc[1] + ":_CBC_DOCUMENTCURRENCYCODE:TEXT")
				oWS:oWSfactura:crangoNumeracion := &("oXml:" + aOpcDoc[1] + ":_EXT_UBLEXTENSIONS:_EXT_UBLEXTENSION[1]:_EXT_EXTENSIONCONTENT:_STS_DIANEXTENSIONS:_STS_INVOICECONTROL:_STS_AUTHORIZEDINVOICES:_STS_PREFIX:TEXT") + "-" + ;
				                                   Alltrim(Str(Val(&("oXml:" + aOpcDoc[1] + ":_EXT_UBLEXTENSIONS:_EXT_UBLEXTENSION[1]:_EXT_EXTENSIONCONTENT:_STS_DIANEXTENSIONS:_STS_INVOICECONTROL:_STS_AUTHORIZEDINVOICES:_STS_FROM:TEXT"))))
				oWS:oWSfactura:ctipoDocumento := PadL(&("oXml:" + aOpcDoc[1] + ":_CBC_INVOICETYPECODE:TEXT"),2,"0")
				If XmlChildEx(&("oXml:" + aOpcDoc[1] + ":_FE_LEGALMONETARYTOTAL"), "_CBC_ALLOWANCETOTALAMOUNT" ) <> Nil
					oWS:oWSfactura:ctotalDescuentos := &("oXml:" + aOpcDoc[1] + ":_FE_LEGALMONETARYTOTAL:_CBC_ALLOWANCETOTALAMOUNT:TEXT")
				EndIf
				oWS:oWSfactura:ctotalSinImpuestos := &("oXml:" + aOpcDoc[1] + ":_FE_LEGALMONETARYTOTAL:_CBC_LINEEXTENSIONAMOUNT:TEXT")

				//Cliente
				oWS:oWSfactura:oWScliente := Service_Cliente():NEW()
				If cTipoPer == "2"
					oWS:oWSfactura:oWScliente:cnombreRazonSocial := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PERSON:_CBC_FIRSTNAME:TEXT")
					oWS:oWSfactura:oWScliente:csegundoNombre     := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PERSON:_CBC_MIDDLENAME:TEXT")
					oWS:oWSfactura:oWScliente:capellido := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PERSON:_CBC_FAMILYNAME:TEXT")
				Else
					oWS:oWSfactura:oWScliente:cnombreRazonSocial := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYLEGALENTITY:_CBC_REGISTRATIONNAME:TEXT")
				EndIf
				oWS:oWSfactura:oWScliente:cnotificar    := "NO"
				oWS:oWSfactura:oWScliente:cciudad       := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PHYSICALLOCATION:_FE_ADDRESS:_CBC_CITYNAME:TEXT")
				oWS:oWSfactura:oWScliente:cdepartamento := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PHYSICALLOCATION:_FE_ADDRESS:_CBC_DEPARTMENT:TEXT")
				oWS:oWSfactura:oWScliente:cdireccion    := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PHYSICALLOCATION:_FE_ADDRESS:_CAC_ADDRESSLINE:_CBC_LINE:TEXT")
				oWS:oWSfactura:oWScliente:cnumeroDocumento   := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_ID:TEXT")
				oWS:oWSfactura:oWScliente:cpais         := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PHYSICALLOCATION:_FE_ADDRESS:_CAC_COUNTRY:_CBC_IDENTIFICATIONCODE:TEXT")
				oWS:oWSfactura:oWScliente:cregimen      := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CBC_TAXLEVELCODE:TEXT")
				oWS:oWSfactura:oWScliente:csubDivision  := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PHYSICALLOCATION:_FE_ADDRESS:_CBC_CITYSUBDIVISIONNAME:TEXT")
				oWS:oWSfactura:oWScliente:ctipoIdentificacion := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_ID:_SCHEMEID:TEXT")
				oWS:oWSfactura:oWScliente:ctipoPersona  := cTipoPer

				cInfoAd := &("oXml:" + aOpcDoc[1] + ":_CBC_NOTE:TEXT")

				//Impuestos generales
				If XmlChildEx(&("oXml:" + aOpcDoc[1]), "_FE_TAXTOTAL") <> Nil
					oWS:oWSfactura:oWSimpuestosGenerales := Service_ArrayOfFacturaImpuestos():NEW()
					If ValType(&("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL")) == "A" //Varios impuestos
						For nX := 1 To Len(&("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL"))
							cCodImp := Alltrim( &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL[" + Str(nX) + "]:_FE_TAXSUBTOTAL:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT") )
							If !EsAutoReten(cCodImp)
								oWSImpDet := Service_FACTURAIMPUESTOS():New()
								oWSImpDet:ccodigoTOTALImp := Substr( cCodImp, 1, 2)
								If Len(cCodImp) > 2
									oWSImpDet:ccontrolInterno := Substr( cCodImp, 3)
								EndIf
								oWSImpDet:cbaseImponibleTOTALImp := &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL[" + Str(nX) + "]:_FE_TAXSUBTOTAL:_CBC_TAXABLEAMOUNT:TEXT")
								oWSImpDet:cporcentajeTOTALImp := &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL[" + Str(nX) + "]:_FE_TAXSUBTOTAL:_CBC_PERCENT:TEXT")
								oWSImpDet:cvalorTOTALImp := &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL[" + Str(nX) + "]:_FE_TAXSUBTOTAL:_CBC_TAXAMOUNT:TEXT")
								aAdd(oWS:oWSfactura:oWSimpuestosGenerales:oWSFacturaImpuestos,oWSImpDet)
							Else
								cInfoAd += IIf(Empty(cInfoAd), "", "<br>") + "Cod: " + cCodImp + ;
										"<br>Descripción: " + ObtColSAT("S005",PadR(cCodImp,3),1,3,4,80) + ;
										"<br>Base Impuesto: " + &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL[" + Str(nX) + "]:_FE_TAXSUBTOTAL:_CBC_TAXABLEAMOUNT:TEXT") + ;
										"<br>Porcentaje: " + &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL[" + Str(nX) + "]:_FE_TAXSUBTOTAL:_CBC_PERCENT:TEXT") + ;
										"<br>Valor Impuesto: " + &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL[" + Str(nX) + "]:_FE_TAXSUBTOTAL:_CBC_TAXAMOUNT:TEXT")
							Endif
						Next nX
					Else //Un solo impuesto
						cCodImp := Alltrim( &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL:_FE_TAXSUBTOTAL:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT") )
						If !EsAutoReten(cCodImp)
							oWSImpDet := Service_FACTURAIMPUESTOS():New()
							oWSImpDet:ccodigoTOTALImp := Substr( cCodImp, 1, 2)
							If Len(cCodImp) > 2
								oWSImpDet:ccontrolInterno := Substr( cCodImp, 3)
							EndIf
							oWSImpDet:cbaseImponibleTOTALImp := &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL:_FE_TAXSUBTOTAL:_CBC_TAXABLEAMOUNT:TEXT")
							oWSImpDet:cporcentajeTOTALImp := &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL:_FE_TAXSUBTOTAL:_CBC_PERCENT:TEXT")
							oWSImpDet:cvalorTOTALImp := &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL:_FE_TAXSUBTOTAL:_CBC_TAXAMOUNT:TEXT")
							aAdd(oWS:oWSfactura:oWSimpuestosGenerales:oWSFacturaImpuestos,oWSImpDet)
						Else
							cInfoAd += IIf(Empty(cInfoAd), "", "<br>") + "Cod: " + cCodImp + ;
									"<br>Descripción: " + ObtColSAT("S005",PadR(cCodImp,3),1,3,4,80) + ;
									"<br>Base Impuesto: " + &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL:_FE_TAXSUBTOTAL:_CBC_TAXABLEAMOUNT:TEXT") + ;
									"<br>Porcentaje: " + &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL:_FE_TAXSUBTOTAL:_CBC_PERCENT:TEXT") + ;
									"<br>Valor Impuesto: " + &("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL:_FE_TAXSUBTOTAL:_CBC_TAXAMOUNT:TEXT")
						Endif
					EndIf
				EndIf

				// Información adicional: Motivo NDC/NCC, auto-retenciones
				If !Empty(cInfoAd)
					oWS:oWSfactura:cinformacionAdicional := cInfoAd
				Endif

				//Detalle
				oWS:oWSfactura:oWSdetalleDeFactura  := Service_ArrayOfFacturaDetalle():NEW()

				If Valtype(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2])) == "A" //Varios items
					For nX := 1 To Len(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2]))
						oWSDet := Service_FacturaDetalle():NEW()
					  	oWSDet:ccantidadUnidades := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:" + aOpcDoc[3] + ":TEXT")
					  	oWSDet:ccodigoProducto   := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CBC_ID:TEXT")
					  	oWSDet:cdescripcion      := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:" + aOpcDoc[4] + ":_CBC_DESCRIPTION:TEXT")
					  	If XmlChildEx(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]"), "_CAC_ALLOWANCECHARGE" ) <> Nil
					  		oWSDet:cdescuento        := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_ALLOWANCECHARGE:_CBC_AMOUNT:TEXT")
					  	EndIf
					  	If XmlChildEx(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]"), "_CAC_PRICINGREFERENCE") <> Nil
					  		oWSDet:cprecioTotal	:= Alltrim(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE[1]:_CBC_PRICEAMOUNT:TEXT"))
					  		oWSDet:cprecioTotalSinImpuestos	:= Alltrim(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE[2]:_CBC_PRICEAMOUNT:TEXT"))
					  	EndIf
					  	oWSDet:cprecioVentaUnitario := Alltrim(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:" + aOpcDoc[5] + ":_CBC_PRICEAMOUNT:TEXT"))
					  	oWSDet:cunidadMedida := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:" + aOpcDoc[3] + ":_UNITCODE:TEXT")

					 	AAdd(oWS:oWSfactura:oWSdetalleDeFactura:oWSFacturaDetalle, oWSDet)

					 	//Impuestos Detalle
					 	If XmlChildEx(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]"), "_CAC_TAXTOTAL") <> Nil
						 	oWS:oWSfactura:oWSdetalleDeFactura:oWSFacturaDetalle[nX]:oWSimpuestosDetalles := Service_ArrayOfFacturaImpuestos():NEW()
						 	If ValType(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_TAXTOTAL")) == "A"
						 		For nY := 1 To Len(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_TAXTOTAL"))
								 	oWSImpDet := Service_FACTURAIMPUESTOS():New()
								 	oWSImpDet:cbaseImponibleTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_TAXTOTAL[" + Str(nY) + "]:_CAC_TAXSUBTOTAL:_CBC_TAXABLEAMOUNT:TEXT")
								 	cCodImp := Alltrim( &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_TAXTOTAL[" + Str(nY) + "]:_CAC_TAXSUBTOTAL:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT") )
									oWSImpDet:ccodigoTOTALImp := Substr( cCodImp, 1, 2)
									If Len(cCodImp) > 2
										oWSImpDet:ccontrolInterno := Substr( cCodImp, 3)
									EndIf
								 	oWSImpDet:cporcentajeTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_TAXTOTAL[" + Str(nY) + "]:_CAC_TAXSUBTOTAL:_CBC_PERCENT:TEXT")
								 	oWSImpDet:cvalorTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_TAXTOTAL[" + Str(nY) + "]:_CAC_TAXSUBTOTAL:_CBC_TAXAMOUNT:TEXT")
								 	AAdd( oWS:oWSfactura:oWSdetalleDeFactura:oWSFacturaDetalle[nX]:oWSimpuestosDetalles:oWSFacturaImpuestos, oWSImpDet)
							 	Next nY
						 	Else
							 	oWSImpDet := Service_FACTURAIMPUESTOS():New()
							 	oWSImpDet:cbaseImponibleTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL:_CBC_TAXABLEAMOUNT:TEXT")
							 	cCodImp := Alltrim( &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT") )
								oWSImpDet:ccodigoTOTALImp := Substr( cCodImp, 1, 2)
								If Len(cCodImp) > 2
									oWSImpDet:ccontrolInterno := Substr( cCodImp, 3)
								EndIf
							 	oWSImpDet:cporcentajeTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL:_CBC_PERCENT:TEXT")
							 	oWSImpDet:cvalorTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL:_CBC_TAXAMOUNT:TEXT")
							 	AAdd( oWS:oWSfactura:oWSdetalleDeFactura:oWSFacturaDetalle[nX]:oWSimpuestosDetalles:oWSFacturaImpuestos, oWSImpDet)
						 	EndIf
					 	EndIf
					Next nX

				Else //Un solo item
					oWSDet := Service_FacturaDetalle():NEW()
				  	oWSDet:ccantidadUnidades := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":" + aOpcDoc[3] + ":TEXT")
				  	oWSDet:ccodigoProducto   := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CBC_ID:TEXT")
				  	oWSDet:cdescripcion      := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":" + aOpcDoc[4] + ":_CBC_DESCRIPTION:TEXT")
				  	If XmlChildEx(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2]), "_CAC_ALLOWANCECHARGE" ) <> Nil
				  		oWSDet:cdescuento        := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_ALLOWANCECHARGE:_CBC_AMOUNT:TEXT")
				  	EndIf

				  	If XmlChildEx(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2]), "_CAC_PRICINGREFERENCE") <> Nil
					  	oWSDet:cprecioTotal	:= Alltrim(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE[1]:_CBC_PRICEAMOUNT:TEXT"))
					  	oWSDet:cprecioTotalSinImpuestos	:= Alltrim(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE[2]:_CBC_PRICEAMOUNT:TEXT"))
				  	EndIf
				  	oWSDet:cprecioVentaUnitario := Alltrim(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":" + aOpcDoc[5] + ":_CBC_PRICEAMOUNT:TEXT"))
				  	oWSDet:cunidadMedida := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":" + aOpcDoc[3] + ":_UNITCODE:TEXT")

				 	AAdd(oWS:oWSfactura:oWSdetalleDeFactura:oWSFacturaDetalle, oWSDet)

				 	//Impuestos Detalle
				 	If XmlChildEx(&("oXml:" + aOpcDoc[1]), "_CAC_TAXTOTAL") <> Nil
					 	oWS:oWSfactura:oWSdetalleDeFactura:oWSFacturaDetalle[1]:oWSimpuestosDetalles := Service_ArrayOfFacturaImpuestos():NEW()
					 	If ValType(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_TAXTOTAL")) == "A"
					 		For nY := 1 To Len(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_TAXTOTAL"))
							 	oWSImpDet := Service_FACTURAIMPUESTOS():New()
							 	oWSImpDet:cbaseImponibleTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_TAXTOTAL[" + Str(nY) + "]:_CAC_TAXSUBTOTAL:_CBC_TAXABLEAMOUNT:TEXT")
							 	cCodImp := Alltrim( &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_TAXTOTAL[" + Str(nY) + "]:_CAC_TAXSUBTOTAL:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT") )
								oWSImpDet:ccodigoTOTALImp := Substr( cCodImp, 1, 2)
								If Len(cCodImp) > 2
									oWSImpDet:ccontrolInterno := Substr( cCodImp, 3)
								EndIf
							 	oWSImpDet:cporcentajeTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_TAXTOTAL[" + Str(nY) + "]:_CAC_TAXSUBTOTAL:_CBC_PERCENT:TEXT")
							 	oWSImpDet:cvalorTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_TAXTOTAL[" + Str(nY) + "]:_CAC_TAXSUBTOTAL:_CBC_TAXAMOUNT:TEXT")
							 	AAdd( oWS:oWSfactura:oWSdetalleDeFactura:oWSFacturaDetalle[1]:oWSimpuestosDetalles:oWSFacturaImpuestos, oWSImpDet)
					 		Next nY
					 	Else
						 	oWSImpDet := Service_FACTURAIMPUESTOS():New()
						 	oWSImpDet:cbaseImponibleTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL:_CBC_TAXABLEAMOUNT:TEXT")
						 	cCodImp := Alltrim( &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT") )
							oWSImpDet:ccodigoTOTALImp := Substr( cCodImp, 1, 2)
							If Len(cCodImp) > 2
								oWSImpDet:ccontrolInterno := Substr( cCodImp, 3)
							EndIf
						 	oWSImpDet:cporcentajeTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL:_CBC_PERCENT:TEXT")
						 	oWSImpDet:cvalorTOTALImp := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + ":_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL:_CBC_TAXAMOUNT:TEXT")
						 	AAdd( oWS:oWSfactura:oWSdetalleDeFactura:oWSFacturaDetalle[1]:oWSimpuestosDetalles:oWSFacturaImpuestos, oWSImpDet)
					 	EndIf
					 EndIf
				EndIf
			Else
				aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],STR0225}) //"XML mal generado, revise el script correspondiente (FATECOL.INI, FATSCOL.INI, FATSECOL.INI)."
			EndIf

		EndIf

		If oWS <> Nil

			If oWS:Enviar()
				If !oWS:oWSEnviarResult:lesValidoDian
					If oWS:oWSEnviarResult:nCodigo == 201 //Documento autorizado
						aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],Str(oWS:oWSEnviarResult:nCodigo) + "-" + oWS:oWSEnviarResult:cmensaje})
						aAdd(aTrans, {aFact[nI,6],aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],"","4"})
					Else
						If oWS:oWSEnviarResult:nCodigo == 114 //Documento transmitido previamente
							aAdd(aDocAct, {aFact[nI,6],aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],"","1"})
						EndIf
						aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],Alltrim(Str(oWS:oWSEnviarResult:nCodigo)) + " - " + Alltrim(oWS:oWSEnviarResult:cmensaje)})
						For nY := 1 to Len(oWS:oWSEnviarResult:oWSmensajesValidacion:cstring)
							If nY == 1
								aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],oWS:oWSEnviarResult:oWSmensajesValidacion:cstring[nY]})
								nTamAError := Len(aError)
							Else
								aError[nTamAError][5] := AllTrim(aError[nTamAError][5]) + " " + AllTrim( oWS:oWSEnviarResult:oWSmensajesValidacion:cstring[nY] )
							EndIf
						Next nY
						
						//Impresion de validaciones DIAN
						nLenVlDian := Len(oWS:oWSEnviarResult:oWSReglasValidacionDian:cString) //Nodo de Reglas de Validacion DIAN
						If nLenVlDian > 0
							aAdd(aError, {"", "", "", "", cCRLF + STR0329}) //"Reglas validación DIAN:"
							For nY := 1 To nLenVlDian
								If nY == 1
									aAdd(aError, {aFact[nI,1], aFact[nI,2], aFact[nI,3], aFact[nI,4], oWS:oWSEnviarResult:oWSReglasValidacionDian:cString[nY]}) //Detalle de las Reglas
									nTamAError := Len(aError)
								Else
									aError[nTamAError][5] := AllTrim(aError[nTamAError][5]) + " " + AllTrim( oWS:oWSEnviarResult:oWSReglasValidacionDian:cString[nY] )
								EndIf
							Next nY
							aAdd(aError, {"", "", "", "", ""}) //Agrega espacio al finalizar impresion de validaciones
						EndIf
						
						If !Empty(oWS:oWSEnviarResult:cXML)
							cResXML := Decode64(oWS:oWSEnviarResult:cXML)
							If !Empty(cResXML)
								fWriteXml(cResXML,cDocXML + "_Error"+ ".xml",.T.)
							EndIf
						EndIf
					EndIf
				Else
					If !Empty(oWS:oWSEnviarResult:cconsecutivoDocumento)
						cResXML :=  Decode64(oWS:oWSEnviarResult:cXML)
						If !Empty(cResXML)
							fWriteXml(cResXML,cDocXML + ".xml",.T.)
						EndIf
						If oWS:oWSEnviarResult:nCodigo == 200 //Transmisión Exitosa
							If lMailAut .And. lNoEnv //Documento no envíado por Email del cliente vacío						
								aAdd(aNoEnv, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4]})
							EndIf
						EndIf
						aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],Str(oWS:oWSEnviarResult:nCodigo) + "-" + oWS:oWSEnviarResult:cmensaje})
						cCodSta := IIf(oWS:oWSEnviarResult:nCodigo == 201, "4", "6")	//Código de estatus (Protheus)
						cCUFE   := IIf(oWS:oWSEnviarResult:nCodigo == 201, "", oWS:oWSEnviarResult:ccufe) //CUFE
						aAdd(aTrans, {aFact[nI,6],aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],cCUFE,cCodSta})
					Else
						aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4],Str(oWS:oWSEnviarResult:nCodigo) + "-" + oWS:oWSEnviarResult:cmensaje})
					EndIf
				EndIf
			Else
				aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],STR0224}) //"Sin respuesta del servicio web."
			EndIf
		EndIf
	Next nI
Return lRet

/*/{Protheus.doc} M486CExt
//TODO Descrição auto-gerada.
@author arodriguez
@since 15/02/2019
@version 1.0
@return aCamposExt, array, Arreglo de sub-arreglos de campos extensible sin etiquetas, solo valores
@param aFact, array, datos de la factura a transmitir
@param aCamposExt, array, campos extensibles existentes
@type function
/*/
Function M486CExt( aFact , aCamposExt )
	Local aM486CExt		:= {}
	Local nX			:= 0
	Local lOK			:= .F.

	/* Respuesta esperada del PE:
		{{"","","","","",""}, {"","","","","",""}, ...}

		Nodos y atributos a generar:
		<!--Zero or more repetitions:-->
		<ser:Extras>
			<!--Optional: c(100) Etiqueta para PDF -->
			<ser:controlInterno1></ser:controlInterno1>
			<!--Optional: x() índice de campo repetible y asociado -->
			<ser:controlInterno2></ser:controlInterno2>
			<!--Optional: x() Código campo extensible-->
			<ser:nombre></ser:nombre>
			<!--Optional: n(1) 0=No en PDF, 1=Incluir en PDF-->
			<ser:pdf></ser:pdf>
			<!--Optional: x() Valor campo-->
			<ser:valor></ser:valor>
			<!--Optional: n(1) 0=No en XML, 1=Incluir en XML-->
			<ser:xml></ser:xml>
		</ser:Extras>
	*/

	aM486CExt := ExecBlock("M486CEXT", .F., .F., {aFact,cEspecie} )

	If Len(aM486CExt) > 0 .And. ValType(aM486CExt) == "A"
		For nX := 1 to Len(aM486CExt)
			lOK := .F.
			If Len(aM486CExt[nX]) == 6 .And. ValType(aM486CExt[nX]) == "A"
				aEval( aM486CExt , {|x,y| IIf(ValType(x[y]) == "U", aM486CExt[nX,y]:="", ) })
				IIf(ValType(aM486CExt[nX,4]) == "N", aM486CExt[nX,4]:=Alltrim(Str(aM486CExt[nX,4])), )
				IIf(ValType(aM486CExt[nX,6]) == "N", aM486CExt[nX,6]:=Alltrim(Str(aM486CExt[nX,6])), )
				If !Empty(aM486CExt[nX][3]) .And. (aM486CExt[nX][4] $ "0|1") .And. (aM486CExt[nX][6] $ "0|1")
					lOK := .T.
				EndIf
			EndIf
			If lOK
				aAdd( aCamposExt , aM486CExt[nX] )
			Else
				Conout( STR0193 + aFact[1] + aFact[2] + " - " + aFact[3] + "/" + aFact[4] + " #Item " + Str(nX) ) // "PE M486CEXT regresa valores incorrectos para campos extensibles; factura, cliente: "
			EndIf
		Next nX

	Else
		Conout( STR0193 + aFact[1] + aFact[2] + " - " + aFact[3] + "/" + aFact[4] ) // "PE M486CEXT regresa valores incorrectos para campos extensibles; factura, cliente: "

	EndIf

Return aCamposExt

/*/{Protheus.doc} M486CBAJA
  Función que comunica baja de documentos electrónicos a la SUNAT.
  @type
  @author luis.enriquez
  @since 08/02/2019
  @version 1.0
  @param aFact, array, Array con Documentos a Enviar
  @param aError, array, Array con Errores en generación o Trasmisión
  @param cUrl, character, URL DE API REST para envío de doucmentos a TSS
  @param aTrans, array, Array que gaurda los documentos exitosamente enviados a TSS
  @return ${return}, ${return_description}
  @example
  (examples)
  @see (links_or_references)
  /*/
Function M486CBAJA(lResDia)
	Local cPergBC     := IIf(_lCerRet,"MATA486I","MATA486G")
	Local aDocs       := {}
	Local aArea       := GetArea()
	Local aTamaho     := MsAdvSize()
	Local aIndx	      := IIf(_lCerRet,{OemToAnsi(STR0368)},{OemToAnsi(STR0369)})   //"Comprobante de Retención + Serie 2" //"Factura + Serie"
	Local cIndx	      := aIndx[1]
	Local nOpc        := 0
	Local cBusca      := Space(TAMSX3("F2_LOJA")[1]+TAMSX3("F2_CLIENTE")[1]+TAMSX3("F2_DOC")[1]+TAMSX3("F2_SERIE")[1])
	Local oOkS        := LoadBitmap(GetResources(),"br_verde")
	Local oNoS        := LoadBitmap(GetResources(),"br_vermelho")
	Local oOk	      := LoadBitmap(GetResources(),"LBOK")
	Local oNo	      := LoadBitmap(GetResources(),"LBNO")
	Local oDlgFat     := Nil
	Local bSet15	  := {|| M486VALGEN(oLbx1,oDlgFat,@nOpc,aDocs)}
	Local bSet24	  := {|| nOpc:=0, oDlgFat:End()}
	Local aButtons    := {{"S4WB011N", {|| LeyendaCB()}, "Leyenda", "Leyenda"}} //"Leyenda"
	Local bDialogInit := { || EnchoiceBar(oDlgFat,bSet15,bSet24,nil,aButtons)}
	Local nX          := 0
	Local nI          := 0
	Local nPosLbx     := 0
	Local aFact       := {}
	Local aError      := {}
	Local aTrans      := {}
	Local cUrl		  := GetNewPar("MV_WSRTSS","")
	Local nTotDoc     := 0
	Local oWs         := Nil
	Local aEnviados   := {}
	Local lEnvia      := .T.
	Local oBoton      := Nil
	Local oBusca      := Nil
	Local oMarTodos   := Nil
	Local oDesTodos   := Nil
	Local oInvSelec   := Nil
	Local cMsgLog     := ""
	Local lTSS	      := SuperGetMV("MV_PROVFE",,"") == "TSS" .Or. Empty(SuperGetMV("MV_PROVFE",,""))
	Local cIdEnt      := IIf(lTSS, GetIdEnt(), "")
	Local cRutaSMR    := &("GetClientDir()")
	Local cNomXML     := ""
	Local cPath	      := &(SuperGetMV("MV_CFDDOCS",,""))
	Local cError	  := ""
	Local cWarning	  := ""
	Local cCodErro    := ""
    Local cDescErro   := ""
    Local dDataTim	  := CTOD(" / / ")
    Local cTimeTim	  := ""
    Local cStatusOSE  := ""
	Local cTmpCad	  := ""
	Local cTitPan     := STR0370 //"Transmisión de "
	Local aTitCol     := {} //Titulos columnas del Browse
	Local cAviso      := ""
	Local cTitAviso   := ""  
	Local bLineCB     :=  {||}
	Local cValidCpo   := ""
	Local cCRLF		  := (chr(13) + chr(10))

	Private aCabsSF1  := {}
	Private aCabsSF2  := {}
	Private aItensSD1 := {}
	Private aItensSD2 := {}
	Private dFecLim   := Date()-7
	Private cTipo     := ""
	Private cSerComB  := ""
	Private cDocIniCB := ""
	Private cDocFinCB := ""
	Private cMotivoCB := ""

	Default lResDia := .F.

	If _lCerRet
		cPath += "\ResumenDiario\"
		cTitPan += STR0366 //"Resumen Diario de Reversión"
		aTitCol := 	{OemToAnsi(""),; //Status
			OemToAnsi(""),;      //Check
			OemToAnsi(STR0201),; //Serie 2
			OemToAnsi(STR0044),; //Comprobante de Retención 
			OemToAnsi(STR0202),; //Fecha de emisión	
			OemToAnsi(STR0203),; //Fecha de autorización (SUNAT)
			OemToAnsi(STR0084),; //Tienda
			OemToAnsi(STR0083),; //Proveedor
			OemToAnsi(STR0205)}	 //Nombre
		bLineCB := {|| {If(aDocs[oLbx1:nAt,1],oOkS,oNoS),If(aDocs[oLbx1:nAt,2],oOk,oNo),aDocs[oLbx1:nAt,4],;
							aDocs[oLbx1:nAt,5],aDocs[oLbx1:nAt,6],aDocs[oLbx1:nAt,7],aDocs[oLbx1:nAt,8],aDocs[oLbx1:nAt,9],aDocs[oLbx1:nAt,10]}}
		If SFE->(ColumnPos("FE_GRPTRIB")) == 0 
			cValidCpo += StrTran(STR0372,'###',"FE_GRPTRIB") + cCRLF //"El campo ### debe existir en el diccionario de Datos"
		EndIf
		If SFE->(ColumnPos("FE_DTESTOR")) == 0 
			cValidCpo += StrTran(STR0372,'###',"FE_DTESTOR") + cCRLF //"El campo ### debe existir en el diccionario de Datos"
		EndIf
		If !Empty(cValidCpo)
			MsgAlert(STR0373  + cCRLF + cCRLF + cValidCpo) //"Para proceso de Resumen Diario de Reversión:"
			Return
		EndIf
	Else
		// Obtener arreglos de campos de SF1/SF2/SD1/SD2
		M486SX3(@aCabsSF1, @aCabsSF2, @aItensSD1, @aItensSD2)

		If nTDTras = 1 .Or. nTDTras = 4 //Factura/Boleta de Venta
			cTipo := "N"
		ElseIf nTDTras = 2 //Nota de Débito
			cTipo := "D"
		ElseIf nTDTras = 3 //Nota de Crédito
			cTipo := "C"
		EndIf
		aTitCol := 	{OemToAnsi(""), ; //Status
			OemToAnsi(""),;      //Check
			OemToAnsi(STR0200),; //Serie
			OemToAnsi(STR0201),; //Serie 2
			OemToAnsi(STR0060),; //Documento 
			OemToAnsi(STR0202),; //Fecha de emisión	
			OemToAnsi(STR0203),; //Fecha de autorización (SUNAT)
			OemToAnsi(STR0084),; //Tienda
			OemToAnsi(STR0204),; //Cliente
			OemToAnsi(STR0205)}	 //Nombre
		bLineCB := {|| {If(aDocs[oLbx1:nAt,1],oOkS,oNoS),If(aDocs[oLbx1:nAt,2],oOk,oNo),aDocs[oLbx1:nAt,3],aDocs[oLbx1:nAt,4],;
							aDocs[oLbx1:nAt,5],aDocs[oLbx1:nAt,6],aDocs[oLbx1:nAt,7],aDocs[oLbx1:nAt,8],aDocs[oLbx1:nAt,9],aDocs[oLbx1:nAt,10]}}
		If lResDia
			cPath += "\ResumenDiario\"
			cTitPan += STR0343 //"Resumen Diario"
		Else
			cPath += "\ComunicadoBaja\"
			cTitPan += STR0198 //"Comunicado de Baja"	
		EndIf
	EndIf

	If Pergunte(cPergBC,.T.)
		cSerComB  := MV_PAR01
		cDocIniCB := MV_PAR02
		cDocFinCB := MV_PAR03
		cMotivoCB := MV_PAR04

		If lResDia
			cTmpCad := cCadastro
			cCadastro := (STR0307 + cTipDocto + " - " + Upper(STR0343)) //"Documentos Electrónicos - " ## "Resumen Diario"
		EndIf

		aDocs := M486SFCB(cSerComB, cDocIniCB, cDocFinCB, cMotivoCB, lResDia)

		If Len(aDocs) == 0
			If _lCerRet
				cAviso    := STR0371 //"No se encontraron Comprobantes de Retención para generación de Resumen Diario de Reversión. Revise los parámetros de selección."
				cTitAviso := STR0044 //"Comprobante de Retención"
			Else
				cAviso    :=  STR0199 //"No se encontraron documentos para el comunicado de baja. Revise los parámetros de selección."
				cTitAviso := STR0198  //"Comunicado de Baja"
			EndIf
			If !Empty(cAviso)
				Aviso(cTitAviso, cAviso, {STR0066}) //Ok
			EndIf
			Return Nil
		Else
			DEFINE MSDIALOG oDlgFat FROM aTamaho[1],aTamaho[2] TO aTamaho[6],aTamaho[5] TITLE cTitPan PIXEL

			@ c(30),c(05) MSCOMBOBOX oIndx VAR cIndx ITEMS aIndx SIZE c(90),c(10) PIXEL OF oDlgFat
			@ c(30),c(98) BUTTON oBoton PROMPT STR0206 SIZE c(35),c(10) ;//"Buscar"
					 ACTION (oLbx1:nAT := M486BUSCVE(oLbx1,aDocs,cBusca,oIndx:nAT), ;
							oLbx1:bLine := {|| {If(aDocs[oLbx1:nAt,1],oOkS,oNoS),If(aDocs[oLbx1:nAt,2],oOk,oNo),aDocs[oLbx1:nAt,3],aDocs[oLbx1:nAt,4],;
							aDocs[oLbx1:nAt,5],aDocs[oLbx1:nAt,6],aDocs[oLbx1:nAt,7],aDocs[oLbx1:nAt,8],aDocs[oLbx1:nAt,9],aDocs[oLbx1:nAt,10]}},;
							oLbx1:SetFocus()) PIXEL OF oDlgFat
			@ c(42),c(05)  MSGET oBusca VAR cBusca PICTURE "@!" SIZE c(130),c(10) PIXEL  OF oDlgFat
			@ c(58),c(05)  LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER aTitCol;
			          SIZE aTamaho[3] - 25,IIf(aTamaho[6]>700,(aTamaho[4] * .775)-25, IIf(aTamaho[6]<500,aTamaho[4] * .6,aTamaho[4] * .7)) OF oDlgFat ; //aTamaho[6] * .875
			          PIXEL ON DBLCLICK ( IIf(aDocs[oLbx1:nAt,1] .And. aDocs[oLbx1:nAt,7] >= dFecLim ;
			          .And. (IIf(!_lCerRet,IIf(aDocs[oLbx1:nAt,11]$"NF|NDC",MaCanDelF2("SF2",aDocs[oLbx1:nAt,13],,,,aDocs[oLbx1:nAt,14]),LxMaCanDelF1(aDocs[oLbx1:nAt,13],,,,,,.F.,aDocs[oLbx1:nAt,14])),.T.)), ;
			          (M486MarcaI(oLbx1,@aDocs,@oDlgFat),oLbx1:nColPos:= 1,oLbx1:Refresh()),M486VLDEDO(aDocs[oLbx1:nAt,3],aDocs[oLbx1:nAt,5],aDocs[oLbx1:nAt,12],aDocs[oLbx1:nAt,7]) ) ) NOSCROLL
			oLbx1:aHeaders := aClone(aTitCol)
			oLbx1:SetArray(aDocs)
			oLbx1:bLine := bLineCB
			oLbx1:Refresh()

			@ aTamaho[4] * .953,c(005) BUTTON oMarTodos PROMPT STR0207 SIZE c(45),c(10) ACTION M486MarcaI( oLbx1 , @aDocs , @oDlgFat , "M" ) PIXEL OF oDlgFat //aTamaho[4] * .92
			@ aTamaho[4] * .953,c(055) BUTTON oDesTodos PROMPT STR0208 SIZE c(45),c(10) ACTION M486MarcaI( oLbx1 , @aDocs , @oDlgFat , "D" ) PIXEL OF oDlgFat
			@ aTamaho[4] * .953,c(110) BUTTON oInvSelec PROMPT STR0209 SIZE c(45),c(10) ACTION M486MarcaI( oLbx1 , @aDocs , @oDlgFat , "I" ) PIXEL OF oDlgFat

			ACTIVATE MSDIALOG oDlgFat ON INIT Eval(bDialogInit) CENTERED
			
			If lResDia
				cCadastro := cTmpCad
			EndIf

			CursorWait()

			If  nOpc == 1
				nTotDoc := Len(aDocs)
				For nX := 1 To Len(aDocs)
					If aDocs[nX][2] //Seleccionado
						aAdd(aFact,{IIf(_lCerRet,aDocs[nX][4],aDocs[nX][3]), aDocs[nX][5], aDocs[nX][8], aDocs[nX][9], aDocs[nX][6], aDocs[nX][15], .F., ""})
						If !Empty(aDocs[nX][16]) //Contiene ID de comunicado de abaja
							If lTSS
								oWS := WSTSSWSSUNAT():NEW()
								oWs:cUSERTOKEN  := "TOTVS"
								oWs:cIDENT		:= cIdEnt
								oWS:cMODELO 	:= "SE"
								oWS:_URL		:= cURL + "/TSSWSSUNAT.apw"
								oWS:cIdDoc      := Alltrim(aDocs[nX,16]) + "/" + aDocs[nX,3] + aDocs[nX,5]
								If oWs:ConsultaDoc()
									If oWS:OWSCONSULTADOCRESULT:nStatus == 6 //Comunicado de baja autorizado por la SUNAT
										M486ACTSTA(cEspecie, oWS:OWSCONSULTADOCRESULT:nStatus, oWS:OWSCONSULTADOCRESULT:dFechaAut, aDocs[nX][3], aDocs[nX][5])
										lEnvia := .F.
										M486AUTOCB(cEspecie)
										aAdd(aTrans, {aDocs[nX,15],aDocs[nX,3], aDocs[nX,5], aDocs[nX,8], aDocs[nX,9]})
										aAdd(aError, {aDocs[nX,3], aDocs[nX,5], aDocs[nX,8], aDocs[nX,9], STR0197}) // "Comunicado de baja a la SUNAT y borrado de documento con éxito."
									ElseIf oWS:OWSCONSULTADOCRESULT:nStatus == 7 //Comunicado de baja pendiente de procesamiento
										aAdd(aError, {aDocs[nX,3], aDocs[nX,5], aDocs[nX,8], aDocs[nX,9], STR0218}) //"El comunicado de baja se encuentra en estatus pendiente de procesamiento."
									EndIf
								Else
									MsgAlert(STR0196) //"Error Documento de comunicado de baja no consultado."
									lEnvia := .F.
								EndIf
							Else //Proceso mediante OSE
								If cMVPROVFE $ "TCI"
									lEnvia := .F.
									cNomXML := "CB_" + Alltrim(SM0->M0_CGC) + "-" + Alltrim(aDocs[nX,3]) + Alltrim(aDocs[nX,5])
								    cParametros := cRutaSMR + cNomXML + ".xml "  			// Archivo xml
									cParametros += cRutaSMR + " "							// Ruta Destino Respuesta
									cParametros += cMVCFDIAM + " "							// Ambiente D = Desarrollo P= Producción
									cParametros += "X "							            // ruta del certificado digital
									cParametros += "X "							            // Password del Certificado
									cParametros += "SE "							        // Modelo
									cParametros += "TCI "							        // Proveedor Envio
									cParametros += "C " 									// Opción C=Opción consulta
									cParametros += Alltrim(aDocs[nX,16]) + " " 				// Ticket para comunicado de baja
									cParametros += cMVCFDIUS + " "							// Usuario autenticación con OSE
									cParametros += cMVCFDICO        						// Contraseña autenticación con OSE

									If cMVCFDIAM $ "D"
										CONOUT("PARAMETROS CONSULTA: " + cParametros)
									EndIf

									nOpc := WAITRUN( cRutaSMR + cMVCFDIPA + ".exe " + cParametros, 0 )	// Se ejecuta exe

									If nOpc == 0
										If File(cRutaSMR  + cNomXML + ".xml.out")
											CpyT2S(cRutaSMR  + cNomXML + ".xml.out" , cPath)
										EndIf
										// Procesar archivo out
										oXMLResp := XmlParserFile(EncodeUtf8(cPath + cNomXML +".xml.out"), "_", @cError, @cWarning )
										If oXMLResp <> Nil
											lHasError := "True" $ oXMLResp:_RESPONSE:_HASERROR:TEXT
											If lHasError // Si el .out reportó error
												cCodigo  := oXMLResp:_RESPONSE:_EXCEPTION:_CODE:TEXT
												cDescrip :=  oXMLResp:_RESPONSE:_EXCEPTION:_MESSAGE:TEXT
												lRet := .F.
												cError:=  cCodigo + "-" + cDescrip
											Else
												// Si no hay error y el codigo de aceptación es 0
												cCodigo := ALLTRIM(oXMLResp:_RESPONSE:_MESSAGE:_CODE:TEXT)
												If cCodigo == "0"
													ConOut("Sin Error")
													cCodErro	:= oXMLResp:_RESPONSE:_MESSAGE:_CODE:TEXT
													cDescErro	:= oXMLResp:_RESPONSE:_MESSAGE:_DESCRIPTION:TEXT
													dDataTim	:= STod(StrTran(ALLTRIM(oXMLResp:_RESPONSE:_MESSAGE:_DATE:TEXT),"-",""))
													cTimeTim	:= oXMLResp:_RESPONSE:_MESSAGE:_TIME:TEXT
													cStatus     := Alltrim(oXMLResp:_RESPONSE:_MESSAGE:_STATUS:TEXT)
													cStatusOSE := IIf(cStatus == "098",4,IIf(cStatus == "0",6,0))
													M486ACTSTA(cEspecie, cStatusOSE, dDataTim)
													If cStatusOSE == 6
														//Baja automatica
														M486AUTOCB(cEspecie)
														cError += STR0197 //"Comunicado de baja ante la SUNAT y anulado del documento con éxito."
													EndIf
													cError += cDescErro	// "Transmisión a TSS exitosa"
													aAdd(aTrans, {aDocs[nX,15],aDocs[nX,3], aDocs[nX,5], aDocs[nX,8], aDocs[nX,9]})
												Else
													cCodErro:= oXMLResp:_RESPONSE:_MESSAGE:_CODE:TEXT
													cStatus := oXMLResp:_RESPONSE:_MESSAGE:_STATUS:TEXT
													If Empty(oXMLResp:_RESPONSE:_MESSAGE:_DESCRIPTION:TEXT)
														cDescErro := STR0231 //"Error, verificar Anexo 2: Listado de Errores de la SUNAT."
													Else
														cDescErro	:= oXMLResp:_RESPONSE:_MESSAGE:_DESCRIPTION:TEXT
													EndIf

													// Se actualizan array de estatus de documentos
													aAdd(aDocs, {5,;
																	 aFact[nI,1]+aFact[nI,2],;
													 				 IIf(cMVCFDIAM == "P",STR0036,STR0037),; //Produccion //Homologacion
																	 "",;
																	 "",;
																	 cDescErro,;
																	 ""})
													cError := cCodErro +" - "+ cDescErro
													lRet := .f.
												EndIf
												// Se envia CDR. archivo out y XML sellado al servidor
												// Copiar timbre al servidor
												CpyT2S(cRutaSMR  + cNomXML + ".xml" , cPath )
												CpyT2S(cRutaSMR  + "R-" + cNomXML + ".xml" , cPath )
												CpyT2S(cRutaSMR  + cNomXML + ".zip" , cPath )

												// Se eliminan archivos de la carpeta del smartclient
												Ferase( cRutaSMR  + cNomXML + ".out" )
												Ferase( cRutaSMR  + cNomXML + ".xml" )
												Ferase( cRutaSMR  + cNomXML + ".zip" )

											EndIf
										Else
											cError := STR0232  + cError //"006 - Imposible leer archivo .out, intente transmitir de nuevo el documento."
											lRet := .F.
										EndIf
										aAdd(aError, {aDocs[nX,3], aDocs[nX,5], aDocs[nX,8], aDocs[nX,9], cError})
									EndIf
								Else // rsm
									lEnvia := .F.
									cNomXML := alltrim(SM0->M0_CGC)+ "-" + alltrim(aDocs[nX,16])
									// Realizar consulta para obtener documentos.
				 					lRet := M486CONSRSM(@aError,aFact[len(aFact)],@aDocs,cNomXML,"",@aTrans,.t.,alltrim(aDocs[nX,16]))
								EndIf
							EndIf
						EndIf
						If lEnvia
							If lTSS
								Processa({|lEnd| lRet := M486SENDDOC(aFact, @aError, cUrl, @aTrans, "SE", IIF(lResDia,.F.,.T.),lResDia)}, STR0101) //"Transmitiendo Documentos..."
							ElseIf lResDia
								Processa({|lEnd| lRet := M486GENDOC({aFact[Len(aFact)]}, @aError, @aTrans, "SE", , .T.)},STR0101) //"Transmitiendo Documentos..."
							Else
								Processa({|lEnd| lRet := M486GENDOC({aFact[Len(aFact)]}, @aError, @aTrans, "SE", .T.)},STR0101) //"Transmitiendo Documentos..."
							EndIf
						Else
							aAdd(aEnviados, {aDocs[nX,15],aDocs[nX,1],aDocs[nX,2],aDocs[nX,3],aDocs[nX,4]})
						EndIf
					EndIf
				Next nX
			EndIf

			If Len(aError) > 0 .And. Len(aTrans) <> Len(aError)
				cMsgLog := STR0052 + cCRLF + STR0100 // "Ocurrieron inconvenientes al momento de la transmisión" // "¿Desea visualizar log de Transmisión?"
			ElseIf Len(aError) > 0 .And. Len(aTrans) == Len(aError)
			cMsgLog := STR0055 + cCRLF + STR0100// "Transmisión a TSS exitosa" // "¿Desea visualizar log de Transmisión?"
			ElseIf Len(aEnviados) > 0 .And. Len(aTrans) == 0
				cMsgLog := STR0210 + cCRLF + STR0100// "Los comunicados de baja no pueden ser enviados, ya están autorizados por la SUNAT." // "¿Desea visualizar log de Transmisión?"
			ElseIf Len(aEnviados) > 0 .And. Len(aTrans) > 0
				cMsgLog := STR0211 + cCRLF + STR0100// "Transmisión a TSS exitosa, con comunidados de baja existentes ya autorizados por la SUNAT." // "¿Desea visualizar log de Transmisión?"
			EndIf

			If !Empty(cMsgLog)
				If MsgYESNO(cMsgLog)
					M486GENLOG(aError, nTotDoc, Len(aTrans))
				EndIf
			EndIf

			DeleteObject(oOk)
			DeleteObject(oNo)
			DeleteObject(oOkS)
			DeleteObject(oNoS)

			CursorArrow()
			bFiltraBrw := {|| FilBrowse(cAliasB,@aIndArqE,@cFiltro) }
			Eval(bFiltraBrw)
			RestArea(aArea)
		EndIf
	EndIf
Return

/*/{Protheus.doc} M486SFCB
//Carga datos a ser mostrados para comunicado de baja.
@author Luis Enríquez
@since 20/02/2019
@version 1.0
@return Nil
@type function
/*/
Static Function M486SFCB(cSerie, cDocIni, cDocFin, cMotivo, lResDia)
	Local cAliasTmp := GetNextAlias()
	Local cEsp      := ""
	Local cCampos   := ""
	Local cTablas   := ""
	Local cCond     := ""
	Local cCondFB   := ""
	Local cOrder    := ""
	Local lGetDB    := AllTrim(Upper(TCGetDB())) == "ORACLE"  //.T. - Oracle, .F. - Otros manejadores
	Local aFacturas := {}
	Local nReg 		:= 0
	Local cRutina   := ""

	Default lResDia := .F.

	If nTDTras == 1 .Or. nTDTras == 2 .Or. nTDTras == 4 //Factura de Venta - Nota de Débito
		cRutina := "MATA467N|MATA460"
		If nTDTras == 1 .Or. nTDTras == 4 //Factura/Boleta de Venta
			cEsp := "NF"
			If lGetDB //Oracle
				cCondFB := IIf(nTDTras == 1, " AND SUBSTR(SF2.F2_SERIE2,1,1) = 'F'", " AND SUBSTR(SF2.F2_SERIE2,1,1) = 'B'")
			Else
				cCondFB := IIf(nTDTras == 1, " AND SUBSTRING(SF2.F2_SERIE2,1,1) = 'F'", " AND SUBSTRING(SF2.F2_SERIE2,1,1) = 'B'")
			EndIf
		ElseIf nTDTras == 2 // Nota Débito al Cliente
			cEsp := "NDC"
			cRutina := "MATA465N"
			If lGetDB //Oracle
				cCondFB := " AND SUBSTR(SF2.F2_SERIE2,1,1) = " + IIf(lResDia, "'B'", "'F'")
			Else
				cCondFB := " AND SUBSTRING(SF2.F2_SERIE2,1,1) = " + IIf(lResDia, "'B'", "'F'")
			EndIf
		EndIf
		cCampos	:= "% SF2.F2_FILIAL FILIAL, SF2.F2_CLIENTE CLIENTE, SF2.F2_LOJA LOJA, SF2.F2_DOC DOC, SF2.F2_SERIE SERIE, SF2.F2_SERIE2 SERIE2, SF2.F2_EMISSAO EMISSAO, "
		cCampos	+= "SF2.F2_FECAUT FECAUT, SA1.A1_NOME, SF2.F2_FLFTEX STATUS, SF2.F2_ESPECIE ESPECIE, SF2.R_E_C_N_O_ SFRECNO, F2_IDCBAJA IDCBAJA %"
		cTablas := "% " + RetSqlName("SF2") + " SF2, " + RetSqlName("SA1") + " SA1 %"
		cCond	:= "% SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
		cCond	+= " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
		cCond	+= " AND SF2.F2_CLIENTE = SA1.A1_COD"
		cCond	+= " AND SF2.F2_LOJA = SA1.A1_LOJA"
		cCond	+= " AND SF2.F2_ESPECIE = '" + cEsp + "'"
		cCond	+= " AND SF2.F2_SERIE = '" + cSerie + "'"
		cCond	+= " AND SF2.F2_DOC >= '" + cDocIni + "'"
		cCond	+= " AND SF2.F2_DOC <= '" + cDocFin + "'"

		If !Empty(cCondFB)
			cCond	+= cCondFB
		EndIf
		cCond	+= " AND SF2.D_E_L_E_T_  = ' ' "
		cCond	+= " AND SA1.D_E_L_E_T_  = ' ' %"
		cOrder 	:= "% SF2.F2_SERIE, SF2.F2_DOC %"
	ElseIf nTDTras == 3 //Nota de Crédito
		cEsp    := "NCC"
		cRutina := "MATA465N"
		cCampos	:= "% SF1.F1_FILIAL FILIAL, SF1.F1_FORNECE CLIENTE, SF1.F1_LOJA LOJA, SF1.F1_DOC DOC, SF1.F1_SERIE SERIE, SF1.F1_SERIE2 SERIE2, SF1.F1_EMISSAO EMISSAO, "
		cCampos	+= "SF1.F1_FECAUT FECAUT, SA1.A1_NOME, SF1.F1_FLFTEX STATUS, SF1.F1_ESPECIE ESPECIE, SF1.R_E_C_N_O_ SFRECNO, F1_IDCBAJA IDCBAJA  %"
		cTablas := "% " + RetSqlName("SF1") + " SF1, " + RetSqlName("SA1") + " SA1 %"
		cCond	:= "% SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
		cCond	+= " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
		cCond	+= " AND SF1.F1_FORNECE = SA1.A1_COD"
		cCond	+= " AND SF1.F1_LOJA = SA1.A1_LOJA"
		cCond	+= " AND SF1.F1_ESPECIE = '" + cEsp + "'"
		cCond	+= " AND SF1.F1_SERIE = '" + cSerie + "'"
		cCond	+= " AND SF1.F1_DOC >= '" + cDocIni + "'"
		cCond	+= " AND SF1.F1_DOC <= '" + cDocFin + "'"
		If lGetDB //Oracle
			cCond += " AND SUBSTR(SF1.F1_SERIE2,1,1) = "  + IIf(lResDia, "'B'", "'F'")
		Else
			cCond += " AND SUBSTRING(SF1.F1_SERIE2,1,1) = " + IIf(lResDia, "'B'", "'F'")
		EndIf
		If !Empty(cCondFB)
			cCond	+= cCondFB
		EndIf
		cCond	+= " AND SF1.D_E_L_E_T_  = ' ' "
		cCond	+= " AND SA1.D_E_L_E_T_  = ' ' %"
		cOrder 	:= "% SF1.F1_SERIE, SF1.F1_DOC %"
	EndIf

	//Certificados de Retención
	If _lCerRet
		cTablas := "% " + RetSqlName("SFE") + " SFE, " + RetSqlName("SA2") + " SA2 %"
		cCampos	:= "% SFE.FE_FILIAL FILIAL, SFE.FE_SERIE2 SERIE2, SFE.FE_NROCERT DOC, SFE.FE_EMISSAO EMISSAO, SFE.FE_FECAUT FECAUT, SFE.FE_FORNECE CLIENTE, SFE.FE_LOJA LOJA, SFE.FE_STATUS STATUS, SA2.A2_NOME A2_NOME, SFE.FE_GRPTRIB IDCBAJA %"
		cCond	:= "% SFE.FE_FILIAL = '" + xFilial("SFE") + "'"
		cCond	+= " AND SA2.A2_FILIAL = '" + xFilial("SA2") + "'"
		cCond	+= " AND SFE.FE_FORNECE = SA2.A2_COD"
		cCond	+= " AND SFE.FE_LOJA = SA2.A2_LOJA"
		cCond	+= " AND SFE.FE_SERIE2 = '" + cSerie + "'"
		cCond	+= " AND SFE.FE_NROCERT >= '" + cDocIni + "'"
		cCond	+= " AND SFE.FE_NROCERT <= '" + cDocFin + "'"
		cCond	+= " AND SFE.D_E_L_E_T_  = ' ' "
		cCond   += " GROUP BY SFE.FE_FILIAL, SFE.FE_SERIE2, SFE.FE_NROCERT, SFE.FE_EMISSAO, SFE.FE_FECAUT, SFE.FE_FORNECE, SFE.FE_LOJA, SFE.FE_STATUS, SA2.A2_NOME, SFE.FE_GRPTRIB %"
		cOrder 	:= "% SFE.FE_FILIAL, SFE.FE_SERIE2, SFE.FE_NROCERT %"
	EndIf

	BeginSql alias cAliasTmp
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		ORDER BY %exp:cOrder%
	EndSql

	TCSetField(cAliasTmp,"EMISSAO","D")
	TCSetField(cAliasTmp,"FECAUT","D")

	Count to nReg

	If nReg > 0
		dbSelectArea(cAliasTmp)
		(cAliasTmp)->(dbGotop())

		While  (cAliasTmp)->(!EOF())
			aAdd(aFacturas,{(cAliasTmp)->STATUS $ "6|7|8", ;        //[1]Status
				.F., ;                                              //[2]Selección al cargar
				IIf(_lCerRet,"",(cAliasTmp)->SERIE), ;              //[3]Serie
				(cAliasTmp)->SERIE2, ;                              //[4]Serie 2
				(cAliasTmp)->DOC, ;                                 //[5]Documento
				(cAliasTmp)->EMISSAO, ;                             //[6]Fecha de emisión
				(cAliasTmp)->FECAUT, ;                              //[7]Fecha de autorización SUNAT
				(cAliasTmp)->LOJA, ;                                //[8]Tienda
				(cAliasTmp)->CLIENTE, ;                             //[9]Cód. Cliente
				IIf(_lCerRet,Alltrim((cAliasTmp)->A2_NOME),Alltrim((cAliasTmp)->A1_NOME)), ; //[10]Nombre Cliente/Proveedor
				IIf(_lCerRet,"",Alltrim((cAliasTmp)->ESPECIE)), ;   //[11]Especie
				(cAliasTmp)->STATUS, ;                              //[12]Status
				IIf(_lCerRet,"",(cAliasTmp)->SFRECNO), ;            //[13]RecNo
				cRutina, ;                                          //[14]Rutina
				(cAliasTmp)->FILIAL, ;                              //[15]Filial
				(cAliasTmp)->IDCBAJA})                              //[16]ID de comunicado de baja/Resumen Diario de Reversión
			(cAliasTmp)->(dbSkip())
		EndDo

		(cAliasTmp)->( dbCloseArea())
	EndIf
Return aFacturas


/*/{Protheus.doc} M486RECXML
//Opción de recuperar XML de portal del proveedor tecnológico - Colombia.
@author arodriguez
@since 13/03/2019
@version 1.0
@return ${return}, ${}

@type function
/*/
Function M486RECXML()
	Local cPerg		:= "MATA486H"
	Local cSerie	:= ""
	Local cFacIni	:= ""
	Local cFacFin	:= ""
	Local nGuardar	:= 1
	Local cRuta		:= ""
	Local cDrive	:= ""
	Local cPath		:= ""
	Local cDiagonal	:= ""

	Private cLog	:= ""
	Private aTrans	:= {}
	Private aError	:= {}

	Do While .T.
		If Pergunte(cPerg,.T.)
			cSerie := MV_PAR01
			cFacIni := MV_PAR02
			cFacFin := MV_PAR03
			cRuta := Alltrim(MV_PAR04)

			If "/" $ cRuta
				cDiagonal := "/"
			Else
				cDiagonal := "\"
			EndIf

			If !(Substr(cRuta,Len(cRuta),1) == cDiagonal)
				cRuta += cDiagonal
			EndIf

			SplitPath( cRuta + "dummy.ext", @cDrive, @cPath, "", "" )
			nGuardar := IIf(Empty(cDrive), 1, 2)

			If Empty(cPath)
				MsgAlert( OemToAnsi(STR0228) )
				Loop
			EndIf

			M486PROCTRAN(cSerie, cFacIni, cFacFin, nGuardar, cRuta)
		EndIf

		Exit
	Enddo

Return

/*/{Protheus.doc} M486BajaXML
//Consumo de WS TFHKA para recuperar XML y PDF.
@author arodriguez
@since 13/03/2019
@version 1.0
@return ${return}, ${Proceso satisfactorio}
@param aFact, array, Documentos a procesar /NF, NDC, NCC)
@param aError, array, Mensajes de incidencias
@param cUrl, characters, url del WS
@param aTrans, array, Documentos procesados correctamente
@param nGuardar, numeric, Guardar en 1-Sistema (protheus_data) o 2-Carpeta local
@param cRuta, characters, Ubicación; ruta local de destino
@type function
/*/
Static Function M486BajaXML(aFact,aError,cUrl,aTrans,nGuardar,cRuta)
	Local lRet		:= .T.
	Local nI		:= 0
	Local cAmbiente	:= SuperGetMV("MV_CFDIAMB",.F.,"2") // Ambiente 1=Productivo, 2=Homologación
	Local cTokenEmp	:= SuperGetMV("MV_TKN_EMP",,"") // Token empresa
	Local cTokenPas	:= SuperGetMV("MV_TKN_PAS",,"") // Token password
	Local cUrl      := SuperGetMV("MV_WSRTSS",,"")	//URL de WS
	Local cDoc		:= ""
	Local cRespXML	:= ""
	Local cRespPDF	:= ""
	Local oWS
	Local cCUFE		:= ""

	// Procesa arreglo de facturas seleccionadas para solicitar bajada del XML
	For nI := 1 to Len(aFact)

		oWS := WSNFECol():New()

		oWS:ctokenEmpresa	:= cTokenEmp
		oWS:ctokenPassword	:= cTokenPas
		oWS:_URL := cUrl
		cDoc := Alltrim(aFact[nI,9])+Alltrim(Str(Val(aFact[nI,2])))
		oWS:cdocumento		:= cDoc

		If oWS:GenerarContenedor()
			If oWS:oWSGenerarContenedorResult:ncodigo == 200 .And. !Empty(oWS:oWSGenerarContenedorResult:ccontenedorXml)
				cRespXML := Decode64(oWS:oWSGenerarContenedorResult:ccontenedorXml)

				If !Empty(cRespXML)
					cCUFE := ExtraeCufe(cRespXML)
					fWriteLocal(cRespXML, cRuta, cDoc + ".xml", nGuardar)
					aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],oWS:oWSGenerarContenedorResult:cmensaje}) //"Se retorna el archivo solicitado."
					aAdd(aTrans, {aFact[nI,6],aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],cCUFE})

					If oWS:DescargaPDF()
						If !Empty(oWS:oWSDescargaPDFResult:cdocumento)
							cRespPDF := Decode64(oWS:oWSDescargaPDFResult:cdocumento)
							If !Empty(cRespPDF)
								fWriteLocal(cRespPDF, cRuta, cDoc + ".pdf", nGuardar)
							EndIf
						EndIf
					EndIf

				Else
					aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],STR0223}) //"Problema al decodificar el documento."

				EndIf

			Else
				aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],Str(oWS:oWSGenerarContenedorResult:nCodigo) + "-" + oWS:oWSGenerarContenedorResult:cmensaje})

			EndIf

		Else
			aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],STR0224}) //"Sin respuesta del servicio web."

		EndIf
	Next nI

Return lRet

/*/{Protheus.doc} fWriteLocal
//Graba archivo en ruta local
@author arodriguez
@since 13/03/2019
@version 1.0
@return ${return}, ${}
@param cTexto, characters, Contenido a grabar
@param cPath, characters, Ruta local
@param cFile, characters, Nombre del archivo a grabar
@param nGuardar, numérico, Guardar en: 1=Sistema (protheus_data), 2=Ruta local
@type function
/*/
Function fWriteLocal(cTexto, cPath, cFile, nGuardar)
	Local cPathFile	:= cPath + cFile
	Local nHdl		:= 0

	If nGuardar == 2 .And. !ExistDir( cPath )
		MakeDir( cPath )
	EndIf

	If File(cPathFile)
		FErase (cPathFile)
	Endif

	nHdl := fCreate(cPathFile)
	fWrite(nHdl, cTexto)
	fClose(nHdl)
Return

/*/{Protheus.doc} ${M486GENDOC}
Reliza la transmisión de documentos en formato XML para el TSS/OSE
@type
@author mayra.camargo
@since 30/05/2019
@version 1.0
@param aFact, Array, Array con los documentos que pasaron las validaciones
@param aError, Array, Array con los registros de error de los documentos
@param aTrans, Array, Array con los documentos que serán enviados a TSS
@return cMod, Caracter, Modelo que será enviado a TSS
@return lComBaja, Boolean, Indica si el documento procesado es un comunicado de baja
@example
(examples)
@see (links_or_references)
/*/
Static Function M486GENDOC(aFact,aError,aTrans,cMod,lComBaja,lResDia)
	Local aArea	:= getArea()
	Local lRet	:= .T.
	Local oWS	:= Nil
	Local cXML 	:= ""
	Local nI	:= 0
	Local cFilTab	:= IIf(Alltrim(cEspecie) $ "NF|NDC", xFilial("SF2"), xFilial("SF1"))
	Local dFecGen	:= dDataBase
	Local cIdCB		:= ""
	Local aIdCBaja	:= {}
	Local cNomXML	:= ""
	Local lOk		:= .F.
	Local oRestClient := Nil
	Local cAliasSF 	:= IIf(!Empty(nTDTras), IIf(nTDTras != 3,"SF2","SF1"), "")
	Local cPreSF  	:= IIf(!Empty(nTDTras), IIf(nTDTras != 3,"F2_","F1_"), "")
	Local lOpc		:= .F.
	Local cParam	:= ""
	Local cPath	   	:= &(SuperGetMV("MV_CFDDOCS",,""))
	Local cRUTASMR	:= &("GetClientDir()")
	Local cProvNFE	:= SuperGetMV("MV_PROVFE",,"")
	Local oXMLResp	:= Nil
	Local cError	:= ""
	Local cWarning	:= ""
	Local cCodDoc	:= ""
	Local aDocs		:= {}
	Local StatusTSS	:= 0
	Local cIdXMLCB  := ""
	Local lResDRev  := _lCerRet .And. Alltrim(cProvNFE) == "TCI"
	Local cParamB   := ""
	Local cFilSFE   := xFilial("SFE")

	Default cMod	 := IIF(IsMemVar("cModelo"), cModelo, "S1")
	Default lComBaja := .F. //Envío de comunicado de baja
	Default lResDia  := .F. //Envio Resumen Diario

	If lResDia .Or. (lComBaja .And. lResDRev) //Resumen Diario o Resumen Diario de Devolución
		cPath += "\ResumenDiario\"
		If lComBaja .And. lResDRev
			cIdCB := GetMV("MV_IDRDREV",,"") //Consecutivo Resumen Diario de Devolución
			cParamB := "MV_IDRDREV
		Else
			cIdCB := GetMV("MV_IDREDIA",,"") //Consecutivo Resumen Diario
		EndIf
	ElseIf lComBaja .And. !lResDRev
		cPath += "\ComunicadoBaja\"
		cIdCB := GetMV("MV_IDCBAJA",,"") //Consecutivo Comunicado Baja
		cParamB := "MV_IDCBAJA"
	EndIf

	For nI:= 1 to len(aFact)
		// Dependiendo del modelo se genera el XML
		If lResDia //Resumen Diario
			//Obtener consecutivo del parámetro
			aIdCBaja := StrTokArr(cIdCB, "-")
			If Len(aIdCBaja) < 3 .Or. aIdCBaja[2] <> dtos(dFecGen)
				cIdXMLCB := "RC-" + dtos(dFecGen) + "-1"
			Else
				cIdXMLCB := "RC-" + dtos(dFecGen) + "-" + Alltrim(Str(Val(aIdCBaja[3]) + 1))
			EndIf
			PutMv("MV_IDREDIA",cIdXMLCB)
			cXML	:= M486RDXML(cFilTab, aFact[nI,1], aFact[nI,4], aFact[nI,3], aFact[nI,2], cEspecie, cIdXMLCB)
		ElseIf cMod $ "S1|SD" // Factura | Boleta de Venta
			If alltrim(cEspecie) == "NF" .and. ExistBlock("M486PENF")
				cXML	:= ExecBlock("M486PENF",.F.,.F.,{cFilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie})
			Else
				cXML	:= M486NFXML(cFilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie)
			EndIf
		ElseIf cMod $ "S4" //  | Nota de Crédito
			If alltrim(cEspecie) == "NCC" .and. ExistBlock("M486PENC")
				cXML	:= ExecBlock("M486PENC",.F.,.F.,{cfilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie})
			Else
				cFilTab:= xFilial("SF1")
				cXML	:= M486NCCXML(cFilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie)
			EndIf
		ElseIf cMod $ "S5" //  | Nota de Débito
			If alltrim(cEspecie) == "NDC" .and. ExistBlock("M486PEND")
				cXML	:= ExecBlock("M486PEND",.F.,.F.,{cFilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie})
			Else
				cXML	:= M486NDCXML(cFilTab, aFact[nI,1], aFact[nI,3], aFact[nI,4], aFact[nI,2], cEspecie)
			EndIf
		ElseIf cMod $ "S7" //  | Comprobante Retención
			If ExistBlock("M486PECR")
				cXML	:= ExecBlock("M486PECR",.F.,.F.,{cFilTab, aFact[nI,2], aFact[nI,5], aFact[nI,6], aFact[nI,3], aFact[nI,4]})
			Else
				cFilTab:= xFilial("SFE")
				cXML	:= M486CERXML(cFilTab, aFact[nI,2], aFact[nI,5], aFact[nI,6], aFact[nI,3], aFact[nI,4], aFact[nI,1])
			EndIf
		ElseIf cMod $ "S6" //  | Guía Remisión
			If alltrim(cEspecie) == "RNF" .and. ExistBlock("M486PEGR")
				cXML	:= ExecBlock("M486PEGR",.F.,.F.,{cFilTab, aFact[nI,1],aFact[nI,2], aFact[nI,3], aFact[nI,4],cEspecie})
			Else
				cXML	:= M486RNFXML(cFilTab, aFact[nI,1],aFact[nI,2], aFact[nI,3], aFact[nI,4],,)
			EndIf
		ElseIf lComBaja //  | Comunicado de Baja
			//Obtener consecutivo del parámetro
			aIdCBaja := StrTokArr(cIdCB, "-")
			If Len(aIdCBaja) < 3 .Or. aIdCBaja[2] <> dtos(dFecGen)
				cIdXMLCB := IIf(lResDRev,"RR-","RA-") + dtos(dFecGen) + "-1"
			Else
				cIdXMLCB := IIf(lResDRev,"RR-","RA-") + dtos(dFecGen) + "-" + Alltrim(Str(Val(aIdCBaja[3]) + 1))
			EndIf
			PutMv(cParamB,cIdXMLCB)
			cXML	:= M486CBXML(cFilTab, aFact[nI,1], aFact[nI,4], aFact[nI,3], aFact[nI,2], cEspecie, cMotivoCB, cIdXMLCB)
		EndIf

		If Empty(cXML) // Si no se generá el XML se registra un error
			aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], STR0115}) // "No se pudo generar XML."
		Else
			// Se realiza envío al exe
			cCodDoc := getModelo(IIf(lComBaja .Or. lResDia,"SE",cModelo))
			If lComBaja .Or. lResDia
				cNomXML := Alltrim(SM0->M0_CGC) + "-" + cIdXMLCB
			Else
				If cMod <> "S7"
					cNomXML := Alltrim(SM0->M0_CGC) + "-" + cCodDoc + "-" + alltrim(aFact[nI,9]) + "-" +  STRZERO(VAL(aFact[nI,2]),8)
				Else
					cNomXML := Alltrim(SM0->M0_CGC) + "-" + cCodDoc + "-" + alltrim(aFact[nI,1]) + "-" +  STRZERO(VAL(aFact[nI,2]),8)
				EndIf
			EndIf

			//  Se escribe XML
			fWriteXml(cXml, cNomXML + ".xml",.f.,lComBaja,lResDia)

			If cProvNFE $ "TCI"
				// Aquí se realizará el envió del xml a la SUNAT/TCI
				//COPIAR la factura.xml del servidor a la ruta del smartclient (ROOTPATH...\CFD\FACTURAS\NF_UNI_000020.XML a x:\totvs\protheusroot\bin\smartclient)
				CpyS2T(cPath + cNomXML + ".xml " , cRUTASMR,,.F.)
				cParametros := cRUTASMR + cNomXML + ".xml "  			// Archivo xml
				cParametros += cRUTASMR + " "							// Ruta Destino Respuesta
				cParametros += cMVCFDIAM + " "							// Ambiente D = Desarrollo P= Producción
				cParametros += cRUTASMR + cMVCFDIPX + " " 				// ruta del certificado digital
				cParametros += cMVCFDICVE + " "					 		// Password del Certificado
				cParametros += IIf(lComBaja .Or. lResDia, "SE", cModelo) + " " // Modelo
				cParametros += cProvNFE + " " 							// Proveedor Envio
				cParametros += "X " 									// Opción C=Opción consulta
				cParametros += "X " 									// Ticket para comunicado de baja
				cParametros += cMVCFDIUS + " "							// Usuario autenticación con OSE
				cParametros += cMVCFDICO 							    // Contraseña autenticación con OSE

				nOpc := WAITRUN( cRUTASMR + cMVCFDIPA + ".exe " + cParametros, 0 )	// Se ejecuta exe

				If cMVCFDIAM $ "D"
					CONOUT("PARAMETROS: " + cParametros)
				EndIf

				lOpc := nOpc == 0

				CursorWait()

				// Si se ejecutó el exe
				If lOpc
					If File(cRUTASMR  + cNomXML + ".xml.out")
						CpyT2S(cRUTASMR  + cNomXML + ".xml.out" , cPath + IIf(!lComBaja .And. !lResDia, "\autorizados\", ""))
					EndIf
					// Procesar archivo out
					oXMLResp := XmlParserFile(EncodeUtf8(cPath + IIf(!lComBaja .And. !lResDia, "\autorizados\", "") + cNomXML +".xml.out"), "_", @cError, @cWarning )
					If oXMLResp <> Nil
						lHasError := "True" $ oXMLResp:_RESPONSE:_HASERROR:TEXT
						If lHasError // Si el .out reportó error
							cCodigo  	:= oXMLResp:_RESPONSE:_EXCEPTION:_CODE:TEXT
							cDescrip	:=  oXMLResp:_RESPONSE:_EXCEPTION:_MESSAGE:TEXT
							lRet 		:= .F.
							cError		:=  cCodigo + "-" + cDescrip
						Else
							// Si no hay error y el codigo de acpetación es 0
							cCodigo := ALLTRIM(oXMLResp:_RESPONSE:_MESSAGE:_CODE:TEXT)
							If cCodigo == "0"
								cCodErro	:= oXMLResp:_RESPONSE:_MESSAGE:_CODE:TEXT
								cDescErro	:= oXMLResp:_RESPONSE:_MESSAGE:_DESCRIPTION:TEXT
								cDataTim	:= ALLTRIM(oXMLResp:_RESPONSE:_MESSAGE:_DATE:TEXT)
								cTimeTim	:= oXMLResp:_RESPONSE:_MESSAGE:_TIME:TEXT
								If lComBaja .Or. lResDia
									cStatus     := Alltrim(oXMLResp:_RESPONSE:_MESSAGE:_STATUS:TEXT)
									StatusTSS := IIf(cStatus == "098",4,IIf(cStatus == "0",6,0))
									If lResDRev
										M486ASTASFE(cFilSFE, aFact[nI][2], StatusTSS, STod(StrTran(cDataTim,"-","")),oXMLResp:_RESPONSE:_MESSAGE:_IDCBAJA:TEXT)
									Else
										RecLock(cAliasSF,.F.)
											(cAliasSF)->&(cPreSF + "IDCBAJA") := oXMLResp:_RESPONSE:_MESSAGE:_IDCBAJA:TEXT
										(cAliasSF)->(MsUnlock())
										M486ACTSTA(cEspecie, StatusTSS, STod(StrTran(cDataTim,"-","")), aFact[nI,1], aFact[nI,2])
									EndIf
									
									If StatusTSS == 6
										//Baja automatica
										If lResDRev
											M486BAJACR(aFact[nI][2])
										Else
											M486AUTOCB(cEspecie)
										EndIf										
										cError += IIf(lResDia, STR0344, IIf(_lCerRet,STR0367,STR0197)) //"Resumen Diario ante la SUNAT y anulado del documento con éxito." ## "Resumen Diario de Reversión ante la SUNAT y borrado de Comprobante de Retención realizado con éxito." ## "Comunicado de baja ante la SUNAT y anulado del documento con éxito."
									EndIf
								Else
									// Se actualizan array de estatus de documentos
									aAdd(aDocs, {6,;
												 aFact[nI,1]+aFact[nI,2],;
								 				 IIf(cMVCFDIAM == "P",STR0036,STR0037),; //Produccion //Homologacion
												 STod(StrTran(cDataTim,"-","")),;
												 cTimeTim,;
												 cDescErro,;
												 ""})
								EndIf
								cError += cDescErro	// "Transmisión a TSS exitosa"
								aAdd(aTrans, {cFilTab,aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4]})
							Else
								If lComBaja .Or. lResDia
									cCodErro:= oXMLResp:_RESPONSE:_MESSAGE:_CODE:TEXT
									cStatus := oXMLResp:_RESPONSE:_MESSAGE:_STATUS:TEXT
									If Empty(oXMLResp:_RESPONSE:_MESSAGE:_DESCRIPTION:TEXT)
										cDescErro := STR0231 // "Error, verificar Anexo 2: Listado de Errores de la SUNAT."
									Else
										cDescErro	:= oXMLResp:_RESPONSE:_MESSAGE:_DESCRIPTION:TEXT
									EndIf

								Else
									cCodErro	:= oXMLResp:_RESPONSE:_MESSAGE:_CODE:TEXT
									cDescErro	:= oXMLResp:_RESPONSE:_MESSAGE:_DESCRIPTION:TEXT
								EndIf
								// Se actualizan array de estatus de documentos
								aAdd(aDocs, {5,;
												 aFact[nI,1]+aFact[nI,2],;
								 				 IIf(cMVCFDIAM == "P",STR0036,STR0037),; //Produccion //Homologacion
												 "",;
												 "",;
												 cDescErro,;
												 ""})
								cError := cCodErro +" - "+ cDescErro
								lret := .f.
							EndIf
							// Se actualizan estatus de documentos a Protheus
							ActCertif(aDocs,.f.)
							// Se envia CDR. archivo out y XML sellado al servidor
							// Copiar timbre al servidor
							CpyT2S(cRUTASMR  + cNomXML + ".xml" , cPath + IIf(!lComBaja .And. !lResDia, "\autorizados\", ""))
							CpyT2S(cRUTASMR  + "R-" + cNomXML + ".xml" , cPath + IIf(!lComBaja .And. !lResDia, "\autorizados\", ""))
							CpyT2S(cRUTASMR  + cNomXML + ".zip" , cPath + IIf(!lComBaja .And. !lResDia, "\autorizados\", ""))

							// Se eliminan archivos de la carpeta del smartclient
							Ferase( cRUTASMR  + cNomXML + ".out" )
							Ferase( cRUTASMR  + cNomXML + ".xml" )
							Ferase( cRUTASMR  + cNomXML + ".zip" )
							Ferase( cRUTASMR  + "R-" + cNomXML + ".xml" )

						EndIf
					Else
						cError := STR0232  + cError //"006 - Imposible leer archivo .out, intente transmitir de nuevo el documento."
						lRet := .F.
					EndIf
					aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], cError})
				Else
					aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], STR0230 + cMVCFDIPA }) //"Imposible ejecutar componente "
					lRet := .F.
				EndIF
			ElseIf cProvNFE == "RSM"
				M486INTRSM(cXML,@aError,aFact[nI],@aDocs,@aTrans,cFilTab,cNomXML,lComBaja,cIdXMLCB)
			EndIf
		EndIf
	Next nI

    CursorArrow()
	RestArea(aArea)
Return lRet

Static Function M486VldPar()
	Local lRet := .T.
	Local cMsg := STR0229 + Chr(10) + Chr(13) //"Falta configuración de los siguientes parámetros: "

	cMVCFDIUS := SuperGetMV("MV_CFDI_US",,"") // Usuario
	cMVCFDICO := SuperGetMV("MV_CFDI_CO",,"") // PasSword
	cMVCFDIPA := SuperGetMV("MV_CFDI_PA",,"") // Nombre del Ejecutable
	cMVCFDIAM := SuperGetMV("MV_CFDI_AM",,"") // Ambiente
	cMVCFDIPX := SuperGetMV("MV_CFDI_PX",,"") // Certificado Digital
	cMVCFDICVE:= SuperGetMV("MV_CFDICVE",,"") // Clave certificado Digital
	cMVWSRTSS := SuperGetMV("MV_WSRTSS",,"")  // Url de web services

	
	If !(cPaisLoc $ "PAR") .and. Empty(cMVCFDICO)
		cMsg += " - MV_CFDI_CO - " + STR0314 + Chr(10) + Chr(13) //"Contraseña para la conexión con el Operador de Servicios Electrónicos."
		lRet := .F.
	EndIf
	
	If Empty(cMVCFDDOCS)
		cMsg += " - MV_CFDDOCS - " + STR0327 + Chr(10) + Chr(13) //"Directorio donde se graban los Documentos Electrónicos."
		lRet := .F.
	EndIf
	If cMVPROVFE $ "TCI" .or. cPaisLoc $ "PAR"
		If !(cPaisLoc $ "PAR") .and. Empty(cMVCFDIUS)
			cMsg += " - MV_CFDI_US - " + STR0309 + Chr(10) + Chr(13) //"Usuario para la conexión con el Operador de Servicios Electrónicos."
			lRet := .F.
		EndIf
		If Empty(cMVCFDIPA)
			cMsg += " - MV_CFDI_PA - " + STR0310 + Chr(10) + Chr(13) //"Nombre del ejecutable(.exe) para firmar y transmitir documentos electrónicos."
			lRet := .F.
		EndIf
		If Empty(cMVCFDIAM)
			cMsg += " - MV_CFDI_AM - " + STR0311 + Chr(10) + Chr(13) //"Ambiente para transmisión electrónica D=Desarrollo y P=Producción."
			lRet := .F.
		EndIf
		If Empty(cMVCFDIPX)
			cMsg += " - MV_CFDI_PX - " + STR0312 + Chr(10) + Chr(13) //"Nombre del chivo en formato .pfx del certificado digital."
			lRet := .F.
		EndIf
		If Empty(cMVCFDICVE)
			cMsg += " - MV_CFDICVE - " + STR0313 + Chr(10) + Chr(13)	//"Contraseña del certificado digital para firmado de los documentos electrónicos."
			lRet := .F.
		EndIf
	ElseIf cMVPROVFE $ "RSM"
		If Empty(cMVWSRTSS)
			cMsg += " - MV_WSRTSS" + STR0308 + Chr(10) + Chr(13) //"URL de los Web Services de RSM."
			lRet := .F.
		EndIf
	EndIf
	If !lRet
		MsgAlert(cMsg)
	EndIf
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} getModelo

@author  Mayra Camargo
@since    30/05/2019
@version 12
/*/
//-----------------------------------------------------------------------
Function getModelo(cTipoMod)
	Local cRet := ""
	Do Case
		Case cTipoMod $ "S1"  	// Factura
			cRet := "01"
		Case cTipoMod $ "S4"  	// Nota Crédito
			cRet := "07"
		Case cTipoMod $ "S5"	// Nota Débito
			cRet := "08"
		Case cTipoMod $ "S6"	// Guía remisión
			cRet := "09"
		Case cTipoMod $ "S7"	// Certificado de Retención
			cRet := "20"
		Case cTipoMod $ "SD" 	// Boleta de Venta
			cRet := "03"
		Case cTipoMod $ "SE" 	// Comunicado de Baja
			cRet := "RA"
		Otherwise
			cRet := "NA"
	EndCase

Return cRet

/*/{Protheus.doc} M486GETSFX
@author  Mayra Camargo
@since    30/05/2019
@version 12
/*/
Static Function M486GETSFX(cSerie,cFacIn,cFacFi)
	Local aRet    	:= {}
	Local aArea   	:= getArea()
	Local cTempF  	:= CriaTrab(Nil, .F.)
	Local cSts	   	:= ""
	Local cRec	   	:= ""
	Local cMes		:= ""
	Local aError	:= {}
	Local cCodDoc 	:= ""
	Local cNomXML 	:= ""

	Private aArcTmp  := Directory(&(SuperGetMV("MV_CFDDOCS","")) + "autorizados\" + "*.xml",,,.F.)
	If nTipoDoc == 0
		cQuery := "SELECT F1_FILIAL FILIAL,F1_FORNECE CLIFOR, F1_LOJA TIENDA, F1_DOC DOC, F1_SERIE SERIE, F1_FLFTEX FLFTEX, F1_FECAUT FECAUT"
		If SF1->(ColumnPos("F1_SERIE2"))
			cQuery += ", F1_SERIE2 SERIE2 "
		EndIf
		If SF1->(ColumnPos("F1_IDCBAJA"))
			cQuery += ", F1_IDCBAJA IDCBAJA "
		EndIf

		cQuery += "FROM "+RetSqlName("SF1")+" SF1 "
		cQuery += "WHERE F1_SERIE = '"+cSerie+"' AND F1_ESPECIE = '"+cEspecie+"' AND F1_DOC BETWEEN '"+cFacIn+"' AND '"+cFacFi+"' AND D_E_L_E_T_ = '' "
		cQuery += "AND F1_FLFTEX <> ' ' "

		If SF1->(ColumnPos("F1_IDCBAJA"))
			cQuery += "AND F1_IDCBAJA = ' ' "
		EndIf
	Else
		cQuery := "SELECT F2_FILIAL FILIAL, F2_CLIENTE CLIFOR, F2_LOJA TIENDA, F2_DOC DOC, F2_SERIE SERIE,F2_FLFTEX FLFTEX, F2_FECAUT FECAUT "
		If SF2->(ColumnPos("F2_SERIE2"))
			cQuery += ", F2_SERIE2 SERIE2 "
		EndIf

		If SF2->(ColumnPos("F2_IDCBAJA"))
			cQuery += ", F2_IDCBAJA IDCBAJA "
		EndIf

		cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
		cQuery += "WHERE F2_SERIE = '"+cSerie+"' AND F2_ESPECIE = '"+cEspecie+"' AND F2_DOC BETWEEN '"+cFacIn+"' AND '"+cFacFi+"' AND D_E_L_E_T_ = '' "
		cQuery += "AND F2_FLFTEX <> ' ' "
		If SF2->(ColumnPos("F2_IDCBAJA"))
			cQuery += "AND F2_IDCBAJA = ' ' "
		EndIf
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)
	count to nCount

	(cTempF)->(dbGoTop())
	While (!(cTempF)->(EOF()))
		If cMVPRovFE == "RSM"
			cCodDoc := getModelo(cModelo)
			If cModelo <> "S7"
				cNomXML := Alltrim(SM0->M0_CGC) + "-" + cCodDoc + "-" + alltrim((cTempF)->SERIE2) + "-" +  STRZERO(VAL((cTempF)->DOC),8)
			Else
				cNomXML := Alltrim(SM0->M0_CGC) + "-" + cCodDoc + "-" + alltrim((cTempF)->SERIE2) + "-" +  STRZERO(VAL((cTempF)->DOC),8)
			EndIf
			M486CONSRSM(@aError,{(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR,(cTempF)->TIENDA,,,,,(cTempF)->SERIE2},@aRet,cNomXML,(cTempF)->FILIAL)
			ActCertif(aRet,.f.)
		ElseIf cMVPRovFE == "TCI"
			cSts := (cTempF)->FLFTEX
			cMes := STR0234 //"Transmitido"
			If cSts == "6"
				cMes := STR0235 //"Autorizado"
				cRec := STR0236 //"Distribuir o enviar a Cliente."
			ElseIf  cSts == "5"
				cMes := STR0237 //"Rechazado"
				cRec := STR0238 //"Corregir y reenviar. Revise CDR para observaciones."
			EndIf

			aAdd(aRet, {val((cTempF)->FLFTEX),;
						(cTempF)->SERIE + (cTempF)->DOC +"-" + (cTempF)->SERIE2 ,;
						IIf(cMVCFDIAM == "P",STR0036,STR0037),; //Produccion //Homologacion
						(cTempF)->FECAUT,;
						TIME(),;
						cMes,;
						cRec})
		EndIF
		(cTempF)->(dbSkip())
	EndDo
	(cTempF)->(dbcloseArea())

	RestArea(aArea)
Return aRet
/*/{Protheus.doc} M486INTRSM
Realiza el envío de una documento XML a RSM
@type function
@author mayra.camargo
@since 22/07/2019
@version 1.0
@param aError, array, array en dónde se atra´pan los errores
@param aFact , array, array con la información de la NF que será consultada
@param aDocs , array, array con la información de retorno de la consulta
@param cNomXML,string, Nombre del archivo .zip que será recuperado.
@param cFilTab,string, filial del documento
@param aTras  ,array, array con la información de la NF que fue consultada de manera exitosa.
@return lRet  , lógico
/*/
Static function M486INTRSM(cXML, aError,aFact,aDocs,aTrans,cFilTab,cNomXML,lComBaja,cIdXMLCB)
	Local lRet 	 	:= .T.
	Local cURL 	 	:= SuperGetMV("MV_WSRTSS",,"")
	Local aHeader	:= {}
	Local oRest	 	:= Nil
	Local oObj	 	:= Nil
	Local nStatus	:= 1
	Local cMsg		:= ""
	Default cXML	:= ""
	Default aError	:= {}
	Default lComBaja := .F.
	Default cIdXMLCB := ""

	If !Empty(cXML)
		//Se envía
		cMVCFDIUS := cUserName
		oRest:= FWRest():New(cUrl)
		aAdd(aHeader,"Content-Type: text/plain")
		aAdd(aHeader,"CacheControl: no-control" )
		aAdd(aHeader,"Username: " + cMVCFDIUS )
		aAdd(aHeader,"Authorization: Bearer " + cMVCFDICO )
		oRest:setPath("/rest/sendDocumentXml")
		oRest:SetPostParams(cXML)

		If oRest:Post(aHeader)
			If FWJsonDeserialize(oRest:GetResult(),@oObj)
				If oObj <> Nil
				 	If AttIsMemberOf(oObj,"RequestState")
				 		If oObj:ErrorMessage <> Nil
				 			cMsg :=  DecodeUTF8(oObj:ErrorMessage)
				 		EndIf
				 		If Empty(cMsg)
				 			cMsg := STR0076 // "XML Enviado"
				 		EndIf
				 		If oObj:RequestState == 7 .or.  oObj:RequestState == 6  .OR. oObj:RequestState == 3
				 			nStatus := 5
				 			cRec := STR0157 // "Corregir y reenviar."
				 			lRet := .f.
				 			aAdd(aError, {aFact[1],aFact[2],aFact[3], aFact[4], cMsg})
					 		aAdd(aDocs , {nStatus ,;
										 aFact[1]+aFact[2]+ iIf(LEN(aFact) > 9,"-" + aFact[9],""),;
								 		 IIf(cMVCFDIAM == "P",STR0036,STR0037),; //Produccion //Homologacion
										 DATE()	,;
										 TIME()	,;
										 cMsg	,;
										 cRec})
				 		Else
				 		 	// Realizar consulta para obtener documentos.
				 			lRet := M486CONSRSM(@aError,aFact,@aDocs,cNomXML,cFilTab,@aTrans,lComBaja,cIdXMLCB)
				 			// Se actualizan estatus de documentos a Protheus

				 		EndIf
						ActCertif(aDocs,.f.)
				 	Else
				 		aAdd(aError, {aFact[1],aFact[2],aFact[3], aFact[4], STR0161})// "Error Desconocido"
				 		lRet := .F.
				 	EndIf
				Else
					aAdd(aError, {aFact[1],aFact[2],aFact[3], aFact[4],STR0161}) // "Error Desconocido"
				 	lRet := .F.
				EndIf
			Endif
		Else
			// Aquí va que pasa si no hace post
			aAdd(aError, {aFact[1],aFact[2],aFact[3], aFact[4],oRest:GetLastError()})
		Endif
		oRest:= Nil
		oObj := Nil
	Else
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} M486CONSRSM
Ejecuta consulta de documentos consumiento
método getDocument API Rest de RSM.
@type function
@author mayra.camargo
@since 22/07/2019
@version 1.0
@param aError, array, array en dónde se atra´pan los errores
@param aFact , array, array con la información de la NF que será consultada
@param aDocs , array, array con la información de retorno de la consulta
@param cNomXML,string, Nombre del archivo .zip que será recuperado.
@param cFilTab,string, filial del documento
@param aTras  ,array, array con la información de la NF que fue consultada de manera exitosa.
@return lRet  , lógico
/*/
Static function M486CONSRSM(aError,aFact,aDocs,cNomXML,cFilTab,aTrans,lComBaja,cIdXMLCB)
	Local lRet 	 	:= .T.
	Local cURL 	 	:= SuperGetMV("MV_WSRTSS",,"")
	Local aHeader	:= {}
	Local oRest	 	:= Nil
	Local oObj	 	:= Nil
	Local nStatus	:= 1
	Local cMsg		:= ""
	Local cJSON		:= ""
	Local cZip		:= ""
	Local dFecha	:= CTOD(" /  / ")
	Local cHora		:= ""
	Local cRec		:= ""
	Local cSerDoc	:= ""
	Local cNumDoc	:= ""
	Local cAliasSF 	:= IIf(!Empty(nTDTras), IIf(nTDTras != 3,"SF2","SF1"), "")
	Local cPreSF  	:= IIf(!Empty(nTDTras), IIf(nTDTras != 3,"F2_","F1_"), "")

	Default aError := {}
	Default aFact 	:= {}
	Default aDocs 	:= {}
	Default cNomXML  := ""
	Default cFilTab  := ""
	Default aTrans	  := {}
	Default lComBaja := .F.
	Default cIdXMLCB := ""

	If Empty(cFilTab)
		cFilTab := IIf(!Empty(nTDTras), IIf(nTDTras != 3,xFilial("SF2"),xfilial("SF1")), "")
	EndIf
	If len(aFact) > 0
		If !lComBaja
			cSerDoc := IIF(cModelo =="S7",aFact[1],aFact[9])
			cNumDoc := strzero(val(aFact[2]),8)
		Else
			cSerDoc := Substr(cIdXMLCB,1,rat("-",cIdXMLCB)-1)
			cNumDoc := Substr(cIdXMLCB,rat("-",cIdXMLCB)+1)
		endIf
		cJSON := '{ '
		cJSON += '"DocumentType" : "' + IIF(lComBaja,"0", getModelo(cModelo)) + '",'
		cJSON += '"Serie" :  "' + cSerDoc + '", '
		cJSON += '"Number" : "' + cNumDoc + '", '
		cJSON += '"IncludeTicket" : "true",'
		cJSON += '"IncludeXML" : "true",'
		cJSON += '"IncludeCDR" : "true",'
		cJSON += '"IncludePDF" : "true",'
		cJSON += '"ReturnEncoding" : "3" '
		cJSON += '}'

		//Se envía
		cMVCFDIUS := cUserName
		oRest:= FWRest():New(cUrl)
		aAdd(aHeader,"Content-Type: application/json")
		aAdd(aHeader,"CacheControl: no-control" )
		aAdd(aHeader,"Username: " + cMVCFDIUS )
		aAdd(aHeader,"Authorization: Bearer " + cMVCFDICO )
		oRest:setPath("/rest/getDocument")
		oRest:SetPostParams(cJSON)

		If oRest:Post(aHeader)
			If FWJsonDeserialize(oRest:GetResult(),@oObj)
				If oObj <> Nil
				 	If AttIsMemberOf(oObj,"RequestState")
				 		If oObj:ErrorMessage <> Nil
				 			cMsg :=  DecodeUTF8(oObj:ErrorMessage)
				 		EndIf
				 		If Empty(cMsg)
				 			cMsg := STR0076 // "XML Enviado"
				 		EndIf
				 		If oObj:RequestState == 0 .or.  oObj:RequestState == 1
				 			If lComBaja
				 				nStatus := 4
				 				cMsg := STR0076 + "," + STR0158 //"XML Enviado" "Espere procesamiento del documento"
				 			Else
				 				nStatus := 1
				 			EndIf
				 			cRec := STR0158 // "Espere procesamiento del documento"
				 		ElseIf oObj:RequestState == 4 .or.  oObj:RequestState == 5
				 			nStatus := 6
				 			cMsg := STR0075 // "Documento autorizado"
				 			If oObj:RequestState == 4
				 				cRec := STR0159 // "Documento Autorizado. Enviar a receptor"
				 			Else
				 				cRec := STR0159 + "-" + STR0162 // "Documento Autorizado. Enviar a receptor"		 "Revisar observaciones - "
				 			EndIf
				 		ElseIf oObj:RequestState == 7 .or.  oObj:RequestState == 6
				 			nStatus := 5
				 			cRec := STR0157 // "Corregir y reenviar."
				 			lRet := .f.
				 		Else
				 			nStatus := 2
				 			cRec := STR0158 // "Espere procesamiento del documento"
				 		EndIf
				 		If oObj:ContentBase64String <> Nil .and. !Empty(oObj:ContentBase64String)
				 			cZip := DECODE64(oObj:ContentBase64String)
				 			If !Empty(cZip)
				 				fWriteXml(cZip, cNomXML + ".zip",.T.,lComBaja)
				 				M486READCDR("R-"+cNomXML+".xml", @dFecha,@cHora,lComBaja)
				 			EndIf
				 		EndIf

				 		If !lComBaja
					 		aAdd(aDocs , {nStatus ,;
										 aFact[1] + aFact[2] + IIF(cModelo<> "S7","-"+aFact[9],""),;
								 		 IIf(cMVCFDIAM == "P",STR0036,STR0037),; //Produccion //Homologacion
										 dFecha	,;
										 cHora	,;
										 cMsg	,;
										 cRec})
						EndIf
					  	If lRet
					  		If lComBaja
								RecLock(cAliasSF,.F.)
									(cAliasSF)->&(cPreSF + "IDCBAJA") := cIdXMLCB
								(cAliasSF)->(MsUnlock())
								M486ACTSTA(cEspecie, nStatus, dFecha, aFact[1], aFact[2])
								If nStatus == 6
									//Baja automatica
									M486AUTOCB(cEspecie)
									cMsg += "- " + STR0197 //"Comunicado de baja ante la SUNAT y anulado del documento con éxito."
								EndIf
					  		EndIf
					  		aAdd(aTrans, {cFilTab ,aFact[1],aFact[2],aFact[3],aFact[4]})
					  	EndIF
					  	aAdd(aError, {aFact[1],aFact[2],aFact[3], aFact[4], cMsg})
				 	Else
				 		aAdd(aError, {aFact[1],aFact[2],aFact[3], aFact[4], EncodeUTF8(oObj:ErrorMessage)})
				 		lRet := .F.
				 	EndIf
				Else
					aAdd(aError, {aFact[1],aFact[2],aFact[3], aFact[4], STR0161})// "Error Desconocido"
				 	lRet := .F.
				EndIf
			Endif
		Endif
		oRest:= Nil
		oObj := Nil
	EndIf
Return lRet
/*/{Protheus.doc} M486READCDR
Lee CDR Y OBTIENE FECHA Y HORA DE RESPUESTA
@type function
@author mayra.camargo
@since 22/07/2019
@version 1.0
@param cXML, string, XML del CDR
@return por referencia dDato, fecha de respuesta sunat
@return por referencia cHora, Hora de respuesta sunat
/*/
Static Function M486READCDR(cXML,dDate,cHora,lBaja,cIDBaja)
	Local oXMLCDR 	:= Nil
	Local cError  	:= ""
	Local cWarning	:= ""
	Local cDate		:= ""
	Local cPath	   	:= getMV("MV_CFDDOCS")
	Local cPathFile	:= ""
	Local aNomArc   := {}
	Local nPos      := 0
	Local lSrvUnix := IsSrvUnix()
	
	Default cXML := ""
	
	If lBaja
		aNomArc := StrTokArr(StrTran( cXML, '.XML', '' ),"-")
		If Len(aNomArc) >= 5
			aNomArc[5] := StrZero(Val(aNomArc[5]),5)
			cXML := aNomArc[1] + "-" + aNomArc[2] + "-" + aNomArc[3] + "-" + aNomArc[4] + "-" + aNomArc[5] + ".XML"
		EndIf
	EndIf

	If !Empty(cXML)
		If lSrvUnix //LINUX       
			If (Len(aArcTmp) > 0)
				nPos := ascan (aArcTmp,{|x| Upper(x[1]) == Upper(cXML)})
				If (nPos > 0)
					cPathFile := cTmpPath +  aArcTmp[nPos][1]
				EndIf
				aArcTmp := asize(aArcTmp,0)
			Else 
				cPathFile := cTmpPath  + cXML  
			EndIf
		Else //WINDOWS
			cPathFile	:= &(cPath) + "autorizados\" + cXML  
		EndIf

		oXMLCDR := XmlParserFile(cPathFile, "_", @cError, @cWarning,,.F.)

		If oXMLCDR <> Nil
			If XmlChildEx(oXMLCDR, "_NS4_APPLICATIONRESPONSE") <> Nil
				cDate := oXMLCDR:_NS4_APPLICATIONRESPONSE:_RESPONSEDATE:TEXT
				cHora := SubStr(oXMLCDR:_NS4_APPLICATIONRESPONSE:_RESPONSETIME:TEXT,1,8)		
			Else
				cDate := oXMLCDR:_AR_APPLICATIONRESPONSE:_CBC_RESPONSEDATE:TEXT
				cHora := oXMLCDR:_AR_APPLICATIONRESPONSE:_CBC_RESPONSETIME:TEXT
			EndIf
			If !Empty(cDate)
				dDate := STOD(STRTRAN(cDate,"-",""))
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} M486VLDCAT
Valida si un registro  para una tabla dada existe en el catálogo registrado
en F3I y F3H
@type
@author luis.enriquez
@since 31/01/2020
@version 1.0
@param cCodigo	, caracter, Código de la Tabla
@param cConteudo, caracter, Cadena a buscar
@param nPos1, numérico, Posición de inicio de búsqueda
@param nPos2, numérico, Posición de fin de búsqueda
@return lRet, verdadero si encuentra el registro, falso si no lo encuentra
@example
lRet := ValidCat("S006", SA1->A1_TIPDOC,1,1)
@see (links_or_references)
/*/
Function M486VLDCAT(cCodigo,cConteudo,nPos1,nPos2)
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
			If Alltrim(Substr(TRBF3I->F3I_CONTEUDO,nPos1,nPos2)) == Alltrim(cConteudo)
				lRet := .T.
				Exit
			EndIf
			TRBF3I->(dBSkip())
		EndDo
	EndIf
	RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} M486VLDDR
Valida si un registro  para una tabla dada existe en el catálogo registrado
en F3I y F3H
@type
@author luis.enriquez
@since 07/02/2020
@version 1.0
@param cUUID	, caracter, documentos relacionados
@param lMsj, lógico, .T. para imprimir mensaje en msg alert, .F. para agregar a aError
@param aError, arreglo, Arregló con errores (para transmisión)
@return lRet, verdadero si encuentra el registro, falso si no lo encuentra en F3I
@example
lRet := ValidCat("S006", SA1->A1_TIPDOC,1,1)
@see (links_or_references)
/*/
Function M486VLDDR(cUUID,lMsj,aError)
	Local lRetDR := .T.
	Local cCRLF     := (chr(13)+chr(10))
	Local aUUIDRel  := {}
	Local aDRelAux  := {}
	Local nI        := 0
	Local nX        := 0
	Local cMsj      := ""
	Local cMsjErr   := ""

	Default cUUID  := ""
	Default	aError := {}
	Default lMsj   := .T.

	If !Empty(cUUID)
		aUUIDRel := StrTokArr(cUUID, cCRLF)
		For nI := 1 To Len(aUUIDRel)
			aAdd(aDRelAux, StrTokArr(aUUIDRel[nI], "/"))
		Next nI

		For nX := 1 To Len(aDRelAux)
			If Len(aDRelAux[nX]) >= 1
				If !(aDRelAux[nX][1] == "ORDC")
					If !M486VLDCAT("S018", aDRelAux[nX][1],1,4)
						cMsj := "(" + Alltrim(aDRelAux[nX][1]) + ") "+ STR0320 //"Tipo de Referencia a otros documentos, no existe en catálogo S018 (Docs. Rel.)"
						If lMsj
							cMsjErr += cMsj + cCRLF
						Else
							aAdd(aError, {(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA, cMsj}) //"El documento relacionado no se encuentra autorizado."
						EndIf
						lRetDR := .F.
					EndIf
				EndIf
			EndIf
		Next nX
		If lMsj .And. !Empty(cMsjErr)
			MsgAlert(cMsjErr,)
		EndIf
	EndIf
Return lRetDR

/*/{Protheus.doc} ExtraeCufe
// Extrar el CUFE del AttachedDocument obtenido del WS de TFHKA.
@author arodriguez
@since 14/07/2020
@version 1.0
@return cCUFE, caracter, CUFE del receptor
@param cXML, characters, AttachedDocument
/*/
Static Function ExtraeCufe( cXML )
	Local cCUFE := ""
	Local nLenCufe := GetSx3Cache("F2_UUID","X3_TAMANHO")
	Local nPos := 0

	nPos := At("CUFE: ", cXML)	// CUFE en el QRCode

	If nPos > 0
		cCUFE := Substr(cXML, nPos + 6, nLenCufe)
	EndIf

Return cCUFE
/*/{Protheus.doc} LibMetric
Funcion utilizada para validar la fecha de la LIB para ser utilizada en Telemetria

@type       Function
@author     Luis Eduardo Enríquez Mata
@since      20/10/2021
@version    1.0
@return     lMetric, lógico, Retorna .T. si la LIB puede ser utilizada para Telemetria
/*/
Static Function LibMetric()
	Local lMetric := .F.

	lMetric := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

Return lMetric
/*/{Protheus.doc} M486ClieDS
Funcion para obtener Cliente configurado a partir del Proveedor para generac.
de Documento Soporte.

@type       Function
@author     oscar.lopez
@since      23/12/2021
@version    1.0
@param		cCodProv, caracter, Código Proveedor
@param		cLojProv,caracter, Tienda Proveedor
@return     aInfo, arreglo, Arreglo con Codigo y Tienda de Cliente relacionado a Proveedor
/*/
Function M486ClieDS(cCodProv,cLojProv)
	Local aInfo := {"",""}
	Local aArea	:= GetArea()

	DbSelectArea("SA2")
	SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
	If SA2->(MsSeek(xFilial("SA2")+cCodProv+cLojProv))
		aInfo := {SA2->A2_CLIENTE, SA2->A2_LOJCLI}
	EndIf
	RestArea(aArea)
Return aInfo

/*/{Protheus.doc} M486BAJACR
Realiza eliminación lógica de Certificado de Retención a partir de  Resumen diario de reversiones autorizado.
@author Luis Enríquez
@since 25/04/2022
@version 1.0
@return Nil
@type function
/*/
Function M486BAJACR(cNroCert)
	Local cFilSFE    := xFilial("SFE")
	Default cSerieCR := ""
	Default cNroCert := ""

	dbSelectArea("SFE")
	SFE->(dbSetOrder(1)) //FE_FILIAL + FE_NROCERT + STR(FE_ITEM,3)

	If SFE->(DbSeek(cFilSFE + cNroCert))
		Do While SFE->(!Eof()) .And. SFE->FE_FILIAL + SFE->FE_NROCERT == cFilSFE + cNroCert
			RecLock("SFE",.F.)
				SFE->(dbDelete())
			SFE->(MsUnLock())
			SFE->(DbSkip())
		EndDo
	EndIf
Return Nil

/*/{Protheus.doc} M486ACTSTA
//Actualiza campo STATUS de estatus de Resumen Diario de Reversión.
@author Luis Enríquez
@since 29/04/2022
@version 1.0
@return Nil
@type function
/*/
Function M486ASTASFE(cFilSFE, cCompRet, nStatus, dFecBaja,cIDResDiaR)
	Local cStaPro  := ""

	Default cFilSFE  := xFilial("SFE")
	Default cCompRet := ""
	Default nStatus  := 0
	Default dFecBaja := Ctod(" / / ")
	Default cIDResDiaR := ""

	Do Case
		Case nStatus == 6 //Autorizado
			cStaPro := "8"
		Case nStatus == 4 //Pendiente
			cStaPro := "7"
	EndCase

	dbSelectArea("SFE")
	SFE->(dbSetOrder(1)) //FE_FILIAL + FE_NROCERT + STR(FE_ITEM,3)

	If SFE->(DbSeek(cFilSFE + cCompRet))
		Do While SFE->(!Eof()) .And. SFE->FE_FILIAL + SFE->FE_NROCERT == cFilSFE + cCompRet
			RecLock("SFE",.F.)
				SFE->FE_GRPTRIB := Alltrim(cIDResDiaR)
				If !Empty(cStaPro)
					SFE->FE_STATUS:= cStaPro //STATUS
				EndIf
				If nStatus == 6
					SFE->FE_DTESTOR := dFecBaja //FECHA DE BAJA
				EndIF
			SFE->(MsUnLock())
			SFE->(DbSkip())
		EndDo
	EndIf
Return

/*/{Protheus.doc} M486GETXML
Carga documentos autorizados para el copiado de XML/PDF de documentos autorizados 
@type       Function
@author     luis.enríquez
@since      30/08/2022
@version    1.0
@param		cEsp, caracter, Especie del Documento
@param		lCertR, lógico, .T. indica que es un Cert. de Retención
/*/
Function M486GETXML(cEsp, lCertR)
	Local cPerg		:= IIf(!lCertR, "MATA486J", "MATA486K")
	Local cSerie	:= ""
	Local cDocIni	:= ""
	Local cDocFin	:= ""
	Local cRuta     := ""
	Local cAliasTRB	:= getNextAlias()
	Local nRegProc  := 0
	Local cCampos   := ""
	Local cTablas   := ""
	Local cCond     := ""
	Local cOrder    := ""
	Local lRet      := .T.
	Local cTitulo   := STR0417 //"COPIADO DE XML/PDF"
	Local aLogTitle := {}
	Local aLog      := {}
	Local cFileGen  := ""
	Local cArcCpy   := ""
	Local cDocProc  := ""
	Local aNewLog   := {}
	Local oObjP     := Nil //Objeto de Grupo de Preguntas
	Local aX1Pre    := {}	
	Local cEspTRB   := ""
	Local lLog      := .F.

	Default cEsp   := ""
	Default lCertR := .F.

	//Valida que exista el grupo de Preguntas
	oObjP := FWSX1Util():New()
	oObjP:AddGroup(cPerg)
	oObjP:SearchGroup()
	aX1Pre := oObjP:GetGroup(cPerg)

	If Len(aX1Pre[2]) == 0 //No se tiene configurado el grupo de preguntas
		MsgInfo(STR0412 + cPerg, STR0015) //"No se tiene configurado el grupo de preguntas: " "Atención."
		Return Nil
	End

	If Pergunte(cPerg,.T.)
		cSerie  := MV_PAR01
		cDocIni := MV_PAR02
		cDocFin := MV_PAR03
		cRuta   := Alltrim(MV_PAR04)
	
		If lCertR
			cCampos := "% FE_FILIAL, FE_SERIE2 SERIE, FE_NROCERT DOCUMENTO, FE_FORNECE CLIENTE, FE_LOJA LOJA%"
			cTablas  := "% " + RetSqlName("SFE") + " SFE %"
			cCond := "% SFE.FE_SERIE2 = '" + cSerie + "'"
			cCond    += " AND SFE.FE_NROCERT >= '"  + cDocIni + "'"
			cCond    += " AND SFE.FE_NROCERT <= '"  + cDocFin + "'"
			cCond    += " AND SFE.FE_STATUS = '6' %"
			cOrder   := "% SFE.FE_FILIAL, SFE.FE_SERIE2, SFE.FE_NROCERT %"	
		Else
			If Alltrim(cEsp) $ "NF|NDC|RFN"	
				cCampos  := "% SF2.F2_FILIAL, SF2.F2_SERIE SERIE, SF2.F2_DOC DOCUMENTO, SF2.F2_ESPECIE ESPECIE, SF2.F2_CLIENTE CLIENTE, SF2.F2_LOJA LOJA, SF2.F2_MOEDA MONEDA,SF2.F2_SERIE2 SERIE2 %" 
				cTablas  := "% " + RetSqlName("SF2") + " SF2 %"
				cCond    := "% SF2.F2_SERIE = '"  + cSerie + "'"
				cCond    += " AND SF2.F2_DOC >= '"  + cDocIni + "'"
				cCond    += " AND SF2.F2_DOC <= '"  + cDocFin + "'"
				cCond    += " AND SF2.F2_ESPECIE = '"  + cEsp + "'"
				cCond    += " AND SF2.F2_FLFTEX = '6'"
				cCond	 += " AND SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
				cCond	 += " AND SF2.D_E_L_E_T_  = ' ' %"
				cOrder := "% SF2.F2_FILIAL, SF2.F2_SERIE, SF2.F2_DOC %"
			ElseIf Alltrim(cEsp) $ "NCC"
				cCampos  := "% SF1.F1_FILIAL, SF1.F1_SERIE SERIE, SF1.F1_DOC DOCUMENTO, SF1.F1_ESPECIE ESPECIE, SF1.F1_FORNECE CLIENTE, SF1.F1_LOJA LOJA , SF1.F1_MOEDA MONEDA, SF1.F1_SERIE2 SERIE2 %" 
				cTablas  := "% " + RetSqlName("SF1") + " SF1 %"
				cCond    := "% SF1.F1_SERIE = '"  + cSerie + "'"
				cCond    += " AND SF1.F1_DOC >= '"  + cDocIni + "'"
				cCond    += " AND SF1.F1_DOC <= '"  + cDocFin + "'"
				cCond    += " AND SF1.F1_ESPECIE = '"  + cEsp + "'"
				cCond    += " AND SF1.F1_FLFTEX = '6'"
				cCond	 += " AND SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
				cCond	 += " AND SF1.D_E_L_E_T_  = ' ' %"
				cOrder := "% SF1.F1_FILIAL, SF1.F1_SERIE, SF1.F1_DOC %"				
			EndIf
		EndIf
	
		BeginSql alias cAliasTRB
			SELECT %exp:cCampos%
			FROM  %exp:cTablas%
			WHERE %exp:cCond%
			ORDER BY %exp:cOrder%
		EndSql
	
		Count to nRegProc

		If nRegProc > 0
			dbSelectArea(cAliasTRB)
			(cAliasTRB)->(DbGoTop())

			While (cAliasTRB)->(!Eof())
				cEspTRB := IIf(!lCertR,Alltrim((cAliasTRB)->ESPECIE),"")
				cFileGen := Alltrim((cAliasTRB)->SERIE) + Alltrim((cAliasTRB)->DOCUMENTO) + cEspTRB
				cArcCpy  := ""
				Processa({|lEnd| lRet := M486CPYARC(Alltrim((cAliasTRB)->SERIE), Alltrim((cAliasTRB)->DOCUMENTO),cEspTRB,cFileGen,@cArcCpy,.T.,lCertR, cRuta)},STR0421 + Alltrim((cAliasTRB)->SERIE) + Alltrim((cAliasTRB)->DOCUMENTO) + cEspTRB) //"Copiando archivo..."
				If lRet
					cDocProc := (cAliasTRB)->DOCUMENTO + space(14 - Len((cAliasTRB)->DOCUMENTO))+ sPace(2) + ; // Documento
					(cAliasTRB)->SERIE + Space(4) +;    // Serie
					(cAliasTRB)->CLIENTE + Space(4) +;  // Cliente
					(cAliasTRB)->LOJA + space(5)        // Tienda
					aadd(aLog,cDocProc + cArcCpy)       // Archivo
				EndIf
				(cAliasTRB)->(dbskip())
			EndDo
			lLog := MsgYESNO(OemToAnsi(STR0413)) //"Proceso de copiado de XML/PDF finalizado, ¿Desea ver el log?"
			If lLog
				aLogTitle := {STR0414}  //"Documento       Serie  Cliente  Tienda  Archivo"
				aNewLog	  := aClone(aLog)
				aLog      := {}

				If !Empty(aNewLog)
					aAdd( aLog , aClone( aNewLog ) )
				EndIf
				M486LOGPRO(cTitulo, STR0415 + cTipDocto, aLog, aLogTitle) //"Copiado de archivos de "
			EndIf
		Else
			MsgAlert(STR0416) //"No se encontraron Documentos en estatus Autorizado, con los parámetros de filtrado establecidos."
		EndIf
		(cAliasTRB)->(dbCloseArea())
	EndIf
Return Nil

/*/{Protheus.doc} M486CPYARC
Ejecución del proceso de copiado de archivos XML/PDF
@type       Function
@author     luis.enríquez
@since      30/08/2022
@version    1.0
@param		cSerie, caracter, Serie del Documento
@param		cDoc, caracter, Folio del Documento
@param		cEspDoc, caracter, Especie del Documento
@param		cFileGen, caracter, Nombre para el archivo del Documento
@param		cArcCpy, caracter, Archivos XML/PDF copiados
@param		lTSS, lógico, .T. indica que es transmisión con TSS
@param		lCertR, lógico, .T. indica que es un Cert. de Retención
@param		cRuta, caracter, Ruta local donde serán copiados los archivos XML/PDF
/*/
Function M486CPYARC(cSerie, cDoc, cEspDoc, cFileGen, cArcCpy, lTSS, lCertR, cRuta)
	Local aFilesXML := {}
	Local aFilesPDF := {}
	Local cUrl      := ""
	Local cIdEnt    := ""
	Local aDocsC    := {}
	Local lCopia    := .F.

	Private cPath	 := &(SuperGetMV("MV_CFDDOCS",,"")) + "autorizados\" 
	Private oXML     := Nil
	Private nTotPag  := 0
	Private oFont1   := TFont():New( "ARIAL", , 7, .F., .F.)
	Private oFont2   := TFont():New( "ARIAL", , 8, .F., .F.) 
	Private oFont3   := TFont():New( "ARIAL", ,10, .T., .T.)
	Private oFont4   := TFont():New( "ARIAL", , 8, .F., .T.) 
	Private nLinea	 := 0
	Private cPicture := "999,999,999,999.99"
	
	Default cSerie   := ""
	Default cDoc     := ""
	Default cEspDoc  := ""
	Default cFileGen := ""
	Default cArcCpy  := ""
	Default lTSS     := .T.
	Default lCertR   := .F.
	Default cRuta    := ""

	aFilesXML := Directory(cPath + cFileGen + '-ok.xml')

	If !lCertR
		//PDF no aplica para Cert. de Retención
		aFilesPDF := Directory(cPath + cFileGen + '.pdf')
	EndIf

	If Len(aFilesXML) == 0
		If lTSS //Consulta de Status de Documentos en TSS
			cUrl   := GetNewPar("MV_WSRTSS","")
			cIdEnt := GetIdEnt()
			If !lCertR //Notas Fiscales
				Processa({|lEnd| aDocsC := M486GETINF(cSerie, cDoc, cDoc)}, STR0148) //"Obteniendo Información"
			Else //Cert. de Retención
				Processa({|lEnd| aDocsC := M486GETCR(cSerie,cDoc,cDoc)}, STR0148) //"Obteniendo Información"
			EndIf
			Processa({|lEnd| M486GETTSS(aDocsC, cIdEnt, cURL)},STR0149)	//"Consultando TSS ... aguarde..."	
		EndIf
		aFilesXML := Directory(cPath + cFileGen + '-ok.xml')
	EndIf

	//Copiado del XML
	If Len(aFilesXML) > 0
		lCopia := .T.
		CpyS2T(cPath + cFileGen + "-ok.xml", cRuta,,.F.)
		cArcCpy += cFileGen + "-ok.xml"
	EndIf
	
	If !lCertR 
		//PDF no aplica para Cert. de Retención
		//Copiado del PDF
		If Len(aFilesPDF) == 0
			cDocIni := cDoc
			cDocFin := cDoc
			cFormato:= 1
			Processa({|| ImpXmlPDF(cEspDoc, .F.)},STR0418, STR0419) //"Espere..." "Generando impresión de documento autorizado"
			aFilesPDF := Directory(cPath + cFileGen + '.pdf')
		EndIf
		If Len(aFilesPDF) > 0
			lCopia := .T.
			CpyS2T(cPath + cFileGen + ".pdf", cRuta,,.F.)
			cArcCpy += "/" + cFileGen + ".pdf"
		EndIf
	EndIf
Return lCopia

/*/{Protheus.doc} M486LOGPRO
Creación del LOG de Procesos
@type       Function
@author     luis.enríquez
@since      30/08/2022
@version    1.0
@param		cTitulo, caracter, Titulos principal para el LOG
@param		cTitRep, caracter, Titulo inferior para el LOG
@param		aLog, arreglo, Listado de LOG
@param		aLogTitle, arreglo, Listado de Titulos para cada LOG
/*/
Function M486LOGPRO(cTitulo, cTitRep, aLog, aLogTitle)
	Local cTamanho	:= "M"
	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"

	Private wCabec1 := ""

	Default cTitulo   := ""
	Default cTitRep   := ""
	Default aLog      := {}
	Default aLogTitle := {}

	wCabec1 := cTitRep

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
	MsAguarde( { ||fMakeLog( aLog ,aLogTitle , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},STR0015) // "Generando Log de errores..."
Return Nil
