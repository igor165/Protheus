#INCLUDE "GPEM884.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#Include "RPTDEF.CH"
#INCLUDE "FONT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±| Programa    ³ GPEM884  ³ Autor ³ ARodriguez         ³Fecha ³ 27/04/2021    |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±| Desc.       ³ Volante de Pago Electrónico - Colombia                       |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±| Uso         ³ SIGAGPE                                                      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|           ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL           |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±| Programador ³  Fecha   ³ Motivo de Alteración                              |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|ARodriguez   ³27/04/2021³DMINA-11443 Construcción inicial.                  |±±
±±|Alf Medrano  ³23/07/2021³DMINA-12636 Implementación de requerimientos.      |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPEM884()
Local cPerg     := "GPEM884"

Private cTitulo		:= STR0001	//"Volante de Pago Electrónico"
Private cProceso	:= ""		// mv_par01 ¿Proceso?
Private cRoteiro	:= ""		// mv_par02 ¿Procedimiento?
Private cPeriodo	:= ""		// mv_par03 ¿Periodo?
Private cSucursal	:= ""		// mv_par04 ¿Sucursal?
Private cCCosto		:= ""		// mv_par05 ¿Centro de Costos?
Private cArea		:= ""		// mv_par06 ¿Area?
Private cMatricula	:= ""		// mv_par07 ¿Matrícula?
Private cSituacion	:= ""		// mv_par08 ¿Situacion?
Private cCategoria	:= ""		// mv_par09 ¿Categoria?
Private cMensaje1	:= ""		// mv_par10 ¿Mensaje 1?
Private cMensaje2	:= ""		// mv_par11 ¿Mensaje 2?
Private cMensaje3	:= ""		// mv_par12 ¿Mensaje 3?
Private cMensajeXML	:= ""		// mv_par13 ¿Mensaje XML?
Private nTipoXML	:= ""		// mv_par14 ¿Tipo XML?
Private nGnraNom	:= ""		// mv_par15 ¿1 = Visualizar PDF / 2 = Enviar por email / 3= Ninguna?
Private nSDcsTpTrans:= 0		// mv_par16 ¿Tipo de transmision?
Private cComplPrdt	:= ""		// mv_par17 ¿Complemento Procedimiento?
Private nAnoMes		:= 0		// Ano/Mes a presentar
Private cProvFE		:= ""		// Proveedor de factura electrónica
Private cTokenEmp	:= ""		// Token empresa
Private cTokenPwd	:= ""		// Token password
Private cCompanyId	:= ""		// Company Id
Private cMailServe	:= ""		// Server (puede contener puerto)
Private nMailPort	:= 0		// Puerto (opcional)
Private cMailConta	:= ""		// Cuenta utilizada para envío de email
Private cMailSenha	:= ""		// Contraseña para autenticación en servidor de e-mail
Private lAuth		:= .F.		// Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao
Private cUser		:= ""		// Usuario para Autenticación en el Servidor de Email
Private lUseTLS		:= .F.	    // Define se o envio e recebimento de E-Mail utilizara conexao segura (SSL/TLS)
Private lUseSSL		:= .F.		// Define se o envio e recebimento de E-Mail utilizara conexao segura (SSL)
Private cPathCan	:= ""		// Ruta de documentos cancelados
Private aFechasPer	:= {}		// Fechas de inicio, fin y pago
Private cFchPerIni 	:= "" 		// Fecha Inicio del periodo RCH
Private cFchPerFin 	:= "" 		// Fecha Fin del periodo RCH
Private cPathDocs	:= "" 		// Ruta donde seran guardados los archivos xml
Private cSerieVolP	:= ""		// Serie para generar prefijo de Volante electronico para ambiente Poducción
Private cSerieVolT	:= ""		// Serie para generar prefijo de Volante electronico para ambiente Pruebas
Private cSerieVAjP	:= ""		// Serie para generar prefijo de ajuste del Volante electronico para ambiente Poducción
Private cSerieVAjT	:= ""		// Serie para generar prefijo de ajuste del Volante electronico para ambiente Pruebas
private cSerieVolE	:= ""		// Serie del volante electrónico
Private cURLAmbPrd	:= ""		// Url Ambiente Producción
Private cURLAmbTsT	:= ""		// Url Ambiente Pruebas

FormBatch(cTitulo,;
	{OemToAnsi(STR0002),OemToAnsi(STR0003),OemToAnsi(STR0004)},;
    { { 5,.T.,{|o| Pergunte(cPerg,.T.) }},;
      { 1,.T.,{|o| IIf(GM884Valid(cPerg), (FechaBatch(),Processa({||GM884Proc(cPerg)})), Nil)}},;
      { 2,.T.,{|o| FechaBatch()}}})

Return Nil


/*/{Protheus.doc} GM884Valid
Validaciones previas a la transmisión
@author alfredo Medrano
@since 08/07/2021
@version 1.0
@return Nil
@param cPerg
/*/
Static Function GM884Valid(cPerg)
Local aArea		:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local cProceso	:= MV_PAR01 //¿Proceso?
Local cRoteiro	:= MV_PAR02 //¿Procedimiento?
Local cPeriodo	:= MV_PAR03 //¿Periodo?
Local nTipTrans	:= MV_PAR16	//¿Tipo de transmision? 1 Producción/ 2 Prueba
Local lCerrados	:= .T.
Local cMsg		:= ""
Local lRet		:= .T.
Local nFor		:= 0
Local nTamArr	:= {}

Pergunte(cPerg , .F. )

If Empty(cProceso) .Or. Empty(cRoteiro) .Or. Empty(cPeriodo)
	MsgAlert( STR0006 , STR0005)	//"Debe indicar el proceso, procedimiento y periodo a informar."##"Atención"
	Return .F.
EndIf

RCH->(dbSetOrder(4)) // RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG

BeginSql Alias cAliasQry
	SELECT
		RCH_ANO, RCH_MES, RCH_STATUS, RCH_NUMPAG, RCH_DTINI, RCH_DTFIM, RCH_DTPAGO
	FROM
		%table:RCH% 
	WHERE
		RCH_FILIAL = %xFilial:RCH% AND
		RCH_PROCES = %exp:cProceso% AND
		RCH_ROTEIR = %exp:cRoteiro% AND
		RCH_PER = %exp:cPeriodo% AND
		%notDel%
	ORDER BY
		%Order:RCH%
EndSql

nAnoMes := 0
aSize(aFechasPer, 0)

Do While (cAliasQry)->(!Eof())
	// Determina AAMM del periodo
	If nAnoMes == 0
		nAnoMes := (cAliasQry)->(VAL(RCH_ANO) * 100 + VAL(RCH_MES))
	EndIf
	// Valida que todos los cálculos (NumPag) estén cerrados
	If !((cAliasQry)->(VAL(RCH_STATUS)) == 5)
		lCerrados := .F.
		//Exit
	EndIf
	// Arreglo con fechas de NumPag: Inicio , Fin , Pago, comodín 
	aAdd( aFechasPer , {(cAliasQry)->RCH_NUMPAG,(cAliasQry)->RCH_DTINI,(cAliasQry)->RCH_DTFIM,(cAliasQry)->RCH_DTPAGO,0} )

	(cAliasQry)->(dbSkip())
Enddo

(cAliasQry)->(DbCloseArea())	
RestArea(aArea)

// obtiene la Fecha inicio del periodo y la fecha Fin (RCH)
// El periodo es mensual, aunque puede contener pagos semanales, quincenales o mensuales)
nTamArr := Len(aFechasPer)
For nFor := 1 to nTamArr
	
	If nTamArr == 1
		cFchPerIni := aFechasPer[nFor,2] // la primera fecha del periodo
		cFchPerFin := aFechasPer[nFor,3] //la ultima fecha del periordo
	Else
		If nFor == 1
			cFchPerIni := aFechasPer[nFor,2] // la primera fecha del periodo
		ElseIf nFor == nTamArr
			cFchPerFin := aFechasPer[nFor,3] //la ultima fecha del periordo
		EndIf
	Endif
Next nFor



If nAnoMes == 0
	MsgAlert( STR0007 , STR0005)	//"No se encontraron periodos para informar."##"Atención"
	Return .F.
EndIf

// Parámetros del WS y para envío de correo
cSerieVolP	:= SuperGetMV("MV_SERVOLP",,"")		
cSerieVolT	:= SuperGetMV("MV_SERVOLT",,"")	
cSerieVAjP	:= SuperGetMV("MV_SERVLAP",,"")		
cSerieVAjT	:= SuperGetMV("MV_SERVLAT",,"")			
cProvFE		:= SuperGetMV("MV_PROVFE",,"")		
cTokenEmp	:= SuperGetMV("MV_TKN_EMP",,"")		
cTokenPwd	:= SuperGetMV("MV_TKN_PAS",,"")		
cCompanyId	:= SuperGetMV("MV_COMPID",,"")		
cMailServer	:= SuperGetmv("MV_RELSERV", .F., "")
nMailPort	:= SuperGetmv("MV_SRVPORT", .F., 25)
cMailConta	:= SuperGetmv("MV_RELACNT", .F., "")
cMailSenha	:= SuperGetmv("MV_RELAPSW", .F., "")
lAuth		:= SuperGetmv("MV_RELAUTH", .F., .F.)
cUser		:= SuperGetmv("MV_RELAUSR", .F., "")
lUseTLS		:= SuperGetmv("MV_RELTLS", .F., .F.)
lUseSSL		:= SuperGetmv("MV_RELSSL", .F., .F.)
cPathDocs	:= SuperGetMV("MV_CFDRECN",,"")	
cPathCan	:= cPathDocs + "cancelados\"
cURLAmbPrd	:= SuperGetMV("MV_WSNOMP",,"")
cURLAmbTsT	:= SuperGetMV("MV_WSNOMT",,"")	


If nTipTrans == 2 // pruebas
	cTokenEmp	:= SuperGetMV("MV_TKNEMPT",,"")		
	cTokenPwd	:= SuperGetMV("MV_TKNPAST",,"")	 
Endif

If Empty(cPathDocs) .OR. !ExistDir(&cPathDocs)
	cMsg += STR0010 + CRLF		//"MV_CFDRECN Ruta para guardar los documentos."
EndIf

If Empty(cProvFE)
	cMsg += STR0013 + CRLF		//"MV_PROVFE Identificación del Proveedor Tecnológico."
EndIf

If Empty(cTokenEmp) .and. nTipTrans == 1 // produccion
	cMsg += STR0014 + CRLF		//"MV_TKN_EMP Token empresa."
EndIf

If Empty(cTokenPwd) .and. nTipTrans == 1 // produccion
	cMsg += STR0015 + CRLF		//"MV_TKN_PAS Token password."
EndIf

If Empty(cMailServer)
	cMsg += STR0017 + CRLF		//"MV_RELSERV url del servicio de correo electrónico."
EndIf

If Empty(cMailConta)
	cMsg += STR0018 + CRLF		//"MV_RELACNT Cuenta utilizada para envío de email." 
EndIf

If Empty(cMailSenha)
	cMsg += STR0019 + CRLF		//"MV_RELAPSW Contraseña para autenticación en servidor de e-mail."
EndIf

If nTipTrans == 1 
	If Empty(cSerieVolP)
		cMsg += STR0021  + CRLF		//"MV_SERVOLP Serie para obtener el prefijo del volante electrónico en ambiente de producción "
	EndIf
	If Empty(cURLAmbPrd)
		cMsg += STR0039 + CRLF	 //"MV_WSNOMP Url del WS para transmisión de volante electrónico ambiente de producción" 
	Endif
	If Empty(cSerieVAjP)
		cMsg +=  STR0060 + CRLF		//"MV_SERVLAP Serie para obtener el prefijo de ajuste del volante electrónico en ambiente de producción"
	EndIf
EndIf
If nTipTrans == 2
	If Empty(cSerieVolT)
		cMsg += STR0022  + CRLF		//"MV_SERVOLT Serie para obtener el prefijo del volante electrónico en ambiente de pruebas"
	EndIf
	If Empty(cURLAmbTsT)
		cMsg += STR0040 + CRLF //"MV_WSNOMT Url del WS para transmisión de volante electrónico ambiente de pruebas"	
	Endif
	If Empty(cSerieVAjT)
		cMsg +=  STR0061 + CRLF		//"MV_SERVLAT Serie para obtener el prefijo de ajuste del volante electrónico en ambiente de pruebas"
	EndIf
EndIf

If !Empty(cMsg)
	MsgAlert( OemToAnsi(STR0020 + CRLF + cMsg) , OemToAnsi(STR0005) )	//"Se encontraron estas inconsistencias o faltan configuraciones:"##"Atención"
	lRet := .F.
EndIf

Return lRet



/*/{Protheus.doc} GM884FFile
Verifica si existen Archivos Xml (Ordinario o Ajuste)
@author alfredo Medrano
@since 30/09/2021
@version 1.0
@return Nil
/*/
Static Function GM884FFile()
	Local cAviso   := ""
	Local cErro    := ""
	Local lRet	   := .T. 
	Local cFileOrd	:= ""
	Local cFileAju	:= ""
	Local cNomArch	:= ""
	Local lAjusArc	:= .F.

	cFileOrd := cFilePathH+ "\" + cArchivoSmp + "_O" + cIndicador 
	cFileAju := cFilePathH+ "\" + cArchivoSmp + "_A" + cIndicador 

	If File(cFileAju + ".xml") // busca si existe archivo de ajuste para ajustar o Eliminar 
		oXML := XmlParserFile(cFileAju + ".xml", "_", @cAviso,@cErro )
		cNomArch :=  cArchivoSmp + "_A" + cIndicador 
		cArchAjus := cFileAju  
		cTpAjust := "A"
		lAjusArc := .T.
	ElseIf  File(cFileOrd + ".xml") // busca archivo Ordinario para ajustar o Eliminar
		oXML := XmlParserFile(cFileOrd + ".xml", "_", @cAviso,@cErro )
		cNomArch :=  cArchivoSmp + "_O" + cIndicador
		cArchAjus := cFileOrd 
		cTpAjust := "O"
		lAjusArc := .T.
	EndIf

	If !lAjusArc
		aAdd(aLog , { Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F., STR0069 + cArchivoSmp, STR0005 ,'','','' } ) //"No existen documentos previamente generados para realizar el Ajuste. ""Error."
		lRet := .F.
	EndIf
	If lRet .and. oXML == Nil
		aAdd(aLog , { Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F., STR0067 + " " + cMsjOAC + " (" + cNomArch + ".xml ) " + STR0068, STR0044 ,'','','' } ) //"El documento" // "Ordinario" - "Ajuste" - "Cancelación" //"no pudo procesarse para el ajuste."//"Error."
		lRet := .F.
	Endif

Return lRet 


