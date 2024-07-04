#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"

/*/{Protheus.doc} M486RDXML
	Generacion de XML - Resumen Diario de Boletas de Venta Electrónicas 
	y Notas Electrónicas vinculadas a Boletas de Venta.
	@type function
	@author oscar.lopez
	@since 22/11/2021
	@version 1.0
	@param cFilSF	, string, Sucursal que emitio el documento.
	@param cSerie	, string, Numero o Serie del Documento.
	@param cCliente	, string, Codigo del cliente.
	@param cLoja	, string, Codigo de la tienda del cliente.
	@param cNumDoc	, string, Numero de documento.
	@param cEspecie	, string, Especie del documento.
	@param cIdReDia	, string, ID Resumen Diario.
	@return cXml	, string, Texto con estructura de XML.
	@example
		cXml := M486RDXML(cFilSF, cSerie, cCliente, cLoja, cNumDoc, cEspecie, cIdReDia)
/*/
Function M486RDXML(cFilSF, cSerie, cCliente, cLoja, cNumDoc, cEspecie, cIdReDia)
	Local cXMLRD	:= ""
	Local cMoneda	:= ""
	Local aEncab	:= {}
	Local aValAdic	:= {}
	Local cLetraVB	:= ""
	Local aArea		:= getArea()
	Local aImpFact	:= {} //Impuestos
	Local aDetFact	:= {} //Items
	Local nTotalFac	:= 0
	Local lFacGra	:= .F.
	Local lDocExp	:= .F.
	Local nValBrut	:= 0
	Local cFecha	:= ""
	Local cFolio	:= ""
	Local aGRNF		:= {}
	Local nDescont	:= 0
	Local nGastos	:= 0
	Local nTotImp	:= 0
	Local lIvap		:= .F.
	Local cOpeExp	:= ""
	Local nVlrImp	:= 0
	Local cTipoCod	:= ""
	Local cTpDocCli := ""
	Local nValMerc	:= 0

	Local cSFEsp	:= ""
	Local cSFDoc	:= ""
	Local cSFSer	:= ""
	Local cSFClie	:= ""
	Local cSFLoj	:= ""
	Local cSFRef	:= ""
	Local nSFMoed	:= ""
	Local cSer2		:= ""
	Local aInfClie	:= {"", "", ""}
	Local cEspDoc	:= alltrim(cEspecie)

	Local cFilSA1	:= xFilial("SA1")
	Local cFilCTO	:= xFilial("CTO")

	If cEspDoc $ "NF|NDC"
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If SF2->(MsSeek(cFilSF + cNumDoc + cSerie + cCliente + cLoja))
			cFolio	:= RTRIM(SF2->F2_SERIE2) + "-" + STRZERO(VAL(SF2->F2_DOC),8)
			cSFEsp	:= SF2->F2_ESPECIE
			cSFDoc	:= SF2->F2_DOC
			cSFSer	:= SF2->F2_SERIE
			cSFClie	:= SF2->F2_CLIENTE
			cSFLoj	:= SF2->F2_LOJA
			cSFRef	:= SF2->F2_TIPREF
			nSFMoed	:= SF2->F2_MOEDA
			cSer2	:= SF2->F2_SERIE2
			nValMerc:= SF2->F2_VALMERC
		EndIf
	Else
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		If SF1->(MsSeek(cFilSF + cNumDoc + cSerie + cCliente + cLoja))
			cFolio	:= RTRIM(SF1->F1_SERIE2) + "-" + STRZERO(VAL(SF1->F1_DOC),8) 
			cSFEsp	:= SF1->F1_ESPECIE
			cSFDoc	:= SF1->F1_DOC
			cSFSer	:= SF1->F1_SERIE
			cSFClie	:= SF1->F1_FORNECE
			cSFLoj	:= SF1->F1_LOJA
			cSFRef	:= SF1->F1_TIPREF
			nSFMoed	:= SF1->F1_MOEDA
			cSer2	:= SF1->F1_SERIE2
			nValMerc:= SF1->F1_VALMERC
		EndIf
	EndIf
	
	//Monedas
	dbSelectArea("CTO")
	CTO->(DbSetOrder(1))//CTO_FILIAL+CTO_MOEDA
	If CTO->(MsSeek(cFilCTO+Strzero(nSFMoed,2)))
		cMoneda := ALLTRIM(CTO->CTO_MOESAT)
	Else
		cMoneda := "PEN"
	EndIf

	//Clientes
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(MsSeek(cFilSA1 + cSFClie + cSFLoj))
		cTpDocCli := AllTrim(SA1->A1_TIPDOC)
		If cEspDoc == "NF" .And. cTpDocCli # "06" // Boleta de Venta
			cOpeExp  := "0200|0201|0203|0204|0206|0207|0208"
			lDocExp := IIf(SA1->A1_EST == "EX" .And. SF2->F2_TIPONF $ cOpeExp,.T.,.F.)
		EndIf
		aInfClie := {cTpDocCli, AllTrim(SA1->A1_CGC), AllTrim(SA1->A1_PFISICA)}
	EndIf
	
	//Impuestos
	M486XMLIMP(cSFEsp,cSFDoc,cSFSer,cSFClie,cSFLoj,lDocExp, @aImpFact, @aDetFact, @aValAdic, @nTotalFac, @lFacGra, @aGRNF, @nTotImp, @lIvap)
	
	//Encabezado
	If !lFacGra
		nValBrut  := IIF(cEspDoc $ "NF|NDC", SF2->F2_VALBRUT, SF1->F1_VALBRUT)
	EndIf

	/*
		01. Documento
		02. Fecha
		03. Moneda
		04. Total de venta documento
		05. Monto Total en letras
		06. Indicador Factura gratuita
		07. Indicador Factura Exportación
		08. Valor de la Mercanciá sin impuestos ni gastos 
		09. Valor Total Descuentos
		10. Valor Total de Gatos (Flete, seguro, otros gastos)
		11. Total Monto Impuestos
		12. Si es de exportacion
	*/
	If nTotalFac == nValMerc .AND. lDocExp
		aEncab := {cFolio, cFecha, cMoneda, nValBrut, cLetraVB, lFacGra, lDocExp, nValMerc-nTotImp, nDescont, nGastos, nTotImp, lDocExp}
	Else
		aEncab := {cFolio, cFecha, cMoneda, nValBrut, cLetraVB, lFacGra, lDocExp, nValMerc-nVlrImp, nDescont, nGastos, nTotImp, lDocExp}
	EndIf
	
	If cEspDoc == "NF" //Boleta de Venta
		cTipoCod := "03"
	ElseIf cEspDoc == "NCC" //Nota de Crédito
		cTipoCod := "07"
	Else //Nota de Débito
		cTipoCod := "08"
	EndIf

	// Se genera XML de Resumen Diario
	cXMLRD := fGenXMLRD(aInfClie, aEncab, aImpFact, aValAdic, nTotalFac, lFacGra, nTotImp, cIdReDia, cTipoCod)
	
	RestArea(aArea)
