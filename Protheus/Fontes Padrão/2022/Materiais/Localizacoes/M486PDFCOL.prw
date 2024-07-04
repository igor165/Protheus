#include 'protheus.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FONT.CH"
#INCLUDE "M486XMLPDF.CH"

// #########################################################################################
// Projeto: FE Colombia
// Modulo : SIGAFAT
// Fonte  : M486PDFCOL.PRW
// -----------+-------------------+---------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+---------------------------------------------------------
// 20/08/2018 | A. Rodriguez      | fac-e v.20 actualizaciones ImpXmlPDF, ObtImptos (COL)
// 05/10/2018 | A. Rodriguez      | Datos correctos para generación del QR-Code
//            |                   | Impresión correcta del QR-Code
//            |                   | Envío de email sin borrar xml y pdf
//            |                   | Impresión correcta de impuestos/retenciones
// 09/10/2018 | A. Rodriguez      | Importe en letra con formato de Colombia (Loc en MATXFUNC)
//            |                   | QR-Code en NDC y NCC
// 15/10/2018 | A. Rodriguez      | Imprimir descuento
// 21/11/2018 | Luis Enríquez     | Se elimina decodeUTF2 en obtención de cadena de autoretenciones
//            |                   | y se elimina bifurcación para mostrar impuestos para extranjeros
// 13/06/2019 | Alfredo Medrano   | En fun ImpEnc() se valida valor nulo del tag MIDDLENAME
//            |                   | En fun ImpXmlPDF() para notas de débito se quita tag FE_ITEM y se asigna CAC_ITEM
//17/02/2020  |Andres Sanodval    | Se agrega funcionalidad para envio por Email para documentos electronicos.
// 02/07/2020 | Luis Enríquez     | Cambio de la clase DescargaXML por GenerarContenedor
// -----------+-------------------+---------------------------------------------------------

