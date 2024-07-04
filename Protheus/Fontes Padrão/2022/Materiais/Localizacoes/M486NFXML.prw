#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"
#Include "mata486.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M486NFXML   ³ Autor ³ Luis Enriquez         ³ Data ³ 31.05.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Generacion de XML de Factura - Boleta de Venta  para factura- ³±±
±±³          ³cion electronica de Peru, de acuerdo a estandar UBL 2.0, para ³±±
±±³          ³ser enviado a TSS para su envio a la SUNAT. (PERU)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486NFXML(cFil, cSerie, cCliente, cLoja, cNumDoc, cEspDoc)   ³±±
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
±±³Luis Enriquez ³31/07/18³DMINA-3376 ³Corrección para agregar imptos a XML ³±±
±±³(PERU)        ³        ³           ³sólo si existen en arreglo y así evi-³±±
±±³              ³        ³           ³tar error.log.                       ³±±
±±³M.Camargo     ³26/10/18³DMINA-4575 ³Implementacion UBL2.1                ³±±
±±³M.Camargo     ³14/03/19³DMINA-4575 ³uso de funcion strZero supliendo el  ³±±
±±³              ³        ³           ³uso de substr para generar correlati-³±±
±±³              ³        ³           ³vo a 8 caracterés.                   ³±±
±±³M.Camargo     ³14/03/19³DMINA-6471 ³Si la NF es gratuita, aparecerá leyen³±±
±±³              ³        ³           ³da que indicará muestrasg ratuitas   ³±±
±±³M.Camargo     ³14/03/19³DMINA-6777 ³Si la NF es gratuita, aparecerá el   ³±±
±±³              ³        ³           ³monto y pricetype en 02              ³±±
±±³M.Camargo     ³26/07/19³DMINA-7000 ³Si la NF tiene descuentos de agrega  ³±±
±±³              ³        ³           ³tag MultiplierFactorNumeric          ³±±
±±³              ³        ³           ³y BaseAmount                         ³±±
±±³M.Camargo     ³14/08/19³DMINA-7289 ³Se agrega alltrim en                 ³±±
±±³              ³        ³           ³tag MultiplierFactorNumeric          ³±±
±±³V. Flores     ³06/09/19³DMINA-7628 ³Modificación de XML , agregando los  ³±± 
±±               ³        ³           ³nuevos nodos del impuesto ICBPER     ³±±
±±³M.Camargo     ³24/09/19³DMINA-7417 ³Modificación de XML uso de EXTENSO   ³±± 
±±³M.Camargo     ³27/09/19³DMINA-7501 |Ajustes operaciones gratuitas        ³±±
±±³M.Camargo     ³11/10/19³DMINA-7508 |Apertuna PE M486ENF                  ³±±
±±³Luis Enríquez ³06/09/20³DMINA-9655 |Se activan nodos para transmisión de ³±±
±±               ³        ³           ³Factura/Boleta con detracción.       ³±± 
±±³Luis Enriquez ³03/02/21³DMINA-10845³Se activa funcionalidad de Forma de  ³±±
±±³              ³        ³           ³Pago para NF Fact. Electrónica. (PER)³±± 
±±³Luis Enriquez ³22/09/21³DMINA-13775³Se realizan ajustes para transmisión ³±±
±±³              ³        ³           ³de NF con descuentos. (PER)          ³±±   
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486NFXML(cFil, cSerie, cCliente, cLoja, cNumDoc, cEspDoc) 
	Local cXMLNF   := ""	
	Local cMoneda  := ""
	Local aEncab 	:= {}		
	Local aValAdic 	:= {}
	Local cLetraVB 	:= ""
	Local aArea 	:= getArea()
	Local aImpFact 	:= {} //Impuestos
	Local aDetFact 	:= {} //Items	
	Local cTpDocA1 	:= ""
	Local nTotalFac	:= 0
	Local lFacGra 	:= .F.
	Local lDocExp 	:= .F.		
	Local aGastos 	:= {}
	Local cValBrut 	:= 0
	Local cFecha 	:= ""
	Local cFolio 	:= ""
	Local cTpDoc01 := ""
	Local aGRNF		:= {}    
	Local nDescont	:= 0
	Local nGastos	:= 0
	Local nTotImp	:= 0
	Local cSF1Hrs  := time()	
	Local lIvap 	:= .F.		
	Local cOpeExp   := ""	
    Local cTipoPag  := ""
	Local cFilSE4   := xFilial("SE4")
	Local aParc     := {}
	Local nSalPago  := 0
	Local nY        := 0
	Local nVlrImp   := 0
	Local nVlrAnt   := 0
	Local aDocAnt   := {}
	Local aImpAfe   := {}

	Private lTipoPago := SE4->(ColumnPos("E4_MPAGSAT")) > 0

	dbSelectArea("SF2")
	SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(dbSeek(cFil + cNumDoc + cSerie + cCliente + cLoja)) 	
		cFolio := RTRIM(SF2->F2_SERIE2) + "-" + STRZERO(VAL(SF2->F2_DOC),8)
		cFecha := Alltrim(Str(YEAR(SF2->F2_EMISSAO))) + "-" + Padl(Alltrim(Str(MONTH(SF2->F2_EMISSAO))),2,'0') + "-" +;
		Padl(Alltrim(Str(DAY(SF2->F2_EMISSAO))),2,'0')		
		cMoneda   := ALLTRIM(Posicione("CTO",1,xFilial("CTO")+Strzero(SF2->F2_MOEDA,2),"CTO_MOESAT"))
		cSF1Hrs := SF2->F2_HORA
		nVlrAnt := SF2->F2_VALADI //Importe de Anticipo
		
		If alltrim(cEspDoc) == "NF" .AND. 'F' $ Substr(SF2->F2_SERIE2,1,1) // Factura
			cTpDoc01 := '01'
			cOpeExp  := "0200|0201|0202|0203|0204|0205|0206|0207|0208"
			If lTipoPago
				cTipoPag := M486TPPAG(cFilSE4, SF2->F2_COND)
				If cTipoPag == "2" //Crédito
					M486CUOTA(F2_FILIAL,F2_CLIENTE,F2_LOJA,F2_SERIE,F2_DOC,F2_ESPECIE,@aParc,@nSalPago)
				EndIf
			EndIf
		ElseIf alltrim(cEspDoc) == "NF" .AND. 'B' $ Substr(SF2->F2_SERIE2,1,1) .AND. cTpDocA1 # "06" // Boleta de Venta
			cTpDoc01 := '03'
			cOpeExp  := "0200|0201|0203|0204|0206|0207|0208"
		EndIf	

		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
		
		If dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA)
			cTpDocA1 := SA1->A1_TIPDOC
			lDocExp := IIf(SA1->A1_EST == "EX" .And. SF2->F2_TIPONF $ cOpeExp,.T.,.F.)
		Else
			cTpDocA1 := ""
		EndIf

		//Impuestos				
		M486XMLIMP(SF2->F2_ESPECIE,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA, lDocExp, @aImpFact, @aDetFact, @aValAdic, @nTotalFac, @lFacGra,@aGRNF, @nTotImp,@lIvap,@nVlrAnt,@aDocAnt,@aImpAfe)		

		For nY := 1 To Len(aImpFact)
			If aImpFact[nY][9] == "3" .And. aImpFact[nY][2] $ "1000|1016|9995|9997|9998"
				nVlrImp += aImpFact[nY][6]
			EndIf
		Next nY
		
		If !lFacGra
			cLetraVB := Extenso(SF2->F2_VALBRUT,.f.,SF2->F2_MOEDA,,"2",.t.,.t.) 
		Else
			cLetraVB :=  fCero2Text(SF2->F2_MOEDA)
		EndIf		
		
		If SF2->F2_DESPESA+SF2->F2_FRETE + SF2->F2_SEGURO > 0
			aAdd(aGastos,{"50",SF2->F2_DESPESA+SF2->F2_FRETE + SF2->F2_SEGURO}) // Otros gastos
			nGastos := SF2->F2_DESPESA+SF2->F2_FRETE + SF2->F2_SEGURO
		EndIf
		//Encabezado
		cValBrut  := IIF(lFacGra,0, SF2->F2_VALBRUT)//nTotalFac		
		/*
			01. Documento
			02. Fecha
			03. Serie
			04. Tipo de documento Sunat
			05. Moneda
			06. Total de venta documento
			07. Monto Total en letras
			08. Indicador Factura gratuita
			09. Indicador Factura Exportación
			10. Número de Orden
			11. Valor de la Mercanciá sin impuestos ni gastos 
			12. Valor Total Descuentos
			13. Valor Total de Gatos (Flete, seguro, otros gastos)	
			14. Total Monto Impuestos
			15.	Tipo de Factura Segun Cat. No 51
			16. Si es de exportacion 	
			17. hr	
			18. Indica si afecat ivap		 			
		*/	
		If nTotalFac == SF2->F2_VALMERC .AND. lDocExp
			aEncab := {cFolio,cFecha,cTpDoc01,cMoneda,cValBrut,cLetraVB, cValBrut, lFacGra, lDocExp,SF2->F2_NUMORC,SF2->F2_VALMERC-nTotImp,nDescont,nGastos, nTotImp, SF2->F2_TIPONF,lDocExp,cSF1Hrs,lIvap,cTipoPag,nSalPago,nVlrAnt,SF2->F2_VALADI}
		Else
			aEncab := {cFolio,cFecha,cTpDoc01,cMoneda,cValBrut,cLetraVB, cValBrut, lFacGra, lDocExp,SF2->F2_NUMORC,SF2->F2_VALMERC-nVlrImp,nDescont,nGastos, nTotImp, SF2->F2_TIPONF,lDocExp,cSF1Hrs,lIvap,cTipoPag,nSalPago,nVlrAnt,SF2->F2_VALADI}				
		EndIf
		// Se genera XML de Factura/Boleta de Venta	
		cXMLNF := fGenXMLNF(cCliente, cLoja, aValAdic, aEncab, aImpFact, aDetFact,aGRNF,aGastos,lDocExp,aParc,aDocAnt,aImpAfe)
	EndIf
	RestArea(aArea)	
