#INCLUDE "protheus.ch"
#include "FILEIO.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "M486XFUNBO.CH"
#INCLUDE "TBICONN.CH"

Static aCposImpD1	:= {}
Static aCposImpD2	:= {}

/*/{Protheus.doc} M486XFUNBOL
Comunicación con el WS para transmisión y consulta
@author alfredo.medrano
@since 11/10/2019
@version 1.0
@param aFact, array, Array con los documentos de los cuales se generarán los XML
@param aError, array, Array con Errores 
@param aTrans, array, Array con los documentos que han sido transmitidos 
@param cTipTrans, string, String con el tipo de transacción T= transmisión, E= Consulta
@param aRetObs, array, Array con las observaciones (generadas por la consulta de la transmisión)
@return lRet, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486XFUNBOL(aFact, aError, aTrans, cTipTrans, aRetObs, lRetSal)
	Local lRet := .T.
	Local cParametros := ""
	Local cMVCFDIAMB:= SuperGetMV("MV_CFDIAMB",,"") //cod Ambiente 2 
	Local cMVSISTEMA:= SuperGetMV("MV_SINSIS",,"") //cod Sistema
	Local cMVNUMSUC	:= SuperGetMV("MV_NUMSUC",,0) 	//cod Sucursal
	Local cMVCUIS   := SuperGetMV("MV_CUIS",,"")	//cuis
	Local cMVNIT    := alltrim(SM0->M0_CGC)	//nit
	Local cMV814PATH:= SuperGetMV("MV_PATH814 ",,"")//Direccion donde se guardaran los archivos csv
	Local cRutaSMR	:= &(SuperGetMV("MV_CFDSMAR",,""))//ruta donde reside el cliente de WS 
	Local cMVCFDIPA := SuperGetMV("MV_CFDI_PA",,"") //Nombre del ejecutable del servicio web a utiliza.   
	Local cPath 	:= &(SuperGetMV("MV_CFDDOCS",,""))  
	Local cMVMODAL	:= SuperGetMV("MV_SINMOD",,"") //Modalidad 1=Electrónica, 2=Computarizada, 3=Manual, 4=Prevalorada Electrónica, 5=Prevalorada Computarizada
	Local cCUFD     := SuperGetMV("MV_CUFD",,"") //CUFD
	Local cCUFDFEC	:= SuperGetMV("MV_CUFDFEC",,"") // Fecha vigencia cufd
	Local cMVCFDIPX := SuperGetMV("MV_CFDI_PX",,"") //Archivo certificado pfx
	Local cMVCFDICVE:= SuperGetMV("MV_CFDICVE",,"") // Clave de llave privada.
	Local cMVEMISION:= SuperGetMV("MV_SINEMI",,"1") //1=Online, 2=Offline
	Local cFilTab   := IIf(Alltrim(cEspecie) $ "NF|NDC", xFilial("SF2"), xFilial("SF1"))
	local cMsg 		:= ""
	Local cCodigo 	:= ""
	Local cDescrip 	:= ""
	local cNomArch 	:= ""
	Local cError 	:= ""
	Local cCatOk 	:= ""
	Local cWarning 	:= ""
	Local lHasError := .F.
	Local cCodTab 	:= ""
	Local cCodEst 	:= ""
	Local cCodRes 	:= ""
	Local nX		:= 0 	
	Local nOpc 		:= 0
	Local nHandle 	:= 0
	Local nRet		:= 0
	Local nI 		:= 0
	Local nT		:= 0
	Local cCUF		:= ""
	Local cFechTrns := ""
	Local cHoraTrns := ""
	Local aTrErr	:= {}
	Local cNumDto  	:=iif(AllTrim(cEspecie) =="NF", '1',iif(AllTrim(cEspecie) =="NCC", '4', iif(AllTrim(cEspecie) =="NDC", '5', '0')) )
	Local cCodDocF 	:= "0"
	Local cPuntoVen := "0"
	Local cSeriePe 	:= MV_PAR01
	Local lRetSal	:= .T.
	/* array aCodEst
	0   = no transmitida.                        0    BR_CINZA
	901 = Recepción Pendiente.                   4    BR_AMARELO
	902 = Recepción Rechazada.                   5    BR_VERMELHO
	903 = Recepción Procesada.                   1    BR_AZUL
	904 = Recepción Observada.                   5    BR_VERMELHO
	905 = Anulación Confirmada.                  8    BR_LARANJA
	906 = Anulación Rechazada.                   9    BR_PRETO
	907 = Anulación Pendiente de Confirmación.   7    BR_PINK
	908 - Recepción Validada.                    6    BR_VERDE
	*/
	Private aCodEst := {{'901','4'},{'902','5'},{'903','1'},{'904','5'},{'905','8'},{'906','9'},{'907','7'},{'908','6'}}
	Private cTipT 	:= cTipTrans
	Private aCabsSF1  := {}
	Private aCabsSF2  := {}
	Private aItensSD1 := {}
	Private aItensSD2 := {}
	default aRetObs	:= {}
	default aError  := {} 
	default aTrans  := {} 
	

	dbSelectArea("SFP")
	SFP->(dbSetOrder(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE+FP_PV
	If SFP->(MsSeek(xFilial("SFP") + cFilAnt + cSeriePe + cNumDto))
		cCodDocF := SFP->FP_DOCFIS
		cPuntoVen:= SFP->FP_PV
	EndIf
	
	// Obtener arreglos de campos de SF1/SF2/SD1/SD2
	M486SX3(@aCabsSF1, @aCabsSF2, @aItensSD1, @aItensSD2)
	
	cParametros := alltrim(cTipT) + " "
	/*If cTipT == "T"
		cParametros := "T "//Opción para transmisión
	ElseIf cTipT == "E"
		cParametros := "E "//Opción para validacion 
	ElseIf cTipT == "C"
		cParametros := "C "//Opción para anulacion
	EndIf*/
	cParametros += cMVCFDIAMB + " "							
	cParametros += cMVSISTEMA + " "							
	cParametros += alltrim(STR(cMVNUMSUC)) + " "							            
	cParametros += cMVCUIS + " "						            
	cParametros += cMVNIT + " "							        						        
	cParametros += cMV814PATH + " "	
	cParametros += cRutaSMR	 + " " 
	cParametros += cMVMODAL	 
	
	If Empty(cCUFD)
		cParametros += " X"
	Else
		cParametros += " " + cCUFD	 
	EndIf
	If Empty(cCUFDFEC)
		cParametros += " X"	
	Else
		cParametros += " " + Alltrim(substr(cCUFDFEC,1,10) + "-" + substr(cCUFDFEC,12,8))
	EndIf
	
	cParametros += " " + cMVCFDIPX + " "
	cParametros += cMVCFDICVE + " "
	cParametros += cCodDocF + " "	
	cParametros += cMVEMISION + " "
	cParametros += "1 "
	cParametros += alltrim(cEspecie) + " "
	cParametros += alltrim(cPuntoVen)
	
	If cTipT == "T"
		cMsg := STR0001 + chr(13)+ Chr(10)//"Confirma la transmición de los documentos ?"
	ElseIf cTipT == "E"
		cMsg := STR0002 + chr(13)+ Chr(10)//"Confirma la validación de la recepción de documentos ?"
	ElseIf cTipT == "C"
		cMsg := STR0036 + chr(13)+ Chr(10)// "Confirma la anulación de los documentos seleccionados?" 
	EndIf
	 			        
	If MsgYESNO(cMsg)
	CursorWait()
		aRet	:= {}
		nOpc := WAITRUN( cRutaSMR + cMVCFDIPA + ".exe " + cParametros, 0 )	// Se ejecuta exe	
		If nOpc == 0
			// Lee xml de cufd para actualizar los parametros MV_CUFD y MV_CUFDFEC
			If File(cRutaSMR  + "cufd.xml.out")
				// Procesar archivo out
				CpyT2S(cRutaSMR  + "cufd.xml.out" , cPath)
				oXMLResp := XmlParserFile(EncodeUtf8(cPath + "cufd.xml.out"), "_", @cError, @cWarning )
				If oXMLResp <> Nil
					lHasError := "True" $ oXMLResp:_RESPONSES:_RESPONSE:_HASERROR:TEXT
					If lHasError // Si el .out reportó error		
						cCodigo := oXMLResp:_RESPONSES:_RESPONSE:_EXCEPTION:_CODE:TEXT			
						cError 	+= STR0003  + cCodigo + chr(13)+ Chr(10) //"Error al generar el cufd, Cod Respuesta: "
						cDescrip := ObtColSAT('S012',Alltrim(cCodigo),1,4,5,120)
						aAdd(aError, {"","","","", cCodigo +" "+ ALLTRIM(cDescrip)})	
						lRet := .F.
					Else 
						cCodigo	:= oXMLResp:_RESPONSES:_RESPONSE:_MESSAGE:_CODCUFD:TEXT
						cDataTim:= ALLTRIM(oXMLResp:_RESPONSES:_RESPONSE:_MESSAGE:_DATE:TEXT)
						If cCUFD != cCodigo .or. cCUFDFEC != cDataTim
							PutMvPar("MV_CUFD",cCodigo)
							PutMvPar("MV_CUFDFEC",cDataTim)
						EndIf
					EndIf
				EndIf	
				// Se eliminan archivos de la carpeta del smartclient
				Ferase( cRutaSMR  + "cufd.xml.out" )
			/*Else
				aAdd(aError, {"","","","", STR0053})//"000 No se generó el archivo .out del CUFD"
				lRet := .F.*/
			EndIf
			
			If lRet
				For nI:= 1 to len(aFact)
					cDocXml := alltrim(aFact[nI][1]) + alltrim(aFact[nI][2]) + iif( cTipT == "C", "Anula", alltrim(cEspecie)) + ".xml"
					cDocto := cDocXml + ".out"
					cFilTab := Iif(cTipT == "E", aFact[nI][6],cFilTab)
					If File(cRutaSMR  + cDocXml)
						CpyT2S(cRutaSMR  + cDocXml, cPath)
					EndIf
					If File(cRutaSMR  + cDocto)
					 IncProc(STR0038 + cDocto)//"Procesando Documentos:"
						CpyT2S(cRutaSMR  + cDocto, cPath)
						oXMLResp := XmlParserFile(EncodeUtf8(cPath + cDocto), "_", @cError, @cWarning )
						If oXMLResp <> Nil
							cCodEst := oXMLResp:_RESPUESTA:_CODIGOESTADO:TEXT
							cDescrip := ObtColSAT('S012',cCodEst,1,4,5,120)
							
							If cTipT == "E"
								nT := ascan(aCodEst,{|x| x[1]= cCodEst})
								If  nT > 0
									aAdd(aRet, {val(aCodEst[nT][2]),;
									Alltrim(aFact[nI,1]) + "-" + aFact[nI,2],;
									IIf(cMVCFDIAMB == "1", STR0004, STR0005),;//"Producción" // "Pruebas"
									dDataBase,;
									cCodEst,; //Cod. Estado
									cDescrip,;
									"", ;
									aFact[nI,2], ; //Documento
									aFact[nI,1], ; //Serie
									aFact[nI,3], ; //Cliente
									aFact[nI,4], ; //Loja
									""})  
								EndIf
							EndIf
							
							lHasError := "true" $ oXMLResp:_RESPUESTA:_TRANSACCION:TEXT
							If lHasError // Si el .out reporta envio ok
								cCUF := ""
								cFechTrns := ""
								cHoraTrns := ""
								If XmlChildEx(oXMLResp:_RESPUESTA, "_CUF") <> Nil
									cCUF := oXMLResp:_RESPUESTA:_CUF:TEXT
								EndIf
								If XmlChildEx(oXMLResp:_RESPUESTA, "_FECHA") <> Nil
									cFechTrns := oXMLResp:_RESPUESTA:_FECHA:TEXT
								EndIf
								If XmlChildEx(oXMLResp:_RESPUESTA, "_HORA") <> Nil
									cHoraTrns := oXMLResp:_RESPUESTA:_HORA:TEXT
								EndIf
								cCodRes := oXMLResp:_RESPUESTA:_CODIGORECEPCION:TEXT
								aAdd(aTrans, {cFilTab,aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],cCodEst,cCodRes,cCUF,cFechTrns,cHoraTrns})
								aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], cCodEst +" "+ ALLTRIM(cDescrip)})
							Else
								If cCodEst !="000"// error msg de visual Studio
									aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], cCodEst +" "+ ALLTRIM(cDescrip)})
									aAdd(aTrErr, {cFilTab,aFact[nI,1],aFact[nI,2],aFact[nI,3],aFact[nI,4],cCodEst,"",""})
								EndIF
								If ValType( oXMLResp:_RESPUESTA:_LISTACODIGOSRESPUESTAS) == "A" //Varios 
									For nX := 1 To Len(oXMLResp:_RESPUESTA:_LISTACODIGOSRESPUESTAS)
										cCodRes := oXMLResp:_RESPUESTA:_LISTACODIGOSRESPUESTAS[nX]:TEXT	
										cDescrip := ObtColSAT('S012',cCodRes,1,4,5,120)
										aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], cCodRes +" "+ ALLTRIM(cDescrip)})	
										If cTipT == "E"
											nT := ascan(aCodEst,{|x| x[1]= cCodEst})
											If  nT > 0
												aAdd(aRetObs, {val(aCodEst[nT][2]),;
												Alltrim(aFact[nI,1]) + "-" + aFact[nI,2],;
												IIf(cMVCFDIAMB == "1", STR0004, STR0005),;//"Producción" // "Pruebas"
												dDataBase,;
												cCodEst,; //Cod. Estado
												cCodRes +" - "+ ALLTRIM(cDescrip),;
												"", ;
												aFact[nI,2], ; //Documento
												aFact[nI,1], ; //Serie
												aFact[nI,3], ; //Cliente
												aFact[nI,4], ; //Loja
												""})  
											EndIf
										EndIf
									
									Next
								ElseIf ValType( oXMLResp:_RESPUESTA:_LISTACODIGOSRESPUESTAS) == "O"
										cCodRes := oXMLResp:_RESPUESTA:_LISTACODIGOSRESPUESTAS:TEXT	
										cDescrip := ObtColSAT('S012',cCodRes,1,4,5,120)
										aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], cCodRes +" "+ ALLTRIM(cDescrip)})	
										If cTipT == "E"
											nT := ascan(aCodEst,{|x| x[1]= cCodEst})
											If  nT > 0
												aAdd(aRetObs, {val(aCodEst[nT][2]),;
												Alltrim(aFact[nI,1]) + "-" + aFact[nI,2],;
												IIf(cMVCFDIAMB == "1", STR0004, STR0005),;//"Producción" // "Pruebas"
												dDataBase,;
												cCodEst,; //Cod. Estado
												cCodRes +" - "+ ALLTRIM(cDescrip),;
												"", ;
												aFact[nI,2], ; //Documento
												aFact[nI,1], ; //Serie
												aFact[nI,3], ; //Cliente
												aFact[nI,4], ; //Loja
												""})  
											EndIf
										EndIf
								EndIf
								/////////////LISTADESCRIPCIONESRESPUESTAS //////////////////////
								If XmlChildEx(oXMLResp:_RESPUESTA, "_LISTADESCRIPCIONESRESPUESTAS") <> Nil
									If ValType( oXMLResp:_RESPUESTA:_LISTADESCRIPCIONESRESPUESTAS) == "A" //Varios impuestos
										For nX := 1 To Len(oXMLResp:_RESPUESTA:_LISTADESCRIPCIONESRESPUESTAS)
											cDescrip := oXMLResp:_RESPUESTA:_LISTADESCRIPCIONESRESPUESTAS[nX]:TEXT	
											If cTipT == "C" // Solicitud de anulación
												aAdd(aRetObs, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], cCodRes +" "+ ALLTRIM(cDescrip)})	
											EndIf
											If cTipT == "E" 
												nT := ascan(aCodEst,{|x| x[1]= cCodEst})
												If  nT > 0
													aAdd(aRetObs, {val(aCodEst[nT][2]),;
													Alltrim(aFact[nI,1]) + "-" + aFact[nI,2],;
													IIf(cMVCFDIAMB == "1", STR0004, STR0005),;//"Producción" // "Pruebas"
													dDataBase,;
													cCodEst,; //Cod. Estado
													cDescrip,;
													"", ;
													aFact[nI,2], ; //Documento
													aFact[nI,1], ; //Serie
													aFact[nI,3], ; //Cliente
													aFact[nI,4], ; //Loja
													""})  
												EndIf
											EndIf
										
										Next
									ElseIf ValType( oXMLResp:_RESPUESTA:_LISTADESCRIPCIONESRESPUESTAS) == "O"
											cDescrip := oXMLResp:_RESPUESTA:_LISTADESCRIPCIONESRESPUESTAS:TEXT	
											If cTipT == "T" .AND. cCodEst =="000"// error msg de visual Studio
												aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], cCodEst +" "+ ALLTRIM(cDescrip)})	
											EndIf
											If cTipT == "C" // Solicitud de anulación
												aAdd(aRetObs, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], cCodRes +" "+ ALLTRIM(cDescrip)})	
											EndIf
											If cTipT == "E"
												nT := ascan(aCodEst,{|x| x[1]= cCodEst})
												aAdd(aRetObs, {iif( nT > 0, val(aCodEst[nT][2]),'0'),;
												Alltrim(aFact[nI,1]) + "-" + aFact[nI,2],;
												IIf(cMVCFDIAMB == "1", STR0004, STR0005),;//"Producción" // "Pruebas"
												dDataBase,;
												cCodEst,; //Cod. Estado
												cDescrip,;
												"", ;
												aFact[nI,2], ; //Documento
												aFact[nI,1], ; //Serie
												aFact[nI,3], ; //Cliente
												aFact[nI,4], ; //Loja
												""})  
											EndIf
									EndIf
								EndIf
							EndIf
							
						EndIf
						
						// Se eliminan archivos de la carpeta del smartclient .out, .xml y .gz
						Ferase( cRutaSMR  + cDocto )
						If File(cRutaSMR  + cDocXml)
							Ferase( cRutaSMR  + cDocXml)
						EndIf
						If File(cRutaSMR  + cDocXml + ".gz")
							Ferase( cRutaSMR  + cDocXml + ".gz")
						EndIf
					Else
						aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], STR0052})	//"000 No se generó el archivo .out del documento."
					EndIf	
				Next
				
				If len(aTrans) > 0
					IncProc(STR0039)//"Actualizando Documentos..."
					M486UPBO(aTrans)
				EndIf
				If len(aTrErr) > 0
					M486UPBO(aTrErr)
				EndIf
				// Se eliminan archivos de la carpeta del smartclient .ini
				If File(cRutaSMR  + "listaxml.ini") .AND. cTipT == "T"
					Ferase( cRutaSMR  + "listaxml.ini") //ini de solicitud transmisión 
				EndIf
				If File(cRutaSMR  + "listaxmlC.ini") .AND. cTipT == "E"
					Ferase( cRutaSMR  + "listaxmlC.ini") //ini de consulta transmisión
				EndIf
				If File(cRutaSMR  + "listaxmlA.ini") .AND. cTipT == "C"
					Ferase( cRutaSMR  + "listaxmlA.ini") // ini de solicitud de anulación 
					Ferase( cRutaSMR  + cDocto)
				EndIf
			EndIf 
		Endif
	CursorArrow()
	Else
		If cTipT == "T"
			For nI:= 1 to len(aFact)
				cDocXml := alltrim(aFact[nI][1]) + alltrim(aFact[nI][2]) +  alltrim(cEspecie) + ".xml"
				If File(cRutaSMR  + cDocXml)
					Ferase( cRutaSMR  + cDocXml) //ini de solicitud transmisión 
				EndIf
			Next
			If File(cRutaSMR  + "listaxml.ini") 
				Ferase( cRutaSMR  + "listaxml.ini") //ini de solicitud transmisión 
			EndIf
		ElseIf File(cRutaSMR  + "listaxmlC.ini") .AND. cTipT == "E"
			Ferase( cRutaSMR  + "listaxmlC.ini") //ini de consulta transmisión
		ElseIf File(cRutaSMR  + "listaxmlA.ini") .AND. cTipT == "C"
			Ferase( cRutaSMR  + "listaxmlA.ini") // ini de solicitud de anulación 
		EndIf
		lRetSal := .F.
		lRet := .F.
		
	EndIf
Return lRet

