#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"
#INCLUDE "MATA486.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M486NDCXML  ³ Autor ³ Luis Enriquez         ³ Data ³ 08.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Generacion de XML de Nota de debito  para facturacion electro-³±±
±±³          ³nica de Peru, de acuerdo a estandar UBL 2.0, para ser enviado ³±±
±±³          ³a TSS para su envio a la SUNAT. (PERU)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486NDCXML(cFil, cSerie, cCliente, cLoja, cNumDoc, cEspDoc)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFil .- Sucursal que emitio el documento.                    ³±±
±±³          ³ cSerie .- Numero o Serie del Documento.                      ³±±
±±³          ³ cCliente .- Codigo del cliente.                              ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±³          ³ cNumDoc .- Numero de documento.                              ³±±
±±³          ³ cEspDoc .- Especie del documento.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA486                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz  ³31/08/17³DMINA-38   ³Se modifica funcion fGenXMLNDC para  ³±±
±±³              ³        ³           ³negenerar de manera correcta el nodo ³±±
±±³              ³        ³           ³con se pondra la firma digital.      ³±±
±±³Alf Medrano   ³26/10/18³DMINA-4575 ³Se actualiza a UBL 2.1               ³±±
±±³V. Flores     ³23/01/19³DMINA-5822 ³Modificación de tranmision NCC y  XML³±± 
±±               ³        ³           ³para la NDC                          ³±± 
±±³M.Camargo     ³14/03/19³DMINA-4575 ³uso de funcion strZero supliendo el  ³±±
±±³              ³        ³           ³uso de substr para generar correlati-³±±
±±³              ³        ³           ³vo a 8 caracterés.                   ³±±
±±³V. Flores     ³06/09/19³DMINA-7628 ³Modificación de XML , agregando los  ³±± 
±±               ³        ³           ³nuevos nodos del impuesto ICBPER     ³±±
±±³M.Camargo     ³24/09/19³DMINA-7417 ³Modificación de XML uso de EXTENSO   ³±± 
±±³M.Camargo     ³11/10/19³DMINA-7508 |Apertuna PE M486ENDC                 ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486NDCXML(cFil, cSerie, cCliente, cLoja, cNumDoc, cEspDoc)	
	Local cXMLNDC := ""
	Local cMoneda := ""
	Local aEncab := {} 
	Local aDetFact := {}
	Local cLetraVB := ""
	Local aImpFact := {}
	Local aValAdic := {}
	Local nTotalFac := 0
	Local lFacGra := .F.
	Local nTamDoc 	:= TamSX3("F2_DOC")[1]
	Local aArea 	:= getArea()
	Local lDocExp := .F.	
	Local cSF1Hrs := ""
	Local nTotImp := 0
	
	dbSelectArea("SF2")
	SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(dbSeek(cFil + cNumDoc + cSerie + cCliente + cLoja)) 
		cFolio := RTRIM(SF2->F2_SERIE2) + "-" + STRZERO(val(SF2->F2_DOC),8)
		cFecha := Alltrim(Str(YEAR(SF2->F2_EMISSAO))) + "-" + Padl(Alltrim(Str(MONTH(SF2->F2_EMISSAO))),2,'0') + "-" +;
		Padl(Alltrim(Str(DAY(SF2->F2_EMISSAO))),2,'0')			
		CTO->(DbSetOrder(1))//CTO_FILIAL+CTO_MOEDA
		CTO->(dbSeek(xFilial("CTO")+Strzero(SF2->F2_MOEDA,2)))
		cMoneda := ALLTRIM(Posicione("CTO",1,xFilial("CTO")+Strzero(SF2->F2_MOEDA,2),"CTO_MOESAT"))
		cSF1Hrs := SF2->F2_HORA
		
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
	    If dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA)
			lDocExp := IIf(SA1->A1_EST == "EX" .And. SF2->F2_TIPREF $ "11",.T.,.F.)
		EndIf
		
		//Impuestos				
		M486XMLIMP(SF2->F2_ESPECIE,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA, lDocExp, @aImpFact, @aDetFact, @aValAdic, @nTotalFac, @lFacGra,,@nTotImp)	

		If !lFacGra
			cLetraVB := Extenso(SF2->F2_VALBRUT,.f.,SF2->F2_MOEDA,,"2",.t.,.t.) 
		Else
			cLetraVB :=  fCero2Text(SF2->F2_MOEDA)
		EndIf		
		
		//Encabezado
		cValBrut  := TRANSFORM(nTotalFac,"999999.99")			
			
		aEncab := {cFolio,cFecha,cMoneda,cValBrut,cLetraVB,SF2->F2_ESPECIE, SF2->F2_DOC, SF2->F2_SERIE,;
				SF2->F2_CLIENTE,SF2->F2_LOJA,RTRIM(SF2->F2_TIPREF),RTRIM(SF2->F2_MOTIVO),lFacGra,cSF1Hrs,nTotImp }	
				
		cXMLNDC := fGenXMLNDC(cCliente, cLoja, aValAdic, aEncab, aImpFact, aDetFact, lDocExp)
	EndIf	
	RestArea(aArea)	