/*/{Protheus.doc} GM884Proc
Proceso de generacion XML.
@author arodriguez
@since 05/07/2021
@version 1.0
@return Nil
@param cPerg
/*/
Static Function GM884Proc(cPerg)
	Local aArea			:= GetArea()
	Local nReg			:= 0
	Local CSitQuery		:= ""
	Local cCatQuery		:= ""
	Local cQuery		:= ""
	Local lAceptado		:= .F.
	Local nFor			:= 0
	Local nLenLog		:= 0
	Local cXML			:= ""
	Local cSRATab		:= '%'+RetSqlName('SRA')+'%' 
	Local cTiposMvo		:= ""
	Local cResult		:= ""
	Local lProcesa		:= .T.
	Local msgLogEnv		:= ""
	Local msgLogErr		:= ""
	Local cProdIn		:= ""
	Local  nX	  		:= 0
	Local aArchNov		:= {}
	Local cMsgNov		:= ""

	
	private oExtensibles:= Nil

	Private cQuerySRC	:= ""
	Private cQuerySRD	:= ""

	Private cQrySRCNov	:= ""
	Private cQrySRDNov	:= ""

	Private cAliasSRA   := GetNextAlias()
	Private oWS
	Private nDeven		:= 0
	Private nDeduc		:= 0
	Private nTotal		:= 0
	Private aLog		:= {}
	Private aLogMail	:= {}
	Private aMensajes	:= {}
	Private aDatosSM0	:= {}
	Private aSTipHrExt 	:= {} 
	Private cSR8Tab		:= '%'+RetSqlName('SR8')+'%' 
	Private cSRDTab		:= '%'+RetSqlName('SRD')+'%' 
	Private cSRCTab		:= '%'+RetSqlName('SRC')+'%' 
	Private cSRVTab		:= '%'+RetSqlName('SRV')+'%' 
	Private cTipoXmlDs	:= ""
	Private cIndicador	:= ""
	Private cSPrefCons  := 0 // Consecutivo documeto 
	Private cSURLAmbnt	:= ""
	Private cArchivoXML	:= ""
	Private cidSoft 	:= ""
	Private cnitEmp 	:= ""

	
	Private aNomina		:= {} //Proceso+Procedimiento+Periodo+Matricula
	Private aSBonifica 	:= {} //Bonificaciones
	Private	aSCompensa	:= {} // Compensaciones		
	Private aSComision  := {} // Comisiones
	Private aSIncidenc	:= {} // Incidencias
	Private aSAuxilio	:= {} // Auxilio 	
	Private aSOtroConc  := {} // Otros conceptos
	Private aSLicencia  := {} // Licencias  Materinidad/Paternidad, Remunerada y no Remunerada
	Private aSVacacion 	:= {} // Vacaciones comunes
	Private aSVacaComp  := {} // Vacaciones compensadas
	Private aSHorasExt	:= {} // Horas Extras
	Private aSHuelgas	:= {} // Huelgas legales
	Private aSIncapaci  := {} // Incapacidades
	Private aSPagoTerc	:= {} // Pagos Terceros
	Private aSTranspor 	:= {} // Transporte
	Private aSBonEPCTV	:= {} // Bono EPCTV
	Private cSPeriNom	:= "" // Periodo Nómina RCJ->RCJ_PERIOD
	Private nSRedondeo 	:= 0  // Redondeo en el documento
	Private aSAnticipo 	:= {} // Anticipos
	Private nSApoyoSos 	:= 0 // Apoyo Sos
	Private nSDotacion 	:= 0 // Dotación
	Private nSTelTraba 	:= 0 // Teletrabajo
	Private nSBonifRet 	:= 0 // Bonificación Retiro
	Private nSIndenmni 	:= 0 // Indemnización
	Private nSReintegr 	:= 0 // Reintegro
	Private	nSDiasTrab 	:= 0 // Dias Trabajados
	private nSSueldoTr 	:= 0 // Sueldo trabajado
	Private nSPgoCesPr 	:= 0 // Porcentaje de Interes de Cesantias 
	Private cSOtroTipo	:= ""// Tipo Incapacidad
	Private nSDiaPrima 	:= 0 // Dias Prima
	Private nSPagPrima 	:= 0 // Pago Dias Prima
	Private nSPgPriNoS 	:= 0 // Pago Dias Prima No Salarial
	Private nSDocsProc	:= 0 // contabiliza los doctos procesados
	Private nSDcsTrans 	:= 0 // contabiliza los doctos transmitidos
	
	Private aSSancion	:= {} // Sanciones
	Private aSPagTerce	:= {} // Pago tercero
	Private aSAnticipD  := {}// Anticipo Deducciones
	Private aSLibranza	:= {} // Libranza
	Private aSOtraDedu	:= {} // Otra Deducción
	Private aSSindicat	:= {} // Sindicatos
	Private aSCesantia	:= {} // Cesantia
	Private nSAFC		:= 0 // AFC
	Private nSCooperat	:= 0 // Cooperativa
	Private nSDeuda		:= 0 // Deuda
	Private nSEduca 	:= 0 // Educación 
	Private nSEmbarFis 	:= 0 // Embargo Fiscal 
	Private nSPlanComS	:= 0 // Plan complementario Salud
	Private nSPensionV	:= 0 // Pension Voluntaria
	Private nSReintegD	:= 0 // Reintegro
	Private nSRtFuente  := 0 // Retención Fuente
	Private nSFdPenDed 	:= 0 // Fondo pensión
	Private nSPrPenDed 	:= 0 // porcentaje pensión
	Private nSFonDePrj	:= 0 // Porcentaje Fondo SP
	Private nSFonDedSP	:= 0 // Deducción Fondo SP
	Private nSFonPrSub	:= 0 // Porcentaje Sub Fondo SP
	Private nSFonDeSub	:= 0 // Deducción Sub Fondo SP
	Private nSSaludDed  := 0 // Salud deducción
	Private nSSaludPor  := 0 // Salud porcentaje
	Private cFilePathP	:= ""
	Private cFilePathH	:= ""
	Private cArchAjus	:= ""
	Private cArchivoSmp	:= ""
	private cPrefNum	:= ""
	Private cTpAjust	:= ""
	Private cMsjOAC		:= ""
	Private oXML	    := Nil
	Private cEPSSalud   := fTabela('S004',1,4) // %Salud - Eps Salud
	Private cAFPPensi   := fTabela('S004',1,6) // %Pensión - AFP trabajador

	Private lSal := .F.
	Private lNovedadOK := .F.
	Private lCalcNove := .T. 
	Private cCUNENove := ""

	Private cSalinteg  := ""
	Private cSTipoTrab := ""
	Private cSubTpTrab := ""
	private cAltoRsgPn := ""
	Private nSueldoEm  := 0

	Private nContNov := 0
	Private aNovedades := {}
	Private aFechasNov := {}
	Private cFchPrNovI := ""
	Private cFchPrNovF := ""
	Private cFechaNovS := ""
	Private nPorcent := 1
	private aSalDiaQ := {}

	Private nDeduccT := 0
	Private nDevengT := 0



	CursorWait()

	
	MakeSqlExpr(cPerg)

	cProceso	:= MV_PAR01 //¿Proceso?
	cRoteiro	:= MV_PAR02 //¿Procedimiento ?
	cPeriodo	:= MV_PAR03 //¿Período ?  
	cSucursal	:= MV_PAR04	//¿Rango Sucursal ?             
	cCCosto		:= MV_PAR05	//¿Rango Centro de Costo ?      
	cArea		:= MV_PAR06	//¿Rango de Área ?              
	cMatricula	:= MV_PAR07	//¿Rango de Matrícula ?         
	cSituacion	:= MV_PAR08 //¿Situaciones ?                
	cCategoria	:= MV_PAR09 //¿Categorias ?                 
	cMensaje1	:= MV_PAR10 //¿Mensaje 1 ?                  
	cMensaje2	:= MV_PAR11 //¿Mensaje 2 ?                  
	cMensaje3	:= MV_PAR12 //¿Mensaje 3 ?                  
	cMensajeXML	:= MV_PAR13 //¿Mensaje XML ?                
	nTipoXML	:= MV_PAR14	//¿Tipo XML ?   Ordinaria/Ajuste/Cancelación
	nGnraNom	:= MV_PAR15 //¿Generar ? 1 = Visualizar PDF / 2 = Enviar por email / 3= Ninguna?
	nSDcsTpTrans:= MV_PAR16	//¿Tipo de Transmisión ?   Producción/Prueba
	cComplPrdt  := MV_PAR17 //¿Procedimiento Complemento? Rango  
	cTipoXmlDs := ""
	nSDcsTrans := 0

	If nTipoXML == 1
		cTipoXmlDs := 'O' //Odinaria
		cMsjOAC := STR0066
	ElseIf nTipoXML == 2  
		cTipoXmlDs := 'A' // AJuste
		cMsjOAC := STR0064
	ElseIf nTipoXML == 3 
		cTipoXmlDs := 'C' // Cancelación
		cMsjOAC := STR0065
	Endif

	
	If nSDcsTpTrans == 1 // producción
		cSerieVolE := cSerieVolP
		If nTipoXML > 1 // ajuste o cancelación
			cSerieVolE := cSerieVAjP
		Endif
		cSURLAmbnt := cURLAmbPrd
	ElseIf nSDcsTpTrans == 2 // pruebas
		cSerieVolE := cSerieVolT
		If nTipoXML > 1 // ajuste o cancelación
			cSerieVolE := cSerieVAjT
		Endif
		cSURLAmbnt := cURLAmbTsT
		cIndicador := "P"
	EndIf

	If nGnraNom == 1
		msgLogErr := STR0070 //"Ocurrieron inconvenientes en la visualización de los archivos. ¿Desea visualizar el log?"
		msgLogEnv := STR0071 //"Visualización de archivos exitosa. ¿Desea visualizar el log?"
	ElseIf nGnraNom == 2
		msgLogErr := STR0046 //"Ocurrieron inconvenientes en el envío de correo. ¿Desea visualizar log de envío ?"
		msgLogEnv := STR0047 //"Envío de correo exitoso. ¿Desea visualizar log de envío?"
	Else
		msgLogErr := STR0023 //"Ocurrieron inconvenientes al momento de la transmisión. ¿Desea visualizar log de Transmisión?"
		msgLogEnv := STR0024 // "Transmisión exitosa. ¿Desea visualizar log de Transmisión?"
	Endif

	aDatosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , {"M0_ESTCOB","M0_CODMUN","M0_CGC"})
	
	// Tabla de Processos //
	DbSelectArea("RCJ")
	RCJ->( DbSetOrder(1) ) //RCJ_FILIAL+RCJ_CODIGO
	RCJ->( DbSeek( xFilial("RCJ") + cProceso , .F. ) )
	If !(RCJ->(Eof()))
		cSPeriNom := RCJ->RCJ_PERIOD
		nSPgoCesPr := RCJ->RCJ_PORINT
	EndIf

	// Mensajes { {Filial, Msj} }
	aMensajes := fMensajes()

	//Tipo Hrs Extras 
	//1-TipoXML,2-Cod HoraExtra,3-Diurno/Nocturno,4-Porcentaje Tabla 15 (Tipo de Hora Extra)
	aSTipHrExt := {{"113","0","D","25.00"},{"114","3","D","100.00"},{"115","1","N","75.00"},;
				  {"116","5","N","150.00"},{"117","4","D","75.00"},{"118","2","N","35.00"},{"119","6","N","110.00"}}

	//Tipo XML - se informa en el Query
	cTiposMvo := "'223','102','103','112','131','107','123','130','105','106','108','124','109','111','110' '113','114','115','116','117','118','119'" 
	

	// Filtro para Situaciones -
	For nReg := 1 To Len( cSituacion )
		cSitQuery += "'" + Subs( cSituacion , nReg , 1 ) + "'"
		If ( nReg + 1 ) <= Len( cSituacion )
			cSitQuery += ","
		Endif
	Next nReg

	For nReg := 1 To Len(cCategoria )
		cCatQuery += "'" + Subs( cCategoria , nReg , 1 ) + "'"
		If ( nReg + 1 ) <= Len( cCategoria )
			cCatQuery += ","
		Endif
	Next nReg

	If !Empty( cProceso )// Proceso
		cQuerySRD +=" AND SRD.RD_PROCES = '" + cProceso + "'"
		cQuerySRC +=" AND SRC.RC_PROCES = '" + cProceso + "'"
	EndIf

	If !Empty( cRoteiro )// Procedimiento
		nPosIn := AT('IN', cComplPrdt)
		If nPosIn > 0
			cProdIn := Substr(cComplPrdt,nPosIn + 3, len(cComplPrdt) - (nPosIn + 4) )
		Endif
	
		cQuerySRD +=" AND SRD.RD_ROTEIR IN ('" + cRoteiro + "'" + IIf(!EMPTY(cProdIn),  "," + cProdIn,"") + ")"
		cQuerySRC +=" AND SRC.RC_ROTEIR IN ('" + cRoteiro + "'" + IIf(!EMPTY(cProdIn),  "," + cProdIn,"") + ")"
	EndIf

	If !Empty( cPeriodo )// Periodo
		cQuerySRD +=" AND SRD.RD_PERIODO = '" + cPeriodo + "'"
		cQuerySRC +=" AND SRC.RC_PERIODO = '" + cPeriodo + "'"
	EndIf

	cQrySRCNov	:= cQuerySRC
	cQrySRDNov	:= cQuerySRD

	cQuerySRD := '%'+cQuerySRD+'%'
	cQuerySRC := '%'+cQuerySRC+'%'

	
	
	If !Empty( cSucursal )//Sucursal
		cQuery += " AND " + cSucursal
	EndIf
	If !Empty( cCCosto )// Centro de costo
		cQuery += " AND " + cCCosto
	EndIf
	If !Empty( cArea )// Area
		cQuery += " AND " + cArea
	EndIf
	If !Empty( cProceso )// proceso
		cQuery += " AND RA_PROCES = '" + cProceso + "'"
	EndIf
	If !Empty( cMatricula )// Matricula
		cQuery += " AND " + cMatricula
	EndIf
	If  !Empty(cSitQuery) //Situacion
		cQuery += "   AND RA_SITFOLH IN ("+cSitQuery+")"
	Endif
	If  !Empty(cCatQuery) //Categoria
		cQuery += "   AND RA_CATFUNC IN ("+cCatQuery+")"
	Endif
	cQuery := '%'+cQuery+'%'

	oWS := WSNominaCol():NEW()
	oWS:_URL := cSURLAmbnt //URL ambiente Pruebas/Producción


	BeginSql alias cAliasSRA
		SELECT RA_FILIAL, RA_MAT, RA_CC, RA_NOME, RA_KEYLOC, RA_RG, RA_ADMISSA,RA_DEMISSA, RA_MUNICIP, RA_ESTADO,RA_CATFUNC,;
		RA_TIPCOT, RA_SUBCOT, RA_PORAFP, RA_TPCIC, RA_CIC,RA_PRISOBR,RA_SECSOBR,RA_PRINOME,RA_SECNOME,RA_ENDEREC,RA_DEMISSA,;
		RA_COMPLEM,RA_BAIRRO, RA_ESTADO, RA_MUNICIP , RA_TIPOSAL, RA_TIPOCO,RA_SALARIO, RA_EMAIL,RA_BCOHAB,RA_CTDEPSA,RA_TIPOHAB,;
		RA_FORPAG, RA_SITFOLH, RA_HRSMES
		FROM %exp:cSRATab% SRA
		WHERE SRA.%NotDel%  %exp:cQuery%
		ORDER BY RA_FILIAL,RA_MAT,RA_CC,RA_DEPTO
		
	EndSql

	Do While (cAliasSRA)->(!Eof())
	
		lProcesa	:= .T.
		oXML 		:= Nil
		cSPrefCons 	:= "" // consecutivo del documento
		cTpAjust  	:= ""
		cPrefNum  	:= ""
		cArchAjus 	:= ""
		cArchivoSmp := AllTrim((cAliasSRA)->RA_FILIAL) + "_" + AllTrim(cProceso) + "_" + AllTrim(cRoteiro) + "_" + AllTrim(cPeriodo) + "_" +AllTrim((cAliasSRA)->RA_MAT) 
		cArchivoXML := cArchivoSmp + "_" + cTipoXmlDs + cIndicador
		cFilePathP 	:= &cPathDocs + AllTrim((cAliasSRA)->RA_FILIAL) + "_" + AllTrim(cProceso) + "_" + Substr(cPeriodo,1,4) + cIndicador  
		cFilePathH 	:= cFilePathP + "\" + AllTrim(cRoteiro) + "_" + AllTrim(cPeriodo) + cIndicador
		nSDocsProc++ // contabiliza los doctos procesados
		cSalinteg  := (cAliasSRA)->RA_TIPOSAL
		cSTipoTrab := (cAliasSRA)->RA_TIPCOT
		cSubTpTrab := (cAliasSRA)->RA_SUBCOT
		cAltoRsgPn := (cAliasSRA)->RA_PORAFP
		nSueldoEm  := (cAliasSRA)->RA_SALARIO
		nPorcent := 1
		nDeduccT := 0
		nDevengT := 0

		cCUNENove := ""
		cFchPrNovI := ""
		cFchPrNovF := ""
		cMsgNov := ""
		
		If nGnraNom == 1 // Visualizar PDF 
			GM884FnPDF()
			lProcesa := .F.
		EndIf
		If nGnraNom == 2 // Envio de Email
			M884Email()
			lProcesa := .F.
		EndIf

		If lProcesa .and. nTipoXML > 1 // Ajuste // Cancelación
			If !GM884FFile() // verifica si existe archivo .xml ordinario o de ajuste 
				lProcesa := .F.
			Endif
		EndIf
		//Novedades
		If lProcesa .and. nTipoXML == 1 // solo si es ordinaria
			If lCalcNove
				If lNovedadOK := ExsNovedad(@aNovedades) //Obtienen novedades
					If!BuscaMovEmp() // No tiene movimientos en el mes
						lNovedadOK := .F.
						lProcesa := .F.
					Else
						AsigValNov(@lSal, @cFechaNovS,@aSalDiaQ) // obtiene registros de array aNovedades y asigna valores anteriores a la novedad
					EndIf
				EndIf
			EndIf
			If lNovedadOK
			// accede a buscar CUNE solo cuando el documento ordinario haya sido enviado		
				If nContNov > 0 
					cMsgNov := STR0084//"Novedad"
					If !M884BusArc("XML", .T., '','','',@cCUNENove) // obtiene CUNE
						aAdd(aLog , { Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F., STR0062 + cMsjOAC +" (" + cArchivoXML + ".xml ) " + STR0081 + STR0085 ,STR0005,'','','' } ) //"Documento" // Novedad //"No existen documentos "// " XML previamente generados para la novedad del empleado."//"Atención"
						lNovedadOK := .F.
						lProcesa := .F.
					EndIf 
					cArchivoXML := cArchivoSmp + "_N"+ cIndicador // nombre archivo novedad
				EndIf

				If lNovedadOK 
					nContNov++
					// obtiene fechas inicio/fin y el porcentaje proporcional que se aplicará a las nominas(Ordinaria y novedad)
					IF !obtFchNov(@cFchPrNovI,@cFchPrNovF,@nPorcent)
						lNovedadOK := .F.
						lProcesa := .F.
					EndIf
				Endif
			Endif
		Else 
			lNovedadOK := .F.
		Endif

		If lProcesa .and. (nTipoXML == 1 .OR. nTipoXML == 3) .and. File(cFilePathH+ "\" +cArchivoXML + ".xml")  
			aAdd(aLog , { Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F., STR0062 + " " + cMsjOAC + " (" + cArchivoXML + ".xml ) " + STR0063,STR0005,'','','' } ) //"Documento" // "Ordinario" - "Ajuste" - "Cancelación" //"previamente transmitido."//"Atención"
			lProcesa := .F.
			nContNov := 0
			lNovedadOK := .F.
		Endif

		If lProcesa		
			If  GM884MovEm() //Obtiene Ausencias e incidencias del empleado
				oWS:owsRequest:oWSnomina := Service_NominaGeneral():New()		
				aNomina := {cProceso,cRoteiro,cPeriodo,(cAliasSRA)->RA_MAT}

				// Generales
				GM884General(oWS)

				If nTipoXML > 1 // Solo se informa para Ajustes
					// Documentos referenciales
					GM884Docs(oWS) 
				Endif

				// Lugar de generación del XML
				GM884Lugar(oWS)

				If nTipoXML < 3 // si es cancelacion no se informan 
					// Periodos <Array>
					GM884Periodo(oWS)

					// Empleado
					GM884Trab(oWS)

					// Devengados <array>
					GM884Deven()

					// Deducciones <array>
					GM884Deduc()

				Endif

				// Notas
				GM884Notas(oWS)

				// Pago <array>
				GM884Pago(oWS)

				If 	lNovedadOK 
					 nDeduc := nDeduccT
					 nDeven := nDevengT
					 nTotal := nDevengT - nDeduccT
				EndIf
				oWS:owsRequest:oWSnomina:ctotalComprobante := lTrim(Str(nTotal ,18,2))
				oWS:owsRequest:oWSnomina:ctotalDeducciones := lTrim(Str(nDeduc ,18,2))
				oWS:owsRequest:oWSnomina:ctotalDevengados := lTrim(Str(nDeven ,18,2))

				If oWS:Enviar()

					// *********************************************************************************
					// Atributo oWS:oWSEnviarResult:cresultado "Exitoso"/"Procesado"/"Error"
					// *********************************************************************************
					cResult := oWS:oWSEnviarResult:cresultado
					lAceptado := (oWS:oWSEnviarResult:lesvalidoDIAN .Or. oWS:oWSEnviarResult:ccodigo $ "200|201|299")
					//1= Prefijo+Consecutivo, 2= Filial, 3= Matricula, 4= Nombre, 5= Aceptado, 6= Detalle de transmisión,7= Resultado, 8= Email, 9= Nombre Archivo XML, 10= Ruta Archivos XML/PDF
					aAdd(aLog , { cSPrefCons,(cAliasSRA)->RA_FILIAL ,(cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, lAceptado, oWS:oWSEnviarResult:ccodigo + "-" + oWS:oWSEnviarResult:cmensaje + " " + cMsgNov,cResult,(cAliasSRA)->RA_EMAIL,cArchivoXML,cFilePathH } )
					
					If lAceptado
						nSDcsTrans++
					Else
						If oWS:oWSEnviarResult:oWSreglasRechazoTFHKA != Nil
							If ValType(oWS:oWSEnviarResult:oWSreglasRechazoTFHKA:cstring) == "A"
								For nFor := 1 to Len(oWS:oWSEnviarResult:oWSreglasRechazoTFHKA:cstring)
									If nFor == 1
										aAdd(aLog, {Space(20) ,Space(10),Space(15), STR0041, .F., oWS:oWSEnviarResult:oWSreglasRechazoTFHKA:cstring[nFor],cResult,'','',''})	//"Rechazos TFHKA"
										nLenLog := Len(aLog)
									Else
										aLog[nLenLog][6] += ", " + AllTrim( oWS:oWSEnviarResult:oWSreglasRechazoTFHKA:cstring[nFor] )
									EndIf
								Next nFor
							Endif
						Endif
						If oWS:oWSEnviarResult:oWSreglasRechazoDIAN != Nil
							If ValType(oWS:oWSEnviarResult:oWSreglasRechazoDIAN:cstring) == "A"
								For nFor := 1 to Len(oWS:oWSEnviarResult:oWSreglasRechazoDIAN:cstring)
									If nFor == 1
										aAdd(aLog, {Space(20) ,Space(10),Space(15), STR0042, .F., oWS:oWSEnviarResult:oWSreglasRechazoDIAN:cstring[nFor],cResult,'','',''})	//"Rechazos DIAN"		<== OJO STR no definido en .CH
										nLenLog := Len(aLog)
									Else
										aLog[nLenLog][6] += ", " + AllTrim( oWS:oWSEnviarResult:oWSreglasRechazoDIAN:cstring[nFor] )
									EndIf
								Next nFor
							EndIf
						EndIf
					EndIf

					cXML := Decode64(oWS:oWSEnviarResult:cxml)
					If !Empty(cXML)
						If nTipoXML == 2 // Ajuste 
							// Se renombra archivo xml y pdf ajustado
							FRENAME(cArchAjus + ".xml", cArchAjus + "_" + cPrefNum + "_A.xml") // 0101_1001_liq_202107_000007_op  --> 0101_1001_liq_202107_000007_op_FSNE20_a = Ajustado
							If File(cArchAjus  +".pdf") // busca archivo pdf 
								FRENAME(cArchAjus + ".pdf", cArchAjus + "_" + cPrefNum + "_A.pdf") 
							Endif
						ElseIf nTipoXML == 3 // Cancelación		                              // 0101_1001_liq_202107_000007_ap  --> 0101_1001_liq_202107_000007_ap_JJNA4_a = Ajustado
							// Se renombra archivo xmly pdf Cancelado
							FRENAME(cArchAjus + ".xml", cArchAjus + "_" + cPrefNum + "_C.xml") // 0101_1001_liq_202107_000007_op  --> 0101_1001_liq_202107_000007_op_JJNA4_c = Cancelado	
							If File(cArchAjus + ".pdf") // busca archivo pdf 
								FRENAME(cArchAjus + ".pdf", cArchAjus + "_" + cPrefNum + "_C.pdf") 
							Endif
							ObtArchNov(@aArchNov) // busca archivos de novedades
							If Len(aArchNov) > 0
								For nX:=1 To Len(aArchNov) // renombra archivos de novedad
									FRENAME(aArchNov[nX][1], aArchNov[nX][6] + "_" + cPrefNum + "_C" + aArchNov[nX][4]) // 0101_1001_liq_202107_000007_ap  --> 0101_1001_liq_202107_000007_ap_JJNA4_c = Ajustado
								Next nX
							EndIf
						Endif																   
						// se crea nuevo archivo xml 
						//Filial + Proceso + Procedimiento + Periodo + Empleado + TipoXML + indicador (P = pruebas) 
						fEscribXml(cXML, cArchivoXML + ".xml",cFilePathP,cFilePathH)		// crea archivo XML
						fDescargaPDF(cArchivoXML, cFilePathH)

					EndIf

				Else
					aAdd(aLog , { cSPrefCons, (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F., STR0043,STR0044,'','','' } )	//"Sin respuesta del servicio web." //"Error"
				EndIf
			EndIf
		Endif
		If lNovedadOK .and. nContNov == 1 
			lCalcNove := .F.
		Else
			cFechaNovS := ""
			nContNov := 0
			lCalcNove := .T.
			lNovedadOK := .F.
			lSal := .F. 
			aNovedades := {}
			aSalDiaQ := {}
			(cAliasSRA)->(dbSkip() )
		EndIf
	Enddo

	If Len(aLog) > 0
		If aScan(aLog,{|x|x[5] == .F.}) > 0
			cMsgLog := msgLogErr
		Else
			cMsgLog :=  msgLogEnv 
		EndIf
		If MsgYESNO(cMsgLog)
			M884GENLOG(aLog, nSDocsProc, nSDcsTrans,nGnraNom)
		EndIf

	EndIf

(cAliasSRA)->(DbCloseArea())
RestArea(aArea)

Return Nil


/*/{Protheus.doc} GM884MovEm
Obtiene movimintos SRC/SRD
@author arodriguez
@since 05/07/2021
@version 1.0
@return .T.
@param 
/*/
Static Function GM884MovEm()

	Local cConTab		:= ""
	Local nPosNum		:= 0
	Local cSalarial		:= ""	
	Local lValMoV		:= .F.
	Local lMovOrd 		:= .T.
	Private cAliasSR	:= GetNextAlias()

	//Inicializacion de Variables 
	aSBonifica 	:= {} // Bonificaciones
	aSCompensa	:= {} // Compensaciones
	aSComision  := {} // Comisiones
	aSAnticipD  := {} // Anticipo Devengados
	aSCesantia	:= {} // Cesantia
	aSIncidenc	:= {} // Incidencias
	aSOtroConc 	:= {} // Otros conceptos
	aSLicencia 	:= {} // Licencias  Materinidad o Paternidad, Remunerada y no Remunera
	aSIncapaci  := {} // Incapacidades
	aSHuelgas	:= {} // Huelgas legales
	aSVacacion 	:= {} // Vacaciones comunes
	aSVacaComp	:= {} // Vacaciones compensadas  
	aSHorasExt	:= {} // Horas Extras
	aSAuxilio	:= {} // Auxilio 	
	aSAnticipo 	:= {} // Anticipos
	aSPagoTerc	:= {} // Pagos Terceros
	aSBonEPCTV	:= {} // Bono EPCTV
	aSTranspor 	:= {} // Transporte
	aSLibranza	:= {} // Libranza
	aSOtraDedu	:= {} // Otra Deducción
	aSPagTerce	:= {} // Pago tercero
	aSSancion	:= {} // Sanciones
	aSSindicat	:= {} // Sindicatos
	nSSaludDed  := 0 // Salud deducción
	nSSaludPor  := 0 // Salud porcentaje
	nSApoyoSos 	:= 0 // Apoyo Sos
	nSDotacion 	:= 0 // Dotación
	nSTelTraba 	:= 0 // Teletrabajo
	nSBonifRet 	:= 0 // Bonificación Retiro
	nSIndenmni 	:= 0 // Indemnización
	nSReintegr 	:= 0 // Reintegro
	nSDiasTrab 	:= 0 // Dias Trabajados
	nSSueldoTr 	:= 0 // Sueldo trabajado
	nSDiaPrima  := 0 // Dias Prima
	nSPagPrima  := 0 // Pago Dias Prima
	nSPgPriNoS  := 0 // Pago Dias Prima No Salarial
	nSAFC		:= 0 // AFC
	nSCooperat	:= 0 // Cooperativa
	nSDeuda		:= 0 // Deuda
	nSEduca 	:= 0 // Educación 
	nSEmbarFis 	:= 0 // Embargo Fiscal 
	nSPlanComS	:= 0 // Plan complementario Salud
	nSPensionV	:= 0 // Pension Voluntaria
	nSReintegD	:= 0 // Reintegro
	nSRtFuente  := 0 // Retención Fuente
	nSFdPenDed 	:= 0 // Fondo pensión
	nSPrPenDed 	:= 0 // porcentaje pensión
	nSFonDePrj	:= 0 // Porcentaje Fondo SP
	nSFonDedSP	:= 0 // Deducción Fondo SP
	nSFonPrSub	:= 0 // Porcentaje Sub Fondo SP
	nSFonDeSub	:= 0 // Deducción Sub Fondo SP
	nTotal		:= 0
	nDeduc		:= 0
	nDeven		:= 0
	cSOtroTipo	:= ""// Tipo Incapacidad
	cSalarial 	:= ""


	BeginSql alias cAliasSR
		SELECT RD_FILIAL,RD_MAT, RD_PD, RV_TIPOCOD, RV_TIPSAT, RV_SALARIA, RV_CODFOL,RD_DATPGT,
			   R8_DATAINI,R8_DATAFIM,RD_NUMID,RD_DTREF,RD_ENTIDAD,SUM(RD_HORAS) RD_HORAS, SUM(RD_VALOR) RD_VALOR, RD_SEMANA,RV_DESCDET
		FROM %exp:cSRDTab% SRD INNER JOIN  %exp:cSRVTab% SRV ON RD_PD=RV_COD
		      LEFT OUTER JOIN	%exp:cSR8Tab% SR8 ON R8_FILIAL = RD_FILIAL AND R8_PD = RD_PD AND R8_MAT = RD_MAT AND R8_PROCES = RD_PROCES 
			   AND R8_NUMID = RD_NUMID AND SR8.%NotDel%
		WHERE RD_FILIAL = %exp:(cAliasSRA)->RA_FILIAL% AND RD_MAT =  %exp:(cAliasSRA)->RA_MAT% AND
			  SRD.%NotDel% AND SRV.%NotDel%  %exp:cQuerySRD%
			  GROUP BY RD_FILIAL,RD_MAT, RD_PD, RV_TIPOCOD, RV_TIPSAT, RV_SALARIA, RV_CODFOL,RD_DATPGT,R8_DATAINI,R8_DATAFIM,RD_NUMID,RD_DTREF,RD_ENTIDAD,RD_SEMANA,RV_DESCDET
		UNION

		SELECT RC_FILIAL,RC_MAT, RC_PD, RV_TIPOCOD, RV_TIPSAT, RV_SALARIA, RV_CODFOL,RC_DATA,
			   R8_DATAINI,R8_DATAFIM,RC_NUMID,RC_DTREF,RC_ENTIDAD,SUM(RC_HORAS) RC_HORAS, SUM(RC_VALOR) RC_VALOR, RC_SEMANA,RV_DESCDET
		FROM %exp:cSRCTab% SRC INNER JOIN  %exp:cSRVTab% SRV ON RC_PD=RV_COD
		      LEFT OUTER JOIN	%exp:cSR8Tab% SR8 ON R8_FILIAL = RC_FILIAL AND R8_PD = RC_PD AND R8_MAT = RC_MAT AND R8_PROCES = RC_PROCES 
			  AND R8_NUMID = RC_NUMID AND SR8.%NotDel%
		WHERE RC_FILIAL = %exp:(cAliasSRA)->RA_FILIAL% AND RC_MAT =  %exp:(cAliasSRA)->RA_MAT% AND
			  SRC.%NotDel% AND SRV.%NotDel%  %exp:cQuerySRC%
			  GROUP BY RC_FILIAL,RC_MAT, RC_PD, RV_TIPOCOD, RV_TIPSAT, RV_SALARIA, RV_CODFOL,RC_DATA,R8_DATAINI,R8_DATAFIM,RC_NUMID,RC_DTREF,RC_ENTIDAD,RC_SEMANA,RV_DESCDET

			  ORDER BY RD_FILIAL,RD_MAT,RV_TIPOCOD,RD_PD
	EndSql

	Do While (cAliasSR)->(!Eof())
		
		lValMoV := .T.
		If nTipoXML < 3 // si es diferente a Ajuste para cancelación 
			//Redondeo - Sub Elemeto de nomina Individual (Opcional, una ocurrencia)
			If (cAliasSR)->RV_TIPSAT=='223'
				nSRedondeo +=  (cAliasSR)->RD_VALOR
			Endif

			//---------DEVENGADOS---------//

			//Anticipo (Opcional, varias ocurrencias)
			If (cAliasSR)->RV_TIPSAT=='102' 
				aSAnticipo := GM884incid(aSAnticipo)
			Endif
			//Apoyo Sost (Opcional, una ocurrencia)
			If (cAliasSR)->RV_TIPSAT=='103' 
				nSApoyoSos +=  (cAliasSR)->RD_VALOR
			Endif
			
			//Si hay novedad, los siguientes conceptos se asigna solo a la nomian de novedades(XML)
			If !lNovedadOK .OR.  (lNovedadOK .and. nContNov > 1)
				//Dotación (Opcional, una ocurrencia) 
				If (cAliasSR)->RV_TIPSAT=='112' 
					nSDotacion +=  (cAliasSR)->RD_VALOR
				Endif
				//Teletrabajo (Opcional, una ocurrencia)
				If (cAliasSR)->RV_TIPSAT=='131'
					nSTelTraba +=  (cAliasSR)->RD_VALOR
				Endif
				//Bonificación Retiro (Opcional, una ocurrencia)
				If (cAliasSR)->RV_TIPSAT=='107'
					nSBonifRet +=  (cAliasSR)->RD_VALOR
				Endif
				//Indenmización (Opcional, una ocurrencia)
				If (cAliasSR)->RV_TIPSAT=='123'
					nSIndenmni +=  (cAliasSR)->RD_VALOR
				Endif

				// Pago Cesantia e Interes Cesantia (Opcional, una ocurrencia)
				If (cAliasSR)->RV_TIPSAT $ '108|124' 
					nPosSal:=IIf((cAliasSR)->RV_TIPSAT == '108',4 ,5)	
					nSm:= 0 
					If (cAliasSR)->RV_TIPOCOD  $ '1|2|3|4'
						If (cAliasSR)->RV_TIPOCOD $ '1|3'
							nSm:= 1 
						EndIf
						nPosEx := aScan(aSCesantia,{|x|x[1] $ '108|124'})
						If nPosEx > 0
							If nSm == 1
								aSCesantia[nPosEx][nPosSal] += (cAliasSR)->RD_VALOR
							Else
								aSCesantia[nPosEx][nPosSal] -= (cAliasSR)->RD_VALOR
							EndIf
						Else
							AADD(aSCesantia, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RV_TIPOCOD,;
								Iif( (cAliasSR)->RV_TIPSAT == '108' ,IIF(nSm == 0, -(cAliasSR)->RD_VALOR,(cAliasSR)->RD_VALOR) ,0),;
								Iif( (cAliasSR)->RV_TIPSAT == '124',IIF(nSm == 0, -(cAliasSR)->RD_VALOR,(cAliasSR)->RD_VALOR),0),;
								''})
						EndIf
					EndIf
				EndIf

				// Compensacion Ordinaria / Extraordinaria (Opcional, varias ocurrencias)
				//generara varios elementos dependiendo la fecha (si los movimientos pertenecen al mismo dia los suma)
				If (cAliasSR)->RV_TIPSAT $ '111|110'
					nPosSal := IIf( (cAliasSR)->RV_TIPSAT == '111',4,5)
					nPosEx := aScan(aSCompensa,{|x|x[1] == (cAliasSR)->RV_TIPSAT .and. x[2] == (cAliasSR)->RD_DTREF})
					If nPosEx > 0
						aSCompensa[nPosEx][nPosSal] += (cAliasSR)->RD_VALOR
					Else
						AADD(aSCompensa, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RV_SALARIA,;
							Iif( (cAliasSR)->RV_TIPSAT == '111' ,(cAliasSR)->RD_VALOR,0),;
							Iif( (cAliasSR)->RV_TIPSAT == '110',(cAliasSR)->RD_VALOR,0),;
							''})
					EndIf
				EndIf

				// Otros Conceptos (Opcional, varias ocurrencias)
				// Generara varios elementos dependiendo el concepto y el tipo Salarial (si los movimientos pertenecen al mismo concepto y tipo salarial los suma)
				If (cAliasSR)->RV_TIPSAT=='127'
					If (cAliasSR)->RV_SALARIA $ '1|2|3|4'
						cSalarial := (cAliasSR)->RV_SALARIA 
						nPosSal := IIf( cSalarial == '1',4,5)
						nPosEx := aScan(aSOtroConc,{|x|x[1] == (cAliasSR)->RD_PD .and. x[2] == (cAliasSR)->RV_SALARIA  })
						If nPosEx > 0
							aSOtroConc[nPosEx][nPosSal] += (cAliasSR)->RD_VALOR
						Else// 1 Concepto, 2 Tipo Salarial, 3 Descrip Concepto, 4 Valor Concep Salarial, 5 Valor Conep No Salarial
							AADD(aSOtroConc, {(cAliasSR)->RD_PD, (cAliasSR)->RV_SALARIA, (cAliasSR)->RV_DESCDET,;
							Iif(cSalarial == '1',(cAliasSR)->RD_VALOR,0), Iif(cSalarial $ '2|3|4',(cAliasSR)->RD_VALOR,0) }) 
						EndIf
					EndIf
				Endif


				// Bonos EPCTV (Opcional, varias ocurrencias)
				//generara varios elementos dependiendo la fecha (si los movimientos pertenecen al mismo dia los suma)
				If (cAliasSR)->RV_TIPSAT $ '134|135' 
					nPosSal:=IIf((cAliasSR)->RV_TIPSAT == '135',4 ,6)	
					nPosEx := aScan(aSBonEPCTV,{|x|x[2] == (cAliasSR)->RD_DTREF })
					If nPosEx > 0
						If (cAliasSR)->RV_SALARIA == '1'
							aSBonEPCTV[nPosEx][nPosSal] += (cAliasSR)->RD_VALOR
						ElseIf  (cAliasSR)->RV_SALARIA $ '2|3|4'
							aSBonEPCTV[nPosEx][nPosSal+1] += (cAliasSR)->RD_VALOR
						EndIf
					Else
						AADD(aSBonEPCTV, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RV_SALARIA,;
							Iif( (cAliasSR)->RV_TIPSAT == '135' .and. (cAliasSR)->RV_SALARIA == '1' ,(cAliasSR)->RD_VALOR,0),;
							Iif( (cAliasSR)->RV_TIPSAT == '135' .and. (cAliasSR)->RV_SALARIA $ '2|3|4' ,(cAliasSR)->RD_VALOR,0),;
							Iif( (cAliasSR)->RV_TIPSAT == '134' .and. (cAliasSR)->RV_SALARIA == '1' ,(cAliasSR)->RD_VALOR,0),;
							Iif( (cAliasSR)->RV_TIPSAT == '134' .and. (cAliasSR)->RV_SALARIA $ '2|3|4' ,(cAliasSR)->RD_VALOR,0),;
							''})
					EndIf
				EndIf

				//Prima se suman todos sus valores - solo puede informarse un elemento
				If (cAliasSR)->RV_TIPSAT=='129'
					nSDiaPrima +=  (cAliasSR)->RD_HORAS
					If (cAliasSR)->RV_SALARIA =='4'//Pago prima dias (NO APLICA O BASE) << --- este cambio se platico con Ximena y Eloisa
						nSPagPrima +=  (cAliasSR)->RD_VALOR
					ElseIf (cAliasSR)->RV_SALARIA $ '2|3' // Pago prima No Salarial
						nSPgPriNoS +=  (cAliasSR)->RD_VALOR
					EndIf
				EndIf

				// Auxilio (Opcional, varias ocurrencias)
				// generara varios elementos dependiendo la fecha (si los movimientos pertenecen al mismo día los suma)
				If (cAliasSR)->RV_TIPSAT=='105' 
					If (cAliasSR)->RV_SALARIA  $ '1|2|3|4'
						cSalarial := (cAliasSR)->RV_SALARIA 
						nPosSal := IIf( cSalarial == '1',4,5)
						nPosEx := aScan(aSAuxilio,{|x|x[1] == (cAliasSR)->RV_TIPSAT .and. x[2] == (cAliasSR)->RD_DTREF})
						If nPosEx > 0
							aSAuxilio[nPosEx][nPosSal] += (cAliasSR)->RD_VALOR
						Else
							AADD(aSAuxilio, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RV_SALARIA,;
								Iif( cSalarial == '1' ,(cAliasSR)->RD_VALOR,0),;
								Iif( cSalarial $ '2|3|4',(cAliasSR)->RD_VALOR,0),;
								''})
						EndIf
					EndIf
				Endif

				//Bonificación (Opcional, varias ocurrencias)
				//generara varios elementos dependiendo la fecha (si los movimientos pertenecen al mismo dia los suma)
				If (cAliasSR)->RV_TIPSAT=='106' 
					If (cAliasSR)->RV_SALARIA  $ '1|2|3|4'
						cSalarial := (cAliasSR)->RV_SALARIA 
						nPosSal := IIf( cSalarial == '1',4,5)
						nPosEx := aScan(aSBonifica,{|x|x[1] == (cAliasSR)->RV_TIPSAT .and. x[2] == (cAliasSR)->RD_DTREF})
						If nPosEx > 0
							aSBonifica[nPosEx][nPosSal] += (cAliasSR)->RD_VALOR
						Else
							AADD(aSBonifica, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RV_SALARIA,;
								Iif( cSalarial == '1' ,(cAliasSR)->RD_VALOR,0),;
								Iif( cSalarial $ '2|3|4',(cAliasSR)->RD_VALOR,0),;
								''})
						EndIf
					EndIf
				Endif
				//Monto comisión (Opcional, varias ocurrencias)
				If (cAliasSR)->RV_TIPSAT=='109'
					aSComision :=  GM884incid(aSComision)
				Endif
				//Pagos Terceros (Opcional, varias ocurrencias)
				If (cAliasSR)->RV_TIPSAT=='128'
					aSPagoTerc :=  GM884incid(aSPagoTerc)
				EndIf

			EndIf	

			//Reintegro (Opcional, una ocurrencia)
			If (cAliasSR)->RV_TIPSAT=='130'
				nSReintegr +=  (cAliasSR)->RD_VALOR
			Endif
			// Dias Trabajados (Obligatorio, una ocurrencia)
			If (cAliasSR)->RV_CODFOL=='0638'
				nSDiasTrab +=  (cAliasSR)->RD_HORAS
			Endif
			// Sueldo Trabajado (Obligatorio, una ocurrencia)
			If (cAliasSR)->RV_CODFOL $ '0031|1054'
				nSSueldoTr +=  (cAliasSR)->RD_VALOR
			Endif
			
			///HORAS EXTRAS (Opcional, varias ocurrencias)
			//generara varios elementos dependiendo la fecha (si los movimientos pertenecen al mismo dia los suma)
			If (cAliasSR)->RV_TIPSAT $ '113|114|115|116|117|118|119'
				GM884HrsEx()
			EndIf

			//Vacaciones compensadas
			If (cAliasSR)->RV_TIPSAT $ '132'
				aSVacaComp:= GM884Ausen(aSVacaComp,'VC')
			EndIf

			//Vacaciones comunes Vacaciones calculadas no registrados en SR8
			If Empty((cAliasSR)->RD_NUMID) .and. (cAliasSR)->RV_TIPSAT == '133' 
				aSVacacion:= GM884Ausen(aSVacacion,'NH')
			EndIf

			//Ausencias (Opcional, varias ocurrencias)
			If !Empty((cAliasSR)->RD_NUMID) // debe ir lleno para las ausencias
				//Huelgas
				If (cAliasSR)->RV_TIPSAT $ '250' 
					aSHuelgas := GM884Ausen(aSHuelgas)
				EndIf
				//Vacaciones comunes
				If (cAliasSR)->RV_TIPSAT $ '133'
					aSVacacion:= GM884Ausen(aSVacacion)
				EndIf
				//Incapacidades
				If (cAliasSR)->RV_TIPSAT $ '120|121|122'
					cSOtroTipo := IIf((cAliasSR)->RV_TIPSAT=='120','3',IIf((cAliasSR)->RV_TIPSAT=='121','1', '2'))
					aSIncapaci:= GM884Ausen(aSIncapaci)
				EndIf
				// Licencias
				If (cAliasSR)->RV_TIPSAT $ '125|126|212'
					aSLicencia:= GM884Ausen(aSLicencia)
				EndIf
				
			Endif
			
			//Transporte (Opcional, varias ocurrencias)
			//generara varios elementos dependiendo la fecha (si los movimientos pertenecen al mismo dia los suma)
			If (cAliasSR)->RV_TIPSAT $ '104|101' 
				lMovOrd := .T.
				nPosSal:=IIf((cAliasSR)->RV_TIPSAT == '104',4 ,5)	
				nPosEx := aScan(aSTranspor,{|x|x[2] == (cAliasSR)->RD_DTREF})
				If nPosEx > 0
					If (cAliasSR)->RV_TIPSAT == '104'
						aSTranspor[nPosEx][nPosSal] += (cAliasSR)->RD_VALOR
					ElseIf (cAliasSR)->RV_SALARIA == '1'
						aSTranspor[nPosEx][nPosSal] += (cAliasSR)->RD_VALOR
					ElseIf  (cAliasSR)->RV_SALARIA $ '2|3|4'
						aSTranspor[nPosEx][nPosSal+1] += (cAliasSR)->RD_VALOR
					EndIf
				Else
					If lNovedadOK 
						If !((cAliasSR)->RD_DTREF >= cFchPrNovI .and. (cAliasSR)->RD_DTREF <= cFchPrNovF)
							lMovOrd :=.F.
						EndIf
					EndIf
					If lMovOrd
						AADD(aSTranspor, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RV_SALARIA,;
							Iif( (cAliasSR)->RV_TIPSAT == '104' ,(cAliasSR)->RD_VALOR,0),;
							Iif( (cAliasSR)->RV_TIPSAT == '101' .and. (cAliasSR)->RV_SALARIA == '1' ,(cAliasSR)->RD_VALOR,0),;
							Iif( (cAliasSR)->RV_TIPSAT == '101' .and. (cAliasSR)->RV_SALARIA $ '2|3|4' ,(cAliasSR)->RD_VALOR,0),;
							''})
					EndIf
				EndIf
			EndIf

			//---------DEDUCCIONES---------//

			//Si hay novedad se asigna info al último documento XML
			If !lNovedadOK .OR.  (lNovedadOK .and. nContNov > 1)
				// AFC (Opcional, una ocurrencia)
				If (cAliasSR)->RV_TIPSAT == '201' 
					nSAFC += (cAliasSR)->RD_VALOR
				EndIf
				//Anticpo Deducciones  (Opcional, varias ocurrencia)
				If (cAliasSR)->RV_TIPSAT == '203' 
					aSAnticipD :=  GM884incid(aSAnticipD)
				EndIf
				// Cooperativa (Opcional, una ocurrencia)
				If (cAliasSR)->RV_TIPSAT == '204' 
					nSCooperat += (cAliasSR)->RD_VALOR
				EndIf
				// Deuda (Opcional, una ocurrencia)
				If (cAliasSR)->RV_TIPSAT == '222' 
					nSDeuda += (cAliasSR)->RD_VALOR
				EndIf
				// Educacion (Opcional, una ocurrencia)
				If (cAliasSR)->RV_TIPSAT == '205' 
					nSEduca += (cAliasSR)->RD_VALOR
				EndIf
				// Plan complementario Salud (Opcional, una ocurrencia)
				If (cAliasSR)->RV_TIPSAT == '216' 
					nSPlanComS += (cAliasSR)->RD_VALOR
				EndIf

				//Libranzas -  (Opcional, varias ocurrencias)
				If (cAliasSR)->RV_TIPSAT == '211'
					nPosNum := FPOSTAB('S008',(cAliasSR)->RD_ENTIDAD, '=', 4)  
					cConTab := fTabela('S008',nPosNum,5)
					AADD(aSLibranza, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RD_HORAS,(cAliasSR)->RD_VALOR,'', cConTab})
				EndIf
				//Otra Deducción - (Opcional, varias ocurrencias)
				If (cAliasSR)->RV_TIPSAT == '213'
					AADD(aSOtraDedu, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RD_HORAS,(cAliasSR)->RD_VALOR,''})
				Endif
				//Pago Tercero - (Opcional, varias ocurrencias)
				If (cAliasSR)->RV_TIPSAT == '214'
					AADD(aSPagTerce, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RD_HORAS,(cAliasSR)->RD_VALOR,''})
				Endif
				// Pension Voluntaria (Opcional, una ocurrencia)
				If (cAliasSR)->RV_TIPSAT == '215' 
					nSPensionV += (cAliasSR)->RD_VALOR
				EndIf

			EndIf
			// Embargo Fiscal (Opcional, una ocurrencia)
			If (cAliasSR)->RV_TIPSAT == '206' 
				nSEmbarFis += (cAliasSR)->RD_VALOR
			EndIf
			// Reintegro (Opcional, una ocurrencia)
			If (cAliasSR)->RV_TIPSAT == '217' 
				nSReintegD += (cAliasSR)->RD_VALOR
			EndIf
			// Retencion Fuente (Opcional, una ocurrencia)
			If (cAliasSR)->RV_TIPSAT == '218' 
				nSRtFuente += (cAliasSR)->RD_VALOR
			EndIf
			// Fondo Pensión (obligatorio, una ocurrencia)
			If (cAliasSR)->RV_TIPSAT == '202' 
				nSFdPenDed += (cAliasSR)->RD_VALOR
				nSPrPenDed := cAFPPensi
			Endif
			// Fondo seguridad pensional (Opcional, una ocurrencia)
			If (cAliasSR)->RV_CODFOL ==  '0860'	
				nSFonDePrj += (cAliasSR)->RD_HORAS
			Endif
			If (cAliasSR)->RV_TIPSAT ==  '208'	
				nSFonDedSP += (cAliasSR)->RD_VALOR
			Endif
			If (cAliasSR)->RV_CODFOL ==  '0873'		
				nSFonPrSub += (cAliasSR)->RD_HORAS
			Endif
			If (cAliasSR)->RV_TIPSAT ==  '209'	
				nSFonDeSub += (cAliasSR)->RD_VALOR
			Endif
		
			// Salud // (Obligatorio, una ocurrencia)
			If (cAliasSR)->RV_TIPSAT == '207' 
				nSSaludDed += (cAliasSR)->RD_VALOR
				nSSaludPor := cEPSSalud 
			Endif
			// Sanciones (Opcional, varias ocurrencias)
			//generara varios elementos dependiendo la fecha (si los movimientos pertenecen al mismo dia los suma)
			If (cAliasSR)->RV_TIPSAT $ '219|220'
				lMovOrd := .T.
				nPosSal := IIf( (cAliasSR)->RV_TIPSAT == '220',4,5)
				nPosEx := aScan(aSSancion,{|x|x[2] == (cAliasSR)->RD_DTREF})
				If nPosEx > 0
					aSSancion[nPosEx][nPosSal] += (cAliasSR)->RD_VALOR
				Else
					If lNovedadOK 
						If !((cAliasSR)->RD_DTREF >= cFchPrNovI .and. (cAliasSR)->RD_DTREF <= cFchPrNovF)
							lMovOrd :=.F.
						EndIf
					EndIf
					If lMovOrd
						AADD(aSSancion, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RV_SALARIA,;
							Iif( (cAliasSR)->RV_TIPSAT == '220' ,(cAliasSR)->RD_VALOR,0),;
							Iif( (cAliasSR)->RV_TIPSAT == '219',(cAliasSR)->RD_VALOR,0),;
							''})
					EndIf
				EndIf
			EndIf
			// Sindicatos
			If (cAliasSR)->RV_TIPSAT == '221'
				AADD(aSSindicat, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RV_SALARIA,(cAliasSR)->RD_HORAS,(cAliasSR)->RD_VALOR,''})
			EndIf

		EndIf //fin validacion tipo XML

		If (cAliasSR)->RV_CODFOL $  '0047|0021|0126|0162|0546'
			nTotal += (cAliasSR)->RD_VALOR
		Endif
		If (cAliasSR)->RV_CODFOL $  '0545'
			nDeduc += (cAliasSR)->RD_VALOR
		Endif
		If (cAliasSR)->RV_CODFOL $  '0542'
			nDeven += (cAliasSR)->RD_VALOR
		Endif

		(cAliasSR)->(dbSkip())
	Enddo