/*/{Protheus.doc} M486BOLXML
Generación de XML 
@type
@author alfredo.medrano
@since 07/10/2019
@version 1.0
@param aFact, array, Array con los documentos de los cuales se generarán los XML
@param aError, array, Array con Errores 
@return lRet, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486BOLXML(aFact,aError)
	Local nI := 0
	Local lRet := .F.
	Local aArcXML := {}
	Local nArch 
	Local cNomArc :=""
	Local cPath	:= &(SuperGetMV("MV_CFDDOCS",,"")) 
	Local cRutaSMR	:= &(SuperGetMV("MV_CFDSMAR",,""))//ruta donde reside el cliente de WS 
	Private SD2ORIG := "SD2ORIG"
	ProcRegua(len(aFact))	
	For nI := 1 to len(aFact)
		IncProc()
		lRet := CFDGerXML(cEspecie,aFact[nI,3],aFact[nI,4],aFact[nI,2],aFact[nI,1],.F.)
		aFact[nI,7] := lRet
		If !lRet // Si No se generó XML, se agrega Error a Log 			
			aAdd(aError, {aFact[nI,1],aFact[nI,2],aFact[nI,3], aFact[nI,4], STR0013  }) // "Error al Generar XML"
		Else 
			cNomArc := lower(alltrim(aFact[nI,1])+alltrim(aFact[nI,2])+alltrim(cEspecie)) 
			AADD(aArcXML,cNomArc )	
			//Copia el archivo xml del servidor a la ruta del smartclient 
			CpyS2T(cPath + cNomArc + '.xml', cRUTASMR)		
		EndIf
	Next nI	
	
	If len(aArcXML) > 0 
	 	nArch:= FCREATE(cPath + "listaxml.ini")
	 	If nArch != -1
	 		fwrite(nArch, '[XML]' + chr(13)+ Chr(10))
	 		For nI:=1 to len(aArcXML)
				fwrite(nArch, aArcXML[nI] + '.xml' + chr(13)+ Chr(10))
			Next nI
		EndIf
		fclose(nArch)
		//Copia el archivo listaxml.ini del servidor a la ruta del smartclient 
		CpyS2T(cPath + "listaxml.ini", cRUTASMR)
	EndIf
	
Return lRet

/*/{Protheus.doc} M486BOLXML
Consulta de valores SF1 / SF2 para generar el XML
@type
@author alfredo.medrano
@since 07/10/2019
@version 1.0
@param cDoc, Número de documento
@param cSerie, Serie del documento
@param cClient, Cliente 
@param cLoja, Tienda
@param cTipTab, 1- Encabezado (SF1, SF2)  2- detalle (SD1, SD2)
@return aDatos
@example
(examples)
@see (links_or_references)
/*/
Function M486BOLDAT(cDoc, cSerie, cClient, cLoja, cTipTab)
	Local cAliasRet := CriaTrab(Nil, .F.)
	Local aDatos:= {}
	Local cFecha:= ""
	Local cQuery:= ""
	Local nCount:= 0
	Local cFilTab := ""
	Local cPrefx := ""
	Local cTabF := ""
	Local cCli := ""
	Local cPreUn := ""
	Local cBActiv := ""
	Local cBProdS := ""
	Local cBCod	  := ""
	Local cBDesc  := ""
	Local cSAHCO  := ""
	Local cPic := "99999999999999999999.9999"
	Local xmlOut := ""
	
	default cTipTab := "" // '1'- encabezado, '2'- detalle 
		
	If cDoc!="" .and. cSerie!="" .and.  cClient!="" .and.  cLoja!=""
	
		If Alltrim(cEspecie) $ "NF|NDC|NCC"
			cFilTab := xFilial("SF2")
		  	cCli := "_CLIENTE"
		  	cPreUn:="_PRCVEN"
		  	If cTipTab =='1'
		  		cPrefx := "F2"
		  		cTabF := "SF2"
		  	ElseIf cTipTab =='2'
		  		cPrefx := "D2"
		  		cTabF := "SD2"
		  	EndIf
		  Else
		   cPreUn:="_VUNIT"
		   	cFilTab := xFilial("SF1")
		   	cCli := "_FORNECE"
		   	If cTipTab =='1'
		   		cPrefx := "F1"
		   		cTabF := "SF1"
		  	ElseIf cTipTab =='2'
		  		cPrefx := "D1"
		  		cTabF := "SD1"
		  	EndIf
		EndIf
		
	 	If cTipTab =='1'
	 		cQuery += "SELECT " + cPrefx + "_CODDOC, " + cPrefx + "_FECTIMB, " + cPrefx + "_HORATRM, " + cPrefx + "_VALBRUT, " + cPrefx + "_VALMERC "
		ElseIf cTipTab =='2'
			cQuery += "SELECT " + cPrefx + "_UM, " + cPrefx + "_COD, " + cPrefx + "_QUANT, " + cPrefx + cPreUn + ", " + cPrefx +"_TOTAL "
		EndIF
	    cQuery += " FROM " + RetSqlName(cTabF) + " " + cTabF 
		cQuery += " WHERE " + cTabF + "." + cPrefx + "_FILIAL = '" + cFilTab + "' "
		cQuery += "AND " + cTabF + "." + cPrefx +  cCli + " = '" + cClient + "' "
		cQuery += "AND " + cTabF + "." + cPrefx + "_LOJA = '" + cLoja + "' "
		cQuery += "AND " + cTabF + "." + cPrefx + "_DOC = '" + cDoc + "' "
		cQuery += "AND " + cTabF + "." + cPrefx + "_SERIE = '" + cSerie + "' "
		cQuery += "AND " + cTabF + ".D_E_L_E_T_ = ''"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasRet, .T., .T.)
		count to nCount
		(cAliasRet)->(dbGoTop())
		While (!(cAliasRet)->(EOF()))
			
			If cTipTab =='1'
				cFecha := Left((cAliasRet)->&(cPrefx + "_FECTIMB"),4) + "-" + Substr((cAliasRet)->&(cPrefx + "_FECTIMB"),5,2)+ "-" + Right((cAliasRet)->&(cPrefx + "_FECTIMB"),2)+ "T" + alltrim((cAliasRet)->&(cPrefx + "_HORATRM")) + iif(Len(alltrim((cAliasRet)->&(cPrefx + "_HORATRM"))) == 5, ":00.000", ".000" )
				AADD(aDatos, {(cAliasRet)->&(cPrefx + "_CODDOC"),cFecha, (cAliasRet)->&(cPrefx + "_VALBRUT"), (cAliasRet)->&(cPrefx + "_VALMERC")} )
			
			ElseIf cTipTab =='2'
				cBActiv := ALLTRIM(SM0->M0_INSC)
				If SAH->(DbSeek(xFilial("SAH") + (cAliasRet)->&(cPrefx + "_UM")))
					cSAHCO := Alltrim(SAH->AH_COD_CO)
				EndIf	
				If SB1->(DbSeek(xFilial("SB1") + (cAliasRet)->&(cPrefx +"_COD")))
					cBProdS := Alltrim(SB1->B1_PRODSAT)
					cBCod 	:= Alltrim(SB1->B1_COD)
					cBDesc 	:= Alltrim(SB1->B1_DESC)
				EndIf	
				
				xmlOut += '  <detalle>' +  chr(13) + chr(10) 
				xmlOut += '    <actividadEconomica>' + cBActiv + '</actividadEconomica>' +  chr(13) + chr(10)
				xmlOut += '    <codigoProductoSin>' + cBProdS + '</codigoProductoSin>' + chr(13) + chr(10)
				xmlOut += '    <codigoProducto>' +cBCod + '</codigoProducto>' + chr(13) + chr(10)
				xmlOut += '    <descripcion>' + cBDesc + '</descripcion>' +  chr(13) + chr(10)
				xmlOut += '    <cantidad>' + Alltrim(TRANSFORM((cAliasRet)->&(cPrefx + "_QUANT"),cPic)) + '</cantidad>' +  chr(13) + chr(10)
				xmlOut += '    <unidadMedida>' + cSAHCO + '</unidadMedida>' +  chr(13) + chr(10)
				xmlOut += '    <precioUnitario>'+ Alltrim(TRANSFORM((cAliasRet)->&(cPrefx + cPreUn),cPic)) +'</precioUnitario>' +  chr(13) + chr(10)  
				xmlOut += '    <subTotal>'+ Alltrim(TRANSFORM((cAliasRet)->&(cPrefx + "_TOTAL"),cPic)) +'</subTotal>' +  chr(13) + chr(10)
				xmlOut += '    <codigoDetalleTransaccion>1</codigoDetalleTransaccion>' +  chr(13) + chr(10)
				xmlOut += '  </detalle>' +  chr(13) + chr(10) 	
			EndIf	
		(cAliasRet)->(dbSkip())
		EndDo
		
		If cTipTab =='2'
			If !empty(xmlOut)
				AADD(aDatos, {xmlOut} )
			Else
				AADD(aDatos, {" "} )
			EndIf
		EndIf
		
		(cAliasRet)->(dbCloseArea())  
	Endif                                                                                          
return aDatos

/*/{Protheus.doc} M486UPBO
Actualiza estaus de los documentos SF1/SF2 
@type
@author alfredo.medrano
@since 07/10/2019
@version 1.0
@param aDoct, array, Array con los datos obtenidos por el webService.
@return .T.
@example
(examples)
@see (links_or_references)
/*/
Static Function M486UPBO(aDoct)
	Local aArea	:= getArea()
	Local nI := 0
	Local nT := 0
	Local nRec := ""
	default aDoct := {}
	
	For nI := 1 to len(aDoct)
		nT := ascan(aCodEst,{|x| x[1]= aDoct[nI,6]}) // Cod. Estado
		If  nT > 0
			If nTipoDoc == 0 //NCC
				cClave := aDoct[nI,1] + aDoct[nI,3] + aDoct[nI,2] + aDoct[nI,4] + aDoct[nI,5]
				dbSelectArea("SF1")
				nRec := ConsultSF(cClave, 'SF1') 
				If nRec > 0
					SF1->(dbgoto(nRec))
					If cTipT $ "T|E" // transmisión y consulta 
						RecLock("SF1",.F.)
						SF1->F1_FLFTEX := aCodEst[nT][2]
						If !Empty(aDoct[nI,7]) // El código recepción debera esta lleno para actualizar los campos
							SF1->F1_UUID := aDoct[nI,7] 
							If cTipT == "T" // solo para transmisión 
								SF1->F1_CODDOC := aDoct[nI,8] // se almacena el CUF que fue autorizado
								SF1->F1_FECTIMB  := STOD(STRTRAN(aDoct[nI,9],'-',"")) // se almacena la Fecha de transmisión
								SF1->F1_HORATRM  := aDoct[nI,10] // se almacena la Hora de transmisión
							EndIf
							If aCodEst[nT][2] $  '8'// 8 = cancelada
								SF1->F1_FECANTF := STOD(STRTRAN(aDoct[nI,9],'-',"")) // se actualiza la Fecha de Cancelación
								SF1->F1_HORACAN  := aDoct[nI,10] // se actualiza la Hora cancelación
							EndIf
						EndIf
						SF1->(MsUnlock())
						IIF(aCodEst[nT][2] == '8' .and. !Empty(aDoct[nI,7]), M486BOAUTO(cEspecie),) //8 = cancelada // fun M486BOAUTO Ejecución de rutinas estandar para movimientos de anulación 	
					ElseIf cTipT $ "C" // Anulación 
						If !Empty(aDoct[nI,7]) // El código recepción debera esta lleno para actualizar los campos
							RecLock("SF1",.F.)
						    SF1->F1_FLFTEX := aCodEst[nT][2]
							SF1->F1_UUIDC := aDoct[nI,7]
							SF1->F1_FECANTF := STOD(STRTRAN(aDoct[nI,9],'-',"")) // se almacena la Fecha de Cancelación
							SF1->F1_HORACAN  := aDoct[nI,10] // se almacena la Hora de transmisión de cancelación
							SF1->F1_CODAUT  := MV_PAR04 // Codigo motivo cancelación 
							SF1->(MsUnlock())
						EndIf
					EndIf
				EndIF
			Else //NF / NDC		
				cClave := aDoct[nI,1] + aDoct[nI,4] + aDoct[nI,5] + aDoct[nI,3] + aDoct[nI,2]
				dbSelectArea("SF2")
				nRec := ConsultSF(cClave, 'SF2') 
				If nRec > 0
					SF2->(dbgoto(nRec))
					If cTipT $ "T|E" // transmisión y consulta 
					    RecLock("SF2",.F.)
						SF2->F2_FLFTEX := aCodEst[nT][2]
						If !Empty(aDoct[nI,7]) // El código recepción debera esta lleno para actualizar los campos	
							SF2->F2_UUID := aDoct[nI,7] 
							If cTipT == "T"// solo para transmisión 
								SF2->F2_CODDOC := aDoct[nI,8] // se almacena el CUF que fue autorizado
								SF2->F2_FECTIMB  := STOD(STRTRAN(aDoct[nI,9],'-',"")) // se almacena la Fecha de transmisión
								SF2->F2_HORATRM  := aDoct[nI,10] // se almacena la Hora de transmisión
							EndIf
							If aCodEst[nT][2] $  '8'// 8 = cancelada
								SF2->F2_FECANTF := STOD(STRTRAN(aDoct[nI,9],'-',"")) // se actualiza la Fecha de Cancelación
								SF2->F2_HORACAN  := aDoct[nI,10] // se actualiza la Hora cancelación
							EndIf
						Endif
						SF2->(MsUnlock())
						IIF(aCodEst[nT][2] == '8' .and. !Empty(aDoct[nI,7]), M486BOAUTO(cEspecie),) //8 = cancelada // fun M486BOAUTO Ejecución de rutinas estandar para movimientos de anulación 	
					ElseIf cTipT $ "C" // Anulación 
						If !Empty(aDoct[nI,7]) // El código recepción debera esta lleno para actualizar los campos
							RecLock("SF2",.F.)
						    SF2->F2_FLFTEX := aCodEst[nT][2]
							SF2->F2_UUIDC := aDoct[nI,7]
							SF2->F2_FECANTF := STOD(STRTRAN(aDoct[nI,9],'-',"")) // se almacena la Fecha de Cancelación
							SF2->F2_HORACAN  := aDoct[nI,10] // se almacena la Hora de transmisión de cancelación
							SF2->F2_CODAUT  := MV_PAR04 // Codigo motivo cancelación 
							SF2->(MsUnlock())
						EndIf
					EndIf
				EndIF
			EndIf	
		EndIf
	Next nI
	RestArea(aArea)
Return .t.

/*/{Protheus.doc} ConsultSF
Consulta las tablas SF1/SF2
@type
@author alfredo.medrano
@since 07/10/2019
@version 1.0
@param cClave, datos para el filtro de las tablas. (SEEK)
@param cxAlias, Alias de la tabla (SF1/SF2).
@return nRegno, regno del registro
@example
(examples)
@see (links_or_references)
/*/
Static Function ConsultSF(cClave, cxAlias)
	Local cAliasRet := CriaTrab(Nil, .F.)
	Local cQuery := ""
	Local cSWere := ""
	Local nRegno := 0
	
	If cClave != ""
		If cxAlias == 'SF1'
			cSWere := " WHERE F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA ="
		Else
			cSWere := " WHERE F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE ="
		EndIf 
	
		cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName(cxAlias) + cSWere + "'" + cClave +"'"
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasRet, .T., .T.)
		If (cAliasRet)->(!EOF())
			nRegno := (cAliasRet)->R_E_C_N_O_ 
		EndIf
	EndIf
	(cAliasRet)->(dbCloseArea()) 
return nRegno

/*/{Protheus.doc} M486GETSIN
Obtiene datos SIN para los documentos contenidos en aDocs (Consulta estado)
@type
@author alfredo.medrano
@since 07/10/2019
@version 1.0
@param aDocs, array, Array con los datos del documento a consultar
@param aRetObs, array que será lledo con las observaciones generadas por la consulta.
@return .T.
@example
(examples)
@see (links_or_references)
/*/
Function M486GETSIN(aDocs, aRetObs)
	Local cRutaSMR	:= &(SuperGetMV("MV_CFDSMAR",,""))//ruta donde reside el cliente de WS 
	Local cPath	:= &(SuperGetMV("MV_CFDDOCS",,"")) 
	Local nArch := 0
	Local nI 	:= 0
	Local cNomArc:= ""
	Local cDocto := ""
	Local cDocXml:= ""
	Local aDocsC := {}
	Local aError := {}
	Local aTrans := {}
	Local cProvFE   := SuperGetMV("MV_PROVFE",,"")
	Local aRetAux	:= {}
	Private aRet := {}
	Default aRetObs := {}

	
	CURSORWAIT()
	If "VULCAN" $ cProvFE
		Return M486GETVUL(aDocs,@aRetObs)
	ElseIf ExistBlock("M486CBOL")
		aRetAux := ExecBlock("M486CBOL",.F.,.F.,{aDocs, cEspecie})
		If Len(aRetAux) > 0
			aRet := aRetAux[1]
		EndIf
		If Len(aRetAux) > 1
			aRetObs := aRetAux[2]
		EndIf
		If Len(aRetAux) > 2
			M486UPDB(aRetAux[3], cEspecie)
		EndIf
	Else
		If Len(aDocs) > 0  //aDocs se llena en funcion M486GETINF (MATA486)
			nArch:= FCREATE(cPath + "listaxmlC.ini")
			If nArch != -1
				fwrite(nArch, '[XML]' + chr(13)+ Chr(10))
				For nI:=1 to len(aDocs)
					//aDocsC {SERIE,DOC,CLIFOR,TIENDA,UUID,FILIAL,.F.,"",}
					AADD(aDocsC,{aDocs[nI,2],aDocs[nI,3],aDocs[nI,4],aDocs[nI,5],aDocs[nI,6],aDocs[nI,1],.F.,"",aDocs[nI,7]} )
					cNomArc := lower(alltrim(aDocs[nI,2]) + alltrim(aDocs[nI,3])+ alltrim(cEspecie)) 
					fwrite(nArch, alltrim(aDocs[nI,2]) + "|" +  alltrim(aDocs[nI,3]) + "|" + cNomArc + "|" + alltrim(aDocs[nI,6]) + "|" + alltrim(aDocs[nI,7]) + '|' + alltrim(aDocs[nI,8]) + '|' + alltrim(aDocs[nI,9])  + '|' + alltrim(aDocs[nI,10]) + '|' + alltrim(aDocs[nI,11])  + chr(13)+ Chr(10))
				Next nI
			EndIf
			fclose(nArch)
			//Copia el archivo listaxml.ini del servidor a la ruta del smartclient 
			CpyS2T(cPath + "listaxmlC.ini", cRUTASMR)
			
			//llena aRet
			M486XFUNBOL(aDocsC,,,"E", @aRetObs)
		EndIf
	EndIf
	CURSORARROW()
Return aRet

/*/{Protheus.doc} M486BoObs
Muestra las observaciones en una lista de texto.
@type
@author alfredo.medrano
@since 07/10/2019
@version 1.0
@param nLin, linea seleccionada
@param aRetObs, array que será lledo con las observaciones generadas por la consulta.
@param aRetoList, Objeto de la lista de texto.
@param aObs, array que contiene las observaciones obtenidas del WS
@return .T.
@example
(examples)
@see (links_or_references)
/*/
Function M486BoObs(nLin, oList, aObs)
	Local aGrlist := {}	
	Local nI := 0
	Local nReg := 0
	Local cMsg := ""
	Local lban := .T.
	Local  oDlg, oMemo, oButton
	Local cProvFE 	:= 	SuperGetMV("MV_PROVFE",,"")
	Local lM486CBOL := ExistBlock("M486CBOL")
	
	CURSORWAIT()

	If "VULCAN" $ cProvFE .or. lM486CBOL
		If Len(aObs) >= nLin
			cMsg += STR0006 + aObs[nLin,2] + chr(13)+chr(10)//"Docto   "
			cMsg += STR0007 + aObs[nLin,1] + chr(13)+chr(10)//"Serie   "
			cMsg += STR0008 + aObs[nLin,3]+ chr(13)+chr(10)//"Cliente "
			cMsg += STR0009 + aObs[nLin,4]+ chr(13)+chr(10)//"Tienda  "
			cMsg += aObs[nLin,5]
		EndIf
	Else
		If Len(oList:aArray)> 0
			nReg := Len(aObs)
			If nReg > 0 
				// DOC + SERIE + CLIENTE + TIENDA + COD. ESTADO
				cChave := oList:aArray[nLin,8] + oList:aArray[nLin,9] + oList:aArray[nLin,10] + oList:aArray[nLin,11] + oList:aArray[nLin,5]  
				nT := ascan(aObs,{|x| x[8]+x[9]+x[10]+x[11]+x[5] == cChave })
				If nT > 0
					For nI:=1 to nReg
						If aObs[nI,8]+aObs[nI,9]+aObs[nI,10]+aObs[nI,11]+aObs[nI,5] == cChave
							If lban
								cMsg += STR0006 + aObs[nI,8] + chr(13)+chr(10)//"Docto   "
								cMsg += STR0007 + aObs[nI,9] + chr(13)+chr(10)//"Serie   "
								cMsg += STR0008 + aObs[nI,10]+ chr(13)+chr(10)//"Cliente "
								cMsg += STR0009 + aObs[nI,11]+ chr(13)+chr(10)//"Tienda  "
								lban := .F.
							EndIf							
							cMsg += aObs[nI,5] + " " + aObs[nI,6] + chr(13)+chr(10)
						EndIf
					Next 
				EndIf
			Else
				cMsg := STR0010//"Sin observaciones "
			EndIf
		EndIf
	EndIf
	
	CURSORARROW()
	DEFINE MSDIALOG oDlg FROM 0,0 TO 375,440 PIXEL TITLE STR0011//'Observaciones'
	oMemo:= tMultiget():New(10,10,{|u|if(Pcount()>0,cMsg:=u,cMsg)} ,oDlg,200,150,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
	oButton := TButton():New(165, 160,STR0012,oDlg,{||oDlg:End()},30,11,,,,.T.) //"Salir"	
	ACTIVATE MSDIALOG oDlg CENTERED	
Return

/*/{Protheus.doc} m486xBoMax
obtiene la última secuencia de la tabla informada
@type
@author alfredo.medrano
@since 22/11/2019
@version 1.0
@param cCod, tabla alfanumeria 
@return nNumRet
@example
(examples)
@see (links_or_references)
/*/
Function m486xBoMax(cCod)
	Local cAliasRet := CriaTrab(Nil, .F.)
	Local cQuery := ""
	Local nNumRet := 0
	
	If cCod != ""
		cQuery := "SELECT  MAX(F3I_SEQUEN) NUMMAX FROM " + RetSqlName("F3I")  
		cQuery += " WHERE F3I_CODIGO ='" + cCod + "'"   
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasRet, .T., .T.)
		If (cAliasRet)->(!EOF())
			nNumRet := Val((cAliasRet)->NUMMAX)
		EndIf
	EndIf
	(cAliasRet)->(dbCloseArea()) 
Return nNumRet

/*/{Protheus.doc} M486XFBOLB
  Función que comunica la anulacion de documentos electrónicos SIN.
  @type
  @author Alfredo Medrano
  @since 26/11/2019
  @version 1.0
  @param N/A
  @return ${return}, ${return_description}
  @example
  (examples)
  @see (links_or_references)
  /*/
Function M486XFBOLB()
	Local cPergBC     := "MATA486G"
	Local aDocs       := {}
	Local aArea       := GetArea()
	Local aTamaho     := MsAdvSize()
	Local aIndx	      := {STR0020}   //"Factura + Serie"
	Local cIndx	      := aIndx[1]
	Local nOpc        := 0
	Local cBusca      := Space(TAMSX3("F2_LOJA")[1]+TAMSX3("F2_CLIENTE")[1]+TAMSX3("F2_DOC")[1]+TAMSX3("F2_SERIE")[1])
	Local oOkS        := LoadBitmap(GetResources(),"br_verde")//disponible para anular
	Local oNoS        := LoadBitmap(GetResources(),"br_vermelho")//Anulación Rechazada
	Local oOkP        := LoadBitmap(GetResources(),"br_pink")//Anulación Pendiente
	Local oOk	      := LoadBitmap(GetResources(),"LBOK")
	Local oNo	      := LoadBitmap(GetResources(),"LBNO")
	Local oDlgFat     := Nil
	Local bSet15	  := {|| VALGENBOL(oLbx1,oDlgFat,@nOpc,aDocs)}
	Local bSet24	  := {|| nOpc:=0, oDlgFat:End()}
	Local aButtons    := {{"S4WB011N", {|| LeyendaCB()}, STR0019, STR0019}} //"Leyenda"
	Local bDialogInit := { || EnchoiceBar(oDlgFat,bSet15,bSet24,nil,aButtons)}
	Local nX          := 0
	Local nPosLbx     := 0
	Local aFact       := {}
	Local oBoton      := Nil
	Local oBusca      := Nil
	Local oMarTodos   := Nil
	Local oDesTodos   := Nil
	Local oInvSelec   := Nil
	Local cMsgLog     := ""	
	Local aError      := {}	
	Local aTrans	  := {}							
    Local nArch 
    Local lRet		  := .T.
    Local cNomArc	  :=""
    Local aDocsA      := {}
	Local cPath		  := &(SuperGetMV("MV_CFDDOCS",,"")) 
	Local cRutaSMR	  := &(SuperGetMV("MV_CFDSMAR",,""))//ruta donde reside el cliente de WS 
	Local n 		  := 0
	Local cProvFE	  := SuperGetMV("MV_PROVFE",,"")
	private aRetObs	  := {}	
	Private aCabsSF1  := {}
	Private aCabsSF2  := {}
	Private aItensSD1 := {}
	Private aItensSD2 := {}	
		
	If nTDTras = 1 .Or. nTDTras = 4 //Factura/Boleta de Venta
		cTipo := "N"
	ElseIf nTDTras = 2 //Nota de Débito
		cTipo := "D"
	ElseIf nTDTras = 3 //Nota de Crédito
		cTipo := "C"
	EndIf
	
	If Pergunte(cPergBC,.T.)

		aDocs := M486SFANU(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04)
		
		If Len(aDocs) == 0
			Aviso(STR0014,STR0015,{STR0016})// "Anulación", "No se encontraron facturas para anular, revise los parametros de selección", {"Ok"}
			Return Nil
		Else	
			M486SX3(@aCabsSF1, @aCabsSF2, @aItensSD1, @aItensSD2)
			DEFINE MSDIALOG oDlgFat FROM aTamaho[1],aTamaho[2] TO aTamaho[6],aTamaho[5] TITLE STR0017 PIXEL   //"Anulacción de Facturas"
		
			@ c(30),c(05) MSCOMBOBOX oIndx VAR cIndx ITEMS aIndx SIZE c(90),c(10) PIXEL OF oDlgFat
			@ c(30),c(98) BUTTON oBoton PROMPT STR0018 SIZE c(35),c(10) ; //"Buscar"
					 ACTION (oLbx1:nAT := M486BusBol(oLbx1,aDocs,cBusca,oIndx:nAT), ;
							oLbx1:bLine := {|| {If(aDocs[oLbx1:nAt,11] == "6",oOkS,If(aDocs[oLbx1:nAt,11]=="9",oNoS,oOkP)),If(aDocs[oLbx1:nAt,2],oOk,oNo),aDocs[oLbx1:nAt,3],aDocs[oLbx1:nAt,4],;
							aDocs[oLbx1:nAt,5],aDocs[oLbx1:nAt,6],aDocs[oLbx1:nAt,7],aDocs[oLbx1:nAt,8],aDocs[oLbx1:nAt,9]}},;
							oLbx1:SetFocus()) PIXEL OF oDlgFat
			@ c(42),c(05)  MSGET oBusca VAR cBusca PICTURE "@!" SIZE c(130),c(10) PIXEL  OF oDlgFat
			@ c(58),c(05)  LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER ;
							OemToAnsi(""),;     //Status
							OemToAnsi(""),;     //Check
							STR0007,;           //serie
							STR0021,;    		//Documento
							STR0022,;			//Fecha de emisión
							STR0023,;			//Fecha de autorización (SUNAT)
							STR0009,;	        //"Tienda"
							STR0008,;	        //"Cliente"
							STR0024;	        //"Nombre"   
			          SIZE aTamaho[3] - 25,IIf(aTamaho[6]>700,(aTamaho[4] * .775)-25, IIf(aTamaho[6]<500,aTamaho[4] * .6,aTamaho[4] * .7)) OF oDlgFat ; //aTamaho[6] * .875
			          PIXEL ON DBLCLICK ( IIf(aDocs[oLbx1:nAt,1] ;			          
			          .And. (IIf(aDocs[oLbx1:nAt,10]$"NF|NDC",MaCanDelF2("SF2",aDocs[oLbx1:nAt,12],,,,aDocs[oLbx1:nAt,13]),LxMaCanDelF1(aDocs[oLbx1:nAt,12],,,,,,.F.,aDocs[oLbx1:nAt,13]))), ;
			          (M486MrcBol(oLbx1,@aDocs,@oDlgFat),oLbx1:nColPos:= 1,oLbx1:Refresh()), ) ) NOSCROLL
			oLbx1:SetArray(aDocs)
			oLbx1:bLine := {|| {If(aDocs[oLbx1:nAt,11] == "6",oOkS,If(aDocs[oLbx1:nAt,11]=="9",oNoS,oOkP)),If(aDocs[oLbx1:nAt,2],oOk,oNo),aDocs[oLbx1:nAt,3],aDocs[oLbx1:nAt,4],;
							aDocs[oLbx1:nAt,5],aDocs[oLbx1:nAt,6],aDocs[oLbx1:nAt,7],aDocs[oLbx1:nAt,8],aDocs[oLbx1:nAt,9]}}
			oLbx1:Refresh()
		
			@ aTamaho[4] * .953,c(005) BUTTON oMarTodos PROMPT STR0025 SIZE c(45),c(10) ACTION M486MrcBol( oLbx1 , @aDocs , @oDlgFat , "M" ) PIXEL OF oDlgFat //aTamaho[4] * .92 //"Marcar Todos"
			@ aTamaho[4] * .953,c(055) BUTTON oDesTodos PROMPT STR0026 SIZE c(45),c(10) ACTION M486MrcBol( oLbx1 , @aDocs , @oDlgFat , "D" ) PIXEL OF oDlgFat //"Desmarcar Todos"
			@ aTamaho[4] * .953,c(110) BUTTON oInvSelec PROMPT STR0027 SIZE c(45),c(10) ACTION M486MrcBol( oLbx1 , @aDocs , @oDlgFat , "I" ) PIXEL OF oDlgFat //"Invierte selección"
		
			ACTIVATE MSDIALOG oDlgFat ON INIT Eval(bDialogInit) CENTERED
		
			CursorWait()
		
			If  nOpc == 1
				If "VULCAN" $ cProvFE
					nTotDoc := Len(aDocs)
					For nX := 1 To nTotDoc
						If aDocs[nX][2] //Seleccionado
							VulcanCaIn(aDocs[nX][17],ALLTRIM(MV_PAR04), @aError, @aTrans, aDocs[nX][14],aDocs[nX][4], aDocs[nX][3], aDocs[nX][8], aDocs[nX][7],cESpecie)
						EndIf
					Next nX
				Else
					nArch:= FCREATE(cPath + "listaxmlA.ini")
					If nArch != -1
						fwrite(nArch, '[XML]' + chr(13)+ Chr(10))
						nTotDoc := Len(aDocs)
						For nX := 1 To nTotDoc
							If aDocs[nX][2] //Seleccionado
								aAdd(aFact,{aDocs[nX][3], aDocs[nX][4], aDocs[nX][7], aDocs[nX][8], aDocs[nX][5], aDocs[nX][14], .F., ""})
								AADD(aDocsA,{aDocs[nX,3],aDocs[nX,4],aDocs[nX,8],aDocs[nX,7],aDocs[nX,16],aDocs[nX,14],.F.,"",} ) 
								fwrite(nArch, alltrim(aDocs[nX,3]) + "|" +  alltrim(aDocs[nX,4]) + "|" + alltrim(aDocs[nX,15]) + "|" + alltrim(aDocs[nX,16]) + "|" + alltrim(aDocs[nX,17]) + "|" + alltrim(MV_PAR04) + "|" + alltrim(aDocs[nX,18]) + chr(13)+ Chr(10))
							EndIf
						Next nX		
					EndIf
					fclose(nArch)
					//Copia el archivo listaxml.ini del servidor a la ruta del smartclient 
					CpyS2T(cPath + "listaxmlA.ini", cRUTASMR)
					//ejecuta .exe para consumir servicios web de anulación
					Processa({|lEnd| lRet := M486XFUNBOL(aDocsA,@aError,@aTrans,"C", @aRetObs)},STR0037) //"Transmitiendo Documentos..."	
				EndIf
			EndIf
			
			If Len(aError) > 0 .And. Len(aTrans) <> Len(aError)
				cMsgLog := STR0028  + cCRLF + STR0029 // "Ocurrieron inconvenientes al momento de solicitud de anulación" // "¿Desea visualizar log de anulación?"
			ElseIf Len(aError) > 0 .And. Len(aTrans) == Len(aError)
				cMsgLog := STR0030 + cCRLF + STR0029// "Solicitud de anulación exitosa"  // "¿Desea visualizar log de anulación?"
			EndIf
			
			nDetalle := Len(aRetObs)
			If nDetalle > 0
				for n:= 1 to nDetalle
					AADD(aError,{aRetObs[n][1], aRetObs[n][2], aRetObs[n][3], aRetObs[n][4], aRetObs[n][5]})
				next
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
			DeleteObject(oOkP)
		
			CursorArrow()
			bFiltraBrw := {|| FilBrowse(cAliasB,@aIndArqE,@cFiltro) }
			Eval(bFiltraBrw)	

			CursorArrow()
			RestArea(aArea)		
		EndIf
	EndIf
Return

/*/{Protheus.doc} VALGENBOL
//Valida que hayan sido seleccionado al menos un documento para anular.
@author Alfredo Medrano
@since 26/11/2019
@version 1.0
@return Nil
@type function
/*/
Static Function VALGENBOL(oLbx1, oDlgFat, nOpc, aItems)
	Local lRet  := .F.
	Local nPos  := 0
	
	nPos := aScan(aItems, {|aVal| aVal[2] == .T.} )
	If  nPos>0
		lRet := .T.
		nOpc := 1
		oDlgFat:End()
	Else
		Aviso(STR0017, STR0031 ,{STR0016}) //"Anulación de Facturas" //"Es necesario selecionar al menos una factura." //"Ok"
	EndIf
Return lRet

/*/{Protheus.doc} M486SFANU
//Carga datos a ser mostrados para anulaciónd e documentos electrónicos.
@author Alfredo Medrano
@since 26/11/2019
@version 1.0
@return Nil
@type function
/*/
Static Function M486SFANU(cSerie, cDocIni, cDocFin, cMotivo)
	Local cAliasTmp := GetNextAlias() 
	Local cEsp      := ""
	Local cCampos   := ""
	Local cTablas   := ""
	Local cCond     := ""
	Local cCondFB   := ""
	Local cOrder    := ""
	Local aFacturas := {}
	Local nReg 		:= 0
	Local cRutina   := ""

	If nTDTras == 1 .Or. nTDTras == 2 .Or. nTDTras == 4 //Factura de Venta - Nota de Débito
		cRutina := "MATA467N|MATA460"
		If nTDTras == 1 //Factura/
			cEsp := "NF"
		ElseIf nTDTras == 2 //nota de débito
			cEsp := "NDC"
			cRutina := "MATA465N"
		EndIf
		cCampos	:= "% SF2.F2_FILIAL FILIAL, SF2.F2_CLIENTE CLIENTE, SF2.F2_LOJA LOJA, SF2.F2_DOC DOC, SF2.F2_SERIE SERIE, SF2.F2_EMISSAO EMISSAO, SF2.F2_FECTIMB FECHATRANS, F2_TPDOC TIPDOC, "
		cCampos	+= "  SF2.F2_FECANTF FECHCANCEL, SA1.A1_NOME, SF2.F2_FLFTEX STATUS, SF2.F2_ESPECIE ESPECIE, SF2.R_E_C_N_O_ SFRECNO, F2_UUIDC IDANULA , F2_UUID IDTRANS, F2_CODDOC CUF, F2_NUMAUT NUMAUT %"
		cTablas := "% " + RetSqlName("SF2") + " SF2, " + RetSqlName("SA1") + " SA1 %"
		cCond	:= "% SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
		cCond	+= " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
		cCond	+= " AND SF2.F2_CLIENTE = SA1.A1_COD"
		cCond	+= " AND SF2.F2_LOJA = SA1.A1_LOJA"
		cCond	+= " AND SF2.F2_ESPECIE = '" + cEsp + "'"
		cCond	+= " AND SF2.F2_SERIE = '" + cSerie + "'"
		cCond	+= " AND SF2.F2_DOC >= '" + cDocIni + "'"
		cCond	+= " AND SF2.F2_DOC <= '" + cDocFin + "'"
		cCond	+= " AND SF2.F2_FLFTEX  IN ('6','7') "
		cCond	+= " AND SF2.D_E_L_E_T_  = ' ' "
		cCond	+= " AND SA1.D_E_L_E_T_  = ' ' %"
		cOrder 	:= "% SF2.F2_SERIE, SF2.F2_DOC %"
	ElseIf nTDTras == 3 //Nota de Crédito
		cEsp    := "NCC"
		cRutina := "MATA465N"
		cCampos	:= "% SF1.F1_FILIAL FILIAL, SF1.F1_FORNECE CLIENTE, SF1.F1_LOJA LOJA, SF1.F1_DOC DOC, SF1.F1_SERIE SERIE, SF1.F1_EMISSAO EMISSAO, SF1.F1_FECTIMB FECHATRANS,F1_TIPNOTA TIPDOC, "
		cCampos	+= "  SF1.F1_FECANTF FECHCANCEL, SA1.A1_NOME, SF1.F1_FLFTEX STATUS, SF1.F1_ESPECIE ESPECIE, SF1.R_E_C_N_O_ SFRECNO, F1_UUIDC IDANULA, F1_UUID IDTRANS, F1_CODDOC CUF, F1_NUMAUT NUMAUT  %"
		cTablas := "% " + RetSqlName("SF1") + " SF1, " + RetSqlName("SA1") + " SA1 %"
		cCond	:= "% SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
		cCond	+= " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
		cCond	+= " AND SF1.F1_FORNECE = SA1.A1_COD"
		cCond	+= " AND SF1.F1_LOJA = SA1.A1_LOJA"
		cCond	+= " AND SF1.F1_ESPECIE = '" + cEsp + "'"
		cCond	+= " AND SF1.F1_SERIE = '" + cSerie + "'"
		cCond	+= " AND SF1.F1_DOC >= '" + cDocIni + "'"
		cCond	+= " AND SF1.F1_DOC <= '" + cDocFin + "'"
		cCond	+= " AND SF1.F1_FLFTEX  IN ('6','7') "
		cCond	+= " AND SF1.D_E_L_E_T_  = ' ' "
		cCond	+= " AND SA1.D_E_L_E_T_  = ' ' %"
		cOrder 	:= "% SF1.F1_SERIE, SF1.F1_DOC %"		
	EndIf

	BeginSql alias cAliasTmp
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		ORDER BY %exp:cOrder%
	EndSql
	
	TCSetField(cAliasTmp,"EMISSAO","D")
	TCSetField(cAliasTmp,"FECHATRANS","D")

	Count to nReg
	
	If nReg > 0
		dbSelectArea(cAliasTmp)
		(cAliasTmp)->(dbGotop())
		
		While  (cAliasTmp)->(!EOF())
			aAdd(aFacturas,{(cAliasTmp)->STATUS $ "5|6|7", ;                    //[1]Status/ 9=anulacion Rechazada /6=disponible p/anulación/7=anulacion pendiente 
							.F., ;                                              //[2]Selección al cargar
			                (cAliasTmp)->SERIE, ;                               //[3]Serie
			                (cAliasTmp)->DOC, ;                                 //[4]Documento
							(cAliasTmp)->FECHATRANS, ;                          //[5]Fecha de emisión
							(cAliasTmp)->FECHCANCEL, ;                          //[6]Fecha de autorización SUNAT
							(cAliasTmp)->LOJA, ;                                //[7]Tienda
							(cAliasTmp)->CLIENTE, ;                             //[8]Cód. Cliente
							Alltrim((cAliasTmp)->A1_NOME), ;                    //[9]Nombre Cliente
							Alltrim((cAliasTmp)->ESPECIE), ;                    //[10]Especie
							(cAliasTmp)->STATUS, ;                              //[11]Status
							(cAliasTmp)->SFRECNO, ;                             //[12]RecNo
							cRutina, ;                                          //[13]Rutina
							(cAliasTmp)->FILIAL, ;                              //[14]Filial
							(cAliasTmp)->IDANULA,;                              //[15]ID de anulación
							(cAliasTmp)->IDTRANS,;                              //[16]ID de transmisión
							Iif(!Empty((cAliasTmp)->CUF),(cAliasTmp)->CUF,(cAliasTmp)->NUMAUT),;                                   //[17]CUF
							(cAliasTmp)->TIPDOC})                               //[18]Docto Sector
			(cAliasTmp)->(dbSkip())
		EndDo
		
		(cAliasTmp)->( dbCloseArea())
	EndIf
Return aFacturas

/*/{Protheus.doc} M486BUSCVE
//Valida posición de documentos para comunicado de baja.
@author Alfredo Medrano
@since 26/11/2019
@version 1.0
@return Nil
@type function
/*/
static Function M486BusBol(oLbx1,aItems,cBusca,nIndx)
	Local nPos := 0
	
	cBusca := Upper(Alltrim(cBusca))
	If  nIndx == 1    //"Factura + Serie"
		nPos := aScan(aItems, {|aVal| aVal[4] + aVal[3] = Alltrim(cBusca)} ) 
	EndIf
	If  nPos == 0
		nPos := oLbx1:nAt
	EndIf
Return nPos

/*/{Protheus.doc} M486MarcaI
//Marca el item para comunicado de baja.
@author Alfredo Medrano
@since 26/11/2019
@version 1.0
@return Nil
@type function
/*/
Static Function M486MrcBol(oLbx1,aItems,oDlgRec,cMarckTip)
	Local nI := 0
	Default cMarckTip := ""
	If Empty( cMarckTip )
		aItems[oLbx1:nAt,2]:= !aItems[oLbx1:nAt,2]
	ElseIf cMarckTip == "M"
		for nI := 1 to Len(aItems)
			If aItems[nI,10] $ "NF|NDC"
				If MaCanDelF2("SF2",aItems[nI,12],,,,aItems[nI,13])
					aItems[nI,2]:= .T.
				EndIf
			Else
				If LxMaCanDelF1(aItems[nI,12],,,,,,.F.,aItems[nI,13])
					aItems[nI,2]:= .T.
				EndIf
			EndIf
		next
	ElseIf cMarckTip == "D"
		aEval( aItems , { |x,y| aItems[y,2] := .F. } )
	ElseIf cMarckTip == "I"
		for nI := 1 to Len(aItems)
			If aItems[nI,10] $ "NF|NDC"
				If MaCanDelF2("SF2",aItems[nI,12],,,,aItems[nI,13])
					aItems[nI,2]:= !aItems[nI,2]
				EndIf
			Else
				If LxMaCanDelF1(aItems[nI,12],,,,,,.F.,aItems[nI,13])
					aItems[nI,2]:= !aItems[nI,2]
				EndIf
			EndIf
		next
	EndIf
Return Nil

/*/{Protheus.doc} Leyenda
Genera ventana con leyenda y significado de los estatus
@type function
@author Alfredo Medrano
@since 27/11/2019
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function LeyendaCB()
	BrwLegenda(STR0032,STR0019,{;//"Anulación de Documentos","Leyenda"
		            {"BR_VERMELHO",STR0033},;//"Anulación Rechazada"
		            {"BR_PINK",STR0034},;//"Anulación Pendiente de Confirmación"
		            {"BR_VERDE",STR0035};//"Disponible para Anulación"
		            })	        
