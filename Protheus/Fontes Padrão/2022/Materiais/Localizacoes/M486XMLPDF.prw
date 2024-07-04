#INCLUDE 'protheus.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FONT.CH"
#INCLUDE "M486XMLPDF.CH"

Static lFormaPag := .F.
Static nLFinD := 0

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Programa  �M486XMLPDF� Autor �Luis Eduardo Enr�quez Mata  � Data �  06/07/17   ���
���������������������������������������������������������������������������������͹��
���Desc.     � Rutina para creaci�n y/o envio de reporte en formato PDF generado  ���
���          � a partir de XML timbrado por la SUNAT (PERU).                      ���
���������������������������������������������������������������������������������͹��
���Uso       � MATA486                                                            ���
���������������������������������������������������������������������������������Ĵ��
���                 ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
���������������������������������������������������������������������������������Ĵ��
���Programador  � Data   �   BOPS   �            Motivo da Alteracao              ���
���������������������������������������������������������������������������������Ĵ��
���Luis Enriquez�08/09/17�DMINA-38  �Se realiza modificacion en funcion DetFact   ���
���(PERU)       �        �          �en nodo _CAC_PRICINGREFERENCE para cuando no ���
���             �        �          �es un desc. ya que no se maneja como arreglo ���
���Luis Enriquez�31/07/18�DMINA-3376�Se valida existencia de _CAC_TAXTOTAL en fun.���
���(PERU)       �        �          �ObtIGV para corregir error.log en impresi�n. ���
���M.Camargo    �25/10/18�DMINA-4575�Implementaci�n UBL2.1                        ���
���(PERU)       �        �          �                                             ���
���Luis Enriquez�30/04/19�DMINA-6347�En funci�n ImpRef se agrega funcionalidad p/ ���
���             �        �          �imprimir m�s de una referencia. (PER)        ���
���M.Camargo    �06/06/19�DMINA-6777�En funci�n ImpDet se modifica los valores    ���
���             �        �          �precio unitario, valor unitario y total      ���
���             �        �          �para ser tomados de linextensionamoutn,      ���
���             �        �          �priceamount y price_priceamount respectiva-  ���
���             �        �          �mente.                                       ���
���M.Camargo    �14/06/19�DMINA-6838�En funci�n ImpDet se revierte posici�n de co-���
���             �        �          �lumnas precio unitario, valunitario y total. ���
���             �        �          �Se utiliza picture para nodos de valores y   ���
���             �        �          �cantidad que ser�n tomados de los campos     ���
���             �        �          �D2_PRCVEN,D2_QTD y D2_TOTAL 				  ���
���M.Camargo    �26/07/19�DMINA-7000�Se modifica IMPXMLODF para que detecte si el ���
���             �        �          �OSE es RSM, entonces muestre el PDF recupera-���
���             �        �          �do desde su sistema y no generar desde el xml���
���Oscar G.     �10/09/19�DMINA-7268�Se a�ade tratamiento para impuesto ICB en los���
���             �        �          ��tems y en los totales (PER)				  ���
���M.Camargo    �09/10/19�DMINA-7259�Se implementa uso de QRCode y se corrige nom-���
���             �        �          �bre de XML al enviar por email cuando ose es ���
���             �        �          �TCI                                          ���
���Marco A. Glez�24/09/20�DMINA-9639�Se agrega parametro para controlar el envio  ���
���             �        �          �del archivo .zip o archivos separados para la���
���             �        �          �FE de Peru.                                  ���
���Oscar G.     �12/01/21�DMINA-    �Se ajusta tama�o de impresion de c�digo QR   ���
���             �        �   10933  �cuando MV_CFDIQR = .T. (PER)				  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/
Function M486XMLPDF(cEspecie)	
	Local cPerg := "M486PDF"
	Private cSerie := ""
	Private cDocIni := ""
	Private cDocFin := ""
	Private cFormato := ""
	Private cPath := &(SuperGetmv( "MV_CFDDOCS" , .F. , "'cfd\recibos\'" )) + "\Autorizados\"
	Private oXML   := Nil
	Private nTotPag := 0
	Private oFont1 := TFont():New( "ARIAL", , 7, .F., .F.)
	Private oFont2 := TFont():New( "ARIAL", , 8, .F., .F.) 
	Private oFont3 := TFont():New( "ARIAL", , 10, .T., .T.)
	Private oFont4 := TFont():New( "ARIAL", , 8, .F., .T.) //Negrita - 8
	Private nLinea	:= 0
	Private cPicture := "999,999,999,999.99"
	
	cPath := Replace( cPath, "\\", "\" )
	
	If (alltrim(cEspecie) == "RFN" .And. SuperGetMV("MV_PROVFE",,"") != "RSM")
		MsgAlert(STR0093) //"Funcionalidad de impresi�n de Gu�as de Remisi�n electr�nicas no disponible para este OSE"
		
	ElseIf Pergunte(cPerg,.T.)
		cSerie 	:= MV_PAR01
		cDocIni := MV_PAR02
		cDocFin := MV_PAR03
		cFormato:= MV_PAR04
	
		Processa({|| ImpXmlPDF(cEspecie)},STR0046, STR0047) //"Espere.." "Generando impresi�n de documento autorizado"
	EndIf
Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ImpXmlPDF  � Autor � Luis Enriquez         � Data � 06.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Llamado de funciones para impresi�n de reporte PDF (PERU).   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpXmlPDF(cEspecie)                                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cEspecie .- Especie del documento.                           ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � No aplica.                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function ImpXmlPDF(cEspecie,lOnlyImp)
	Local cCampos 	:= ""
	Local cTablas 	:= ""
	Local cCond   	:= ""
	Local cOrder  	:= ""
	Local cAliasPDF	:= getNextAlias()
	Local aFiles 	:= {}
	Local nI     	:= 0
	Local cAviso	:= ""
	Local cErro		:= ""		
	Local oPrinter 
	Local nDec 		:= 0	
	Local aFileAux 	:= {}
	Local cFileAux 	:= ""
	Local cEmailCli	:= ""	
	Local cImpTot 	:= ""
	Local aOpcDoc 	:= {}
	Local lImpRef 	:= .F.
	Local nRegProc 	:= 0
	Local nRegEnv 	:= 0	
	Local lEnvOK 	:= .F.
	Local cCRLF		:= (chr(13)+chr(10))
	Local lTSS		:= SuperGetMV("MV_PROVFE",,"") == "TSS"  .or. Empty(SuperGetMV("MV_PROVFE",,""))
	Local cMod		:= ""
	Local cDirLocal	:= GetTempPath() 
	Local lNoEnvZip	:= SuperGetMV("MV_ENVZIP", .F., 1) == 2  //Indica envio de archivo ZIP o archivos por separado - 1 = Zip / 2 = Separados
	Local nFiles	:= 0
	
	Private cLetFac:= ""
	Private cLetPie := ""
	Private cTpoDocSA1 := ""
	Private aDoc 		:= {}	
	Private nRef 		:= 0
	Private cMonDoc	:= ""
	Private lPDFExp 	:= .F.
	Private cFileGen 	:= ""
	Private aItens 	:= {}
	Private cFile 		:= ""
	Private nLinEnc := 175

	Default lOnlyImp  := .T.
	
	If alltrim(cEspecie) $ "NF|NDC"	.Or. (alltrim(cEspecie) == "RFN" .And. SuperGetMV("MV_PROVFE",,"") == "RSM")	
		cCampos  := "% SF2.F2_FILIAL, SF2.F2_SERIE SERIE, SF2.F2_DOC DOCUMENTO, SF2.F2_ESPECIE ESPECIE, SF2.F2_CLIENTE CLIENTE, SF2.F2_LOJA LOJA, SF2.F2_MOEDA MONEDA,SF2.F2_SERIE2 SERIE2 %" 
		cTablas  := "% " + RetSqlName("SF2") + " SF2 %"
		cCond    := "% SF2.F2_SERIE = '"  + cSerie + "'"
		cCond    += " AND SF2.F2_DOC >= '"  + cDocIni + "'"
		cCond    += " AND SF2.F2_DOC <= '"  + cDocFin + "'"
		cCond    += " AND SF2.F2_ESPECIE = '"  + cEspecie + "'"
		cCond    += " AND SF2.F2_FLFTEX = '6'"
		cCond	 += " AND SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
		cCond	 += " AND SF2.D_E_L_E_T_  = ' ' %"
		cOrder := "% SF2.F2_FILIAL, SF2.F2_SERIE, SF2.F2_DOC %"
	ElseIf alltrim(cEspecie) $ "NCC"
		cCampos  := "% SF1.F1_FILIAL, SF1.F1_SERIE SERIE, SF1.F1_DOC DOCUMENTO, SF1.F1_ESPECIE ESPECIE, SF1.F1_FORNECE CLIENTE, SF1.F1_LOJA LOJA , SF1.F1_MOEDA MONEDA, SF1.F1_SERIE2 SERIE2 %" 
		cTablas  := "% " + RetSqlName("SF1") + " SF1 %"
		cCond    := "% SF1.F1_SERIE = '"  + cSerie + "'"
		cCond    += " AND SF1.F1_DOC >= '"  + cDocIni + "'"
		cCond    += " AND SF1.F1_DOC <= '"  + cDocFin + "'"
		cCond    += " AND SF1.F1_ESPECIE = '"  + cEspecie + "'"
		cCond    += " AND SF1.F1_FLFTEX = '6'"
		cCond	 += " AND SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
		cCond	 += " AND SF1.D_E_L_E_T_  = ' ' %"
		cOrder := "% SF1.F1_FILIAL, SF1.F1_SERIE, SF1.F1_DOC %"				
	EndIf		
		
	BeginSql alias cAliasPDF
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		ORDER BY %exp:cOrder%
	EndSql
	
	Count to nRegProc
	
	dbSelectArea(cAliasPDF)

	(cAliasPDF)->(DbGoTop())

	While (cAliasPDF)->(!Eof())
		aFiles := {}
		If lTSS
			aFiles := Directory(cPath + RTRIM((cAliasPDF)->SERIE) + RTRIM((cAliasPDF)->DOCUMENTO) + RTRIM((cAliasPDF)->ESPECIE) + '-ok.xml')
		Else
			cMod := getModelo(cModelo)
			aFiles := Directory(cPath + Alltrim(SM0->M0_CGC) + "-"+ cMod+ "-" + RTRIM((cAliasPDF)->SERIE2)+"-" + STRZERO(VAL(RTRIM((cAliasPDF)->DOCUMENTO)),8) +  '.xml')
		EndIf
		IF cMVPRovFE <> "RSM"
			For nI:= 1 to len(aFiles)
				nLinEnc := 175
				cFile := aFiles[nI,1]
				cFileGen := RTRIM((cAliasPDF)->SERIE) + RTRIM((cAliasPDF)->DOCUMENTO) + RTRIM((cAliasPDF)->ESPECIE)
				cCodCli	:= (cAliasPDF)->CLIENTE
				cCodLoja:= (cAliasPDF)->LOJA
				oXML := XmlParserFile(cPath + cFile, "_", @cAviso,@cErro)
				cMonDoc:= (cAliasPDF)->MONEDA					
				oPrinter := FWMSPrinter():New(cFileGen,6,.F.,GetClientDir(),.T.,,,,,.F.,,lOnlyImp)
				If alltrim((cAliasPDF)->ESPECIE) $ "NF|NDC"
					If alltrim((cAliasPDF)->ESPECIE) == "NF"
						oXML := oXml:_INVOICE
						
						cTpoDocSA1 := ObtColSAT("S006",oXml:_CAC_ACCOUNTINGCUSTOMERPARTY:_CAC_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_ID:_SCHEMEID:TEXT, 1, 1, 2,30)
						aDoc := StrTokArr( oXml:_CBC_ID:TEXT, "-" )
						aOpcDoc := {"_CAC_INVOICELINE","_CBC_INVOICEDQUANTITY","_CAC_LEGALMONETARYTOTAL"}
						nTotPag := IIf(ValType(oXml:_CAC_INVOICELINE) == "A",Len(oXml:_CAC_INVOICELINE) / 63, 1)	
						
						If Alltrim((cAliasPDF)->ESPECIE) == "NF" .AND. Substr(aDoc[1],1,1) $ 'F' // Factura
							cLetFac := STR0001 //"FACTURA ELECTR�NICA"
							cLetPie := STR0029 //"Representaci�n impresa de FACTURA ELECTR�NICA"
						ElseIf Alltrim(cEspecie) == "NF" .AND. Substr(aDoc[1],1,1) $ 'B' .AND. cTpoDocSA1 # "06" // Boleta de Venta
							cLetFac := STR0035 //"BOLETA ELECTR�NICA"
							cLetPie := STR0032 //"Representaci�n impresa de BOLETA ELECTR�NICA"
						EndIf	
	
						lImpRef := .F.					
					ElseIf alltrim((cAliasPDF)->ESPECIE) == "NDC"		
						oXML    := oXml:_DEBITNOTE
						aOpcDoc := {"_CAC_DEBITNOTELINE","_CBC_DEBITEDQUANTITY","_CAC_REQUESTEDMONETARYTOTAL"}
						nRef    := IIf(ValType(oXml:_CAC_DISCREPANCYRESPONSE) == "A",Len(oXml:_CAC_DISCREPANCYRESPONSE),1)
						nTotPag := IIf(ValType(oXml:_CAC_DEBITNOTELINE) == "A",(Len(oXml:_CAC_DEBITNOTELINE) + nRef) / 63, 1)
						
						cLetFac := STR0002 //"NOTA DE D�BITO ELECTR�NICA"
						cLetPie := ""
						cLetPie := STR0030 //"Representaci�n impresa de NOTA DE D�BITO ELECTR�NICA"
						lImpRef := .T.
					EndIf													
				ElseIf alltrim((cAliasPDF)->ESPECIE) $ "NCC"
					oXML 	:= oXml:_CREDITNOTE
					nRef   	:= IIf(ValType(oXml:_CAC_DISCREPANCYRESPONSE) == "A",Len(oXml:_CAC_DISCREPANCYRESPONSE),1)
					nTotPag := IIf(ValType(oXml:_CAC_CREDITNOTELINE) == "A",(Len(oXml:_CAC_CREDITNOTELINE) + nRef) / 63, 1)				
					aOpcDoc := {"_CAC_CREDITNOTELINE","_CBC_CREDITEDQUANTITY","_CAC_LEGALMONETARYTOTAL"}
					cLetFac	:= STR0003 //"NOTA DE CR�DITO ELECTR�NICA"
					cLetPie	:= STR0031  //"Representaci�n impresa de NOTA DE CR�DITO ELECTR�NICA"
					lImpRef	:= .T.
				EndIf
				
				nDec := nTotPag - Int(nTotPag)
				If nDec > 0
					nTotPag := Int(nTotPag) + 1
				EndIf
				
				oPrinter:setDevice(IMP_PDF)
				oPrinter:cPathPDF := GetClientDir()
				oPrinter:StartPage()
				ImpEnc(oPrinter,oXml, cCodCli, cCodLoja, @nLinEnc) //Encabezado
				DetFact(oPrinter,oXML,aOpcDoc,cCodCli,cCodLoja,nLinEnc) //Detalle
				If lImpRef
					ImpRef(oPrinter,oXml,cCodCli,cCodLoja) //Referencia
				EndIf
				ImpPie(oPrinter,oXML,aOpcDoc,cCodCli, cCodLoja) //Pie
				oPrinter:EndPage()
				
				oPrinter:Print()
				
				cFileAux := GetClientDir()  + cFileGen +".pdf"
				CpyT2S(cFileAux, cPath)
				
				If cFormato == 2
					aFileAux := {}
					aItens := {}
					
					aAdd( aItens, cPath + cFileGen + ".pdf" )
					
					If lTSS
						aAdd( aItens, cPath + cFileGen + "-ok.xml" )
					Else
						aAdd( aItens, cPath + cFile )
					EndIf
					
					If lNoEnvZip //Se realiza envio de archivos por separado
						For nFiles := 1 To Len(aItens)
							aAdd(aFileAux, StrTran( Upper(aItens[nFiles]), Upper(GetSrvProfString('RootPath','')))) //Se agrega PDF y XML como anexos
						Next nFiles
					Else
						cFile := cPath + cFileGen + ".zip"
						&('FZip(cFile, aItens, cPath )') //Se crea zip
						aAdd(aFileAux, StrTran( upper(cFile), upper(GetSrvProfString('RootPath','')))) //Se agrega zip como anexo
					EndIf
					
					cEmailCli := ObtEmail((cAliasPDF)->CLIENTE,(cAliasPDF)->LOJA)
					lEnvOK := EnvioMail(cEmailCli, aFileAux, lNoEnvZip)
					If lEnvOK
						nRegEnv += 1
					EndIf
					If !lNoEnvZip //Solo elimina cuando es archivo .zip
						For nI := 1 To Len(aFileAux)
							FErase(aFileAux[nI])
						Next nI
					EndIf
				EndIf
				FreeObj(oPrinter)
				oPrinter := Nil	
			Next nI
		Else
			For nI:=1 to len(aFiles)
				cFileGen := AllTrim(StrTran(aFiles[nI,1], ".XML", ""))
				CpyS2T( cPath + cFileGen + ".PDF", cDirLocal,,.F.) //Se copia archivo pdf
				ShellExecute("Open", cFileGen + ".PDF", "", cDirLocal, 1) //Se visualiza archivo pdf
				
				If cFormato == 2
					aFileAux := {}
					aItens := {}								
					aAdd( aItens, cPath + cFileGen + ".pdf" ) //Se agrega PDF
					aAdd( aItens, cPath + cFileGen + ".xml" ) //Se agrega XML
					
					If lNoEnvZip //Se realiza envio de archivos por separado
						For nFiles := 1 To Len(aItens)
							aAdd(aFileAux, StrTran( Upper(aItens[nFiles]), Upper(GetSrvProfString('Rootpath','')))) //Se agrega PDF y XML como anexos
						Next nFiles
					Else
						cFile := cPath + cFileGen + ".zip"
						&('FZip(cFile, aItens, cPath )') //Se crea zip
						aAdd(aFileAux, StrTran( Upper(cFile), Upper(GetSrvProfString('RootPath','')))) //Se agrega zip como anexo
					EndIf
					cEmailCli := ObtEmail((cAliasPDF)->CLIENTE,(cAliasPDF)->LOJA)
					lEnvOK := EnvioMail(cEmailCli, aFileAux, lNoEnvZip)
					If lEnvOK
						nRegEnv += 1
					EndIf
					If !lNoEnvZip //Solo elimina cuando es archivo .zip
						For nI := 1 To Len(aFileAux)
							FErase(aFileAux[nI])
						Next nI
					EndIf
				EndIf
			Next nI
			
		EndIf
		(cAliasPDF)->(dbskip())
	EndDo
	If Len(aFiles) == 0
		APMSGINFO(STR0036, STR0037) //"No se localizaron archivos XML autorizados, para generacion de reporte." "Aviso" 
	Else
		If lOnlyImp
			APMSGINFO(STR0043 + cCRLF + ; //"Generaci�n Representaci�n Impresa Finalizada"
					STR0044 + Str(nRegProc) + cCRLF + ; //"Registros procesados: "
					STR0045 + Str(nRegEnv) , STR0037) //"Registros enviados: "
		EndIf
	EndIf 
Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ImpEnc     � Autor � Luis Enriquez         � Data � 06.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime encabezado de factura a partir de XML (PERU).        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpEnc(oPrinter,oXml)                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oPrinter .- Objeto creado por FWMSPrinter.                   ���
���          � oXml .- Objeto con estructura de archivo XML.                ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � No aplica.                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ImpEnc(oPrinter,oXml,cCodCli,cCodLoja,nLinEnc,lImpED)
	Local oBrush
	Local cFileLogo	:= ""
	Local cRUCEmi  := STR0004 + oXml:_CAC_ACCOUNTINGSUPPLIERPARTY:_CBC_CUSTOMERASSIGNEDACCOUNTID:TEXT //"R.U.C. N� "
	Local cNoDoc   := STR0005 + oXml:_CBC_ID:TEXT //"N� "
	Local cNomEmi  := ""
	Local cDirEmi  := oXml:_CAC_ACCOUNTINGSUPPLIERPARTY:_CAC_PARTY:_CAC_PARTYLEGALENTITY:_CAC_REGISTRATIONADDRESS:_CAC_ADDRESSLINE:_CBC_LINE:TEXT
	Local cCiuEmi  := oXml:_CAC_ACCOUNTINGSUPPLIERPARTY:_CAC_PARTY:_CAC_PARTYLEGALENTITY:_CAC_REGISTRATIONADDRESS:_CBC_CITYNAME:TEXT
	Local cDistEmi := oXml:_CAC_ACCOUNTINGSUPPLIERPARTY:_CAC_PARTY:_CAC_PARTYLEGALENTITY:_CAC_REGISTRATIONADDRESS:_CBC_DISTRICT:TEXT
	Local cNomRec  := oXml:_CAC_ACCOUNTINGCUSTOMERPARTY:_CAC_PARTY:_CAC_PARTYLEGALENTITY:_CBC_REGISTRATIONNAME:TEXT
	Local cDirRec  := ""
	Local cRUCRec  := oXml:_CAC_ACCOUNTINGCUSTOMERPARTY:_CAC_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_ID:TEXT			
	Local cMonAux  := strZero(cMonDoc,2)
	Local cMonLetra	:= ALLTRIM(Posicione("CTO",1,xFilial("CTO")+cMonAux,"CTO_DESC"))
	Local cPagina 	:= Alltrim(Str(oPrinter:nPageCount)) + "/" + Alltrim(Str(nTotPag))
	Local cOrdComp	:= ""
	Local cFormaPago:= ""
	Local nLinTB    := 190
	Local nLinIni   := 190

	Default lImpED := .T.

	cNomEmi := ValorNodo("oXml:_CAC_ACCOUNTINGSUPPLIERPARTY:_CAC_PARTY","_CAC_PARTYLEGALENTITY","_CBC_REGISTRATIONNAME:TEXT")
	cDirRec := ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1")+cCodCli+cCodLoja,"A1_END") )	+", "
	cDirRec += ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1")+cCodCli+cCodLoja,"A1_BAIRRO")) 	+", "
	cDirRec += ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1")+cCodCli+cCodLoja,"A1_MUN"))		+", "
	cDirRec += ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1")+cCodCli+cCodLoja,"A1_CEP"))
	lPDFExp	:= POSICIONE("SA1",1,XFILIAL("SA1")+cCodCli+cCodLoja,"A1_EST")== "EX"	
    
	oPrinter:Box( 10, 355, 90, 580, "-4")
	
	cFileLogo := CargaLogo()
	
	nLinea := 10
	If File(cFilelogo)
		oPrinter:SayBitmap(nLinea,10,cFileLogo,50,50) // Impresion de logotipo
	EndIf
	nLinea += 40
	oPrinter:SayAlign(nLinea-7,190,cDirEmi,oFont1,160,5,CLR_BLACK, 2, 2 )
	nLinea += 10
	oPrinter:SayAlign(nLinea-7,190,cCiuEmi,oFont1,160,5,CLR_BLACK, 2, 2 )
	nLinea += 10
	oPrinter:SayAlign(nLinea+5,15,cNomEmi,oFont3,160,5,CLR_BLACK, 0, 2 )
	oPrinter:SayAlign(nLinea-7,190,cDistEmi,oFont1,160,5,CLR_BLACK, 2, 2 )
	
	oPrinter:SayAlign(25,390,cRUCEmi,oFont3,160,5,CLR_BLACK, 2, 2 ) //R.U.C. EMISOR
	oPrinter:SayAlign(45,390,cLetFac,oFont3,160,5,CLR_BLACK, 2, 2 ) //FACTURACION ELECTRONICA
	oPrinter:SayAlign(65,390,cNoDoc,oFont3,160,5,CLR_BLACK, 2, 2 )  //NO. FACTURA
	
	nLinea += 50
	oPrinter:Say(nLinea,15,STR0006,oFont4) //"Cliente"
	oPrinter:Say(nLinea,60,":",oFont4)
	oPrinter:Say(nLinea,65,cNomRec,oFont4)
	
	oPrinter:Say(nLinea,360,STR0007,oFont4) //"Fecha emisi�n"
	oPrinter:Say(nLinea,430,":",oFont4)
	oPrinter:Say(nLinea,435,ObtFecEmi(oXml),oFont4)
	
	oPrinter:Say(nLinea,500,STR0011,oFont4) //"P�gina"
	oPrinter:Say(nLinea,555,":",oFont4)	
	oPrinter:Say(nLinea,560,cPagina,oFont4)
	
	nLinea += 20
	oPrinter:Say(nLinea,15,STR0008,oFont4) //"Direcci�n"
	oPrinter:Say(nLinea,60,":",oFont4)
	oPrinter:Say(nLinea,65,cDirRec,oFont4)
	
	oPrinter:Say(nLinea,360,STR0009,oFont4) //"Tipo de moneda"
	oPrinter:Say(nLinea,430,":",oFont4)
	oPrinter:Say(nLinea,435,cMonLetra,oFont4)
	
	nLinea += 20
	oPrinter:Say(nLinea,15,STR0010,oFont4) //"R.U.C."
	oPrinter:Say(nLinea,60,":",oFont4)
	oPrinter:Say(nLinea,65,cRUCRec,oFont4)

	// Orden de compra si Existe
	cOrdComp := ValorNodo("oXml","_CAC_ORDERREFERENCE","_CBC_ID:TEXT")
	IF !Empty(cOrdComp)
		oPrinter:Say(nLinea,360,"Orden de Compra",oFont4) //"R.U.C."
		oPrinter:Say(nLinea,430,":",oFont4)
		oPrinter:Say(nLinea,435,cOrdComp,oFont4)
	EndIF

	//Forma de Pago
	If AttIsMemberOf(oXML, "_CAC_PAYMENTTERMS")
		If ValType(oXML:_CAC_PAYMENTTERMS) == "A"
			If AttIsMemberOf(oXML:_CAC_PAYMENTTERMS[1], "_CBC_ID")
				If oXML:_CAC_PAYMENTTERMS[1]:_CBC_ID:TEXT == "FormaPago"
					If AttIsMemberOf(oXML:_CAC_PAYMENTTERMS[1], "_CBC_PAYMENTMEANSID")
						cFormaPago := oXML:_CAC_PAYMENTTERMS[1]:_CBC_PAYMENTMEANSID:TEXT
					EndIf
				EndIf
			EndIf
		Else
			If AttIsMemberOf(oXML:_CAC_PAYMENTTERMS, "_CBC_ID")
				If oXML:_CAC_PAYMENTTERMS:_CBC_ID:TEXT == "FormaPago"
					If AttIsMemberOf(oXML:_CAC_PAYMENTTERMS, "_CBC_PAYMENTMEANSID")
						cFormaPago := oXML:_CAC_PAYMENTTERMS:_CBC_PAYMENTMEANSID:TEXT
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If !Empty(cFormaPago)
		nLinea += 20
		oPrinter:Say(nLinea,15,STR0095,oFont4) //"Forma de Pago"
		oPrinter:Say(nLinea,70,":",oFont4)
		oPrinter:Say(nLinea,75,cFormaPago,oFont4)
		nLinEnc += 15
		nLinTB += 15
		nLinea += 20
		nLinIni += 15
		lFormaPag := .T.
	Else
		nLinea += 25
	EndIf

	If lImpED
		//Cuadro gris 3 (Encabezado detalle)
		oBrush := TBrush():New( , CLR_LIGHTGRAY )  
		oPrinter:FillRect( {nLinEnc, 10, nLinTB, 580}, oBrush ) 
		
		//Lineas de marco gris

		oPrinter:Line(nLinEnc,10,nLinEnc,580,,"-4") 
		nLinEnc += 15
		oPrinter:Line(nLinEnc,10,nLinEnc,580,,"-4") 
    
		oPrinter:Say(nLinea,15,STR0012,oFont4)         //"CANTIDAD"
		oPrinter:Say(nLinea,70,STR0013,oFont4)         //"UNIDAD"
		oPrinter:Say(nLinea,110,STR0014,oFont4)        //"C�DIGO PRODUCTO"
		oPrinter:Say(nLinea,200,STR0015,oFont4)        //"DESCRIPCI�N"
		oPrinter:Say(nLinea,340,STR0016,oFont4)        //"PRECIO UNITARIO"
		oPrinter:Say(nLinea,430,STR0017,oFont4)        //"VALOR UNITARIO"
		oPrinter:Say(nLinea,530,STR0018,oFont4)        //"TOTAL"	
	EndIf		
	
	nLinea := nLinIni
	
Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DetFact    � Autor � Luis Enriquez         � Data � 06.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime detalle de factura a partir de XML (PERU).           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � DetFact(oPrinter,oXml)                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oPrinter .- objeto creado por FWMSPrinter.                   ���
���          � oXml .- Objeto con estructura de archivo XML.                ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � No aplica.                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function DetFact(oPrinter,oXml,aOpcDoc,cCodCli,cCodLoja,nLinEnc)
	Local nX := 0
	Local cPicQtd  := PESQPICT("SD2","D2_QUANT")
	Local cPicVal  := PESQPICT("SD2","D2_PRCVEN")
	Local cPicTotal	:= PESQPICT("SD2","D2_TOTAL") 
	Local nTotalI	:= 0
	Local nQuant 	:= 0
	Local aFormP    := {}
	Local nLinDet   := IIf(lFormaPag,190,175)

	nLFinD := 0
	
	If ValType(&("oXml:" + aOpcDoc[1] )) == "A"
		For nX := 1 to Len(&("oXml:" + aOpcDoc[1]))
		 	If nLinea > 815
			 	nLFinD := nLinea
		 		SaltoPag(oPrinter,cCodCli,cCodLoja)
			EndIf
			nTotalI := Val(&("oXml:" + aOpcDoc[1] + "[" + Str(nX) + "]" + ":_CAC_TAXTOTAL:_CBC_TAXAMOUNT:TEXT")) + Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CBC_LINEEXTENSIONAMOUNT:TEXT"))
			
			oPrinter:SayAlign(nLinea,10, alltrim(TRANSFORM(Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:" + aOpcDoc[2] + ":TEXT")),cPicQtd)),oFont2,45,10,CLR_BLACK, 1, 2 )                             //CANTIDAD
			oPrinter:SayAlign(nLinea,70,&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:" + aOpcDoc[2] + ":_UNITCODE:TEXT"),oFont2,27,10,CLR_BLACK, 2, 0 )                   //UNIDAD
			oPrinter:SayAlign(nLinea,110,&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_ITEM:_CAC_SELLERSITEMIDENTIFICATION:_CBC_ID:TEXT"),oFont2,73,10,CLR_BLACK, 2, 0 ) //C�DIGO DEL PRODUCTO
			oPrinter:SayAlign(nLinea,200,&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_ITEM:_CBC_DESCRIPTION:TEXT"),oFont2,130,10,CLR_BLACK, 0, 0 )                      //DESCRIPCI�N
			// valor unitario			
			If ValType(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE")) == "A"
				oPrinter:SayAlign(nLinea,428,TRANSFORM(Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE[2]:_CBC_PRICEAMOUNT:TEXT")),cPicVal),oFont2,58,10,CLR_BLACK, 1, 0 ) //VALOR UNITARIO
				If &("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE:_cbc_pricetypecode:text") == "01"
					nValItem := Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICE:_CBC_PRICEAMOUNT:TEXT"))
				Else
					nValItem := Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE[2]:_CBC_PRICEAMOUNT:TEXT"))
				EndIf 
			Else
				oPrinter:SayAlign(nLinea,428,TRANSFORM(Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE:_CBC_PRICEAMOUNT:TEXT")),cPicVal),oFont2,58,10,CLR_BLACK, 1, 0 ) //VALOR UNITARIO
				If &("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE:_cbc_pricetypecode:text") == "01"
					nValItem := Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICE:_CBC_PRICEAMOUNT:TEXT"))
				Else
					nValItem := Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE:_CBC_PRICEAMOUNT:TEXT"))
				EndIf 				
			EndIf 		
			oPrinter:SayAlign(nLinea,346,TRANSFORM(nValItem,cPicVal),oFont2,58,10,CLR_BLACK, 1, 0 ) // precio unitario			
			oPrinter:SayAlign(nLinea,515,TRANSFORM(Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CBC_LINEEXTENSIONAMOUNT:TEXT")),cPicTotal),oFont2,58,10,CLR_BLACK, 1, 0 ) //TOTAL 
			
			nLinea += 10
		Next nX
	Else
		nQuant := Val(&("oXml:" +  aOpcDoc[1] + ":" + aOpcDoc[2] + ":TEXT"))                             //CANTIDAD
		oPrinter:SayAlign(nLinea,10, ALLTRIM(TRANSFORM(nQuant,cPicQtd)),oFont2,45,10,CLR_BLACK, 1, 2 )                             //CANTIDAD
		oPrinter:SayAlign(nLinea,70,&("oXml:" +  aOpcDoc[1] + ":" + aOpcDoc[2] + ":_UNITCODE:TEXT"),oFont2,27,10,CLR_BLACK, 2, 0 )                   //UNIDAD
		oPrinter:SayAlign(nLinea,110,&("oXml:" +  aOpcDoc[1] + ":_CAC_ITEM:_CAC_SELLERSITEMIDENTIFICATION:_CBC_ID:TEXT"),oFont2,73,10,CLR_BLACK, 2, 0 ) //C�DIGO DEL PRODUCTO
		oPrinter:SayAlign(nLinea,200,&("oXml:" +  aOpcDoc[1] + ":_CAC_ITEM:_CBC_DESCRIPTION:TEXT"),oFont2,130,10,CLR_BLACK, 0, 0 )                      //DESCRIPCI�N
		
		// Valor unitario con impuesto x item 
		If ValType(&("oXml:" +  aOpcDoc[1] + ":_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE")) == "A"
			oPrinter:SayAlign(nLinea,428,TRANSFORM(Val(&("oXml:" +  aOpcDoc[1] + ":_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE[2]:_CBC_PRICEAMOUNT:TEXT")),cPicVal),oFont2,58,10,CLR_BLACK, 1, 0 )
			If &("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE:_cbc_pricetypecode:text") == "01"
				nValItem := Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICE:_CBC_PRICEAMOUNT:TEXT"))
			Else
				nValItem := Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE[2]:_CBC_PRICEAMOUNT:TEXT"))
			EndIf 			 
		Else
			oPrinter:SayAlign(nLinea,428,TRANSFORM(Val(&("oXml:" +  aOpcDoc[1] + ":_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE:_CBC_PRICEAMOUNT:TEXT")),cPicture),oFont2,58,10,CLR_BLACK, 1, 0 )
			If &("oXml:" +  aOpcDoc[1] + ":_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE:_cbc_pricetypecode:text") == "01"
				nValItem:= Val(&("oXml:" +  aOpcDoc[1] +":_CAC_PRICE:_CBC_PRICEAMOUNT:TEXT"))
			Else
				nValItem:= Val(&("oXml:" +  aOpcDoc[1] + ":_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE:_CBC_PRICEAMOUNT:TEXT"))
			EndIf 						
		EndIf	
		oPrinter:SayAlign(nLinea,346,alltrim(TRANSFORM(nValItem,cPicVal)),oFont2,58,10,CLR_BLACK, 1, 0 ) // Valor unitario										
		
		//TOTAL
		oPrinter:SayAlign(nLinea,515,TRANSFORM(Val(&("oXml:" + aOpcDoc[1] + ":_CBC_LINEEXTENSIONAMOUNT:TEXT")),cPicTotal),oFont2,58,10,CLR_BLACK, 1, 0 ) //PRECIO UNITARIO		
		nLinea += 10
	EndIf

	oPrinter:Line(nLinea,10,nLinea,580,,"-4")  //Linea final detalle
	nLFinD := nLinea
	oPrinter:Line(nLinDet,10,nLinea,10,,"-4")    //Linea 1
	oPrinter:Line(nLinDet,60,nLinea,60,,"-4")    //Linea 2
	oPrinter:Line(nLinDet,105,nLinea,105,,"-4")  //Linea 3
	oPrinter:Line(nLinDet,190,nLinea,190,,"-4")  //Linea 4
	oPrinter:Line(nLinDet,330,nLinea,330,,"-4")  //Linea 5
	oPrinter:Line(nLinDet,415,nLinea,415,,"-4")  //Linea 6
	oPrinter:Line(nLinDet,505,nLinea,505,,"-4")  //Linea 7
	oPrinter:Line(nLinDet,580,nLinea,580,,"-4")  //Linea 8
	

	If AttIsMemberOf(oXML, "_CAC_PAYMENTTERMS")
		If ValType(oXML:_CAC_PAYMENTTERMS) == "A"
			For nX := 2 To Len(oXML:_CAC_PAYMENTTERMS)
				If oXML:_CAC_PAYMENTTERMS[nX]:_CBC_ID:TEXT == "FormaPago" 
					If AttIsMemberOf(oXML:_CAC_PAYMENTTERMS[nX], "_CBC_PAYMENTMEANSID") .AND. AttIsMemberOf(oXML:_CAC_PAYMENTTERMS[nX], "_CBC_PAYMENTDUEDATE") 
						aAdd(aFormP,{ oXML:_CAC_PAYMENTTERMS[nX]:_CBC_PAYMENTMEANSID:TEXT, ; //Cuota
							          oXML:_CAC_PAYMENTTERMS[nX]:_CBC_AMOUNT:TEXT, ;         //Valor
							          oXML:_CAC_PAYMENTTERMS[nX]:_CBC_PAYMENTDUEDATE:TEXT}) //Fecha de Vencimiento
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

	If Len(aFormP) > 0
		nLinea += 15
		If nLinea > 815
			SaltoPag(oPrinter,cCodCli,cCodLoja)
		EndIf
		oPrinter:SayAlign(nLinea,10,STR0096,oFont4,45,10,CLR_BLACK, 1, 2 ) //"CUOTA"
		oPrinter:SayAlign(nLinea,70,STR0097,oFont4,60,10,CLR_BLACK, 2, 2 )  //"VALOR"
		oPrinter:SayAlign(nLinea,110,STR0098,oFont4,120,10,CLR_BLACK, 2, 2 ) //"FECHA VENCIMIENTO"
		nLinea += 10
		oPrinter:Line(nLinea,10,nLinea,220,,"-4") //580 
	EndIf
	
	For nX := 1 To Len(aFormP)
		nLinea += 10
		If nLinea > 815
			SaltoPag(oPrinter,cCodCli,cCodLoja,.F.)
		EndIf
		oPrinter:SayAlign(nLinea,10,Alltrim(aFormP[nX][1]),oFont2,45,10,CLR_BLACK, 1, 2 ) //CUOTA
		oPrinter:SayAlign(nLinea,70,Alltrim(TRANSFORM(Val(aFormP[nX][2]),cPicVal)),oFont2,60,10,CLR_BLACK, 2, 1 )  //VALOR
		oPrinter:SayAlign(nLinea,110,Alltrim(aFormP[nX][3]),oFont2,120,10,CLR_BLACK, 2, 2 ) //FECHA DE VENCIMIENTO
	Next nX
	
Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ImpRef     � Autor � Luis Enriquez         � Data � 10.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime docs de referencia para notas de debito/credito(PERU)���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpRef(oPrinter,oXml)                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oPrinter .- objeto creado por FWMSPrinter.                   ���
���          � oXml .- Objeto con estructura de archivo XML.                ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � No aplica.                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ImpRef(oPrinter,oXml,cCodCli,cCodLoja)
	Local cTipoDoc := ""
	Local nI       := 0
	
	If nLinea > 815
 		SaltoPag(oPrinter,cCodCli,cCodLoja)
	EndIf
	
	nLinea += 10
	
	oPrinter:Box(nLinea + 10, 10, nLinea, 580, "-4")
	oPrinter:SayAlign(nLinea,20,STR0038,oFont4,100,5,CLR_BLACK, 0, 2 ) //"TIPO DOCUMENTO"
	oPrinter:SayAlign(nLinea,130,STR0039,oFont4,100,5,CLR_BLACK, 0, 2 ) //"N� DOCUMENTO REF."
	oPrinter:SayAlign(nLinea,240,STR0040,oFont4,100,5,CLR_BLACK, 0, 2 ) //"MOTIVO REFERENCIA"
	
	oPrinter:Line(nLinea,105,nLinea + 10,105,,"-4")  
	oPrinter:Line(nLinea,230,nLinea + 10,230,,"-4")  
	
	nLinea += 10		
	
	If ValType(oXml:_CAC_BILLINGREFERENCE) == "A"
		For nI := 1 To Len(oXml:_CAC_BILLINGREFERENCE)		
			oPrinter:Line(nLinea,10,nLinea + 10,10,,"-4")
			oPrinter:Line(nLinea,105,nLinea + 10,105,,"-4")  
			oPrinter:Line(nLinea,230,nLinea + 10,230,,"-4")
			oPrinter:Line(nLinea,580,nLinea + 10,580,,"-4")		
			If oXml:_CAC_BILLINGREFERENCE[nI]:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_DOCUMENTTYPECODE:TEXT == '01'
				cTipoDoc := STR0041 //"FACTURA"
			ElseIf oXml:_CAC_BILLINGREFERENCE[nI]:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_DOCUMENTTYPECODE:TEXT== "03"
				cTipoDoc := STR0042 //"BOLETA"
			EndIf	
			oPrinter:SayAlign(nLinea,20,cTipoDoc,oFont2,70,5,CLR_BLACK, 2, 2 )
			oPrinter:SayAlign(nLinea,110,oXml:_CAC_BILLINGREFERENCE[nI]:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ID:TEXT,oFont2,110,5,CLR_BLACK, 2, 2 )
			oPrinter:SayAlign(nLinea,240,oXml:_CAC_DISCREPANCYRESPONSE:_CBC_DESCRIPTION:TEXT,oFont2,150,5,CLR_BLACK, 0, 2 )	
			nLinea += 10
			oPrinter:Line(nLinea,10,nLinea,580,,"-4")  //Linea final detalle
		Next nI
	Else
		oPrinter:Line(nLinea,10,nLinea + 10,10,,"-4")
		oPrinter:Line(nLinea,105,nLinea + 10,105,,"-4")  
		oPrinter:Line(nLinea,230,nLinea + 10,230,,"-4")
		oPrinter:Line(nLinea,580,nLinea + 10,580,,"-4")	
		If oXml:_CAC_BILLINGREFERENCE:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_DOCUMENTTYPECODE:TEXT == '01'
			cTipoDoc := STR0041 //"FACTURA"
		ElseIf oXml:_CAC_BILLINGREFERENCE:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_DOCUMENTTYPECODE:TEXT== "03"
			cTipoDoc := STR0042 //"BOLETA"
		EndIf
		oPrinter:SayAlign(nLinea,20,cTipoDoc,oFont2,70,5,CLR_BLACK, 2, 2 )
		oPrinter:SayAlign(nLinea,110,oXml:_CAC_DISCREPANCYRESPONSE:_CBC_REFERENCEID:TEXT,oFont2,110,5,CLR_BLACK, 2, 2 )
		oPrinter:SayAlign(nLinea,240,oXml:_CAC_DISCREPANCYRESPONSE:_CBC_DESCRIPTION:TEXT,oFont2,150,5,CLR_BLACK, 0, 2 )	
		nLinea += 10
		oPrinter:Line(nLinea,10,nLinea,580,,"-4")  //Linea final detalle	
	EndIf
	
		
Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ImpPie     � Autor � Luis Enriquez         � Data � 06.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir pie de reporte de factura a partir de XML (PERU).   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpPie(oPrinter,oXml,cCodBar)                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oPrinter .- objeto creado por FWMSPrinter.                   ���
���          � oXml .- Objeto con estructura de archivo XML.                ���
���          � cCodBar .- String de texto para c�digo de barra.             ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � No aplica.                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ImpPie(oPrinter,oXml,aOpcDoc,cCodCli,cCodLoja)	
	Local cMontoStr	:= ""
	Local nI 		:= 0
	Local aAdic 	:= {}
	Local nPos 		:= 0
	Local cCodBarra	:= ""
	Local nTotal 	:= Val(&("oXml:" + aOpcDoc[3] + ":_CBC_PAYABLEAMOUNT:TEXT")) 
	Local lQrCode	:= SuperGetMV("MV_CFDIQR", .F., .T.) //Define impresion de QR, cuando no se cuenta con librerias actualizadas para generacion de QR.
	Local nIGVExp	:= 0
	Local cTxtGrat	:= ""
	Local cMonTot	:= ""
	
	cMontoStr := STR0019 // *** SON:
	If Valtype(OXML:_CBC_NOTE) == "A"
		For nI:= 1 to len(OXML:_CBC_NOTE)
			If nI == 1
				cMontoStr+= OXML:_CBC_NOTE[1]:TEXT 
			Else
				cTxtGrat+= OXML:_CBC_NOTE[2]:TEXT 
			EndIF
		Next nI
	Else
		cMontoStr := STR0019 + OXML:_CBC_NOTE:TEXT
	EndIf	
	
	//Codigo de barras
	cCodBarra := GenCodBar(oXml,aOpcDoc)
	
	If ValType(oXml:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL) == "A"
		For nI := 1 To Len(oXml:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL)
			If XmlChildEx( oXml:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL[nI], "_CBC_TAXABLEAMOUNT" ) <> Nil
				cMonTot := oXml:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL[nI]:_CBC_TAXABLEAMOUNT:TEXT
			Else
				cMonTot := oXml:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL[nI]:_CBC_TAXAMOUNT:TEXT
			EndIf
			aAdd(aAdic,{oXml:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL[nI]:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT, cMonTot})
		Next nI
	Else
		aAdd(aAdic,{oXml:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT,;
					oXml:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL:_CBC_TAXABLEAMOUNT:TEXT})
	EndIf
	// Busca Descuentos y Otros Cargos
	If AttIsMemberOf(oXML, "_CAC_ALLOWANCECHARGE")
		If ValType(OXML:_CAC_ALLOWANCECHARGE) == "A"
			For nI := 1 To Len(OXML:_CAC_ALLOWANCECHARGE)
				aAdd(aAdic,{OXML:_CAC_ALLOWANCECHARGE[nI]:_CBC_ALLOWANCECHARGEREASONCODE:TEXT,;
							OXML:_CAC_ALLOWANCECHARGE[nI]:_CBC_AMOUNT:TEXT})
			Next nI
		Else
			aAdd(aAdic,{OXML:_CAC_ALLOWANCECHARGE:_CBC_ALLOWANCECHARGEREASONCODE:TEXT,;
						OXML:_CAC_ALLOWANCECHARGE:_CBC_AMOUNT:TEXT})
		EndIf	
	EndIf
	
 	If nLinea > 699
 		SaltoPag(oPrinter,cCodCli,cCodLoja)
	EndIf

	nLinea := 650
	oPrinter:Box( 	nLinea + 153, 330, nLinea, 580, "-4")
	oPrinter:Line(	nLinea + 153, 490, nLinea, 490,,"-4") 
	
	nLinea += 10	
	oPrinter:Say(nLinea,350,STR0020,oFont4) //"Operaci�n Gravada"
	nPos := aScan(aAdic,{|x| x[1] == '1000' })
	oPrinter:SayAlign(nLinea-7,515,IIf(nPos > 0,TRANSFORM(Val(aAdic[nPos][2]),cPicture),"0.00"),oFont2,58,5,CLR_BLACK, 1, 1 )
	If lQrCode
		oPrinter:SayAlign(nLinea-30,330,cMontoStr,oFont1,350,5,CLR_BLACK, 0, 1 )
	Else
		oPrinter:SayAlign(nLinea-10,15,cMontoStr,oFont1,350,5,CLR_BLACK, 0, 1 )
	EndIf
		
	If !Empty(cTxtGrat)
		oPrinter:SayAlign(nLinea,15,cTxtGrat,oFont1,350,5,CLR_BLACK, 0, 1 )	
	EndIf
	nLinea += 10	
	oPrinter:Say(nLinea,350,STR0021,oFont4) //"Operaci�n Inafecta"
	nPos := aScan(aAdic,{|x| x[1] == '9998' })
	oPrinter:SayAlign(nLinea-7,515,IIf(nPos > 0,TRANSFORM(Val(aAdic[nPos][2]),cPicture),"0.00"),oFont2,58,5,CLR_BLACK, 1, 1 )

	nLinea += 10
	oPrinter:Say(nLinea,350,STR0022,oFont4) //"Operaci�n Exonerada"
	nPos := aScan(aAdic,{|x| x[1] == '9997' })
	oPrinter:SayAlign(nLinea-7,515,IIf(nPos > 0,TRANSFORM(Val(aAdic[nPos][2]),cPicture),"0.00"),oFont2,58,5,CLR_BLACK, 1, 1 )
	If lQrCode
		oPrinter:QRCode(nLinea+150,20, cCodBarra , 192)	
	Else		
		oPrinter:pdf417(nLinea + 50,20, cCodBarra , 192, 64)	
	EndIf
	nLinea += 10	
	oPrinter:Say(nLinea,350,STR0023,oFont4) //"Operaci�n Gratuita"
	nPos := aScan(aAdic,{|x| x[1] == '9996' })
	oPrinter:SayAlign(nLinea-7,515,IIf(nPos > 0,TRANSFORM(Val(aAdic[nPos][2]),cPicture),"0.00"),oFont2,58,5,CLR_BLACK, 1, 1 )
	
	nLinea += 10	
	oPrinter:Say(nLinea,350,STR0081,oFont4) //"Exportaciones"
	nPos := aScan(aAdic,{|x| x[1] == '9995' })
	oPrinter:SayAlign(nLinea-7,515,IIf(nPos > 0,TRANSFORM(Val(aAdic[nPos][2]),cPicture),"0.00"),oFont2,58,5,CLR_BLACK, 1, 1 )
	
	nLinea += 10
	oPrinter:Say(nLinea,350,STR0024,oFont4) //"Perpeciones"	
	nPos := aScan(aAdic,{|x| x[1] == '2001' })
	oPrinter:SayAlign(nLinea-7,515,IIf(nPos > 0,TRANSFORM(Val(aAdic[nPos][2]),cPicture),"0.00"),oFont2,58,5,CLR_BLACK, 1, 1 )
	
	nLinea += 10
	oPrinter:Say(nLinea,350,STR0025,oFont4) //"Retenciones"
	nPos := aScan(aAdic,{|x| x[1] == '2002' })
	oPrinter:SayAlign(nLinea-7,515,IIf(nPos > 0,TRANSFORM(Val(aAdic[nPos][2]),cPicture),"0.00"),oFont2,58,5,CLR_BLACK, 1, 1 )	
	
	nLinea += 10
	oPrinter:Say(nLinea,350,STR0026,oFont4) //"Detracciones"	
	nPos := aScan(aAdic,{|x| x[1] == '2003' })
	oPrinter:SayAlign(nLinea-7,515,IIf(nPos > 0,TRANSFORM(Val(aAdic[nPos][2]),cPicture),"0.00"),oFont2,58,5,CLR_BLACK, 1, 1 )	
	
	nLinea += 10
	oPrinter:Say(nLinea,350,STR0027,oFont4) //"Bonificaciones"
	oPrinter:SayAlign(nLinea-7,515,"0.00",oFont2,58,5,CLR_BLACK, 1, 1 )
	
	nLinea += 10
	oPrinter:Say(nLinea,350,STR0028,oFont4) //"Importe de descuento"
	nPos := aScan(aAdic,{|x| x[1] == '00' })
	oPrinter:SayAlign(nLinea-7,515,IIf(nPos > 0,TRANSFORM(Val(aAdic[nPos][2]),cPicture),"0.00"),oFont2,58,5,CLR_BLACK, 1, 1 )
	
	nLinea += 10
	oPrinter:Say(nLinea,350,STR0080,oFont4) //""Otros Cargos""
	nPos := aScan(aAdic,{|x| x[1] == '50' })

	oPrinter:SayAlign(nLinea-7,515,IIf(nPos > 0,TRANSFORM(Val(aAdic[nPos][2]),cPicture),"0.00"),oFont2,58,5,CLR_BLACK, 1, 1 )
	If lQrCode
		oPrinter:SayAlign(nLinea+60,320,cLetPie,oFont4,200,10,CLR_BLACK, 2, 0 )  //"Representaci�n impresa de FACTURA ELECTR�NICA/NOTA DE D�BITO ELECTR�NICA/NOTA DE CR�DITO ELECTR�NICA"
	Else
		oPrinter:SayAlign(nLinea,10,cLetPie,oFont4,200,10,CLR_BLACK, 2, 0 ) // //"Representaci�n impresa de FACTURA ELECTR�NICA/NOTA DE D�BITO ELECTR�NICA/NOTA DE CR�DITO ELECTR�NICA"
	EndIf
	
	nLinea += 10
	oPrinter:Say(nLinea,350,STR0033,oFont4) //"I.G.V." 
	
	If lPDFExp
		nIGVExp := Val(ObtIGV(oXml,'EXP'))
	Else
		nIGVExp := Val(ObtIGV(oXml,'IGV'))
	EndIf
	oPrinter:SayAlign(nLinea-7,515,TRANSFORM(nIGVExp,cPicture),oFont2,58,5,CLR_BLACK, 1, 1 )
	
	nLinea += 10
	oPrinter:Say(nLinea,350,STR0082,oFont4) //"I.S.C." 
	oPrinter:SayAlign(nLinea-7,515,TRANSFORM(Val(ObtIGV(oXml,'ISC')),cPicture),oFont2,58,5,CLR_BLACK, 1, 1 )

	nLinea += 10	
	oPrinter:Say(nLinea,350,STR0083,oFont4) //"ICBPER"
	nPos := aScan(aAdic,{|x| x[1] == '7152' })
	oPrinter:SayAlign(nLinea-7,515,IIf(nPos > 0,TRANSFORM(Val(aAdic[nPos][2]),cPicture),"0.00"),oFont2,58,5,CLR_BLACK, 1, 1 )

	nLinea += 10
	oPrinter:Say(nLinea,350,STR0034,oFont4) //"IMPORTE TOTAL"	
	oPrinter:SayAlign(nLinea-7,515,TRANSFORM(nTotal,cPicture),oFont2,58,5,CLR_BLACK, 1, 1 )
Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � EnvioMail  � Autor � Luis Enriquez         � Data � 06.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Carga logo de la empresa (PERU).                             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � EnvioMail(cEmailC, aAnexo)                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cEmailC .- Email del cliente para envio de archivo XML/PDF.  ���
���          � aAnexo .- Arreglo con archivos adjuntos.                     ���
���          � lNoEnvZip .- .T. si envia Zip, .F. Envia archivos separados. ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lResult .- Valor l�gico .T. envio exitoso, .F. error de envio���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function EnvioMail(cEmailC, aAnexo, lNoEnvZip)
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
		cMsg += STR0088 + STR0089 + CHR(13) + CHR(10) //"Configure par�metro " "MV_RELSERV" 
	EndIf
	If Empty(cEmail)
		cMsg += STR0088 + STR0090 + CHR(13) + CHR(10) //"Configure par�metro " "MV_RELACNT"
	EndIf
	If Empty(cPassword)
		cMsg += STR0088 + STR0091 + CHR(13) + CHR(10) // "Configure par�metro " "MV_RELPSW"
	EndIf
	If Empty(cEmailC)
		cMsg += STR0092 + CHR(13) + CHR(10) // "Configure email del cliente."
	EndIf
	
	If !Empty(cMsg)
		ApMsgInfo(cMsg, STR0094) //"Configuraci�n"
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
					Help(" ",1,STR0087,,cError,4,5)
				EndIf

			Else
				//Erro na conexao com o SMTP Server
    			GET MAIL ERROR cError                                       
    			Help(" ",1,STR0087,,cError,4,5) //--- Aviso    

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
		                               
		    //Defini��o do timeout do servidor
			If oMailServer:SetSmtpTimeOut(120) != 0
		   		Help(" ",1,STR0037,,OemToAnsi(STR0085) ,4,5) //"Aviso" ## "Tiempo de Servidor"
		   		Return .F.
		   	EndIf
		
		   	//Conex�o com servidor
		   	nErr := oMailServer:smtpConnect()
		   	If nErr <> 0
		   		cTrErr:= oMailServer:getErrorString(nErr)
		    	oMailServer:smtpDisconnect()
		    	
		    	// Intenta (varias veces) el env�o a trav�s de otra clase de conexi�n
		    	lResult := EnvioMail2(cServer, cEmail, cPassword, lAuth, cEmailC, cLetFac, cLetPie, aAnexo, @cTrErr)
		    	
		    	If !lResult
			   		Help(" ",1,STR0087,,ctrErr,4,5) //"Aviso"
				EndIf

				Return lResult
		   	EndIf

		   	//Autentica��o com servidor smtp
		   	nErr := oMailServer:smtpAuth(cEmail, cPassword)
		   	If nErr <> 0
		    	cTrErr := OemToAnsi(STR0086) + CRLF + oMailServer:getErrorString(nErr)
		     	oMailServer:smtpDisconnect()

		    	// Intenta (varias veces) el env�o a trav�s de otra clase de conexi�n
		    	lResult := EnvioMail2(cServer, cEmail, cPassword, lAuth, cEmailC, cLetFac, cLetPie, aAnexo, @cTrErr)
		    	
		    	If !lResult
			     	Help(" ",1,STR0037,,cTrErr ,4,5)//"Aviso" ## "Autenticaci�n con servidor smtp"
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
		   			oMessage:AddAtthTag( 'Content-Disposition: attachment; filename=' + M486RemPat(aAnexo[nX])) //Essa tag, � a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
		   		Else
		   			oMessage:AddAttHTag("Content-ID: <" + aAnexo[nX] + ">") //Essa tag, � a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
		   		EndIf
		   	Next nX
		                               
			//Dispara o email          
			nErr := oMessage:send(oMailServer)
			If nErr <> 0
		   		cTrErr := oMailServer:getErrorString(nErr)
		     	Help(" ",1,STR0037,,OemToAnsi(STR0087) + CRLF + cTrErr ,4,5)//"Aviso" ## "Error en el Envio del Email"
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

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � fCarLogo   � Autor � Luis Enriquez         � Data � 06.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Carga logo de la empresa (PERU).                             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � CargaLogo()                                                  ���
���������������������������������������������������������������������������Ĵ��
���Parametros� No aplica.                                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � cLogo .- Retorna url de ubicaci�n de logo de empresa.        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function CargaLogo()
	Local  cStartPath:= GetSrvProfString("Startpath","")

	cLogo	:= cStartPath + "ADMIN	"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial
	//-- Logotipo da Empresa
	If !File( cLogo )
		cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	EndIf
Return cLogo

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � SaltoPag   � Autor � Luis Enriquez         � Data � 06.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Genera salto de p�gina en reporte (PERU).                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � SaltoPag(oPrinter)                                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oPrinter .- objeto creado por FWMSPrinter.                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � No aplica.                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function SaltoPag(oPrinter,cCodCli,cCodLoja,lImpED)	
	Local nIniLin := IIf(lFormaPag,190,175)

	Default lImpED := .T.

	oPrinter:Line(nIniLin,10,nLFinD,10,,"-4")  //Linea 1
	oPrinter:Line(nIniLin,60,nLFinD,60,,"-4")  //Linea 2
	oPrinter:Line(nIniLin,105,nLFinD,105,,"-4")  //Linea 3
	oPrinter:Line(nIniLin,190,nLFinD,190,,"-4")  //Linea 4
	oPrinter:Line(nIniLin,330,nLFinD,330,,"-4")  //Linea 5
	oPrinter:Line(nIniLin,415,nLFinD,415,,"-4")  //Linea 6
	oPrinter:Line(nIniLin,505,nLFinD,505,,"-4")  //Linea 7
	oPrinter:Line(nIniLin,580,nLFinD,580,,"-4")  //Linea 8

	oPrinter:Line(nLFinD,10,820,580,,"-4")
			
	oPrinter:EndPage()

	nLinEnc := 175
	
	oPrinter:StartPage()
	ImpEnc(oPrinter,oXml,cCodCli,cCodLoja,@nLinEnc,lImpED)	
Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ObtEmail   � Autor � Luis Enriquez         � Data � 06.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Obtiene valor de impuesto IGV de XML (PERU).                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtEmail(cCliente,cLoja)                                     ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cCliente .- C�digo de cliente.                               ���
���          � cLoja .- Tienda de cliente.                                  ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � cEmailCli .- Email configurado para cliente (A1_EMAIL).      ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ObtEmail(cCliente,cLoja)
	Local cEmailCli := ""
	Local aArea 	:= getArea()
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA                                                                                                                                                 
	If SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
		cEmailCli := SA1->A1_EMAIL
	EndIf
	RestArea(aArea)	
Return cEmailCli

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ObtIGV     � Autor � Luis Enriquez         � Data � 06.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Obtiene valor de impuesto IGV de XML (PERU).                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtIGV(oXml,cImp)                                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oXml .- Objeto con estructura de archivo XML.                ���
���          � cImp .- String con el nombre de impuesto a obtener de XML.   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � cValImp .- Valor de importe contenido en archivo XML.        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ObtIGV(oXml,cImp)
	Local aImptosAux := {}
	Local aImptos    := {}
	Local nPos       := 0
	Local cValImp    := ""
	Local nI := 0
	Local lTaxTotal  := XmlChildEx( oXML, "_CAC_TAXTOTAL" ) <> Nil
	
	If lTaxTotal
		aImptosAux := oXml:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL
	
		If ValType(aImptosAux) == "A"
			For nI := 1 To Len(aImptosAux)
				aAdd(aImptos, {aImptosAux[nI]:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_NAME:TEXT,aImptosAux[nI]:_CBC_TAXAMOUNT:TEXT}) 
			Next nI
		Else
			aAdd(aImptos, {oXml:_CAC_TAXTOTAL:_CAC_TAXSUBTOTAL:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_NAME:TEXT,;
							oXml:_CAC_TAXTOTAL:_CBC_TAXAMOUNT:TEXT})
		EndIf
		
		nPos := aScan(aImptos,{|x| x[1] == cImp })
		
		cValImp := IIf(nPos > 0,aImptos[nPos][2],"0.00")
	EndIf	
Return cValImp

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ObtFecEmi  � Autor � Luis Enriquez         � Data � 06.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Obtiene valor de fecha de emision de XML (PERU)              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtFecEmi(oXml)                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oXml .- Objeto con estructura de archivo XML.                ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � cFecEmi .- Valor string con la fecha de emision.             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ObtFecEmi(oXml)
	Local cFecEmi  := Replace(oXml:_CBC_ISSUEDATE:TEXT,"-","")
	cFecEmi  := Substr(cFecEmi,7,2) + "-" + Substr(cFecEmi,5,2) + "-" +;		
		               Substr(cFecEmi,0,4)
Return cFecEmi

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � GenCodBar  � Autor � Luis Enriquez         � Data � 07.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Genera c�digo de barras reporte de factura (PERU)            ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GenCodBar(oXml)                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oXml .- Objeto con estructura de archivo XML.                ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � cCodBarra .- Cadena de caracteres que seran mostrados en el  ���
���          � codigo de barras.                                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GenCodBar(oXml,aOpcDoc)
	Local cValFirma := ""
	Local cRucEmiso := ""
	Local cRUCRecep := ""
	Local cTpoDoc := ""
	Local cCodBarra := ""	

	aDoc := StrTokArr( oXml:_CBC_ID:TEXT, "-" )
	cValFirma	:= ValorNodo("oXml:_EXT_UBLEXTENSIONS:_EXT_UBLEXTENSION:_EXT_EXTENSIONCONTENT","_SIGNATURE","_SIGNATUREVALUE:TEXT")
	cImpTot 	:= &("oXml:" + aOpcDoc[3] + ":_CBC_PAYABLEAMOUNT:TEXT")
	cRucEmiso 	:= oXml:_CAC_ACCOUNTINGSUPPLIERPARTY:_CBC_CUSTOMERASSIGNEDACCOUNTID:TEXT
	cRUCRecep 	:= oXml:_CAC_ACCOUNTINGCUSTOMERPARTY:_CAC_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_ID:TEXT
	cTpoDocSA1 	:= oXml:_CAC_ACCOUNTINGCUSTOMERPARTY:_CAC_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_ID:_SCHEMEID:TEXT
	If Alltrim(cEspecie) == "NF" .AND. Substr(aDoc[1],1,1) $ 'F' // Factura
		cTpoDoc := '01'
	ElseIf Alltrim(cEspecie) == "NF" .AND. Substr(aDoc[1],1,1) $ 'B' .AND. cTpoDocSA1 # "06" // Boleta de Venta
		cTpoDoc := '03'
	ElseIf Alltrim(cEspecie) == "NCC"
		cTpoDoc := '07'
	ElseIf Alltrim(cEspecie) == "NDC"
		cTpoDoc := '08'
	EndIf					
	 					 				
	cCodBarra := Alltrim(cRucEmiso) + ;
		"|" + Alltrim(cTpoDoc) + "|" + Alltrim(Substr(aDoc[1],1,1)) + "|" + Alltrim(aDoc[2]) + ;
		"|" + Alltrim(ObtIGV(oXml,'IGV')) + "|" + Alltrim(cImpTot) + "|" + Alltrim(ObtFecEmi(oXml)) + ;
		"|" + Alltrim(cTpoDocSA1) + "|" + Alltrim(cRUCRecep) + "|" + Alltrim(cValFirma)
Return cCodBarra			

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ValorNodo  � Autor � Luis Enriquez         � Data � 11.07.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Obtiene valor de nodo de XML validando existencia (PERU)     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ValorNodo(cXML,cBusca,cValor)                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cXML .- Cadena del objeto donde se realizara busqueda XML.   ���
���Parametros� cBusca .- Cadena de objeto a ser buscada.                    ���
���Parametros� cValor .- Valor del objeto a ser devuelto.                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � cResultado .- Valor obtenido del objeto XML.                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486XMLPDF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ValorNodo(cXML,cBusca,cValor)
	Local cResultado := ""
	
	If AttIsMemberOf(&(cXML), cBusca)
		If Valtype(&(cXML + ":" + cBusca )) <> "A"
			cResultado := &(cXML + ":" + cBusca + ":" + cValor)
		Else
			cResultado := &(cXML + ":" + cBusca + "[1]:" + cValor)
		EndIf
	EndIf
Return	cResultado		

/*/{Protheus.doc} EnvioMail2
//TODO Descri��o auto-gerada.
@author arodriguez
@since 10/01/2020
@version 1.0
@return l�gico, env�o correcto?
@param cMailServer, characters, direcci�n de servidor de correo
@param cMailConta, characters, usuario de conexi�n / cuenta de correo remitente
@param cMailSenha, characters, contrase�a del usuario
@param lAutentica, logical, requiere autenticaci�n?
@param cEmail, characters, correo destinatario (cliente)
@param cEMailAst, characters, asunto
@param cMensGral, characters, contenido
@param aAnexo, array, array de anexos
@param cErr, characters, (@referencia) variable para mensaje de error
@type function
/*/
Static Function EnvioMail2(cMailServer, cMailConta, cMailSenha, lAutentica, cEmail, cEMailAst, cMensGral, aAnexo, cErr)
	Local cAcAut	:= GetMV("MV_RELAUSR",,"" )		//Usuario para autenticacion en el servidor de email
	Local cPwAut 	:= GetMV("MV_RELAPSW",,""  )	//Contrase�a para autenticacion en servidor de email
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

/*/{Protheus.doc} M486RemPat
Funci�n utilizada para remover el path a un archivo.
@author Marco Augsto Gonzalez Rivera
@since 23/09/2020
@version 1.0
@type Static Function
@param cFile, Char, Nombre de archivo con Path
@return cFileName, Char, Nombre del archivo sin path
/*/
Static Function M486RemPat(cFile)

	Local cFileName := ""
	
	Default cFile := ""
	
	If (rAt("\", cFile) > 0 )
	   cFileName := SubStr(cFile, rAt("\", cFile) + 1, Len(cFile))
	EndIf
	
Return cFileName