return lValMoV


/*/{Protheus.doc} GM884incid
Genera Array con Inicidencias 
@author alfredo medrano
@since 05/11/2021
@version 1.0
@return aIncidencia
@param aIncidencia - array con de la incidencia
/*/
Static Function GM884incid(aIncidencia)
DEFAULT aIncidencia := {}
	AADD(aIncidencia, {(cAliasSR)->RV_TIPSAT,(cAliasSR)->RD_DTREF,(cAliasSR)->RD_HORAS,(cAliasSR)->RD_VALOR,'' })
Return aIncidencia

/*/{Protheus.doc} GM884HrsEx
Genera Array con Horas Extras
@author alfredo medrano
@since 05/07/2021
@version 1.0
@return Nil
@param 
/*/
Static Function GM884HrsEx()
Local cFechaExD		:= ""
Local cFchExIni		:= ""
Local cFchExFin		:= ""
Local nPosEx		:= 0
Local lMovOrd		:= .T.

    cFechaExD := FechaAMD((cAliasSR)->RD_DTREF)
    cFchExIni := cFechaExD + " 06:00:00"
    cFchExFin := cFechaExD + " 21:00:00"
    nPosEx := aScan(aSHorasExt,{|x|x[1] == (cAliasSR)->RV_TIPSAT .AND. x[8] == (cAliasSR)->RD_DTREF})
	
    If nPosEx > 0
        aSHorasExt[nPosEx][5] +=  (cAliasSR)->RD_HORAS
        aSHorasExt[nPosEx][7] +=  (cAliasSR)->RD_VALOR
    Else
        nPosEx := aScan(aSTipHrExt,{|x|x[1] == (cAliasSR)->RV_TIPSAT }) 
        If aSTipHrExt[nPosEx][3] == "N" // si es horario nocturno
            cFchExIni := cFechaExD + " 21:00:00"
            cFchExFin := cFechaExD + " 06:00:00"
        Endif

		IF lNovedadOK 
			If !((cAliasSR)->RD_DTREF >= cFchPrNovI .and. (cAliasSR)->RD_DTREF <= cFchPrNovF)
				lMovOrd := .F.
			EndIf
		EndIf
		If lMovOrd
			// 1-TipoXml,2-CodHoraExtra,3-HoraInicio,4-HoraFin,5-CantidadHrs,6-Procentaje,7-Valor, 8-Fecha Ref 
			aadd(aSHorasExt,{(cAliasSR)->RV_TIPSAT,aSTipHrExt[nPosEx][2],cFchExIni,cFchExFin,;
				(cAliasSR)->RD_HORAS,aSTipHrExt[nPosEx][4],(cAliasSR)->RD_VALOR,(cAliasSR)->RD_DTREF})
		EndIf

    Endif
    