Return

/*/{Protheus.doc} M486AUTOCB
//Realiza baja automatica de documentos.
@author Alfredo Medrano
@since 13/04/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function M486BOAUTO(cEsp)
	Local aArea	:= getArea()
	Local aCabs  := {}
	Local aItens := {}
	Local cFilSD := IIf(Alltrim(cEsp) $ "NF|NDC", xFilial("SD2"), xFilial("SD1"))
	Local nY     := 0
	
	aSize(aCabs, 0)
	aSize(aItens, 0)
	
	If Alltrim(cEsp) $ "NF|NDC"
		For nY := 1 to Len(aCabsSF2)
			aAdd(aCabs, {aCabsSF2[nY], &("SF2->"+aCabsSF2[nY]), Nil})
		Next nY
	
		SD2->(dbSetOrder(3)) //D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
		SD2->(dbSeek(cFilSD + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
		Do While !SD2->(Eof()) .And. cFilSD+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
			aAdd(aItens, {})
			For nY := 1 to Len(aItensSD2)
				aAdd(aItens[Len(aItens)], {aItensSD2[nY],&("SD2->"+aItensSD2[nY]), Nil})
			Next nY
			SD2->(dbSkip())
		 Enddo
	
		BeginTran()
		lMSErroAuto := .F.
		MaFisEnd()	
		
		If Alltrim(cEsp) == "NF" //Factura-Boleta de Venta
			MSExecAuto({|x,y,z,a| MATA467N(x,y,z,a)},aCabs,aItens,6) //Anulado
		ElseIf Alltrim(cEsp) == "NDC" //Nota de Débito
			MSExecAuto({|x,y,z,a| MATA465N(x,y,z,a)},aCabs,aItens,6)
		EndIF
	ElseIf Alltrim(cEsp) = "NCC"
		For nY := 1 to Len(aCabsSF1)
			aAdd(aCabs, {aCabsSF1[nY], &("SF1->"+aCabsSF1[nY]), Nil})
		Next nY

		SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		SD1->(dbSeek(cFilSD + SF1->F1_DOC +SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
		Do While !SD1->(Eof()) .And. cFilSD+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA==SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			aAdd(aItens, {})
			For nY := 1 to Len(aItensSD1)
				aAdd(aItens[Len(aItens)], {aItensSD1[nY],&("SD1->"+aItensSD1[nY]), Nil})
			Next nY
			SD1->(dbSkip())
		 Enddo

		// Baja por rutina automática
		BeginTran()
		lMSErroAuto := .F.
		MaFisEnd()
		MSExecAuto({|x,y,z,a| MATA465N(x,y,z,a)},aCabs,aItens,6) //Anulado	
	EndIf
	
	If lMSErroAuto
		DisarmTransaction()
	Else
		EndTran()
	EndIf
	RestArea(aArea)
Return
/*/{Protheus.doc} M486MonBo
Muestra pantalla gráfica del monitor 
@type function
@author Alf Medrano
@since 23/04/2020
@version 1.0
@param aItems, array, (Array con los items que serán mostrados en el monitor)
@param aDocs, array, (Array original con los datos de los documentos a consultar)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486MonBo(aItems,aDocs,aObs )
Local cProvFE  := SuperGetMV("MV_PROVFE",,"")
Local lM486CBOL := ExistBlock("M486CBOL")

	Local oDlg, oList, oButton0, oButton1, oButton2
	default aObs := {}
	DEFINE MSDIALOG oDlg FROM 0,0 TO 347,958 PIXEL TITLE STR0051 //Monitor

	If "VULCAN" $ cProvFE .or. lM486CBOL
		@ 01,01 LISTBOX oList FIELDS;
		HEADER "", STR0040, STR0046 , STR0044 , strtran(STR0055,":", "") ; //Documento  //"Cod. Estado" //Mensaje //CUF 
		SIZE 480,130 OF oDlg PIXEL			

		oList:SetArray(aItems)
		If len(aItems) > 0
			oList:bLine := {|| {GetStatus(aItems[oList:nAt,1]),aItems[oList:nAt,2],aItems[oList:nAt,5],GStatusDes(aItems[oList:nAt,1]),aItems[oList:nAt,12]}}			
		EndIf
	Else			
		@ 01,01 LISTBOX oList FIELDS;
		HEADER "", STR0040 , STR0041 , STR0042 , STR0046 , STR0044 , STR0045 ; //Documento //Ambiente //Fch. Aut //"Cod. Estado" //Mensaje //Recomendacion 
		SIZE 480,130 OF oDlg PIXEL			

		oList:SetArray(aItems)
		If len(aItems) > 0
			oList:bLine := {|| {GetStatus(aItems[oList:nAt,1]),aItems[oList:nAt,2],aItems[oList:nAt,3],aItems[oList:nAt,4],aItems[oList:nAt,5],aItems[oList:nAt,6],aItems[oList:nAt,7]}}			
		EndIf
	EndIf

	If !("VULCAN" $ cProvFE)
		oButton0 := TButton():New(140, 338,STR0047,oDlg,{||ObtieneXML(oList:nAt,oList,aObs)},46,17,,,,.T.) //Obtener XML
	EndIf
	oButton1 := TButton():New(140, 390,STR0048,oDlg,{||M486BoObs(oList:nAt,oList,aObs)},46,17,,,,.T.) //Observaciones 	
	oButton2 := TButton():New(140, 442,STR0049,oDlg,{||oDlg:End()},33,17,,,,.T.) //"Salir"
					
	ACTIVATE MSDIALOG oDlg CENTERED