Return cXMLRD

/*/{Protheus.doc} fGenXMLRD
	Generacion de XML - Resumen Diario de Boletas de Venta Electrónicas 
	y Notas Electrónicas vinculadas a Boletas de Venta.
	@type function
	@author oscar.lopez
	@since 22/11/2021
	@version 1.0
	@param aInfClie	, array	, Arreglo con la información de cliente.
	@param aEnc		, array	, Arreglo con informacion de impuestos para encabezado.
	@param aImpFact	, array	, Arreglo con informacion de detale de impuestos.
	@param aValAd	, array, Arreglo con datos para area de adicionales.
	@param nTotalFac, int	, Valor total de Factura.
	@param lFacGra	, boolean, Factura grava impuestos.
	@param nTotImp	, int	, Valor total de impuestos
	@param cIdReDia	, string, ID de Resumen Diario.
	@param cTipoCod	, string, Tipo de Documento que se esta anulando.
	@return cXml	, string, Texto con estructura de XML.
	@example
		cXml := fGenXMLRD(aInfClie, aEnc, aImpFact, aValAd, nTotalFac, lFacGra, nTotImp, cIdReDia, cTipoCod)
/*/
Static Function fGenXMLRD(aInfClie, aEnc, aImpFact, aValAd, nTotalFac, lFacGra, nTotImp, cIdReDia, cTipoCod)
	Local cXML		:= ""
	Local nX		:= 0
	Local nI		:= 0
	Local lProc		:= .T.
	Local cCRLF		:= (chr(13)+chr(10))
	Local aInfoEmp	:= FWSM0Util():GetSM0Data(,,{"M0_NOME","M0_CGC"})
	Local cNombreE	:= AllTrim(aInfoEmp[1,2])
	Local cDocuE	:= AllTrim(aInfoEmp[2,2])
	Local cFecTrab 	:= Alltrim(Str(YEAR(dDataBase))) + "-" + Padl(Alltrim(Str(MONTH(dDataBase))),2,'0') + "-" +;
			          Padl(Alltrim(Str(DAY(dDataBase))),2,'0')
					  
	cXML := '<?xml version="1.0" encoding="UTF-8"?>' + cCRLF
	cXML += '<SummaryDocuments' + cCRLF
	cXML += '	xmlns="urn:sunat:names:specification:ubl:peru:schema:xsd:SummaryDocuments-1"' + cCRLF
	cXML += '	xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' + cCRLF
	cXML += '	xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"' + cCRLF
	cXML += '	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"' + cCRLF
	cXML += '	xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"' + cCRLF
	cXML += '	xmlns:sac="urn:sunat:names:specification:ubl:peru:schema:xsd:SunatAggregateComponents-1">' + cCRLF
	
	cXML += '	<ext:UBLExtensions>' + cCRLF
   	cXML += '		<ext:UBLExtension>' + cCRLF
	cXML += '			<ext:ExtensionContent />' + cCRLF
  	cXML += '		</ext:UBLExtension>' + cCRLF
	cXML += '	</ext:UBLExtensions>' + cCRLF
	cXML += '	<cbc:UBLVersionID>2.0</cbc:UBLVersionID>' + cCRLF
	cXML += '	<cbc:CustomizationID>1.1</cbc:CustomizationID>' + cCRLF
	cXML += '	<cbc:ID>' + cIdReDia + '</cbc:ID>' + cCRLF
	cXML += '	<cbc:ReferenceDate>' + cFecTrab + '</cbc:ReferenceDate>' + cCRLF
	cXML += '	<cbc:IssueDate>' + cFecTrab + '</cbc:IssueDate>' + cCRLF
	
	//Signature
	cXML += '	<cac:Signature>' + cCRLF
	cXML += '		<cbc:ID>' + cDocuE + '</cbc:ID>' + cCRLF
	cXML += '		<cac:SignatoryParty>' + cCRLF
	cXML += '			<cac:PartyIdentification>' + cCRLF
	cXML += '				<cbc:ID>' + cDocuE + '</cbc:ID>' + cCRLF
	cXML += '			</cac:PartyIdentification>' + cCRLF
	cXML += '			<cac:PartyName>' + cCRLF
	cXML += '				<cbc:Name><![CDATA[' + cNombreE + ']]></cbc:Name>' + cCRLF
	cXML += '			</cac:PartyName>' + cCRLF
	cXML += '		</cac:SignatoryParty>' + cCRLF
	cXML += '		<cac:DigitalSignatureAttachment>' + cCRLF
	cXML += '			<cac:ExternalReference>' + cCRLF
	cXML += '				<cbc:URI>#SignatureTOTVS</cbc:URI>' + cCRLF
	cXML += '			</cac:ExternalReference>' + cCRLF
	cXML += '		</cac:DigitalSignatureAttachment>' + cCRLF
	cXML += '	</cac:Signature>' + cCRLF

	cXML += '	<cac:AccountingSupplierParty>' + cCRLF
	cXML += '		<cbc:CustomerAssignedAccountID>' + cDocuE + '</cbc:CustomerAssignedAccountID>' + cCRLF
	cXML += '		<cbc:AdditionalAccountID>6</cbc:AdditionalAccountID>' + cCRLF
	cXML += '		<cac:Party>' + cCRLF
	cXML += '			<cac:PartyLegalEntity>' + cCRLF
	cXML += '				<cbc:RegistrationName><![CDATA[' + cNombreE + ']]></cbc:RegistrationName>' + cCRLF
	cXML += '			</cac:PartyLegalEntity>' + cCRLF
	cXML += '		</cac:Party>' + cCRLF
	cXML += '	</cac:AccountingSupplierParty>' + cCRLF

	cXML += '	<sac:SummaryDocumentsLine>' + cCRLF
	cXML += '		<cbc:LineID>1</cbc:LineID>' + cCRLF
	cXML += '		<cbc:DocumentTypeCode>' + cTipoCod + '</cbc:DocumentTypeCode>' + cCRLF
	cXML += '		<cbc:ID>' + aEnc[1] + '</cbc:ID>' + cCRLF

	cXML += '		<cac:AccountingCustomerParty>' + cCRLF
	cXML += '			<cbc:CustomerAssignedAccountID>' + IIf(!Empty(aInfClie[2]), aInfClie[2], aInfClie[3]) + '</cbc:CustomerAssignedAccountID>' + cCRLF
	cXML += '			<cbc:AdditionalAccountID>' + aInfClie[1] + '</cbc:AdditionalAccountID>' + cCRLF
	cXML += '		</cac:AccountingCustomerParty>' + cCRLF
	
	cXML += '		<cac:Status>' + cCRLF
	cXML += '			<cbc:ConditionCode>3</cbc:ConditionCode>' + cCRLF
	cXML += '		</cac:Status>' + cCRLF
	cXML += '		<sac:TotalAmount currencyID="' + aEnc[3] + '">' + AllTrim(Transform(aEnc[4],"999999999999.99")) + '</sac:TotalAmount>' + cCRLF
	cXML += '		<sac:BillingPayment>' + cCRLF
	cXML += '			<cbc:PaidAmount currencyID="' + aEnc[3] + '">' + AllTrim(Transform(aEnc[8],"999999999999.99")) + '</cbc:PaidAmount>' + cCRLF
	cXML += '			<cbc:InstructionID>01</cbc:InstructionID>' + cCRLF
	cXML += '		</sac:BillingPayment>' + cCRLF
	
	For nX :=1 To Len(aImpFact)
		// Impuestos totales
		If (aImpFact[nX,3] <> "D") //Diferente de Detracción
			If lProc
				cXML += '		<cac:TaxTotal>' + cCRLF
				cXML += '			<cbc:TaxAmount currencyID="' + aEnc[3] + '">' + AllTrim(Transform(aImpFact[nX,6],"999999999999.99")) + '</cbc:TaxAmount>' + cCRLF
				lProc := .F.
			EndIf
			If !aEnc[7]
				cXML += '			<cac:TaxSubtotal>' + cCRLF
				cXML += '				<cbc:TaxAmount currencyID="' + aEnc[3] + '">' + AllTrim(Transform(aImpFact[nX,6],"999999999999.99")) + '</cbc:TaxAmount>' + cCRLF
				cXML += '				<cac:TaxCategory>' + cCRLF
				cXML += '					<cac:TaxScheme>' + cCRLF
				cXML += '						<cbc:ID>' + aImpFact[nX,2] + '</cbc:ID>' + cCRLF
				cXML += '						<cbc:Name>' + aImpFact[nX,4] + '</cbc:Name>' + cCRLF
				cXML += '						<cbc:TaxTypeCode>' + aImpFact[nX,5] + '</cbc:TaxTypeCode>' + cCRLF
				cXML += '					</cac:TaxScheme>' + cCRLF
				cXML += '				</cac:TaxCategory>' + cCRLF
				cXML += '			</cac:TaxSubtotal>' + cCRLF
			EndIf
			If nX == len(aImpFact)
				// Se procesan los Valores de las Operaciones del IGV
				For nI:=2 to len(aValAd)
					If aValAd[nI,2]> 0
						cXML += '			<cac:TaxSubtotal>' + cCRLF
						cXML += '				<cbc:TaxAmount currencyID="' + aEnc[3] + '">' + AllTrim(TRANSFORM(aValAd[nI,3],"999999999999.99")) + '</cbc:TaxAmount>' + cCRLF
						cXML += '				<cac:TaxCategory>' + cCRLF
						cXML += '					<cac:TaxScheme>' + cCRLF
						cXML += '						<cbc:ID>' + aValAd[nI,1] + '</cbc:ID>' + cCRLF
						cXML += '						<cbc:Name>' + aValAd[nI,4] + '</cbc:Name>' + cCRLF
						cXML += '						<cbc:TaxTypeCode>' + aValAd[nI,5] + '</cbc:TaxTypeCode>' + cCRLF
						cXML += '					</cac:TaxScheme>' + cCRLF
						cXML += '				</cac:TaxCategory>' + cCRLF
						cXML += '			</cac:TaxSubtotal>' + cCRLF
					EndIf
				Next nI
			EndIf
			cXML += '		</cac:TaxTotal>' + cCRLF
		EndIf
	Next nX
	cXML += '	</sac:SummaryDocumentsLine>' + cCRLF
	cXML += '</SummaryDocuments>'

Return cXML