Return cXMLNF 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGenXMLNF  ³ Autor ³ Luis Enriquez         ³ Data ³ 01.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura de XML para factura/boleta de venta de     ³±±
±±³          ³ acuerdo a esquema UBL 2.0. (PERU).                           ³±±
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
±±³Retorno   ³ cXML .- String con estructruafra de XML para factura/boleta de ³±±
±±³          ³ venta.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486XMLPDF                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGenXMLNF(cClie, cTienda, aValAd, aEnc, aImpXML, aDetImp,aGRNF,aGastos,lDocExp,aParc,aDocAnt,aImpAfe)
	Local cXML  := ""
	Local nX    := 0
	Local cCRLF	:= (chr(13)+chr(10))
	Local nC    := 0
	Local nI    := 0
	Local nA    := 0
	Local cTexto := (OemToAnsi(STR0078)) //"TRANSFERENCIA GRATUITA DE UN BIEN Y/O SERVICIO PRESTADO GRATUITAMENTE"
	Local cPicAmount := "999999999999.9999999999"
	Local lRSM   := ALLTRIM(SuperGetMV("MV_PROVFE",,"")) == "RSM"
	Local lProc  := .T.
	Local nDetra := 0
	Local cCtaDetra := ALLTRIM(SuperGetMV("MV_TKN_EMP",.F.,""))
	Local nDetraccion := 0
	Local nImp	 := 0
	Local nValorDet := 0
	Local nAnticipo := 0
	Local aDatosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CGC"} ) 

	Default aDocAnt := {}
	Default aImpAfe := {}
	
	cXML := '<?xml version="1.0" encoding="UTF-8"?>' + cCRLF
	cXML += '<Invoice' + cCRLF 
	cXML += '	xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"' + cCRLF 
	cXML += '	xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' + cCRLF
	cXML += '	xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"' + cCRLF 
	cXML += '	xmlns:ccts="urn:un:unece:uncefact:documentation:2"' + cCRLF 
	cXML += '	xmlns:ds="http://www.w3.org/2000/09/xmldsig#"' + cCRLF 
	cXML += '	xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"' + cCRLF 
	cXML += '	xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2"' + cCRLF
	cXML += '	xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"' + cCRLF 
	cXML += '	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' + cCRLF
	
	cXML += '	<ext:UBLExtensions>' + cCRLF
	If lRSM
		// Puntos de Entrada que son habiles solamente cuando se usa RSM
		If ExistBlock("M486ENF") .AND. !aEnc[16] .and. "F" $ Substr(aEnc[1],1,1)
			cXML += ExecBlock("M486ENF",.F.,.F.,{SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,cClie,cTienda})
		ElseIf ExistBlock("M486ENFE") .AND. aEnc[16] .and. "F" $ Substr(aEnc[1],1,1)
			cXML += ExecBlock("M486ENFE",.F.,.F.,{SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,cClie,cTienda})
		ElseIf ExistBlock("M486EBV") .AND. !aEnc[16] .and. "B" $ Substr(aEnc[1],1,1)
			cXML += ExecBlock("M486EBV",.F.,.F.,{SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,cClie,cTienda})
		EndIf
	EndIf
   	cXML += '		<ext:UBLExtension>' + cCRLF 
	cXML += '			<ext:ExtensionContent></ext:ExtensionContent>' + cCRLF 
  	cXML += '		</ext:UBLExtension>' + cCRLF    
	cXML += '	</ext:UBLExtensions>' + cCRLF	
	cXML += '	<cbc:UBLVersionID>2.1</cbc:UBLVersionID>' + cCRLF
	cXML += '	<cbc:CustomizationID>2.0</cbc:CustomizationID>' + cCRLF	
	cXML += '	<cbc:ID>' + aEnc[1] + '</cbc:ID>' + cCRLF  
	cXML += '	<cbc:IssueDate>' + aEnc[2] + '</cbc:IssueDate>' + cCRLF
	cXML += '	<cbc:IssueTime>' + aEnc[17] + '</cbc:IssueTime>' + cCRLF  
	If ExistBlock("M486FECVEN") .And. !aEnc[16]
		cXML += ExecBlock("M486FECVEN",.F.,.F.)
	EndIf
	cXML += '	<cbc:InvoiceTypeCode listID="' + aEnc[15]+ '" '
	cXML += 						'name="Tipo de Operacion" '
	cXML += 						'listAgencyName="PE:SUNAT" '
	cXML += 						'listName="Tipo de Documento" '
	cXML += 						'listSchemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo51" '
	cXML += 						'listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo01">' + aEnc[3] + '</cbc:InvoiceTypeCode>' + cCRLF
	cXML += '	<cbc:Note languageLocaleID="1000">' + alltrim(aEnc[6]) + '</cbc:Note>' + cCRLF
	If aEnc[18]
		cXML += '	<cbc:Note languageLocaleID="2007">' + ObtColSAT("S052", '2007', 1, 4,5,250) + '</cbc:Note>' + cCRLF 
	EndIf   
	If aEnc[8] //Gratuitos
		cXML += '	<cbc:Note>' + cTexto + '</cbc:Note>' + cCRLF  
	EndIf
	//Nota requerida para las Detracciones
	AEval(aImpXML, {|x,y| If(aImpXML[y][3] == "D", nDetra++,.T.)})  //Qtd de impuestos de detracción
	If nDetra > 0
		cXML += '	<cbc:Note languageLocaleID="2006">' + EncodeUtf8(ObtColSAT("S052", '2006', 1, 4,5,250)) + '</cbc:Note>' + cCRLF
	EndIf
	// Punto de Entrada para agregar campos personalizados Factura.
	If ExistBlock("M486NF") .AND. !aEnc[16]
		cXML += ExecBlock("M486NF",.F.,.F.,{SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,cClie,cTienda})
	ElseIf ExistBlock("M486NFE") .AND. aEnc[16]
		cXML += ExecBlock("M486NFE",.F.,.F.,{SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,cClie,cTienda})
	EndIf
	
	cXML += '	<cbc:DocumentCurrencyCode listID="ISO 4217 Alpha" '
	cXML += 					'listName="Currency" '
	cXML += 					'listAgencyName="United Nations Economic Commission for Europe">' + aEnc[4] + '</cbc:DocumentCurrencyCode>' + cCRLF    
	cXML += '	<cbc:LineCountNumeric>' + ALLTRIM(TRANSFORM(Len(aDetImp),"999999.99")) + '</cbc:LineCountNumeric>' + cCRLF

	//Anticipos
	If Len(aDocAnt) > 0
		For nA := 1 To Len((aDocAnt))
			cXML += '	<cac:AdditionalDocumentReference> ' + cCRLF
			cXML += '		<cbc:ID>' + aDocAnt[nA][10] + '</cbc:ID> ' + cCRLF
			cXML += '		<cbc:DocumentTypeCode listAgencyName="PE:SUNAT" listName="Documento Relacionado" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo12">' + aDocAnt[nA][2] + '</cbc:DocumentTypeCode> ' + cCRLF
			cXML += '		<cbc:DocumentStatusCode listName="Anticipo" listAgencyName="PE:SUNAT">' + Alltrim(Str(nA)) + '</cbc:DocumentStatusCode> ' + cCRLF
			cXML += '		<cac:IssuerParty> ' + cCRLF
			cXML += '			<cac:PartyIdentification> ' + cCRLF
			cXML += '				<cbc:ID schemeID="6" schemeName="Documento de Identidad" schemeAgencyName="PE:SUNAT" schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo06">' + Alltrim(aDatosSM0[1][2]) + '</cbc:ID> ' + cCRLF
			cXML += '			</cac:PartyIdentification> ' + cCRLF
			cXML += '		</cac:IssuerParty> ' + cCRLF
			cXML += '	</cac:AdditionalDocumentReference> ' + cCRLF
		Next nA
	EndIf
	
	If !Empty(aEnc[10])
		cXML += '	<cac:OrderReference>' + cCRLF
		cXML += '		<cbc:ID>' + Alltrim(aEnc[10]) + '</cbc:ID>' + cCRLF 
		cXML += '	</cac:OrderReference>' + cCRLF
	EndIf
	// -------------------Guías de Remisión relacionadas a la NF ------------------------
	For nI := 1 to len(aGRNF)
		cXML += '	<cac:DespatchDocumentReference>' + cCRLF
		cXML += '	<cbc:ID>' + aGRNF[nI,3]+"-"+aGRNF[nI,2]+ '</cbc:ID>'+ cCRLF
		cXML += '	<cbc:DocumentTypeCode>09</cbc:DocumentTypeCode>'+ cCRLF
		cXML += '	</cac:DespatchDocumentReference>'	 + cCRLF
	Next nI

	cXML += M486XmlFE() 	// Firma Electrónica	
	cXML += M486XmlEmi() 	// Emisor	
	cXML += M486XmlRec(cClie,cTienda) // Receptor

	//Detracción
	If Len(aImpXML) > 0
		For nX :=1 To Len(aImpXML)
			If aImpXML[nX,3] == "D"
				nValorDet:= xMoeda(aImpXML[nX,6],SF2->F2_MOEDA,1,SF2->F2_EMISSAO,MsDecimais(1),SF2->F2_TXMOEDA,0)//Retorna o valor da Detracion em Soles
				nDetraccion := aImpXML[nX,6] 
				cXML += '	<cac:PaymentMeans>' + cCRLF
				cXML += '	<cbc:ID>Detraccion</cbc:ID>' + cCRLF
				If SF2->(FieldPos("F2_MODCONS")) > 0
					cXML += '		<cbc:PaymentMeansCode>' + Alltrim(SF2->F2_MODCONS) + '</cbc:PaymentMeansCode>' + cCRLF //Medio de Pago (Catálogo 59)
				EndIf
				cXML += '		<cac:PayeeFinancialAccount>' + cCRLF
	            cXML += '			<cbc:ID>' + Alltrim(cCtaDetra) + '</cbc:ID>' + cCRLF //Número de cuenta en el Banco de la Nación 0004-3342343243
				cXML += '		</cac:PayeeFinancialAccount>' + cCRLF
	      		cXML += '	</cac:PaymentMeans>' + cCRLF
	      		
				cXML += '	<cac:PaymentTerms>' + cCRLF
				cXML += '	<cbc:ID>Detraccion</cbc:ID>' + cCRLF
				If SF2->(FieldPos("F2_CODDOC")) > 0
					cXML += '		<cbc:PaymentMeansID>' + Alltrim(SF2->F2_CODDOC) + '</cbc:PaymentMeansID>' + cCRLF //Código del bien o servicio sujeto a detracción (Catálogo 59)
				EndIf
				cXML += '		<cbc:PaymentPercent>' + Alltrim(TRANSFORM(aImpXML[nX,12],"999.99")) + '</cbc:PaymentPercent>' + cCRLF //Porcentaje de la detracción
	             cXML += '		<cbc:Amount currencyID="PEN">' + alltrim(TRANSFORM(nValorDet,"999999999999.99")) + '</cbc:Amount>' + cCRLF //Monto de la Detracción
	      		cXML += '	</cac:PaymentTerms>' + cCRLF	      		
			EndIf

			If aImpXML[nX,3] == "I"
				nImp:= aImpXML[nX,6] 
			EndIF
		Next nX
	EndIf

	//Nodo para Forma de Pago
	If lTipoPago
		cXML += M486FOPAGO(aEnc[4],aEnc[19],aEnc[20],aParc,nDetraccion,nImp)
	EndIf

	//Montos de Anticipos
	If Len (aDocAnt) > 0
		For nA := 1 To Len(aDocAnt)
			cXML += '	<cac:PrepaidPayment>'	 + cCRLF
			cXML += '		<cbc:ID schemeName="Anticipo" schemeAgencyName="PE:SUNAT">' + Alltrim(Str(nA)) + '</cbc:ID>'	 + cCRLF
			cXML += '		<cbc:PaidAmount currencyID="' + Alltrim(aEnc[4]) + '">' + alltrim(TRANSFORM(aDocAnt[nA,5],"999999999999.99")) + '</cbc:PaidAmount>'	 + cCRLF
			cXML += '		<cbc:PaidDate>' + Alltrim(aDocAnt[nA,13]) + '</cbc:PaidDate>'	 + cCRLF
			cXML += '	</cac:PrepaidPayment>'	 + cCRLF
		Next nA
  	EndIf
	
	//---------------------------------CARGOS Y DESCUENTOS-------------------------------------------------//	
	For nX := 1 to len(aGastos)
		cXML += '	<cac:AllowanceCharge>'	 + cCRLF
		cXML += '		<cbc:ChargeIndicator>' + IIF(aGastos[nX,1] == "00", 'false','true') + '</cbc:ChargeIndicator>'	 + cCRLF
		cXML += '		<cbc:AllowanceChargeReasonCode>' + aGastos[nX,1] + '</cbc:AllowanceChargeReasonCode>'	 + cCRLF
		cXML += '		<cbc:MultiplierFactorNumeric>' + Alltrim(Transform(((aGastos[nX,2]*100)/(aGastos[nX,2]+ aEnc[5]))/100,"999.99999")) + '</cbc:MultiplierFactorNumeric>'	 + cCRLF
		cXML += '		<cbc:Amount currencyID="' + aEnc[4] + '">' + alltrim(STR(aGastos[nX,2],10,2))  + '</cbc:Amount>'	 + cCRLF
		cXML += '		<cbc:BaseAmount currencyID="' + aEnc[4] + '">' + alltrim(STR(aGastos[nX,2]+ aEnc[5],10,2))  + '</cbc:BaseAmount>'	 + cCRLF
		cXML += '	</cac:AllowanceCharge>'	 + cCRLF	
	Next nX

	//Anticipos
	If Len (aImpAfe) > 0
		For nA := 1 To Len(aImpAfe)
			cXML += '	<cac:AllowanceCharge>'	 + cCRLF
			cXML += '	<cbc:ChargeIndicator>false</cbc:ChargeIndicator>'	 + cCRLF
			cXML += '	<cbc:AllowanceChargeReasonCode listAgencyName="PE:SUNAT" listName="Cargo/descuento" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo53">' + Alltrim(aImpAfe[nX,1]) + '</cbc:AllowanceChargeReasonCode>'	 + cCRLF
			cXML += '	<cbc:Amount currencyID="' + Alltrim(aEnc[4]) + '">' + Alltrim(TRANSFORM(aImpAfe[nX,2],"999999999999.99"))  + '</cbc:Amount>'	 + cCRLF
			cXML += '	</cac:AllowanceCharge>'	 + cCRLF
		Next nA
	EndIf
	
	// Impuestos totales
	If Len(aImpXML) > 0
		For nX :=1 To Len(aImpXML)
			If !(aImpXML[nX,3] == "D")
				If lProc
					cXML += '	<cac:TaxTotal>' + cCRLF
					cXML += '		<cbc:TaxAmount currencyID="' + aEnc[4] + '">' + alltrim(TRANSFORM(iIf(aEnc[8],0,aEnc[14]),"999999999999.99")) + '</cbc:TaxAmount>' + cCRLF
					lProc := .F.					
				EndIf
				If !lDocExp
					cXML += '		<cac:TaxSubtotal>' + cCRLF
					If aImpXML[nX,4] <>"ICB"
						cXML += '			<cbc:TaxableAmount currencyID="' + aEnc[4] + '">' + alltrim(TRANSFORM(IIf(aEnc[11]==aEnc[22],0,aImpXML[nX,10]),"999999999999.99")) + '</cbc:TaxableAmount>' + cCRLF
					EndIf
					cXML += '			<cbc:TaxAmount currencyID="' + aEnc[4] + '">' + alltrim(TRANSFORM(aImpXML[nX,6],"999999999999.99")) + '</cbc:TaxAmount>' + cCRLF
					cXML += '			<cac:TaxCategory>' + cCRLF
					cXML += '				<cac:TaxScheme>' + cCRLF
					cXML += '					<cbc:ID schemeID="UN/ECE 5153" schemeAgencyID="6">' + aImpXML[nX,2] + '</cbc:ID>' + cCRLF
					cXML += '					<cbc:Name>' + IIF(aImpXML[nX,4] == "ICB", 'ICBPER',aImpXML[nX,4]) + '</cbc:Name>' + cCRLF
					cXML += '					<cbc:TaxTypeCode>' + aImpXML[nX,5] + '</cbc:TaxTypeCode>' + cCRLF
					cXML += '				</cac:TaxScheme>' + cCRLF
					cXML += '			</cac:TaxCategory>' + cCRLF
					cXML += '		</cac:TaxSubtotal>' + cCRLF
				EndIF
				If nX == len(aImpXML)
					// Se procesan los Valores de las Operaciones del IGV
					For nI:=2 to len(aValAd)
						If aValAd[nI,2]> 0
							cXML += '		<cac:TaxSubtotal>' + cCRLF
							cXML += '			<cbc:TaxableAmount currencyID="'+ aEnc[4] + '">' + alltrim(TRANSFORM(aValAd[nI,2],"999999999999.99")) + '</cbc:TaxableAmount>' + cCRLF
							cXML += '			<cbc:TaxAmount currencyID="' + aEnc[4] + '">' + alltrim(TRANSFORM(aValAd[nI,3],"999999999999.99")) + '</cbc:TaxAmount>' + cCRLF
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
			EndIf
		Next nX
	EndIf

	If Len(aEnc) >= 21 //Anticipos 
		nAnticipo := aEnc[21]
	EndIf
	
	cXML += '	<cac:LegalMonetaryTotal>' + cCRLF
	If aEnc[8]
		cXML += '		<cbc:LineExtensionAmount currencyID="' + aEnc[4] + '">'	+ alltrim(TRANSFORM(0,"999999999999.99")) + '</cbc:LineExtensionAmount>' + cCRLF		
	Else
		cXML += '		<cbc:LineExtensionAmount currencyID="' + aEnc[4] + '">'	+ alltrim(TRANSFORM(aEnc[11],"999999999999.99")) + '</cbc:LineExtensionAmount>' + cCRLF
	EndIf
	cXML += '		<cbc:TaxInclusiveAmount currencyID="' + aEnc[4] + '">' 	+ alltrim(TRANSFORM(aEnc[5]+nAnticipo,"999999999999.99"))+ '</cbc:TaxInclusiveAmount>' + cCRLF
	cXML += '		<cbc:AllowanceTotalAmount currencyID="' + aEnc[4] + '">'+ alltrim(TRANSFORM(0,"999999999999.99"))+'</cbc:AllowanceTotalAmount>' + cCRLF
	cXML += '		<cbc:ChargeTotalAmount currencyID="' + aEnc[4] + '">' + alltrim(TRANSFORM(aEnc[13],"999999999999.99")) + '</cbc:ChargeTotalAmount>' + cCRLF
	If nAnticipo > 0
		cXML += '		<cbc:PrepaidAmount currencyID="' + aEnc[4] + '">' 	+ alltrim(TRANSFORM(nAnticipo,"999999999999.99"))+ '</cbc:PrepaidAmount>' + cCRLF
	EndIf	
	cXML += '		<cbc:PayableAmount currencyID="' + aEnc[4] + '">' + alltrim(TRANSFORM(aEnc[5],"999999999999.99")) + '</cbc:PayableAmount>' + cCRLF
	cXML += '	</cac:LegalMonetaryTotal>' + cCRLF
 
	aSort(aDetImp,,,{|X,Y| x[1] < y[1]}) 
	// Detalle por ítem de la factura
	If Len(aDetImp) > 0		
		For nX := 1 To Len(aDetImp)
			cXML += '	<cac:InvoiceLine>' + cCRLF
			
			cXML += '		<cbc:ID>' + alltrim(str(aDetImp[nX][1])) + '</cbc:ID>' + cCRLF
			cXML += '		<cbc:InvoicedQuantity unitCode="' + alltrim(aDetImp[nX][2]) + '" '
			cXML += 							'unitCodeListID="UN/ECE rec 20" ' 
			cXML += 							'unitCodeListAgencyName="United Nations Economic Commission for Europe">' + alltrim(TRANSFORM(aDetImp[nX][3],"999999999999.9999999999")) + '</cbc:InvoicedQuantity>' + cCRLF
     	    cXML += '		<cbc:LineExtensionAmount currencyID="' + aEnc[4] + '">' + alltrim(Transform(aDetImp[nX][4]-IIf(lDocExp,aDetImp[nX,6],0),"9999999999999.99")) + '</cbc:LineExtensionAmount>' + cCRLF
			cXML += '		<cac:PricingReference>' + cCRLF
			If aDetImp[nX][12] 
				cXML += '			<cac:AlternativeConditionPrice>' + cCRLF  //Precio de venta unitario
				cXML += '				<cbc:PriceAmount currencyID="' + aEnc[4] + '">' +  alltrim(TRANSFORM(aDetImp[nX][09],cPicAmount)) + '</cbc:PriceAmount>' + cCRLF
				cXML += '				<cbc:PriceTypeCode listName="Tipo de Precio" '
				cXML += 								'listAgencyName= "PE:SUNAT" ' 
				cXML += 								'listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo16">02</cbc:PriceTypeCode>' + cCRLF
				cXML += '			</cac:AlternativeConditionPrice>' + cCRLF						
			Else
				cXML += '			<cac:AlternativeConditionPrice>' + cCRLF  //Precio de venta unitario
        		cXML += '				<cbc:PriceAmount currencyID="' + aEnc[4] + '">' + IIf(!aDetImp[nX][12],alltrim(TRANSFORM(aDetImp[nX][11]-IIf(lDocExp,aDetImp[nX,6]/aDetImp[nX][3],0),cPicAmount)),"0.00") + '</cbc:PriceAmount>' + cCRLF
				cXML += '				<cbc:PriceTypeCode listName="Tipo de Precio" '
				cXML += 								'listAgencyName= "PE:SUNAT" ' 
				cXML += 								'listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo16">01</cbc:PriceTypeCode>' + cCRLF
				cXML += '			</cac:AlternativeConditionPrice>' + cCRLF
			EndIf
			cXML += '		</cac:PricingReference>' + cCRLF
			cXML += '		<cac:AllowanceCharge>' + cCRLF
			cXML += '			<cbc:ChargeIndicator>false</cbc:ChargeIndicator>' + cCRLF
			cXML += '			<cbc:AllowanceChargeReasonCode>00</cbc:AllowanceChargeReasonCode>' + cCRLF			
			cXML += '			<cbc:MultiplierFactorNumeric>' + alltrim(TRANSFORM(aDetImp[nX,14]/100,"999.99999"))+ '</cbc:MultiplierFactorNumeric>' + cCRLF
			cXML += '			<cbc:Amount currencyID="' + aEnc[4] + '">' + IIf(!aDetImp[nX][12],alltrim(TRANSFORM(aDetImp[nX][6],"999999.99")),"0.00") + '</cbc:Amount>' + cCRLF
			cXML += '			<cbc:BaseAmount currencyID="' + aEnc[4] + '">' + IIf(!aDetImp[nX][12],alltrim(TRANSFORM(aDetImp[nX,4] + IIf(lDocExp,0,aDetImp[nX,6]),"9999999999.99") ),"0.00") + '</cbc:BaseAmount>'+ cCRLF
			cXML += '		</cac:AllowanceCharge>' + cCRLF  

			If Len(aDetImp[nX][13]) > 0
				cXML += '		<cac:TaxTotal>' + cCRLF
				cXML += '			<cbc:TaxAmount currencyID="' + aEnc[4] + '">' + alltrim(TRANSFORM(aDetImp[nX,5],"9999999999999.99"))/*alltrim(aDetImp[nX][13][nC][1])*/ + '</cbc:TaxAmount>' + cCRLF 				
				For nC := 1 To Len(aDetImp[nX][13]) //Impuestos por ítem
					If Len(aDetImp[nX][13][nC]) > 0
						If !(aDetImp[nX][13][nC][10] == "D")
							cXML += '			<cac:TaxSubtotal>' + cCRLF
							If aDetImp[nX][13][nC,5] <> "ICB"
								cXML += '				<cbc:TaxableAmount currencyID="'+ aEnc[4] + '">' + alltrim(TRANSFORM(aDetImp[nX,4]-IIf(lDocExp,aDetImp[nX,6],0),"9999999999999.99"))+ '</cbc:TaxableAmount>' + cCRLF
							EndIf
							cXML += '				<cbc:TaxAmount currencyID="' + aEnc[4] + '">' + alltrim(TRANSFORM(aDetImp[nX][13][nC][1],"9999999999999.99")) + '</cbc:TaxAmount>' + cCRLF 
							If aDetImp[nX][13][nC,5] == "ICB"
							cXML += '				<cbc:BaseUnitMeasure unitCode="NIU">' + alltrim(TRANSFORM(aDetImp[nX][3],"9999999999999")) + '</cbc:BaseUnitMeasure>' + cCRLF 
							EndIf
							cXML += '				<cac:TaxCategory>' + cCRLF
							If aDetImp[nX][13][nC,5] == "ICB"
							cXML += '					<cbc:PerUnitAmount currencyID="' + aEnc[4] + '">' + alltrim(TRANSFORM(aDetImp[nX][16],"9999999999999.99")) + '</cbc:PerUnitAmount>' + cCRLF 
							Else
								cXML += '					<cbc:Percent>' + alltrim(TRANSFORM(aDetImp[nX][13][nC][8],"999.99"))+ '</cbc:Percent> '  + cCRLF
							EndIf
							If aDetImp[nX][13][nC][5] <> "ISC" .And. aDetImp[nX][13][nC,5] <> "ICB"
								cXML += '					<cbc:TaxExemptionReasonCode listAgencyName="PE:SUNAT" listName="Afectacion del IGV" '
								cXML += 						'listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo07">' + alltrim(aDetImp[nX][13][nC][2]) + '</cbc:TaxExemptionReasonCode>' + cCRLF
							ElseIf aDetImp[nX][13][nC][5] == "ISC" 
								cXML += '					<cbc:TierRange >' + alltrim(aDetImp[nX][13][nC][3]) + '</cbc:TierRange >' + cCRLF
							EndIf
							cXML += '					<cac:TaxScheme>' + cCRLF
							cXML += '						<cbc:ID >' + aDetImp[nX][13][nC,4] + '</cbc:ID>' + cCRLF
							cXML += '						<cbc:Name>' + IIF(aDetImp[nX][13][nC,5] == "ICB", 'ICBPER',aDetImp[nX][13][nC,5])  + '</cbc:Name>' + cCRLF
							cXML += '						<cbc:TaxTypeCode>' + aDetImp[nX][13][nC,6] + '</cbc:TaxTypeCode>' + cCRLF
							cXML += '					</cac:TaxScheme>' + cCRLF
							cXML += '				</cac:TaxCategory>' + cCRLF
							cXML += '			</cac:TaxSubtotal>' + cCRLF
						EndIf
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
    		cXML += '		<cac:Price>' + cCRLF  //Valor unitario
    		cXML += '			<cbc:PriceAmount currencyID="' + aEnc[4] + '">' + IIf(!aDetImp[nX][12],alltrim(TRANSFORM(aDetImp[nX][10]+IIf(lDocExp .Or. aDetImp[nX][10]==0,0,(aDetImp[nX][6]/aDetImp[nX][3])),cPicAmount)),"0.00") + '</cbc:PriceAmount>' + cCRLF
			cXML += '		</cac:Price>' + cCRLF			
			cXML += '	</cac:InvoiceLine>' + cCRLF			
		Next nX		
	EndIf
	cXML += '</Invoice>' + cCRLF	
Return cXML