Return
/*/{Protheus.doc} GetStatus
Obtiene el icono del status de los documentos mostrados en la opción monitor
@type function
@author Alfredo Medrano
@since 23/04/2020
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

/*/{Protheus.doc} ObtieneXMl
Obtiene el xml del documento seleccionado
@type function
@author Alfredo Medrano
@since 27/04/2020
@version 1.0
@param nStatus, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
static function ObtieneXMl(nLin, oList, aObs)
	Local aGrlist := {}	
	Local nI := 0
	Local nReg := 0
	Local cMsg := ""
	Local lban := .T.
	Local  oDlg, oMemo, oButton
	Local cSchema := ""
	Local cPath		:= (getMV("MV_CFDDOCS"))
	
	CURSORWAIT()
	If Len(oList:aArray)> 0
		cFile := alltrim(oList:aArray[nLin,9]) + alltrim(oList:aArray[nLin,8]) +alltrim(cEspecie)+".xml"
		if !Empty(cFile)	
			cSchema:= fReadfile(cPath,cFile)
			cSchema := strtran(cSchema,chr(13) + chr(10), "")
		EndIf
		If !Empty(cSchema)
			DEFINE MSDIALOG oDlg FROM 0,0 TO 375,440 PIXEL TITLE STR0050 + " " + cFile//'ARchivo'
			oMemo:= tMultiget():New(10,10,{|u|if(Pcount()>0,cSchema:=u,cSchema)} ,oDlg,200,150,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
			oButton := TButton():New(165, 160,STR0049,oDlg,{||oDlg:End()},30,11,,,,.T.) //"Salir"	
			ACTIVATE MSDIALOG oDlg CENTERED	
		EndIf

	EndIf	
	CURSORARROW()
	
return
/*/{Protheus.doc} fReadfile
Lee archivo XML 
@type function
@author Alfredo MEdrano
@since 27/04/2020
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

/*/{Protheus.doc} ObtImpBol
Obtiene y suma los valimp por medio del Impuesto de cada ítem
@type function
@author Alfredo Medrano
@since 27/04/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function ObtImpBol(cDoc,cSerie,cCliente,cLoja)
Local aArea  	:= GetArea()
Local cTmp   	:= getNextAlias()
Local cValimp 	:= ""
Local nValimp	:= 0
Local cCpoCab 	:= ""

dbSelectArea("SX3")
dbSetOrder(1)//
dbSeek("SD1")
While !Eof() .and. SX3->X3_ARQUIVO == "SD1"
	If "D1_VALIMP" $ SX3->X3_CAMPO 
		cValimp += SX3->X3_campo + ","
	EndIf
	dbSkip()
EndDo
cValimp := "%"+cValimp+"%"
BeginSql alias cTmp
	SELECT %exp:cValimp% FC_TES, FB_CODIGO, FB_CPOLVRO, FB_ALIQ, FC_INCDUPL
	FROM %table:SFB% SFB INNER JOIN %table:SFC% SFC ON FB_CODIGO = FC_IMPOSTO
	INNER JOIN %table:SF4% SF4 ON SFC.FC_TES = SF4.F4_CODIGO INNER JOIN %table:SD1% SD1 ON SFC.FC_TES = SD1.D1_TES 
	WHERE FB_FILIAL = %exp:xfilial("SFB")%
		AND SD1.D1_FILIAL = %exp:xfilial("SD1")%
		AND FC_FILIAL = %exp:xfilial("SFC")%
		AND F4_FILIAL = %exp:xfilial("SF4")%
		AND SD1.D1_DOC =  %exp:cDoc%
		AND SD1.D1_SERIE =  %exp:cSerie%
		AND SD1.D1_FORNECE = %exp:cCliente%
		AND SD1.D1_LOJA = %exp:cLoja%
		AND SD1.%notDel%
		AND SFC.%notDel%
		AND SFB.%notDel%
		AND SF4.%notDel%	
EndSql

dbSelectArea(cTmp)
(cTmp)->(DbGoTop())
While (!(cTmp)->(EOF()))
	cCpoCab  := 'D1_VALIMP'+ (cTmp)->FB_CPOLVRO
	nValimp += (cTmp)->(&cCpoCab)
	dbSkip()
EndDo 
(cTmp)->(dbCloseArea())                          
RestArea(aArea)
Return nValimp

/*/{Protheus.doc} VulcanTkn
Realiza la solicitud del token para los webservices de Vulcan
@type function
@author raul.medina
@since 10/2021
@version 1.0
*/

Function VulcanTkn()
Local lRest			:= .F.
Local cURL			:= SuperGetMV("MV_WSRTSS",,"")
Local cMVCFDIUS  	:= SuperGetMV("MV_CFDI_US",,"")
Local cMVCFDICO   	:= SuperGetMV("MV_CFDI_CO",,"")
Local aHeader		:= {}
Local oRest			:= Nil
Local oObj	 		:= Nil
Local cJson			:= ""
Local cToken		:= ""
Local cEndPoint		:= "/gateway/api/authenticate"

	oRest := FWRest():New(cUrl)
	aAdd(aHeader, "Content-Type: application/json")

	cJson	:= '{'
	cJson	+= 		'"username" : "' + cMVCFDIUS + '",'
	cJson	+= 		'"password" : "' + cMVCFDICO + '",'
	cJson	+= 		'"rememberMe" : "false"'
	cJson	+= '}'

	cEndPoint := ChckUrlV("authenticate", cEndPoint)
	oRest:setPath(cEndPoint)
	oRest:SetPostParams(cJson)

	lRest := oRest:Post(aHeader)

	If FWJsonDeserialize(oRest:GetResult(),@oObj)
		If oObj <> Nil
			If lRest
				If AttIsMemberOf(oObj,"id_token")
					cToken := oObj:id_token
				EndIf
			EndIf
		EndIf
	EndIF

	oRest:= Nil

Return cToken

/*/{Protheus.doc} VulcanCrIn
Crea una nueva factura de compra y venta en Vulcan
@type function
@author raul.medina
@since 10/2021
@version 1.0
@param cToken,		Caracter, 	Token para la conexión con el webservice.
@param cJson,		Caracter, 	Json con la información de la factura.
@param aError,		array, 		Arreglo con errores de la transmisión.
@param aTrans,		array, 		Arreglo con las transmisiones exitosas.
@param cFil,		Caracter, 	Filia de la factura.
@param cFactura,	Caracter, 	Número de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param cCliente,	Caracter, 	Cliente de la factura.
@param cLoja,		Caracter, 	Loja de la factura.
@param cEspecie,	Caracter, 	Especie de la factura.

*/
Function VulcanCrIn(cToken, cJson, aError, aTrans, cFil, cFactura, cSerie, cCliente, cLoja, cEspecie, cTipoFac)
Local cURL			:= SuperGetMV("MV_WSRTSS",,"")
Local aHeader		:= {}
Local oRest			:= Nil
Local oObj	 		:= Nil
Local lRest			:= .F.
Local aFieldErro	:= {}
Local nI			:= 0
Local cMsg			:= ""
Local cId			:= ""
Local cCUF			:= ""
Local cExternId		:= ""
Local cFecTim		:= ""
Local dFecTim		:= Nil
Local cStatus		:= ""
Local cEndPoint		:= ""
Local cTypeUrl		:= ""
Local cHoraTim		:= ""

DEFAULT cToken		:= ""
DEFAULT cTipoFac	:= "0"

	oRest := FWRest():New(cUrl)
	aAdd(aHeader, "Content-Type: application/json; charset=utf-8")
	aAdd(aHeader, "Authorization: Bearer " + cToken)

	Do Case
		Case AllTrim(cEspecie) $ "NF"
			If cTipoFac == "0"
				cEndPoint	:= "/msinvoice/api/integrations/create-invoice/buy-and-sell"
				cTypeUrl	:= "Compra-venta"
			ElseIf cTipoFac = "1"
				cEndPoint	:= "/msinvoice/api/integrations/create-invoice/product-reached-by-ice"
				cTypeUrl	:= "ICE"
			ElseIf cTipoFac = "2"
				cEndPoint	:= "/msinvoice/api/integrations/create-invoice/export"
				cTypeUrl	:= "export"
			EndIf
		Case AllTrim(cEspecie) $ "NCC|NDC"
			cEndPoint	:= "/msinvoice/api/integrations/create-debit-credit/external-invoice"
			cTypeUrl	:= "Credito-debito"
	EndCase

	cEndPoint := ChckUrlV(cTypeUrl, cEndPoint)
	oRest:setPath(cEndPoint)
	oRest:SetPostParams(cJson)

	lRest := oRest:Post(aHeader)

	If FWJsonDeserialize(oRest:GetResult(),@oObj)
		If oObj <> Nil
			If lRest
				If AttIsMemberOf(oObj,"CUF")
					cCUF := oObj:CUF
				EndIf

				If AttIsMemberOf(oObj,"EXTERNALID")
					cExternId := oObj:EXTERNALID
				EndIf

				If AttIsMemberOf(oObj,"ID")
					cId := oObj:ID
				EndIf

				If AttIsMemberOf(oObj,"EMISSIONDATE")
					cFecTim := Substr(oObj:EMISSIONDATE,1,10)
					cFecTim := STRTRAN(cFecTim,"-","")
					dFecTim := SToD(cFecTim)
					cHoraTim := Substr(oObj:EMISSIONDATE,12)
				EndIf

				If AttIsMemberOf(oObj,"EMISSIONTYPE")
					If oObj:EMISSIONTYPE == "ONLINE"
						cStatus := "6"
					Else
						cStatus := "4"
					EndIf
				EndIf

				//Actualización de status
				V486UPDST(cStatus, cEspecie, cCUF, dFecTim,cId,,cHoraTim)

				//Obtención del PDF.
				VulcanGPDF(cToken, cExternId, AllTrim(cSerie) + AllTrim(cFactura) + AllTrim(cEspecie), AllTrim(cEspecie))
				VulcanGXML(cToken, cExternId, AllTrim(cSerie) + AllTrim(cFactura) + AllTrim(cEspecie), AllTrim(cEspecie))

				aAdd(aTrans, {cFil,cSerie,cFactura,cCliente,cLoja, STR0055 + cCUF})
				aAdd(aError, {cSerie, cFactura, cCliente, cLoja, STR0055 + cCUF})
			Else
				If AttIsMemberOf(oObj,"FIELDERRORS")
					aFieldErro := oObj:FIELDERRORS
					For nI := 1 To Len(aFieldErro)
						aAdd(aError, {cSerie, cFactura, cCliente, cLoja, aFieldErro[nI]:FIELD + ": " + aFieldErro[nI]:MESSAGE })
					Next nI
					V486UPDST("5", cEspecie)
				Else
					If AttIsMemberOf(oObj,"TITLE")
						cMsg += oObj:TITLE + ": "
					EndIf
					If AttIsMemberOf(oObj,"DETAIL")
						cMsg += oObj:DETAIL
					ElseIf AttIsMemberOf(oObj,"ERRORKEY")
						cMsg += oObj:ERRORKEY
					ElseIf AttIsMemberOf(oObj,"MESSAGE")
						cMsg += oObj:MESSAGE
					EndIf
					If !Empty(cMsg)
						aAdd(aError, {cSerie, cFactura, cCliente, cLoja, cMsg })
					EndIf
					V486UPDST("5", cEspecie)
				EndIf
			EndIf
		EndIf
	ElseIf AttIsMemberOf(oRest,"ORESPONSEH")

		If AttIsMemberOf(oRest:ORESPONSEH, "CSTATUSCODE")
			cMsg += oRest:ORESPONSEH:CSTATUSCODE +  ": "
		EndIf

		If AttIsMemberOf(oRest:ORESPONSEH, "CREASON")
			cMsg += oRest:ORESPONSEH:CREASON
		EndIf
		If !Empty(cMsg)
			aAdd(aError, {cSerie, cFactura, cCliente, cLoja, cMsg })
		EndIf
	EndIf

	oRest:= Nil


Return 

/*/{Protheus.doc} VulcanGPDF
Permite obtener el archivo PDF de la factura en Vulcan
@type function
@author raul.medina
@since 10/2021
@version 1.0
@param cToken,string, Token para la conexión con vulcan.
@param cExternId,string, Identificador de la factura.
@param cDoc,string, nombre del archivo.
@param cEspecie, strin, especie de la factura
*/
Function VulcanGPDF(cToken, cExternId, cDoc, cEspecie)
Local cURL			:= SuperGetMV("MV_WSRTSS",,"")
Local aHeader		:= {}
Local oRest			:= Nil
Local cRespPDF		:= ""
Local cRuta			:= &(SuperGetMV("MV_CFDDOCS",,"GetSrvProfString('startpath','')+'\cfd\facturas\'"))
Local nGuardar		:= 1
Local cEndPoint		:= "/msinvoice/api/integrations/by-external-id/"
Local cQueryPar		:= ""
Local cPdfImp		:= SuperGetMV("MV_PDFIMPF",,"1")

Default cToken		:= ""
Default cExternId	:= ""
Default cDoc		:= ""

	If !Empty(cExternId)

		oRest := FWRest():New(cUrl)
		aAdd(aHeader, "Authorization: Bearer " + cToken)

		If cEspecie $ "NDC|NCC"
			cQueryPar := "?typeDocument=CREDIT_DEBIT"
		EndIf
		If cPdfImp == "2"
			cQueryPar += Iif(Empty(cQueryPar),"?","&") + "invoiceFormat=ROLL"
		EndIf
		cEndPoint := ChckUrlV("Archivo-Pdf", cEndPoint)
		//Archivo PDF 
		oRest:SetPath(cEndPoint + cExternId +"/pdf" + cQueryPar)

		If oRest:Get(aHeader)
			cRespPDF := oRest:GetResult()
			If !Empty(cRespPDF)
				fWriteLocal(cRespPDF, cRuta, cDoc + ".pdf", nGuardar)
			EndIf
		EndIf
		oRest:= Nil
	EndIf

Return

/*/{Protheus.doc} VulcanGXML
Permite obtener el archivo Xml de la factura en Vulcan
@type function
@author raul.medina
@since 11/2021
@version 1.0
@param cToken,string, Token para la conexión con vulcan.
@param cExternId,string, Identificador de la factura.
@param cDoc,string, nombre del archivo.
@param cEspecie, strin, especie de la factura
*/
Function VulcanGXML(cToken, cExternId, cDoc, cEspecie)
Local cURL			:= SuperGetMV("MV_WSRTSS",,"")
Local aHeader		:= {}
Local oRest			:= Nil
Local cRespXml		:= ""
Local cRuta			:= &(SuperGetMV("MV_CFDDOCS",,"GetSrvProfString('startpath','')+'\cfd\facturas\'"))
Local nGuardar		:= 1
Local cEndPoint		:= "/msinvoice/api/integrations/by-external-id/"
Local cQueryPar		:= ""

Default cToken		:= ""
Default cExternId	:= ""
Default cDoc		:= ""

	If !Empty(cExternId)

		oRest := FWRest():New(cUrl)
		aAdd(aHeader, "Authorization: Bearer " + cToken)

		If cEspecie $ "NDC|NCC"
			cQueryPar := "?typeDocument=CREDIT_DEBIT"
		EndIf	
		cEndPoint := ChckUrlV("Archivo-Xml", cEndPoint)
		//Archivo PDF 
		oRest:SetPath(cEndPoint+ cExternId +"/xml" + cQueryPar)

		If oRest:Get(aHeader)
			cRespXml := oRest:GetResult()
			If !Empty(cRespXml)
				fWriteLocal(cRespXml, cRuta, cDoc + ".xml", nGuardar)
			EndIf
		EndIf
		oRest:= Nil
	EndIf

Return

/*/{Protheus.doc} VulcanCaIn
Realiza la solicitud de cancelación de una factura.
@type function
@author raul.medina
@since 10/2021
@version 1.0
@param cCUF,	    string, 	Identificador de la factura. Codigo unico de facturación
@param cDesc,		string, 	Razón por la cual se realiza la cancelación de la factura.
@param aError,		array, 		Arreglo con errores de la transmisión.
@param aTrans,		array, 		Arreglo con las transmisiones exitosas.
@param cFil,		Caracter, 	Filial de la factura.
@param cFactura,	Caracter, 	Número de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param cCliente,	Caracter, 	Cliente de la factura.
@param cLoja,		Caracter, 	Loja de la factura.
@param cEspecie,	Caracter, 	Especie de la factura.
*/
Function VulcanCaIn(cCUF, cCodDesc, aError, aTrans, cFil, cFactura, cSerie, cCliente, cLoja, cEspecie)
Local cURL			:= SuperGetMV("MV_WSRTSS",,"")
Local aHeader		:= {}
Local oRest			:= Nil
Local OOBJ			:= Nil
Local cToken		:= ""
Local cJSON			:= ""
Local aFieldErro	:= {}
Local nI			:= 0
Local cMsg			:= ""
Local lOK			:= .F.
Local aArea			:= GetArea()
Local aAreaSF		:= {}
Local cEndPoint		:= ""
Local cTypeUrl		:= ""

Default cCUF		:= ""
Default cCodDesc	:= ""
Default cEspecie	:= ""


	If !Empty(cCUF)

		cToken	:= VulcanTkn()

		cJSON	:= '{'
		cJSON	+=	'"cuf": "' + AllTrim(cCUF) + '", '
		cJSON	+=	'"siatReason": "' + cCodDesc + '"'
		cJSON	+= '}'

		oRest := FWRest():New(cUrl)
		aAdd(aHeader, "Content-Type: application/json")
		aAdd(aHeader, "Authorization: Bearer " + cToken)
		If AllTrim(cEspecie) $ "NF"
			cEndPoint := "/msinvoice/api/integrations/cancel"
			cTypeUrl  := "Cancelacion"
		Else
			cEndPoint := "/msinvoice/api/integrations/cancel-create-debit"
			cTypeUrl  := "Cancelacion-credito-debito"
		EndIf

		cEndPoint := ChckUrlV(cTypeUrl, cEndPoint)
		
		oRest:SetPath(cEndPoint)
		oRest:SetPostParams(cJson)

		lRest := oRest:Post(aHeader)
	
		If FWJsonDeserialize(oRest:GetResult(),@oObj)
			If oObj <> Nil
				
				If !lRest
					If AttIsMemberOf(oObj,"FIELDERRORS")
						aFieldErro := oObj:FIELDERRORS
						For nI := 1 To Len(aFieldErro)
							aAdd(aError, {cSerie, cFactura, cCliente, cLoja, aFieldErro[nI]:FIELD + ": " + aFieldErro[nI]:MESSAGE })
						Next nI
					Else
						If AttIsMemberOf(oObj,"TITLE")
							cMsg += oObj:TITLE + ": "
						EndIf
						If AttIsMemberOf(oObj,"DETAIL")
							cMsg += oObj:DETAIL
						ElseIf AttIsMemberOf(oObj,"ERRORKEY")
							cMsg += oObj:ERRORKEY
						ElseIf AttIsMemberOf(oObj,"MESSAGE")
							cMsg += oObj:MESSAGE
						EndIf
						If !Empty(cMsg)
							aAdd(aError, {cSerie, cFactura ,cCliente, cLoja, cMsg })
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf AttIsMemberOf(oRest,"ORESPONSEH")

			If AttIsMemberOf(oRest:ORESPONSEH, "CSTATUSCODE")
				
				If oRest:ORESPONSEH:CSTATUSCODE == "200"
					If Alltrim(cEspecie) $ "NCI|NCC"
						aAreaSF := SF1->(GetArea())
						DbSelectArea("SF1")
						DbSetOrder(1)//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO 
						lOK := MsSeek(xFilial("SF1")+cFactura+cSerie+cCliente+cLoja)
					Else
						aAreaSF := SF2->(GetArea())
						DbSelectArea("SF2")
						DbSetOrder(1)//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
						lOK := MsSeek(xFilial("SF2")+cFactura+cSerie+cCliente+cLoja)
					EndIf
					If lOK
						V486UPDST("8", cEspecie,,,,dDatabase)
						M486BOAUTO(cEspecie)
					EndIf
					aAdd(aTrans, {cFil,cSerie,cFactura,cCliente,cLoja, STR0055 + cCUF + STR0056})
					aAdd(aError, {cSerie, cFactura, cCliente, cLoja, STR0055 + cCUF + STR0056})
				Else
					cMsg += oRest:ORESPONSEH:CSTATUSCODE +  ": "

					If AttIsMemberOf(oRest:ORESPONSEH, "CREASON")
						cMsg += oRest:ORESPONSEH:CREASON
					EndIf
					If !Empty(cMsg)
						aAdd(aError, {cSerie, cFactura, cCliente, cLoja, cMsg })
					EndIf
				EndIf
			EndIf
		EndIf
		oRest:= Nil
	EndIf

	If Len(aAreaSF) > 0 
		RestArea(aAreaSF)
	EndIf
	RestArea(aArea)

Return

/*/{Protheus.doc} VulcanCkIn
Verifica el estatus de la factura.
@type function
@author raul.medina
@since 10/2021
@version 1.0
@param cToken,string, Token de conexión.
@param cExternId,string, Identificador de la factura.
@param aError,Array, Identificador de la factura.
@param cFil,		Caracter, 	Filial de la factura.
@param cFactura,	Caracter, 	Número de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param cCliente,	Caracter, 	Cliente de la factura.
@param cLoja,		Caracter, 	Loja de la factura.
@param cEspecie,	Caracter, 	Especie de la factura.
@param cDesc,		Caracter, 	Descripción del estatus.
@param cFlftex,		Caracter, 	Status actual de la factura.
*/
Function VulcanCkIn(cToken, cExternId, aError, cFil, cFactura, cSerie, cCliente, cLoja, cEspecie, cDesc, cFlftex, cFechTim, cHoraTim, cId, cCUF)
Local cURL			:= SuperGetMV("MV_WSRTSS",,"")
Local aHeader		:= {}
Local oRest			:= Nil
Local oObj			:= Nil
Local cJson			:= ""
Local cMsg			:= ""
Local nI			:= 0
Local cStatus		:= ""
Local cEndPoint		:= "/msinvoice/api/integrations/invoice-status"

Default cToken		:= ""
Default cExternId	:= ""
Default aError		:= ""

	cDesc := ""
	If !Empty(cExternId)

		cJson	:= '{'
		cJson	+= 		'"externalId" : "' + cExternId + '"'
		cJson	+= '}'

		oRest := FWRest():New(cUrl)
		aAdd(aHeader, "Content-Type: application/json")
		aAdd(aHeader, "Authorization: Bearer " + cToken)

		cEndPoint := ChckUrlV("Status", cEndPoint)
		oRest:setPath(cEndPoint)
		oRest:SetPostParams(cJson)

		lRest := oRest:Post(aHeader)

		If FWJsonDeserialize(oRest:GetResult(),@oObj)
			If oObj <> Nil
				If lRest
					If AttIsMemberOf(oObj,"INVOICESTATE")
						//0=No Enviado; 1=Enviado; 4=Esperando procesamiento; 5=Rechazado; 6=Autorizado; 7=Anulación Pendiente; 8=Anulación Confirmada    
						If oObj:INVOICESTATE == "VALIDATED"
							cStatus := "6"
						Elseif oObj:INVOICESTATE == "PENDING"
							If cFlftex == "4"
								cStatus := "4"
							ElseIf cFlftex == "7"
								cStatus := "7"
							EndIf
						ElseIf oObj:INVOICESTATE == "CANCELED"
							cStatus := "8"
						ElseIf oObj:INVOICESTATE == "REJECTED"
							cStatus := "5"
						EndIf
						cDesc := oObj:INVOICESTATE
						If AttIsMemberOf(oObj,"EMISSIONDATE")
							cFechTim := Substr(oObj:EMISSIONDATE,1,10)
							cFechTim := STRTRAN(cFechTim,"-","")
							cFechTim := SToD(cFechTim)
							cHoraTim := Substr(oObj:EMISSIONDATE,12)
						EndIf
						If AttIsMemberOf(oObj,"ID")
							cId := oObj:ID
						EndIf
						If AttIsMemberOf(oObj,"CUF")
							cCUF := oObj:CUF
						EndIf
					EndIf
					aAdd(aError, {cSerie, cFactura ,cCliente, cLoja, cDesc })
				Else
					
					If AttIsMemberOf(oObj,"FIELDERRORS")
						aFieldErro := oObj:FIELDERRORS
						For nI := 1 To Len(aFieldErro)
							aAdd(aError, {cSerie, cFactura, cCliente, cLoja, aFieldErro[nI]:FIELD + ": " + aFieldErro[nI]:MESSAGE })
						Next nI
					Else
						If AttIsMemberOf(oObj,"TITLE")
							cMsg += oObj:TITLE + ": "
							cDesc := oObj:TITLE 
						EndIf
						If AttIsMemberOf(oObj,"DETAIL")
							cMsg += oObj:DETAIL
						ElseIf AttIsMemberOf(oObj,"ERRORKEY")
							cMsg += oObj:ERRORKEY
							If oObj:ERRORKEY == "INVOICE_NOT_FOUND"
								cStatus := "0"
							EndIf
						ElseIf AttIsMemberOf(oObj,"MESSAGE")
							cMsg += oObj:MESSAGE
						EndIf
						If !Empty(cMsg)
							aAdd(aError, {cSerie, cFactura ,cCliente, cLoja, cMsg })
						EndIf
					EndIf
				EndIf
			ElseIf AttIsMemberOf(oRest,"ORESPONSEH")
				If AttIsMemberOf(oRest:ORESPONSEH, "CSTATUSCODE")
					cMsg += oRest:ORESPONSEH:CSTATUSCODE +  ": "

					If AttIsMemberOf(oRest:ORESPONSEH, "CREASON")
						cMsg += oRest:ORESPONSEH:CREASON
						cDesc := oRest:ORESPONSEH:CREASON
					EndIf
					If !Empty(cMsg)
						aAdd(aError, {cSerie, cFactura, cCliente, cLoja, cMsg })
					EndIf
				EndIf
			EndIf
		EndIf
		oRest:= Nil
	EndIf

Return cStatus

/*/{Protheus.doc} M486VULFAC
Procesa las facturas
@type function
@author raul.medina
@since 10/2021
@version 1.0
@param aFact, array, Array con los documentos de los cuales se generarán los XML
@param aError, array, Array con Errores
@param aTrans,		array, 		Arreglo con las transmisiones exitosas.
@param cEspecie,	Caracter, 	Especie de la factura.
*/
Function M486VULFAC(aFact, aError, aTrans, cEspecie)
Local nI		:= 0
Local lRet		:= 0
Local cJson		:= ""
Local cToken	:= ""
Local cTipoFac	:= "0"

Default aError		:= {}
Default aTrans		:= {}
Default cEspecie	:= {}

	CposImp()
	cToken	:= VulcanTkn()

	ProcRegua(len(aFact))
	For nI := 1 to len(aFact)
		IncProc()
		cTipoFac	:= "0"
		cJson := CFDGerJSon( cEspecie, aFact[nI][3], aFact[nI][4], aFact[nI][2], aFact[nI][1], @aError, @cTipoFac )

		If !Empty(cJson)
			IncProc(STR0037) // "Transmitiendo Documentos..."
			VulcanCrIn(cToken, cJson, @aError, @aTrans,aFact[nI][6],aFact[nI][2], aFact[nI][1], aFact[nI][3], aFact[nI][4], cEspecie, cTipoFac)
		EndIf

	Next nI

Return lRet

/*/{Protheus.doc} CFDGerJSon
Función encargada de devolver el json a ser enviado
@type function
@author raul.medina
@since 10/2021
@version 1.0
@param cEspecie,	Caracter, 	Especie de la factura.
@param cCodigo,		Caracter, 	Cliente de la factura.
@param cLoja,		Caracter, 	Loja de la factura.
@param cFactura,	Caracter, 	Número de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param aError,		Array, 		Arrar de errores.
@param cTipoFac,	Caracter, 	Tipo de factura para determinar endpoint.
*/
Function CFDGerJSon( cEspecie, cCodigo, cLoja, cFatura, cSerie, aError, cTipoFac )
Local aArea		:= GetArea()
Local lOk		:= .F.
Local cJson		:= ""
Local aErrorDoc	:= {}
Local nX 		:= 0

DEFAULT cEspecie 	:= "NF"
DEFAULT cCodigo	 	:= ""
DEFAULT cLoja	 	:= ""
DEFAULT cFatura	 	:= ""
DEFAULT cSerie	 	:= ""
DEFAULT cTipoFac	:= "0"

	cEspecie := AllTrim(cEspecie)

	If cCodigo <> SA1->A1_COD .or. cLoja <> SA1->A1_LOJA
		dbSelectArea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		SA1->(MsSeek(xFilial("SA1")+cCodigo+cLoja))
	EndIf

	If cEspecie $ "NCI|NCC"
		DbSelectArea("SF1")
		DbSetOrder(1)//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO 
		lOK := MsSeek(xFilial("SF1")+cFatura+cSerie+cCodigo+cLoja)

		If lOk
			If !( Empty(SF1->F1_FLFTEX) .or. SF1->F1_FLFTEX $ "0|5|")
				lOk := .F.
			EndIf
		EndIf

		If lOk
			lOk := TimeOutFEV(@aError, SF1->F1_EMISSAO, cFatura, cSerie, cCodigo, cLoja)
		EndIf 

		If lOK
			cJson := VulJsonF1(cCodigo, cLoja, cFatura, cSerie, @aErrorDoc)
			If ExistBlock("M486EJSON")
				cJson	:= ExecBlock("M486EJSON",.F.,.F.,{cJson})
			EndIf
		EndIf

	Else
		DbSelectArea("SF2")
		DbSetOrder(1)//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		lOK := MsSeek(xFilial("SF2")+cFatura+cSerie+cCodigo+cLoja)

		If lOk
			If !(Empty(SF2->F2_FLFTEX) .or. SF2->F2_FLFTEX $ "0|5|")
				lOk := .F.
			EndIf
		EndIf 

		If lOk
			lOk := TimeOutFEV(@aError, SF2->F2_EMISSAO, cFatura, cSerie, cCodigo, cLoja)
		EndIf

		If lOK
			cJson := VulJsonF2(cCodigo, cLoja, cFatura, cSerie, @cTipoFac, @aErrorDoc)
			If ExistBlock("M486SJSON")
				cJson	:= ExecBlock("M486SJSON",.F.,.F.,{cJson})
			EndIf
		EndIf

	EndIf	

	If Len(aErrorDoc) > 0
		For nX := 1 To Len(aErrorDoc)
			aAdd(aError, {cSerie, cFatura, cCodigo, cLoja, aErrorDoc[nX] })
		Next
		cJson := ""
	EndIf	

	RestArea(aArea)

Return cJson

/*/{Protheus.doc} VulJsonF1
Crea el json de los documentos de entrada.
@type function
@author raul.medina
@since 10/2021
@version 1.0
@param cCodigo,		Caracter, 	Cliente de la factura.
@param cLoja,		Caracter, 	Loja de la factura.
@param cFactura,	Caracter, 	Número de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param aError,		Array,      Arreglo para los errores.

*/
Static Function VulJsonF1(cCodigo, cLoja, cFatura, cSerie, aError)
Local cJson		:= ""
//Local lOkItem	:= .F.
Local nItems	:= 0
Local cAlias	:= ""
Local nVlrUnit	:= 0
Local nDescUnit	:= 0
Local nDescTot	:= 0
Local nVlrTotal	:= 0
Local nFactor	:= 0
Local cNFOri	:= ""
Local cSerOri	:= ""
Local nValFact	:= 0
Local cIdEmp	:= SuperGetMV("MV_NUMSUC", , "")
Local aAuxOrig	:= {}
Local cDataAut	:= ""
Local nICEItem	:= 0
Local cSB1Act	:= ""
Local lICEaux:=.F.

DEFAULT cCodigo	 	:= ""
DEFAULT cLoja	 	:= ""
DEFAULT cFatura	 	:= ""
DEFAULT cSerie	 	:= ""

	cJson := '{ '
	

	cAlias := ItemsDoc ("SD1", aCposImpD1, cFatura, cSerie, cCodigo, cLoja)
	If !Empty(cAlias)
		cJson += '"details": ['

		While (cAlias)->(!EOF())

			If Empty(cNFOri)
				cNFOri := (cAlias)->D1_NFORI
				cSerOri	:= (cAlias)->D1_SERIORI
			EndIF

			If nItems > 0
				cJson += ','
			EndIf

			If SB1->(ColumnPos("B1_PRODACT")) > 0
				cSB1Act := GetAdvFVal("SB1","B1_PRODACT",xFilial("SB1")+(cAlias)->D1_COD,1,"")
				If cSB1Act <> "2"
					AADD(aError,STR0094 + AllTrim((cAlias)->D1_COD) + STR0095 + STR0096 )
				EndIf
			EndIf

			nVlrUnit	:= 0
			nDescUnit	:= 0
			nDescTot	:= 0
			nVlrTotal	:= 0
			nVlrAuxT	:= 0
			nFactor		:= 0

			nVlrAuxT	:= (cAlias)->D1_TOTAL
			nVlrTotal	:= (cAlias)->D1_TOTAL

			If (cAlias)->D1_VALDESC > 0
				nVlrTotal -= (cAlias)->D1_VALDESC
			EndIf

			//Verifica si hay calculo de ICE 
			nICEItem := ICEItem(cAlias,"D1")
			
			If nICEItem > 0
				lICEaux:=.T.
				nICEItem:= VALDOCDECI(lICEaux,"D1_TOTAL",SF1->F1_TIPNOTA,SF1->F1_MOEDA,nICEItem) 
				nVlrAuxT += nICEItem
				nVlrTotal += nICEItem
			EndIf

			nVlrUnit  :=VALDOCDECI(lICEaux,"D1_TOTAL",SF1->F1_TIPNOTA,SF1->F1_MOEDA,(nVlrAuxT / (cAlias)->D1_QUANT))  // Round(nVlrAuxT / (cAlias)->D1_QUANT,2) 	//Valor unitario sumando descuentos con impuestos
			If SF1->F1_MOEDA <> 1
				nVlrUnit	:=VALDOCDECI(lICEaux,"D1_TOTAL",SF1->F1_TIPNOTA,SF1->F1_MOEDA,(nVlrUnit*SF1->F1_TXMOEDA))  //Round(nVlrUnit*SF1->F1_TXMOEDA,2)
				If !((cAlias)->D1_VALDESC > 0)
					nVlrTotal 	:= (cAlias)->D1_QUANT * nVlrUnit
				else
					nVlrTotal := VALDOCDECI(lICEaux,"D1_TOTAL",SF1->F1_TIPNOTA,SF1->F1_MOEDA,(nVlrTotal*SF1->F1_TXMOEDA))  //Round(nVlrTotal*SF1->F1_TXMOEDA,2)
				EndIf
			EndIf

			If (cAlias)->D1_VALDESC > 0
				nVlrAuxT  := nVlrUnit * (cAlias)->D1_QUANT				//Valor total obtenido del precio unitatio con descuentos e impuestos.
				nDescTot  := nVlrAuxT - nVlrTotal						//Descuento total, descuento por unidad x cantidad.
				nDescUnit := nDescTot / (cAlias)->D1_QUANT				//Se obtiene el descuento por unidad con impuestos.
			EndIf

			nValFact += nVlrTotal

			cJson += 	'{'
			cJson += 	'"detailTransaction": "RETURNED",'
			cJson += 	'"quantity":' + AllTrim(Str((cAlias)->D1_QUANT)) + ','
			cJson +=	'"productCode": "' + JsonCarEsp(AllTrim((cAlias)->D1_COD)) +  '",'
			cJson += 	'"concept": "' + JsonCarEsp(AllTrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+(cAlias)->D1_COD,1,""))) + '",'
			cJson += 	'"unitPrice": ' + AllTrim(Str(nVlrUnit)) + ','
			cJson += 	'"subtotal": ' + AllTrim(Str(  VALDOCDECI(lICEaux,"D1_TOTAL",SF1->F1_TIPNOTA,SF1->F1_MOEDA,(nVlrTotal)) )) + ''  //nVlrTotal)) + ''
			If (cAlias)->D1_VALDESC > 0
				cJson +=	',"discountAmount": ' + AllTrim(Str((nDescTot))) + ''
			EndIf
			cJson += 	'}'

			nItems += 1

			(cAlias)->(dbSkip())
		End

		(cAlias)->(dbcloseArea())
		//Items ogininales
		cJson += "," + ItemOrig(cNFOri, cSerOri, cCodigo, cLoja, SF1->F1_MOEDA)

		cJson += '],'
	EndIf

	cJson +=	'"invoiceTypeId": "GENERIC",'
	cJson += 	'"branchId": ' + AllTrim(STR(cIdEmp)) + ','
	cJson +=	'"creditDebitNoteNumber":' + AllTrim(STR(Val(cFatura))) + ','
	cJson += 	'"customerCode": "' + JsonCarEsp(Alltrim(SA1->A1_COD)) + '",'
	cJson += 	'"name": "' + JsonCarEsp(Alltrim(SA1->A1_NOME)) + '",'
	If !Empty(SA1->A1_TIPDOC)
		cJson += 	'"documentNumber": ' + Alltrim(SA1->A1_CGC) + ','
		cJson += 	'"documentTypeCode": ' + SA1->A1_TIPDOC + ','
	EndIf
	If SA1->(ColumnPos("A1_CLDOCID")) > 0 .and. !Empty(SA1->A1_CLDOCID)
		cJson += '"documentComplement": "' + Alltrim(SA1->A1_CLDOCID) + '",'
	EndIf
	If !Empty(SA1->A1_EMAIL)
		cJson += 	'"emailNotification": "' + JsonCarEsp(AllTrim(SA1->A1_EMAIL)) + '",'
	EndIf
	cJson +=	'"extraCustomerAddress": "' + JsonCarEsp(Alltrim(SA1->A1_END)) + '",'
	cJson += 	'"id": "' + Alltrim(cSerie) + AllTrim(cFatura) + '",'

	//Datos de la factura originial.
	aAuxOrig := DocOrig( cNFOri, cSerOri, cCodigo, cLoja)
	If Len(aAuxOrig) == 4
		cJson +=	'"invoiceControlCode": "' +  Iif(!Empty(aAuxOrig[1]), AllTrim(aAuxOrig[1]), AllTrim(aAuxOrig[2])) + '",' //CUF
		cJson +=	'"invoiceEmissionDate": "' 
		cDataAut := Iif(!Empty(aAuxOrig[3]),aAuxOrig[3], DTOS(SF1->F1_EMISSAO))
		cJson += Substr(cDataAut,1,4) + "-" + Substr(cDataAut,5,2) + "-" + Substr(cDataAut,7,2)
		cJson += "T"
		cJson += Iif(Empty(aAuxOrig[4]) .or. Len(AllTrim(aAuxOrig[4])) < 18 ,"00:00:01.000-00:00", AllTrim(aAuxOrig[4]))
		cJson += '",' //EMIISON
	EndIf
	cJson +=	'"externalIdInvoice": "' + AllTrim(cSerOri) + AllTrim(cNFOri) + '",'
	cJson +=	'"invoiceNumber": ' + AllTrim(STR(Val(cNFOri))) //Número de Factura

	cJson += '}'

