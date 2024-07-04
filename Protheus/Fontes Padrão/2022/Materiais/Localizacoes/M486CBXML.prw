#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M486CBXML   ³ Autor ³ Luis Enriquez         ³ Data ³ 12.02.19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Generacion de XML de Comunicado de Baja para facturación elec-³±±
±±³          ³trónica de Peru, de acuerdo a estandar UBL 2.0, para ser en-  ³±±
±±³          ³viado a TSS para su envio a la SUNAT. (PERU)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486CBXML(cFil, cSerie, cCliente, cLoja, cNumDoc, cEspDoc)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFil .- Sucursal que emitio el documento.                    ³±±
±±³          ³ cSerie .- Numero o Serie del Documento.                      ³±±
±±³          ³ cCliente .- Codigo del cliente.                              ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±³          ³ cNumDoc .- Numero de documento.                              ³±±
±±³          ³ cEspDoc .- Especie del documento.                            ³±±
±±³          ³ cMotivo .- Motivo del comunicado de baja.                    ³±±
±±³          ³ cIdComBaja .- Id de comunicado de baja.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA486                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³           ³                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486CBXML(cFil, cSerie, cCliente, cLoja, cNumDoc, cEspDoc, cMotivo, cIdComBaja) 
	Local cXMLCB    := ""	
	Local aArea 	:= getArea()
	Local cTpDocT   := ""
	Local cFecha    := ""
	Local cAliasQry := GetNextAlias()
	Local nCountSF1 := 0
	Local nCountCR  := 0
	
	If Alltrim(cEspDoc) $ "NF|NDC"
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If SF2->(dbSeek(cFil + cNumDoc + cSerie + cCliente + cLoja)) 
			If Alltrim(cEspDoc) == "NDC"
				cTpDocT := "08"
			Else
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
				
				If dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA)
					cTpDocA1 := SA1->A1_TIPDOC
				Else
					cTpDocA1 := ""
				EndIf
				
				If Alltrim(cEspDoc) == "NF" .AND. 'F' $ Substr(SF2->F2_SERIE2,1,1) // Factura
					cTpDocT := "01"
				ElseIf Alltrim(cEspDoc) == "NF" .AND. 'B' $ Substr(SF2->F2_SERIE2,1,1) .AND. cTpDocA1 # "06" // Boleta de Venta
					cTpDocT := "03"
				EndIf		
			EndIf
			
			cFecha := Alltrim(Str(YEAR(SF2->F2_EMISSAO))) + "-" + Padl(Alltrim(Str(MONTH(SF2->F2_EMISSAO))),2,'0') + "-" +;
			Padl(Alltrim(Str(DAY(SF2->F2_EMISSAO))),2,'0')		
		
			// Se genera XML de Comunicado de Baja	
			cXMLCB := fGenXMLCB(SF2->F2_SERIE2, SF2->F2_DOC, cTpDocT, cMotivo, cFecha, cIdComBaja)
		EndIf
	ElseIf Alltrim(cEspDoc) == "NCC"
		BeginSQL Alias cAliasQry
			SELECT F1_SERIE2, F1_DOC, F1_EMISSAO 
			FROM %table:SF1% SF1
			WHERE  SF1.F1_FILIAL = %Exp:xFilial("SF1")%
				AND SF1.F1_SERIE = %Exp:cSerie%
				AND SF1.F1_DOC = %Exp:cNumDoc%
				AND SF1.F1_FORNECE = %Exp:cCliente%
				AND SF1.F1_LOJA = %Exp:cLoja%
				AND SF1.%NotDel%
		EndSQL
		
		count to nCountSF1
		
		TCSetField(cAliasQry,"F1_EMISSAO","D")
		
		If nCountSF1 > 0
			DbSelectArea(cAliasQry)
			(cAliasQry)->(DbGoTop())
			While (cAliasQry)->(!EOF())
				cTpDocT := "07"
				
				cFecha := Alltrim(Str(YEAR((cAliasQry)->F1_EMISSAO))) + "-" + Padl(Alltrim(Str(MONTH((cAliasQry)->F1_EMISSAO))),2,'0') + "-" +;
				Padl(Alltrim(Str(DAY((cAliasQry)->F1_EMISSAO))),2,'0')		
			
				// Se genera XML de Comunicado de Baja	
				cXMLCB := fGenXMLCB((cAliasQry)->F1_SERIE2, (cAliasQry)->F1_DOC, cTpDocT, cMotivo, cFecha, cIdComBaja)
				(cAliasQry)->(DbSkip())
			Enddo
		EndIf	
		(cAliasQry)->(dbCloseArea())
	ElseIf _lCerRet //Certificado de Retención
		BeginSQL Alias cAliasQry
			SELECT FE_SERIE2, FE_NROCERT, FE_EMISSAO 
			FROM %table:SFE% SFE
			WHERE  SFE.FE_FILIAL = %Exp:xFilial("SFE")%
				AND SFE.FE_SERIE2 = %Exp:cSerie%
				AND SFE.FE_NROCERT = %Exp:cNumDoc%
				AND SFE.FE_FORNECE = %Exp:cCliente%
				AND SFE.FE_LOJA = %Exp:cLoja%
				AND SFE.%NotDel%
		EndSQL

		count to nCountCR
		
		TCSetField(cAliasQry,"FE_EMISSAO","D")
		
		If nCountCR > 0
			DbSelectArea(cAliasQry)
			(cAliasQry)->(DbGoTop())
			While (cAliasQry)->(!EOF())
				cTpDocT := "20"
				
				cFecha := Alltrim(Str(YEAR((cAliasQry)->FE_EMISSAO))) + "-" + Padl(Alltrim(Str(MONTH((cAliasQry)->FE_EMISSAO))),2,'0') + "-" +;
				Padl(Alltrim(Str(DAY((cAliasQry)->FE_EMISSAO))),2,'0')		
			
				// Se genera XML de Comunicado de Baja	
				cXMLCB := fGenXMLCB((cAliasQry)->FE_SERIE2, (cAliasQry)->FE_NROCERT, cTpDocT, cMotivo, cFecha, cIdComBaja)
				(cAliasQry)->(DbSkip())
			Enddo
		EndIf	
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aArea)	
Return cXMLCB

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGenXMLCB  ³ Autor ³ Luis Enriquez         ³ Data ³ 12.02.19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura de XML para comunicado de baja de acuerdo a³±±
±±³          ³ esquema UBL 2.1 (PERU).                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGenXMLCB(cClie, cTienda, aValAd, aEnc, aImpXML, aDetImp)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cClie .- Codigo de cliente.                                  ³±±
±±³          ³ cTienda .- Codigo de tienda de cliente.                      ³±±
±±³          ³ aValAd .- Arreglo con datos para area de adicionales.        ³±±
±±³          ³ aEnc .- Arreglo con datos para encabezado de XML.            ³±±
±±³          ³ aImpXML .- Arreglo con datos impuestos generales de XML.     ³±±
±±³          ³ aDetImp .- Arreglo con datos de detalle de nota de debito pa-³±±
±±³          ³            ra XML.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXML .- String con estructrura de XML para factura/boleta de ³±±
±±³          ³ venta.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486CBXML                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGenXMLCB(cSerie2, cDoc, cTpDocT, cMotivo, cFecha, cIdComBaja)
	Local cXML     := ""
	Local cCRLF	   := (chr(13)+chr(10))
	Local cFecTrab := Alltrim(Str(YEAR(dDataBase))) + "-" + Padl(Alltrim(Str(MONTH(dDataBase))),2,'0') + "-" +;
			          Padl(Alltrim(Str(DAY(dDataBase))),2,'0')

	cXML := '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' + cCRLF
	cXML += '<VoidedDocuments' + cCRLF 
	cXML += '	xmlns="urn:sunat:names:specification:ubl:peru:schema:xsd:VoidedDocuments-1"' + cCRLF 
	cXML += '	xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' + cCRLF
	cXML += '	xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"' + cCRLF 
	cXML += '	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"' + cCRLF 
	cXML += '	xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"' + cCRLF 
	cXML += '	xmlns:sac="urn:sunat:names:specification:ubl:peru:schema:xsd:SunatAggregateComponents-1"' + cCRLF
	cXML += '	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' + cCRLF
	
	cXML += '	<ext:UBLExtensions>' + cCRLF
   	cXML += '		<ext:UBLExtension>' + cCRLF 
	cXML += '			<ext:ExtensionContent></ext:ExtensionContent>' + cCRLF 
  	cXML += '		</ext:UBLExtension>' + cCRLF    
	cXML += '	</ext:UBLExtensions>' + cCRLF	
	
	cXML += '	<cbc:UBLVersionID>2.0</cbc:UBLVersionID>' + cCRLF
	cXML += '	<cbc:CustomizationID>1.0</cbc:CustomizationID>' + cCRLF	
	cXML += '	<cbc:ID>' + Alltrim(cIdComBaja) + '</cbc:ID>' + cCRLF  
	cXML += '	<cbc:ReferenceDate>' + Alltrim(cFecha) + '</cbc:ReferenceDate>' + cCRLF  
	cXML += '	<cbc:IssueDate>' + Alltrim(cFecTrab) + '</cbc:IssueDate>' + cCRLF  

	cXML += M486XmlFE() 	// Firma Electrónica	
	cXML += M486XMLEMI(.T.) 	// Emisor	
	
	cXML += '	<sac:VoidedDocumentsLine>' + cCRLF
    cXML += '		<cbc:LineID>1</cbc:LineID>' + cCRLF
    cXML += '		<cbc:DocumentTypeCode>' + Alltrim(cTpDocT) + '</cbc:DocumentTypeCode>' + cCRLF
    cXML += '		<sac:DocumentSerialID>' + Alltrim(cSerie2) + '</sac:DocumentSerialID>' + cCRLF
    cXML += '		<sac:DocumentNumberID>' + ALLTRIM(STRZERO(VAL(cDoc),8)) + '</sac:DocumentNumberID>' + cCRLF
    cXML += '		<sac:VoidReasonDescription>' + Alltrim(cMotivo) + '</sac:VoidReasonDescription>' + cCRLF
 	cXML += '	</sac:VoidedDocumentsLine>' + cCRLF

	cXML += '</VoidedDocuments>' + cCRLF	
Return cXML