Return Nil


/*/{Protheus.doc} GM884Ausen
Genera Array con ausencias 
@author alfredo medrano
@since 05/07/2021
@version 1.0
@return aSAusencia
@param aSAusencia - array con de la ausencia
/*/
Static function GM884Ausen(aSAusencia,cTpAus)
Local nRow 		:= 0
Local cFPerPagIn:= cFchPerIni
Local cFPerPagFi:= cFchPerFin

Local nPorDias	:= 0
Local nValTot 	:= 0
Local nValDias 	:= 0
Local nDiasHab 	:= 0
Local cFechaNIn := ""
Local cFechaNFi := ""
Local lMovOrd 	:= .T.
Local lDias 	:= .F.



Default cTpAus := ""

	If ValType(aSAusencia) == "A"

		nRow := aScan(aFechasPer,{|x|x[1] == (cAliasSR)->RD_SEMANA})
		If nRow > 0
			cFPerPagIn := aFechasPer[nRow][2]
			cFPerPagFi := aFechasPer[nRow][3]
		Endif

		If cTpAus $ 'VC|NH' //VC = vacaciones compensadas // NH = vacaciones dias no Habiles

			IF lNovedadOK 
				If !((cAliasSR)->RD_DTREF >= cFchPrNovI .and. (cAliasSR)->RD_DTREF <= cFchPrNovF)
					lMovOrd := .F.
				EndIf
			EndIf

			If lMovOrd
				AADD(aSAusencia, {(cAliasSR)->RV_TIPSAT,;
						IIf(cTpAus == 'VC',cFPerPagIn,cFchPerIni),;
						IIf(cTpAus == 'VC',cFPerPagFi,cFchPerFin),;
						(cAliasSR)->RD_HORAS,;
						(cAliasSR)->RD_VALOR,;
						cSOtroTipo })
			EndIf
		Else

			If lNovedadOK

				ValTotVac(@nPorDias)

				If (cAliasSR)->R8_DATAINI >= cFchPrNovI .and. (cAliasSR)->R8_DATAFIM <= cFchPrNovF 
					//asigna valor y fechas sin necesidad de obtener proporcionales
					nDiasHab := (cAliasSR)->RD_HORAS
					nValDias := (cAliasSR)->RD_VALOR
					cFechaNIn := (cAliasSR)->R8_DATAINI
					cFechaNFi := (cAliasSR)->R8_DATAFIM 
				ElseIf  (cAliasSR)->R8_DATAINI >= cFchPrNovI .and. (cAliasSR)->R8_DATAINI <= cFchPrNovF
					//Si la fecha inicial de la ausencia esta entre las fechas inicio (periodo mensual) y fin (novedad) 
					cFechaNIn := (cAliasSR)->R8_DATAINI //fecha inicio ausencia
					cFechaNFi := cFchPrNovF	// fecha novedad
					lDias := .T.
				ElseIf  (cAliasSR)->R8_DATAFIM >= cFchPrNovI .and. (cAliasSR)->R8_DATAFIM <= cFchPrNovF
					//Si la fecha Final de la ausencia esta entre las fechas inicio (periodo mensual) y fin (novedad)
					cFechaNIn := cFchPrNovI //fecha novedad + 1
					cFechaNFi := (cAliasSR)->R8_DATAFIM //fecha final ausencia 
					lDias := .T.
				ElseIf (cAliasSR)->R8_DATAINI < cFchPrNovI // las vacaciones abarcan dos periodos (ejem: 25/09/2021 - 10/10/2021)
					If (cAliasSR)->R8_DATAFIM > cFchPrNovF 
						cFechaNIn := cFchPrNovI //fecha inicio periodo mensual
						cFechaNFi := cFchPrNovF	// fecha novedad
						lDias := .T.
					EndIf
				Endif

				If lDias
					//Obtiene los dias y valor proporcional de vacaciones
					nDiasHab:= 0
					GpeCalend((cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_mat ,,,, STOD( cFechaNIn) , STOD(cFechaNFi) , @nDiasHab ,"D",,.F. )
					nValTot := nDiasHab * aSalDiaQ[nContNov][2]
					nValDias := nValTot / nPorDias
					nValDias := Round((cAliasSR)->RD_VALOR * nValDias,4)
				EndIf

				If nDiasHab > 0
					AADD(aSAusencia, {(cAliasSR)->RV_TIPSAT,;
								cFechaNIn,;
								cFechaNFi,;
								nDiasHab,;
								nValDias,;
								cSOtroTipo })
				EndIf

			Else
				AADD(aSAusencia, {(cAliasSR)->RV_TIPSAT,;
								IIf((cAliasSR)->R8_DATAINI < cFPerPagIn, cFPerPagIn, (cAliasSR)->R8_DATAINI ),;
								IIf((cAliasSR)->R8_DATAFIM > cFPerPagFi, cFPerPagFi, (cAliasSR)->R8_DATAFIM ),;
								(cAliasSR)->RD_HORAS,;
								(cAliasSR)->RD_VALOR,;
								cSOtroTipo })	
			EndIf
		EndIf
	EndIf
return aSAusencia

/*/{Protheus.doc} GM884General
Asigna informacion general al XML 
@author arodriguez
@since 05/07/2021
@version 1.0
@return Nil
@param oWS - Objeto principal del WS
/*/
Static Function GM884General(oWS)

	Local nSalida 	:= 0
	Local cRazSoc 	:= ""
	Local cCGC 		:= ""
	Local cDigNIT 	:= ""
	Local cRangoNum := ""
	Local nPosNIT 	:= 0

	//obtiene la Razon Social Empleador
	If len(aDatosSM0[3][2]) < 17
		cCGC := aDatosSM0[3][2] + Space(17 - len(aDatosSM0[3][2]))
	ElseIf len(aDatosSM0[3][2]) > 17
		cCGC := Substr(aDatosSM0[1][2],1,17)
	Else
		cCGC := aDatosSM0[3][2]
	EndIf
	nSalida := FPOSTAB('S011',cCGC, '=', 5)  
	cRazSoc := fTabela('S011',nSalida,4)

	GerNumCons(cSerieVolE, @cSPrefCons,@cRangoNum)
	cidSoft	:= alltrim(FTABELA("S046",1,14))
	cnitEmp	:= alltrim(FTABELA("S046",1,8)) 

	cnitEmp :=  AllTrim(SubSTr(fTabela('S011',1,5),1,17))
	cDigNIT := "0"
	nPosNIT := AT("-",cnitEmp)
	If nPosNIT <> 0
		cDigNIT := SubSTr(cnitEmp,nPosNIT+1,1)
		cnitEmp := SubSTr(cnitEmp,1,nPosNIT-1)
	EndIF

	oWS:oWSrequest:cidSoftware 		:= cidSoft // S046, campo 8
	oWS:oWSrequest:cnitEmpleador 	:= cnitEmp // S046, campo 6 (Sin DV) <6>
	oWS:oWSrequest:ctokenEnterprise	:= cTokenEmp//  MV_TKN_EMP
	oWS:oWSrequest:ctokenPassword 	:= cTokenPwd//  MV_TKN_PAS	
	
	oWS:oWSrequest:oWSnomina:cconsecutivoDocumentoNom := cSPrefCons // "FSNE1"	
	oWS:oWSrequest:oWSnomina:cfechaEmisionNom :=FechaAMD(dDatabase) + " " +  TIME() //"2021-05-05 14:00:00" 
	IF !Empty(cCUNENove)
		oWS:oWSrequest:oWSnomina:cnovedad := "1"		//0=false / 1=true 
		oWS:oWSrequest:oWSnomina:cnovedadCUNE := cCUNENove
	Else
		oWS:oWSrequest:oWSnomina:cnovedad := "0"		//0=false / 1=true 
	Endif
	
	oWS:oWSrequest:oWSnomina:cperiodoNomina := cSPeriNom// RCJ->RCJ_PERIOD
	oWS:oWSrequest:oWSnomina:crangoNumeracionNom :=cRangoNum  //"FSNE-1"
	oWS:oWSrequest:oWSnomina:credondeo := AllTrim(STR(nSRedondeo,18,2)) // redondeo 
	oWS:oWSrequest:oWSnomina:ctipoDocumentoNom := IIf(nTipoXML == 1, "102", "103")	// Tipo de XML: Ordinaria(Soporte)/Ajuste
	oWS:oWSrequest:oWSnomina:ctipoMonedaNom := "COP"
	oWS:oWSrequest:oWSnomina:ctipoNota := IIf(nTipoXML < 3, "1","2")// se agrega valor basado en los ejemplos SOAP
	oWS:oWSrequest:oWSnomina:ctrm := "1.00"

Return Nil

/*/{Protheus.doc} GM884Docs
Asigna informacion del documento referenciado al XML 
@author arodriguez
@since 05/07/2021
@version 1.0
@return Nil
@param oWS - Objeto principal del WS
/*/
Static Function GM884Docs(oWS)
	Local oWSDocumentos	:= Service_ArrayOfDocumentoReferenciadoNom():New()
	Local oWSDocto		:= Service_DocumentoReferenciadoNom():New()
	Local cCUNE 		:= ""
	Local cFechGen 		:= ""

	If oXML != Nil
		If cTpAjust == "O"

			If ObtUidXML(OXml:_NOMINAINDIVIDUAL:_INFORMACIONGENERAL, "CUNE")
				cCUNE:= OXml:_NOMINAINDIVIDUAL:_INFORMACIONGENERAL:_CUNE:TEXT
			Endif
			If ObtUidXML(OXml:_NOMINAINDIVIDUAL:_INFORMACIONGENERAL, "FECHAGEN")
				cFechGen:= OXml:_NOMINAINDIVIDUAL:_INFORMACIONGENERAL:_FECHAGEN:TEXT
			Endif
			If ObtUidXML(OXml:_NOMINAINDIVIDUAL:_NUMEROSECUENCIAXML, "NUMERO")
				cPrefNum:= OXml:_NOMINAINDIVIDUAL:_NUMEROSECUENCIAXML:_NUMERO:TEXT
			Endif
		
		ElseIf cTpAjust == "A"
                        
			If ObtUidXML(OXml:_NOMINAINDIVIDUALDEAJUSTE:_REEMPLAZAR:_INFORMACIONGENERAL, "CUNE")
				cCUNE:=  OXml:_NOMINAINDIVIDUALDEAJUSTE:_REEMPLAZAR:_INFORMACIONGENERAL:_CUNE:TEXT
			Endif
			If ObtUidXML(OXml:_NOMINAINDIVIDUALDEAJUSTE:_REEMPLAZAR:_INFORMACIONGENERAL, "FECHAGEN")
				cFechGen:= OXml:_NOMINAINDIVIDUALDEAJUSTE:_REEMPLAZAR:_INFORMACIONGENERAL:_FECHAGEN:TEXT
			Endif
			If ObtUidXML(OXml:_NOMINAINDIVIDUALDEAJUSTE:_REEMPLAZAR:_NUMEROSECUENCIAXML, "NUMERO")
				cPrefNum:= OXml:_NOMINAINDIVIDUALDEAJUSTE:_REEMPLAZAR:_NUMEROSECUENCIAXML:_NUMERO:TEXT
			Endif

		EndIf


	Endif

	oWSDocto:ccunePred := cCUNE
	oWSDocto:cfechaGenPred := cFechGen //"2021-03-04"
	oWSDocto:cnumeroPred := cPrefNum //"DSNE1"
	
	// Campos extensibles "DocumentoReferenciado"	
	oExtensibles := GM884EXT("DocumentoReferenciado")
	If !(oExtensibles==Nil)
		oWSDocto:oWSextrasNom := oExtensibles
	EndIf
	aAdd( oWSDocumentos:oWSDocumentoReferenciadoNom , oWSDocto )
	oWS:oWSrequest:oWSnomina:oWSdocumentosReferenciadosNom := oWSDocumentos

Return Nil
/*/{Protheus.doc} GM884Periodo
Asigna inforamación de la tayectoria laboral del empleado al XML 
@author arodriguez
@since 05/07/2021
@version 1.0
@return Nil
@param oWS - Objeto principal del WS
/*/
Static Function GM884Periodo(oWS)
	Local oWSPers		:= Service_ArrayOfPeriodo():New()
	Local oWSNumPer		:= Nil
	Local cFinPerFch	:= ""

	oWSNumPer := Service_Periodo():New()

	If oWSNumPer != Nil
		oWSNumPer:cfechaIngreso := FechaAMD((cAliasSRA)->RA_ADMISSA)
		If lNovedadOK  
			oWSNumPer:cfechaLiquidacionInicio := FechaAMD(cFchPrNovI)
			oWSNumPer:cfechaLiquidacionFin := FechaAMD(cFchPrNovF)
			cFinPerFch := cFchPrNovF 
		Else
			oWSNumPer:cfechaLiquidacionInicio := FechaAMD(cFchPerIni)
			oWSNumPer:cfechaLiquidacionFin := FechaAMD(cFchPerFin)
			cFinPerFch := cFchPerFin 
		EndIf
		
		if (cAliasSRA)->RA_SITFOLH == "D" .and. !Empty((cAliasSRA)->RA_DEMISSA)
			oWSNumPer:cfechaRetiro := FechaAMD((cAliasSRA)->RA_DEMISSA)
		EndIf
		cDiasLab := AllTrim(STR(FKDias360(STOD((cAliasSRA)->RA_ADMISSA), STOD(cFinPerFch))))// concepto con operador de cálculo DIAS_360
		oWSNumPer:ctiempoLaborado := cDiasLab
		// Campos extensibles "Periodo"
		oExtensibles := GM884EXT("Periodo")
		If !(oExtensibles==Nil)
			oWSNumPer:oWSextrasNom := oExtensibles
		EndIf
		aAdd( oWSPers:oWSPeriodo , oWSNumPer )

		oWS:oWSrequest:oWSnomina:oWSperiodos := oWSPers
	EndIf

Return Nil
/*/{Protheus.doc} GM884Lugar
Asigna lugar de generacion de XML
@author arodriguez
@since 05/07/2021
@version 1.0
@return Nil
@param oWS - Objeto principal del WS
/*/
Static Function GM884Lugar(oWS)
	Local oWSLugarGeneracion	:= Service_LugarGeneracionXML():New()

	oWSLugarGeneracion:cpais := "CO"
	oWSLugarGeneracion:cdepartamentoEstado := aDatosSM0[1][2]	// SM0->M0_ESTCOB
	oWSLugarGeneracion:cmunicipioCiudad := AllTrim(aDatosSM0[2][2])	// (SM0->M0_CODMUN
	oWSLugarGeneracion:cidioma := "es"
	// Campos extensibles "LugarGeneracionXML"
	oExtensibles := GM884EXT("LugarGeneracionXML")
	If !(oExtensibles==Nil)
		oWSLugarGeneracion:oWSextrasNom := oExtensibles
	EndIf
	oWS:oWSrequest:oWSnomina:oWSLugarGeneracionXML := oWSLugarGeneracion
Return Nil
/*/{Protheus.doc} GM884Notas
Asigna notas  a XML 
@author arodriguez
@since 05/07/2021
@version 1.0
@return Nil
@param oWS - Objeto principal del WS
/*/
Static Function GM884Notas(oWS)
	Local oWSNots	:= Service_ArrayOfNota():New()
	Local oWSNote	:= Nil
	Local nFor		:= 0
	Local lMsj		:= .F.

	
	If Len(aMensajes) > 0
		For nFor := 1 to Len(aMensajes)
			If Empty(aMensajes[nFor,1]) .Or. aMensajes[nFor,1] == SRA->RA_FILIAL 
				oWSNote := Service_Nota():New()
				oWSNote:cdescripcion := aMensajes[nFor,2]
				// Campos extensibles "Notas"
				oExtensibles := GM884EXT("Notas")
				If !(oExtensibles==Nil)
					oWSNote:oWSextrasNom := oExtensibles
				EndIf
				aAdd( oWSNots:oWSNota, oWSNote )
				lMsj := .T.
			EndIf
		Next nFor

		If lMsj
			oWS:oWSrequest:oWSnomina:oWSNotas := oWSNots
		EndIf
	EndIf
	
Return Nil
/*/{Protheus.doc} GM884Trab
Asigna datos del trabajador al XML 
@author arodriguez
@since 05/07/2021
@version 1.0
@return Nil
@param oWS - Objeto principal del WS
/*/
Static Function GM884Trab(oWS)
	Local oWSTrab	:= Service_Trabajador():New()

	oWSTrab:ctipoTrabajador := cSTipoTrab // RA_TIPCOT
	oWSTrab:csubTipoTrabajador := cSubTpTrab // RA_SUBCOT
	oWSTrab:caltoRiesgoPension := IIf(cAltoRsgPn == "1", "1", "0" ) //RA_PORAFP
	oWSTrab:ctipoIdentificacion :=  fDescRCC("S022",(cAliasSRA)->RA_TPCIC,1,2,38,2)  // RA_TPCIC
	oWSTrab:cnumeroDocumento := Alltrim((cAliasSRA)->RA_CIC) // RA_CIC
	oWSTrab:cprimerApellido :=  Alltrim((cAliasSRA)->RA_PRISOBR) //  RA_PRISOBR
	oWSTrab:csegundoApellido :=  Alltrim((cAliasSRA)->RA_SECSOBR) // RA_SECSOBR
	oWSTrab:cprimerNombre :=  Alltrim((cAliasSRA)->RA_PRINOME) // RA_PRINOME
	If !Empty((cAliasSRA)->RA_SECNOME)
		oWSTrab:cotrosNombres := allTrim((cAliasSRA)->RA_SECNOME)		// RA_SECNOME
	EndIf
	oWSTrab:clugarTrabajoPais := "CO"
	oWSTrab:clugarTrabajoDepartamentoEstado := (cAliasSRA)->RA_ESTADO
	oWSTrab:clugarTrabajoMunicipioCiudad := Alltrim((cAliasSRA)->RA_MUNICIP)
	oWSTrab:clugarTrabajoDireccion := RTRIM((cAliasSRA)->RA_ENDEREC) + RTRIM((cAliasSRA)->RA_COMPLEM) + " "+RTRIM((cAliasSRA)->RA_BAIRRO)//"Direccion de prueba"

	oWSTrab:csalarioIntegral := IIf(cSalinteg $ '1|3',"0","1")//RA_TIPOSAL
	oWSTrab:ctipoContrato := fDescRCC("S018",(cAliasSRA)->RA_TIPOCO,1,2,71,1) //"1"
	oWSTrab:csueldo := Alltrim(STR(nSueldoEm,18,2)) //RA_SALARIO
	oWSTrab:ccodigoTrabajador := (cAliasSRA)->RA_MAT //RA_MAT
	oWSTrab:cemail :=  Alltrim((cAliasSRA)->RA_EMAIL) //"miCorreo@midominio.com"
	// Campos extensibles 
	oExtensibles := GM884EXT("Trabajador")
	If !(oExtensibles==Nil)
		oWSTrab:oWSextrasNom := oExtensibles
	EndIf
	oWS:oWSrequest:oWSnomina:oWStrabajador := oWSTrab

Return Nil
/*/{Protheus.doc} GM884Pago
Asigna informacion de pago del trabajador al XML 
@author arodriguez
@since 05/07/2021
@version 1.0
@return Nil
@param oWS - Objeto principal del WS
/*/
Static Function GM884Pago(oWS)
	Local oWSPags		:= Service_ArrayOfPago():New()
	Local oWSPag		:= Service_Pago():New()
	Local oWSFechasP	:= Service_ArrayOfFechaPago():New()
	Local oWSFechaP		:= Nil
	Local nFor 			:= 0
	Local nTamArr 		:= 0
	Local aBcoAgen 		:= {}
	Local cNombreBco 	:= ""
	Local cBcoCod 		:= ""
	Local cCtaBco 		:= ""


	// Bucle con fechas de pago, a partir de arreglo creado por NumPag
	nTamArr := Len(aFechasPer)
	For nFor := 1 to nTamArr
		oWSFechaP := Service_FechaPago():New()
		oWSFechaP:cfechapagonomina := FechaAMD(aFechasPer[nFor,4])
		// Campos extensibles 
		oExtensibles := GM884EXT("FechaPago")
		If !(oExtensibles==Nil)
			oWSFechaP:oWSextrasNom := oExtensibles
		EndIf
		aAdd( oWSFechasP:oWSFechaPago, oWSFechaP )
	Next nFor

	oWSPag:cmedioPago := IIf((cAliasSRA)->RA_FORPAG=='1' /*Consignación*/, "42", IIf((cAliasSRA)->RA_FORPAG=='2' /*Efectivo*/, "10", IIf((cAliasSRA)->RA_FORPAG=='3' /*Cheque*/, "20", /*4=Otros*/ "1")))
	oWSPag:cmetodoDePago := "1" //1= contado //Fijo
	
	If !Empty((cAliasSRA)->RA_BCOHAB) .AND. !Empty((cAliasSRA)->RA_CTDEPSA) 

		If "/" $ (cAliasSRA)->RA_BCOHAB 
			aBcoAgen := STRTOKARR((cAliasSRA)->RA_BCOHAB, "/")
			If Len(aBcoAgen) == 2 //banco y agencia
				cBcoCod := aBcoAgen[1]
				cCtaBco := aBcoAgen[2]
			EndIf
		Else
			cBcoCod := left((cAliasSRA)->RA_BCOHAB, TamSX3( "A6_COD" )[1])
			cCtaBco := right((cAliasSRA)->RA_BCOHAB, TamSX3( "A6_AGENCIA" )[1])
		Endif

		// Tabla de bancos //	
		DbSelectArea("SA6")
		SA6->( DbSetOrder(1) ) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON 
		SA6->( DbSeek( xFilial("SA6") + cBcoCod + cCtaBco , .F. ) )
		If !(SA6->(Eof()))
			cNombreBco := SA6->A6_NOME
		EndIf
		oWSPag:cnombreBanco := cNombreBco//	// RA_BCOHAB --> SA6->A6_NOME
		oWSPag:cnumeroCuenta :=(cAliasSRA)->RA_CTDEPSA // RA_CTADEPSA
		oWSPag:ctipoCuenta := (cAliasSRA)->RA_TIPOHAB // RA_TIPOHAB (descripción)
		
	Endif
	// Campos extensibles "Pago"
	//oWSPag:oWSextrasNom
	oExtensibles := GM884EXT("Pago")
	If !(oExtensibles==Nil)
		oWSPag:oWSextrasNom := oExtensibles
	EndIf

	oWSPag:oWSfechasPagos := oWSFechasP
	aAdd( oWSpags:oWSPago, oWSPag )

	oWS:oWSrequest:oWSnomina:oWSpagos := oWSpags
Return Nil
/*/{Protheus.doc} GM884Deven
Asigna los movimientos devengados del periodo al XML 
@author arodriguez
@since 05/07/2021
@version 1.0
@return Nil
@param 
/*/
Static Function GM884Deven()
	Local oWSDevengados		:= Service_Devengado():New()
	Local oWSAnticps		:= Service_ArrayOfAnticipoNom():New()
	Local oWSAnt			:= Nil
	Local oWSAuxils			:= Service_ArrayOfAuxilio():New()
	Local oWSAux			:= Nil
	Local oWSBasics			:= Service_ArrayOfBasico():New()
	Local oWSBasic			:= Nil
	Local oWSBonifics		:= Service_ArrayOfBonificacion():New()
	Local oWSBonif			:= Nil
	Local oWSBonos			:= Service_ArrayOfBonoEPCTV():New()
	Local oWSBono			:= Nil
	Local oWSCesans			:= Service_ArrayOfCesantia():New()
	Local oWSCesan			:= Nil
	Local oWSComisns		:= Service_ArrayOfComision():New()
	Local oWSComis			:= Nil
	Local oWSCompens		:= Service_ArrayOfCompensacion():New()
	Local oWSComp			:= Nil
	Local oWSHorasEx		:= Service_ArrayOfHoraExtra():New()
	Local oWSHoraEx			:= Nil
	Local oWSHuelgas		:= Service_ArrayOfHuelgaLegal():New()
	Local oWSHuelga			:= Nil
	Local oWSIncaps			:= Service_ArrayOfIncapacidad():New()
	Local oWSIncap			:= Nil
	Local oWSLicens			:= Service_Licencias():New()
	Local oWSLicenGrl		:= Nil
	Local oWSLics			:= Nil
	Local oWSVacCmpn		:= Nil
	Local oWSOtros			:= Service_ArrayOfOtroConcepto():New()
	Local oWSOtro			:= Nil
	Local oWSPagos3			:= Service_ArrayOfPagoTercero():New()
	Local oWSPago3			:= Nil
	Local oWSPrimas			:= Service_ArrayOfPrima():New()
	Local oWSPrima			:= Nil
	Local oWSTransps		:= Service_ArrayOfTransporte():New()
	Local oWSTrans			:= Nil
	Local oWSVacacs			:= Service_Vacacion():New()
	Local oWSVCompen		:= Nil
	Local oWSVComun			:= Nil
	Local nPost 			:= 0
	Local nNum 				:= 0
	Local cSTpXMLic 		:= ""

	nDevengT := 0
// Anticipos
	nPost := Len(aSAnticipo)
	If  nPost > 0
		For nNum := 1 to nPost
			oWSAnt := Service_AnticipoNom():New()
			oWSAnt:cmontoanticipo := AllTrim(STR(aSAnticipo[nNum][4] * nPorcent,18,2)) 
			nDevengT += aSAnticipo[nNum][4] * nPorcent
			// Campos extensibles
			oExtensibles := GM884EXT("Anticipo")
			If !(oExtensibles==Nil)
				oWSAnt:oWSextrasNom := Service_ArrayOfAnticipoNom():New()
				oWSAnt:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSAnticps:oWSanticipoNom , oWSAnt )
			oWSDevengados:oWSanticiposNom := oWSAnticps
		Next nNum
	EndIf
	If nSApoyoSos > 0
		// Apoyo aprendiz/practicante
		oWSDevengados:capoyoSost :=  AllTrim(STR(nSApoyoSos * nPorcent,18,2)) //"10000.00"
		nDevengT += nSApoyoSos * nPorcent
	EndIf

	// Auxilios
	nPost := Len(aSAuxilio)
	If  nPost > 0
		For nNum := 1 to nPost
			oWSAux := Service_Auxilio():New()
			If aSAuxilio[nNum][4] > 0
				nDevengT += aSAuxilio[nNum][4]
				oWSAux:cauxilioS  :=  AllTrim(STR(aSAuxilio[nNum][4] ,18,2))
			EndIf
			If aSAuxilio[nNum][5] > 0
				nDevengT += aSAuxilio[nNum][5]
				oWSAux:cauxilioNS :=  AllTrim(STR(aSAuxilio[nNum][5] ,18,2))
			EndIf
			// Campos extensibles 
			oExtensibles := GM884EXT("Auxilio")
			If !(oExtensibles==Nil)
				oWSAux:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSAuxils:oWSAuxilio , oWSAux )
			oWSDevengados:oWSAuxilios := oWSAuxils
	
		Next nNum
	EndIf


	// Básicos
	oWSBasic := Service_Basico():New()
	If lNovedadOK .and. len(aSalDiaQ) >= 0 .and. nContNov > 0
		nSDiasTrab := aSalDiaQ[nContNov][3]
		oWSBasic:cdiasTrabajados :=  AllTrim(STR(nSDiasTrab)) //"15"
	Else
		oWSBasic:cdiasTrabajados :=  AllTrim(STR(nSDiasTrab/8)) //"15"
	EndIf
	nDevengT += nSSueldoTr * nPorcent
	oWSBasic:csueldoTrabajado := AllTrim(STR(nSSueldoTr * nPorcent,18,2))//""
	// Campos extensibles 
	oExtensibles := GM884EXT("Basico")
	If !(oExtensibles==Nil)
		oWSBasic:oWSextrasNom := oExtensibles
	EndIf
	aAdd( oWSBasics:oWSBasico , oWSBasic )
	oWSDevengados:oWSBasico := oWSBasics

	// Bonificación retiro
	If nSBonifRet > 0
		oWSDevengados:cbonifRetiro :=  AllTrim(STR(nSBonifRet,18,2))//"10000.00"
		nDevengT += nSBonifRet
	Endif

	// Bonificaciones
	nPost := Len(aSBonifica)
	If  nPost > 0
		For nNum := 1 to nPost
			oWSBonif := Service_Bonificacion():New()
			If aSBonifica[nNum][4] > 0
				nDevengT += aSBonifica[nNum][4]
				oWSBonif:cbonificacionS  :=  AllTrim(STR(aSBonifica[nNum][4] ,18,2))
			EndIf
			If aSBonifica[nNum][5] > 0
				nDevengT += aSBonifica[nNum][5] 
				oWSBonif:cbonificacionNS :=  AllTrim(STR(aSBonifica[nNum][5] ,18,2))
			EndIf
			// Campos extensibles 
			oExtensibles := GM884EXT("Bonificacion")
			If !(oExtensibles==Nil)
				oWSBonif:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSBonifics:oWSbonificacion , oWSBonif )
			oWSDevengados:oWSbonificaciones := oWSBonifics
		Next nNum
	EndIf
	
	// Bonos EPCTV
	nPost := Len(aSBonEPCTV)
	If  nPost > 0
		For nNum := 1 to nPost
			oWSBono := Service_BonoEPCTV():New()
			If aSBonEPCTV[nNum][6] > 0
				nDevengT += aSBonEPCTV[nNum][6]
				oWSBono:cpagoAlimentacionS := AllTrim(STR(aSBonEPCTV[nNum][6] ,18,2))
			EndIf
			If aSBonEPCTV[nNum][7] > 0
				nDevengT += aSBonEPCTV[nNum][7]
				oWSBono:cpagoAlimentacionNS := AllTrim(STR(aSBonEPCTV[nNum][7] ,18,2))
			EndIf
			If aSBonEPCTV[nNum][4] > 0
				nDevengT += aSBonEPCTV[nNum][4]
				oWSBono:cpagoS := AllTrim(STR(aSBonEPCTV[nNum][4] ,18,2))
			EndIf
			If aSBonEPCTV[nNum][5] > 0 
				nDevengT += aSBonEPCTV[nNum][5]
				oWSBono:cpagoNS :=AllTrim(STR(aSBonEPCTV[nNum][5] ,18,2))
			EndIf
			// Campos extensibles 
			oExtensibles := GM884EXT("BonoEPCTV")
			If !(oExtensibles==Nil)
				oWSBono:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSBonos:oWSBonoEPCTV , oWSBono )
			oWSDevengados:oWSbonoEPCTVs := oWSBonos
		Next nNum
	EndIf

	// Cesantias
	nPost := Len(aSCesantia)
	If  nPost > 0
		For nNum := 1 to nPost
			oWSCesan := Service_Cesantia():New()
			oWSCesan:cpago :=  AllTrim(STR(aSCesantia[nNum][4],18,2)) //"10000.00"
			oWSCesan:cpagoIntereses :=  AllTrim(STR(aSCesantia[nNum][5],18,2))//"10000.00"
			oWSCesan:cporcentaje :=  AllTrim(STR(nSPgoCesPr,18,2))//"10.00
			nDevengT += aSCesantia[nNum][4] + aSCesantia[nNum][5]
			// Campos extensibles 
			oExtensibles := GM884EXT("Cesantia")
			If !(oExtensibles==Nil)
				oWSCesan:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSCesans:oWSCesantia , oWSCesan )
			oWSDevengados:oWScesantias := oWSCesans
		Next nNum
	EndIf

	// Comisiones
	nPost := Len(aSComision)
	If  nPost > 0
		For nNum := 1 to nPost
			oWSComis := Service_Comision():New()
			oWSComis:cmontocomision :=  AllTrim(STR(aSComision[nNum][4] ,18,2)) //"10000.00"
			nDevengT += aSComision[nNum][4]
			// Campos extensibles 
			oExtensibles := GM884EXT("Comision")
			If !(oExtensibles==Nil)
				oWSComis:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSComisns:oWSComision , oWSComis )
			oWSDevengados:oWScomisiones := oWSComisns
		Next nNum
	EndIf

	// Compensaciones
	nPost := Len(aSCompensa)
	If  nPost > 0
		For nNum := 1 to nPost
			oWSComp := Service_Compensacion():New()
			oWSComp:ccompensacionO :=  AllTrim(STR(aSCompensa[nNum][4],18,2)) //"10000.00"
			oWSComp:ccompensacionE :=  AllTrim(STR(aSCompensa[nNum][5],18,2)) //"10000.00"
			//nDevengT += aSCompensa[nNum][4] + aSCompensa[nNum][5]
			// Campos extensibles 
			oExtensibles := GM884EXT("Compensacion")
			If !(oExtensibles==Nil)
				oWSComp:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSCompens:oWSCompensacion , oWSComp )
			oWSDevengados:oWScompensaciones := oWSCompens
		Next nNum
	EndIf
	If nSDotacion > 0
		// Dotación
		oWSDevengados:cdotacion :=  AllTrim(STR(nSDotacion,18,2))
		nDevengT += nSDotacion
	Endif

	nPost:= Len(aSHorasExt)
	// Horas extra
	IF nPost > 0
		For nNum := 1 to nPost
			oWSHoraEx := Service_HoraExtra():New()
			oWSHoraEx:choraInicio := aSHorasExt[nNum][3] //"2021-03-02 12:00:00"
			oWSHoraEx:choraFin := aSHorasExt[nNum][4]  //"2021-03-02 12:00:00"
			oWSHoraEx:ccantidad :=  AllTrim(STR(aSHorasExt[nNum][5])) //"1"
			oWSHoraEx:cpago :=  AllTrim(STR(aSHorasExt[nNum][7],18,2))//"10000.00"
			oWSHoraEx:cporcentaje := aSHorasExt[nNum][6] //"25.00"
			oWSHoraEx:ctipoHorasExtra := aSHorasExt[nNum][2] //"0"
			nDevengT += aSHorasExt[nNum][7]
			//Campos extensibles 
			oExtensibles :=  GM884EXT('HoraExtra')
			If !(oExtensibles==Nil)
				oWSHoraEx:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSHorasEx:oWSHoraExtra , oWSHoraEx )
			oWSDevengados:oWShorasExtras := oWSHorasEx
		Next nNum
	EndIf

	// Huelgas legales
	nPost:= Len(aSHuelgas)
	IF nPost > 0
		For nNum := 1 to nPost
			oWSHuelga := Service_HuelgaLegal():New()
			oWSHuelga:cfechaInicio := FechaAMD(aSHuelgas[nNum][2])
			oWSHuelga:cfechaFin := FechaAMD(aSHuelgas[nNum][3])
			oWSHuelga:ccantidad := Alltrim(STR(aSHuelgas[nNum][4]))//"1"
			// Campos extensibles 
			oExtensibles := GM884EXT("HuelgaLegal")
			If !(oExtensibles==Nil)
				oWSHuelga:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSHuelgas:oWSHuelgaLegal , oWSHuelga )
			oWSDevengados:oWShuelgasLegales := oWSHuelgas
		Next nNum
	EndIf

	// Incapacidades
	nPost:= Len(aSIncapaci)
	IF nPost > 0
		For nNum := 1 to nPost
			oWSIncap := Service_Incapacidad():New()
			oWSIncap:cfechaInicio := FechaAMD(aSIncapaci[nNum][2])
			oWSIncap:cfechaFin := FechaAMD(aSIncapaci[nNum][3])
			oWSIncap:ccantidad := Alltrim(STR(aSIncapaci[nNum][4]))//"1"
			oWSIncap:cpago := Alltrim(STR(aSIncapaci[nNum][5],18,2))
			oWSIncap:ctipo := aSIncapaci[nNum][6]
			nDevengT += aSIncapaci[nNum][5]
			// Campos extensibles 
			oExtensibles := GM884EXT("Incapacidad")
			If !(oExtensibles==Nil)
				oWSIncap:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSIncaps:oWSIncapacidad , oWSIncap )
			oWSDevengados:oWSincapacidades := oWSIncaps
		Next nNum
	EndIf

	// Indemnización
	If nSIndenmni > 0
		oWSDevengados:cindemnizacion :=  AllTrim(STR(nSIndenmni,18,2)) //"10000.00"
		nDevengT += nSIndenmni
	Endif

	//Licencias
	nPost:= Len(aSLicencia)
	If nPost > 0
		ASORT(aSLicencia, , , { | x,y | x[1] < y[1] } ) // ordena de menor a mayor
		For nNum := 1 to nPost
            oWSLicenGrl := Service_Licencia():New()
            oWSLicenGrl:cfechaInicio := FechaAMD(aSLicencia[nNum][2])
			oWSLicenGrl:cfechaFin :=  FechaAMD(aSLicencia[nNum][3])
			oWSLicenGrl:ccantidad := Alltrim(STR(aSLicencia[nNum][4]))//"1"
			oWSLicenGrl:cpago := Alltrim(STR(aSLicencia[nNum][5],18,2))
			If aSLicencia[nNum][1] != '212'
				nDevengT += aSLicencia[nNum][5]
			EndIf
			// Campos extensibles 
			oExtensibles := GM884EXT("Licencia")
			If !(oExtensibles==Nil)
				oWSLicenGrl:oWSextrasNom := oExtensibles
			EndIf
			If aSLicencia[nNum][1] <> cSTpXMLic
				oWSLics :=  Service_ArrayOfLicencia():New()
			Endif
			aAdd( oWSLics:oWSlicencia, oWSLicenGrl)
			If aSLicencia[nNum][1] == '125'
				// Licencias de maternidad/paternidad
				oWSLicens:oWSlicenciaMP :=  oWSLics
			ElseIf aSLicencia[nNum][1] == '126'
				// Licencias remuneradas
				oWSLicens:oWSlicenciaR := oWSLics 
			ElseIf aSLicencia[nNum][1] == '212'
				// Licencias no remuneradas
				oWSLicens:oWSlicenciaNR := oWSLics 
			EndIf
			cSTpXMLic :=  aSLicencia[nNum][1]
		Next nNum
		oWSDevengados:oWSlicencias := oWSLicens
	EndIf

	// Otros conceptos
	nPost:= Len(aSOtroConc)
	If nPost > 0
		For nNum := 1 to nPost
			oWSOtro := Service_OtroConcepto():New()
			If aSOtroConc[nNum][4] 
				oWSOtro:cconceptoS := Alltrim(STR(aSOtroConc[nNum][4],18,2))
				nDevengT += aSOtroConc[nNum][4]
			ElseIf aSOtroConc[nNum][5] 
				oWSOtro:cconceptoNS := Alltrim(STR(aSOtroConc[nNum][5],18,2))
				nDevengT += aSOtroConc[nNum][5]
			EndIf
			oWSOtro:cdescripcionConcepto :=  aSOtroConc[nNum][3]
			// Campos extensibles 
			oExtensibles := GM884EXT("OtroConcepto")
			If !(oExtensibles==Nil)
				oWSOtro:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSOtros:oWSOtroConcepto , oWSOtro )
			oWSDevengados:oWSotrosConceptos := oWSOtros
		Next nNum
	EndIf

	// Pagos terceros
	nPost:= Len(aSPagoTerc)
	If nPost > 0
		For nNum := 1 to nPost
			oWSPago3 := Service_PagoTercero():New()
			oWSPago3:cmontopagotercero := Alltrim(STR(aSPagoTerc[nNum][4] ,18,2))
			nDevengT += aSPagoTerc[nNum][4]
			// Campos extensibles 
			oExtensibles := GM884EXT("PagoTercero")
			If !(oExtensibles==Nil)
				oWSPago3:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSPagos3:oWSPagoTercero , oWSPago3 )
			oWSDevengados:oWSpagosTerceros := oWSPagos3
		Next nNum
	EndIf

	// Primas
	If nSDiaPrima > 0 .Or. nSPagPrima > 0
		oWSPrima := Service_Prima():New()
		oWSPrima:ccantidad := Alltrim(STR(nSDiaPrima))
		oWSPrima:cpago := Alltrim(STR(nSPagPrima,18,2))
		nDevengT += nSPagPrima
		If nSPgPriNoS > 0 
			oWSPrima:cpagoNS := Alltrim(STR(nSPgPriNoS,18,2))
			nDevengT += nSPgPriNoS
		EndIf
		// Campos extensibles 
		oExtensibles := GM884EXT("Prima")
		If !(oExtensibles==Nil)
			oWSPrima:oWSextrasNom := oExtensibles
		EndIf
		aAdd( oWSPrimas:oWSPrima , oWSPrima )
		oWSDevengados:oWSprimas := oWSPrimas
	Endif

	// Reintegro
	If nSReintegr > 0
		oWSDevengados:creintegro :=  AllTrim(STR(nSReintegr * nPorcent,18,2))//"10000.00"
		nDevengT += nSReintegr * nPorcent
	EndIf
	// Teletrabajo
	If nSTelTraba > 0
		oWSDevengados:cteletrabajo :=  AllTrim(STR(nSTelTraba,18,2)) //"10000.00"
		nDevengT += nSTelTraba
	EndIf

	// Transporte
	nPost:= Len(aSTranspor)
	If nPost > 0
		For nNum := 1 to nPost
			oWSTrans := Service_Transporte():New()
			If aSTranspor[nNum][4] > 0
				oWSTrans:cauxilioTransporte :=  AllTrim(STR(aSTranspor[nNum][4],18,2))
				nDevengT +=aSTranspor[nNum][4]
			EndIf
			If aSTranspor[nNum][5] > 0
				oWSTrans:cviaticoManuAlojs := AllTrim(STR(aSTranspor[nNum][5],18,2))
				nDevengT +=aSTranspor[nNum][5]
			EndIf
			If aSTranspor[nNum][6] > 0
				oWSTrans:cviaticoManuAlojNS :=AllTrim(STR( aSTranspor[nNum][6],18,2))
				nDevengT +=aSTranspor[nNum][6]
			Endif
			// Campos extensibles 
			oExtensibles := GM884EXT("Transporte")
			If !(oExtensibles==Nil)
				oWSTrans:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSTransps:oWSTransporte , oWSTrans )
			oWSDevengados:oWStransporte := oWSTransps
		Next nNum
	EndIf		

	// Vacaciones comunes
	nPost:= Len(aSVacacion)
	IF nPost > 0
		
		oWSVacCmpn:= Service_ArrayOfVacaciones():New()
		For nNum := 1 to nPost
			oWSVComun := Service_Vacaciones():New()
			oWSVComun:cfechaInicio := FechaAMD(aSVacacion[nNum][2])
			oWSVComun:cfechaFin := FechaAMD(aSVacacion[nNum][3])
			oWSVComun:ccantidad :=Alltrim(STR(aSVacacion[nNum][4]))
			oWSVComun:cpago := Alltrim(STR(aSVacacion[nNum][5],18,2))
			nDevengT += aSVacacion[nNum][5]
			// Campos extensibles 
			oExtensibles := GM884EXT("VacacionesComunes")
			If !(oExtensibles==Nil)
				oWSVComun:oWSextrasNom := oExtensibles
			EndIf
			aadd(oWSVacCmpn:oWSVacaciones, oWSVComun) 
			
		Next nNum
		oWSVacacs:oWSvacacionesComunes := oWSVacCmpn
		oWSDevengados:oWSvacaciones := oWSVacacs
	EndIf

	// Vacaciones compensadas
	nPost:= Len(aSVacaComp)
	IF nPost > 0
		oWSVacCmpn:= Service_ArrayOfVacaciones():New()
		For nNum := 1 to nPost
			oWSVCompen := Service_Vacaciones():New()
			oWSVCompen:ccantidad :=Alltrim(STR(aSVacaComp[nNum][4]))
			oWSVCompen:cpago := Alltrim(STR(aSVacaComp[nNum][5],18,2))
			nDevengT += aSVacaComp[nNum][5]
			// Campos extensibles 
			oExtensibles := GM884EXT("VacacionesCompensadas")
			If !(oExtensibles==Nil)
				oWSVCompen:oWSextrasNom := oExtensibles
			EndIf
			aadd(oWSVacCmpn:oWSVacaciones, oWSVCompen)
		Next nNum
		oWSVacacs:oWSvacacionesCompensadas := oWSVacCmpn
		oWSDevengados:oWSvacaciones := oWSVacacs
	EndIf

	// Campos extensibles 
	oExtensibles := GM884EXT("Devengados")
	If !(oExtensibles==Nil)
		oWSDevengados:oWSextrasNom := oExtensibles
	EndIf
	oWS:oWSrequest:oWSnomina:oWSdevengados := oWSDevengados