Return cJson

/*/{Protheus.doc} VulJsonF2
Crea el json de los documentos de salida.
@type function
@author raul.medina
@since 10/2021
@version 1.0
@param cCodigo,		Caracter, 	Cliente de la factura.
@param cLoja,		Caracter, 	Loja de la factura.
@param cFactura,	Caracter, 	Número de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param aError,		Array,      Arreglo para los errores.

*/
Static Function VulJsonF2(cCodigo, cLoja, cFatura, cSerie, cTipoFac, aError)
Local cJson		:= ""
//Local lOkItem	:= .F.
Local nItems	:= 0
Local cAlias	:= ""
Local nVlrUnit	:= 0
//Local nVlrUnAux := 0
Local nDescUnit	:= 0
Local nDescTot	:= 0
Local nVlrTotal	:= 0
Local nVlrAuxT	:= 0
Local nFactor	:= 0
Local cIdEmp	:= SuperGetMV("MV_NUMSUC", , "")
Local cNFOri	:= ""
Local nValICE	:= 0
Local cICEJson	:= ""
Local lICE		:= .F.
Local nValFact	:= 0
Local cSerOri	:= ""
Local nICEItem	:= ""
Local cSB1Act	:= ""
Local lExport	:= .F.

DEFAULT cCodigo	 	:= ""
DEFAULT cLoja	 	:= ""
DEFAULT cFatura	 	:= ""
DEFAULT cSerie	 	:= ""
DEFAULT cTipoFac	:= "0"

	lExport := Iif(AllTrim(SF2->F2_ESPECIE) $ "NF", ChkExport(AllTrim(SF2->F2_ESPECIE), cSerie),.F.)

	cJson := '{ '
	cJson += 	'"id": "' + Alltrim(cSerie) + AllTrim(cFatura) + '",'
	If !Empty(SA1->A1_EMAIL)
		cJson += 	'"emailNotification": "' + JsonCarEsp(AllTrim(SA1->A1_EMAIL)) + '",'
	EndIf
	cJson += 	'"branchId": ' + AllTrim(STR(cIdEmp)) + ','
	If !Empty(SA1->A1_TIPDOC)
		cJson += 	'"documentTypeCode": ' + SA1->A1_TIPDOC + ','
		cJson += 	'"documentNumber": ' + Alltrim(SA1->A1_CGC) + ','
	EndIf
	If SA1->(ColumnPos("A1_CLDOCID")) > 0 .and. !Empty(SA1->A1_CLDOCID)
		cJson += '"documentComplement": "' + Alltrim(SA1->A1_CLDOCID) + '",'
	EndIf
	cJson += 	'"customerCode": "' + JsonCarEsp(Alltrim(SA1->A1_COD)) + '",'
	cJson += 	'"name": "' + JsonCarEsp(Alltrim(SA1->A1_NOME)) + '",'
	cJson +=	'"extraCustomerAddress": "' + JsonCarEsp(Alltrim(SA1->A1_END)) + '",'
	cJson +=	'"paymentMethodType": ' + Alltrim(SF2->F2_MODCONS) + ','
	If AllTrim(SF2->F2_ESPECIE) $ "NF"
		cJson += 	'"invoiceNumber": "' + Alltrim(cFatura) + '",'
		
		If !Empty(SF2->F2_IDRGS)
			cJson +=	'"cardNumber": ' + Alltrim(SF2->F2_IDRGS) + ','
		EndIf

		If SF2->F2_MOEDA <> 1
			cJson += 	'"exchangeRate": ' + AllTrim(STR(SF2->F2_TXMOEDA)) + ','
			cJson += 	'"currencyIso": ' + AllTrim(GetAdvFVal("CTO","CTO_MOESAT",xFilial("CTO")+Strzero(SF2->F2_MOEDA,2),1,"")) + ','
		EndIf
		//Se verifica si la factura tiene ICE.
		lICE := CheckICE()

		If lExport
			cTipoFac := "2"
			If SF2->(ColumnPos("F2_PAISENT")) > 0 .and. !Empty(SF2->F2_PAISENT)
				cJson += '"countryCode": ' + AllTrim(GetAdvFVal("SYA","YA_CODERP",xFilial("SYA")+SF2->F2_PAISENT,1,"")) + ','
			else
				AADD(aError,STR0097 + "F2_PAISENT" + STR0098 )
			EndIf
			If SF2->(ColumnPos("F2_DESTPLA")) > 0 .and. !Empty(SF2->F2_DESTPLA)
				cJson += '"destinationPlace": "' + JsonCarEsp(AllTrim(SF2->F2_DESTPLA)) + '",'
			else
				AADD(aError,STR0097 + "F2_DESTPLA" + STR0098 )
			EndIf
			If SF2->(ColumnPos("F2_DESTPOR")) > 0 .and. !Empty(SF2->F2_DESTPOR)
				cJson += '"destinationPort": "' + JsonCarEsp(AllTrim(SF2->F2_DESTPOR)) + '",'
			else
				AADD(aError,STR0097 + "F2_DESTPOR" + STR0098 )
			EndIf
			If SF2->(ColumnPos("F2_INCOTER")) > 0 .and. !Empty(SF2->F2_INCOTER)
				cJson += '"incoterm": "' + AllTrim(SF2->F2_INCOTER) + '",'
				cJson += '"incotermDetail": "' + JsonCarEsp(AllTrim(GetAdvFVal("DB6","DB6_DESCR",xFilial("DB6")+SF2->F2_INCOTER,1,""))) + '",'
			else
				AADD(aError,STR0097 + "F2_INCOTER" + STR0098 )
			EndIf
		EndIf
	EndIf

	cAlias 	:= ItemsDoc ("SD2", aCposImpD2, cFatura, cSerie, cCodigo, cLoja)
	If !Empty(cAlias)
		cJson += '"details": ['

		While (cAlias)->(!EOF())

			If Empty(cNFOri) .and. AllTrim(SF2->F2_ESPECIE) $ "NDC"
				cNFOri := (cAlias)->D2_NFORI
				cSerOri	:= (cAlias)->D2_SERIORI
			EndIF

			If nItems > 0
				cJson += ','
			EndIf
			
			If SB1->(ColumnPos("B1_PRODACT")) > 0
				cSB1Act := GetAdvFVal("SB1","B1_PRODACT",xFilial("SB1")+(cAlias)->D2_COD,1,"")
				If cSB1Act <> "2"
					AADD(aError,STR0094 + AllTrim((cAlias)->D2_COD) + STR0095 + STR0096 )
				EndIf
			EndIf

			nVlrUnit	:= 0
			nDescUnit	:= 0
			nDescTot	:= 0
			nVlrTotal	:= 0
			nVlrAuxT	:= 0
			nFactor		:= 0

			nVlrTotal	:= (cAlias)->D2_TOTAL
			nVlrAuxT	:= (cAlias)->D2_TOTAL

			//Valores ICE, se verifica antes de hacer los calculos para restarlo del valor de los items.
			nValICE	:= 0
			If lICE
				cICEJson := ValICE((cAlias)->D2_TES, (cAlias)->D2_CF, (cAlias)->D2_COD, @nValICE, cAlias)
			EndIf	

			If (cAlias)->D2_DESCON > 0 .and. !lExport
				nVlrAuxT += (cAlias)->D2_DESCON 
			EndIf

			If AllTrim(SF2->F2_ESPECIE) $ "NDC"
				//Verifica si hay calculo de ICE 
				nICEItem := ICEItem(cAlias,"D2")
				If nICEItem > 0
					nVlrAuxT += nICEItem
					nVlrTotal += nICEItem
				EndIf
			EndIf

			nVlrUnit  := Round(nVlrAuxT / (cAlias)->D2_QUANT,VALDOCDECI((lICE .OR.lExport ),"D2_TOTAL",SF2->F2_TPDOC,SF2->F2_MOEDA)) 	//Valor unitario sumando descuentos con impuestos
			
			If SF2->F2_MOEDA <> 1 .and. !lExport
				nVlrUnit	:= Round(nVlrUnit*SF2->F2_TXMOEDA,VALDOCDECI((lICE .OR.lExport ),"D2_TOTAL",SF2->F2_TPDOC,SF2->F2_MOEDA))
				nVlrTotal 	:= (cAlias)->D2_QUANT * nVlrUnit
			EndIf

			If (cAlias)->D2_DESCON > 0 .and. !lExport
				If SF2->F2_MOEDA <> 1
					nVlrTotal 	:= (cAlias)->D2_QUANT * Round((cAlias)->D2_PRCVEN*SF2->F2_TXMOEDA,VALDOCDECI((lICE .OR.lExport ),"D2_TOTAL",SF2->F2_TPDOC,SF2->F2_MOEDA))
				EndIf
				
				nVlrAuxT  := nVlrUnit * (cAlias)->D2_QUANT				//Valor total obtenido del precio unitatio con descuentos e impuestos.
				nDescTot  := nVlrAuxT - nVlrTotal						//Descuento total, descuento por unidad x cantidad.
				nDescUnit := nDescTot / (cAlias)->D2_QUANT				//Se obtiene el descuento por unidad con impuestos.
			EndIf

			nValFact += nVlrTotal

			//Datos del Json correspondiente al item.
			cJson += 	'{'
			If AllTrim(SF2->F2_ESPECIE) $ "NF"
				cJson += 	'"sequence": ' + AllTrim(Str(Val((cAlias)->D2_ITEM))) + ','
				//ICE - Se agrega la parte del item correspondiente a ICE.
				If lICE
					cTipoFac := "1"
					cJson += cICEJson
				EndIf
			EndIf
			If AllTrim(SF2->F2_ESPECIE) $ "NDC"
				cJson += 	'"detailTransaction": "RETURNED",'
			EndIf
			cJson += 	'"quantity": ' + AllTrim(Str((cAlias)->D2_QUANT)) + ','
			cJson +=	'"productCode": "' + JsonCarEsp(AllTrim((cAlias)->D2_COD)) +  '",'
			cJson += 	'"concept": "' + JsonCarEsp(AllTrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+(cAlias)->D2_COD,1,""))) + '",'
			cJson += 	'"unitPrice": ' + AllTrim(Str(nVlrUnit)) + ','
			cJson += 	'"subtotal": ' + AllTrim(Str(Round(nVlrTotal,VALDOCDECI((lICE .OR.lExport ),"D2_TOTAL",SF2->F2_TPDOC,SF2->F2_MOEDA)) )) + ''
			If (cAlias)->D2_DESCON > 0 .and. !lExport
				If AllTrim(SF2->F2_ESPECIE) $ "NDC"
					cJson +=	',"discountAmount": ' + AllTrim(Str((nDescTot))) + ''
				Else
					cJson +=	',"discount": ' + AllTrim(Str((nDescUnit))) + ''
					cJson +=	',"discountAmount": ' + AllTrim(Str((nDescTot))) + ''
				EndIf
				
			EndIf

			cJson += 	'}'

			nItems += 1

			(cAlias)->(dbSkip())
		End
		
		(cAlias)->(dbcloseArea())

		If AllTrim(SF2->F2_ESPECIE) $ "NDC"
			//Items ogininales
			cJson += "," + ItemOrig(cNFOri, cSerOri, cCodigo, cLoja, SF2->F2_MOEDA)
		EndIf

		cJson += ']'
	EndIf

	If AllTrim(SF2->F2_ESPECIE) $ "NDC"
		cJson +=	','
		cJson +=	'"creditDebitNoteNumber":' + AllTrim(STR(Val(cFatura))) + ','
		cJson += 	'"invoiceTypeId": "GENERIC",'
		//Datos de la factura originial.
		aAuxOrig := DocOrig( cNFOri, cSerOri, cCodigo, cLoja)
		If Len(aAuxOrig) == 4
			cJson +=	'"invoiceControlCode": "' +  Iif(!Empty(aAuxOrig[1]), AllTrim(aAuxOrig[1]), AllTrim(aAuxOrig[2])) + '",' //CUF
			cJson +=	'"invoiceEmissionDate": "' 
			cDataAut := Iif(!Empty(aAuxOrig[3]),aAuxOrig[3], DTOS(SF2->F2_EMISSAO))
			cJson += Substr(cDataAut,1,4) + "-" + Substr(cDataAut,5,2) + "-" + Substr(cDataAut,7,2)
			cJson += "T"
			cJson += Iif(Empty(aAuxOrig[4]) .or. Len(AllTrim(aAuxOrig[4])) < 18 ,"00:00:01.000-00:00", AllTrim(aAuxOrig[4]))
			cJson += '",' //EMIISON
		EndIf
		cJson +=	'"externalIdInvoice": "' + AllTrim(cSerOri) + AllTrim(cNFOri) + '",'
		cJson +=	'"invoiceNumber": ' + AllTrim(STR(Val(cNFOri))) //Número de Factura
	EndIf

	cJson += '}'

Return cJson


/*/{Protheus.doc} CposImp
Valida los campos de impuestos en el sistema y verifica cuales existen
@type function
@author raul.medina
@since 10/2021
@version 1.0

*/
Static Function CposImp()
Local aImp 	:= {"1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
Local nI 	:= 0

	If Len(aCposImpD1) == 0 .Or. Len(aCposImpD2) == 0
		aCposImpD1 := {}
		aCposImpD2 := {}
		For nI := 1 To Len(aImp)
			If SD1->(ColumnPos("D1_VALIMP" + aImp[nI]))
				aAdd(aCposImpD1,"D1_VALIMP" + aImp[nI])
			EndIf
			If SD2->(ColumnPos("D2_VALIMP" + aImp[nI]))
				aAdd(aCposImpD2,"D2_VALIMP" + aImp[nI])
			EndIf
		Next nI
	EndIf

Return

/*/{Protheus.doc} ItemsDoc
Obtiene información de los items de la factura
@type function
@author raul.medina
@since 10/2021
@version 1.0
@param cToken,		cAlias, 	Alias para la tabla del query a ser.
@param aCpos,		Aray,	 	Campos para el query.
@param cFactura,	Caracter, 	Número de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param cCodigo,		Caracter, 	Cliente de la factura.
@param cLoja,		Caracter, 	Loja de la factura.

*/
Static Function ItemsDoc (cAlias, aCpos, cFatura, cSerie, cCodigo, cLoja)
Local cQuery 	:= ""
Local nI		:= 0
Local cAliasTmp	:= getNextAlias()
Local cQueryImp	:= "" 
Local cAliasImp	:= ""
Local cImpICE	:= SuperGetMV("MV_IMPICE",,"ICE|IC1")

	cImpICE := STRTRAN(cImpICE, "|", "','")

	cQuery := "Select"
	If cAlias == "SD1"
		cQuery += " D1_ITEM,"
		cQuery += " D1_QUANT,"
		cQuery += " D1_QTSEGUM,"
		cQuery += " D1_COD,"
		cQuery += " D1_VUNIT,"
		cQuery += " D1_TOTAL,"
		cQuery += " D1_VALDESC,"
		cQuery += " D1_TES,"
		cQuery += " D1_NFORI ,"
		cQuery += " D1_SERIORI,"
		cAliasImp := "D1"
	ElseIf cAlias == "SD2"
		cQuery += " D2_ITEM,"
		cQuery += " D2_QUANT,"
		cQuery += " D2_QTSEGUM,"
		cQuery += " D2_COD,"
		cQuery += " D2_PRCVEN,"
		cQuery += " D2_TOTAL,"
		cQuery += " D2_DESCON,"
		cquery += " D2_TES,"
		cquery += " D2_CF,"
		cQuery += " D2_NFORI,"
		cQuery += " D2_SERIORI,"
		cAliasImp := "D2"
	EndIf
	cQuery += " ("
	
	For nI := 1 To Len(aCpos)
		If nI > 1
			cQuery += "+"
		EndIf
		cQuery += aCpos[nI]
		cQueryImp += "," + aCpos[nI]
		cQueryImp += ", " + cAliasImp + "_ALQIMP" + SubStr(aCpos[nI], Len(aCpos[nI]), 1)
	Next

	cQuery += ") TOTALIMP"
	cQuery += cQueryImp
	If cAlias == "SD2"
		cQuery += ", (Select"
		cQuery += " Count(FC_IMPOSTO)"
		cQuery += " from "+RetSqlName("SFC")+ " SFC"
		cQuery += " Where FC_FILIAL = '" + xFilial("SFC") + "' "
		cQuery += " AND FC_TES = D2_TES"
		cQuery += " AND FC_IMPOSTO IN ('" + cImpICE + "')"
		cQuery += ") ICEIMP"
	EndIf
	cQuery += " from "+RetSqlName(cAlias)+ " " + cAlias + " "
	cQuery += " Where "
	If cAlias == "SD1"
		cQuery += " D1_FILIAL = '" + xFilial("SD1")
		cQuery += "' And D1_FORNECE = '" + cCodigo
		cQuery += "' And D1_LOJA = '" + cLoja
		cQuery += "' And D1_DOC = '" + cFatura
		cQuery += "' And D1_SERIE = '" + cSerie
	ElseIf cAlias == "SD2"
		cQuery += " D2_FILIAL = '" + xFilial("SD2")
		cQuery += "' And D2_CLIENTE = '" + cCodigo
		cQuery += "' And D2_LOJA = '" + cLoja
		cQuery += "' And D2_DOC = '" + cFatura
		cQuery += "' And D2_SERIE = '" + cSerie
	EndIf
	cQuery += "' AND D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	(cAliasTmp)->(dbGoTop())

Return cAliasTmp

/*/{Protheus.doc} V486UPDST
Función para realizar la actualización de los datos de la transmisión
@type function
@author raul.medina
@since 10/2021
@version 1.0
@param cStatus,		Caracter, 	Status para actualizar.
@param cEspecie,	Caracter, 	Especie de la factura.
@param cCUF,		Caracter, 	CUF de la respuesta de la transmisión.
@param dData,		Fecha, 		fecha de transmisión.

*/
Static Function V486UPDST(cStatus, cEspecie, cCUF, dData, cId, dDataCan, cHoraTim)
Local aArea		:= getArea()
Local cLlave	:= ""

Default cStatus		:= ""
Default cEspecie	:= ""
Default cCUF		:= ""
Default dData		:= Nil
Default dDataCan	:= Nil
Default cHoraTim	:= ""

	cEspecie := AllTrim(cEspecie)

	If cEspecie $ "NCI|NCC"
		RecLock("SF1",.F.)
			SF1->F1_FLFTEX := Iif(cStatus <> "0",cStatus,SF1->F1_FLFTEX )
			If !Empty(cCUF)
				SF1->F1_NUMAUT	:= cCUF
				SF1->F1_UUID	:= AllTrim(STR(cId))
				cLlave	:= SF1->(F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE)
			EndIf
			If ValType(dData) == "D"
				SF1->F1_FECTIMB := dData
			EndIf
			If !Empty(cHoraTim)
				SF1->F1_HORATRM	:= cHoraTim
			EndIf
			If ValType(dDataCan) == "D"
				SF1->F1_FECANTF := dDataCan
			EndIF
		SF1->(MsUnlock())
	Else
		RecLock("SF2",.F.)
			SF2->F2_FLFTEX := cStatus
			If cStatus == "0"
				SF2->F2_NUMAUT 	:= ""
				SF2->F2_UUID	:= ""
				SF2->F2_FECTIMB := cToD("")
				SF2->F2_HORATRM	:= ""
				cLlave	:= SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)
			EndIf
			If !Empty(cCUF)
				SF2->F2_NUMAUT 	:=  cCUF
				SF2->F2_UUID	:= AllTrim(STR(cId))
				cLlave	:= SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)
			EndIf
			If ValType(dData) == "D"
				SF2->F2_FECTIMB := dData
			EndIf
			If !Empty(cHoraTim)
				SF2->F2_HORATRM	:= cHoraTim
			EndIf
			If ValType(dDataCan) == "D"
				SF2->F2_FECANTF := dDataCan
			EndIF
		SF2->(MsUnlock())	
	EndIf
	
	//Actualización de el campo F3_NUMAUT.
	If !Empty(cLlave) .and. (!Empty(cCUF) .Or. cStatus=="0")
		SF3NUMAUT(cLlave, cCUF)
	EndIf

	RestArea(aArea)