/*/{Protheus.doc} M486PDFCOL
Rutina para creación y/o envio de reporte en formato PDF generado
a partir de XML timbrado por la DIAN (COL).
@type function
@author mayra.camargo
@since 17/05/2018
@version 1.0
@param cEspecie, character, Especie del Documento
/*/
Function M486PDFCOL(cEspecie)
 	Local cPerg := "M486PDF"
	Private cSerie := ""
	Private cDocIni := ""
	Private cDocFin := ""
	Private nFormato := 0
	Private cPath := &(SuperGetmv( "MV_CFDDOCS" , .F. , "'cfd\facturas\'" )) + "\autorizados\"
	Private oXML   := Nil
	Private nTotPag := 0
	Private oFont1 := TFont():New( "ARIAL", , 7, .F., .F.)
	Private oFont2 := TFont():New( "ARIAL", , 8, .F., .F.)
	Private oFont3 := TFont():New( "ARIAL", , 10, .T., .T.)
	Private oFont4 := TFont():New( "ARIAL", , 8, .F., .T.) //Negrita - 8
	Private oFont5 := TFont():New( "ARIAL", , 12, .F., .T.) //Negrita - 12
	Private oFont6 := TFont():New( "ARIAL", , 10, .F., .F.)
	Private nLinea	:= 0
	Private cPicture := "@E 99,999,999,999.99"
	Private cPicture2 := "@E 99999999999.99"
	Private aImptos := {}

	cPath := Replace( cPath, "\\", "\" )

	If Pergunte(cPerg,.T.)
		cSerie := MV_PAR01
		cDocIni := MV_PAR02
		cDocFin := MV_PAR03
		nFormato := MV_PAR04

		Processa({|| ImpXmlPDF(cEspecie)},STR0046, STR0047)// "Espere.." "Generando impresión de documento autorizado"
	EndIf
Return Nil
/*/{Protheus.doc} ImpXmlPDF
Llamado de funciones para impresión de reporte PDF
@type function
@author mayra.camargo
@since 17/05/2018
@version 1.0
@param cEspecie, character,  Especie del documento.
/*/
Static Function ImpXmlPDF(cEspecie)
	Local cCampos := ""
	Local cTablas := ""
	Local cCond   := ""
	Local cOrder  := ""
	Local cAliasPDF := getNextAlias()
	Local aFiles := {}
	Local nI     := 0
	Local cAviso			:= ""
	Local cErro			:= ""
	Local oPrinter
	Local cFile := ""
	Local cFileGen := ""
	Local nDec := 0
	Local aItens := {}
	Local cArq := ""
	Local aFileAux := {}
	Local cFileAux := ""
	Local cEmailCli := ""
	Local cImpTot := ""
	Local aOpcDoc := {}
	Local lImpRef := .F.
	Local nRegProc := 0
	Local nRegEnv := 0
	Local lEnvOK := .F.
	Local cCRLF	 := (chr(13)+chr(10))
	Local cTpdoc := "f"
	Local lExp := .F.
	Local cPDFPro  := SuperGetMV("MV_PDFPRO",,"1")
	Local cTokenEmp	:= SuperGetMV("MV_TKN_EMP",,"") // Token empresa
	Local cTokenPas	:= SuperGetMV("MV_TKN_PAS",,"") // Token password
	Local cUrl      := SuperGetMV("MV_WSRTSS",,"")	//URL de WS
	Local oWSPDF    := Nil
	Local cDirLocal	:= GetTempPath()
	Local cRespPDF  := ""
	Local lEmail    := (nFormato == 2)
	Local cRespXML  := ""
	Local lNoFound	:= .F.
	Local cFilSA1   := xFilial("SA1")
	Local cFilAI0   := xFilial("AI0")
	Local aDocNoE   := {}
	Local lECliente := .T. //Indica si el Cliente del documento tiene Email
	Local cNomCli   := ""  //Nombre del Cliente
	Local lNtAjNCP  :=  cPaisLoc == "COL" .AND. alltrim(cEspecie) $ 'NCP|NDP' .AND. (nTDTras == 8 .OR. nTDTras == 9  )
	Local lDoSport  :=  cPaisLoc == "COL" .AND. nTDTras == 6
	Private cLetFac:= ""
	Private cLetPie := ""
	Private cTpoDocSA1 := ""
	Private aDoc := {}
	Private nRef := 0
	Private nImpIva  := 0
	Private nImpRet  := 0
	Private nImpOtro := 0
	Private nDesc    := 0

	If alltrim(cEspecie) $ "NF|NDC|NCP"
		cCampos  := "% SF2.F2_FILIAL, SF2.F2_SERIE SERIE, SF2.F2_DOC DOCUMENTO, SF2.F2_ESPECIE ESPECIE, SF2.F2_CLIENTE CLIENTE, SF2.F2_LOJA LOJA, SF2.F2_MOEDA AS MONEDA, F2_SERIE2 SERIE2 %"
		cTablas  := "% " + RetSqlName("SF2") + " SF2 %"
		cCond    := "% SF2.F2_SERIE = '"  + cSerie + "'"
		cCond    += " AND SF2.F2_DOC >= '"  + cDocIni + "'"
		cCond    += " AND SF2.F2_DOC <= '"  + cDocFin + "'"
		cCond    += " AND SF2.F2_ESPECIE = '"  + cEspecie + "'"
		cCond	 += " AND SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
		If lNtAjNCP //Nota ajuste NCP
			cCond += " AND SF2.F2_MARK = 'S' "
		EndIf
		cCond	 += " AND SF2.D_E_L_E_T_  = ' ' %"
		cOrder := "% SF2.F2_FILIAL, SF2.F2_SERIE, SF2.F2_DOC %"
		cLetFac := IIf(Alltrim(cEspecie) == "NF", STR0001, IIf(lNtAjNCP,STR0105,STR0002)) //"FACTURA ELECTRÓNICA" //"NOTA DE AJUSTE ELECTRÓNICA"//"NOTA DE DÉBITO ELECTRÓNICA"
		cLetPie := IIf(Alltrim(cEspecie) == "NF", STR0029, IIf(lNtAjNCP,STR0106,STR0030)) //"Representación impresa de FACTURA ELECTRÓNICA" //"Representación impresa de NOTA DE AJUSTE ELECTRÓNICA"//"Representación impresa de NOTA DE DÉBITO ELECTRÓNICA"
	ElseIf alltrim(cEspecie) $ "NCC|NDP"
		// NOTA DE CRÉDITO
		cCampos  := "% SF1.F1_FILIAL, SF1.F1_SERIE SERIE, SF1.F1_DOC DOCUMENTO, SF1.F1_ESPECIE ESPECIE, SF1.F1_FORNECE CLIENTE, SF1.F1_LOJA LOJA, SF1.F1_MOEDA AS MONEDA, F1_SERIE2 SERIE2  %"
		cTablas  := "% " + RetSqlName("SF1") + " SF1 %"
		cCond    := "% SF1.F1_SERIE = '"  + cSerie + "'"
		cCond    += " AND SF1.F1_DOC >= '"  + cDocIni + "'"
		cCond    += " AND SF1.F1_DOC <= '"  + cDocFin + "'"
		cCond    += " AND SF1.F1_ESPECIE = '"+IIf(lDoSport,'NF',cEspecie)+"'"
		cCond	 += " AND SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
		If lDoSport //lDocSop
			cCond += " AND F1_SOPORT = 'S' "
		EndIf
		If lNtAjNCP //Nota ajuste NDP
			cCond += " AND SF1.F1_MARK = 'S' "
		EndIf
		cCond	 += " AND SF1.D_E_L_E_T_  = ' ' %"
		
		cOrder := "% SF1.F1_FILIAL, SF1.F1_SERIE, SF1.F1_DOC %"
		cLetFac := IIf(lDoSport,STR0099,IIf(lNtAjNCP,STR0105,STR0003)) //"DOCUMENTO SOPORTE" //"NOTA DE AJUSTE ELECTRÓNICA"//"NOTA DE CRÉDITO ELECTRÓNICA"
		cLetPie := IIf(lDoSport,STR0100,IIf(lNtAjNCP,STR0106,STR0031)) //"Representación impresa del Documento Soporte" //"Representación impresa de NOTA DE AJUSTE ELECTRÓNICA"//"Representación impresa de NOTA DE CRÉDITO ELECTRÓNICA"
	
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
		If cPDFPro == "2" //No imprime PDF Protheus
			lNoFound := .F.
			oWSPDF := Nil
			cFileGen := Alltrim((cAliasPDF)->SERIE2)+Alltrim(Str(Val((cAliasPDF)->DOCUMENTO)))
			oWSPDF := WSNFECol():New()
			oWSPDF:ctokenEmpresa	:= cTokenEmp
			oWSPDF:ctokenPassword	:= cTokenPas
			oWSPDF:_URL := cUrl
			oWSPDF:cdocumento := cFileGen
			If !FILE(cDirLocal + cFileGen + ".pdf")
				If oWSPDF:DescargaPDF()
					If !Empty(oWSPDF:oWSDescargaPDFResult:cdocumento)
						cRespPDF := Decode64(oWSPDF:oWSDescargaPDFResult:cdocumento)
						If !Empty(cRespPDF)
							fWriteLocal(cRespPDF, cDirLocal, cFileGen + ".pdf", 2)
							If !lEmail
								ShellExecute("Open",cFileGen + ".pdf","",cDirLocal ,1)
							EndIf
						EndIf
					Else
						lNoFound := .T.
					EndIf
				Else
					MsgAlert(STR0076, Alltrim((cAliasPDF)->SERIE) + "-" + Alltrim((cAliasPDF)->DOCUMENTO) + "-" + STR0084) //"Sin respuesta del servicio web."
				EndIf
			Else
				If !lEmail
					ShellExecute("Open",cFileGen + ".pdf","",cDirLocal ,1)
				EndIf
			EndIf

			If lEmail .And. !lNoFound
				cFileAux := cDirLocal + cFileGen +".pdf"
				CpyT2S(cFileAux, cPath)
				cFileAux := cDirLocal + cFileGen +".xml"
				If !FILE(cFileAux)
					If oWSPDF:GenerarContenedor()
						If oWSPDF:oWSGenerarContenedorResult:ncodigo == 200 .And. !Empty(oWSPDF:oWSGenerarContenedorResult:ccontenedorXml)
							cRespXML := Decode64(oWSPDF:oWSGenerarContenedorResult:ccontenedorXml)
							If !Empty(cRespXML)
								fWriteLocal(cRespXML, cDirLocal, cFileGen + ".xml", 2)
							EndIf
						EndIf
					EndIf
				EndIf
				CpyT2S(cFileAux, cPath)

				//Envío de Zip
				aFileAux := {}
				aItens := {}
				aAdd( aItens, cPath + cFileGen + ".pdf" )
				aAdd( aItens, cPath + cFileGen + ".xml" )
				cArq := tarCompress( aItens, cPath + cFileGen + ".Zip" )
				aAdd(aFileAux, StrTran( upper(cPath + cFileGen + ".Zip"), upper(GetSrvProfString('rootpath',''))))
				cEmailCli := ObtEmail((cAliasPDF)->CLIENTE,(cAliasPDF)->LOJA, cFilSA1, cFilAI0, @cNomCli)
				If Empty(cEmailCli)
					aAdd(aDocNoE,{(cAliasPDF)->SERIE,(cAliasPDF)->DOCUMENTO,(cAliasPDF)->CLIENTE,(cAliasPDF)->LOJA, cNomCli})
					lECliente := .F.
				Else
					lECliente := .T.
				EndIf
				lEnvOK := IIf(lECliente,EnvioMail(cEmailCli,aFileAux),.F.)
				If lEnvOK
					nRegEnv += 1
				EndIf
				For nI := 1 To Len(aFileAux)
					FErase(aFileAux[nI])
				Next nI
			EndIf

		Else
			cTpDoc 	:= IIf(alltrim(cEspecie) == "NF","f",IIF(alltrim(cEspecie) == "NDC","d","c"))
			cFileGen := "face_" + cTpDoc + PADR( Alltrim(SM0->M0_CGC) , 10 , "0" ) + M486XHEX(Alltrim( Substr( (cAliasPDF)->DOCUMENTO  , 4 , Len((cAliasPDF)->DOCUMENTO)  - 3 ) ), 10)
			cFile := cFileGen + ".xml"
			oXML := XmlParserFile(cPath + cFile, "_", @cAviso,@cErro)

			lExp := POSICIONE("SA1",1,XFILIAL("SA1") +(cAliasPDF)->CLIENTE + (cAliasPDF)->LOJA,"A1_EST" ) == "EX"

			If oXML <> Nil
				If File(GetClientDir() + cFileGen + ".pdf")
					// En caso de que exista el PDF en la carpeta del Smartclient, lo borra para que no pregunte si se sobre-escribe
					Delete File &(GetClientDir() + cFileGen + ".pdf")
				Endif

				oPrinter := FWMSPrinter():New(cFileGen,6,.F.,GetClientDir(),.T.,,,,,.F.,,(nFormato == 1) )

				If alltrim((cAliasPDF)->ESPECIE) $ "NF|NDC"
					If alltrim((cAliasPDF)->ESPECIE) == "NF"
						oXML := oXml:_FE_INVOICE

						aDoc := StrTokArr( oXml:_CBC_ID:TEXT, "-" )
						aOpcDoc := {"_FE_INVOICELINE","_CBC_INVOICEDQUANTITY","_FE_LEGALMONETARYTOTAL","_FE_ITEM"}
						nTotPag := IIf(ValType(oXml:_FE_INVOICELINE) == "A",Len(oXml:_FE_INVOICELINE) / 63, 1)

						cLetFac := STR0001 //"FACTURA ELECTRÓNICA"
						cLetPie := STR0029 //"Representación impresa de FACTURA ELECTRÓNICA"

						lImpRef := .F.
					ElseIf alltrim((cAliasPDF)->ESPECIE) == "NDC"
						oXML    := oXml:_FE_DEBITNOTE
						aOpcDoc := {"_CAC_DEBITNOTELINE","_CBC_DEBITEDQUANTITY","_CAC_REQUESTEDMONETARYTOTAL","_CAC_ITEM"}
						nRef    := IIf(ValType(oXml:_CAC_DISCREPANCYRESPONSE) == "A",Len(oXml:_CAC_DISCREPANCYRESPONSE),1)
						nTotPag := IIf(ValType(oXml:_CAC_DEBITNOTELINE) == "A",(Len(oXml:_CAC_DEBITNOTELINE) + nRef) / 63, 1)

						cLetFac := STR0002 //"NOTA DE DÉBITO ELECTRÓNICA"
						cLetPie := STR0030 //"Representación impresa de NOTA DE DÉBITO ELECTRÓNICA"
						lImpRef := .T.
					EndIf
				ElseIf alltrim((cAliasPDF)->ESPECIE) $ "NCC"
					oXML 	:= oXml:_FE_CREDITNOTE
					nRef   	:= IIf(ValType(oXml:_CAC_DISCREPANCYRESPONSE) == "A",Len(oXml:_CAC_DISCREPANCYRESPONSE),1)
					nTotPag := IIf(ValType(oXml:_CAC_CREDITNOTELINE) == "A",(Len(oXml:_CAC_CREDITNOTELINE) + nRef) / 63, 1)
					aOpcDoc := {"_CAC_CREDITNOTELINE","_CBC_CREDITEDQUANTITY","_CAC_LEGALMONETARYTOTAL","_CAC_ITEM"}
					cLetFac	:= STR0003 //"NOTA DE CRÉDITO ELECTRÓNICA"
					cLetPie	:= STR0031  //"Representación impresa de NOTA DE CRÉDITO ELECTRÓNICA"
					lImpRef	:= .T.
				EndIf

				nDec := nTotPag - Int(nTotPag)
				If nDec > 0
					nTotPag := Int(nTotPag) + 1
				EndIf

				oPrinter:setDevice(IMP_PDF)
				oPrinter:cPathPDF := GetClientDir()
				oPrinter:StartPage()

				nImpIva := 0
				nImpRet := 0
				nImpOtro := 0
				nDesc := 0

				//Impuestos
				ObtImptos(oXml)
				For nI := 1 To Len(aImptos)
					If aImptos[nI, 1] == "01" .And. aImptos[nI, 3] == "false"
						nImpIva += aImptos[nI, 2]
					ElseIf aImptos[nI, 3] == "false"
						nImpOtro += aImptos[nI, 2]
					Else
						nImpRet += aImptos[nI, 2]
					Endif
				Next nI

				ImpEnc(oPrinter,oXml)   //Encabezado
				DetFact(oPrinter,oXML,aOpcDoc)  //Detalle
				// Referencia, solo para NDC/NCC
				If lImpRef
					ImpRef(oPrinter,oXml)
				EndIf

				ImpPie(oPrinter,oXML,(cAliasPDF)->MONEDA) //Pie de página
				oPrinter:EndPage()
				oPrinter:Print()

				cFileAux := GetClientDir() + cFileGen +".pdf"
				CpyT2S(cFileAux, cPath)

				FreeObj(oPrinter)
				oPrinter := Nil

				FErase(cFileAux)
			EndIf
		EndIf
		(cAliasPDF)->(dbskip())
	EndDo

	If lEmail
		If Len(aDocNoE) > 0
			F486MsgObs(aDocNoE)
		EndIf
		APMSGINFO(STR0043 + cCRLF + ; //"Generación Representación Impresa Finalizada"
			 		STR0044 + Str(nRegProc) + cCRLF + ; //"Registros procesados: "
			 			STR0045 + Str(nRegEnv) , STR0037) //"Registros enviados: "
	EndIf

Return Nil

/*/{Protheus.doc} ImpEnc
Imprime encabezado de factura a partir de XML COLOMBIA
@type function
@author mayra.camargo
@since 17/05/2018
@version 1.0
@param oPrinter, objeto, Objeto creado por FWMSPrinter.
@param oXml, objeto, Objeto con estructura de archivo XML.
/*/
Static Function ImpEnc(oPrinter,oXml)

	Local cFileLogo	:= ""
	Local cPais     := ""
	Local cNomEmi   := oXml:_FE_ACCOUNTINGSUPPLIERPARTY:_FE_PARTY:_CAC_PARTYNAME:_CBC_NAME:TEXT
	Local cDocStr   := IIF(alltrim(cEspecie) == "NF",STR0048,IIF(alltrim(cEspecie) == "NDC",STR0049,STR0050)) //"ORIGINAL DE NOTA DE DEBITO No ", "ORIGINAL DE NOTA DE CREDITO No "
	Local cDocFol   := oXml:_CBC_ID:TEXT
	Local cNITEmi   := oXml:_FE_ACCOUNTINGSUPPLIERPARTY:_FE_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_ID:TEXT
	Local cDirEmi   := oXml:_FE_ACCOUNTINGSUPPLIERPARTY:_FE_PARTY:_FE_PHYSICALLOCATION:_FE_ADDRESS:_CAC_ADDRESSLINE:_CBC_LINE:TEXT + " "
	Local cFecEmi   := Replace(oXml:_CBC_ISSUEDATE:TEXT,"-","")
	Local cTpoRec   := oXml:_FE_ACCOUNTINGCUSTOMERPARTY:_CBC_ADDITIONALACCOUNTID:TEXT
	Local cNITRec   := oXml:_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_ID:TEXT
	Local cDirRec   := oXml:_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PHYSICALLOCATION:_FE_ADDRESS:_CAC_ADDRESSLINE:_CBC_LINE:TEXT
	Local cDepRec   := Upper(oXml:_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PHYSICALLOCATION:_FE_ADDRESS:_CBC_DEPARTMENT:TEXT)
	Local cCiuRec   := Upper(oXml:_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PHYSICALLOCATION:_FE_ADDRESS:_CBC_CITYNAME:TEXT)
	Local cSerDoc   := ""
	Local cRanIni   := ""
	Local cRanFin   := ""
	Local cResDIAN  := ""
	Local cFecResD  := ""
	Local cCodBarra := ""
	Local nItem     := 0

	If Alltrim(cEspecie) == "NF"
		nItem := aScan( oXml:_EXT_UBLEXTENSIONS:_EXT_UBLEXTENSION, {|x,y| AttIsMemberOf(x:_EXT_EXTENSIONCONTENT, "_STS_DIANEXTENSIONS")} )
		cSerDoc   := oXml:_EXT_UBLEXTENSIONS:_EXT_UBLEXTENSION[nItem]:_EXT_EXTENSIONCONTENT:_STS_DIANEXTENSIONS:_STS_INVOICECONTROL:_STS_AUTHORIZEDINVOICES:_STS_PREFIX:TEXT
		cRanIni   := oXml:_EXT_UBLEXTENSIONS:_EXT_UBLEXTENSION[nItem]:_EXT_EXTENSIONCONTENT:_STS_DIANEXTENSIONS:_STS_INVOICECONTROL:_STS_AUTHORIZEDINVOICES:_STS_FROM:TEXT
		cRanFin   := oXml:_EXT_UBLEXTENSIONS:_EXT_UBLEXTENSION[nItem]:_EXT_EXTENSIONCONTENT:_STS_DIANEXTENSIONS:_STS_INVOICECONTROL:_STS_AUTHORIZEDINVOICES:_STS_TO:TEXT
		cResDIAN  := oXml:_EXT_UBLEXTENSIONS:_EXT_UBLEXTENSION[nItem]:_EXT_EXTENSIONCONTENT:_STS_DIANEXTENSIONS:_STS_INVOICECONTROL:_STS_INVOICEAUTHORIZATION:TEXT
		cFecResD  := Replace(oXml:_EXT_UBLEXTENSIONS:_EXT_UBLEXTENSION[nItem]:_EXT_EXTENSIONCONTENT:_STS_DIANEXTENSIONS:_STS_INVOICECONTROL:_STS_AUTHORIZATIONPERIOD:_CBC_ENDDATE:TEXT,"-","")
	EndIf

	cFecEmi  := Substr(cFecEmi,7,2) + "-" + Substr(cFecEmi,5,2) + "-" + Substr(cFecEmi,0,4)
	cFecResD := Substr(cFecResD,7,2) + "-" + Substr(cFecResD,5,2) + "-" + Substr(cFecResD,0,4)

	If cTpoRec == "2"
		cNomRec   := oXml:_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PERSON:_CBC_FIRSTNAME:TEXT + ' '
		If XmlChildEx( oXml:_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PERSON, '_CBC_MIDDLENAME') <> Nil
			cNomRec += oXml:_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PERSON:_CBC_MIDDLENAME:TEXT + ' '
		EndIF
		cNomRec += oXml:_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PERSON:_CBC_FAMILYNAME:TEXT
	ElseIf cTpoRec == "1"
		cNomRec   := oXml:_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYLEGALENTITY:_CBC_REGISTRATIONNAME:TEXT
	EndIf

	//Codigo de barras (QR)
	//If Alltrim(cEspecie) == "NF"
		cCodBarra := GenCodBar(oXml, cEspecie)
	//EndIF

	cDirEmi += oXml:_FE_ACCOUNTINGSUPPLIERPARTY:_FE_PARTY:_FE_PHYSICALLOCATION:_FE_ADDRESS:_CBC_CITYNAME:TEXT + " "
	cPais := oXml:_FE_ACCOUNTINGSUPPLIERPARTY:_FE_PARTY:_FE_PHYSICALLOCATION:_FE_ADDRESS:_CAC_COUNTRY:_CBC_IDENTIFICATIONCODE:TEXT + " "

	cFileLogo := CargaLogo()

	nLinea := 30
	If File(cFilelogo)
		oPrinter:SayBitmap(nLinea,20,cFileLogo,100,50) // Impresion de logotipo
	EndIf
	nLinea += 30
	oPrinter:SayAlign(nLinea-7,190,cNomEmi,oFont5,160,5,CLR_BLACK, 2, 2 ) //Nombre Emisor
	nLinea += 20
	oPrinter:SayAlign(nLinea-7,190," N.I.T. " + cNITEmi,oFont1,160,5,CLR_BLACK, 2, 2 ) //N.I.T. Emisor
	oPrinter:QRCode(170, 425, cCodBarra,32)
	nLinea += 10
	oPrinter:SayAlign(nLinea-7,190,cDirEmi,oFont1,160,5,CLR_BLACK, 2, 2 ) //Dirección Emisor
	nLinea += 10
	oPrinter:SayAlign(nLinea,180,cDocStr,oFont3,160,5,CLR_BLACK, 2, 2 ) //"ORIGINAL DE FACTURA DE VENTA No "
	oPrinter:SayAlign(nLinea,300,cDocFol,oFont3,160,5,CLR_RED, 2, 2 )  //NO. FACTURA

	nLinea += 30
	oPrinter:Say(nLinea,020,STR0051,oFont2) // "GRANDES CONTRIBUYENTES"
	oPrinter:Say(nLinea,320,"FECHA",oFont2)
	oPrinter:Say(nLinea,380,cFecEmi,oFont2)

	If Alltrim(cEspecie) == "NF"
		nLinea += 10
		oPrinter:Say(nLinea,020,STR0052 + cSerDoc + " " + cRanIni + STR0053 + cSerDoc + " " + cRanFin,oFont2)  // "NUMERACIÓN AUTORIZADA DEL " " AL "
		oPrinter:Say(nLinea,320,STR0054,oFont2) // "VENCIMIENTO"
		oPrinter:Say(nLinea,380,cFecEmi,oFont2)

		nLinea += 10
		oPrinter:Say(nLinea,020,STR0055 + cResDIAN + STR0056 + cFecResD,oFont2) // "RESOLUCION DIAN " " DE "

		nLinea += 30
		oPrinter:Line(nLinea,10,nLinea,580,,"-4")

	Else
		nLinea += 50

	EndIf

	//DATOS CLIENTE
	nLinea += 10
	oPrinter:Say(nLinea,020,STR0057,oFont2) // "CLIENTE"
	oPrinter:Say(nLinea,100,cNomRec,oFont2)
	oPrinter:Say(nLinea,400,STR0058,oFont2) // "DEPARTAMENTO"
	oPrinter:Say(nLinea,480,cDepRec,oFont2)

	nLinea += 10
	oPrinter:Say(nLinea,020,STR0059,oFont2) // "N.I.T."
	oPrinter:Say(nLinea,100,cNITRec,oFont2)
	oPrinter:Say(nLinea,400,STR0060,oFont2) // "CIUDAD"
	oPrinter:Say(nLinea,480,cCiuRec,oFont2)

	nLinea += 10
	oPrinter:Say(nLinea,020,STR0061,oFont2) // "DIRECCIÓN"
	oPrinter:Say(nLinea,100,cDirRec,oFont2)
	oPrinter:Say(nLinea,400,STR0062,oFont2) //"TELÉFONO"

	nLinea += 10
	oPrinter:Line(nLinea,10,nLinea,580,,"-4")

	nLinea += 15
	oPrinter:Say(nLinea,020,STR0063,oFont6) // "CÓDIGO"
	oPrinter:Say(nLinea,080,STR0064,oFont6) // "DESCRIPCIÓN"
	oPrinter:Say(nLinea,250,STR0065,oFont6) // "CANT."
	oPrinter:Say(nLinea,330,STR0066,oFont6) // "PRECIO UNIT."
	oPrinter:Say(nLinea,500,STR0067,oFont6) // "SUBTOTAL"

	nLinea += 10
	oPrinter:Line(nLinea,10,nLinea,580,,"-4")

	nLinea += 10
Return Nil

/*/{Protheus.doc} DetFact
Imprime detalle de factura a partir de XML
@type function
@author mayra.camargo
@since 17/05/2018
@version 1.0
@param oPrinter, objeto, objeto creado por FWMSPrinter.
@param oXml, objeto, Objeto con estructura de archivo XML.
@param aOpcDoc, array, Nodos de búsqueda dependiendo del documento
/*/
Static Function DetFact(oPrinter,oXml,aOpcDoc)
	Local nX := 0
	Local nY := 0
	Local nTotItem := 0

	If ValType(&("oXml:" + aOpcDoc[1] )) == "A"
		For nX := 1 To Len(&("oXml:" + aOpcDoc[1]))
			If nLinea > 815
		 		SaltoPag(oPrinter,oXml)
			EndIf
			oPrinter:SayAlign(nLinea,010,&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:" + aOpcDoc[4] + ":_CAC_SELLERSITEMIDENTIFICATION:_CBC_ID:TEXT")		,oFont1,040,10,CLR_BLACK, 1, 0 )//CÓDIGO DEL PRODUCTO

			If alltrim(cEspecie) == "NF"
				//  oPrinter:SayAlign(nLinea,080,&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_FE_ITEM:_CBC_DESCRIPTION:TEXT")							,oFont1,150,10,CLR_BLACK, 0, 0 )//DESCRIPCIÓN
				If Valtype(oXml:_FE_INVOICELINE[nX]:_FE_ITEM:_CBC_DESCRIPTION) == "O"
					oPrinter:SayAlign(nLinea,080,&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:" + aOpcDoc[4] + ":_CBC_DESCRIPTION:TEXT"),oFont1,150,10,CLR_BLACK, 0, 0 ) //DESCRIPCIÓN
				Else
					For nY:= 1 to len(oXml:_FE_INVOICELINE[nX]:_FE_ITEM:_CBC_DESCRIPTION)
						oPrinter:SayAlign(nLinea,080,&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:" + aOpcDoc[4] + ":_CBC_DESCRIPTION["+ STR(nY) +"]:TEXT")	,oFont1,150,10,CLR_BLACK, 0, 0 ) //DESCRIPCIÓN
						nLinea +=10
					Next nY
					nLinea -=10
				EndIf
			Else
				oPrinter:SayAlign(nLinea,080,&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:" + aOpcDoc[4] + ":_CBC_DESCRIPTION:TEXT")							,oFont1,150,10,CLR_BLACK, 0, 0 )//DESCRIPCIÓN
			EndIf

			//If alltrim(cEspecie) <> "NCC"
				If alltrim(cEspecie) == "NF"
					oPrinter:SayAlign(nLinea,230,TRANSFORM(Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:" + aOpcDoc[2] + ":TEXT")),cPicture)			,oFont1,060,10,CLR_BLACK, 2, 0 )//CANTIDAD
					oPrinter:SayAlign(nLinea,300,TRANSFORM(Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_FE_PRICE:_CBC_PRICEAMOUNT:TEXT")),cPicture)	,oFont1,080,10,CLR_BLACK, 1, 0 ) //PRECIO UNITARIO
					nTotItem = Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_FE_PRICE:_CBC_PRICEAMOUNT:TEXT")) * Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:" + aOpcDoc[2] + ":TEXT"))
				Else
					oPrinter:SayAlign(nLinea,230,TRANSFORM(Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:" + aOpcDoc[2] + ":TEXT")),cPicture)			,oFont1,060,10,CLR_BLACK, 2, 0 )//CANTIDAD
					oPrinter:SayAlign(nLinea,300,TRANSFORM(Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICE:_CBC_PRICEAMOUNT:TEXT")),cPicture)	,oFont1,080,10,CLR_BLACK, 1, 0 ) //PRECIO UNITARIO
					nTotItem = Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICE:_CBC_PRICEAMOUNT:TEXT")) * Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:" + aOpcDoc[2] + ":TEXT"))
				EndIf
			//Else
			//	nTotItem = Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_PRICE:_CBC_PRICEAMOUNT:TEXT")) * Val(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:" + aOpcDoc[2] + ":TEXT"))
			//EndIf

			oPrinter:SayAlign(nLinea,460,TRANSFORM(nTotItem,cPicture),oFont1,080,10,CLR_BLACK, 1, 0 ) //TOTAL
			nLinea += 10

			If XmlChildEx(&("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]"), "_CAC_ALLOWANCECHARGE") <> Nil
				If &("oXml:" +  aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_ALLOWANCECHARGE:_CBC_CHARGEINDICATOR:TEXT") == "false"
					nDesc += Val(&("oXml:" + aOpcDoc[1] + "[" + Str(nX) + "]:_CAC_ALLOWANCECHARGE:_CBC_AMOUNT:TEXT"))
				Endif
			EndIf
		Next nX
	Else
		oPrinter:SayAlign(nLinea,010,&("oXml:" +  aOpcDoc[1] + ":" + aOpcDoc[4] + ":_CAC_SELLERSITEMIDENTIFICATION:_CBC_ID:TEXT")									,oFont1,040,10,CLR_BLACK, 1, 0 ) //CÓDIGO DEL PRODUCTO
		If alltrim(cEspecie) == "NF"
			If Valtype(oXml:_FE_INVOICELINE:_FE_ITEM:_CBC_DESCRIPTION) == "O"
				oPrinter:SayAlign(nLinea,080,&("oXml:" +  aOpcDoc[1] + ":" + aOpcDoc[4] + ":_CBC_DESCRIPTION:TEXT")		,oFont1,150,10,CLR_BLACK, 0, 0 ) //DESCRIPCIÓN
			Else
				For nX:= 1 to len(oXml:_FE_INVOICELINE:_FE_ITEM:_CBC_DESCRIPTION)
					oPrinter:SayAlign(nLinea,080,&("oXml:" +  aOpcDoc[1] + ":" + aOpcDoc[4] + ":_CBC_DESCRIPTION["+ STR(nX) +"]:TEXT")	,oFont1,150,10,CLR_BLACK, 0, 0 ) //DESCRIPCIÓN
					nLinea +=10
				Next nX
				nLinea -=10
			EndIf
		Else
			oPrinter:SayAlign(nLinea,080,&("oXml:" +  aOpcDoc[1] + ":" + aOpcDoc[4] + ":_CBC_DESCRIPTION:TEXT")							,oFont1,150,10,CLR_BLACK, 0, 0 ) //DESCRIPCIÓN
		EndIf

		oPrinter:SayAlign(nLinea,230,&("oXml:" +  aOpcDoc[1] + ":" + aOpcDoc[2] + ":TEXT"),oFont1,060,10,CLR_BLACK, 2, 0 ) //CANTIDAD
		If alltrim(cEspecie) == "NF"
			oPrinter:SayAlign(nLinea,300,TRANSFORM(Val(&("oXml:" + aOpcDoc[1] + ":_FE_PRICE:_CBC_PRICEAMOUNT:TEXT")),cPicture)	,oFont2,080,10,CLR_BLACK, 1, 0 ) //PRECIO UNITARIO
			nTotItem = Val(&("oXml:" + aOpcDoc[1] + ":_FE_PRICE:_CBC_PRICEAMOUNT:TEXT")) * Val(&("oXml:" +  aOpcDoc[1] + ":" + aOpcDoc[2] + ":TEXT"))
		Else
			oPrinter:SayAlign(nLinea,300,TRANSFORM(Val(&("oXml:" + aOpcDoc[1] + ":_CAC_PRICE:_CBC_PRICEAMOUNT:TEXT")),cPicture)	,oFont2,080,10,CLR_BLACK, 1, 0 ) //PRECIO UNITARIO
			nTotItem = Val(&("oXml:" + aOpcDoc[1] + ":_CAC_PRICE:_CBC_PRICEAMOUNT:TEXT")) * Val(&("oXml:" +  aOpcDoc[1] + ":" + aOpcDoc[2] + ":TEXT"))
		EndIf

		oPrinter:SayAlign(nLinea,460,TRANSFORM(nTotItem,cPicture)	,oFont2,080,10,CLR_BLACK, 1, 0 ) //SUB TOTAL
		nLinea += 10

		If XmlChildEx(&("oXml:" +  aOpcDoc[1]), "_CAC_ALLOWANCECHARGE") <> Nil
			If &("oXml:" +  aOpcDoc[1] + ":_CAC_ALLOWANCECHARGE:_CBC_CHARGEINDICATOR:TEXT") == "false"
				nDesc += Val(&("oXml:" + aOpcDoc[1] + ":_CAC_ALLOWANCECHARGE:_CBC_AMOUNT:TEXT"))
			Endif
		EndIf
	EndIf

	oPrinter:Line(nLinea,10,nLinea,580,,"-4")
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpRef     ³ Autor ³ Luis Enriquez         ³ Data ³ 10.07.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime docs de referencia para notas de debito/credito(COL) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpRef(oPrinter,oXml)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPrinter .- objeto creado por FWMSPrinter.                   ³±±
±±³          ³ oXml .- Objeto con estructura de archivo XML.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ No aplica.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486XMLPDF                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRef(oPrinter,oXml)
	Local cTipoDoc := ""
	Local nX 		:= 0
	Local cTabRef	:= IIF(Alltrim(cEspecie)=="NDC","S004","S003")
	Local cTpRef 	:= ""

	If nLinea > 815
 		SaltoPag(oPrinter,oXml)
	EndIf

	nLinea += 10

	oPrinter:Box(nLinea + (nRef * 10), 10, nLinea, 580, "-4")
	oPrinter:SayAlign(nLinea,20,STR0038,oFont4,100,5,CLR_BLACK, 0, 2 )  //"TIPO DOCUMENTO"
	oPrinter:SayAlign(nLinea,130,STR0039,oFont4,100,5,CLR_BLACK, 0, 2 ) //"N° DOCUMENTO REF."
	oPrinter:SayAlign(nLinea,240,STR0040,oFont4,100,5,CLR_BLACK, 0, 2 ) //"MOTIVO REFERENCIA"

	oPrinter:Line(nLinea,105,nLinea + 10,105,,"-4")
	oPrinter:Line(nLinea,230,nLinea + 10,230,,"-4")

	nLinea += 10
	oPrinter:Line(nLinea,10 ,nLinea + 10,10 ,,"-4")
	oPrinter:Line(nLinea,105,nLinea + 10,105,,"-4")
	oPrinter:Line(nLinea,230,nLinea + 10,230,,"-4")
	oPrinter:Line(nLinea,580,nLinea + 10,580,,"-4")

	cTipoDoc := STR0041 //"FACTURA"
	cTpRef := oXml:_CAC_DISCREPANCYRESPONSE:_CBC_RESPONSECODE:TEXT
	cTpRef += ": " + UPPER(ObtColSAT(cTabRef, cTpRef, 1, 1, 2, 80))
	oPrinter:SayAlign(nLinea,20,cTipoDoc,oFont2,70,5,CLR_BLACK, 2, 2 )
	oPrinter:SayAlign(nLinea,240,cTpRef,oFont2,150,5,CLR_BLACK, 0, 2 )
	// Obtener los documentos de Referencia
	If ValType(oXML:_CAC_BILLINGREFERENCE) == "A"
		For nX:=1 to len(oXML:_CAC_BILLINGREFERENCE)
			oPrinter:Line(nLinea,10 ,nLinea + 10,10 ,,"-4")
			oPrinter:Line(nLinea,105,nLinea + 10,105,,"-4")
			oPrinter:Line(nLinea,230,nLinea + 10,230,,"-4")
			oPrinter:Line(nLinea,580,nLinea + 10,580,,"-4")
			oPrinter:SayAlign(nLinea,110,oXML:_CAC_BILLINGREFERENCE[nX]:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ID:TEXT,oFont2,110,5,CLR_BLACK, 2, 2 )
			nLinea += 10
		Next
	Else
		oPrinter:SayAlign(nLinea,110,oXML:_CAC_BILLINGREFERENCE:_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ID:TEXT,oFont2,110,5,CLR_BLACK, 2, 2 )
		nLinea += 10
	EndIf
	oPrinter:Line(nLinea,10,nLinea,580,,"-4")  //Linea final detalle
Return Nil

/*/{Protheus.doc} ImpPie
Imprimir pie de reporte de factura a partir de XML
@type function
@author mayra.camargo
@since 17/05/2018
@version 1.0
@param oPrinter, objeto, objeto creado por FWMSPrinter.
@param oXml, Objeto con estructura de archivo XML.
@return N/A
/*/
Static Function ImpPie(oPrinter,oXml,nMoneda)
	Local cImpCero := "0"
	Local cCUFE    := IIF(Alltrim(cEspecie)=="NF",oXml:_CBC_UUID:TEXT,"")
	Local nSubTotal:= Val(oXml:_FE_LEGALMONETARYTOTAL:_CBC_LINEEXTENSIONAMOUNT:TEXT)
	Local nValBrut := Val(oXml:_FE_LEGALMONETARYTOTAL:_CBC_PAYABLEAMOUNT:TEXT)
	Local cNote    := ""
	Local nTamLin  := 120
	Local nTamMemo := 0
	Local nX       := 0

	nLinea += 10
	oPrinter:SayAlign(nLinea,400,STR0067,oFont1,60,10,CLR_BLACK, 1, 0 ) // "SUBTOTAL"
	oPrinter:SayAlign(nLinea,460,Transform(nSubTotal,cPicture),oFont1,80,10,CLR_BLACK, 1, 0 )
	nLinea += 10
	oPrinter:SayAlign(nLinea,400,STR0068,oFont1,60,10,CLR_BLACK, 1, 0 ) // "IVA"
	oPrinter:SayAlign(nLinea,460,Transform(nImpIva,cPicture),oFont1,80,10,CLR_BLACK, 1, 0 )
	nLinea += 10
	oPrinter:SayAlign(nLinea,380,STR0070,oFont1,80,10,CLR_BLACK, 1, 0 ) // "TOTAL RETENCIONES"
	oPrinter:SayAlign(nLinea,460,Transform(nImpRet,cPicture),oFont1,80,10,CLR_BLACK, 1, 0 )
	nLinea += 10
	oPrinter:SayAlign(nLinea,400,STR0071,oFont1,60,10,CLR_BLACK, 1, 0 ) //"TOTAL IMPUESTOS"
	oPrinter:SayAlign(nLinea,460,Transform(nImpIva+nImpOtro,cPicture),oFont1,80,10,CLR_BLACK, 1, 0 )
	nLinea += 10
	oPrinter:SayAlign(nLinea,380,STR0075,oFont1,80,10,CLR_BLACK, 1, 0 ) //"TOTAL DESCUENTOS"
	oPrinter:SayAlign(nLinea,460,Transform(nDesc,cPicture),oFont1,80,10,CLR_BLACK, 1, 0 )
	nLinea += 10
	oPrinter:SayAlign(nLinea,400,STR0072,oFont1,60,10,CLR_BLACK, 1, 0 ) // "NETO A PAGAR"
	oPrinter:SayAlign(nLinea,460,Transform(nValBrut,cPicture),oFont1,80,10,CLR_BLACK, 1, 0 )

	//Monto en letra
	nLinea += 20
	oPrinter:Line(nLinea,10,nLinea,580,,"-4")
	oPrinter:SayAlign(nLinea,10,STR0073 + EXTENSO(nValBrut,.F.,nMoneda,,,.T.,.F.,,"2") ,oFont1,400,10,CLR_BLACK, 0, 0 ) // "SON:"
	nLinea += 10
	oPrinter:Line(nLinea,10,nLinea,580,,"-4")
	nLinea += 10
	cNote := oXml:_CBC_NOTE:TEXT
	If !Empty(cNote)
		cNote := Strtran(cNote , "<br>", CRLF)
		nTamMemo := MLCount(cNote,nTamLin)
		For nX := 1 to nTamMemo
			oPrinter:SayAlign(nLinea,10,Alltrim(MemoLine(cNote,nTamLin,nX)),oFont1,400,10,CLR_BLACK, 0, 0 )
			nLinea += 10
		Next nX
	Endif
	oPrinter:Line(nLinea,10,nLinea,580,,"-4")
	nLinea += 5
	If Alltrim(cEspecie)=="NF"
		oPrinter:SayAlign(nLinea,190,STR0074 + cCUFE,oFont1,200,5,CLR_BLACK, 2, 2 ) //CUFE
	EndIf
Return Nil

/*/{Protheus.doc} CargaLogo
Carga logo de la empresa
@type function
@author mayra.camargo
@since 17/05/2018
@version 1.0
@return cLogo .- Retorna url de ubicación de logo de empresa.
/*/
Static Function CargaLogo()
	Local  cStartPath:= GetSrvProfString("Startpath","")

	cLogo	:= cStartPath + "ADMIN	"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial
	//-- Logotipo da Empresa
	If !File( cLogo )
		cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	EndIf
Return cLogo


/*/{Protheus.doc} GenCodBar
Genera código de barras QR en el reporte de factura
@type function
@author mayra.camargo
@since 17/05/2018
@version 1.0
@param oXml, objeto, Objeto con estructura de archivo XML.
@return cRet, Cadena de caracteres que seran mostrados en el  codigo de barras
/*/
Static Function GenCodBar(oXml, cEspecie)
	Local cNumDoc		:= ""
	Local cFechaDoc		:= Replace(oXml:_CBC_ISSUEDATE:TEXT,"-","") + Replace(oXml:_CBC_ISSUETIME:TEXT,":","")
	Local nTamSer		:= TamSX3("F2_SERIE2")[1]
	Local nTamIdDoc		:= Len(oXml:_CBC_ID:TEXT)
	Local cNITFac		:= oXml:_FE_ACCOUNTINGSUPPLIERPARTY:_FE_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_ID:TEXT
	Local cNumAdq		:= oXml:_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_ID:TEXT
	Local cValFac		:= Transform(Val(oXml:_FE_LEGALMONETARYTOTAL:_CBC_LINEEXTENSIONAMOUNT:TEXT),cPicture2)
	Local cValIva		:= Transform(nImpIva,cPicture2)
	Local cValFacTot	:= Transform(Val(oXml:_FE_LEGALMONETARYTOTAL:_CBC_PAYABLEAMOUNT:TEXT),cPicture2)
	Local cValOtroIm	:= Transform(0,cPicture2)
	Local cCUFE			:= ""
	Local cCodBarra		:= ""

	cNumDoc   := oXml:_CBC_ID:TEXT // Substr(oXml:_CBC_ID:TEXT, 1, nTamSer) + "-" + Substr(oXml:_CBC_ID:TEXT,nTamSer + 1, nTamIdDoc)
	cCodBarra := "NumFac: " + cNumDoc + CRLF + ;
				"FecFac: " + cFechaDoc + CRLF + ;
				"NitFac: " + cNITFac + CRLF + ;
				"DocAdq: " + cNumAdq + CRLF + ;
				"ValFac: " + lTrim(cValFac) + CRLF + ;
				"ValIva: " + lTrim(cValIva) + CRLF + ;
				"ValOtroIm: " + lTrim(cValOtroIm) + CRLF + ;
				"ValFacIm: " + lTrim(cValFacTot)

	If Alltrim(cEspecie) == "NF"
		cCUFE := oXml:_CBC_UUID:TEXT
		cCodBarra += CRLF + "CUFE: " + cCUFE
	EndIf

Return cCodBarra


/*/{Protheus.doc} ObtImptos
lEEE LOS IMPUESTIS DESDE EL XML
@type function
@author mayra.camargo
@since 17/05/2018
@version 1.0
@param oXml, objeto, Objeto con estructura de archivo XML.
/*/
Static Function ObtImptos(oXml)
	Local nX        := 0

	aImptos := {}
//	If Alltrim(cEspecie) <> "NCC"
		If AttIsMemberOf(oXML,"_FE_TAXTOTAL")
			If ValType(oXml:_FE_TAXTOTAL) == "A"
				For nX := 1 to Len(oXml:_FE_TAXTOTAL)
					aAdd(aImptos,{oXml:_FE_TAXTOTAL[nX]:_FE_TAXSUBTOTAL:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT,Val(oXml:_FE_TAXTOTAL[nX]:_CBC_TAXAMOUNT:TEXT),oXml:_FE_TAXTOTAL[nX]:_CBC_TAXEVIDENCEINDICATOR:TEXT})
				Next nX
			Else
				aAdd(aImptos,{oXml:_FE_TAXTOTAL:_FE_TAXSUBTOTAL:_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT,Val(oXml:_FE_TAXTOTAL:_CBC_TAXAMOUNT:TEXT),oXml:_FE_TAXTOTAL:_CBC_TAXEVIDENCEINDICATOR:TEXT})
			EndIf
		EndIf
//	Else
//		aAdd(aImptos,{"01",Val(oXml:_FE_LEGALMONETARYTOTAL:_CBC_TAXEXCLUSIVEAMOUNT:TEXT)})
//	EndIf
Return Nil


/*/{Protheus.doc} SaltoPag
Genera salto de página en reporte
@type function
@author mayra.camargo
@since 17/05/2018
@version 1.0
@param oPrinter, objeto, objeto creado por FWMSPrinter.
/*/
Static Function SaltoPag(oPrinter)
	oPrinter:Line(nLinea,10,nLinea,580,,"-4")

	oPrinter:EndPage()
	oPrinter:StartPage()

	ImpEnc(oPrinter,oXml) //Encabezado
Return Nil


/*/{Protheus.doc} EnvioMail
rEALIZA ENVIÓ VÍA EMAIL
@type function
@author mayra.camargo
@since 17/05/2018
@version 1.0
@param cEmailC, character, Email del cliente para envio de archivo XML/PDF
@param aAnexo, array, Arreglo con archivos adjuntos.
@return lRet,lógico, Valor lógico .T. envio exitoso, .F. error de envio
@example
(examples)
@see (links_or_references)
/*/
Function EnvioMail(cEmailC, aAnexo)
	Local lResult	:= .F.
	Local cServer	:= GetMV( "MV_RELSERV",,"" )	//Nombre de servidor de envio de E-mail utilizado en los informes.
	Local cEmail	:= GetMV( "MV_RELACNT",,"" )	//Cuenta a ser utilizada en el envio de E-Mail para los informes
	Local cPassword	:= GetMV( "MV_RELPSW",,""  )	//Contrasena de cta. de E-mail para enviar informes
	Local lAuth		:= GetMv( "MV_RELAUTH",, .F.)	//Servidor de E-Mail necessita de Autenticacao
	Local lUseSSL	:= GetMv( "MV_RELSSL",, .F.)	//Define se o envio e recebimento de E-Mail utilizara conexao segura (SSL)
	Local lUseTLS	:= GetMv( "MV_RELTLS",, .T.)	//Define se o envio e recebimento de E-Mail utilizara conexao segura (SSL)
	Local nPort		:= GetMv( "MV_SRVPORT",, 25)	//Puerto de conexión
	Local cUsrAuth	:= GetMV( "MV_RELAUSR",,"" )	//Usuario para autenticación
	Local cPswAuth	:= GetMV( "MV_RELAPSW",,""  )	//Contraseña de autenticación
	Local nTimeOut	:= 120
	Local oMailServer := Nil
	Local oMessage	:= Nil
	Local nErr		:= 0
	Local cAttach   := ""
	Local nI        := 0

	If !lAuth
		CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPassword RESULT lResult

		If lResult .And. !Empty(cEmailC)
			For nI:= 1 to Len(aAnexo)
				cAttach += aAnexo[nI] + "; "
			Next nI
			SEND MAIL FROM cEmail ;
			TO      	cEmailC;
			BCC     	"";
			SUBJECT 	cLetFac;
			BODY    	cLetPie;
			ATTACHMENT  cAttach  ;
			RESULT lResult
			DISCONNECT SMTP SERVER
		EndIf

	Else
		//Instancia o objeto do MailServer
		oMailServer:= TMailManager():New()
		oMailServer:SetUseSSL(lUseSSL)			//Obs: Apenas se servidor de e-mail utiliza autenticacao SSL para envio
		oMailServer:SetUseTLS(lUseTLS)			//Obs: Apenas se servidor de e-mail utiliza autenticacao TLS para recebimento
		oMailServer:Init("pop.totvs.com.br",cServer,cEmail,cPassword,0,nPort)

		//Definicao do timeout do servidor
	   	If oMailServer:SetSmtpTimeOut(nTimeOut) != 0
	   		Help(" ",1,STR0076,,STR0077,4,5) // "ATENCION" , "No se puede establecer el tiempo de espera del servidor de envío."
	        Return .F.
	    EndIf

	    //Conexao com servidor
	    nErr := oMailServer:smtpConnect()
		If nErr <> 0
			Help(" ",1,STR0076,,oMailServer:getErrorString(nErr),4,5)//"ATENCION"
			oMailServer:smtpDisconnect()
			Return .F.
		EndIf

		//Autenticacao com servidor smtp
		nErr := oMailServer:smtpAuth(cEmail, cPassword)
		If nErr <> 0
			Help(" ",1,STR0076,,STR0078 + oMailServer:getErrorString(nErr),4,5)//"ATENCION", "[Error] Falla al autenticar: "
			oMailServer:smtpDisconnect()
			Return .F.
		EndIf

		//Cria objeto da mensagem
		oMessage := tMailMessage():new()
		oMessage:clear()
		oMessage:cFrom := cEmail
		oMessage:cTo := cEmailC
		oMessage:cCc := ""
		oMessage:cSubject := cLetFac
		oMessage:cBody := cLetPie

		For nI := 1 to Len(aAnexo)
			oMessage:AddAttHTag("Content-ID: <" + aAnexo[nI] + ">")	//Essa tag, a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
			oMessage:AttachFile(aAnexo[nI])							//Adiciona um anexo, nesse caso a imagem esta no root
		Next nI

		//Dispara o email
		nErr := oMessage:send(oMailServer)

		If nErr <> 0
			Help(" ",1,STR0076,,STR0079 + oMailServer:getErrorString(nErr),4,5)//"ATENCION", "[Error] Falla al enviar: "
		Else
			//ApMsgInfo("E-mail enviado com sucesso", "SUCESSO")
			lResult := .T.
		EndIf

		//Desconecta do servidor
		oMailServer:smtpDisconnect()

	EndIf

Return lResult

/*/{Protheus.doc} ObtEmail
Obtiene valorES PARA ENVIO DE eMAIL
@type function
@author mayra.camargo
@since 17/05/2018
@version 1.0
@param cCliente, character,Código de cliente
@param cLoja, character, Código de tienda
@param cFilSA1, character, Filial de la tabla SA1
@param cFilAI0, character, Filial de la tabla AI0
@return cRet, character, Email del cliente

/*/
Static Function ObtEmail(cCliente,cLoja,cFilSA1, cFilAI0, cNomCli)
	Local cEmailCli := ""
	Local aArea 	:= getArea()

	Default cCliente := ""
	Default cLoja    := ""
	Default cFilSA1  := xFilial("SA1")
	Default cFilAI0  := xFilial("AI0")
	Default cNomCli  := ""

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	dbSelectArea("AI0")
	AI0->(dbSetOrder(1)) //AI0_FILIAL+AI0_CODCLI+AI0_LOJA
	cNomCli := ""
	If SA1->(dbSeek(cFilSA1 + cCliente + cLoja))
		cNomCli := Alltrim(SA1->A1_NOME)
		If AI0->(ColumnPos("AI0_RECE")) > 0 //Email especial para Recepción (Definido ante la DIAN)
			//Complementos del Cliente
			If AI0->(dbSeek(cFilAI0 + cCliente + cLoja))
				If !Empty(AI0->AI0_RECE)
					cEmailCli := Alltrim(AI0->AI0_RECE)
				EndIf
			EndIf
		EndIf
		If Empty(cEmailCli)	
			If !Empty(SA1->A1_EMAIL)
				cEmailCli := Alltrim(SA1->A1_EMAIL)
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return cEmailCli

/*/{Protheus.doc} F486MsgObs
Muestra las observaciones en una lista de texto.
@type
@author luis.enriquez
@since 29/07/2022
@version 1.0
@param aObs, array que contiene las observaciones detectadas al enviar email
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Function F486MsgObs(aObs)
	Local nI       := 0
	Local oDlg     := Nil
	Local oSay     := Nil
	Local cMsg     := ""
	Local cEnc     := ""
	Local cCRLF	   := (chr(13)+chr(10))

	CURSORWAIT()

	cMsg := STR0101 + cCRLF + cCRLF //"Para los siguientes documentos, el Cliente no tiene configurado el email para envío:"

	For nI := 1 To Len(aObs)
		cMsg += STR0102 + ": " + Alltrim(aObs[nI][1]) + "-" + Alltrim(aObs[nI][2]) + " / " + STR0006 + ": " + Alltrim(aObs[nI][3]) + "-" + Alltrim(aObs[nI][4]) + " " + Alltrim(aObs[nI][5]) + cCRLF //"Documento" //"Cliente"
	Next nI

	CURSORARROW()

	DEFINE MSDIALOG oDlg FROM 0,0 TO 390,440 PIXEL TITLE STR0103 //"Atención"
	oDlg:lMaximized := .F.
	oSay := TSay():New(05,05,{||OemToAnsi(cEnc)},oDlg,,,,,,.T.)
	oMemo:= tMultiget():New(20,05,{|u|IIf(Pcount() > 0, cMsg:=u, cMsg)} ,oDlg,213,155,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
	oButton := TButton():New(177, 187,STR0104,oDlg,{||oDlg:End()},30,15,,,,.T.) //"Salir"
	ACTIVATE MSDIALOG oDlg CENTERED

Return Nil