Return Nil
/*/{Protheus.doc} GM884Deduc
Asigna los movimientos deducciones del periodo al XML 
@author arodriguez
@since 05/07/2021
@version 1.0
@return Nil
@param 
/*/
Static Function GM884Deduc()
	Local oWSDeducciones	:= Service_Deduccion():New()
	Local oWSAnticps		:= Service_ArrayOfAnticipoNom():New()
	Local oWSAnt			:= Nil
	Local oWSfondosP		:= Service_ArrayOfFondoPension():New()
	Local oWSfondoP			:= Nil
	Local oWSfonsSP			:= Service_ArrayOfFondoSP():New()
	Local oWSfonSP			:= Nil
	Local oWSlibrans		:= Service_ArrayOfLibranza():New()
	Local oWSlibran			:= Nil
	Local oWSotrasD			:= Service_ArrayOfOtraDeduccion():New()
	Local oWSotraD			:= Nil
	Local oWSpagos3			:= Service_ArrayOfPagoTercero():New()
	Local oWSpago3			:= Nil
	Local oWSsaludDs		:= Service_ArrayOfSalud():New()
	Local oWSsaludD			:= Nil
	Local oWSsancins		:= Service_ArrayOfSancion():New()
	Local oWSsancion		:= Nil
	Local oWSsindics		:= Service_ArrayOfSindicato():New()
	Local oWSsindic			:= Nil
	Local nPost 			:= 0
	Local nNum 				:= 0

	nDeduccT := 0
	// Ahorro Fomento a la contruccion
	If nSAFC != 0 
		oWSDeducciones:cafc :=  Alltrim(STR(nSAFC,18,2))
		nDeduccT += nSAFC
	EndIf
	// Anticipos
	nPost:= Len(aSAnticipD)
	IF nPost > 0
		For nNum := 1 to nPost
			oWSAnt := Service_AnticipoNom():New()
			oWSAnt:cmontoanticipo := Alltrim(STR(aSAnticipD[nNum][4],18,2))
			nDeduccT += aSAnticipD[nNum][4]
			// Campos extensibles
			oExtensibles := GM884EXT("AnticipoDeduc")
			If !(oExtensibles==Nil)
				oWSAnt:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSAnticps:oWSAnticipoNom , oWSAnt )
			oWSDeducciones:oWSanticiposNom := oWSAnticps
		Next nNum
	EndIf
	// Cooperativa
	If nSCooperat != 0 
		oWSDeducciones:ccooperativa := Alltrim(STR(nSCooperat,18,2))
		nDeduccT += nSCooperat
	Endif
	// Deuda
	If nSDeuda != 0 
		oWSDeducciones:cdeuda := Alltrim(STR(nSDeuda,18,2))
		nDeduccT += nSDeuda
	Endif
	// Educación
	If nSEduca != 0 
		oWSDeducciones:ceducacion := Alltrim(STR(nSEduca,18,2))
		nDeduccT += nSEduca
	Endif
	// Embargo fiscal
	If nSEmbarFis != 0 
		oWSDeducciones:cembargoFiscal := Alltrim(STR(nSEmbarFis * nPorcent,18,2))
		nDeduccT += nSEmbarFis * nPorcent
	Endif

	// Fondos pensiones
	oWSfondoP := Service_FondoPension():New()
	oWSfondoP:cdeduccion := Alltrim(STR(nSFdPenDed * nPorcent,18,2))
	oWSfondoP:cporcentaje := Alltrim(STR(nSPrPenDed * nPorcent,18,2))
	nDeduccT += nSFdPenDed * nPorcent
	// Campos extensibles 
	oExtensibles := GM884EXT("Pension")
	If !(oExtensibles==Nil)
		oWSfondoP:oWSextrasNom := oExtensibles
	EndIf
	aAdd( oWSfondosP:oWSFondoPension , oWSfondoP )
	oWSDeducciones:oWSfondosPensiones := oWSfondosP

	// Fondo de seguridad pensional
	If nSFonDedSP > 0 .Or. nSFonDeSub > 0 .Or. nSFonDePrj > 0 .Or. nSFonPrSub > 0
		oWSfonSP := Service_FondoSP():New()
		If nSFonDedSP > 0
			oWSfonSP:cdeduccionSP := Alltrim(STR(nSFonDedSP * nPorcent,18,2))
			nDeduccT += nSFonDedSP * nPorcent
		EndIf
		If nSFonDeSub > 0 
			oWSfonSP:cdeduccionSub := Alltrim(STR(nSFonDeSub * nPorcent,18,2))
			nDeduccT += nSFonDeSub * nPorcent
		EndIf
		If nSFonDePrj > 0 
			oWSfonSP:cporcentaje := Alltrim(STR(nSFonDePrj * nPorcent,18,2))
		EndIf
		If nSFonPrSub > 0 
			oWSfonSP:cporcentajeSub := Alltrim(STR(nSFonPrSub * nPorcent,18,2))
		EndIf
		// Campos extensibles 
		oExtensibles := GM884EXT("FondoSP")
		If !(oExtensibles==Nil)
			oWSfonSP:oWSextrasNom := oExtensibles
		EndIf
		aAdd( oWSfonsSP:oWSFondoSP , oWSfonSP )
		oWSDeducciones:oWSfondosSP := oWSfonsSP
	EndIf

	// Libranzas
	nPost:= Len(aSLibranza)
	IF nPost > 0
		For nNum := 1 to nPost
			oWSlibran := Service_Libranza():New()
			oWSlibran:cdeduccion := Alltrim(STR(aSLibranza[nNum][4],18,2))
			oWSlibran:cdescripcion := Alltrim(aSLibranza[nNum][6])
			nDeduccT += aSLibranza[nNum][4]
			// Campos extensibles 
			oExtensibles := GM884EXT("Libranza")
			If !(oExtensibles==Nil)
				oWSlibran:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSlibrans:oWSLibranza , oWSlibran )
			oWSDeducciones:oWSlibranzas := oWSlibrans
		Next nNum
	EndIf
	// Otras deducciones
	nPost:= Len(aSOtraDedu)
	IF nPost > 0
		For nNum := 1 to nPost
			oWSotraD := Service_OtraDeduccion():New()
			oWSotraD:cmontootraDeduccion := Alltrim(STR(aSOtraDedu[nNum][4],18,2))
			nDeduccT += aSOtraDedu[nNum][4]
			// Campos extensibles 
			oExtensibles := GM884EXT("OtraDeduccion")
			If !(oExtensibles==Nil)
				oWSotraD:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSotrasD:oWSOtraDeduccion , oWSotraD )
			oWSDeducciones:oWSotrasDeducciones := oWSotrasD
		Next nNum
	EndIf

	// Pagos a terceros
	nPost:= Len(aSPagTerce)
	IF nPost > 0
		For nNum := 1 to nPost
			oWSpago3 := Service_PagoTercero():New()
			oWSpago3:cmontopagotercero := Alltrim(STR(aSPagTerce[nNum][4],18,2))
			nDeduccT += aSPagTerce[nNum][4]
			// Campos extensibles 
			oExtensibles := GM884EXT("PagoTerceroDeduc")
			If !(oExtensibles==Nil)
				oWSpago3:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSpagos3:oWSPagoTercero , oWSpago3 )
			oWSDeducciones:oWSpagosTerceros := oWSpagos3
		Next nNum
	Endif
	// Pension voluntaria
	If nSPensionV != 0 
		oWSDeducciones:cpensionVoluntaria :=  Alltrim(STR(nSPensionV,18,2))
		nDeduccT += nSPensionV
	Endif
	// Plan complementario de salud
	If nSPlanComS!= 0 
		oWSDeducciones:cplanComplementarios := Alltrim(STR(nSPlanComS,18,2))
		nDeduccT += nSPlanComS
	Endif
	// Reintegro
	If nSReintegD != 0 
		oWSDeducciones:creintegro := Alltrim(STR(nSReintegD * nPorcent,18,2))
		nDeduccT += nSReintegD * nPorcent
	Endif
	// Retención en la fuente por ingresos laborales
	If nSRtFuente != 0 
		oWSDeducciones:cretencionFuente :=  Alltrim(STR(nSRtFuente * nPorcent,18,2))
		nDeduccT += nSRtFuente * nPorcent
	Endif

	// Salud
	oWSsaludD := Service_Salud():New()
	oWSsaludD:cdeduccion := Alltrim(STR(nSSaludDed * nPorcent,18,2)) 
	oWSsaludD:cporcentaje := Alltrim(STR(nSSaludPor * nPorcent,18,2)) 
	nDeduccT += nSSaludDed * nPorcent
	// Campos extensibles 
	oExtensibles := GM884EXT("Salud")
	If !(oExtensibles==Nil)
		oWSsaludD:oWSextrasNom := oExtensibles
	EndIf
	aAdd( oWSsaludDs:oWSSalud , oWSsaludD )
	oWSDeducciones:oWSsalud := oWSsaludDs

	// Sanciones
	nPost:= Len(aSSancion)
	IF nPost > 0
		For nNum := 1 to nPost
			oWSsancion := Service_Sancion():New()
			oWSsancion:csancionPublic := Alltrim(STR(aSSancion[nNum][4],18,2))
			oWSsancion:csancionPriv := Alltrim(STR(aSSancion[nNum][5],18,2))
			nDeduccT += aSSancion[nNum][4] + aSSancion[nNum][5]
			// Campos extensibles 
			oExtensibles := GM884EXT("Sancion")
			If !(oExtensibles==Nil)
				oWSsancion:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSsancins:oWSSancion , oWSsancion )
			oWSDeducciones:oWSsanciones := oWSsancins
		Next nNum
	Endif

	// Sindicatos
	nPost:= Len(aSSindicat)
	IF nPost > 0
		For nNum := 1 to nPost
			oWSsindic := Service_Sindicato():New()
			oWSsindic:cdeduccion := Alltrim(STR(aSSindicat[nNum][5] * nPorcent,18,2))
			oWSsindic:cporcentaje := Alltrim(STR(aSSindicat[nNum][4] * nPorcent,18,2))
			nDeduccT += aSSindicat[nNum][5]
			// Campos extensibles 
			oExtensibles := GM884EXT("Sindicato")
			If !(oExtensibles==Nil)
				oWSsindic:oWSextrasNom := oExtensibles
			EndIf
			aAdd( oWSsindics:oWSSindicato , oWSsindic )
			oWSDeducciones:oWSsindicatos := oWSsindics
		Next nNum
	Endif

	// Campos extensibles Devengados
	oExtensibles := GM884EXT("Deducciones")
	If !(oExtensibles==Nil)
		oWSDeducciones:oWSextrasNom := oExtensibles
	EndIf

	oWS:oWSrequest:oWSnomina:oWSdeducciones := oWSDeducciones