Return

/*/{Protheus.doc} FACTONBOL
Facturación Online Bolivia
@type function
@author raul.medina
@since 11/2021
@version 1.0
@param cAlias,		Caracter, 	Alias de la tabla procesada.

*/
Function FACTONBOL(cAlias)
Local cProvFE 	:= 	SuperGetMV("MV_PROVFE",,"")
Local aError	:= {}
Local aTrans	:= {}
Local nX		:= 0
Local cSalto	:= chr(13) + chr(10)
Local cMsj		:= ""
Local aM486EBOL	:= {}
Local aFact		:= {}
Local cEspecie	:= ""

Default cAlias	:= ""

	If cProvFE == "VULCANON"
		If cAlias == "SF2" .and. AllTrim(SF2->F2_ESPECIE) $ "NF|NDC"
			If (Empty(SF2->F2_FLFTEX) .or. SF2->F2_FLFTEX == "0") .and. ChkFPTrans(AllTrim(SF2->F2_ESPECIE), SF2->F2_SERIE)
				M486VULFAC({{SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_EMISSAO,SF2->F2_FILIAL}},aError, aTrans,SF2->F2_ESPECIE)
			EndIf
		ElseIf cAlias == "SF1" .and. AllTrim(SF1->F1_ESPECIE) $ "NCC"
			If (Empty(SF1->F1_FLFTEX) .or. SF1->F1_FLFTEX == "0") .and. ChkFPTrans(AllTrim(SF1->F1_ESPECIE), SF1->F1_SERIE)
				M486VULFAC({{SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_EMISSAO,SF1->F1_FILIAL}},aError, aTrans,SF1->F1_ESPECIE)
			EndIf
		EndIf
	ElseIf ExistBlock("M486EBOL")
		If cAlias == "SF2" .and. AllTrim(SF2->F2_ESPECIE) $ "NF|NDC" .and. ChkFPTrans(AllTrim(SF2->F2_ESPECIE), SF2->F2_SERIE)
			aFact := {{SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_EMISSAO,SF2->F2_FILIAL}}
			cEspecie := SF2->F2_ESPECIE
		ElseIf cAlias == "SF1" .and. AllTrim(SF1->F1_ESPECIE) $ "NCC" .and. ChkFPTrans(AllTrim(SF1->F1_ESPECIE), SF1->F1_SERIE)
			aFact := {{SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_EMISSAO,SF1->F1_FILIAL}}
			cEspecie := SF1->F1_ESPECIE
		EndIf
		If Len(aFact) > 0
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
		EndIf
	EndIf
	If Len(aError) > 0 .and. Len(aTrans) == 0 
		For nX := 1 To Len(aError)
			cMsj += aError[nX][5] + cSalto
		Next nX
		Help( ,, STR0054 ,,cMsj  ,1, 0 )   // "Facturación Electrónica"
	EndIf

Return

/*/{Protheus.doc} TimeOutFEV
Obtiene información de los items de la factura
@type function
@author raul.medina
@since 11/2021
@version 1.0
@param aError,		Aray,	 	Array con errores de la transmisión.
@param dDateFact,	dDateFact, 	Fecha de la factura.
@param cFactura,	Caracter, 	Número de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param cCodigo,		Caracter, 	Cliente de la factura.
@param cLoja,		Caracter, 	Loja de la factura.

*/
Function TimeOutFEV(aError, dDateFact, cFactura, cSerie, cCodigo, cLoja)
Local lRet 		:= .T.
Local cTimeOut	:= SuperGetMV("MV_CFDTOUT",,"")
Local aTimeOut	:= {}
Local cTime		:= ""

Default aError		:= {}
Default dDateFact	:= Nil
Default cFactura	:= ""
Default cSerie	 	:= ""
Default cCodigo	 	:= ""
Default cLoja	 	:= ""

	//Validación de periodo inhábil.
	If !Empty(cTimeOut)
		aTimeOut := Separa(cTimeOut,"-")
		If Len(aTimeOut) == 2
			cTime := Time()
			If cTime > aTimeOut[1] .and. cTime < aTimeOut[2]
				aAdd(aError, {cSerie, cFactura, cCodigo, cLoja, cTimeOut + " " + STR0057 })
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//Validación de fechas.
	If dDateFact <> dDatabase
		aAdd(aError, {cSerie, cFactura, cCodigo, cLoja, STR0058 })
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} ChkFPTrans
Verifica si realiza transmisión on line
@type function
@author raul.medina
@since 11/2021
@version 1.0
@param cEspecie,	Caracter, 	Especie de la factura.
@param cSerie,		Caracter, 	Serie de la factura.

*/
Static Function ChkFPTrans(cEspecie, cSerie)
Local lRet 		:= .F.
Local aArea		:= getArea()
Local cSX3Combo	:= ""
Local cCombo	:= ""
Local nPos		:= 0
Local aEsp		:= {}
Local aDatosE	:= {}
Local nX		:= 0
Local cTpTrans	:= ""


	DbSelectArea("SFP")
	If SFP->(ColumnPos("FP_TPTRANS")) > 0
		// Busca pos. da descricao da especie da nota no combo da tabela SFP (1=NF;2=NCI;3=NDI;4=NCC;5=NDC)
		cSX3Combo := Alltrim(GetSX3Cache("FP_ESPECIE","X3_CBOX"))
		aEsp := StrTokArr(cSX3Combo, ";")
		For nX := 1 To Len(aEsp)
			aAdd(aDatosE,StrTokArr(aEsp[nX], "="))
		Next nX
		nPos := AScan(aDatosE,{|x|Alltrim(x[2])==cEspecie})
		cCombo := IIf(nPos>0,aDatosE[nPos][1],"")

		cTpTrans := GetAdvFVal("SFP","FP_TPTRANS",xFilial("SFP") + cFilAnt + cSerie + cCombo,5,"")

		If !Empty(cTpTrans)
			If cTpTrans == "1"
				lRet := .T.
			EndIf
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} ValICE
Información de ICE con respecto a los items.
@type function
@author raul.medina
@since 11/2021
@version 1.0
@param cTes,		Caracter, 	Tes del item de la factura.
@param cCfo,		Caracter, 	CFO del item de la factura.
@param cCodProd,	Caracter, 	producto usado en el item de la factura.
@param nValICE,		Caracter, 	Valor ICE del item de la factura.
@param cAlias,		Caracter, 	Alias de la tabla en uso.
*/
Static Function ValICE(cTes, cCfo, cCodProd, nValICE, cAlias)
Local cRet		:= ""
Local cImpICE	:= SuperGetMV("MV_IMPICE",,"ICE|IC1")
Local aArea		:= getArea()
Local nAliqSpec	:= 0
Local nAliqPer	:= 0
Local cParTar	:= ""
Local lFound	:= ""
Local cModo		:= ""
Local nAliq		:= 0
Local nMarkICE	:= 2 //2 - no tiene ICE el item, 1 - el item tiene ICE
Local lSeekSFF	:= .T.
Local cCpLib	:= ""


	If (cAlias)->ICEIMP > 0
		DbSelectArea("SFC")
		SFC->(dbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
		If SFC->(MsSeek(xFilial("SFC") + cTes))
			cParTar := GetAdvFVal("SB1","B1_PARTAR",xFilial("SB1") + cCodProd,1,"")
			While SFC->(!EOF()) .and. cTes == SFC->FC_TES
				If SFC->FC_IMPOSTO $ cImpICE
					dbSelectArea("SFF")
					SFF->(DbSetOrder(16)) //FF_FILIAL+FF_PARTAR+FF_CFO_V
					lFound := (SFF->(DbSeek(xFilial("SFF")+cParTar+cCfo)))
					If !lFound
						lFound := (SFF->(DbSeek(xFilial("SFF")+cParTar)))
						cCfo := "*"
					EndIf
					If lFound
						lSeekSFF := .T.
						While !SFF->(EOF()) .And. xFilial("SFF") == SFF->FF_FILIAL .And. cParTar == SFF->FF_PARTAR .and. lSeekSFF
							If	(dDataBase >= SFF->FF_DTDE .And. ( dDataBase <= SFF->FF_DTATE .Or. Empty(SFF->FF_DTATE) )) .And.;
									(cCfo $ "*/"+SFF->FF_CFO_C+"/"+SFF->FF_CFO_V) .And. SFC->FC_IMPOSTO == SFF->FF_IMPOSTO 
								cModo := SFF->FF_MODO
								nAliq := SFF->FF_ALIQ
								If cModo == "V"
									nAliqSpec := nAliq
								ElseIf cModo == "P"
									nAliqPer := nAliq/100
								EndIf
								lSeekSFF := .F.
								cCpLib := GetAdvFVal("SFB","FB_CPOLVRO",xFilial("SFB") + SFC->FC_IMPOSTO,1,"")
								nValICE += (cAlias)->&("D2_VALIMP"+cCpLib)
							EndIf
							SFF->(dbSkip())
						EndDo
					EndIf
				EndIf
				SFC->(dbSkip())
			Enddo
		EndIf

		cRet += '"quantityIce": ' + AllTrim(Str((cAlias)->D2_QTSEGUM)) + ','
		cRet += '"aliquotSpecify":' + AllTrim(Str(nAliqSpec)) + ','
		cRet += '"aliquotPercentage":' + AllTrim(Str(nAliqPer)) + ','
		nMarkICE := 1
	EndIf
	cRet += '"markIce":' + AllTrim(Str(nMarkICE)) + ','

	RestArea(aArea)

Return cRet

/*/{Protheus.doc} CheckICE
Se verifica si la factura tiene calculo de ICE de los impuestos
informados en el parámetro MV_IMPICE
@type function
@author raul.medina
@since 11/2021
@version 1.0
*/
Static Function CheckICE()
Local cImpICE	:= SuperGetMV("MV_IMPICE",,"ICE|IC1")
Local aImpICE	:= Separa(cImpICE,"|")
Local nX		:= 0
Local cCpLib	:= ""
Local nValICE	:= 0
Local lRet 		:= .F.

	For nX := 1 To Len(aImpICE)
		cCpLib := ""
		cCpLib := GetAdvFVal("SFB","FB_CPOLVRO",xFilial("SFB") + aImpICE[nX],1,"")
		If !Empty(cCpLib)
			nValICE += SF2->&("F2_VALIMP"+cCpLib)
		EndIf
	Next 

	If nValICE > 0
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} M486BLVPDF
Realiza la impresión del archivo PDF o envio por correo
@type function
@author raul.medina
@since 11/2021
@version 1.0
@param cEspecie,	Caracter, 	Especie de la factura.
*/

Function M486BLVPDF(cEspecie)
Local cPerg 	:= "M486PDF"
Local cSerie 	:= ""
Local cDocIni 	:= ""
Local cDocFin 	:= ""
Local nFormato 	:= 1
Local cMsg		:= ""

	If Pergunte(cPerg,.T.)
		cSerie := MV_PAR01
		cDocIni := MV_PAR02
		cDocFin := MV_PAR03
		nFormato := MV_PAR04

		cMsg := Iif(nFormato == 1, STR0064, STR0065) // STR0064 "Imprimiendo comprobantes..." - STR0065 "Enviando documentos..."
		If "VULCAN" $ SuperGetMV("MV_PROVFE",,"")
			Processa({|| M486IMPVUL(cEspecie, cSerie, cDocIni, cDocFin, nFormato)},STR0066, cMsg) // STR0066 "Espere..."
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} M486IMPVUL
Verifica si realiza transmisión on line
@type function
@author raul.medina
@since 11/2021
@version 1.0
@param cEspecie,	Caracter, 	Especie de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param cDocIni,		Caracter, 	Documento inicial.
@param cSerie,		Caracter, 	Documento final.
@param nFormato,	numérico, 	1-Imprimir PDF, 2-Enviar email.

*/
Static Function M486IMPVUL(cEspecie, cSerie, cDocIni, cDocFin, nFormato)
Local cPath 	:= &(SuperGetmv( "MV_CFDDOCS" , .F. , "'cfd\facturas\'" ))
Local cCampos	:= ""
Local cTablas	:= ""
Local cCond		:= ""
Local cOrder	:= ""
Local cAliasImp	:= getNextAlias()
Local nRegProc	:= 0
Local cNomArc	:= ""
Local lFile		:= .F.
Local cToken	:= ""
Local cDirLocal	:= GetTempPath()
Local nRet		:= 0
Local cMsg		:= ""
Local cSalto	:= chr(13) + chr(10)
Local aArea		:= getArea()
Local nPDF		:= 0
Local aFileAux	:= {}
Local aItens	:= {}
Local nFiles	:= 0
Local cEmailCli	:= ""
Local cLetFac	:= ""
Local cLetPie 	:= ""


	cPath := Replace( cPath, "\\", "\" )

	If AllTrim(cEspecie) $ "NF|NDC"
		cCampos  := "% SF2.F2_FILIAL, SF2.F2_SERIE SERIE, SF2.F2_DOC DOCUMENTO, SF2.F2_ESPECIE ESPECIE, SF2.F2_CLIENTE CLIENTE, SF2.F2_LOJA LOJA %"
		cTablas  := "% " + RetSqlName("SF2") + " SF2 %"
		cCond    := "% SF2.F2_SERIE = '"  + cSerie + "'"
		cCond    += " AND SF2.F2_DOC >= '"  + cDocIni + "'"
		cCond    += " AND SF2.F2_DOC <= '"  + cDocFin + "'"
		cCond    += " AND SF2.F2_ESPECIE = '"  + cEspecie + "'"
		cCond	 += " AND SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
		cCond	 += " AND SF2.D_E_L_E_T_  = ' ' %"
		cOrder := "% SF2.F2_FILIAL, SF2.F2_SERIE, SF2.F2_DOC %"
	ElseIf AllTrim(cEspecie) $ "NCC"
		// NOTA DE CRÉDITO
		cCampos  := "% SF1.F1_FILIAL, SF1.F1_SERIE SERIE, SF1.F1_DOC DOCUMENTO, SF1.F1_ESPECIE ESPECIE, SF1.F1_FORNECE CLIENTE, SF1.F1_LOJA LOJA %"
		cTablas  := "% " + RetSqlName("SF1") + " SF1 %"
		cCond    := "% SF1.F1_SERIE = '"  + cSerie + "'"
		cCond    += " AND SF1.F1_DOC >= '"  + cDocIni + "'"
		cCond    += " AND SF1.F1_DOC <= '"  + cDocFin + "'"
		cCond    += " AND SF1.F1_ESPECIE = '"  + cEspecie + "'"
		cCond	 += " AND SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
		cCond	 += " AND SF1.D_E_L_E_T_  = ' ' %"
		cOrder := "% SF1.F1_FILIAL, SF1.F1_SERIE, SF1.F1_DOC %"
	EndIf

	BeginSql alias cAliasImp
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		ORDER BY %exp:cOrder%
	EndSql

	Count to nRegProc

	dbSelectArea(cAliasImp)

	(cAliasImp)->(DbGoTop())
	ProcRegua(nRegProc)

	While (cAliasImp)->(!Eof())

		cNomArc := AllTrim((cAliasImp)->SERIE) +  AllTrim((cAliasImp)->DOCUMENTO) + AllTrim((cAliasImp)->ESPECIE)

		IncProc(Iif(nFormato == 1, STR0064, STR0065) + " " + AllTrim((cAliasImp)->DOCUMENTO))

		//Se verifica que exista el archivo
		lFile := file( cPath + cNomArc + ".pdf" )

		If !lFile //Si no existe el archivo se intenta obtener de nuevo.
			cToken	:= VulcanTkn()

			//Obtención de PDF y Xml.
			VulcanGPDF(cToken, AllTrim((cAliasImp)->SERIE) +  AllTrim((cAliasImp)->DOCUMENTO), cNomArc, AllTrim((cAliasImp)->ESPECIE))
			VulcanGXML(cToken, AllTrim((cAliasImp)->SERIE) +  AllTrim((cAliasImp)->DOCUMENTO), cNomArc, AllTrim((cAliasImp)->ESPECIE))

			lFile := file( cPath + cNomArc + ".pdf" )
		EndIf

		If lFile
			// Copiar archivo al cliente a carpeta temporales.
			If CpyS2T( cPath + cNomArc + ".pdf" , cDirLocal)
				If nFormato == 1
					// Se abre la aplicación para visualizar archivo PDF
					nRet:= ShellExecute("Open",cNomArc + ".pdf","",cDirLocal,1)
					If nRet <= 32
						cMsg += "Error al arbir el archivo " + cNomArc + cSalto //"Error al arbir el archivo "
					Else
						nPDF += 1
					EndIf
				ElseIf nFormato == 2
					aFileAux := {}
					aItens := {}								

					aAdd( aItens, cPath + cNomArc + ".pdf" ) //Se agrega PDF
					aAdd( aItens, cPath + cNomArc + ".xml" ) //Se agrega XML

					For nFiles := 1 To Len(aItens)
						aAdd(aFileAux, StrTran( Upper(aItens[nFiles]), Upper(GetSrvProfString('Rootpath','')))) //Se agrega PDF y XML como anexos
					Next nFiles
					cEmailCli := AllTrim(GetAdvFVal("SA1","A1_EMAIL", xFilial("SA1")  + (cAliasImp)->CLIENTE + (cAliasImp)->LOJA ,1,""))

					cLetFac := STR0077
					cLetPie := STR0078 + STR0077

					lEnvOK := EnvioMail(AllTrim(cEmailCli), aFileAux, .T., cLetFac, cLetPie)
					nPDF += 1
				EndIf
			EndIf
		Else
			If !Empty(cMsg)
				cMsg += cSalto
			EndIf
			cMsg += STR0060 + cNomArc + STR0061  //"Archivo " //" no encontrado"
		EndIf
		(cAliasImp)->(dbSkip())	
	Enddo

	If nPDF == 0 .and. Empty(cMsg)
		cMsg := STR0063 //"Documentos no encontrados"
	EndIf

	If !Empty(cMsg)
		Help( ,, STR0059 ,,cMsg  ,1, 0 )   // "Impresión de comprobantes"
	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} EnvioMail
