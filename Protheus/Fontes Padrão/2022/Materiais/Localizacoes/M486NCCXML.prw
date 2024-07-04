#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"
#INCLUDE "MATA486.CH"

/*/����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �M486NCCXML  � Autor � Dora Vega             � Data � 09.06.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Generacion de XML para Nota de Credito para facturacion elec-���
���          � tronica de Peru, de acuerdo a esquema estandar UBL 2.0 para  ���
���          � ser enviado a TSS para su envio a la SUNAT. (PER)            ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � M486NCCXML(cFil, cSerie, cCliente, cLoja, cNumDoc, cEspDoc)  ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cFil .- Sucursal que emitio el documento.                    ���
���          � cSerie .- Numero o Serie del Documento.                      ���
���          � cCliente .- Codigo del cliente.                              ���
���          � cLoja .- Codigo de la tienda del cliente.                    ���
���          � cNumDoc .- Numero de documento.                              ���
���          � cEspDoc .- Especie del documento.                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � MATA486                                                      ���
���������������������������������������������������������������������������Ĵ��
���Programador   � Data   � BOPS/FNC  �  Motivo da Alteracao                ���
���������������������������������������������������������������������������Ĵ��
���Jonathan Glz  �31/08/17�DMINA-38   �Se modifica funcion fGenXMLNCC para  ���
���              �        �           �negenerar de manera correcta el nodo ���
���              �        �           �con se pondra la firma digital.      ���
���Alf Medrano   �26/10/18�DMINA-4575 �Se actualiza a UBL 2.1               ���
���M.Camargo     �14/03/19�DMINA-4575 �uso de funcion strZero supliendo el  ���
���              �        �           �uso de substr para generar correlati-���
���              �        �           �vo a 8 caracter�s.                   ���
���M.Camargo     �14/06/19�DMINA-6838 �Se modifica picture en el tag price  ���
���              �        �           �amount ya que debe llevar 10 decimal ���
���V. Flores     �06/09/19�DMINA-7628 �Modificaci�n de XML , agregando los  ��� 
��               �        �           �nuevos nodos del impuesto ICBPER     ���
���M.Camargo     �24/09/19�DMINA-7417 �Modificaci�n de XML uso de EXTENSO   ��� 
���M.Camargo     �27/09/19�DMINA-7501 |Ajustes operaciones gratuitas y grav.��� 
���M.Camargo     �11/10/19�DMINA-7508 |Apertuna PE M486ENCC                 ���  
���Luis Enriquez �03/02/21�DMINA-10845�Se activa funcionalidad de Forma de  ���
���              �        �           �Pago para NCC Fact. Electr�nica.(PER)���  
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function M486NCCXML(cFil, cSerie, cCliente, cLoja, cNumDoc, cEspDoc)	
	Local cXML       := ""
	Local cMoneda   := ""
	Local aEncab := {}		
	Local aValAdic := {}
	Local cLetraVB := ""
	Local aArea 	:= getArea()
	Local aImpFact  := {} //Impuestos
	Local aDetFac  := {} //Items factura
	Local lGratis   := .F.
	Local nTotalVta := 0
	Local lDocExp := .F.
	local nTotImp := 0
	local cSF1Esp := ""
	local cSF1Doc := ""
	local cSF1Ser := ""
	local cSF1Frn := ""
	local cSF1Loj := ""
	local cSF1Ref := ""
	local cSF1Mtv := ""
	local cSF1Hrs := ""
	Local nSF1Moed := 0
	Local cTipoPag := ""
	Local cFilSE4  := xFilial("SE4")
	Local aParc    := {}
	Local nSalPago := 0

	Private cFilSF1   := xfilial("SF1")
	Private cValBrut := 0
	Private cFecha := ""
	Private cFolio := ""	
	Private lTipoPago := SE4->(ColumnPos("E4_MPAGSAT")) > 0

	dbSelectArea("SF1") 
	SF1->(dbSetORder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	If SF1->(dbSeek(cFilSF1 + cNumDoc + cSerie + cCliente + cLoja))
		cFolio := SF1->F1_SERIE2 + "-" + STRZERO(VAL(SF1->F1_DOC),8) 
		cFecha := Alltrim(Str(YEAR(SF1->F1_EMISSAO))) + "-" + Padl(Alltrim(Str(MONTH(SF1->F1_EMISSAO))),2,'0') + "-" +;
		Padl(Alltrim(Str(DAY(SF1->F1_EMISSAO))),2,'0')			

		CTO->(DbSetOrder(1))//CTO_FILIAL+CTO_MOEDA
		CTO->(dbSeek(xFilial("CTO")+Strzero(SF1->F1_MOEDA,2)))
		cMoneda := ALLTRIM(Posicione("CTO",1,xFilial("CTO")+Strzero(SF1->F1_MOEDA,2),"CTO_MOESAT"))

		If lTipoPago
			cTipoPag := M486TPPAG(cFilSE4, SF1->F1_COND)
			If cTipoPag == "2" //Cr�dito
				M486CUOTA(F1_FILIAL,F1_FORNECE,F1_LOJA,F1_SERIE,F1_DOC,F1_ESPECIE,@aParc,@nSalPago)
			EndIf
		EndIf
	
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		
		If dbSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA)
			lDocExp := IIf(SA1->A1_EST == "EX" .And. SF1->F1_TIPREF $ "11",.T.,.F.)
		EndIf	
		
		cSF1Esp := SF1->F1_ESPECIE
		cSF1Doc := SF1->F1_DOC
		cSF1Ser := SF1->F1_SERIE
		cSF1Frn := SF1->F1_FORNECE
		cSF1Loj := SF1->F1_LOJA
		cSF1Ref := SF1->F1_TIPREF
		cSF1Mtv := SF1->F1_MOTIVO
		cSF1Hrs := SF1->F1_HORA
		nSF1Moed:= SF1->F1_MOEDA
			
		//Impuestos			
		M486XMLIMP(cSF1Esp,cSF1Doc,cSF1Ser,cSF1Frn,cSF1Loj,lDocExp,@aImpFact,@aDetFac,@aValAdic,@nTotalVta,@lGratis, , @nTotImp)
			
		//Encabezado
		If !lGratis
			cLetraVB := Extenso(SF1->F1_VALBRUT,.F.,nSF1Moed,,"2",.t.,.t.) 
		Else
			cLetraVB :=  fCero2Text(nSF1Moed)
		EndIf
	
		cValBrut  := IIF(lGratis,0, SF1->F1_VALBRUT)//nTotalFac	
		aEncab := {cFolio,cFecha,cMoneda,cValBrut,cLetraVB,cSF1Esp, cSF1Doc, cSF1Ser,;
				cSF1Frn,cSF1Loj,RTRIM(cSF1Ref),RTRIM(cSF1Mtv),lGratis,cSF1Hrs,nTotImp,cTipoPag,nSalPago,lDocExp}	
		
		//Genera XML
		cXML := fGenXMLNCC(cCliente, cLoja, aValAdic, aEncab, aImpFact,aDetFac,aParc)
	EndIf	
	RestArea(aArea)	
Return cXML

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � fGenXMLNCC � Autor � Dora Vega             � Data � 09.06.17 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Genera estructura XML para la nota de credito de acuerdo al  ���
���          � estandar UBL 2.0 (PERU)                                      ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGenXMLNCC(cClie,cTienda,aValAd,aEnc,aImpXML,aDetImp)        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cClie.- Clave del cliente                                    ���
���          � cTienda.- Clave de tienda del cliente                        ���
���          � aValAd.- Adicionales de operaciones.                         ���
���          � aEnc.- Datos del encabezado del documento.                   ���
���          � aImpXML.- Datos de impuesto.                                 ���
���          � aDetImp.- Detalle de nota de credito para XML.               ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � cXML .- String con estructrura de XML para nota de credito   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � M486NCCXML                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fGenXMLNCC(cClie, cTienda, aValAd, aEnc, aImpXML, aDetImp, aParc)
	Local nC 	:= 0
	Local nX    := 0
	local nI 	:= 0
	Local cXML  := ""
	Local cCRLF	:= (chr(13)+chr(10))
	Local cPValUn := "999999999999.9999999999"
	Local cPValIt := "999999999999.99"
	Local lRSM := ALLTRIM(SuperGetMV("MV_PROVFE",,"")) == "RSM"
	
	cXML := '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' + cCRLF
	cXML += '<CreditNote xmlns="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2"' + cCRLF 
	cXML += '	xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' + cCRLF 
	cXML += '	xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"' + cCRLF   
	cXML += '	xmlns:ccts="urn:un:unece:uncefact:documentation:2"' + cCRLF 
	cXML += '	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"' + cCRLF 
	cXML += '	xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"' + cCRLF 
	cXML += '	xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2"' + cCRLF
	cXML += '	xmlns:sac="urn:sunat:names:specification:ubl:peru:schema:xsd:SunatAggregateComponents-1"' + cCRLF 
	cXML += '	xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"' + cCRLF  
	cXML += '	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' + cCRLF
	
	//Adicionales	
	cXML += '	<ext:UBLExtensions>' + cCRLF
	If lRSM
		// Puntos de Entrada que son habiles solamente cuando se usa RSM
		If ExistBlock("M486ENCC") 
			cXML += ExecBlock("M486ENCC",.F.,.F.,{SF1->F1_FILIAL,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_ESPECIE,cClie,cTienda})
		EndIf
	EndIf
	cXML += '		<ext:UBLExtension>' + cCRLF
	cXML += '			<ext:ExtensionContent></ext:ExtensionContent>' + cCRLF  
   	cXML += '		</ext:UBLExtension>' + cCRLF    
   	cXML += '	</ext:UBLExtensions>' + cCRLF	
    
    //Identificacion del Documento
    cXML += '	<cbc:UBLVersionID>2.1</cbc:UBLVersionID>' + cCRLF
	cXML += '	<cbc:CustomizationID>2.0</cbc:CustomizationID>' + cCRLF
	cXML += '	<cbc:ID>' + aEnc[1] + '</cbc:ID>' + cCRLF  
	cXML += '	<cbc:IssueDate>' + aEnc[2] + '</cbc:IssueDate>' + cCRLF 
	cXML += '	<cbc:IssueTime>' + aEnc[14] + '</cbc:IssueTime>'  + cCRLF 
	cXML += '	<cbc:Note languageLocaleID="1000">' + alltrim(aEnc[5]) + '</cbc:Note>' + cCRLF
	// Punto de Entrada para agregar campos personalizados Factura.
	If ExistBlock("M486NCC") 
		cXML += ExecBlock("M486NCC",.F.,.F.,{SF1->F1_FILIAL,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_ESPECIE,cClie,cTienda})
	EndIf
	cXML += '	<cbc:DocumentCurrencyCode>' + aEnc[3] + '</cbc:DocumentCurrencyCode>' + cCRLF
	
	//Referencias de la Nota de Credito
	cXML += M486REF(aEnc[6], aEnc[7], aEnc[8], aEnc[9], aEnc[10], aEnc[11], aEnc[12])
		
	//Firma Electronica
	cXML += M486XmlFE() 
	
	//Emisor
	cXML += M486XMLEMI() 
	
	//Receptor
	cXML += M486XmlRec(cClie,cTienda) 

	//Nodo para Forma de Pago
	If lTipoPago
		cXML += M486FOPAGO(aEnc[3],aEnc[16],aEnc[17],aParc)
	EndIf
	
	//Impuestos
	If Len(aImpXML) > 0
			For nX :=1 To Len(aImpXML)
					If nX == 1
						cXML += '	<cac:TaxTotal>' + cCRLF
						cXML += '		<cbc:TaxAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(iIf(aEnc[13],0,aEnc[15]),"999999.99")) + '</cbc:TaxAmount>' + cCRLF
					EndIf
					If !aEnc[18] //Diferente de exportaci�n
						cXML += '		<cac:TaxSubtotal>' + cCRLF
						If aImpXML[nX,4] <>"ICB"
							cXML += '			<cbc:TaxableAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aImpXML[nX,10],"999999999999.99")) + '</cbc:TaxableAmount>' + cCRLF
						EndIf
						cXML += '		<cbc:TaxAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aImpXML[nX][6],"999999.99")) + '</cbc:TaxAmount>' + cCRLF
						cXML += '			<cac:TaxCategory>' + cCRLF
						cXML += '				<cac:TaxScheme>' + cCRLF
						cXML += '					<cbc:ID>' + aImpXML[nX][2] + '</cbc:ID>' + cCRLF
						cXML += '					<cbc:Name>' + IIF(aImpXML[nX,4] == "ICB", 'ICBPER',aImpXML[nX,4]) + '</cbc:Name>' + cCRLF
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

	//Total Nota de Credito
	cXML += '	<cac:LegalMonetaryTotal>' + cCRLF
	cXML += '		<cbc:PayableAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(cValBrut,"999999999999.99")) + '</cbc:PayableAmount>' + cCRLF
	cXML += '	</cac:LegalMonetaryTotal>' + cCRLF
	aSort(aDetImp,,,{|X,Y| x[1] < y[1]})
	//Detalle de la Nota de Credito
	If Len(aDetImp) > 0
		For nX := 1 To Len(aDetImp)
			cXML += '	<cac:CreditNoteLine>' + cCRLF
			cXML += '		<cbc:ID>' + alltrim(str(aDetImp[nX][1])) + '</cbc:ID>' + cCRLF
			cXML += '		<cbc:CreditedQuantity unitCode="' + alltrim(aDetImp[nX][2]) + '" unitCodeListID="UN/ECE rec 20" unitCodeListAgencyName="United Nations Economic Commission for Europe">' + alltrim(TRANSFORM(aDetImp[nX][3],"999999999999.9999999999")) + '</cbc:CreditedQuantity>' + cCRLF
			cXML += '		<cbc:LineExtensionAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aDetImp[nX][4],cPValIt)) + '</cbc:LineExtensionAmount>' + cCRLF
			cXML += '		<cac:PricingReference>' + cCRLF
			If aDetImp[nX][12]
				cXML += '			<cac:AlternativeConditionPrice>' + cCRLF
				cXML += '				<cbc:PriceAmount currencyID="' + aEnc[3] + '">'+  Alltrim(TRANSFORM(aDetImp[nX][9], cPValUn)) +'</cbc:PriceAmount>' + cCRLF
				cXML += '				<cbc:PriceTypeCode>02</cbc:PriceTypeCode>' + cCRLF
				cXML += '			</cac:AlternativeConditionPrice>' + cCRLF						
			Else
				cXML += '			<cac:AlternativeConditionPrice>' + cCRLF
				cXML += '				<cbc:PriceAmount currencyID="' + aEnc[3] + '">' + Alltrim(TRANSFORM(aDetImp[nX][11], cPValUn))+ '</cbc:PriceAmount>' + cCRLF
				cXML += '				<cbc:PriceTypeCode>01</cbc:PriceTypeCode>' + cCRLF
				cXML += '			</cac:AlternativeConditionPrice>' + cCRLF			
			EndIf
			
			cXML += '		</cac:PricingReference>' + cCRLF

			If Len(aDetImp[nX][13]) > 0
					cXML += '		<cac:TaxTotal>' + cCRLF
					cXML += '			<cbc:TaxAmount currencyID="' + aEnc[3] + '">' +  alltrim(TRANSFORM(aDetImp[nX,5],"9999999999999.99")) + '</cbc:TaxAmount>' + cCRLF 
				For nC := 1 To Len(aDetImp[nX][13])
					If Len(aDetImp[nX][13][nC]) > 0
						cXML += '			<cac:TaxSubtotal>' + cCRLF
						If aDetImp[nX][13][nC,5] <> "ICB"
								cXML += '				<cbc:TaxableAmount currencyID="'+ aEnc[3] + '">' + alltrim(TRANSFORM(aDetImp[nX,4],"9999999999999.99"))+ '</cbc:TaxableAmount>' + cCRLF
						EndIf
						cXML += '				<cbc:TaxAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aDetImp[nX][13][nC][1],cPValIt)) + '</cbc:TaxAmount>' + cCRLF 
						If aDetImp[nX][13][nC,5] == "ICB"
							cXML += '				<cbc:BaseUnitMeasure unitCode="NIU">' + alltrim(TRANSFORM(aDetImp[nX][3],"9999999999999")) + '</cbc:BaseUnitMeasure>' + cCRLF 
						EndIf
						cXML += '				<cac:TaxCategory>' + cCRLF
						If aDetImp[nX][13][nC,5] == "ICB"
							cXML += '					<cbc:PerUnitAmount currencyID="' + aEnc[3] + '">' + alltrim(TRANSFORM(aDetImp[nX][16],"9999999999999.99")) + '</cbc:PerUnitAmount>' + cCRLF 
						Else
								cXML += '					<cbc:Percent>' + alltrim(TRANSFORM(aDetImp[nX][13][nC][8],"999.99"))+ '</cbc:Percent> '  + cCRLF
						EndIf
						If aDetImp[nX][13][nC][5]  <> "ISC" .And. aDetImp[nX][13][nC,5] <> "ICB"
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
			cXML += '				<cbc:PriceAmount currencyID="' + aEnc[3] + '">' +  IIf(!aDetImp[nX][12],alltrim(TRANSFORM(aDetImp[nX][10],"999999999999.9999999999")),"0.00") +  '</cbc:PriceAmount>' + cCRLF
			cXML += '		</cac:Price>' + cCRLF
			cXML += '	</cac:CreditNoteLine>' + cCRLF
		Next nX
		cXML += '	</CreditNote>' + cCRLF
	EndIf

Return cXML