Return Nil


/*/{Protheus.doc} fMensajes
Obtiene mensajes del Catalogo S090 
@author arodriguez
@since 05/07/2021
@version 1.0
@return cMensajes
@param 
/*/

Function fMensajes()
Local _aArea	:= GetArea()
Local aMensajes	:= {}
Local cCodigo	:= "S090"
Local cMensajes	:= IIf(!Empty(cMensaje1), cMensaje1 + "/", "") + IIf(!Empty(cMensaje2), cMensaje2 + "/", "") + IIf(!Empty(cMensaje3), cMensaje3 + "/", "") + cMensajeXML
Local cClave	:= cProceso + cRoteiro + cPeriodo
Local nLenCve	:= GetSx3Cache("RD_PROCES","X3_TAMANHO") + GetSx3Cache("RD_ROTEIR","X3_TAMANHO") + GetSx3Cache("RD_PERIODO","X3_TAMANHO")

/*
	Columna 1 = Código mensaje c1
	Columna 2 = Mensaje c30
	Columna 3 = Proceso c5 (SRD->RD_PROCES)
	Columna 4 = Procedimiento c3 (SRD->RD_ROTEIR)
	Columna 5 = Periodo c6 (SRD->RD_PERIODO)
	Columna 6 = Número de pago c2 (SRD->RD_SEMANA)
*/

If !Empty(cMensajes)
	dbSelectArea( "RCC" )
	dbSetOrder(1)
	dbSeek(xFilial("RCC") + cCodigo)//RCC_FILIAL+RCC_CODIGO
	While !Eof() .AND. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+cCodigo
		If RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+cCodigo .AND. Alltrim(Substr(RCC->RCC_CONTEU,1,1)) $ cMensajes .And. Substr(RCC->RCC_CONTEU,32,nLenCve) == cClave
			If Empty(RCC->RCC_FIL) .or. RCC->RCC_FIL == xFilial("RCC")
				aAdd( aMensajes, {RCC->RCC_FIL, Alltrim(Substr(RCC->RCC_CONTEU,2,30))})
			EndIf
		EndIf
		dBSkip()	
	EndDo

	RestArea(_aArea)
EndIf

Return(aMensajes)           


/*/{Protheus.doc} FechaAMD
Convierte Fecha de tipo date o String a fecha string separada por guiones  
@author arodriguez
@since 05/07/2021
@version 1.0
@return cFechaRet
@param dFecha - fecha tipo date o String 
/*/      
Static Function FechaAMD(dFecha)
Local cFechaRet := ""
	If ValType( dFecha ) == "C"
		dFecha:=  STOD(dFecha)	
	Endif
	cFechaRet := Strzero(Year(dFecha),4) + "-" + Strzero(Month(dFecha),2) + "-" + Strzero(Day(dFecha),2)
Return cFechaRet

/*/{Protheus.doc} GerNumCons
Genera un número Consecutivo (SX5) y el prefijo (SFP)
@author Alfredo Medrano
@since 05/07/2021
@version 1.0
@return cImpX5
@param cClave - Serie
/*/  
Static Function GerNumCons(cClave, cConsecut,cRangoNum)
Local aAreaA	:= GetArea()
Local cImpX5 	:= ""
Local cSerie2	:= ""
Local cNumCert 	:= "" 
Local cImpX5Tam	:= ""
Local nNumIni   := 0

Default cClave	:= ""     
    
	cNumCert := PadL( "1", TamSX3( "FP_NUMINI" )[1], "0" )
	dbSelectArea("SFP")
	SFP->(dbSetOrder(3)) // FP_FILIAL+FP_FILUSO+FP_SERIE+FP_CAI+FP_NUMINI+FP_NUMFIM+FP_ESPECIE+FP_PV 
	If SFP->(dbSeek(xFilial("SFP")+cFilAnt+cClave))
		cSerie2 := Alltrim(SFP->FP_SERIE2) 
		nNumIni := VAL(SFP->FP_NUMINI)
		cRangoNum := cSerie2 + "-" + Alltrim(STR(nNumIni))
	EndIf

	If !Empty(cClave) 	
		DbSelectArea("SX5")
		If dbSeek(xFilial("SX5")+"01"+cClave)
			cImpX5 := (X5Descri())
			cImpX5 := Alltrim(STR(VAL(cImpX5)+1))
			cImpX5Tam := PadL( cImpX5, TamSX3( "FP_NUMINI" )[1], "0" ) // se asignan el tamaño del campo de número de inicial (13)
			If RecLock("SX5",.F.) 
				Replace X5_DESCRI	WITH cImpX5Tam
				Replace X5_DESCSPA	WITH cImpX5Tam
				Replace X5_DESCENG	WITH cImpX5Tam
				SX5->(MsUnLock())
			EndIf
		Else
			RecLock("SX5", .T.)
				SX5->X5_TABELA 	:= '01'
				SX5->X5_FILIAL 	:= xFilial("SX5")
				SX5->X5_CHAVE  	:= cClave
				SX5->X5_DESCRI 	:= cNumCert
				SX5->X5_DESCSPA := cNumCert
				SX5->X5_DESCENG := cNumCert
				cImpX5       	:= '1'
			MsUnLock()
   		EndIf
	
	Endif   
	cConsecut := cSerie2 + cImpX5     
RestArea(aAreaA)
Return 


/*/{Protheus.doc} GM884EXT
Obtiene inforamcion adicional del punto de entrada GR884CEX
para informar los campos extensibles
@author Alfredo Medrano
@since 05/07/2021
@version 1.0
@return oWSExtensibles
@param cElemento - Elemento del XML
/*/  
Function GM884EXT( cElemento )
	Local aM884CExt		:= {}
	Local aCamposExt	:= {}
	Local nX			:= 0
	Local nY			:= 0
	Local lOK			:= .F.
	Local oWSExtensibles:= Nil
	Local oWSCamposExt	:= Nil
	Default cElemento 	:= "" 

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
	If cElemento != ""
		If ExistBlock("GR884CEX")
			aM884CExt := ExecBlock("GR884CEX", .F., .F., {aNomina,cElemento,oWS} )

			If Len(aM884CExt) > 0 .And. ValType(aM884CExt) == "A"
				For nX := 1 to Len(aM884CExt)
					lOK := .F.
					If Len(aM884CExt[nX]) == 6 .And. ValType(aM884CExt[nX]) == "A"
						aEval( aM884CExt , {|x,y| IIf(ValType(x[y]) == "U", aM884CExt[nX,y]:="", ) })
						IIf(ValType(aM884CExt[nX,4]) == "N", aM884CExt[nX,4]:=Alltrim(Str(aM884CExt[nX,4])), )
						IIf(ValType(aM884CExt[nX,6]) == "N", aM884CExt[nX,6]:=Alltrim(Str(aM884CExt[nX,6])), )
						If !Empty(aM884CExt[nX][3]) .And. (aM884CExt[nX][4] $ "0|1") .And. (aM884CExt[nX][6] $ "0|1")
							lOK := .T.
						EndIf
					EndIf
					If lOK
						aAdd( aCamposExt , aM884CExt[nX] )
						
					Else
						Conout( STR0025  + aNomina[1] + " - " + aNomina[2] + " - " + aNomina[3] + " - " + aNomina[4] + " #Item " + Str(nX) ) // "PE GR884CEX regresa valores incorrectos para campos extensibles; Proceso - Procedimeinto - Periodo - Matricua: "
					EndIf
				Next nX

			Else
				Conout( STR0025 + aNomina[1] + " - " + aNomina[2] + " - " + aNomina[3] + " - " + aNomina[4] ) // "PE GR884CEX regresa valores incorrectos para campos extensibles; Proceso - Procedimeinto - Periodo - Matricua: " 
			EndIf
		Endif
	EndIf

	If Len(aCamposExt)>0
		oWSExtensibles := Service_ArrayOfExtensibleNom():New()
		For nY := 1 to Len(aCamposExt)
			oWSCamposExt := Service_ExtensibleNom():New()
			oWSCamposExt:ccontrolInterno1 := aCamposExt[nY,1]
			oWSCamposExt:ccontrolInterno2 := aCamposExt[nY,2]
			oWSCamposExt:cnombre := aCamposExt[nY,3]
			oWSCamposExt:cvalor := aCamposExt[nY,5]
			oWSCamposExt:cpdf := aCamposExt[nY,4]
			oWSCamposExt:cxml := aCamposExt[nY,6]
			aAdd(oWSExtensibles:oWSExtensibleNom , oWSCamposExt)
		Next nY
	EndIf

Return oWSExtensibles