//TODO Descrição auto-gerada.
@version 1.0
@return lógico, envío correcto?
@param cEmailC, characters, correo destinatario (cliente)
@param aAnexo, array, array de anexos
@param lNoEnvZip, logical, archivo.zip?
@param cLetFac, characters, Asuto del correo
@param cLetPie, characters, Cuerpo del correo
@type function
/*/
Static Function EnvioMail(cEmailC, aAnexo, lNoEnvZip, cLetFac, cLetPie)
Local lResult		:= .F.
Local cServer		:= GetMV("MV_RELSERV",,"" ) //Nombre de servidor de envio de E-mail utilizado en los informes.
Local cEmail		:= GetMV("MV_RELACNT",,"" ) //Cuenta a ser utilizada en el envio de E-Mail para los informes
Local cPassword		:= GetMV("MV_RELPSW",,""  ) //Contrasena de cta. de E-mail para enviar informes
Local lAuth			:= GetMv("MV_RELAUTH",,.F.)	//Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao;
Local lUseSSL		:= GetMv("MV_RELSSL",,.F.)	//Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL);
Local lTls			:= GetMV("MV_RELTLS",,.F.)	//Informe si el servidor de SMTP tiene conexion del tipo segura ( SSL/TLS ).    
Local nPort			:= GetMv("MV_SRVPORT",,0)	//Puerto de conexion con el servidor de correo
Local nErr			:= 0
Local ctrErr		:= ""
Local oMailServer	:= Nil
Local cAttach		:= ""
Local nI			:= 0
Local cMsg			:= ""
Local nX			:= 0

Default lNoEnvZip	:= .F.
	
	If Empty(cServer)
		cMsg += STR0067 + STR0068 + CHR(13) + CHR(10) //"Configure parámetro " "MV_RELSERV" 
	EndIf
	If Empty(cEmail)
		cMsg += STR0067 + STR0069 + CHR(13) + CHR(10) //"Configure parámetro " "MV_RELACNT"
	EndIf
	If Empty(cPassword)
		cMsg += STR0067 + STR0070 + CHR(13) + CHR(10) // "Configure parámetro " "MV_RELPSW"
	EndIf
	If Empty(cEmailC)
		cMsg += STR0071 + CHR(13) + CHR(10) // "Configure email del cliente."
	EndIf
	
	If !Empty(cMsg)
		ApMsgInfo(cMsg, STR0072) //"Configuración"
		Return .F.
	EndIf
	
	If !Empty(cEmailC)
		For nI:= 1 to Len(aAnexo)
			cAttach += aAnexo[nI] + "; "
		Next nI

		If !lAuth .And. !lUseSSL .And.!lTls
			CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPassword RESULT lResult
			
			If lResult 
				SEND MAIL FROM cEmail ;
				TO      	cEmailC;
				BCC     	"";
				SUBJECT 	cLetFac;
				BODY    	cLetPie;
				ATTACHMENT  cAttach  ;
				RESULT lResult

				If !lResult
					//Erro no envio do email
					GET MAIL ERROR cError
					Help(" ",1,STR0075,,cError,4,5) //
				EndIf

			Else
				//Erro na conexao com o SMTP Server
    			GET MAIL ERROR cError                                       
    			Help(" ",1,STR0075,,cError,4,5) //--- Aviso    

			EndIf

			DISCONNECT SMTP SERVER

		Else
			//Instancia o objeto do MailServer
			oMailServer:= TMailManager():New()
			oMailServer:SetUseSSL(lUseSSL)    //Obs: Apenas se servidor de e-mail utiliza autenticacao SSL para envio
			oMailServer:SetUseTLS(lTls)       //Obs: Apenas se servidor de e-mail utiliza autenticacao TLS para recebimento

			If Empty(nPort)
				oMailServer:Init("",cServer,cEmail,cPassword,0)
			Else
				oMailServer:Init("",cServer,cEmail,cPassword,0,nPort)
			EndIf
		                               
		    //Definição do timeout do servidor
			If oMailServer:SetSmtpTimeOut(120) != 0
		   		Help(" ",1,STR0073,,OemToAnsi(STR0074) ,4,5) //"Aviso" ## "Tiempo de Servidor"
		   		Return .F.
		   	EndIf
		
		   	//Conexão com servidor
		   	nErr := oMailServer:smtpConnect()
		   	If nErr <> 0
		   		cTrErr:= oMailServer:getErrorString(nErr)
		    	oMailServer:smtpDisconnect()
		    	
		    	// Intenta (varias veces) el envío a través de otra clase de conexión
		    	lResult := EnvioMail2(cServer, cEmail, cPassword, lAuth, cEmailC, cLetFac, cLetPie, aAnexo, @cTrErr)
		    	
		    	If !lResult
			   		Help(" ",1,STR0075,,ctrErr,4,5) //"Aviso"
				EndIf

				Return lResult
		   	EndIf

		   	//Autenticação com servidor smtp
		   	nErr := oMailServer:smtpAuth(cEmail, cPassword)
		   	If nErr <> 0
		    	cTrErr := OemToAnsi(STR0076) + CRLF + oMailServer:getErrorString(nErr) //*
		     	oMailServer:smtpDisconnect()

		    	// Intenta (varias veces) el envío a través de otra clase de conexión
		    	lResult := EnvioMail2(cServer, cEmail, cPassword, lAuth, cEmailC, cLetFac, cLetPie, aAnexo, @cTrErr)
		    	
		    	If !lResult
			     	Help(" ",1,STR0073,,cTrErr ,4,5)//"Aviso" ## "Autenticación con servidor smtp"
				EndIf

				Return lResult
		   	EndIf
		                               
		   	//Cria objeto da mensagem+
		   	oMessage := tMailMessage():new()
		   	oMessage:clear()
		   	oMessage:cFrom 	:= cEmail 
		   	oMessage:cTo 	:= cEmailC 
		   	oMessage:cSubject :=  cLetFac
		   	oMessage:cBody := cLetPie
		   	
		   	For nX := 1 to Len(aAnexo)
		   		
		   		oMessage:AttachFile(aAnexo[nX]) //Adiciona um anexo, nesse caso a imagem esta no root
		   		
		   		If lNoEnvZip
		   			oMessage:AddAtthTag( 'Content-Disposition: attachment; filename=' + M486RemPat(aAnexo[nX])) //Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
		   		Else
		   			oMessage:AddAttHTag("Content-ID: <" + aAnexo[nX] + ">") //Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
		   		EndIf
		   	Next nX
		                               
			//Dispara o email          
			nErr := oMessage:send(oMailServer)
			If nErr <> 0
		   		cTrErr := oMailServer:getErrorString(nErr)
		     	Help(" ",1,STR0073,,OemToAnsi(STR0075) + CRLF + cTrErr ,4,5)//"Aviso" ## "Error en el Envio del Email"
		     	oMailServer:smtpDisconnect()
		     	Return .F.
			Else
		   		lResult := .T.
		   	EndIf
		
		  	//Desconecta do servidor
		   	oMailServer:smtpDisconnect()
		EndIf
	EndIf
Return lResult

/*/{Protheus.doc} EnvioMail2
//TODO Descrição auto-gerada.
@version 1.0
@return lógico, envío correcto?
@param cMailServer, characters, dirección de servidor de correo
@param cMailConta, characters, usuario de conexión / cuenta de correo remitente
@param cMailSenha, characters, contraseña del usuario
@param lAutentica, logical, requiere autenticación?
@param cEmail, characters, correo destinatario (cliente)
@param cEMailAst, characters, asunto
@param cMensGral, characters, contenido
@param aAnexo, array, array de anexos
@param cErr, characters, (@referencia) variable para mensaje de error
@type function
/*/
Static Function EnvioMail2(cMailServer, cMailConta, cMailSenha, lAutentica, cEmail, cEMailAst, cMensGral, aAnexo, cErr)
	Local cAcAut	:= GetMV("MV_RELAUSR",,"" )		//Usuario para autenticacion en el servidor de email
	Local cPwAut 	:= GetMV("MV_RELAPSW",,""  )	//Contraseña para autenticacion en servidor de email
	Local lResult	:= .F.
	Local nIntentos	:= 0

	If lAutentica .And. Empty(cAcAut+cPwAut)
		Return lResult
	EndIf

	Do While !lResult .And. nIntentos < 11
		nIntentos++
		lResult := MailSmtpOn(cMailServer,cMailConta,cMailSenha)

		// Verifica se o E-mail necessita de Autenticacao
		If lResult .And. lAutentica
			lResult := MailAuth(cAcAut,cPwAut)
		Endif

		If lResult
			lResult := MailSend(cMailConta, {cEmail}, {" "}, {" "}, cEMailAst, cMensGral, aAnexo)
		EndIf

		If !lResult
			cErr := MailGetErr()
		EndIf

		MailSmtpOff()
	EndDo

Return lResult

/*/{Protheus.doc} EnvioMail2
//TODO Descrição auto-gerada.
@version 1.0
@param cFile, characters, archivo
@type function
/*/
Static Function M486RemPat(cFile)

	Local cFileName := ""
	
	Default cFile := ""
	
	If (rAt("\", cFile) > 0 )
	   cFileName := SubStr(cFile, rAt("\", cFile) + 1, Len(cFile))
	EndIf
	
Return cFileName

/*/{Protheus.doc} M486GETVUL
Consulta a VULCAN los documentos contenidos en aDocs (Consulta estado)
@type
@author raul.medina
@since 11/2021
@version 1.0
@param aDocs, array, Array con los datos del documento a consultar
@param aRetObs, array que será lledo con las observaciones generadas por la consulta.
@return 
/*/
Function M486GETVUL(aDocs, aRetObs)
Local aRet		:= {}
Local cToken	:= ""
Local nX		:= 0
Local aArea		:= getArea()
Local aAreaSF	:= ""
Local cStatus	:= ""
Local cDesc		:= ""
Local lOk		:= .F.
Local cFlftex	:= ""
Local cFechTim 	:= ""
Local cHoraTim 	:= ""
Local cId		:= "" 
Local cCUF		:= ""

	cToken	:= VulcanTkn()

	ProcRegua(len(aDocs))
	For nX := 1 To Len(aDocs)
		 IncProc(STR0038 + aDocs[nX,3])//"Procesando Documentos:"
		If AllTrim(cEspecie) $ "NCI|NCC"
			aAreaSF := SF1->(GetArea())
			DbSelectArea("SF1")
			DbSetOrder(1)//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO 
			lOK := MsSeek(xFilial("SF1")+aDocs[nX][3]+aDocs[nX][2]+aDocs[nX][4]+aDocs[nX][5])
			If lOk
				cFlftex := SF1->F1_FLFTEX
			EndIf
		Else
			aAreaSF := SF2->(GetArea())
			DbSelectArea("SF2")
			DbSetOrder(1)//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			lOK := MsSeek(xFilial("SF2")+aDocs[nX][3]+aDocs[nX][2]+aDocs[nX][4]+aDocs[nX][5])
			If lOk
				cFlftex := SF2->F2_FLFTEX
			EndIf
		EndIf

		cFechTim := ""
		cHoraTim := ""
		cId		 := "" 
		cCUF	 := ""
		cStatus := VulcanCkIn(cToken, AllTrim(aDocs[nX][2]) + AllTrim(aDocs[nX][3]), @aRetObs, aDocs[nX][1],aDocs[nX][3], aDocs[nX][2], aDocs[nX][4], aDocs[nX][5], cEspecie, @cDesc, cFlftex, @cFechTim, @cHoraTim, @cId, @cCUF)
		
		//Si el estatus cambió se actualiza
		If !Empty(cStatus) .and. cStatus <> cFlftex
			V486UPDST(cStatus, cEspecie,cCUF,cFechTim,cId,,cHoraTim)
		EndIf
		aDocs[nX,9] := cCUF
		aAdd(aRet, {val(cStatus),;
					Alltrim(aDocs[nX,2]) + "-" + aDocs[nX,3],;
					"",;//"Producción" // "Pruebas"
					dDataBase,;
					cDesc,; //Cod. Estado
					"",;
					"", ;
					aDocs[nX,3], ; //Documento
					aDocs[nX,2], ; //Serie
					aDocs[nX,4], ; //Cliente
					aDocs[nX,5], ; //Loja
					AllTrim(aDocs[nX,9])})  //CUF
	Next nX

	RestArea(aArea)
	RestArea(aAreaSF)

Return aRet

/*/{Protheus.doc} GStatusDes
Consulta a VULCAN los documentos contenidos en aDocs (Consulta estado)
@type
@author raul.medina
@since 11/2021
@version 1.0
@param cStatus, Caracter, Estatus actual de la factura
@return 
/*/
Static Function GStatusDes(cStatus)
Local cDesc 	:= ""
Local nX		:= 0
Local cCpo		:= Iif( Type("cEspecie") == "C" .and. cEspecie $ "NCC|NCI", "F1_FLFTEX", "F2_FLFTEX")
Local cSX3Combo	:= ""
Local aEsp		:= {}
Local aDatos	:= {}
Local nPos		:= 0

	// Busca pos. da descricao da especie da nota no combo da tabela SFP (1=NF;2=NCI;3=NDI;4=NCC;5=NDC)
	cSX3Combo := Alltrim(GetSX3Cache(cCpo,"X3_CBOX"))
	aEsp := StrTokArr(cSX3Combo, ";")
	For nX := 1 To Len(aEsp)
		aAdd(aDatos,StrTokArr(aEsp[nX], "="))
	Next nX
	nPos := AScan(aDatos,{|x|Alltrim(x[1])==AllTrim(Str(cStatus))})
	cDesc := IIf(nPos>0,aDatos[nPos][2],"")

Return cDesc

/*/{Protheus.doc} ChckUrlV
Verifica si el PE está compilado y si está compilado se verifica si hay una url personalizada.
@type
@author raul.medina
@since 11/2021
@version 1.0
@param cUrlType	, Caracter, Tipo de documento para la url.
@param cUrl		, Caracter, Url actual.
@return 
/*/
Static Function ChckUrlV(cUrlType, cUrl)
Local cUrlResp	:= cUrl

	//Verificación de existencia de URL en la tabla S020
	cUrl := Lower(ObtColSAT('S020',Upper(cUrlType),1,26,27,100))
	
	If ExistBlock("M486PEURL")
		cUrl	:= ExecBlock("M486PEURL",.F.,.F.,{cUrlType})
	EndIf

	If Empty(cUrl)
		cUrl := cUrlResp
	EndIf

Return cUrl

/*/{Protheus.doc} SF3NUMAUT
Realiza la actualización del campo F3_NUMAUT.
@type
@author raul.medina
@since 01/2022
@version 1.0
@param cLLave	, Caracter, cliente/Proveedor+Tienda+Documento+Serie.
@param cNumAut	, Caracter, CUF.
@return 
/*/
Static Function SF3NUMAUT(cLlave, cNumAut)
Local aArea			:= getArea()

Default cLlave		:= ""
Default cNumAut		:= ""

	DbSelectArea("SF3")
	DbSetOrder(4)//F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
	If MsSeek(xFilial("SF3")+cLlave)
		While !SF3->(EOF()) .and. SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE) == xFilial("SF3") + cLlave
			RecLock("SF3",.F.)
				SF3->F3_NUMAUT	:= cNumAut
			SF3->(MsUnlock())	
			SF3->(dbSkip())
		End
	EndIf
	
	RestArea(aArea)

Return

/*/{Protheus.doc} ItemOrig
Obtiene información de los items de la factura original
@type function
@author raul.medina
@since 01/2022
@version 1.0
@param cFactura,	Caracter, 	Número de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param cCodigo,		Caracter, 	Cliente de la factura.
@param cLoja,		Caracter, 	Loja de la factura.
*/
Static function ItemOrig(cFactura, cSerie, cCodigo, cLoja, nMoeda)
Local cAlias	:= ""
Local cJson		:= ""
Local nItems	:= 0
Local aArea		:= getArea()
Local nVlrUnit	:= 0
Local nDescUnit	:= 0
Local nDescTot	:= 0
Local nVlrTotal	:= 0
Local nVlrAuxT	:= 0
Local nFactor	:= 0
Local nICEItem	:= 0
Local nTasaOrig	:= 0
Local lICEaux:=.F.

	cAlias 	:= ItemsDoc ("SD2", aCposImpD2, cFactura, cSerie, cCodigo, cLoja)
	If !Empty(cAlias)

		While (cAlias)->(!EOF())

			If nItems > 0
				cJson += ','
			EndIf

			nVlrUnit	:= 0
			nDescUnit	:= 0
			nDescTot	:= 0
			nVlrTotal	:= 0
			nVlrAuxT	:= 0
			nFactor		:= 0

			nVlrTotal	:= (cAlias)->D2_TOTAL
			nVlrAuxT	:= (cAlias)->D2_TOTAL



			If (cAlias)->D2_DESCON > 0
				nVlrAuxT += (cAlias)->D2_DESCON 
			EndIf

			//Verifica si hay calculo de ICE 
			nICEItem := ICEItem(cAlias,"D2")
			If nICEItem > 0
				lICEaux:=.T.
				nVlrAuxT += nICEItem
				nVlrTotal += nICEItem
			EndIf

			nVlrUnit  :=VALDOCDECI(lICEaux,"D2_TOTAL","14",nMoeda,(nVlrAuxT / (cAlias)->D2_QUANT)) //Round(nVlrAuxT / (cAlias)->D2_QUANT,2) 	//Valor unitario sumando descuentos con impuestos
			If nMoeda <> 1
				nTasaOrig 	:= TasaOrig(cFactura, cSerie, cCodigo, cLoja)
				If nTasaOrig > 1
					nVlrUnit	:= Round(nVlrUnit*nTasaOrig,2)
					nVlrTotal 	:= (cAlias)->D2_QUANT * nVlrUnit
				EndIf
			EndIf

			If (cAlias)->D2_DESCON > 0
				
				If nMoeda <> 1
					nVlrTotal 	:= (cAlias)->D2_QUANT * Round((cAlias)->D2_PRCVEN*nTasaOrig,2)
				EndIf
				nVlrAuxT  := nVlrUnit * (cAlias)->D2_QUANT				//Valor total obtenido del precio unitatio con descuentos e impuestos.
				nDescTot  := nVlrAuxT - nVlrTotal						//Descuento total, descuento por unidad x cantidad.
				nDescUnit := nDescTot / (cAlias)->D2_QUANT				//Se obtiene el descuento por unidad con impuestos.
			EndIf


			//Datos del Json correspondiente al item.
			cJson += 	'{'
			cJson += 	'"detailTransaction": "ORIGINAL",'
			cJson += 	'"quantity": ' + AllTrim(Str((cAlias)->D2_QUANT)) + ','
			cJson +=	'"productCode": "' + JsonCarEsp(AllTrim((cAlias)->D2_COD)) +  '",'
			cJson += 	'"concept": "' + JsonCarEsp(AllTrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+(cAlias)->D2_COD,1,""))) + '",'
			cJson += 	'"unitPrice": ' + AllTrim(Str(nVlrUnit)) + ','
			cJson += 	'"subtotal": ' + AllTrim(Str( VALDOCDECI(lICEaux,"D2_TOTAL","14",nMoeda,(nVlrTotal)))) + '' //nVlrTotal)) + ''
			If (cAlias)->D2_DESCON > 0
				cJson +=	',"discountAmount": ' + AllTrim(Str((nDescTot))) + ''
			EndIf

			cJson += 	'}'

			nItems += 1

			(cAlias)->(dbSkip())
		End
		
		(cAlias)->(dbcloseArea())
	EndIf

	RestArea(aArea)

Return cJson

/*/{Protheus.doc} DocOrig
Datos del documento original
@type function
@author raul.medina
@since 01/2022
@version 1.0
@param cFactura,	Caracter, 	Número de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param cCodigo,		Caracter, 	Cliente de la factura.
@param cLoja,		Caracter, 	Loja de la factura.

*/
Static Function DocOrig( cFatura, cSerie, cCodigo, cLoja)
Local cQuery 	:= ""
Local cAliasTmp	:= getNextAlias()
Local aDatos	:= {}


	cQuery := "Select"
	cQuery += " F2_CODDOC,"
	cQuery += " F2_NUMAUT,"
	cQuery += " F2_FECTIMB,"
	cQuery += " F2_HORATRM"
	cQuery += " from "+RetSqlName("SF2")+ " SF2 "
	cQuery += " Where "
	cQuery += " F2_FILIAL = '" + xFilial("SF2")
	cQuery += "' And F2_CLIENTE = '" + cCodigo
	cQuery += "' And F2_LOJA = '" + cLoja
	cQuery += "' And F2_DOC = '" + cFatura
	cQuery += "' And F2_SERIE = '" + cSerie
	cQuery += "' AND D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	(cAliasTmp)->(dbGoTop())

	If (cAliasTmp)->(!Eof())
		aDatos := {(cAliasTmp)->F2_CODDOC, (cAliasTmp)->F2_NUMAUT, (cAliasTmp)->F2_FECTIMB, (cAliasTmp)->F2_HORATRM}
	EndIf

	(cAliasTmp)->(dbcloseArea())

Return aDatos

/*/{Protheus.doc} ICEItem
Obtiene el total de impuesto de ICE
@type function
@author raul.medina
@since 01/2022
@version 1.0
@param cAlias	,	Caracter, 	Alias de la tabla en uso.
@param cTab,		Caracter, 	Tabla origen D1/D2.

*/
Static Function ICEItem(cAlias,cTab)
Local nValICE	:= 0
Local cCpoLib	:= ""
Local cImpICE	:= SuperGetMV("MV_IMPICE",,"ICE|IC1")
Local aImpICE	:= Separa(cImpICE,"|")
Local nX		:= 0

Default cAlias	:= ""
Default cTab	:= ""

	For nX := 1 To Len(aImpICE)
		cCpLib := ""
		cCpoLib := GetAdvFVal("SFB","FB_CPOLVRO",xFilial("SFB") + aImpICE[nX],1,"")
		If !Empty(cCpoLib)
			nValICE += (cAlias)->&(cTab + "_VALIMP"+cCpoLib)
		EndIf
	Next
	
Return nValICE

/*/{Protheus.doc} TasaOrig
Tasa del documento original
@type function
@author raul.medina
@since 01/2022
@version 1.0
@param cFactura,	Caracter, 	Número de la factura.
@param cSerie,		Caracter, 	Serie de la factura.
@param cCodigo,		Caracter, 	Cliente de la factura.
@param cLoja,		Caracter, 	Loja de la factura.

*/
Static Function TasaOrig( cFatura, cSerie, cCodigo, cLoja)
Local cQuery 	:= ""
Local cAliasTmp	:= getNextAlias()
Local nTasa		:= 0


	cQuery := "Select"
	cQuery += " F2_TXMOEDA"
	cQuery += " from "+RetSqlName("SF2")+ " SF2 "
	cQuery += " Where "
	cQuery += " F2_FILIAL = '" + xFilial("SF2")
	cQuery += "' And F2_CLIENTE = '" + cCodigo
	cQuery += "' And F2_LOJA = '" + cLoja
	cQuery += "' And F2_DOC = '" + cFatura
	cQuery += "' And F2_SERIE = '" + cSerie
	cQuery += "' AND D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	(cAliasTmp)->(dbGoTop())

	If (cAliasTmp)->(!Eof())
		nTasa := (cAliasTmp)->F2_TXMOEDA
	EndIf

	(cAliasTmp)->(dbcloseArea())

Return nTasa

/*/{Protheus.doc} ImpProdVul
Rutina para el registros de productos en Vulcan.
@type function
@author raul.medina
@since 02/2022
@version 1.0

*/
Function ImpProdVul()
Local aArea		:= getArea()
Local aError	:= {}
Local nTotProd 	:= 0
Local nPrdTrans	:= 0
Local cMsglog	:= ""

	If !(SB1->(ColumnPos("B1_PRODACT")) > 0)
		Help( ,,STR0073 ,, STR0079 ,1, 0 ) //"Aviso" //"No existe el campo B1_PRODACT"
		Return
	EndIf

	
	Processa( { || ImpProd(@aError, @nTotProd, @nPrdTrans) }, STR0066, STR0066 )
	
	If Len(aError) > 0
		cMsglog := AllTrim(STR(nPrdTrans)) + STR0083 + "" + STR0084
		If MsgYESNO(cMsglog)
			PRODLOG(aError, nTotProd, nPrdTrans)
		EndIf
	EndIf

	RestArea(aArea)
Return 

/*/{Protheus.doc} ImpProd
Rutina para el registros de productos en Vulcan.
@type function
@author raul.medina
@since 02/2022
@version 1.0
@param aError,		Array, 		Array para informar los errores.
@param nTotProd,	Numerico, 	Total de productos enviados.
@param nProdTrans,	Numerico, 	Total de productos transmitidos.

*/
Static Function ImpProd(aError, nTotProd, nProdTrans)
Local cQuery	:= ""
Local cAliasTmp	:= getNextAlias()
Local cCodUM	:= ""
Local lOk		:= .T.
Local cActEcon	:= ""
Local lActEcon	:= (SB1->(ColumnPos("B1_ACTECON")) > 0) 

	cToken	:= VulcanTkn()


	cQuery := "Select"
	cQuery += " B1_FILIAL, B1_COD, B1_DESC, B1_PRODSAT, B1_UM, SB1.R_E_C_N_O_ RECNO"
	If lActEcon
		cQuery += ", B1_ACTECON"
	EndIf
	cQuery += " from "+RetSqlName("SB1")+ " SB1 "
	cQuery += " Where "
	cQuery += " B1_FILIAL = '" + xFilial("SB1")
	cQuery += "' And B1_PRODACT <> '2'"
	cQuery += " AND SB1.D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)


	count to nTotProd
	(cAliasTmp)->(dbGoTop())

	While (cAliasTmp)->(!EOF())
		lOk := .T.
		If Empty((cAliasTmp)->B1_UM)
			aAdd(aError, {(cAliasTmp)->B1_FILIAL,(cAliasTmp)->B1_COD, (cAliasTmp)->B1_DESC, STR0080 + "B1_UM" + STR0081})
			lOk := .F.
		Else
			cCodUM := ""
			cCodUM := GetAdvFVal("SAH", "AH_COD_CO", xFilial("SAH") + (cAliasTmp)->B1_UM, 1, "")
			If Empty(cCodUM)
				aAdd(aError, {(cAliasTmp)->B1_FILIAL, (cAliasTmp)->B1_COD, (cAliasTmp)->B1_DESC, STR0080 + "AH_COD_CO" + STR0082 + (cAliasTmp)->B1_UM})
				lOk := .F.
			EndIf
		EndIf
		If Empty((cAliasTmp)->B1_PRODSAT)
			aAdd(aError, {(cAliasTmp)->B1_FILIAL, (cAliasTmp)->B1_COD, (cAliasTmp)->B1_DESC, STR0080 + "B1_PRODSAT" + STR0081})
			lOk := .F.
		EndIf

		If lActEcon
			cActEcon := (cAliasTmp)->B1_ACTECON
		EndIf

		If lOk
			If VulcanProd(cToken, @aError, (cAliasTmp)->B1_FILIAL, (cAliasTmp)->B1_COD, (cAliasTmp)->B1_DESC, cCodUM, AllTrim((cAliasTmp)->B1_PRODSAT), (cAliasTmp)->RECNO, ,cActEcon)
				nProdTrans += 1
			EndIf
		EndIf

		(cAliasTmp)->(DbSkip())
	End

	(cAliasTmp)->(dbcloseArea())

Return

/*/{Protheus.doc} PRODLOG
Rutina para el log de productos registrados de productos en Vulcan.
@type function
@author raul.medina
@since 02/2022
@version 1.0
@param aErrores,	Array, 		Array para informar los errores.
@param nFact,		Numerico, 	Total de productos enviados.
@param nTrans,		Numerico, 	Total de productos transmitidos.

*/
function PRODLOG(aErrores,nFact,nTrans)
Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
Local cTamanho	:= "M"
Local cTitulo	:= STR0085 //"LOG  de DIOT"
Local nX		:= 1
Local aNewLog	:= {}
Local nTamLog	:= 0
Local aLogTitle	:= {STR0087,STR0086}   // "Filial    Producto           Descripción                       Detalle"
Local aLog		:= {}
Local aLogRes	:= {}
Local cDetalle 	:= ""
Local nPos 		:= 1
Local nC		:= 0
Local cProd		:= ""