Return cXMLNDC

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGenXMLNF  ³ Autor ³ Luis Enriquez         ³ Data ³ 01.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura de XML para nota de debito de acuerdo a es-³±±
±±³          ³ quema UBL 2.0. (PERU).                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGenXMLNF(cClie, cTienda, aValAd, aEnc, aImpXML, aDetImp)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cClie .- Codigo de cliente.                                  ³±±
±±³          ³ cTienda .- Codigo de tienda de cliente.                      ³±±
±±³          ³ aValAd .- Arreglo con datos para area de adicionales.        ³±±
±±³          ³ aEnc .- Arreglo con datos para encabezado de XML.            ³±±
±±³          ³ aImpXML .- Arreglo con datos impuestos generales de XML.     ³±±
±±³          ³ aDetImp .- Arreglo con datos de detalle de nota de debito pa-³±±
±±³          ³            ra XML.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXML .- String con estructrura de XML para nota de debito.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486XMLPDF                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGenXMLNDC(cClie, cTienda, aValAd, aEnc, aImpXML, aDetImp, lDocExp)
	Local nX  		:= 0
	Local nC  		:= 0
	Local nI		:= 0
	Local cXML 		:= ""
	Local cCRLF		:= (chr(13)+chr(10))
	Local cTexto	:= (OemToAnsi(STR0078)) //"TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE"
	Local cPValUn 	:= "999999999999.9999999999"
	Local cPValIt 	:= "999999999999.99"
	Local lRSM		:= ALLTRIM(SuperGetMV("MV_PROVFE",,"")) == "RSM"
	Local nVlPorc	:= 0
	
	cXML += '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' + cCRLF
	cXML += '<DebitNote xmlns="urn:oasis:names:specification:ubl:schema:xsd:DebitNote-2"' + cCRLF 
	cXML += 'xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' + cCRLF 
	cXML += 'xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"' + cCRLF 
	cXML += 'xmlns:ccts="urn:un:unece:uncefact:documentation:2"' + cCRLF 
	cXML += 'xmlns:ds="http://www.w3.org/2000/09/xmldsig#"' + cCRLF 
	cXML += 'xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"' + cCRLF 
	cXML += 'xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2"' + cCRLF 
	cXML += 'xmlns:sac="urn:sunat:names:specification:ubl:peru:schema:xsd:SunatAggregateComponents-1"' + cCRLF 
	cXML += 'xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"' + cCRLF 
	cXML += 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' + cCRLF
	
	cXML += '	<ext:UBLExtensions>' + cCRLF
	If lRSM
		// Puntos de Entrada que son habiles solamente cuando se usa RSM
		If ExistBlock("M486ENDC") 
			cXML += ExecBlock("M486ENDC",.F.,.F.,{SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,cClie,cTienda})
		EndIf
	EndIf
    cXML += '		<ext:UBLExtension>' + cCRLF
	cXML += '			<ext:ExtensionContent></ext:ExtensionContent>' + cCRLF  
    cXML += '		</ext:UBLExtension>' + cCRLF    
    cXML += '	</ext:UBLExtensions>' + cCRLF	
	
	cXML += '	<cbc:UBLVersionID>2.1</cbc:UBLVersionID>' + cCRLF
	cXML += '	<cbc:CustomizationID>2.0</cbc:CustomizationID>' + cCRLF
	cXML += '	<cbc:ID>' + aEnc[1] + '</cbc:ID>' + cCRLF
	cXML += '	<cbc:IssueDate>' +  aEnc[2] + '</cbc:IssueDate>' + cCRLF
	cXML += '	<cbc:IssueTime>' + aEnc[14] + '</cbc:IssueTime>'  + cCRLF 
	cXML += '	<cbc:Note languageLocaleID="1000">' + alltrim(aEnc[5]) + '</cbc:Note>' + cCRLF
	// Punto de Entrada para agregar campos personalizados Factura.
	If ExistBlock("M486NDC") 
		cXML += ExecBlock("M486NDC",.F.,.F.,{SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,cClie,cTienda})
	EndIf
	cXML += '	<cbc:DocumentCurrencyCode>' + aEnc[3] + '</cbc:DocumentCurrencyCode>' + cCRLF		

	cXML += M486REF(aEnc[6], aEnc[7], aEnc[8], aEnc[9], aEnc[10], aEnc[11], aEnc[12])
	     			   
	cXML += M486XMLFE() //Firma Electrónica
	
	cXML += M486XMLEMI() //Emisor	
	
	cXML += M486XMLREC(cClie, cTienda) //Receptor
	
	If Len(aImpXML) > 0
		For nX :=1 To Len(aImpXML)
				If nX == 1
					cXML += '	<cac:TaxTotal>' + cCRLF
					cXML += '		<cbc:TaxAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aEnc[15],"999999.99")) + '</cbc:TaxAmount>' + cCRLF
				EndIf
					If !lDocExp
						cXML += '		<cac:TaxSubtotal>' + cCRLF
						If aImpXML[nX,4] <>"ICB"
							cXML += '		<cbc:TaxableAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aImpXML[nX][10],"999999.99")) + '</cbc:TaxableAmount>' + cCRLF
						EndIf
						cXML += '		<cbc:TaxAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aImpXML[nX][6],"999999.99")) + '</cbc:TaxAmount>' + cCRLF
						cXML += '			<cac:TaxCategory>' + cCRLF
						cXML += '				<cac:TaxScheme>' + cCRLF
						cXML += '					<cbc:ID>' + aImpXML[nX][2] + '</cbc:ID>' + cCRLF
						cXML += '					<cbc:Name>' + IIF(aImpXML[nX][4] == "ICB", 'ICBPER',aImpXML[nX][4]) + '</cbc:Name>' + cCRLF
						cXML += '					<cbc:TaxTypeCode>' + aImpXML[nX][5] + '</cbc:TaxTypeCode>' + cCRLF
						cXML += '				</cac:TaxScheme>' + cCRLF
						cXML += '			</cac:TaxCategory>' + cCRLF
						cXML += '		</cac:TaxSubtotal>' + cCRLF
					EndIf
				If nX == len(aImpXML)
					// Se procesan los Valores de las Operaciones del IGV
					For nI:=2 to len(aValAd)
						If aValAd[nI,2]> 0
							cXML += '		<cac:TaxSubtotal>' + cCRLF
							cXML += '			<cbc:TaxableAmount currencyID="'+ aEnc[3] + '">' + alltrim(TRANSFORM(aValAd[nI,2],"999999.99")) + '</cbc:TaxableAmount>' + cCRLF
							cXML += '			<cbc:TaxAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aValAd[nI,3],"999999.99")) + '</cbc:TaxAmount>' + cCRLF
							cXML += '			<cac:TaxCategory>' + cCRLF
							cXML += '				<cac:TaxScheme>' + cCRLF
							cXML += '					<cbc:ID schemeID="UN/ECE 5153" schemeAgencyID="6">' + aValAd[nI,1] + '</cbc:ID>' + cCRLF
							cXML += '					<cbc:Name>' + aValAd[nI,4] + '</cbc:Name>' + cCRLF
							cXML += '					<cbc:TaxTypeCode>' + aValAd[nI,5] + '</cbc:TaxTypeCode>' + cCRLF
							cXML += '				</cac:TaxScheme>' + cCRLF
							cXML += '			</cac:TaxCategory>' + cCRLF
							cXML += '		</cac:TaxSubtotal>' + cCRLF							
						EndIf	
					Next nI		
					cXML += '	</cac:TaxTotal>' + cCRLF	
				EndIf					
		Next nX
	EndIf	
	//Total Nota de Débito
	cXML += '	<cac:RequestedMonetaryTotal>' + cCRLF
    cXML += '		<cbc:PayableAmount currencyID="' + aEnc[3] + '">' + alltrim(cValBrut) + '</cbc:PayableAmount>' + cCRLF
    cXML += '	</cac:RequestedMonetaryTotal>' + cCRLF	
    aSort(aDetImp,,,{|X,Y| x[1] < y[1]})
	If Len(aDetImp) > 0		
		For nX := 1 To Len(aDetImp)
			cXML += '	<cac:DebitNoteLine>' + cCRLF
			
			cXML += '		<cbc:ID>' + alltrim(str(aDetImp[nX][1])) + '</cbc:ID>' + cCRLF
			cXML += '		<cbc:DebitedQuantity unitCode="' + alltrim(aDetImp[nX][2]) + '" unitCodeListID="UN/ECE rec 20" unitCodeListAgencyName="United Nations Economic Commission for Europe">' + alltrim(TRANSFORM(aDetImp[nX][3],"999999999999.9999999999")) + '</cbc:DebitedQuantity>' + cCRLF
			cXML += '		<cbc:LineExtensionAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aDetImp[nX][4],cPValIt)) + '</cbc:LineExtensionAmount>' + cCRLF
			cXML += '		<cac:PricingReference>' + cCRLF
			If aDetImp[nX][12]
				cXML += '			<cac:AlternativeConditionPrice>' + cCRLF
				cXML += '				<cbc:PriceAmount currencyID="' + aEnc[3] + '">'+  Alltrim(TRANSFORM(aDetImp[nX][9], cPValUn)) +'</cbc:PriceAmount>' + cCRLF
				cXML += '				<cbc:PriceTypeCode>02</cbc:PriceTypeCode>' + cCRLF
				cXML += '			</cac:AlternativeConditionPrice>' + cCRLF					
			Else
				cXML += '			<cac:AlternativeConditionPrice>' + cCRLF
				cXML += '				<cbc:PriceAmount currencyID="' + aEnc[3] + '">' + Alltrim(TRANSFORM(aDetImp[nX][11], cPValUn)) + '</cbc:PriceAmount>' + cCRLF
				cXML += '				<cbc:PriceTypeCode>01</cbc:PriceTypeCode>' + cCRLF
				cXML += '			</cac:AlternativeConditionPrice>' + cCRLF			
			EndIf
			cXML += '		</cac:PricingReference>' + cCRLF

			If Len( aDetImp[nX][13]) > 0
					cXML += '		<cac:TaxTotal>' + cCRLF
					cXML += '			<cbc:TaxAmount currencyID="' + aEnc[3] + '">' +  alltrim(TRANSFORM(aDetImp[nX,5],"9999999999999.99")) + '</cbc:TaxAmount>' + cCRLF 
				For nC := 1 To Len(aDetImp[nX][13])
					If Len(aDetImp[nX][13][nC]) > 0
						cXML += '			<cac:TaxSubtotal>' + cCRLF
						If aDetImp[nX][13][nC,5] <> "ICB"
							cXML += '				<cbc:TaxableAmount currencyID="'+ aEnc[3] + '">' + alltrim(TRANSFORM(aDetImp[nX][4],cPValIt))+ '</cbc:TaxableAmount>' + cCRLF
						EndIf							
						cXML += '				<cbc:TaxAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aDetImp[nX][13][nC][1],cPValIt)) + '</cbc:TaxAmount>' + cCRLF
						If aDetImp[nX][13][nC,5] == "ICB"
							cXML += '				<cbc:BaseUnitMeasure unitCode="NIU">' + alltrim(TRANSFORM(aDetImp[nX][3],"9999999999999")) + '</cbc:BaseUnitMeasure>' + cCRLF 
						EndIf 
						cXML += '				<cac:TaxCategory>' + cCRLF
						If aDetImp[nX][13][nC,5] == "ICB"
							cXML += '					<cbc:PerUnitAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aDetImp[nX][16],"9999999999999.99")) + '</cbc:PerUnitAmount>' + cCRLF 
						Else
							nVlPorc := IIF(aDetImp[nX][13][nC][4] $ "9995|9997|9998", 0.00, aDetImp[nX][13][nC][8])  //Exonerado, Inafecto o Gratuitas debe ser 0.00
							cXML += '					<cbc:Percent>' + alltrim(TRANSFORM(nVlPorc,"999.99"))+ '</cbc:Percent> '  + cCRLF
						EndIf
						If !(aDetImp[nX][13][nC][5] $ "ISC|ICB")
							cXML += '					<cbc:TaxExemptionReasonCode>' + alltrim(aDetImp[nX][13][nC][2]) + '</cbc:TaxExemptionReasonCode>' + cCRLF
						ElseIf aDetImp[nX][13][nC][5] == "ISC"
							cXML += '					<cbc:TierRange >' + alltrim(aDetImp[nX][13][nC][3]) + '</cbc:TierRange >' + cCRLF
						EndIf
						cXML += '					<cac:TaxScheme>' + cCRLF
						cXML += '						<cbc:ID>' + aDetImp[nX][13][nC][4] + '</cbc:ID>' + cCRLF
						cXML += '						<cbc:Name>' + IIF(aDetImp[nX][13][nC][5] == "ICB", 'ICBPER',aDetImp[nX][13][nC][5]) + '</cbc:Name>' + cCRLF
						cXML += '						<cbc:TaxTypeCode>' + aDetImp[nX][13][nC][6] + '</cbc:TaxTypeCode>' + cCRLF
						cXML += '					</cac:TaxScheme>' + cCRLF
						cXML += '				</cac:TaxCategory>' + cCRLF
						cXML += '			</cac:TaxSubtotal>' + cCRLF
					EndIf
				Next nC
				cXML += '		</cac:TaxTotal>' + cCRLF
			EndIf

			cXML += '		<cac:Item>' + cCRLF
			cXML += '			<cbc:Description><![CDATA[' + IIF(lRSM,EncodeUtf8(aDetImp[nX][7]),aDetImp[nX][7]) + ']]></cbc:Description>' + cCRLF
			cXML += '			<cac:SellersItemIdentification>' + cCRLF
			cXML += '				<cbc:ID>' + aDetImp[nX][8] + '</cbc:ID>' + cCRLF
			cXML += '			</cac:SellersItemIdentification>' + cCRLF	
			cXML += '			<cac:CommodityClassification>' + cCRLF
			cXML += '				<cbc:ItemClassificationCode listID="UNSPSC" ' 
			cXML += 			'listAgencyName="GS1 US" '
			cXML += 			'listName="Item Classification">' +  aDetImp[nX,15]+ '</cbc:ItemClassificationCode>' + cCRLF
			cXML += '			</cac:CommodityClassification>' + cCRLF			
			cXML += '		</cac:Item>' + cCRLF
			cXML += '		<cac:Price>' + cCRLF
			cXML += '			<cbc:PriceAmount currencyID="' + aEnc[3] + '">' + IIf(!aDetImp[nX][12],alltrim(TRANSFORM(aDetImp[nX][10],cPValUn)),"0.00") + '</cbc:PriceAmount>' + cCRLF
			cXML += '		</cac:Price>' + cCRLF
			cXML += '	</cac:DebitNoteLine>' + cCRLF			
		Next nX		
	EndIf    
	cXML += '</DebitNote>' + cCRLF		
Return cXML
