#Include "PROTHEUS.ch"
#Include "RWMAKE.ch"
#Include "TOPCONN.ch"
#Include "XMLXFUN.ch"
#Include "TBICONN.CH"
#Include "FILEIO.ch"
#Include "GPER811ARG.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออหอออออออหออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบPrograma  บGPER811ARGบAutor  บLuis Samaniego      บFecha บ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออสออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     บImportacion de formulario F572 Web                          บฑฑl
ฑฑบ          บ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       บ SIGAGPE                                                    บฑฑ
ฑฑฬออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             บฑฑ
ฑฑฬออออออออออออหออออออออหอออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ Data   บLlamadoบ  Motivo da Alteracao                    บฑฑ
ฑฑฬออออออออออออลออออออออลอออออออลอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บ        บ       บ                                         บฑฑ
ฑฑศออออออออออออสออออออออสอออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPER811ARG()
Local cPerg       := "GPER811ARG"
Local nOpcA       := 0
Local aSays       := {}
Local aButtons    := {}

Private cRutaSrv  := Curdir()
Private cRutaLoc  := ""
Private cCvlTbls  := SuperGetMv("MV_GPEF572",,"")
Private cCvlTblF  := ""
Private nArchImp   := 0
Private nArchErr   := 0

	Pergunte( cPerg, .F. )
	aAdd(aSays,OemToAnsi( STR0001) ) //"Importaci๓n del archivo XML F572 Web"
	aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{ |o| IIf(VldParam(), (nOpcA := 1, o:oWnd:End()),)}} )
	aAdd(aButtons, { 2,.T.,{ |o| nOpca := 2, o:oWnd:End() }} )             
	FormBatch( oemtoansi(STR0002), aSays , aButtons ) //"Formulario 572 Web"
	
	If nOpcA == 1
		ObtClvTbl()
		cRutaLoc := Alltrim(MV_PAR01)
		Processa({ || ObtArchXML() })
		
		If nArchImp == 1 .And. nArchErr == 1
			Aviso( OemToAnsi(STR0002), OemToAnsi(Str(nArchImp) + " " + STR0014 + CRLF + Str(nArchErr) + " " + STR0015), {STR0004}) //"Formulario 572 Web" - "Archivo importado" - "Archivo con error" - "OK"
		ElseIf nArchImp == 1 .And. nArchErr > 1
			Aviso( OemToAnsi(STR0002), OemToAnsi(Str(nArchImp) + " " + STR0014 + CRLF + Str(nArchErr) + " " + STR0013), {STR0004}) //"Formulario 572 Web" - "Archivo importado" - "Arquivos con errores" - "OK"
		ElseIf nArchImp > 1 .And. nArchErr == 1
			Aviso( OemToAnsi(STR0002), OemToAnsi(Str(nArchImp) + " " + STR0012 + CRLF + Str(nArchErr) + " " + STR0015), {STR0004}) //"Formulario 572 Web" - "Archivos importados" - "Archivo con error" - "OK"
		Else
			Aviso( OemToAnsi(STR0002), OemToAnsi(Str(nArchImp) + " " + STR0012 + CRLF + Str(nArchErr) + " " + STR0013), {STR0004}) //"Formulario 572 Web" - "Archivos importados" - "Arquivos con errores" - "OK"
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtArchXML      บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Procesa los archivos XML F572 Web                                บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtArchXML()
Local nLoop        := 0