Private wCabec1 := STR0088 //"Registro de productos"

	For nx:=1 to len(aErrores)
        cDetalle := ""
      	nPos := 1
		cProd	:=	PADR(aErrores[nx,1],8) + space(8 - len(aErrores[nx,1])) + Space(2)  +; // Filial
					PADR(aErrores[nx,2],15) + space(15 - len(aErrores[nx,2])) + Space(4)  +; // Producto
					PADR(aErrores[nx,3],30) + space(30 - len(aErrores[nx,3])) + Space(4)     // Descripción


		If len(aErrores[nx,4]) > 68
			For nC:= 1 to (len(aErrores[nx,4])/68) + 1
				cDetalle := SUBSTR(aErrores[nx,4],nPos,68)
				nPos += 68
				aadd(aLog,cProd + cDetalle ) // Detalle
			Next nC
		Else
			aadd(aLog,cProd + aErrores[nx,4] ) // Detalle
		EndIF
	next

	aAdd(aLogRes," ")
	aadd(aLogRes,STR0089 + Transform(nFact,"9999"))				// "Productos procesados: 	"
	aadd(aLogRes,STR0090 + Transform(nFact- nTrans,"9999"))		// "Productos con errror: 	"
	aadd(aLogRes,STR0091 + Transform(nTrans,"9999"))			// "Productos registrados:  "

	aNewLog	:= aClone(aLog)
	nTamLog	:= Len( aLog)
	aLog 	:= {}

	If !Empty( aNewLog )
		aAdd( aLog , aClone( aNewLog ) )
	Endif

	aAdd(aLog, aLogRes)
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
	MsAguarde( { ||fMakeLog( aLog ,aLogTitle , , .t. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},STR0092) // "Generando Log de errores..."
Return

/*/{Protheus.doc} VulcanProd
Servicio para realizar el registro de productos en vulcan.
@type function
@author raul.medina
@since 02/2022
@version 1.0
@param cToken,		Caracter, 	Token creado para las transmisiones.
@param aError,		Array, 		Array para informar los errores del proceso.
@param cFil,		Caracter, 	Filial de los productos.
@param cProd,		Caracter, 	Código del producto.
@param cDesc,		Caracter, 	Descripción del producto.
@param cCodUM,		Caracter, 	Código de la unidad de Medida.
@param cProdCod,	Caracter, 	Código del producto SIAT.
@param nRecno,		Numerico, 	Numero del R_E_C_N_O_.
@param cActEcon, 	Caracter,	Codigo de actividad economica.
*/
Function VulcanProd(cToken, aError, cFil, cProd, cDesc, cCodUM, cProdCod, nRecno, lEdit, cActEcon)
Local cURL			:= SuperGetMV("MV_WSRTSS",,"")
Local aHeader		:= {}
Local oRest			:= Nil
Local oObj	 		:= Nil
Local lRest			:= .F.
Local cMsg			:= ""
Local cJson			:= ""
Local cEndPoint		:= "/msinvoice/api/integrations/products"
Local lRet			:= .F.

DEFAULT cToken		:= ""
DEFAULT lEdit		:= .F.
DEFAULT cActEcon	:= ""

	oRest := FWRest():New(cUrl)
	aAdd(aHeader, "Content-Type: application/json; charset=utf-8")
	aAdd(aHeader, "Authorization: Bearer " + cToken)

	cJson	:= '{'
	If !Empty(cActEcon)
		cJson	+=	'"activity": "' + AllTrim(cActEcon) + '", ' 
	EndIf
	cJson	+=	'"productCode": "' + JsonCarEsp(AllTrim(cProd)) + '", '
	cJson	+=  '"description": "' + JsonCarEsp(AllTrim(cDesc)) + '", '
	cJson	+=  '"siatMeasurementUnitCode": ' + AllTrim(cCodUM) + ', '
	cJson	+=  '"siatProductCode": ' + AllTrim(cProdCod) + ', '
	cJson	+=	'"productOrigin": "GENERIC"'
	cJson	+= '}'

	cEndPoint := ChckUrlV("Products", cEndPoint)
	oRest:SetPath(cEndPoint)
	oRest:SetPostParams(cJson)

	lRest := Iif(lEdit, oRest:Put(aHeader) ,oRest:Post(aHeader))

	If FWJsonDeserialize(oRest:GetResult(),@oObj)
		If oObj <> Nil
			If lRest
				aAdd(aError, {cFil, cProd, cDesc, STR0093})
				If nRecno > 0
					V486UPDB1(nRecno, "2")
				EndIf
				lRet := .T.
			Else
				If AttIsMemberOf(oObj,"ERRORKEY")
					cMsg += oObj:ERRORKEY
				EndIf
				If AttIsMemberOf(oObj,"MESSAGE")
					cMsg += " - " + oObj:MESSAGE
				EndIf
				If !Empty(cMsg)
					aAdd(aError, {cFil, cProd, cDesc, cMsg})
				EndIf
				If nRecno > 0
					V486UPDB1(nRecno, "0")
				EndIf
			EndIf
		EndIf
	ElseIf AttIsMemberOf(oRest,"ORESPONSEH")
		If AttIsMemberOf(oRest:ORESPONSEH, "CSTATUSCODE")
			cMsg += oRest:ORESPONSEH:CSTATUSCODE +  ": "
		EndIf
		If AttIsMemberOf(oRest:ORESPONSEH, "CREASON")
			cMsg += oRest:ORESPONSEH:CREASON
		EndIf
		If !Empty(cMsg)
			aAdd(aError, {cFil, cProd, cDesc, cMsg})
		EndIf
		If nRecno > 0
			V486UPDB1(nRecno, "0")
		EndIf
	EndIf
	oRest:= Nil
Return lRet

/*/{Protheus.doc} V486UPDB1
Servicio para realizar el registro de productos en vulcan.
@type function
@author raul.medina
@since 02/2022
@version 1.0
@param nRecno,		Numerico, 	Numero del R_E_C_N_O_.
@param cStatus,		Caracter, 	Estatus del producto.
*/
Static Function V486UPDB1(nRecno, cStatus)
Local aArea		:= getArea()

Default nRecno		:= 0
Default cStatus		:= ""

	dbSelectArea("SB1")
	SB1->(dbgoto(nRecno))
	RecLock("SB1",.F.)
		SB1->B1_PRODACT := cStatus
	SB1->(MsUnlock())
	

	RestArea(aArea)
Return

/*/{Protheus.doc} M486UPDST
Actualiza estatus de documentos electrónicos.
@type function
@author raul.medina
@since 26/02/2022
@version 1.0
@param aTrans, array, Documentos transmitidos.
		aTrans[n,1] 	= Filial
		aTrans[n,2] 	= Serie
		aTrans[n,3] 	= Factura
		aTrans[n,4]		= Cliente
		aTrans[n,5] 	= Loja
		aTrans[n,6] 	= Valor F1/F2_UUID
		aTrans[n,7] 	= Valor F1/F2_FLFTEX
		aTrans[n,8] 	= Valor F1/F2_NUMAUT
		aTrans[n,9]		= Valor F1/F2_FECTIMB
		aTrans[n,10]	= Valor F1/F2_HORATRM

@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486UPDB(aTrans, cEspecie)
Local aArea		:= getArea()
Local nI		:= 0
Local cClave	:= ""
Local cLlaveF3	:= ""

	For nI := 1 to len(aTrans)
		If AllTrim(cEspecie) $ "NCC"
			cClave :=  aTrans[nI,1] + aTrans[nI,4]+aTrans[nI,5]+aTrans[nI,3]+aTrans[nI,2]
			dbSelectArea("SF1")
			SF1->(dbSetOrder(2))// F1_FILIAL+F1_CLIENTE+F1_LOJA+F1_DOC
			If SF1->(dbSeek(cClave))
				RecLock("SF1",.F.)
					If !Empty(aTrans[nI,6])
						SF1->F1_UUID	:= aTrans[nI,6]
					EndIf
					If !Empty(aTrans[nI,7])
						SF1->F1_FLFTEX  := aTrans[nI,7]
					EndIf
					If !Empty(aTrans[nI,8])
						SF1->F1_NUMAUT	:= aTrans[nI,8]
					EndIf
					If ValType(aTrans[nI,9]) == "D"
						SF1->F1_FECTIMB	:= aTrans[nI,9]
					EndIf
					If !Empty(aTrans[nI,10])
						SF1->F1_HORATRM	:= aTrans[nI,10]
					EndIf
				SF1->(MsUnlock())
			EndIF
		Else
			cClave := aTrans[nI,1] + aTrans[nI,4]+aTrans[nI,5]+aTrans[nI,3]+aTrans[nI,2]
			dbSelectArea("SF2")
			SF2->(dbSetOrder(2)) // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
			If SF2->(dbSeek(cClave))
				RecLock("SF2",.F.)
					If !Empty(aTrans[nI,6])
						SF2->F2_UUID	:= aTrans[nI,6]
					EndIf
					If !Empty(aTrans[nI,7])
						SF2->F2_FLFTEX  := aTrans[nI,7]
					EndIf
					If !Empty(aTrans[nI,8])
						SF2->F2_NUMAUT	:= aTrans[nI,8]
					EndIf
					If ValType(aTrans[nI,9]) == "D"
						SF2->F2_FECTIMB	:= aTrans[nI,9]
					EndIf
					If !Empty(aTrans[nI,10])
						SF2->F2_HORATRM	:= aTrans[nI,10]
					EndIf
				SF2->(MsUnlock())
			EndIF
		EndIf
		cLlaveF3 := aTrans[nI,4]+aTrans[nI,5]+aTrans[nI,3]+aTrans[nI,2]
		//Actualización de el campo F3_NUMAUT.
		If !Empty(cLlaveF3) .and. !Empty(aTrans[nI,8])
			SF3NUMAUT(cLlaveF3, aTrans[nI,8])
		EndIf
	Next nI

	RestArea(aArea)

Return



/*/{Protheus.doc} ChkExport
Verifica si el control de formularios corresponde a exportación
@type function
@author raul.medina
@since 03/2022
@version 1.0
@param cEspecie,	Caracter, 	Especie de la factura.
@param cSerie,		Caracter, 	Serie de la factura.

*/
Static Function ChkExport(cEspecie, cSerie)
Local lRet 		:= .F.
Local aArea		:= getArea()
Local cSX3Combo	:= ""
Local cCombo	:= ""
Local nPos		:= 0
Local aEsp		:= {}
Local aDatosE	:= {}
Local nX		:= 0
Local cTpDoc	:= ""


	DbSelectArea("SFP")
	If SFP->(ColumnPos("FP_TPDOC")) > 0
		// Busca pos. da descricao da especie da nota no combo da tabela SFP (1=NF;2=NCI;3=NDI;4=NCC;5=NDC)
		cSX3Combo := Alltrim(GetSX3Cache("FP_ESPECIE","X3_CBOX"))
		aEsp := StrTokArr(cSX3Combo, ";")
		For nX := 1 To Len(aEsp)
			aAdd(aDatosE,StrTokArr(aEsp[nX], "="))
		Next nX
		nPos := AScan(aDatosE,{|x|Alltrim(x[2])==cEspecie})
		cCombo := IIf(nPos>0,aDatosE[nPos][1],"")

		cTpDoc := GetAdvFVal("SFP","FP_TPDOC",xFilial("SFP") + cFilAnt + cSerie + cCombo,5,"")

		If !Empty(cTpDoc)
			If cTpDoc == "2"
				lRet := .T.
			EndIf
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} JsonCarEsp
Control de caracteres especiales para objetos json
@type function
@author raul.medina
@since 03/2022
@version 1.0
@param cTexto,	Caracter, 	Texto a recibir tratamiento para caracteres de escape y UTF-8.

*/
Function JsonCarEsp(cTexto)
Local cRet := ""                    
Local nChar := 0
Local aCarEsp := {}

	If !Empty(cTexto)
		cRet := cTexto
		Aadd(aCarEsp,{'"','\"'})
		Aadd(aCarEsp,{'\','\\'})
		Aadd(aCarEsp,{'\\"','\"'})
		
		For nChar := 1 To Len(aCarEsp)
			cRet := StrTran(cRet,aCarEsp[nChar,1],aCarEsp[nChar,2])
		Next
	EndIf
	cRet := EncodeUtf8(cRet)

Return(cRet)

/*/{Protheus.doc} ValNITVu
Permite validar el NIT en vulcan
@type function
@author adrian.perez
@since 04/2022
@version 1.0
@param cnumNIT , caracter, numero NIT
@return lRet,booleano, si es ".T." indica que el NIT (A1_CGC) informardo al consumir 
								el servicio de vulcan retornno "true" tambien 
								lRet es ".T." cuando se deja vacío el campo del NIT (A1_CGC),
								si no es valido el NIT al consumir el servicio de vulvan,
								retorna false y a lRet se le asigna ".F."
*/
Function ValNITVu(cnumNIT)
Local cURL			:= SuperGetMV("MV_WSRTSS",,"")
Local aHeader		:= {}
Local oRest			:= Nil
Local cEndPoint		:= "/msinvoice/api/integrations/nit-check/"
Local cRespNit:=""
Local cToken		:= VulcanTkn()
Local lRet :=.T.
Local lRetorno:=.T.
Local oObj
Local cCFDUso:= 		SuperGetMv("MV_CFDUSO",.F.,"")
Local cOperador:=   	SuperGetMv("MV_PROVFE",.F.,"") //Indicar el operador de Servicios Electrónicos. (Ejemplo: "VULCAN", no realiza transmisión on-line, "VULCANON", realiza la transmisión on-line.
Local lAux:=.T.
Default cnumNIT	:= ""


	cnumNIT:= ALLTRIM(cnumNIT)
	If !Empty(cnumNIT) .and. (cCFDUso  $("1|2")) .and. ("VULCAN" $ UPPER(cOperador))

		oRest := FWRest():New(cUrl)
		aAdd(aHeader, "Authorization: Bearer " + cToken)
		cEndPoint := ChckUrlV("Checar-Nit", cEndPoint)
	
		oRest:SetPath(cEndPoint+cnumNIT)
	    lRet:=oRest:Get(aHeader)
		If FWJsonDeserialize(oRest:GetResult(),@oObj)

			If oObj <> Nil .and.  lRet
				cRespNit := oRest:GetResult()
			ENDIF

		ElseIf AttIsMemberOf(oRest,"ORESPONSEH")
			If AttIsMemberOf(oRest:ORESPONSEH, "CSTATUSCODE")
				If oRest:ORESPONSEH:CSTATUSCODE != "200"
					
					lAux:= MsgYesNo(STR0101, STR0102)//--No fue posible establecer la conexión con Vulcan desea incluir el NIT sin validación de Vulcan
					
				ENDIF
			ENDIF
		ENDIF
		
		oRest:= Nil
		
		If cRespNit=="false"
			lRetorno:=.F.
			Help(" ",1,STR0099,,STR0100,4,5) //---No es valido el NIT
		EndIf
		IF !lAux
				lRetorno:=.F.		
		EndIf
	EndIf
Return lRetorno

/*/{Protheus.doc} M486MONDOC
Función para visualizar los documentos que han sido transmitidos
@type function
@author raul.medina
@since 07/07/2017
@version 1.0
@param lAut, BOOLEAN, (Si s ejecutado de manera automática)
@param aDocs, array, Array con los documentos a ser monitoreados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486MNDCBO(lAut,aDocs)
Local aArea		:= getArea()
Local cDocIni	:= ''
Local cDocFin	:= ''
Local cDocSer	:= ''
Local lMonitor  := .T.
Local aObs := {}
Private aItems	:= {}

Default lAut	:= .F.
Default adocs	:= {}

	If lMonitor
		If !lAut
			If Pergunte(cPergFac, .T.)
				cDocSer 	:= MV_PAR01
				cDocIni 	:= MV_PAR02
				cDocFin 	:= MV_PAR03

				Processa({|lEnd| aDocs := M486GETINF(cDocSer,cDocIni,cDocFin)}, STR0103) // "Obteniendo Información"
			Else
				Return
			EndIf
		EndIF
		If len(aDocs) > 0
			// Obtiene datos SIN para los documentos contenidos en aDocs
			Processa({|lEnd| aItems:= M486GETSIN(aDocs,@aObs)},STR0104)	//"Consultando al SIN... aguarde..."
			If len(aItems)>0
				M486MonBo(aItems,aDocs,aObs) // Abre monitor con parámetros dados
			EndIf
		Else
			MsgAlert(STR0105)//"No hay documentos dentro de los rangos especificados"
		EndIf
	EndIf
	RestArea(aArea)
Return

/*/{Protheus.doc} M486GETINF
Consulta información sobre los documentos contenidos en el rango dado
@type function
@author raul.medina
@since 04/2022
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


	If nTipoDoc == 0
		cQuery := "SELECT F1_FILIAL FILIAL,F1_FORNECE CLIFOR, F1_LOJA TIENDA, F1_DOC DOC, F1_SERIE SERIE "
		If SF1->(ColumnPos("F1_UUID"))
			cQuery += ", F1_FLFTEX STATUS, F1_UUID UUID, F1_UUIDC UUIDC, F1_CODDOC CODDOC, F1_TIPNOTA TIPDOC, F1_NUMAUT NUMAUT "
		EndIf
		If SF1->(ColumnPos("F1_CODAUT"))
			cQuery += ", F1_CODAUT CODMOTC "
		EndIf
		cQuery += "FROM "+RetSqlName("SF1")+" SF1 "
		cQuery += "WHERE F1_SERIE = '" + cSerie + "' AND F1_ESPECIE = '" + cEspecie + "' AND F1_DOC BETWEEN '" + cFacIn + "' AND '" + cFacFi + "' AND D_E_L_E_T_ = '' "
		cQuery += "AND F1_FLFTEX IN('1','4','5','7') " // 1=Recepción procesada, 4= Recepcion Pendiente, 5=Recepción observada, 7=Anulación pendiente confirmación
	Else
		cQuery := "SELECT F2_FILIAL FILIAL, F2_CLIENTE CLIFOR, F2_LOJA TIENDA, F2_DOC DOC, F2_SERIE SERIE "
		If SF2->(ColumnPos("F2_UUID"))
			cQuery += ", F2_FLFTEX STATUS, F2_UUID UUID, F2_UUIDC UUIDC, F2_CODDOC CODDOC, F2_TPDOC TIPDOC, F2_NUMAUT NUMAUT"
		EndIf
		If SF2->(ColumnPos("F2_CODAUT"))
			cQuery += ", F2_CODAUT CODMOTC "
		EndIf
		cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
		cQuery += "WHERE F2_SERIE = '" + cSerie + "' AND F2_ESPECIE = '" + cEspecie + "' AND F2_DOC BETWEEN '"+cFacIn+"' AND '"+cFacFi+"' AND D_E_L_E_T_ = '' "
		cQuery += "AND F2_FLFTEX IN('1','4','5','7') " // 1=Recepción procesada, 4= Recepcion Pendiente,5=Recepción observada, 7=Anulación pendiente confirmación
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)
	count to nCount

	(cTempF)->(dbGoTop())
	While (!(cTempF)->(EOF()))
		aAdd(aRet, {(cTempF)->FILIAL,(cTempF)->SERIE,(cTempF)->DOC,(cTempF)->CLIFOR, (cTempF)->TIENDA, (cTempF)->UUID,(cTempF)->STATUS,IIF(EMPTY((cTempF)->UUIDC), "000000",(cTempF)->UUIDC ), IIF(EMPTY((cTempF)->CODDOC), IIF(EMPTY((cTempF)->NUMAUT), "000000",(cTempF)->NUMAUT),(cTempF)->CODDOC),  IIF(EMPTY((cTempF)->CODMOTC), "000000",(cTempF)->CODMOTC), (cTempF)->TIPDOC  })
		(cTempF)->(dbSkip())
	EndDo
	(cTempF)->(dbcloseArea())

	RestArea(aArea)
Return aRet



/*/{Protheus.doc} DECIMICEEX
    Valida los documentos del tipo ICE/EXP para determinar el número de decimales, a usar en el valor unitario
    de los items
    @author adrian.perez
    @param cRutina, carácter, nombre de la rutina
    @param nMoeda, numérico, moneda usada
    @param nCasas, numérico, numero de decimales usados
    @return nRet, numérico, numero de decimales usados
    la función es llamada en la función A410Arred|Fatxfun
    /*/
Function DECIMICEEX(cRutina,nMoeda,nCasas)
Local nRet:=nCasas
Local cTiposDoc:=SuperGetMV("MV_DECFE",,"")
Local aDocs:={}
Local cValor :=""

DEFAULT cRutina:=""
DEFAULT nMoeda:=1
DEFAULT nCasas:=2

aDocs:= StrTokArr( cTiposDoc, "|" )

IF Len(aDocs)>0
 
    IF cRutina== "MATA410" .AND.  Valtype(M->C5_TPDOCSE) <> "U"
        cValor := Alltrim(M->C5_TPDOCSE)
    ElseIF cRutina $ "MATA467N|MATA465N|MATA462N" .AND.  Valtype(M->F2_TPDOC) <> "U"
        cValor := Alltrim(M->F2_TPDOC)
    ElseIF cRutina $ "MATA461|MATA468N" .AND.  Valtype(SC5->C5_TPDOCSE) <> "U" 
        cValor := Alltrim(SC5->C5_TPDOCSE)
	ELSEIF cRutina $ "MATA415" .AND.  Valtype(M->CJ_TPDOCSE) <> "U"
		cValor := Alltrim(M->CJ_TPDOCSE)
    ENDIF
    
 	IF !Empty(cValor) .and. Ascan(aDocs,{ |x| Alltrim(x) ==Alltrim(cValor) } ) ==0
        nRet:=MsDecimais(nMoeda)
    ENDIF

    
ENDIF

Return  nRet

/*/{Protheus.doc} ROUNDICEEX
    Valida los documentos del tipo ICE/EXP para determinar el número de decimales en los items informados del pedido
    @author adrian.perez
    @param cRutina, carácter, nombre de la rutina
    @param cCampo, carácter, nombre del campo
    @param xValor,indefinico, valor a redondear
    @param aCols, array, datos de los items del pedido
    @param n,numérico, número del item
    @param nPQtdVen,numérico, posición del campo cantidad 
    @param nPQtdVen,numérico, posición del campo precio
    @return nil, nil, nil
    la función es llamada en la función A410MultT/MATV410A
/*/

Function ROUNDICEEX(cRutina,cCampo,xValor,aCols,n,nPQtdVen,nPPrcVen)

Local nCasas:=TamSX3(REPLACE(cCampo,"M->","") )[2]
Local nCant:= At('QTDVEN', cCampo)
Local nPrecio:=At('PRCVEN', cCampo)

DEFAULT cRutina:=cCampo:=""
DEFAULT xValor:=0
DEFAULT aCols:={}
DEFAULT n:=nPQtdVen:=nPPrcVen:=0

IF ((nCant>0 .and. nPQtdVen>0) .OR. (nPrecio>0 .and. nPPrcVen>0 )) 

    IF Valtype(M->C5_TPDOCSE) <> "U" .and. Valtype(M->C5_MOEDA) <> "U"
    
        nCasas:=DECIMICEEX(cRutina,M->C5_MOEDA,nCasas)
    
        xValor:= round(xValor,nCasas)

        IF nCant>0
            aCols[n][nPQtdVen]:=xValor
        ELSE 
            aCols[n][nPPrcVen]:=xValor
        ENDIF
    ENDIF

ENDIF
RETURN nil

/*/{Protheus.doc} VALDOCDECI
    Valida los documentos del tipo ICE/EXP para determinar el número de decimales a usar en el envió de datos a vulcan
    @author cristian.franco
	@param lDec, booleano, Indica si se calculó ICE ó es documento de exportación
    @param cCampo, carácter, nombre del campo para extraer tamaño decimales
    @param cValor, carácter, valor contenido en el campo F2_TPDOC
	@param nMoeda, numérico, moneda usada
    @param nValRound, numérico, Valor a redondear si se informa la función regresa el valor redondeado, si no
                                se informa solo regresa el número de decimales para redondear
    @return nDecimals, numérico, numero de decimales a usar
/*/

Function VALDOCDECI(lDec,cCampo,cValor,nMoeda,nValRound)
Local nDecimals:= MsDecimais(nMoeda)
Local cTiposDoc:=SuperGetMV("MV_DECFE",,"")
Local aDocs:={}

DEFAULT lDec := .F.
DEFAULT cCampo:=cValor:= ""
DEFAULT nMoeda:=1
DEFAULT nValRound:=0

If !lDec
	Return nDecimals
EndIf	

aDocs:= StrTokArr( cTiposDoc, "|" )

If (Ascan(aDocs,{ |x| Alltrim(x) ==Alltrim(cValor) } )>0) 
	nDecimals:=TamSX3(cCampo)[2]
EndIf
If nValRound>0
	nDecimals:=ROUND(nValRound,nDecimals)
EndIf

Return nDecimals


/*/{Protheus.doc} MAFISICEBO
    Permite determinar el número de decimales a usar en las cantidades, 
    precio unitario y valor total 
    cuando se calculan desde la matxfis
    @author adrian.perez
    @since 08/09/2022
    @param cIT, carácter, campo usado (cantidad, precio unitario o valor total)
    @param xvalor, indefinido, valor asignado al campo en algunas ocasiones en la matxfis lo regresa 
                lo asigna como carácter
    @param cRutina, carácter, nombre de la rutina desde donde se ejecuta la matxfis
    @return nil
    Usada en la función  MaFisAlt de la matxfis

    /*/

Function MAFISICEBO(cIT,xValor,cRutina)

Local cCampo:=""
Local nMoeda:=""
Local cTipDoc:=""

DEFAULT cIT:=""
DEFAULT xValor:=0
DEFAULT cRutina:=""

If cRutina $"MATA465N|MATA467N|MATA462N"

	If cRutina $"MATA465N" .AND. Valtype(M->F1_TIPNOTA) <> "U" .and. Valtype(M->F1_MOEDA) <> "U" .AND. Valtype(xValor)<>"U"  .AND. Valtype(M->F1_ESPECIE)<> "U"
	
		IF ALLTRIM(M->F1_ESPECIE)=="NCC"
			If (At('QUANT', cIT)>0)
				cCampo:="D1_QUANT"
			ElseIf (At('PRCUNI', cIT)>0)
				cCampo:= "D1_VUNIT"
			ElseIf (At('VALMERC', cIT)>0)
				cCampo:="D1_TOTAL"
			EndIf
			nMoeda:=M->F1_MOEDA
			cTipDoc:=M->F1_TIPNOTA
		ENDIF

	Else
		If  Valtype(M->F2_TPDOC) <> "U" .and. Valtype(M->F2_MOEDA) <> "U" .AND. Valtype(xValor)<>"U"  

			If (At('QUANT', cIT)>0)
				cCampo:="D2_QUANT"
			ElseIf (At('PRCUNI', cIT)>0)
				cCampo:= "D2_PRCVEN"
			ElseIf (At('VALMERC', cIT)>0)
				cCampo:="D2_TOTAL"
			EndIf
			nMoeda:=M->F2_MOEDA
			cTipDoc:=M->F2_TPDOC
		ENDIF
	EndIf

	If !empty(cCampo) 
		If  xValor>0
			xValor:=VALDOCDECI(.T.,cCampo,ALLTRIM(cTipDoc),nMoeda,xValor)
		EndIf
	EndIf
    &("M->"+cCampo):=xValor
ENDIF
	
Return xValor

/*/{Protheus.doc} MAFISROUBO
    Permite determinar el número de decimales a usar en el valor total 
    cuando se vuelve a recalcular
    @author adrian.perez
    @since 09/09/2022 
    @param cRutina, carácter, nombre de la rutina desde donde se ejecuta la matxfis
	@param nDec, numérico, número de decimales que ya trae el proceso 
    @return nil
    Usada en la función MaItArred de la matxfis,  a su vez la MaItArred  es llamada de la MaFisRecal
    y ese mafisrecal es llamado unas líneas abajo de donde se llamó MAFISICEBO
/*/

Function MAFISROUBO(cRutina,nDec)

Local nRound:=nDec
DEFAULT cRutina:=""
DEFAULT nDec:=2

If cRutina $"MATA465N|MATA467N|MATA462N"

	If cRutina $"MATA465N" .AND. (Valtype(M->F1_ESPECIE)<> "U")

		If  Valtype(M->F1_TIPNOTA) <> "U" .and. Valtype(M->F1_MOEDA) <> "U"  .AND. ALLTRIM(M->F1_ESPECIE)=="NCC"
			nRound:=VALDOCDECI(.T.,"D1_TOTAL",ALLTRIM(M->F1_TIPNOTA),M->F1_MOEDA)
		EndIf

	Else
		If  Valtype(M->F2_TPDOC) <> "U" .and. Valtype(M->F2_MOEDA) <> "U"  
			nRound:=VALDOCDECI(.T.,"D2_TOTAL",ALLTRIM(M->F2_TPDOC),M->F2_MOEDA)
		EndIf
		
	EndIf

EndIf
	
Return nRound