/*/{Protheus.doc} M884GENLOG
Genera Log de ocurrencias
@author Alfredo Medrano
@since 05/07/2021
@version 1.0
@return Nil
@param aOcurrenci - Array del log
@param nSDocsProc - Documentos Procesados /Enviados
@param nSDcsTrans - Documentos transmitidos/enviados
@param nSDcsTrans - Documentos transmitidos/Enviados
@param TpLog 	  - 1 = Transmision 2 = Envío de correo
/*/ 
function M884GENLOG(aOcurrenci,nSDocsProc,nSDcsTrans,TpLog)
	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
	Local cTamanho	:= "M"
	Local cTitulo	:= STR0026 //"Log de Volante Electrónico" 
	Local nX		:= 1
	Local aNewLog	:= {}
	Local nTamLog	:= 0
	Local aLogTitle	:= { STR0027 ,STR0028, STR0029, STR0030, STR0031 }//'Número','Matrícula','Nombre','Aceptado','Detalle'   
	Local aLogDs	:= {}
	Local aLogRes	:= {}
	Local cDetalle 	:= ""
	Local nPos 		:= 1
	Local nC		:= 0
	Local cDocto	:= ""
	Local cDocTmp	:= ""
	Local cInfoDoc	:= ""
	Local cNMDocPr	:= STR0033 // "Documentos procesados:   "
	Local cNMDocEr	:= STR0034 // "Documentos con error:    "
	Local cNMDocTr	:= STR0035 // "Documentos transmitidos: "
	Default TpLog	:= 1 //log para transmisión de Volante 

	If TpLog == 2 //log envio de correo
		cNMDocPr := STR0048 //"Correos procesados: "
		cNMDocEr := STR0049 //"Correos con error : " 
		cNMDocTr := STR0050 //"Correos Enviados  : " 
	ElseIf TpLog == 1 // log visualización de PDF
		cNMDocPr := STR0072//"Archivos procesados: "
		cNMDocEr := STR0073  //"Archivos con error : " 
		cNMDocTr := STR0074 //"Archivos Visualizados  : " 
	EndIf

	For nx:=1 to len(aOcurrenci)
        cDetalle := ""
      	nPos := 1
		cDocto	:=	aOcurrenci[nx,1] + space(12 - len(aOcurrenci[nx,2]))+ sPace(2) + ; // Documento
	    			aOcurrenci[nx,3] + Space(4) + ; // Matricula
	    			aOcurrenci[nx,4] + Space(4) + ;  // Nombre
	    			aOcurrenci[nx,7] + Space(4)   // Resultado

		cInfoDoc := IIf(cDocTmp == cDocto, Space(Len(cDocto)), cDocto)

		If len(aOcurrenci[nx,6]) > 58
			For nC:= 1 to (len(aOcurrenci[nx,6])/58) + 1
				cDetalle := SUBSTR(aOcurrenci[nx,6],nPos,58)
				nPos += 58
				aadd(aLogDs,IIf(nC == 1, cInfoDoc, Space(Len(cDocto))) + cDetalle ) // Detalle
			Next nC
		Else
			aadd(aLogDs,cInfoDoc + aOcurrenci[nx,6] ) // Detalle
		EndIF

		cDocTmp := cDocto
	next

	aAdd(aLogRes," ")
	aadd(aLogRes,cNMDocPr  + Transform(nSDocsProc,"9999"))				
	aadd(aLogRes,cNMDocEr  + Transform(nSDocsProc- nSDcsTrans,"9999"))
	aadd(aLogRes,cNMDocTr  + Transform(nSDcsTrans,"9999"))			

	aNewLog		:= aClone(aLogDs)
	nTamLog		:= Len( aLogDs)
	aLogDs := {}

	If !Empty( aNewLog )
		aAdd( aLogDs , aClone( aNewLog ) )
	Endif

	aAdd(aLogDs, aLogRes)
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
	MsAguarde( { ||fMakeLog( aLogDs ,aLogTitle , , .t. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},STR0038 ) // "Generando Log de ocurrencias..."
Return Nil
/*/{Protheus.doc} fEscribXml
Guarda el archivo XMl en la carpeta especificada.
@author Alfredo Medrano
@since 05/07/2021
@version 1.0
@return Nil
@param  cTexto - Strin con el XML
@param  cFile - Nombre del archivo 
@param  cFilePathP - Carpeta principal (Filial_Proceso_Periodo+Indicador)
@param  cFilePathH - Subcarpeta (Procedimiento_Periodo+Indicador)
/*/ 
Static Function fEscribXml(cTexto, cFile, cFilePathP, cFilePathH )
	Local cPathFile := ""
	Local nHdl 		:= 0
  	Local lRet 		:= .T.
	Default cTexto 	:= ""
	Default cFile 	:= "" 
	Default cFilePathP := "" 
	Default cFilePathH := ""
	
	If !Empty(cFilePathH) .and. !Empty(cFilePathP) .and. !Empty(cFile) .and. !Empty(cTexto)
		If !ExistDir(cFilePathP)
			If makeDir(cFilePathP)!=0
				Help(,,'GM884ERRORDIR',,STR0036 + cFilePathP + STR0037  + STR(FERROR()),1,0)//"El directorio "//" no pudo ser creado."
				lRet:=.F.
			Endif
		EndIf
		If lRet .and. !ExistDir(cFilePathH)
			If makeDir(cFilePathH)!=0
				Help(,,'GM884ERRORDIR',,STR0036 + cFilePathH + STR0037 + STR(FERROR()),1,0)//"El directorio "//" no pudo ser creado."
				lRet:=.F.
			Endif
		EndIf
		If lRet
			//Filial + Proceso + Procedimiento + Periodo + Empleado+TipoXML 
			cPathFile := cFilePathH + "\" + cFile
			nHdl	:=	fCreate(cPathFile)
			If nHdl <= 0
				aAdd(aLog , { cSPrefCons, (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F.,STR0051 ,STR0044,'','','' } )//"Ocurrió un error al crear el archivo",//'Error'
			Else
				fWrite(nHdl,cTexto)
				fClose(nHdl)
			Endif
			
		EndIf
	EndIf
Return


/*/{Protheus.doc} EnvRecMail
Envia correo electrónico al empleado con los archivos xml y pdf
@author Alfredo Medrano
@since 09/07/2021
@version 1.0
@return Nil
@param  aLogEnvE - Log de ocurrencias
/*/ 
Static Function EnvRecMail(aLogEnvE)
	Local oMailServer	:= Nil
	Local oMessage		:= Nil
	Local cEmailTo		:= ""
	Local cEmailBcc		:= ""
	Local cError		:= ""
	Local cEMailAst		:= STR0052 //"Volante de pago electrónico"
	Local cAttach		:= ""
	Local cFrom			:= cMailConta
	Local lResult		:= .F.
	Local nX			:= 0
	Local NI			:= 0
	Local nNum			:= 0
	Local lDtAd			:= .T.
	Local cPortParam 	:= ""
	Local cSubUrlSrv 	:= ""
	Local _aAnexo		:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia o e-mail para a lista selecionada. Envia como BCC para que a pessoa pense³
	//³que somente ela recebeu aquele email, tornando o email mais personalizado.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Empty(nMailPort)
		nMailPort := 25
	EndIf

	cPortParam	:= SubStr(cMailServer, At(":", cMailServer) + 1, Len(cMailServer)) //Substrae el puerto del parametro MV_RELSERV
	cSubUrlSrv	:= SubStr(cMailServer, 1, Len(cMailServer) - (Len(cPortParam) + 1)) //Substrae la URL del parametro MV_RELSERV
	
	If At(":", cMailServer) > 0 .And. !(Empty(cPortParam)) //Si hay puerto en el parametro MV_RELSERV
		nMailPort := Val(cPortParam)
		cMailServer := cSubUrlSrv
	EndIf

	//aLogEnvE
   //1= Prefijo+Consecutivo, 2= Filial, 3= Matricula, 4= Nombre, 5= Aceptado, 6= Detalle de transmisión,7= Resultado, 8= Email, 9= Nombre Archivo XML, 10= Ruta Archivos XML/PDF
	ASORT(aLogEnvE, , , { | x,y | x[5] > y[5] } ) 
	For nNum:= 1 to Len(aLogEnvE) 
		
		If aLogEnvE[nNum][5] // Si .T. el volante fue transmitido correctamente
		
			If !Empty(aLogEnvE[nNum][8]) // Email esta vacío
				
				_aAnexo := {}
				cEmailTo := Alltrim(aLogEnvE[nNum][8])
				aadd(_aAnexo, {aLogEnvE[nNum][10] + "\" + aLogEnvE[nNum][9] +  ".xml"})
				aadd(_aAnexo, {aLogEnvE[nNum][10] + "\" + aLogEnvE[nNum][9] + ".Pdf"})
				If Len(aLogEnvE[nNum][11]) > 0
					For nX := 1 To Len(aLogEnvE[nNum][11])
						aadd(_aAnexo, {aLogEnvE[nNum][10] + "\" + aLogEnvE[nNum][11][nX][2]})
					Next nX
				EndIf

				If !lAuth

					For nI:= 1 to Len(_aAnexo)
						cAttach += _aAnexo[nI][1] + "; "
					Next nI
					
					CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult

					If lResult
						SEND MAIL FROM cFrom ;
						TO      	cEmailTo;
						BCC     	cEmailBcc;
						SUBJECT 	cEMailAst;
						BODY    	cEMailAst;
						ATTACHMENT  cAttach  ;
						RESULT lResult

						If !lResult
							//Erro no envio do email
							GET MAIL ERROR cError
							//1= Prefijo+Consecutivo, 2= Filial, 3= Matricula, 4= Nombre, 5= Aceptado, 6= Detalle de transmisión,7= Resultado, 8= Email
							AADD(aLog, {aLogEnvE[nNum][1],aLogEnvE[nNum][2],aLogEnvE[nNum][3],aLogEnvE[nNum][4],.F.,cError,STR0053 ,aLogEnvE[nNum][8] })
						EndIf

						DISCONNECT SMTP SERVER

					Else
						//Erro na conexao com o SMTP Server
						GET MAIL ERROR cError
						AADD(aLog, {aLogEnvE[nNum][1],aLogEnvE[nNum][2],aLogEnvE[nNum][3],aLogEnvE[nNum][4],.F.,cError,STR0053 ,aLogEnvE[nNum][8] })

					EndIf

					DISCONNECT SMTP SERVER

				Else
					//Instancia o objeto do MailServer
					oMailServer:= TMailManager():New()
					oMailServer:SetUseSSL(lUseSSL)				//Obs: Apenas se servidor de e-mail utiliza autenticacao SSL para envio
					oMailServer:SetUseTLS(lUseTLS) 				//Obs: Apenas se servidor de e-mail utiliza autenticacao TLS para recebimento
					oMailServer:Init("",cMailServer,cMailConta,cMailSenha,0,nMailPort)

					//Definição do timeout do servidor
					If oMailServer:SetSmtpTimeOut(120) != 0
						//1= Prefijo+Consecutivo, 2= Filial, 3= Matricula, 4= Nombre, 5= Aceptado, 6= Detalle de transmisión,7= Resultado, 8= Email
						AADD(aLog, {aLogEnvE[nNum][1],aLogEnvE[nNum][2],aLogEnvE[nNum][3],aLogEnvE[nNum][4],.F.,STR0054,STR0053 ,aLogEnvE[nNum][8] }) // "No se pudo establecer el tiempo de espera del servidor de envio"//'No Enviado'
						Loop
					EndIf

					//Conexão com servidor
					nErr := oMailServer:smtpConnect()

					If nErr <> 0
						AADD(aLog, {aLogEnvE[nNum][1],aLogEnvE[nNum][2],aLogEnvE[nNum][3],aLogEnvE[nNum][4],.F.,"[Error] " + oMailServer:getErrorString(nErr),STR0053,aLogEnvE[nNum][8] })//No Enviado'
						oMailServer:smtpDisconnect()
						Loop
					EndIf

					//Autenticação com servidor smtp
					nErr := oMailServer:smtpAuth(cMailConta, cMailSenha)

					If nErr <> 0
						AADD(aLog, {aLogEnvE[nNum][1],aLogEnvE[nNum][2],aLogEnvE[nNum][3],aLogEnvE[nNum][4],.F.,"[Error] " + STR0055 + oMailServer:getErrorString(nErr),STR0053,aLogEnvE[nNum][8] }) //"Falla al autenticar: "//'No Enviado'
						oMailServer:smtpDisconnect()
						Loop
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
						oMessage:AddAttHTag("Content-ID: <" + _aAnexo[nX][1] + ">")	//Essa tag, ?a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
						xRet := oMessage:AttachFile( _aAnexo[nX][1] )

						If xRet < 0
							AADD(aLog, {aLogEnvE[nNum][1],aLogEnvE[nNum][2],aLogEnvE[nNum][3],aLogEnvE[nNum][4],.F.,STR0056	 + _aAnexo[nX][1],STR0053,aLogEnvE[nNum][8] }) //"No se pudo adjuntar el archivo " // 'No Enviado'
							lDtAd := .F.
						EndIf
					Next nX
					
					If !lDtAd
						Loop
					EndIf
					
					//Dispara o email
					nErr := oMessage:send(oMailServer)
					If nErr <> 0
						AADD(aLog, {aLogEnvE[nNum][1],aLogEnvE[nNum][2],aLogEnvE[nNum][3],aLogEnvE[nNum][4],.F.,"[Error]" + STR0057 + oMailServer:getErrorString(nErr),STR0053,aLogEnvE[nNum][8] }) //" Falla al enviar: "// 'No Enviado'
						oMailServer:smtpDisconnect()
						Loop
					Else
						lResult := .T.
						nSDcsTrans++
						AADD(aLog, {aLogEnvE[nNum][1],aLogEnvE[nNum][2],aLogEnvE[nNum][3],aLogEnvE[nNum][4],.T.,STR0059 + aLogEnvE[nNum][8],STR0058 ,aLogEnvE[nNum][8] }) //"Correo enviado correctamente a "//'Enviado'
					EndIf

					//Desconecta do servidor
					oMailServer:smtpDisconnect()
					FreeObj(oMailServer)
					FreeObj(oMessage)
				EndIf
			EndIf
		EndIf

	Next nNum

Return(lResult)

/*/{Protheus.doc} FKDias360
Devuelve la cantidad de días entre dos fechas basándose en un año de 360 días (12 meses de 30 días)
@author Alfredo Medrano
@since 06/08/2021
@version 1.0
@return Nil
@param 		dFchIni		Date		Fecha de admision (inicial).
@param 		dFchFin		Date		Fecha Fin periodo / baja (final).
/*/ 
Static Function FKDias360(dFchIni, dFchFin)
	Local nDias360  := 0
	Local nAnoFcIni := 0
	Local nAnoFcFin := 0 
	Local nAnoTotal := 0
	Local nMesFcIni := 0
	Local nMesFcFin := 0
	Local nMesTotal := 0
	Local nDayFcIni := 0 
	Local nDayFcFin := 0 
	Local nDayTotal := 0

	Default dFchIni := CTOD("//")  
	Default dFchFin := CTOD("//")  

	//Año 
	nAnoFcIni := YEAR(dFchIni)
	nAnoFcFin := YEAR(dFchFin)

	//Mes
	nMesFcIni := MONTH(dFchIni)
	nMesFcFin := MONTH(dFchFin)

	//Día 
	nDayFcIni := DAY(dFchIni)
	nDayFcFin := DAY(dFchFin)


	If dFchFin >= dFchIni
		nAnoTotal =  (nAnoFcFin - nAnoFcIni)*360
		nMesTotal = (nMesFcFin- nMesFcIni)*30
		nDayTotal =  (nDayFcFin - nDayFcIni) + 1   

		If nDayTotal > 30
			nDayTotal := 30
		Endif

		nDias360 =  nAnoTotal +  nMesTotal +  nDayTotal 

	Endif

Return nDias360

/*/{Protheus.doc} ObtUidXML
Busca nodo o elemento en el XML  
@author alfredo medrano
@since 28/07/2021
@version 1.0
@return Nil
@param oXml.- Estructura xml
	   cNodo.- Valor del nodo a buscar 
/*/
Static Function ObtUidXML(oXML,cNodo)
	Local cXML     := ""
	Local cError   := ""
	Local cDetalle := ""
	Local lRet     := .F.

	If valType(oXml) == "O"				//Es un objeto
		SAVE oXML XMLSTRING cXML

		If AT( "ERROR" , Upper(cXML) ) > 0	// El archivo tiene errores
			If 	ValType(oXml:_ERROR) == "O"
				cError   := oXml:_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_ERROR:_DESCRIPCIONERROR:TEXT
			EndIf
		Else		//Obtener identificador del certificado
			If At( UPPER(cNodo) , Upper(cXML) ) > 0
				lRet := .T.
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} fDescargaPDF
Descarga el archivo PDF del volante electrónico 
@author alfredo medrano
@since 04/10/2021
@version 1.0
@return Nil
@param cArchivoXML.- Nommbre del Archivo
	   cFilePathH.-  Ruta absoluta 
/*/
Static function fDescargaPDF(cArchivoXML, cFilePathH)
Local cRespPDF 	:= ""
Local cPathFile := ""
Local nHdl 		:= 0
Local lRet		:= .T.

cPathFile := cFilePathH + "\" + cArchivoXML + ".pdf"

oWS:oWSrequestConsultarDocumento:cconsecutivoDocumentoNom = cSPrefCons
oWS:oWSrequestConsultarDocumento:ctokenEnterprise := cTokenEmp
oWS:oWSrequestConsultarDocumento:ctokenPassword   := cTokenPwd

If oWS:DescargaPDF()
	If !Empty(oWS:oWSDescargaPDFResult:cdocumento)
	
		cRespPDF := Decode64(oWS:oWSDescargaPDFResult:cdocumento)
		If !Empty(cRespPDF)
			If File(cPathFile )
				FErase (cPathFile)
			Endif
			nHdl := fCreate(cPathFile)
			If nHdl <= 0
				aAdd(aLog , { cSPrefCons, (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F.,STR0051 + " .pdf" ,STR0044,'','','' } )//"Ocurrió un error al crear el archivo",//'Error'
				lRet := .F.
			Else
				fWrite(nHdl, cRespPDF)
				fClose(nHdl)
			Endif

		EndIF
	Else
		aAdd(aLog , { Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F., STR0075 + cArchivoXML + ".pdf", STR0044 ,'','','' } ) //""Ocurrieron inconveneintes para generar el archivo." // Error
	    lRet := .F.
	EndIf
Else
	aAdd(aLog , { Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F.,STR0076, STR0044 ,'','','' } ) //"Sin respuesta del servicio web de descarga." // Error
	lRet := .F.
EndIf

Return lRet


/*/{Protheus.doc} GM884FnPDF
Verifica si existen Archivos PDF (Ordinario, Ajuste o Cancelación )
@author Alfredo Medrano
@since 13/10/2021
@version 1.0
@return Nil
/*/
Static Function GM884FnPDF()
	Local lRet	    := .T. 
	Local lAjusArc	:= .F.
	Local lArcNov  	:= .F.
	Local cIdent 	:= ""
	Local cNomArch	:= ""
	Local cDirLocal	:= GetTempPath()
	Local aArchNov  := {}
	Local nX 		:= 0

	
     // M884BusArc(" XML / PDF", si es XML ¿llenar objeto oXml? .T./.F., Nombre de Archivo sin extención, identificador (O=Ordinario A=Ajuste C=Cancelación))
	If M884BusArc("PDF", .F., @cNomArch) // existe PDF
		lAjusArc := .T.
	ElseIf M884BusArc("XML", .T., @cNomArch,@cIdent,@cPrefNum) // Existe XML llena objeto oXML y obtiene el consecutivo 
		If !Empty(cPrefNum)
			cSPrefCons := cPrefNum
			If fDescargaPDF(cNomArch, cFilePathH)
				lAjusArc := .T.
			Endif
		Endif
	Else
		aAdd(aLog , { Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F., STR0077 + cArchivoSmp, STR0044 ,'','','' } ) //"No existen documentos previamente generados para realizar la impresión. ""Error."
	Endif

	If lAjusArc 
		// Copia arquivos do servidor para o remote local, compactando antes de transmitir
		If CpyS2T( cFilePathH+ "\" + cNomArch + ".pdf", cDirLocal)
			ShellExecute("Open",cNomArch + ".pdf","",cDirLocal ,1)
			aAdd(aLog , { Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .T., STR0078  + cNomArch + ".pdf " + STR0079, Space(6) ,'','','' } ) //"Documento "//" visualizado."   
			nSDcsTrans++
		Endif

		//tratamiento para Novedades 
		//Obtiene  los Xml y busca que tengan pdf
		ObtArchNov(@aArchNov, .T.)
		If Len(aArchNov) > 0
			For nX := 1 To Len(aArchNov) 
				lArcNov := .F.
				If !Empty(aArchNov[nX][3]) //consecutivo
					cSPrefCons := aArchNov[nX][3]
					If fDescargaPDF(aArchNov[nX][5], cFilePathH)
						lArcNov := .T.
					Endif
				Else
					lArcNov := .T.
				EndIf
				If lArcNov
					If CpyS2T( cFilePathH+ "\" +aArchNov[nx][5] + ".pdf", cDirLocal)
						ShellExecute("Open",aArchNov[nx][5] + ".pdf","",cDirLocal ,1)
						aAdd(aLog , { Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .T., STR0078  + aArchNov[nx][5] + ".pdf " + STR0079, Space(6) ,'','','' } ) //"Documento "//" visualizado."   
						nSDcsTrans++
						nSDocsProc++
					Endif
				EndIf
			Next nX
		EndIf
	Endif

	lRet := lAjusArc

Return lRet 


/*/{Protheus.doc} M884BusArc
Verifica si existen Archivos PDF o XML (Ordinario, Ajuste o Cancelación )
@author Alfredo Medrano
@since 14/10/2021
@version 1.0
@return Nil
@param cTipoDoc .- XML / PDF
	   lLlenaObj.- .T./.F. --> si es XML, ¿llenar objeto oXml?
	   cNomArch (Val Referencia) .- Nombre de Archivo sin extención
	   cIdent  (Val Referencia) .- identificador (O=Ordinario, A=Ajuste, C=Cancelación)
	   cPrefNum  (Val Referencia) .- Consecutivo del documento 
	   cCUNENov (Val Referencia) .- CUNE de docto ordinario para NOVEDAD	
/*/
Static function M884BusArc(cTipoDoc, lLlenaObj, cNomArch,cIdent,cPrefNum, cCUNENvd)
	Local lRet 		:= .T.
	Local cRutAbs 	:= ""
	Local cFileOrd	:= ""
	Local cFileAju	:= ""
	Local cFileCan	:= ""
	Local cAviso    := ""
	Local cErro		:= ""


	Default cTipoDoc := ""
	Default cCUNENvd := ""

	cFileCan := cFilePathH+ "\" + cArchivoSmp + "_C" + cIndicador 
	cFileAju := cFilePathH+ "\" + cArchivoSmp + "_A" + cIndicador 
	cFileOrd := cFilePathH+ "\" + cArchivoSmp + "_O" + cIndicador

	If cTipoDoc == 'PDF' 
		//busca PDF
		If  File(cFileCan + ".pdf") // busca archivo cancelacion 
			cNomArch := cArchivoSmp + "_C" + cIndicador 
		ElseIf File(cFileAju + ".pdf") // busca si existe archivo de ajuste 
			cNomArch := cArchivoSmp + "_A" + cIndicador 
		ElseIf  File(cFileOrd + ".pdf") // busca archivo Ordinario 
			cNomArch := cArchivoSmp + "_O" + cIndicador 
		Else
			lRet := .F.
		EndIf
	ElseIf cTipoDoc == 'XML' 

		If File(cFileCan + ".xml") .and. !lNovedadOK // busca archivo cancelacion 
			cRutAbs := cFileCan
			cIdent := "C"
			cNomArch := cArchivoSmp + "_" + cIdent + cIndicador 
		ElseIf File(cFileAju + ".xml") .and. !lNovedadOK// busca si existe archivo de ajuste
			cRutAbs := cFileAju
			cIdent := "A"
			cNomArch := cArchivoSmp + "_" + cIdent + cIndicador 
		ElseIf  File(cFileOrd + ".xml") // busca archivo Ordinario 
			cRutAbs := cFileOrd
			cIdent := "O"
			cNomArch := cArchivoSmp + "_" + cIdent + cIndicador 
		Else
			lRet := .F.
		EndIf

		If lRet .and. lLlenaObj
			oXML := XmlParserFile(cRutAbs + ".xml", "_", @cAviso,@cErro ) 
			If oXML != Nil
				If cIdent == "O"// Archivo ordinario.
					If ObtUidXML(OXml:_NOMINAINDIVIDUAL:_NUMEROSECUENCIAXML, "NUMERO")
						cPrefNum:= OXml:_NOMINAINDIVIDUAL:_NUMEROSECUENCIAXML:_NUMERO:TEXT
					Endif
					If ObtUidXML(OXml:_NOMINAINDIVIDUAL:_INFORMACIONGENERAL, "CUNE")
						cCUNENvd:= OXml:_NOMINAINDIVIDUAL:_INFORMACIONGENERAL:_CUNE:TEXT
					Endif
				ElseIf cIdent == "A" // Archivo de Ajuste.
					If ObtUidXML(OXml:_NOMINAINDIVIDUALDEAJUSTE:_REEMPLAZAR:_NUMEROSECUENCIAXML, "NUMERO")
						cPrefNum:= OXml:_NOMINAINDIVIDUALDEAJUSTE:_REEMPLAZAR:_NUMEROSECUENCIAXML:_NUMERO:TEXT
					Endif
				ElseIf cIdent == "C" // Archivo de cancelación.
					If ObtUidXML(OXml:_NOMINAINDIVIDUALDEAJUSTE:_ELIMINAR:_NUMEROSECUENCIAXML, "NUMERO")
						cPrefNum:= OXml:_NOMINAINDIVIDUALDEAJUSTE:_ELIMINAR:_NUMEROSECUENCIAXML:_NUMERO:TEXT
					Endif
				EndIf
			Else
				aAdd(aLog , { Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F., STR0080 + cNomArch + ".xml", STR0044 ,'','','' } ) //"No se pudo leer el archivo " // Error
				lRet := .F.
			Endif

		Endif
	Endif

Return lRet


/*/{Protheus.doc} M884Email
Verifica si existen Archivos PDF o XML y realiza el envío de correo.
@author Alfredo Medrano
@since 14/10/2021
@version 1.0
@return Nil
/*/
Static Function M884Email()
	Local cNomArch	:= ""
	Local cIdent	:= ""
	Local lRet 		:= .T.
	Local cMsg		:= ""
	Local aLogEnvE	:= {}
	Local aArchNov	:= {}
 	
	If !M884BusArc("XML", .T., @cNomArch,@cIdent,@cPrefNum) 
		cMsg += STR0081 + " XML " + STR0082 //"No existen documentos "// " previamente generados para el empleado. "
		lRet := .F.
	EndIf 
	If !M884BusArc("PDF", .F., @cNomArch) // existe PDF
		cMsg += STR0081 + " PDF " + STR0082 //"No existen documentos "// " previamente generados para el empleado. "
		lRet := .F.
	Endif
	ObtArchNov(@aArchNov) //obtiene novedades
	
	If lRet
		If !Empty(cPrefNum)
			cSPrefCons := cPrefNum
			aAdd(aLogEnvE , { cSPrefCons,(cAliasSRA)->RA_FILIAL ,(cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .T., "","",(cAliasSRA)->RA_EMAIL,cArchivoXML,cFilePathH,aArchNov } )
			If !EnvRecMail(aLogEnvE)
				AADD(aLog, {Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME,.F., STR0083 ,STR0053 ,(cAliasSRA)->RA_EMAIL }) // "Ocurrieron inconvenientes con el envio de correo. "   //'No Enviado'
			EndIf
		Endif
	Else
		//1= Prefijo+Consecutivo, 2= Filial, 3= Matricula, 4= Nombre, 5= Aceptado, 6= Detalle de transmisión,7= Resultado, 8= Email
		AADD(aLog, {Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME,.F.,cMsg,STR0053 ,(cAliasSRA)->RA_EMAIL }) // "No se pudo establecer el tiempo de espera del servidor de envio"//'No Enviado'
	EndIf


Return


/*/{Protheus.doc} ExsNovedad
Verifica si existe novedad para el empleado
@author Alfredo Medrano
@since 09/11/2021
@version 1.0
@return lRet
@param 
	   aNovPeriP (Val Referencia) .- array  - Contiene las novedades del periodo  
/*/
static Function ExsNovedad(aNovPeriP)
Local aArea		:= GetArea()
Local cAliasRet := GetNextAlias()
Local cAliasSR9 := GetNextAlias()
Local cAliasSR3 := GetNextAlias()
Local cSR9Tab	:= '%'+RetSqlName('SR9')+'%'  
Local cSR3Tab	:= '%'+RetSqlName('SR3')+'%' 
Local nX 		:= 0
Local lRet 		:= .F. 
Local cFchNvS 	:= ""
Local cCmpoNvS 	:=""

Default aNovPeriP  := {}

// Obtiene los las novedades, tomando siempre el último movimiento del empleado de la SR9
	BeginSql alias cAliasSR9
			SELECT R9_FILIAL, R9_MAT, R9_DATA, R9_CAMPO, R9_DESC
				FROM %exp:cSR9Tab% SR9
				WHERE R_E_C_N_O_ IN 
					(SELECT MAX(R_E_C_N_O_)  FROM %exp:cSR9Tab% SR9 WHERE 
					R9_FILIAL = %exp:(cAliasSRA)->RA_FILIAL%  
					AND R9_MAT = %exp:(cAliasSRA)->RA_MAT% 
					AND R9_CAMPO IN ('RA_TIPOSAL','RA_TIPCOT','RA_SUBCOT','RA_PORAFP')
					AND SR9.%NotDel%   AND R9_DATA >=  %exp:cFchPerIni% AND R9_DATA <=  %exp:cFchPerFin%
				GROUP BY R9_FILIAL, R9_MAT, R9_CAMPO, R9_DATA ) AND SR9.%NotDel%
				ORDER BY R9_FILIAL, R9_MAT, R9_DATA, R9_CAMPO 
	EndSql

	Do While (cAliasSR9)->(!Eof()) 
		AADD(aNovPeriP, { (cAliasSR9)->R9_MAT, Alltrim((cAliasSR9)->R9_CAMPO), (cAliasSR9)->R9_DATA,"","",.T.,0 })
		(cAliasSR9)->(dbSkip())
	Enddo

// Por cada registro contenido en aNovPeriP obtiene el valor anterior a la novedad (el que se informará en la nómina)
// y lo asigna a la posicion 5 del array aNovPeriP
	If Len(aNovPeriP) > 0
		aSort( aNovPeriP,,,{ |x,y| x[3] < y[3] } )
		For nX := 1 to Len(aNovPeriP)
			cFchNvS := aNovPeriP[nX][3]
			cCmpoNvS := aNovPeriP[nX][2]
			BeginSql alias cAliasRet
				SELECT R9_FILIAL, R9_MAT, R9_DATA, R9_CAMPO, R9_DESC
					FROM %exp:cSR9Tab% SR9 
						WHERE R_E_C_N_O_ IN 
							(SELECT MAX(R_E_C_N_O_)  FROM %exp:cSR9Tab% SR9 WHERE R9_FILIAL = %exp:(cAliasSRA)->RA_FILIAL%  
							AND R9_MAT = %exp:(cAliasSRA)->RA_MAT% 
							AND R9_DATA < %exp:cFchNvS% AND R9_CAMPO = %exp:cCmpoNvS%
							AND SR9.%NotDel% 
					GROUP BY R9_FILIAL, R9_MAT, R9_CAMPO, R9_DATA ) AND SR9.%NotDel% 
					ORDER BY R9_FILIAL, R9_MAT, R9_CAMPO,R9_DATA DESC
			EndSql

			Do While (cAliasRet)->(!Eof()) 
				aNovPeriP[nX][5] := AllTrim((cAliasRet)->R9_DESC)
				(cAliasRet)->(dbSkip())
			Enddo
			(cAliasRet)->(dbCloseArea())
		Next nX

	Endif

	// Obtiene los las novedades de salario, tomando siempre el último movimiento del empleado de la SR3 y su valor anterior.
	BeginSql alias cAliasSR3
		SELECT  R3_FILIAL, R3_MAT, R3_DATA, R3_SEQ, R3_TIPO, R3_PD, R3_DESCPD, R3_VALOR, R3_ANTEAUM
			FROM %exp:cSR3Tab% SR3
			WHERE R_E_C_N_O_ IN 
			(SELECT MAX(R_E_C_N_O_)  FROM %exp:cSR3Tab% SR3 WHERE R3_FILIAL = %exp:(cAliasSRA)->RA_FILIAL%  
			AND R3_MAT = %exp:(cAliasSRA)->RA_MAT% 
			AND SR3.%NotDel%  AND R3_DATA >=  %exp:cFchPerIni% AND R3_DATA <=  %exp:cFchPerFin% AND R3_PD ='000'
				GROUP BY R3_FILIAL, R3_MAT, R3_DATA, R3_SEQ ) AND SR3.%NotDel%
				ORDER BY R3_FILIAL, R3_MAT, R3_DATA 
	EndSql

	Do While (cAliasSR3)->(!Eof()) 
		If (cAliasSR3)->R3_ANTEAUM > 0
			AADD(aNovPeriP, { (cAliasSR3)->R3_MAT, "SALARIO", (cAliasSR3)->R3_DATA,"",(cAliasSR3)->R3_ANTEAUM,.T.,0 })
		EndIF
		(cAliasSR3)->(dbSkip())
	Enddo

(cAliasSR9)->(dbCloseArea())
(cAliasSR3)->(dbCloseArea())

If Len(aNovPeriP) > 0
	//Toma la novedad que contiene la fecha Mayor, las novedades con fechas anteriores las marca para no ser procesadas
	aSort( aNovPeriP,,,{ |x,y| x[3] > y[3] } ) // Mayor a Menor
	aEval(aNovPeriP,{|x| If( x[3] != aNovPeriP[1][3] ,x[6]:=.F.,.F.)}) // marca las posiciones con fechas anteriores 
	
	If aScan(aNovPeriP,{|x|x[3] == cFchPerIni .and. x[6] == .T.}) > 0 // si la novedad pertenece al primer día del mes solo se envia un XML
		lRet := .F. 
	Else
		lRet := .T.
	EndIf

EndIf

RestArea( aArea )
Return lRet


/*/{Protheus.doc} BuscaMovEmp
Verifica si existe movimientos para el empleado en SRC y SRD
antes de realizar él envió de nómina ordinaria de novedades.
@author Alfredo Medrano
@since 09/11/2021
@version 1.0
@return Nil
/*/
Static function BuscaMovEmp()

Local aArea		:= GetArea()
Local cAliasMvE := GetNextAlias()
Local lRet 		:= .F.
  

BeginSql alias cAliasMvE
		SELECT RD_MAT
		FROM %exp:cSRDTab% SRD 
		WHERE RD_FILIAL = %exp:(cAliasSRA)->RA_FILIAL% AND RD_MAT =  %exp:(cAliasSRA)->RA_MAT% AND
			  SRD.%NotDel%  %exp:cQuerySRD%
		UNION

		SELECT RC_MAT
		FROM %exp:cSRCTab% SRC 
		WHERE RC_FILIAL = %exp:(cAliasSRA)->RA_FILIAL% AND RC_MAT =  %exp:(cAliasSRA)->RA_MAT% AND
			  SRC.%NotDel%  %exp:cQuerySRC%
	EndSql

	If (cAliasMvE)->(!EOF())
		lRet := .T.
	Else
		aAdd(aLog , { Space(6), (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_NOME, .F., STR0089 ,STR0005,'','','' } ) //"Documento" // "Empleado sin movimientos en el mes."//"Atención"
	EndIf
(cAliasMvE)->(dbCloseArea())
RestArea( aArea )
return lRet


/*/{Protheus.doc} AsigValNov
Obtiene los valores anteriores (por periodo) de la novedad y 
los asigna a las variables correspondientes, tambien obtiene el 
Salario diario, los días trabajados, el salario trabajado y la fechas de inicio y fin de
perodo a calcular.
@author Alfredo Medrano
@since 09/11/2021
@version 1.0
@return LBan
@param 
	   cFechaNovS (Val Referencia) .- Char  - informa la fecha de la novedad
/*/
Static function AsigValNov(lSal, cFechaNovS, aSalDiaQ)

Local nNumRw 	:= 0
Local nJ 		:= 0
Local nSalario 	:= 0
Local nSaldia 	:= 0
Local nSalHrs 	:= 0
Local nSalMes 	:= 0
Local nSalCal 	:= 0
Local nX 		:= 0
Local aSueldos 	:= {}
Local nAux 		:= 0
Local nSalMin 	:= 0
Local nDias 	:= 0
Local nDiasNo 	:= 0
Local dFechaNov := stoD( "  /  /  " )

nNumRw := Len(aNovedades)
aSort( aNovedades,,,{ |x,y| x[3] < y[3] } )

	For nJ := 1 to nNumRw
		If aNovedades[nJ][6]
			If aNovedades[nJ][2] == 'RA_TIPOSAL' 
				cSalinteg := aNovedades[nJ][5]
			ElseIf aNovedades[nJ][2] == 'RA_TIPCOT' 
				cSTipoTrab := aNovedades[nJ][5]
			ElseIf aNovedades[nJ][2]== 'RA_SUBCOT' 
				cSubTpTrab := aNovedades[nJ][5] 
			ElseIf aNovedades[nJ][2]== 'RA_PORAFP' 
				cAltoRsgPn:= aNovedades[nJ][5]
			ElseIf aNovedades[nJ][2]== 'SALARIO'
				nSueldoEm:= aNovedades[nJ][5]
				lSal := .T.
			EndIf
		EndIf
	Next nJ

	cFechaNovS := aNovedades[nNumRw][3]


	If lSal // Cambio en Sueldo/Salario
		//1 Sueldo // 2 Fecha Inicio 
		AADD(aSueldos,{nSueldoEm, cFechaNovS }) 
		AADD(aSueldos, {(cAliasSRA)->RA_SALARIO,cFechaNovS })
	Else
		AADD(aSueldos,{(cAliasSRA)->RA_SALARIO, cFechaNovS }) 
		AADD(aSueldos, {(cAliasSRA)->RA_SALARIO,cFechaNovS })
	EndIf
	If len(aSueldos) > 0 	
		For nX:= 1 to len(aSueldos) 
			nSalario := aSueldos[nX][1]
			If (cAliasSRA)->RA_TIPOSAL == '2' .OR.  (cAliasSRA)->RA_TIPOSAL == '4'// Salario integral 
				nSalMes := nSalario
				nSaldia := nSalMes / 30
				nAux := fPosTab("S007",0,"<",4)
				nSalMin := IIf(nAux>0, fTabela("S007",nAux,6),0)
				If nSalMes < (nSalMin * 13)
					nSalMes := (nSalMin * 13)
					nSaldia := nSalMes / 30
				Endif
			Else
				If (cAliasSRA)->RA_CATFUNC == 'D' //Sal Diario
					nSaldia := nSalario
				ElseIf (cAliasSRA)->RA_CATFUNC == 'H' //Salario Horas
					nSalHrs := nSalario
					nSalMes := nSalHrs * (cAliasSRA)->RA_HRSMES
					nSaldia := nSalMes / 30
				ElseIf !((cAliasSRA)->RA_CATFUNC $ 'H|D')
					nSalMes := nSalario
					nSaldia := nSalMes / 30
				EndIf
			EndIf
			dFechaNov :=  stoD(aSueldos[nX][2])
			dFechaFin :=  stoD(cFchPerFin)
			
			If nSaldia > 0
				If nX == 1 //Ordinario
					nDias := DAY(dFechaNov) - 1
				ElseIf nX == 2
					nDiasNo := DAY(dFechaNov) - 1
					nDias := 30 - nDiasNo //nDias := DAY(dFechaFin) - DAY(dFechaNov) 
				EndIf
				If nDias > 0
					nSalCal := nDias * nSaldia
				Endif
			Endif
			// 1 - posicion de array 2 - Salario diario 3 - días trabajados 4 - salario trabajado 5 - Fecha inicio Periodo 6 - Fecha fin Periodo
			If nX == 1
				AADD(aSalDiaQ, {nX, nSaldia,nDias,nSalCal,cFchPerIni,DTOS( stoD(cFechaNovS) - 1 )})
			Else
				AADD(aSalDiaQ, {nX, nSaldia,nDias,nSalCal,cFechaNovS,cFchPerFin})
			Endif

		Next nX

	EndIf
	
Return 

/*/{Protheus.doc} obtFchNov
obtiene las fechas inicio y fin de periodo para la novedad
Calcula y obtiene el porcentaje proporcional que será aplicado
a la nómina ordinaria y de novedad
@author Alfredo Medrano
@since 08/11/2021
@version 1.0
@return lRet
@param 
	   cFchPrNovI  (Val Referencia) .- Fecha Inicio Periodo
	   cFchPrNovF  (Val Referencia) .- Fecha Fin Periodo
	   nPorc       (Val Referencia) .- porcentaje proporcional
/*/
Static function obtFchNov(cFchPrNovI,cFchPrNovF,nPorc)

Local lRet 		:= .T.
Local nTotSal 	:= 0
Local nDiasNo 	:= 0
Local dFechaNov := stoD( "  /  /  " )

	If Len(aSalDiaQ) >= nContNov
		cFchPrNovI:= aSalDiaQ[nContNov][5] // Fecha Inicio
		cFchPrNovF := aSalDiaQ[nContNov][6] //Fecha Fin
	EndIf

	If lSal // obtiene Salario
		If Len(aSalDiaQ) >= nContNov
			aEval(aSalDiaQ,{|x| nTotSal += x[4] })
			If aSalDiaQ[nContNov][4] > 0
				nPorc := aSalDiaQ[nContNov][4] / nTotSal
				nPorc := Round(nPorc,4)
			Endif
		Endif
	Else
		dFechaNov :=  stoD(cFechaNovS)
		If nContNov == 1 //Ordinario
			nDias := DAY(dFechaNov) - 1 
		Else
			nDiasNo := DAY(dFechaNov) - 1
			nDias := 30 - nDiasNo
		EndIf
		If nDias > 0
			nPorc := nDias / 30
			nPorc := Round(nPorc,4)
		Endif
	EndIf

Return lRet


/*/{Protheus.doc} M884ArcNov
Verifica si existen Archivos PDF o XML de las novedades
@author Alfredo Medrano
@since 17/11/2021
@version 1.0
@return Nil
@param cTipoDoc .- XML / PDF
	   aArchNov (Val Referencia) .- Array - Array que almacena nombre y ruta de archivos Xml y Pdf de la novedad
	   lLlenaObj.- .T./.F. --> si es XML, ¿llenar objeto oXml?
	  
/*/
Static function ObtArchNov(aArchNov, lObtVal)

Local cFileNov	:= ""
Local cNomArch 	:= ""
Local cNomSinEx := ""
Local cFilePDF 	:= ""
Local cNoArcpdf := ""
Local cAviso 	:= ""
Local cErro 	:= ""
Local cPrefNum 	:= ""
Local cFlSinEx 	:= ""
Default aArchNov:= {}
Default lObtVal := .F.

	cFlSinEx := cFilePathH+ "\" + cArchivoSmp + "_N" 
	cFilePDF := cFlSinEx + cIndicador + ".pdf"
	cNoArcpdf := cArchivoSmp + "_N" + cIndicador + ".pdf"
	cFileNov := cFlSinEx + cIndicador + ".xml"
	cNomArch := cArchivoSmp + "_N" + cIndicador + ".xml"
	cNomSinEx := cArchivoSmp + "_N"+ cIndicador
	
	If !lObtVal
		If File(cFileNov)
			 AADD(aArchNov, {cFileNov, cNomArch,'','.xml',cNomSinEx,cFlSinEx })
			If File(cFilePDF)
				AADD(aArchNov, {cFilePDF, cNoArcpdf,'','.pdf',cNomSinEx,cFlSinEx })
			EndIf
		EndIf
	
	Else
		If File(cFileNov)
			If !File(cFilePDF)
				oXML := XmlParserFile(cFileNov, "_", @cAviso,@cErro ) 
				If oXML != Nil
					If ObtUidXML(OXml:_NOMINAINDIVIDUAL:_NUMEROSECUENCIAXML, "NUMERO")
						cPrefNum:= OXml:_NOMINAINDIVIDUAL:_NUMEROSECUENCIAXML:_NUMERO:TEXT
					Endif
				Endif
			Endif
			AADD(aArchNov, {cFileNov, cNomArch,cPrefNum,'.xml',cNomSinEx,'' })
		Endif
	EndIf
	
Return

/*/{Protheus.doc} M884ArcNov
Obtiene Salario pagado en vacaciones
@author Alfredo Medrano
@since 18/12/2021
@version 1.0
@return Nil
@param aSalDiaQ .- XML / PDF
	   nPorDias (Val Referencia) .- Número - Valor pagado por dias de vacaciones
	  
/*/
Static function ValTotVac(nPorDias) 

Local nSaldia  	:= 0
Local nX 		:= 0
Local nDiasHab 	:= 0

	For nX := 1 to Len(aSalDiaQ)
		nSaldia := aSalDiaQ[nX][2] //Salario diario

		If !((cAliasSR)->R8_DATAINI >=  aSalDiaQ[nX][5] .and. (cAliasSR)->R8_DATAFIM <=  aSalDiaQ[nX][6] ) 
			If  (cAliasSR)->R8_DATAINI >= aSalDiaQ[nX][5]  .and. (cAliasSR)->R8_DATAINI <= aSalDiaQ[nX][6] 
			//Obtiene los días proporcionales de vacaciones para informar en la nomina ordinal
				nDiasHab:= 0
				GpeCalend((cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_mat ,,,, STOD( (cAliasSR)->R8_DATAINI) , STOD(aSalDiaQ[nX][6] ) , @nDiasHab ,"D",,.F. )
				nPorDias += nDiasHab * nSaldia
			Endif
			If  (cAliasSR)->R8_DATAFIM >= aSalDiaQ[nX][5]  .and. (cAliasSR)->R8_DATAFIM <= aSalDiaQ[nX][6] 
			//Obtiene los dias de vacaciones que estan dentro del periodo de novedad
				nDiasHab:= 0
				GpeCalend((cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_mat ,,,, STOD(aSalDiaQ[nX][5]), STOD( (cAliasSR)->R8_DATAFIM) , @nDiasHab ,"D",,.F. )
				nPorDias += nDiasHab * nSaldia
			Endif
		Endif
	Next

Return