Private aArchXML   := {}
Private aErrLog    := {} /*Log*/

	aArchXML := Directory( cRutaLoc + "*.xml" )
	
	If Len(aArchXML) == 0
		Aviso( OemToAnsi(STR0002), OemToAnsi(STR0003), {STR0004})
	Else
		dbSelectArea("SRA")
		dbSelectArea("SRB")
		dbSelectArea("RG1")
		dbSelectArea("SX5")
		SRA->(DBSetOrder(RETORDEM("SRA","RA_FILIAL+RA_CIC")))
		SRB->(DBSetOrder(RETORDEM("SRB","RB_FILIAL+RB_MAT")))
		RG1->(DBSetOrder(RETORDEM("RG1","RG1_FILIAL+RG1_MAT+RG1_ORDEM+RG1_PD")))
		SX5->(DBSetOrder(RETORDEM("SX5","X5_FILIAL+X5_TABELA+X5_CHAVE")))
		
		ProcRegua(Len(aArchXML))
		For nLoop := 1 to Len(aArchXML)
			If !("PROCESADO" $ aArchXML[nLoop][1])
				IncProc(STR0005 + " " + aArchXML[nLoop][1])
				__CopyFile( cRutaLoc + aArchXML[nLoop][1], cRutaSrv + aArchXML[nLoop][1])
				LeerXML(aArchXML[nLoop][1])
				FErase(cRutaSrv + aArchXML[nLoop][1])
			EndIf
		Next
		
		If Len(aErrLog) != 0
			GrabaLog()
		EndIf
		
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLeerXML         บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Lee el archivo XML                                               บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LeerXML(cArchivo)
Local oXML     := Nil
Local cError   := ""
Local cDetalle := ""
Local cArchXML := cRutaSrv + cArchivo

	If Substr(cArchXML,1,1) == IIf( IsSrvUnix() , "/" , "\" )
		cArchXML := Substr(cArchXML,2)
	Endif
	
	If File(cArchXML)
		oXml := XmlParserFile( cArchXML , "", @cError, @cDetalle)
	EndIf
	
	If ValType(oXml) == "O"
		ObtInfXML(oXml, cArchivo)
	Else
		aAdd(aErrLog, {cArchivo, STR0008})
		nArchErr += 1
	EndIf
	
	oXML := Nil
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtInfXML       บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene informacion del archivo XML                              บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtInfXML(oXml, cArchivo)
Local nLoop			:= 0
/*Variables por empleado*/
Local aEmp			:= {}
Local cFchPres		:= ""
/*Variables por dependiente*/
Local aDepFam		:= {}
Local dFchNacF		:= ("//")
Local cFchNacF		:= ""
Local cNomFam		:= ""
Local cApeFam		:= ""
Local cTipFam		:= ""
Local cMesIniF		:= ""
Local cMesFinF		:= ""
Local cCUITFam		:= ""
/*Variables para Deducciones*/
Local aDed			:= {}
Local cTipDed		:= 0
Local nTotDed		:= 0
/*Variables para Retenciones*/
Local aRet			:= {}
Local cTipRet		:= "00"
Local nTotRet		:= 0
/*Variables para Ganancias Liquidadas por otros Empleadores o Entidades*/
Local aDetEmpEnt	:= {}
/*Variables por empleado*/
Private dFchPres	:= ("//")
Private cCuitEmp	:= ""
Private cMatEmp		:= ""
Private cRACC		:= ""
Private nAnio		:= 0
/*Variables por dependiente*/
Private cValGrp		:= ""
Private cValDep		:= ""
/*Variables para Deducciones*/
Private cConcDed	:= ""
/*Variables para Retenciones*/
Private cConcRet	:= ""

	/*Nodo Presentacion*/
	If ObtUidXML(oXml:_PRESENTACION, "PERIODO")
		nAnio := Val(oXml:_PRESENTACION:_PERIODO:TEXT)
	EndIf
	If ObtUidXML(oXml:_PRESENTACION, "FECHAPRESENTACION")
		cFchPres := oXml:_PRESENTACION:_FECHAPRESENTACION:TEXT
		dFchPres := STOD(Substr(cFchPres,1,4) + Substr(cFchPres,6,2) + Substr(cFchPres,9,2))
	EndIf
	
	/*Nodo Empleado*/
	If ObtUidXML(oXml:_PRESENTACION:_EMPLEADO, "CUIT")
		cCuitEmp := oXml:_PRESENTACION:_EMPLEADO:_CUIT:TEXT
		ObtInfEmp(cCuitEmp) //Obtener informacion del Empleado
		
		aAdd(aEmp, {{'PERIODO', nAnio}, {'FECHAPRESENTACION', dFchPres}, {'CUIT', cCuitEmp}, {'MATRICULA', cMatEmp}})
		
		If !VldAtrbXML(aEmp, cArchivo)
			Return
		EndIf
	EndIf
	
	/*Nodo CargasFamilia*/
	If XmlChildEx(oXml:_PRESENTACION, "_CARGASFAMILIA") <> Nil
		If ObtUidXML(oXml:_PRESENTACION:_CARGASFAMILIA, "CARGAFAMILIA")
			If ValType(oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA) <> "O"
				For nLoop := 1 To Len(oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA)
					cApeFam  := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA[nLoop]:_APELLIDO:TEXT
					cNomFam  := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA[nLoop]:_NOMBRE:TEXT
					cFchNacF := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA[nLoop]:_FECHANAC:TEXT
					cTipFam  := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA[nLoop]:_PARENTESCO:TEXT
					cMesIniF := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA[nLoop]:_MESDESDE:TEXT
					cMesFinF := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA[nLoop]:_MESHASTA:TEXT
					cCUITFam := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA[nLoop]:_NRODOC:TEXT
				
					dFchNacF := STOD(Substr(cFchNacF,1,4) + Substr(cFchNacF,6,2) + Substr(cFchNacF,9,2))
				
					ObtInfAdc(cTipFam) //Obtener valor grupo y tipo dependiente
				
					aAdd(aDepFam, {{'APELLIDO', cApeFam}, {'NOMBRE', cNomFam}, {'FECHANAC', dFchNacF}, {'VALGRUPO', cValGrp},;
									{'PARENTESCO', cValDep}, {'MESDESDE', cMesIniF}, {'MESHASTA', cMesFinF}, {'NRODOC', cCUITFam}})

				Next
			Else
				cApeFam  := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA:_APELLIDO:TEXT
				cNomFam  := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA:_NOMBRE:TEXT
				cFchNacF := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA:_FECHANAC:TEXT
				cTipFam  := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA:_PARENTESCO:TEXT
				cMesIniF := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA:_MESDESDE:TEXT
				cMesFinF := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA:_MESHASTA:TEXT
				cCUITFam := oXml:_PRESENTACION:_CARGASFAMILIA:_CARGAFAMILIA:_NRODOC:TEXT	
			
				dFchNacF := STOD(Substr(cFchNacF,1,4) + Substr(cFchNacF,6,2) + Substr(cFchNacF,9,2))
				
				ObtInfAdc(cTipFam) //Obtener valor grupo y tipo dependiente
				
				aAdd(aDepFam, {{'APELLIDO', cApeFam}, {'NOMBRE', cNomFam}, {'FECHANAC', dFchNacF}, {'VALGRUPO', cValGrp},;
								{'PARENTESCO', cValDep}, {'MESDESDE', cMesIniF}, {'MESHASTA', cMesFinF}, {'NRODOC', cCUITFam}})
							
			EndIf
			If !VldAtrbXML(aDepFam, cArchivo)
				Return
			EndIf
		EndIf
	EndIf
	/*Nodo Deducciones*/
	If XmlChildEx(oXml:_PRESENTACION, "_DEDUCCIONES") <> Nil
		If ObtUidXML(oXml:_PRESENTACION:_DEDUCCIONES, "DEDUCCION")
			If ValType(oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION) <> "O"
				For nLoop := 1 To Len(oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION)
					cTipDed := oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION[nLoop]:_TIPO:TEXT
					nTotDed := Val(oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION[nLoop]:_MONTOTOTAL:TEXT)
				
					cConcDed := ObtConSRV(cTipDed) //Obtener concepto de SRV
					If XmlChildEx(oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION[nLoop], "_PERIODOS") <> Nil
						gp811XMLPER(nTotDed,cConcDed,oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION[nLoop]:_PERIODOS,@aDed)
					Else
						If XmlChildEx(oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION[nLoop], "_DETALLES") <> Nil
							aAdd(aDed, {{'MONTOTOTAL', nTotDed},;
							 			{'CONCEPTO',cConcDed},;
							 			{"MESDESDE",oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION[nLoop]:_DETALLES:_DETALLE[2]:_VALOR:TEXT},;
							 			{"MESHASTA",oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION[nLoop]:_DETALLES:_DETALLE[2]:_VALOR:TEXT},;
							 			{"MONTOMENSUAL", nTotDed}})							
						Else
							aAdd(aDed, {{'MONTOTOTAL', nTotDed}, {'CONCEPTO',cConcDed},{"MESDESDE","1"},{"MESHASTA","12"},{"MONTOMENSUAL", nTotDed}})
						EndIf	
					EndIf	
				Next nLoop
			Else
				cTipDed := oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION:_TIPO:TEXT
				nTotDed := Val(oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION:_MONTOTOTAL:TEXT)
			
				cConcDed := ObtConSRV(cTipDed) //Obtener concepto de SRV
				If XmlChildEx(oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION, "_PERIODOS") <> Nil
					gp811XMLPER(nTotDed,cConcDed,oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION:_PERIODOS,@aDed)
				Else
					If XmlChildEx(oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION, "_DETALLES") <> Nil
						aAdd(aDed, {{'MONTOTOTAL', nTotDed},;
						 			{'CONCEPTO',cConcDed},;
						 			{"MESDESDE",oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION:_DETALLES:_DETALLE[2]:_VALOR:TEXT},;
						 			{"MESHASTA",oXml:_PRESENTACION:_DEDUCCIONES:_DEDUCCION:_DETALLES:_DETALLE[2]:_VALOR:TEXT},;
						 			{"MONTOMENSUAL", nTotDed}})							
					Else
						aAdd(aDed, {{'MONTOTOTAL', nTotDed}, {'CONCEPTO',cConcDed},{"MESDESDE","1"},{"MESHASTA","12"},{"MONTOMENSUAL", nTotDed}})
					EndIf		
				EndIf						
			EndIf
			If !VldAtrbXML(aDed, cArchivo)
				Return
			EndIf		
		EndIf
	EndIf
	
	/*Nodo Retencciones*/
	If XmlChildEx(oXml:_PRESENTACION, "_RETPERPAGOS") <> Nil
		If ObtUidXML(oXml:_PRESENTACION:_RETPERPAGOS, "RETPERPAGO")
			If ValType(oXml:_PRESENTACION:_RETPERPAGOS:_RETPERPAGO) <> "O"
				For nLoop := 1 To Len(oXml:_PRESENTACION:_RETPERPAGOS:_RETPERPAGO)
					nTotRet += Val(oXml:_PRESENTACION:_RETPERPAGOS:_RETPERPAGO[nLoop]:_MONTOTOTAL:TEXT)
				Next
			Else
				nTotRet := Val(oXml:_PRESENTACION:_RETPERPAGOS:_RETPERPAGO:_MONTOTOTAL:TEXT)	
			EndIf
			If nTotRet <> 0
				cConcRet := ObtConSRV(cTipRet) //Obtener concepto de SRV
				aAdd(aRet, {{'MONTOTOTALDED', nTotRet}, {'CONCEPTORET', cConcRet}})
			
				If !VldAtrbXML(aDed, cArchivo)
					Return
				EndIf
			EndIf
		EndIf
	EndIf

	/*Nodo de Ganancias Liquidadas por otros Empleadores o Entidades*/
	If XmlChildEx(oXml:_PRESENTACION, "_GANLIQOTROSEMPENT") <> Nil
		aDetEmpEnt := GPER811Gan(oXml)
		If Len(aDetEmpEnt) > 0
			If !VldAtrbXML(aDetEmpEnt, cArchivo)
				Return
			EndIf
		EndIf
	EndIf

	GPEGraba(cArchivo, aDepFam, aDed, aRet, aDetEmpEnt)
Return

/*/{Protheus.doc} gp811XMLPER
//TODO Funcion para procesar los periodos de vigencia de deducciones contenidas en XML
@author mayra.camargo
@since 27/06/2020
@version undefined
@param nTotDed, numeric, descripci๓n
@param cConcDed, characters, descripci๓n
@param oXML, object, descripci๓n
@param aRet, array, descripci๓n
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function gp811XMLPER(nTotDed,cConcDed,oXML,aRet)
	Local nI		:= 0
	Local cMesDe	:= ""
	Local cMesHa	:= ""
	Local nTotMen	:= 0 
	
	Default oXML		:= Nil
	Default nTotDed 	:= 0
	Default cConcDed	:= ""
	Default aRet		:= {}
	
	If oXML <> Nil
	
		If Valtype(oXml:_PERIODO) <> "O" 
			For nI:= 1 to len(oXml:_PERIODO)				 
				nTotMen := Val(oXml:_PERIODO[nI]:_MONTOMENSUAL:TEXT)
				cMesDe  := oXml:_PERIODO[nI]:_MESDESDE:TEXT
				cMesHa  := oXml:_PERIODO[nI]:_MESHASTA:TEXT
				aAdd(aRet, {{'MONTOTOTAL', nTotDed}, {'CONCEPTO',cConcDed},{"MESDESDE",cMesDe},{"MESHASTA",cMesHa},{"MONTOMENSUAL", nTotMen}})					
			Next nI
		Else
			nTotMen := Val(oXml:_PERIODO:_MONTOMENSUAL:TEXT)
			cMesDe  := oXml:_PERIODO:_MESDESDE:TEXT
			cMesHa  := oXml:_PERIODO:_MESHASTA:TEXT
			aAdd(aRet, {{'MONTOTOTAL', nTotDed}, {'CONCEPTO',cConcDed},{"MESDESDE",cMesDe},{"MESHASTA",cMesHa},{"MONTOMENSUAL", nTotMen}})					
		EndIf
	EndIf
	
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGPEGraba        บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Graba informacion en el sistema                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPEGraba(cArchivo, aDepFam, aDed, aRet, aDetEmpEnt)
	Local nI      := 0
	Local aFam    := {}
	Local aRG1    := {}
	Local nSeqSRB := ObtCodSRB()
	Local nOrdRG1 := ObtCodRG1()
	Local nPos	  := 0
	Local nDiaFin := 0

	Default cArchivo 	:= ""
	Default aDepFam 	:= {}
	Default aDed 		:= {}
	Default aRet 		:= {}
	Default aDetEmpEnt	:= {}
	
	Begin Transaction
		/*Actualiza tabla SRA - Empleados*/
		If SRA->(MsSeek(xFilial("SRA") + cCuitEmp))
			RecLock("SRA",.F.)  
				Replace SRA->RA_F572WEB With "S"
				Replace SRA->RA_WEBFECH With dFchPres
			SRA->(MsUnLock())	
		EndIf
		
		/*Obtiene CUIT dependientes*/
		If SRB->(MsSeek(xFilial("SRB") + cMatEmp))
			Do While !SRB->(EOF()) .And. SRB->(RB_FILIAL + RB_MAT) == xFilial("SRB") + cMatEmp
				RecLock("SRB",.F.) 
					Replace SRB->RB_TIPIR With '4'
				MsUnLock()
				aAdd(aFam, {Alltrim(SRB->RB_CIC), SRB->(RECNO())})	
				SRB->(dbSkip())
			EndDo
		EndIf
		
		/*Actualiza tabla SRB - Dependientes*/
		For nI := 1 To Len(aDepFam)
			nPos := aScan( aFam,{|x| x[1] == Alltrim(aDepFam[nI][8][2])})
			If nPos > 0
				SRB->(dbGoTo(aFam[nPos][2]))
				RecLock("SRB",.F.) 
					Replace SRB->RB_NOME 		With Upper(aDepFam[nI][1][2] + " " + aDepFam[nI][2][2])
					Replace SRB->RB_DTNASC 		With aDepFam[nI][3][2]
					Replace SRB->RB_GRAUPAR 	With aDepFam[nI][4][2]
					Replace SRB->RB_TIPIR 		With aDepFam[nI][5][2]
					Replace SRB->RB_TIPSF 		With "4"
					Replace SRB->RB_DATAINI 	With CTOD('01/' + aDepFam[nI][6][2] + '/' +  Str(nAnio))
					Replace SRB->RB_DTENTRA 	With CTOD('01/' + aDepFam[nI][6][2] + '/' +  Str(nAnio))
					Replace SRB->RB_DTBAIXA 	With CTOD('30/' + aDepFam[nI][7][2] + '/' +  Str(nAnio))					
				SRB->(MsUnLock())
			Else
				RecLock("SRB",.T.) 
					Replace SRB->RB_FILIAL 		With xFilial("SRB")
					Replace SRB->RB_MAT 		With cMatEmp
					Replace SRB->RB_COD 		With Strzero(nSeqSRB, 2)
					Replace SRB->RB_NOME 		With Upper(aDepFam[nI][1][2] + " " + aDepFam[nI][2][2])
					Replace SRB->RB_DTNASC 		With aDepFam[nI][3][2]
					Replace SRB->RB_SEXO 		With "M"
					Replace SRB->RB_GRAUPAR 	With aDepFam[nI][4][2]
					Replace SRB->RB_TIPIR 		With aDepFam[nI][5][2]
					Replace SRB->RB_TIPSF 		With "4"
					Replace SRB->RB_DATAINI 	With CTOD('01/' + aDepFam[nI][6][2] + '/' +  Str(nAnio))
					Replace SRB->RB_DTENTRA 	With CTOD('01/' + aDepFam[nI][6][2] + '/' +  Str(nAnio))
					Replace SRB->RB_DTBAIXA 	With CTOD(STRZERO(Last_Day(CTOD("01/" + aDepFam[nI][7][2] + '/' +  Str(nAnio))),2) +"/" + aDepFam[nI][7][2] + '/' +  Str(nAnio))
					Replace SRB->RB_CIC 		With aDepFam[nI][8][2]
					Replace SRB->RB_PREPAGA 	With '2' //Pendiente	por confirmar valor
				SRB->(MsUnLock())
				
				nSeqSRB += 1		
			EndIf
		Next
		
		/*Obtiene Concepto de Tabla - RG1 Asientos Fijos*/
		aRg1 := GPR811RG1(cMatEmp)
		
		/*Actualiza tabla RG1 - Asientos Fijos (Deducciones)*/
		For nI := 1 To Len(aDed)
			nPos := aScan( aRG1,{|x| x[1] == Alltrim(aDed[nI][2][2]) .And. x[3] == "" .And. x[4] == Strzero(Val(aDed[nI][3][2]),2) })
			nDiafin := last_Day(CTOD("01/"+ aDed[nI][4][2]+"/ "+ Str(nAnio)))
			If nPos > 0
				RG1->(dbGoTo(aRG1[nPos][2]))
				RecLock("RG1",.F.)
					Replace RG1->RG1_VALOR 		With aDed[nI][5][2]
					Replace RG1->RG1_DFIMPG 	With CTOD(STRZERO(nDiafin,2) +"/ "+ aDed[nI][4][2]+"/ "+ Str(nAnio))
				MsUnLock()
				aRG1[nPos][3] := "Actualizado"
			Else
				RecLock("RG1",.T.) 
					Replace RG1->RG1_FILIAL 	With xFilial("RG1")
					Replace RG1->RG1_MAT 		With cMatEmp
					Replace RG1->RG1_AUTOM 		With "1"
					Replace RG1->RG1_ORDEM 		With Strzero(nOrdRG1, 3)
					Replace RG1->RG1_TPCALC 	With "1"
					Replace RG1->RG1_PD 		With aDed[nI][2][2]
					Replace RG1->RG1_VALOR 		With aDed[nI][5][2]
					Replace RG1->RG1_CC 		With cRACC
					Replace RG1->RG1_DINIPG 	With CTOD('01/' + aDed[nI][3][2]+"/"+ Str(nAnio))
					Replace RG1->RG1_LIBPAG 	With CTOD('01/' + aDed[nI][3][2]+"/"+ Str(nAnio))
					Replace RG1->RG1_DFIMPG 	With CTOD(STRZERO(nDiafin,2) +"/ "+ aDed[nI][4][2]+"/ "+ Str(nAnio))
				MsUnLock()
				
				nOrdRG1 += 1		
			EndIf
		Next 
		
		/*Actualiza tabla RG1 - Asientos Fijos (Retenciones)*/
		For nI := 1 To Len(aRet)
			nPos := aScan( aRG1,{|x| x[1] == Alltrim(aRet[nI][2][2]) .And. x[3] == ""})
			If nPos > 0
				RG1->(dbGoTo(aRG1[nPos][2]))
				RecLock("RG1",.F.)
					Replace RG1->RG1_VALOR 	With aRet[nI][1][2]
					Replace RG1->RG1_DFIMPG 	With CTOD( "31/12/"+ Str(nAnio))				
					MsUnLock()
				aRG1[nPos][3] := "Actualizado"
			Else
				RecLock("RG1",.T.) 
					Replace RG1->RG1_FILIAL 	With xFilial("RG1")
					Replace RG1->RG1_MAT 	With cMatEmp
					Replace RG1->RG1_AUTOM 	With "1"
					Replace RG1->RG1_ORDEM 	With  Strzero(nOrdRG1, 3)
					Replace RG1->RG1_TPCALC 	With "1"
					Replace RG1->RG1_PD 		With aRet[nI][2][2]
					Replace RG1->RG1_VALOR 	With aRet[nI][1][2]
					Replace RG1->RG1_CC 		With cRACC
					Replace RG1->RG1_DINIPG 	With CTOD('01/01/' + Str(nAnio))
					Replace RG1->RG1_LIBPAG 	With CTOD('01/01/' + Str(nAnio))
					Replace RG1->RG1_DFIMPG 	With CTOD( "31/12/"+ Str(nAnio))
				MsUnLock()
				
				nOrdRG1 += 1		
			EndIf
		Next

		/*Actualiza tabla RG1 - Asientos Fijos (Ganancias Liquidadas por otros Empleadores o Entidades)*/
		For nI := 1 To Len(aDetEmpEnt)
			//Valida que exista el registro en RG1, comparando Concepto, que no est้ actualizado y el mes del registro.
			nPos := aScan(aRG1, {|x| x[1] == Alltrim(aDetEmpEnt[nI][3][2]) .And. x[3] == "" .And. x[4] == aDetEmpEnt[nI][1][2] })
			
			If nPos > 0
				RG1->(DBGoTo(aRG1[nPos][2]))
				RecLock("RG1",.F.)
					Replace RG1->RG1_VALOR 		With aDetEmpEnt[nI][2][2]
				RG1->(MsUnLock())
				aRG1[nPos][3] := "Actualizado"
			Else
				RecLock("RG1",.T.)
					Replace RG1->RG1_FILIAL 	With xFilial("RG1")
					Replace RG1->RG1_MAT 		With cMatEmp
					Replace RG1->RG1_AUTOM 		With "1"
					Replace RG1->RG1_ORDEM 		With Strzero(nOrdRG1, 3)
					Replace RG1->RG1_TPCALC 	With "1"
					Replace RG1->RG1_PD 		With aDetEmpEnt[nI][3][2]
					Replace RG1->RG1_VALOR 		With aDetEmpEnt[nI][2][2]
					Replace RG1->RG1_CC 		With cRACC
					Replace RG1->RG1_DINIPG 	With FirstDay(CToD("01/"+ aDetEmpEnt[nI][1][2] + "/" + LTrim(Str(nAnio))))
					Replace RG1->RG1_LIBPAG 	With FirstDay(CToD("01/"+ aDetEmpEnt[nI][1][2] + "/" + LTrim(Str(nAnio))))
					Replace RG1->RG1_DFIMPG 	With LastDay(CToD("01/"+ aDetEmpEnt[nI][1][2] + "/" + LTrim(Str(nAnio))))
				RG1->(MsUnLock())
				
				nOrdRG1 += 1
			EndIf
		Next
		
		For nPos:= 1 to len(aRG1)
			If aRG1[nPos][3] <> "Actualizado"
				RG1->(dbGoTo(aRG1[nPos][2]))
				RecLock("RG1",.F.)
					RG1->(dbDelete())
				MsUnLock()
			EndIf
		Next nPos
	End Transaction
	
	aAdd(aErrLog, {cArchivo, STR0011}) //"Importando"
	ArchProc(cArchivo)
	
	nArchImp += 1
	
Return
/*/{Protheus.doc} GPR811RG1
//TODO Funci๓n para Discriminar los conceptos registrados en RG! y SRV para ganancias f572
@author mayra.camargo
@since 27/06/2020
@version undefined
@param cMEmp, characters, descripci๓n
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GPR811RG1(cMEmp)
	Local aArea := getArea()
	Local cTemp := getNextAlias()	
	Local aRet := {}
	Local dFchIni := CTOD('01/01/'+ Str(nAnio))
	Local dFchFin := CTOD('31/12/'+ Str(nAnio))
	
	Default cMEmp := SRA->RA_MAT
	
	BEGINSQL ALIAS cTemp
		SELECT RG1.RG1_PD, RG1.R_E_C_N_O_ AS RECNO, RG1.RG1_DINIPG
		FROM %Table:RG1% RG1 INNER JOIN %Table:SRV% SRV  ON RG1.RG1_PD=SRV.RV_COD
		WHERE SRV.RV_FILIAL = %Exp:XFILIAL("SRV")% 
		AND RG1.RG1_FILIAL = %Exp:XFILIAL("RG1")%
		AND RG1.RG1_MAT=%Exp:cMEmp%
		AND SRV.RV_PDF572W <> ''	
		AND (RG1.RG1_DINIPG >= %Exp:dFchIni% AND RG1.RG1_DFIMPG <= %Exp:dFchFin%)
		AND RG1.%notDel%	
		AND SRV.%notDel%	
	ENDSQL
	
	(cTemp)->(dbGoTop())
	While (!(cTemp)->(EOF()))
		aAdd(aRet, { Alltrim((cTemp)->RG1_PD), (cTemp)->RECNO, "", Strzero(Month(STOD((cTemp)->RG1_DINIPG)),2) })	
		(cTemp)->(dbSkip())
	EndDo
	(cTemp)->(dbCloseArea())
	RestArea(aArea)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtInfEmp       บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener matricula del empleado                                   บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtInfEmp(cCUIT)
	If	SRA->(MsSeek(xFilial("SRA") + cCUIT))
		cMatEmp := Alltrim(SRA->RA_MAT)
		cRACC   := Alltrim(SRA->RA_CC)
	Else
		cMatEmp := ""
		cRACC   := ""		
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtConSRV       บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener concepto de tabla SRV                                    บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtConSRV(cCodigo)
	Local cQuery   := ""
	Local cConc    := ""
	Local cArchTmp := CriaTrab(Nil, .F.)
	Local nNumRegs := 0

	cQuery := " SELECT RV_COD "
	cQuery += " FROM " + RetSqlName("SRV")
	cQuery += " WHERE RV_PDF572W = '" + cCodigo + "'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY RV_COD"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArchTmp,.T.,.T.)
	
	Count To nNumRegs
	
	If nNumRegs > 0
		(cArchTmp)->(DBGoTop())
		cConc := AllTrim((cArchTmp)->RV_COD)
	EndIf
	
	GPEDelArea(cArchTmp)
Return cConc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtCodSRB       บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene el consecutivo del campo RB_COD                          บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtCodSRB()
	Local cQuery   := ""
	Local nOrden   := ""
	Local cArchTmp := CriaTrab(Nil, .F.)
	Local nNumRegs := 0

	cQuery := " SELECT MAX(RB_COD) RB_COD"
	cQuery += " FROM " + RetSqlName("SRB")
	cQuery += " WHERE RB_MAT = '" + cMatEmp + "'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArchTmp,.T.,.T.)
	
	Count To nNumRegs
	
	If nNumRegs > 0
		(cArchTmp)->(dbGoTop())
		nOrden := Val((cArchTmp)->RB_COD) + 1
	Else
		nOrden := 1
	EndIf
	
	GPEDelArea(cArchTmp)
Return nOrden

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtCodRG1       บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene el consecutivo del campo RG1_ORDEM                       บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtCodRG1()
	Local cQuery	:= ""
	Local nOrden	:= ""
	Local cArchTmp	:= CriaTrab(Nil, .F.)
	Local nNumRegs	:= 0

	cQuery := " SELECT MAX(RG1_ORDEM) RG1_ORDEM"
	cQuery += " FROM " + RetSqlName("RG1")
	cQuery += " WHERE RG1_MAT = '" + cMatEmp + "'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArchTmp,.T.,.T.)
	
	Count To nNumRegs
	
	If nNumRegs > 0
		(cArchTmp)->(dbGoTop())
		nOrden := Val((cArchTmp)->RG1_ORDEM) + 1
	Else
		nOrden := 1
	EndIf
	
	GPEDelArea(cArchTmp)
Return nOrden

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtClvTbl       บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene clave de tabla generica                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtClvTbl()
Local aCvlTbl := {}
Local nLoop   := 0

	If subStr(cCvlTbls,len(cCvlTbls),1) != "|"
		cCvlTbls += "|"
	EndIf
	If cCvlTbls != "|"
		For nLoop := 1 To Len(cCvlTbls)
			aAdd(aCvlTbl, AllTrim(Substr(cCvlTbls, 1, At("|", cCvlTbls) -1)))
			cCvlTbls := Substr(cCvlTbls, At("|", cCvlTbls) +1, Len(cCvlTbls) -At("|", cCvlTbls))
			If Len(cCvlTbls) == 0
				Exit
			EndIf
		Next nLoop
	EndIF
	If Len(aCvlTbl) = 2
		cCvlTblF := aCvlTbl[1] //Clave de tabla 'Parentesco'
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtInfAdc       บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene Grupo y tipo de parentesco                               บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtInfAdc(cTipo)
Local cDescCod := ""
Local nLoop    := 0
Local aCods    := {}

	If SX5->(MsSeek(xFilial("SX5") + cCvlTblF + cTipo))
		cDescCod := Alltrim(SX5->X5_DESCRI) 
		
		If subStr(cDescCod,Len(cDescCod),1) != "|"
			cDescCod += "|"
		EndIf
		For nLoop := 1 To Len(cDescCod)
			aAdd(aCods, Alltrim(Substr(cDescCod, 1, At("|", cDescCod) -1)))
			cDescCod := Substr(cDescCod, At("|", cDescCod) +1, Len(cDescCod) -At("|", cDescCod))
			If Len(cDescCod) == 0
				Exit
			EndIf
		Next Loop			
	EndIf
	If Len(aCods) == 3
		cValGrp := aCods[1] //Valor grupo
		cValDep := aCods[2] //Tipo de dependiente
	Else
		cValGrp := "" //Valor grupo
		cValDep := "" //Tipo de dependiente	
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtUidXML       บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida que exista el nodo a consultar en el XML                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtUidXML(oNodo,cNodo)
Local cXML     := ""      
Local lRet     := .F.
	
	If valType(oNodo) == "O"
		SAVE oNodo XMLSTRING cXML
		
		If At( Upper(cNodo) , Upper(cXml) ) > 0
			lRet := .T. 
		Endif
	Endif
	
Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGrabaLog        บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Graba Log                                                        บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrabaLog()
Local cArchLog := "F572W_" + DTOS(Date()) + Strtran(Time(), ":") + ".log"
Local nLoop    := 0
Local nHdle    := FCreate(cRutaLoc + cArchLog, 0)
Local lRet		 := .F.
	
	If !(nHdle == -1)
		For nLoop := 1 To Len(aErrLog)
			FWrite(nHdle, aErrLog[nLoop][1] + " - " + aErrLog[nLoop][2] + CRLF)
		Next
		FClose (nHdle)
		lRet := .T.
	Else
		Aviso( OemToAnsi(STR0002), OemToAnsi(STR0010 + cArchLog), {STR0004})
	EndIf   
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณArchProc        บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Renombra archivos procesados y sin errores                       บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ArchProc(cArch)

Local nLen  := At( "." , cArch ) - 1

	If File(cRutaLoc + cArch)
		Frename( cRutaLoc + cArch , cRutaLoc + Substr(cArch, 1, nLen) + "_PROCESADO.xml" )
	EndIf

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGetDirF572      บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Selecciona directorio donde se almacenan los archivos XML        บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetDirF572()
Local lRuta := .F.
Local cRuta := ""

	cRuta := cGetFile( '|(*.*)|' , 'Seleccione Diret๓rio', 0 , "C:\", .F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY )
	
	If !Empty(cRuta)
		MV_PAR01 := cRuta
		lRuta := .T.
	EndIf
Return lRuta

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณVldParam        บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida que sea informada la ruta de los archivos XML             บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldParam()
Local lOK := .T.
	If Empty(MV_PAR01)
		Aviso( OemToAnsi(STR0002), OemToAnsi(STR0006), {STR0004})
		lOK := .F.
	EndIf
	If Empty(cCvlTbls)
		Aviso( OemToAnsi(STR0002), OemToAnsi(STR0007), {STR0004})
		lOK := .F.
	EndIf
Return lOK

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณVldAtrbXML      บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Se valida atributo y crea log                                    บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function VldAtrbXML(aAtrb, cArchivo)
Local nI := 0
Local nJ := 0
	
	For nI := 1 To Len(aAtrb)
		For nJ := 1 To Len(aAtrb[nI])
			If Valtype(aAtrb[nI][nJ][2]) == "C"
				If Empty(aAtrb[nI][nJ][2]) .and. aAtrb[nI][nJ][1] <> "NOMBRE"
					aAdd(aErrLog, {cArchivo, Replace(STR0009, '#valor#', aAtrb[nI][nJ][1])}) //"Atributo #valor# sin informaci๓n"
					nArchErr += 1
					Return .F.
				EndIf
			ElseIf Valtype(aAtrb[nI][nJ][2]) == "N"
				If Empty(Str(aAtrb[nI][nJ][2]))
					aAdd(aErrLog, {cArchivo, Replace(STR0009, '#valor#', aAtrb[nI][nJ][1])}) //"Atributo #valor# sin informaci๓n"
					nArchErr += 1
					Return .F.
				EndIf
			ElseIf Valtype(aAtrb[nI][nJ][2]) == "D"
				If Empty(DTOS(aAtrb[nI][nJ][2]))
					aAdd(aErrLog, {cArchivo, Replace(STR0009, '#valor#', aAtrb[nI][nJ][1])}) //"Atributo #valor# sin informaci๓n"
					nArchErr += 1
					Return .F.
				EndIf
			EndIf	
		Next
	Next
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGPEDelArea      บAutor  ณLuis Samaniego      บ Data ณ  13/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Elimina tablas temporales                                        บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPEDelArea(cArchTmp)
	(cArchTmp)->(dbCloseArea())
	FErase(AllTrim(cArchTmp)+GetDBExtension())
Return

/*/{Protheus.doc} GPER811Gan
	Funci๓n utilizada para obtener Ganancias Liquidadas por otros 
	Empleadores o Entidades
	
	@type  Static Function
	@author marco.rivera
	@since 26/11/2021
	@version 1.0
	@param oXml, Object, XML parseado
	@return aNodIngMes, Array, Arreglo con el mes, valor y concepto de cada nodo.
	@example
	GPER811Gan(oXml)
/*/
Static Function GPER811Gan(oXml)

	Local aArea			:= GetArea()
	Local nLoopEmp		:= 0
	Local nLoopIng		:= 0
	Local oNodoIng		:= Nil
	Local aNodosIngr	:= {}
	Local aNodIngMes	:= {}
	Local nLoop			:= 0
	Local aDetPorMes	:= {}

	Default oXml		:= Nil

	/*Determina los atributos correspondientes a Gastos, Ingreso o Aportes*/
	aNodosIngr := fGetConSX5()

	If ObtUidXML(oXml:_PRESENTACION:_GANLIQOTROSEMPENT, "EMPENT")
		If ValType(oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT) <> "O" //Si contiene varios Empleadores/Entidades
			For nLoopEmp := 1 To Len(oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT)
				If XmlChildEx(oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT[nLoopEmp], "_INGRESOSAPORTES") <> Nil
					If ObtUidXML(oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT[nLoopEmp]:_INGRESOSAPORTES, "INGAP")
						If ValType(oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT[nLoopEmp]:_INGRESOSAPORTES:_INGAP) <> "O" //Valida que el nodo <ingAp> no se un objeto
							For nLoopIng := 1 To Len(oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT[nLoopEmp]:_INGRESOSAPORTES:_INGAP) //Se procesa cada nodo de ingresos mensuales
								oNodoIng	:= oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT[nLoopEmp]:_INGRESOSAPORTES:_INGAP[nLoopIng]
								fGasPorMes(oNodoIng, aNodosIngr, @aDetPorMes) //Se obtiene el valor de cada concepto
							Next nLoopIng
						Else
							oNodoIng := oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT[nLoopEmp]:_INGRESOSAPORTES:_INGAP
							fGasPorMes(oNodoIng, aNodosIngr, @aDetPorMes) //Se obtiene el valor de cada concepto
						EndIf
					EndIf
				EndIf
			Next nLoopEmp
		Else //Si contiene un Empleador/Entidad
			If XmlChildEx(oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT, "_INGRESOSAPORTES") <> Nil
				If ObtUidXML(oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT:_INGRESOSAPORTES, "INGAP")
					If ValType(oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT:_INGRESOSAPORTES:_INGAP) <> "O" //Valida que el nodo <ingAp> no se un objeto
						For nLoopIng := 1 To Len(oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT:_INGRESOSAPORTES:_INGAP) //Se procesa cada nodo de ingresos mensuales
							oNodoIng := oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT:_INGRESOSAPORTES:_INGAP[nLoopIng]
							fGasPorMes(oNodoIng, aNodosIngr, @aDetPorMes) //Se obtiene el valor de cada concepto
						Next nLoopIng
					Else
						oNodoIng := oXml:_PRESENTACION:_GANLIQOTROSEMPENT:_EMPENT:_INGRESOSAPORTES:_INGAP
						fGasPorMes(oNodoIng, aNodosIngr, @aDetPorMes) //Se obtiene el valor de cada concepto
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//Se crea arreglo final para grabado en RG1
	If Len(aDetPorMes) > 0
		aSort(aDetPorMes, , , {|x, y| x[1] < y[1]}) //Se ordenan los registros por mes
		For nLoop := 1 To Len(aDetPorMes)
			aAdd(aNodIngMes, {	{'MES'		, aDetPorMes[nLoop][1]},;
								{"VALOR"	, aDetPorMes[nLoop][3]},;
								{'CONCEPTO'	, aDetPorMes[nLoop][4]}})
		Next nLoop
	EndIf

	RestArea(aArea)

Return aNodIngMes

/*/{Protheus.doc} fGasPorMes
	Funci๓n utilizada para agrupar la informaci๓n por mes, obtenida al
	leer el nodo <ingAp>.

	@type  Static Function
	@author marco.rivera
	@since 26/11/2021
	@version 1.0
	@param oNodoIng, Object, Nodo con los atributos correspondientes a Gastos, Ingresos o Aportes.
	@param aNodosIngr, Array, Lista de nodos configurados en SX5 - XE - X?.
	@param aDetPorMes, Array, Detalle de Gastos, Ingresos o Aporte por mes.
	@example
	fGasPorMes(oNodoIng, aNodosIngr, aDetPorMes)
/*/
Static Function fGasPorMes(oNodoIng, aNodosIngr, aDetPorMes)

	Local nLoopNodos	:= 0
	Local cNodoMes		:= ""
	Local cNodoRName	:= ""
	Local nNodoVal		:= ""
	Local nPosMes		:= 0
	Local cCodConcep	:= ""
	Local cNombreNod	:= ""

	Default aNodosIngr	:= {}
	
	If XmlChildEx(oNodoIng, "_MES") <> Nil
		cNodoMes := StrZero(Val(oNodoIng:_MES:TEXT),2)
	EndIf

	For nLoopNodos := 1 To Len(aNodosIngr)

		cNombreNod := "_" + aNodosIngr[nLoopNodos][2]

		If XmlChildEx(oNodoIng, cNombreNod) <> Nil
			cNodoRName	:= Upper(&("oNodoIng:" + cNombreNod + ":REALNAME"))
			cCodConcep	:= ObtConSRV(aNodosIngr[nLoopNodos][1])
			nNodoVal	:= Val(&("oNodoIng:" + cNombreNod + ":TEXT"))
			
			//Busca registro en el mes que existan en el arreglo, para agrupar Valores.
			nPosMes		:= aScan(aDetPorMes, {|x| x[1] + x[2] == cNodoMes + cNodoRName })
			
			If nNodoVal > 0
				If nPosMes == 0
					aAdd(aDetPorMes, {cNodoMes, cNodoRName, nNodoVal, cCodConcep})
				Else
					aDetPorMes[nPosMes][3] += nNodoVal
				EndIf
			EndIf
		EndIf
	Next nLoopNodos
	
Return

/*/{Protheus.doc} fGetConSX5
	Funci๓n utilizada para obtener los registros de la Tabla alfanum้rica - XE,
	con las llaves que comienzan con "X".

	@type  Static Function
	@author marco.rivera
	@since 29/11/2021
	@version 1.0
	@return aConIngSX5, Array, Arreglo con las llaves y nodos.
	@example
	fGetConSX5()
/*/
Static Function fGetConSX5()

	Local aArea			:= GetArea()
	Local cAliasSX5		:= GetNextAlias()
	Local cWhereChav	:= "%SX5.X5_CHAVE LIKE 'X%'%"
	Local aConIngSX5	:= {}
	
	/*Se obtiene nombre de los nodos configurados en SX5 - XE*/
	BeginSql Alias cAliasSX5
		SELECT 
			X5_CHAVE, X5_DESCSPA
		FROM   
			%TABLE:SX5% SX5
		WHERE  
			SX5.X5_FILIAL = %xFilial:SX5% AND 
			SX5.X5_TABELA = %Exp:"XE"% AND
			%EXP:cWhereChav% AND
			SX5.%NotDel%
	EndSql

	(cAliasSX5)->(DBGoTop())
	While (cAliasSX5)->(!EoF())
		aAdd(aConIngSX5, {(cAliasSX5)->X5_CHAVE, fGetNodSX5((cAliasSX5)->X5_DESCSPA)})
		(cAliasSX5)->(DBSkip())
	EndDo
	(cAliasSX5)->(DBCloseArea())

	RestArea(aArea)
	
Return aConIngSX5

/*/{Protheus.doc} fGetNodSX5
	Funci๓n utilizada para obtener de las descripciones en SX5, los nodos
	correspondientes a Ganancias Liquidadas por otros Empleadores o Entidades.

	@type  Static Function
	@author marco.rivera
	@since 29/11/2021
	@version 1.0
	@param cDescri, Character, Descripci๓n de Tabla + Llave en SX5.
	@return cNodo, Character, Nombre del nodo.
	@example
	fGetNodSX5(cDescri)
/*/
Static Function fGetNodSX5(cDescri)
	Local cNodo	:= ""

	Default cDescri := ""

	cNodo := SubStr(cDescri, 1, Rat(">", cDescri))
	cNodo := StrTran(cNodo, "<", "" )
	cNodo := Upper(StrTran(cNodo, ">", "" ))
	
Return cNodo
