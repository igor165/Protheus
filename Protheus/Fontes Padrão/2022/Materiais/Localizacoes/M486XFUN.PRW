#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"
#Include "mata486.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486XMLFE  ³ Autor ³ Luis Enriquez               ³ Data ³ 08.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura de Fac. Electronica para XML de acuerdo al estan-³±±
±±³          ³ dar UBL 2.0 (PERU)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486XMLFE()                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ No aplica.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXMLFE = Nodo de facturacion  electronica para XML de estandar     ³±±
±±³          ³  UBL 2.0                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486NFXML - M486NDCXML - M486NCCXML                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                 ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³   BOPS   ³            Motivo da Alteracao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Luis Enriquez³31/07/18³DMINA-3376³Corrección para agregar solo imptos en array ³±±
±±³(PERU)       ³        ³          ³de detalle si este existe en TES de ítem, se ³±±
±±³             ³        ³          ³utiliza función M486IMPTES.                  ³±±
±±³A. Rodriguez ³23/08/18³DMINA-3967³Réplica modificaciones P11.8 fac-e v2.0 COL  ³±±
±±³A. Rodriguez ³10/10/18³DMINA-4582³Auto-retenciones no suman/restan             ³±±
±±³             ³        ³          ³requiere código alfanumérico. COL            ³±±
±±³L. Enriquez  ³11/10/18³DMINA-4582³Datos de documento relacionado por Query; en ³±±
±±³             ³        ³          ³algunos casos no funciona SET FILTER. COL    ³±±
±±³M.Camargo    ³26/10/18³DMINA-4575³Implementación UBL 2.1 PERU                  ³±±
±±³M.Camargo    ³13/11/18³DMINA-5127³Reestablecimiento cambios dmina-4582         ³±±
±±³V. Flores    ³23/01/19³DMINA-5822³Modificación de tranmision NCC y  XML de NDC ³±±
±±³VM.Camargo   ³07/03/19³DMINA-6224³Correccion guias de remision M486XMLIMP PER  ³±±
±±³L. Enriquez  ³25/03/18³DMINA-6311³Se modifica func. M486AUTOCB para anular por ³±±
±±³             ³        ³          ³execauto NF, NCC y NDC.  (PER)               ³±±
±±³M.Camargo    ³02/04/19³DMINA-6471³Se modifica func. M486XMLIMP para NDC para   ³±±
±±³             ³        ³          ³cuando es exportación, el % de IGV sea 0     ³±±
±±³             ³        ³          ³Se implementa uso de MV_TESEXE para muestras ³±±
±±³             ³        ³          ³gratuitas al exterior                        ³±±
±±³Marco A. Glez³29/04/19³DMINA-6288³Correcciones para la correcta generación del ³±±
±±³             ³        ³          ³nodo <cac:InvoiceDocumentReference> cuando se³±±
±±³             ³        ³          ³relacionen mas de un documento diferente en  ³±±
±±³             ³        ³          ³NCC y NDC (FE Colombia)                      ³±±
±±³Luis Enríquez³13/05/19³DMINA-6347³Se modifica función M486Ref para armado del  ³±±
±±³             ³        ³          ³nodo de referencia para varios domentos rela-³±±
±±³             ³        ³          ³cionados. (PER)                              ³±±
±±³M.Camargo    ³06/06/19³DMINA-6777|Se modifica función M486XMLIMP para nf gratui³±±
±±³             ³        ³          ³ta para que no envié valores unitarios en 0  ³±±
±±³             ³        ³          ³en el valor del ítem (PER)                   ³±±
±±³M.Camargo    ³26/07/19³DMINA-6777|Se modifica función M486REF para retornar co-³±±
±±³             ³        ³          ³rrectamente el numero de referencia cuando el³±±
±±³             ³        ³          ³tamaño es menos a 8 caracteres. Se retorna   ³±±
±±³             ³        ³          ³en el XML la fecha de emisión del documento  ³±±
±±³             ³        ³          ³de referencia por lo que se agrega función   ³±±
±±³             ³        ³          ³M486GETEMI para obtenr dicho dato.           ³±±
±±³             ³        ³          ³Se modifica función M486XMLIMP para cuando   ³±±
±±³             ³        ³          ³existen guias de remisión retorne numero de  ³±±
±±³             ³        ³          ³documento a 8 caracteres.                    ³±±
±±³Luis Enríquez³08/08/19³DMINA-7002³Se realiza modificación a generación de nodo ³±±
±±³             ³        ³          ³TaxTotal en encabezado y detalle para XML de ³±±
±±³             ³        ³          ³FE Colombia Val. Previa. (COL)               ³±±
±±³Oscar G.     ³04/09/19³DMINA-7145³En Fun. M486XMLIMP se realiza tratamiento    ³±±
±±³             ³        ³          ³para fact. de muestras gratuitas para cliente³±±
±±³             ³        ³          ³extranjero. (PER)                            ³±±
±±³Veronica Flo ³06/09/19³DMINA-7268³En Fun. M486XMLIMP se realiza la extracción  ³±±
±±³             ³        ³          ³de la alicuota de los items para enviarlo en ³±±
±±³             ³        ³          ³el array de Impuestos. (PER)                 ³±±
±±³Veronica Flo ³10/09/19³DMINA-7268³En Fun. M486XMLIMP se atiende defecto        ³±±
±±³             ³        ³          ³y no se suma el valor del impuesto ICBPER    ³±±
±±³             ³        ³          ³en el total. (PER)                           ³±±
±±³M.Camargo    ³27/09/19³DMINA-7501|Ajustes operaciones gratuitas y gravadas.    ³±±
±±³Luis Enriquez³06/11/19³DMINA-7702³Ajuste de decimales de porcentajes en el no- ³±±
±±³             ³        ³          ³TaxTotal, en fGetRef() se corrige error en la³±±
±±³             ³        ³          ³generación de nodo de docs relacionados (COL)³±±
±±³Luis Enriquez³13/12/19³DMINA-8023³En función fgetTaxas se realiza ajuste para  ³±±
±±³             ³        ³          ³base imponible p/doc con IVA e ICA (COL)     ³±±
±±³Jose Glez    ³13/02/20³DMINA-8156³Se agrega PE MT486AgDes para modificar la    ³±±
±±³             ³        ³          ³descripción del Producto en el XML           ³±±
±±³Luis Enriquez³22/04/20³DMINA-8877³Se realiza corrección para acumulado de auto-³±±
±±³             ³        ³          ³rretenciones excluis código DIAN 'ZZ' de las ³±±
±±³             ³        ³          ³autorretenciones (COL)                       ³±±
±±³Marco A. Glez³10/06/20³DMINA-9376³Se agrega PE M486VLDCMP para desactivar vali-³±±
±±³             ³        ³          ³daciones en Pedido de Venta que genera Remi- ³±±
±±³             ³        ³          ³sion con FE activa. (PER)                    ³±±
±±³Luis Enriquez³19/08/20³DMINA-9853³Se realizan ajustes al xml para tratamiento  ³±±
±±³             ³        ³          ³de descuentos en NCC (COL)                   ³±±
±±³Luis Enriquez³06/09/20³DMINA-9655³Se activan nodos para transmisión de Factura/³±±
±±³             ³        ³          ³Boleta con detracción. (PER)                 ³±±
±±³Luis Enriquez³21/09/20³DMINA-10149³En función fGetTaxDet se agrega tratamiento ³±±
±±³             ³        ³          ³p/TES que no agrega valor de mercaderia, en- ³±±
±±³             ³        ³          ³viar cac:InvoiceLine/cbc:LineExtensionAmount ³±±
±±³             ³        ³          ³con valor cero. (COL)                        ³±±
±±³Marco A. Glez³22/11/20³ DMINA-   ³Se agrega uso de funcion X5Descri() en la    ³±±
±±³             ³        ³  10567   ³funcion M486VALSX5.                          ³±±
±±³Luis Enriquez³03/02/21³DMINA-    ³Se activa funcionalidad de Forma de Pago para³±±
±±³             ³        ³  10845   ³NF y NCC Fact. Electrónica. (PER)            ³±±
±±³Luis Enríquez³13/04/21³DMINA-    ³Se realiza tratamiento para colocar el valor ³±±
±±³             ³        ³  11807   ³unitario por ítem en el nodo cbc:PriceAmount ³±±
±±³             ³        ³          ³y valor total por ítem en LineExtensionAmount³±±
±±³             ³        ³          ³para tipo de afectación IG 30-Inafecta (PER) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486XMLFE()
	Local cXMLFE := ""
	Local cCRLF	 := (chr(13)+chr(10))
	cXMLFE := '	<cac:Signature>' + cCRLF
	cXMLFE += '		<cbc:ID>IDSignTOTVS</cbc:ID>' + cCRLF
	cXMLFE += '		<cac:SignatoryParty>' + cCRLF
	cXMLFE += '			<cac:PartyIdentification>' + cCRLF
	cXMLFE += '				<cbc:ID>' + RTRIM(SM0->M0_CGC) + '</cbc:ID>' + cCRLF
	cXMLFE += '			</cac:PartyIdentification>' + cCRLF
	cXMLFE += '			<cac:PartyName>' + cCRLF
	cXMLFE += '				<cbc:Name><![CDATA[' + RTRIM(SM0->M0_NOME) + ']]></cbc:Name>' + cCRLF
	cXMLFE += '			</cac:PartyName>' + cCRLF
	cXMLFE += '		</cac:SignatoryParty>' + cCRLF
	cXMLFE += '		<cac:DigitalSignatureAttachment>' + cCRLF
	cXMLFE += '			<cac:ExternalReference>' + cCRLF
	cXMLFE += '				<cbc:URI>#SignatureTOTVS</cbc:URI>' + cCRLF
	cXMLFE += '			</cac:ExternalReference>' + cCRLF
	cXMLFE += '		</cac:DigitalSignatureAttachment>' + cCRLF
	cXMLFE += '	</cac:Signature>' + cCRLF
Return cXMLFE

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486XMLEMI ³ Autor ³ Luis Enriquez         ³ Data ³ 08.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura de Emisor para XML de acuerdo al estandar  ³±±
±±³          ³ UBL 2.0 (PERU)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486XMLEMI()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ No aplica.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXMLFE .- Nodo de emisor para XML de estandar UBL 2.0        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486NFXML - M486NDCXML - M486NCCXML                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486XMLEMI(lComBaja)
	Local cXMLEmi := ""
	Local cCRLF	 := (chr(13)+chr(10))

	Default lComBaja := .F.

	cXMLEmi += '	<cac:AccountingSupplierParty>' + cCRLF
	cXMLEmi += '		<cbc:CustomerAssignedAccountID>' + RTRIM(SM0->M0_CGC) + '</cbc:CustomerAssignedAccountID>' + cCRLF
	cXMLEmi += '		<cbc:AdditionalAccountID>6</cbc:AdditionalAccountID>' + cCRLF
	cXMLEmi += '		<cac:Party>' + cCRLF
	If !lComBaja
		cXMLEmi += '			<cac:PartyIdentification>'  + cCRLF
	   	cXMLEmi += '				<cbc:ID schemeID="6" schemeName="Documento de Identidad" schemeAgencyName="PE:SUNAT" schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo06">' + RTRIM(SM0->M0_CGC) + '</cbc:ID>'  + cCRLF
	   	cXMLEmi += '			</cac:PartyIdentification> '  + cCRLF
		cXMLEmi += '			<cac:PartyName>' + cCRLF
		cXMLEmi += '				<cbc:Name><![CDATA[' + RTRIM(SM0->M0_NOMECOM) + ']]></cbc:Name>' + cCRLF
		cXMLEmi += '			</cac:PartyName>' + cCRLF
	EndIf
	cXMLEmi += '			<cac:PartyLegalEntity>' + cCRLF
	cXMLEmi += '				<cbc:RegistrationName><![CDATA[' + RTRIM(SM0->M0_NOME) + ']]></cbc:RegistrationName>' + cCRLF
	If !lComBaja
		cXMLEmi += '				<cac:RegistrationAddress>'+ cCRLF
	   	cXMLEmi += '					<cbc:ID schemeName="Ubigeos">' + RTRIM(SM0->M0_CEPENT) + '</cbc:ID>' + cCRLF
	   	cXMLEmi += '					<cbc:AddressTypeCode listName="Establecimientos anexos">' + Alltrim(SM0->M0_DSCCNA) + '</cbc:AddressTypeCode>'+ cCRLF
	   	cXMLEmi += '				   	<cbc:CitySubdivisionName>-</cbc:CitySubdivisionName>'+ cCRLF
	   	cXMLEmi += '            		<cbc:CityName><![CDATA[' + RTRIM(SM0->M0_CIDENT) + ']]></cbc:CityName>'+ cCRLF
	 	cXMLEmi += '              		<cbc:CountrySubentity><![CDATA[' + RTRIM(SM0->M0_CIDENT) + ']]></cbc:CountrySubentity>'+ cCRLF
		cXMLEmi += '               		<cbc:District><![CDATA[' + RTRIM(SM0->M0_BAIRENT) + ']]></cbc:District>'+ cCRLF
	   	cXMLEmi += '            		<cac:AddressLine>'+ cCRLF
	  	cXMLEmi += '                		<cbc:Line><![CDATA[' + RTRIM(SM0->M0_ENDENT) + ']]></cbc:Line>'+ cCRLF
		cXMLEmi += '              		</cac:AddressLine>'+ cCRLF
		cXMLEmi += '               		<cac:Country>'+ cCRLF
		cXMLEmi += '                		<cbc:IdentificationCode listName="Country">PE</cbc:IdentificationCode>'+ cCRLF
		cXMLEmi += '					</cac:Country>'+ cCRLF
		cXMLEmi += '          		</cac:RegistrationAddress>' + cCRLF
	EndIf
	cXMLEmi += ' 			</cac:PartyLegalEntity>' + cCRLF
	cXMLEmi += '		</cac:Party>' + cCRLF
	cXMLEmi += '	</cac:AccountingSupplierParty>' + cCRLF
Return cXMLEmi

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486XMLREC ³ Autor ³ Luis Enriquez         ³ Data ³ 08.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura de Receptor para XML de acuerdo al estandar³±±
±±³          ³ UBL 2.0 (PERU)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486XMLREC(cCliente,cLoja)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCliente.- Clave del cliente                                 ³±±
±±³          ³ cLoja.- Clave de tienda del cliente                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXMLFE .- Nodo de receptor para XML de estandar UBL 2.0      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486NFXML - M486NDCXML - M486NCCXML                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486XMLREC(cCliente,cLoja)
	Local cXMLRec 	:= ""
	Local cCRLF	 	:= (chr(13)+chr(10))
	Local aArea 	:= getArea()
	Local cPais 	:= ""
	Local cNoId		:= ""
	Local cNomCli   := ""
	Local cMVPROVFE	:= SuperGetMV("MV_PROVFE",,"")
	Local lDirRec   := ExistBlock("M486DIRREC")
	//Receptor (Clientes)
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
		cTipDocId := ALLTRIM(SA1->A1_TIPDOC)
		If cTipDocId $ "6"
			cNoId := RTRIM(SA1->A1_CGC)
		Else
			cNoId := RTRIM(SA1->A1_PFISICA)
		EndIf
		IF cMVPROVFE != "TCI"
			cNomCli := RTRIM(EncodeUtf8(SA1->A1_NOME))
		Else
			cNomCli := RTRIM(SA1->A1_NOME)
		EndIf
		dbSelectArea("SYA")
		SYA->(dbSetOrder(1)) //YA_FILIAL+YA_CODGI
		If SYA->(dbSeek(xFilial("SYA") + SA1->A1_PAIS))
			cPais := SYA->YA_CODERP
		EndIf
		cXMLRec += '	<cac:AccountingCustomerParty>' + cCRLF
		cXMLRec += '		<cac:Party>' + cCRLF
		cXMLRec += '			<cac:PartyIdentification>'+ cCRLF
		cXMLRec += '				<cbc:ID schemeID="'+ cTipDocId +'" '
		cXMLRec += 						'schemeName="Documento de Identidad" '
		cXMLRec += 						'schemeAgencyName="PE:SUNAT" '
		cXMLRec += 						'schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo06">'+ cNoId  + '</cbc:ID> '+ cCRLF
		cXMLRec += '		 	</cac:PartyIdentification>'+ cCRLF
		cXMLRec += '			<cac:PartyLegalEntity>' + cCRLF
		cXMLRec += '				<cbc:RegistrationName><![CDATA[' + cNomCli + ']]></cbc:RegistrationName>' + cCRLF
		//Punto de entrada para personalizar la información de la Dirección del receptor
		If lDirRec
			cXMLRec += ExecBlock("M486DIRREC",.F.,.F.)
		EndIf
		cXMLRec += '			</cac:PartyLegalEntity>' + cCRLF
		If !Empty(SA1->A1_EMAIL)
			cXMLRec += '			<cac:Contact>'+ cCRLF
		    cXMLRec += '				<cbc:ElectronicMail>' + Alltrim(SA1->A1_EMAIL) + '</cbc:ElectronicMail>' + cCRLF
			cXMLRec += '			</cac:Contact>'+ cCRLF
		EndIf
		cXMLRec += '		</cac:Party>' + cCRLF
		cXMLRec += '	</cac:AccountingCustomerParty>' + cCRLF
	EndIf
	RestArea(aArea)
Return cXMLRec

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486VALSX5 ³ Autor ³ Luis Enriquez         ³ Data ³ 31.05.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene Descripción de item en SX5                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486VALSX5(cClave)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ CClave = (X5_TABELA + X5_CHAVE).                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet = Valor obtenido de campo X5_DESCSPA de tabla generica. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486NFXML - M486NDCXML - M486NCCXML                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486VALSX5(cClave)
	Local cRet := ""
	Local aArea 	:= getArea()

	dbSelectArea("SX5")
	SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
	If SX5->(dbSeek(xFilial("SX5") + cClave))
		cRet := X5Descri()
	EndIf
	RestArea(aArea)
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486XMLIMP ³ Autor ³ Luis Enriquez         ³ Data ³ 31.05.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene calculo de impuestos (Generales)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486XMLIMP(cEspecie,cDoc,cSerie,cCliente,cLoja,lDocExp,      ³±±
±±³          ³ aImpFact,aDetFac,aValAdic,nTotalVta,lGratis)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cEspDoc .- Especie del documento.                            ³±±
±±³          ³ cDoc .- Numero de documento.                                 ³±±
±±³          ³ cSerie .- Numero o Serie del Documento.                      ³±±
±±³          ³ cCliente .- Codigo del cliente.                              ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±³          ³ lDocExp .- Documento de Exportacion.                         ³±±
±±³          ³ aImpFact .- Datos de impuestos.                              ³±±
±±³          ³ aDetFac .-  Detalle de impuestos del documento.              ³±±
±±³          ³ aValAdic .- Adicionales de operaciones.                      ³±±
±±³          ³ nTotalVta.- Total venta(Gravada+Inafecta+Exonerada+IGV+ISC)  ³±±
±±³          ³ lGratis .- Factura gratuita.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aImpsto .- Arreglo con valor, codigo, y valores de acuero a  ³±±
±±³          ³ catalogo 05 de la SUNAT.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486NFXML - M486NDCXML - M486NCCXML                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486XMLIMP(cEspecie,cDoc,cSerie,cCliente,cLoja,lDocExp,aImpFact,aDetFac,aValAdic,nTotalVta,lGratis,aGRFac,nTImp,lIvap,nVlrAnt,aDocAnt,aImpAfe)
	Local cCampos 		:= ""
	Local cTablas 		:= ""
	Local cCond   		:= ""
	Local cGroup  		:= ""
	Local cOrder  		:= ""
	Local aArea 	  	:= getArea()
	Local cAliasImp  	:= getNextAlias()
	Local nX 			:= 0
	Local nA 			:= 0
	Local nProp         := 0
	Local nImp          := 0
	Local cTipIGV 		:= ""
	Local cTipISC 		:= ""
	Local nBasImp 		:= 0
	Local nValImp 		:= 0
	Local nAliqImp 		:= 0
	Local cAliasSD  	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"SD2","SD1")
	Local nOrder    	:= IIf(alltrim(cEspecie) $ 'NF|NDC',3,1) //D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA  //D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA
	Local cBasimpSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_BASIMP","D1_BASIMP")
	Local cValimpSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_VALIMP","D1_VALIMP")
	Local cFilialSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_FILIAL","D1_FILIAL")
	Local cTesD     	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_TES","D1_TES")
	Local cSerieSD  	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_SERIE","D1_SERIE")
	Local cDocSD    	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_DOC","D1_DOC")
	Local cClieSD   	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_CLIENTE","D1_FORNECE")
	Local cLojaSD   	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_LOJA","D1_LOJA")
	Local cItemSD   	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_ITEM","D1_ITEM")
	Local cUniMedSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_UM","D1_UM")
	Local cCantSD   	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_QUANT","D1_QUANT")
	Local cTotalSD  	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_TOTAL","D1_TOTAL")
	Local cDescSD   	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_DESCON","D1_VALDESC")
	Local cPreVtaSD 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_PRCVEN","D1_VUNIT")
	Local cCodProSD   	:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_COD","D1_COD")
	Local cDescPor		:= IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_DESC","D1_DESC")
	Local cAlqImpSD	    := IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_ALQIMP","D1_ALQIMP")
	Local cCpoAnt  	    := IIf(alltrim(cEspecie) $ 'NF|NDC',"D2_VALADI","D1_VALADI") //Campo de Anticipo
	Local nTotalImp 	:= 0
	Local nConGra 		:= 0
	Local cUniMed 		:= ""
	Local cDesPro 		:= ""
	Local nValUni 		:= 0
	Local nTotGrav 		:= 0
	Local nTotExo 		:= 0
	Local nTotGrat 		:= 0
	Local nTotExp		:= 0
	Local nTotPer 		:= 0
	Local nTotRet 		:= 0
	Local nTotDesc 		:= 0
	Local nBasePer 		:= 0
	Local aImpos 		:= {}
	Local nValmpDet 	:= 0
	Local nPos 			:= 0
	Local aImpAux 		:= {}
	Local lItemGrat 	:= .F.
	Local nCount 		:= 0
	Local cCodProd 		:= ""
	Local aM486DET 		:= {}
	Local nQtdItem		:= 0
	Local lRet			:= .F.
	Local nPosGR		:= 0
	Local nTotInaf		:= 0
	Local nValBase		:= 0
	Local cClave		:= ""
	Local nAliq			:= 0
	Local cCodprd		:= ""
	Local cCodImp		:= ""
	Local cGRClave		:= ""
	Local cTESGrat		:= SuperGetMV("MV_TESEXE",,"")
	Local cNomeImp		:= ""
	Local lItemGG		:= .F. // ïtem gratuito y gravado
	Local nPrecVar      := 0
	Local aProdBon      := {}
	Local nQtdIGV       := 0
	Local nDescont      := 0
	Local cFilSD		:= xFilial(cAliasSD)
	Local cFilSF4		:= xFilial("SF4")
	Local cConDet		:= ""
	Local cCposDet		:= ""
	Local cCpoValImp	:= ""
	Local cCpoBasImp	:= ""
	Local aDetImp		:= {}
	Local nProd			:= 0
	Local cTpIGV		:= ""
	Local nTotImpGra    := 0
	Local nVlrAntIt     := 0
	Local aImpAnt       := {}
	Local aDetDAnt      := {}
	Local cMonAnt       := ""
	Local nPosImp       := 0
	Local aImpAntIt     := {} 
	Local nJ            := 0
	Local nAntDoc       := 0
	Local aAdianta      := M486CFGADT()
	Local lAdtCompart   := aAdianta[1,5] .And. 'C' $ aAdianta[1,1] + aAdianta[1,2] + aAdianta[1,3]
	Local cFilFR3       := xFilial("FR3")
	
	Default nTotalVta 	:= 0
	Default aGRFac		:= {}
	Default nVlrAnt     := 0
	Default aDocAnt     := {}
	Default aImpAfe     := {}

	//Anticipos
	If Alltrim(cEspecie) == "NF" .And. nVlrAnt > 0 //Anticipos
		aDocAnt := M486DOCANT(cFilFR3,cCliente,cLoja,cDoc,cSerie)
		If Len(aDocAnt) > 0
			nVlrAnt := 0
			For nA := 1 To Len(aDocAnt)
				aImpAnt := {}
				M486IMPANT(aDocAnt[nA][1], aDocAnt[nA][7], aDocAnt[nA][8], aDocAnt[nA][9], aDocAnt[nA][6], cEspecie,@aImpAnt, @aDetDAnt, @nAntDoc, @cMonAnt, @aImpAfe)
				aDocAnt[nA][11] := cMonAnt
				aDocAnt[nA][5]  := nAntDoc
				aDocAnt[nA][12] := aImpAnt
				nVlrAnt += nAntDoc
			Next nA
		EndIf
	EndIf

	//Impuestos factura
	If(alltrim(cEspecie) == "NCC")
		cClave		:= xfilial(cAliasSD) + cDoc + cSerie + cCliente + cLoja
	Else
		cClave		:= xfilial(cAliasSD)+cCliente + cLoja + cDoc + cSerie
	EndIf

	cCampos	:= "% SFB.FB_CODIMP, SFB.FB_ALIQ, SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO, SFC.FC_INCDUPL, SFC.FC_TES  %"
	cTablas	:= "% " + RetSqlName(cAliasSD) + " "+cAliasSD+", "  + RetSqlName("SFC") + " SFC, "  + RetSqlName("SFB") + " SFB %"
	cCond	:= "% "+cAliasSD+"."+cDocSD+" = '" + cDoc + "' AND "+cAliasSD+"."+cSerieSD+" = '" + cSerie + "'"
	cCond  	+= " AND "+cAliasSD+"."+cClieSD+" = '" + cCliente + "' AND "+cAliasSD+"."+cLojaSD+" = '" + cLoja + "'"
	cCond  	+= " AND "+cAliasSD+"."+cTesD+" = SFC.FC_TES "
	cCond 	+= "AND SFC.FC_IMPOSTO = SFB.FB_CODIGO"
	cCond	+= " AND SFC.FC_FILIAL = '" + xFilial("SFC") + "'"
	cCond	+= " AND SFB.FB_FILIAL = '" + xFilial("SFB") + "'"
	cCond	+= " AND SFC.D_E_L_E_T_  = ' ' "
	cCond	+= " AND SFB.D_E_L_E_T_  = ' ' %"
	cGroup 	:= "% SFB.FB_CODIMP, SFB.FB_ALIQ ,SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO, SFC.FC_INCDUPL, SFC.FC_TES %"
	cOrder 	:= "% SFB.FB_CODIMP,SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_CLASSE, SFC.FC_IMPOSTO,SFC.FC_INCDUPL %"

	BeginSql alias cAliasImp
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		GROUP BY %exp:cGroup%
		ORDER BY %exp:cOrder%
	EndSql
	count to nCount
	dbSelectArea(cAliasImp)
	If nCount > 0
		(cAliasImp)->(DbGoTop())
		cConDet		:= "% "+cFilialSD+" = '"+cFilSD+"'"
		cConDet		+= " AND "+cDocSD+" = '" + cDoc + "' AND "+cSerieSD+" = '" + cSerie + "'"
		cConDet  	+= " AND "+cClieSD+" = '" + cCliente + "' AND "+cLojaSD+" = '" + cLoja + "'"
		cConDet  	+= " AND "+cTesD+" = "
		While (cAliasImp )->(!Eof())
			nValBase 	:= 0
			nValImp 	:= 0

			cCpoValImp	:= cValimpSD+Alltrim((cAliasImp)->FB_CPOLVRO)
			cCpoBasImp	:= cBasimpSD+Alltrim((cAliasImp)->FB_CPOLVRO)
			cCposDet	:= "% SUM("+cTotalSD+") "+cTotalSD+", SUM("+cCpoBasImp+") "+cCpoBasImp+", SUM("+cCpoValImp+") "+cCpoValImp+" %"

			aDetImp		:= ObtBasVal(cCposDet, cAliasSD, cConDet, (cAliasImp )->FC_TES, cTotalSD, cCpoBasImp, cCpoValImp)
			nValBase	:= aDetImp[1]
			nValImp		:= aDetImp[2]

			If (cAliasImp)->FB_CLASSE $ "I|D"
				nAliq := IIF(lDocExp .and. (alltrim(cEspecie) == "NDC") ,0,(cAliasImp)->FB_ALIQ)
			EndIf
			/*
				Estructura array Impuestos Globales
				1. Libro Fiscal
				2. Código de Impuesto
				3. Clase de Impuesto
				4. Nombre Imp cat No. 005
				5. Descripcion
				6. 0
				7. False
				8. Código SFB
				9. Si es Incluido
				10.Base del Impuesto
				11.Col 4 cat No. 05
				12.Alícuota en SFB
				13.Codigo TES
			*/
			aAdd(aImpFact,{(cAliasImp)->FB_CPOLVRO,;
							(cAliasImp)->FB_CODIMP,;
							(cAliasImp)->FB_CLASSE,;
							ObtColSAT("S005", (cAliasImp)->FB_CODIMP, 1, 4, 48, 3),;
							ObtColSAT("S005", (cAliasImp)->FB_CODIMP, 1, 4, 45, 3),;
							0,;
							.F.,;
							(cAliasImp)->FB_CODIGO,;
							(cAliasImp)->FC_INCDUPL,;
							nValBase,;
							"",;
							nAliq,;
							(cAliasImp)->FC_TES})

			(cAliasImp)->(dbskip())
		EndDo
		(cAliasImp)->(DBCloseArea())
	ElseIf lDocExp
		dbSelectArea("SFB")
		SFB->(dbSetOrder(1)) // FB_FILIAL + FB_CODIGO
		If SFB->(dbSeek(XFILIAL("SFB") +"IGV"))
			aAdd(aImpFact,{SFB->FB_CPOLVRO,;
							SFB->FB_CODIMP,;
							SFB->FB_CLASSE,;
							ObtColSAT("S005", SFB->FB_CODIMP, 1, 4, 48, 3),;
							ObtColSAT("S005", SFB->FB_CODIMP, 1, 4, 45, 3),;
							0,;
							.F.,;
							SFB->FB_CODIGO,;
							"1",;
							nValBase,;
							"",;
							IIF(lDocExp .and. alltrim(cEspecie)$"NDC|NF",0, SFB->FB_ALIQ),;
							""})
		EndIf
	EndIF

	AEval(aImpFact, {|x,y| If(aImpFact[y][4] == "IGV", nQtdIGV++,.T.)})

	dbSelectArea(cAliasSD)
	&(cAliasSD)->(dbSetOrder(nOrder))
	&(cAliasSD)->(DbGoTop())
	nPos := 0
	If &(cAliasSD)->(DbSeek(xFilial(cAliasSD) + cDoc + cSerie + cCliente + cLoja))
		Do While (cAliasSD)->(!Eof()) .AND. (cAliasSD)->&(cFilialSD)+(cAliasSD)->&(cDocSD)+(cAliasSD)->&(cSerieSD)+(cAliasSD)->&(cClieSD)+(cAliasSD)->&(cLojaSD) == xFilial(cAliasSD) + cDoc + cSerie + cCliente + cLoja
			nPos += 1
			aImpAntIt := {}
			For nX := 1 To Len(aImpFact)
				If !Empty(aImpFact[nX,13]) .And. !(aImpFact[nX,13] == (cAliasSD)->&(cTesD))
					loop
				EndIf
				lRet     	:= M486IMPTES(aImpFact[nX][8],(cAliasSD)->&(cTesD))
				aImpAux 	:= {}
				nBasImp  	:= 0
				nValImp  	:= 0
				nValmpDet 	:= 0
				nAliqImp	:= 0
				nPrecVar	:= 0
				nTotDesc 	+= (cAliasSD)->&(cDescSD) //Descuento
				nVlrAntIt   := (cAliasSD)->&(cCpoAnt) //Anticipo
				cCodprd		:= POSICIONE("SB1",1,XFILIAL("SB1")+ (cAliasSD)->&(cCodProSD),"B1_PRODSAT")
				If lRet
					cTpIGV := POSICIONE("SF4",1,cFilSF4 + aImpFact[nX,13],"F4_CALCIGV") //F4_FILIAL+F4_CODIGO
					nBasImp  := IIf(aImpFact[nX][3] == "D",0,(cAliasSD)->&(cBasimpSD + aImpFact[nX][1])) //Base del impuesto
					If !(cTpIGV $ "2|3")
						nValImp  := (cAliasSD)->&(cValimpSD + aImpFact[nX][1]) //Valor del impuesto
					EndIf
					nAliqImp := (cAliasSD)->&(cAlqimpSD + aImpFact[nX][1]) //Alicuota del impuesto
				EndIf
				nValUni  :=  0
				cCodProd := RTRIM((cAliasSD)->&(cCodProSD))
				nQtdItem := (cAliasSD)->&(cCantSD)
				lItemGrat:= .F.
				lItemGG	 := .F.
				If aImpFact[nX][3] == 'I' //Impuesto
						cCodImp	:= aImpFact[nX][2]
						cNomeImp:= aImpFact[nX][4]
						cTipIGV := M486TIPIGV((cAliasSD)->&(cTesD),aImpFact[nX][8]) //Tipo IGV
						cTipISC := M486TIPISC((cAliasSD)->&(cTesD),aImpFact[nX][8]) //Tipo ISC

						If aImpFact[nX,9] == "3" .And. (cAliasSD)->&(cDescSD) > 0 .And. nAliqImp > 0 // Si el impuesto es incluido
							nDescont := (cAliasSD)->&(cDescSD) / (1+(nAliqImp/100))
						Else
							nDescont := (cAliasSD)->&(cDescSD) //Descuento
						EndIf

							// Para agrupación
							If cTipIGV $ '10'  // 1001 - Gravadas
								nValUni :=  (cAliasSD)->&(cPreVtaSD) + (cAliasSD)->&(cDescSD) //Valor unitario
								aImpFact[nX][6] += nValImp
								If aImpFact[nX,9] <> "3" // Si el impuesto es incluido, ya no se suma
									nTotalImp += nValImp
									nTotGrav += (cAliasSD)->&(cCantSD) * (cAliasSD)->&(cPreVtaSD) //Total importe - gravadas
								Else
									nTotGrav += nBasImp
								EndIf
								nValmpDet := nValImp
								nTotalVta += (cAliasSD)->&(cCantSD) * (cAliasSD)->&(cPreVtaSD)
							ElseIf cTipIGV $ '30'  // 1002 - Inafectas
								nValUni :=  (cAliasSD)->&(cPreVtaSD) + (cAliasSD)->&(cDescSD) //Valor unitario ítem
								nPrecVar := (cAliasSD)->&(cTotalSD) + (cAliasSD)->&(cDescSD) //Valor Total ítem
								nTotInaf += (cAliasSD)->&(cCantSD) * (cAliasSD)->&(cPreVtaSD)
								nTotalVta += (cAliasSD)->&(cCantSD) * (cAliasSD)->&(cPreVtaSD)
								cCodImp := '9998'
							ElseIf cTipIGV $ '20|21' // 1003 - Exoneradas
								nValUni :=  (cAliasSD)->&(cPreVtaSD) + (cAliasSD)->&(cDescSD) //Valor unitario
								nTotExo += (cAliasSD)->&(cCantSD) * (cAliasSD)->&(cPreVtaSD)
								nTotalVta += (cAliasSD)->&(cCantSD) * (cAliasSD)->&(cPreVtaSD)
								nPrecVar := (cAliasSD)->&(cTotalSD) + (cAliasSD)->&(cDescSD) //Valor Total ítem
								cCodImp := '9997'
							ElseIf cTipIGV $ '11|12|13|14|15|16|17|31|32|33|34|35|36|37' .Or. (cAliasSD)->&(cTesD) $ cTESGrat // 1004 - Gratuitas y que NO sean de exportación
								lItemGrat := .T.
								nConGra += 1
								cCodImp := '9996'
								nTotImpGra += nValImp
								If cTipIGV == "31" .And. nQtdIGV > 1
									aImpFact[nX,10] := 0
								EndIf
								If cTipIGV $ '11|12|13|14|15|16|17'
									lItemGG := .T.
									aImpFact[nX,10] := aImpFact[nX,10] - nBasImp
									If cTipIGV $ '17'
										lIvap := .T.
									EndIf
								EndIf
								aProdBon := {(cAliasSD)->&(cCodProSD),(cAliasSD)->&(cCantSD),(cAliasSD)->&(cTesD)}
								If aImpFact[nX,9] <> "3" .Or. IIf(FindFunction("FtIsBonus"),FtIsBonus(aProdBon),.T.) // Si el impuesto es incluido, ya no se suma o si es bonificación obtiene directo el costo
									If cTipIGV == "31" .And. (cAliasSD)->&(cDescSD) > 0
										nTotGrat += (cAliasSD)->&(cTotalSD)
									Else
										nTotGrat += (cAliasSD)->&(cCantSD) * (cAliasSD)->&(cPreVtaSD)
									EndIf
									nValUni :=  (cAliasSD)->&(cPreVtaSD) //Valor unitario
									nPrecVar := (cAliasSD)->&(cTotalSD)
								Else									
									If cTpIGV $ "2|3"
										nValUni :=  (cAliasSD)->&(cPreVtaSD) //Valor unitario
										nPrecVar := (cAliasSD)->&(cTotalSD)  //Valor Total
										nTotGrat += (cAliasSD)->&(cTotalSD)  //Valor Total
									Else
										nValUni :=  nBasImp / (cAliasSD)->&(cCantSD) //Valor unitario
										nPrecVar := nBasImp
										nTotGrat += nBasImp
									EndIf									
									
								EndIf
							ElseIf cTipIGV $ '40' .AND. !lItemGrat .Or. lDocExp // Exportación
								nTotalVta += (cAliasSD)->&(cCantSD) * (cAliasSD)->&(cPreVtaSD)
								cCodImp := '9995'
								If aImpFact[nX,9] <> "3" .Or. cTpIGV == "3" // Si el impuesto es incluido, ya no se suma
									nTotalImp += nValImp
									nTotExp	+= (cAliasSD)->&(cCantSD) * (cAliasSD)->&(cPreVtaSD) //Total importe - gravadas
									nValUni	:=  (cAliasSD)->&(cPreVtaSD) + (cAliasSD)->&(cDescSD) //Valor unitario
									nPrecVar:= (cAliasSD)->&(cTotalSD) + (cAliasSD)->&(cDescSD)
								Else
									nTotExp += nBasImp
									nPrecVar := nBasImp
								EndIf
								If (cAliasSD)->&(cTesD) $ cTESGrat
									lGratis := .T.
								Else
									lGratis := .F.
								EndIf
								aImpFact[nX][2] := cCodImp
								aImpFact[nX][4] := ObtColSAT("S005",cCodImp, 1, 4, 48,  3)
								aImpFact[nX][5] := ObtColSAT("S005", cCodImp, 1, 4,45 , 3)
							Else
								nValmpDet := nValImp
								aImpFact[nX][6] += nValImp
								If aImpFact[nX,9] <> "3" // Si el impuesto es incluido, ya no se suma
									nTotalImp += nValImp
								EndIf
							EndIf

						If lDocExp
							If aImpFact[nX][7] == .F.
								aImpFact[nX][7] := .T.
							EndIf
						EndIf

						If nBasImp > 0 .AND. nValImp > 0
							If aImpFact[nX][7] == .F.
								aImpFact[nX][7] := .T.
							EndIf
						EndIf
				ElseIf aImpFact[nX][3] == 'P' //Percepcion
					nTotPer += nValImp  //Total importe - percepciones
					nBasePer += nBasImp //Total base - percepciones
					aImpAux := {}
				ElseIf aImpFact[nX][3] == 'R' //Retencion
					nTotRet += nValImp //Total importe - retenciones
					aImpAux := {}
				ElseIf aImpFact[nX][3] == 'D' //Detracción
					aImpFact[nX][6] += nValImp
				EndIf

				If lRet .or. lDocExp
					/*
					Estructuta del array aImpAux
					1. Valor del Impuesto x item
					2. Tipo IGV
					3. Tipo ISC
					4. Code Imm Col 1 Cat No.5
					5. Name Code Col 2. Cat No. 5
					6. TaxType  Col 3Cat No. 5
					7. true
					8. Cat Code col 4 Cat no 5
					9.
					*/

					If cCodImp $ "9995/9996/9997/9998"
						cNomeImp	:= ObtColSAT("S005",cCodImp, 1, 4, 48,  3)
					EndIf
					aImpAux := {IIF(lItemGG,nValImp,nValmpDet), ;
								cTipIGV, ;
								cTipISC, ;
								cCodImp, ;
								cNomeImp, ;
								ObtColSAT("S005", cCodImp, 1, 4,45 , 3), ;
								.T., ;
								aImpFact[nX][12],;
								"",;
								aImpFact[nX][3]}
				EndIf

				cUniMed := M486UNIMED((cAliasSD)->&(cUniMedSD))
				If !lDocExp
					If !lItemGrat
						If !(cCodImp $ "9998|9997")
							nPrecVar := nBasImp
						EndIf
					EndIf
				EndIf

				//Acumulado de anticipo
				If Alltrim(cEspecie) == "NF" .And. nVlrAntIt > 0 
					//Busca Documento de Anticipo
					aImpAntIt := M486ANTITM(cFilFR3, (cAliasSD)->&(cClieSD), (cAliasSD)->&(cLojaSD), (cAliasSD)->&(cDocSD), (cAliasSD)->&(cSerieSD), (cAliasSD)->&(cItemSD),lAdtCompart)
					For nJ := 1 To Len(aImpAntIt)
						aPosDocA := aScan(aDocAnt,{|x,y| x[6]+x[7]+x[8]+x[9]== aImpAntIt[nJ][3]+aImpAntIt[nJ][2]+aImpAntIt[nJ][4]+aImpAntIt[nJ][5]}) 
						For nA := 1 To Len(aDocAnt[aPosDocA][12])
							nProp := (aImpAntIt[nJ][6] / aDocAnt[aPosDocA][12][nA][10]) * aDocAnt[aPosDocA][12][nA][6]
							If aImpAux[5] == aDocAnt[aPosDocA][12][nA][4] 
								aImpAux[1] += nProp
								nPrecVar += aImpAntIt[nJ][6]
								nValmpDet += nProp
							EndIf
							If aImpAux[2] $ "10|11|12|13|14|15|16|17"  //Gravado
								cTpoAfe := "04"
							ElseIf aImpAux[2] $ "20|21"                //Exonerado
								cTpoAfe := "05"
							ElseIf aImpAux[2] $ "30|31|32|33|34|35|36" //Inafecto
								cTpoAfe := "06"
							Else
								cTpoAfe := ""
							EndIf
							If !Empty(cTpoAfe)
								nPosImp := aScan(aImpAfe,{|x,y| x[1] == cTpoAfe})
								If nPosImp == 0
									aAdd(aImpAfe,{cTpoAfe,aImpAntIt[nJ][6]})
								Else
									aImpAfe[nPosImp][2] += aImpAntIt[nJ][6]
								EndIf
							EndIf
						Next nA
					Next nJ
				EndIf

				cDesPro := M486DESPRO((cAliasSD)->&(cCodProSD))
				// PE permite personalizar, precio unitario sin impuestos, unidad de medida y cantidad
				If ExistBlock("M486DETNF") .AND. alltrim(cEspecie) == "NF"
					aM486DET	:= ExecBlock("M486DETNF",.F.,.F.,{(cAliasSD)->&(cFilialSD),(cAliasSD)->&(cDocSD),(cAliasSD)->&(cSerieSD),alltrim(cEspecie),(cAliasSD)->&(cClieSD),(cAliasSD)->&(cLojaSD),(cAliasSD)->D2_ITEM,cCodProd})
				ElseIf alltrim(cEspecie) == "NDC" .and. ExistBlock("M486DNDC")
					aM486DET	:= ExecBlock("M486DNDC",.F.,.F.,{(cAliasSD)->&(cFilialSD),(cAliasSD)->&(cDocSD),(cAliasSD)->&(cSerieSD),alltrim(cEspecie),(cAliasSD)->&(cClieSD),(cAliasSD)->&(cLojaSD),(cAliasSD)->D2_ITEM,cCodProd})
				ElseIf alltrim(cEspecie) == "NCC" .and. ExistBlock("M486DNCC")
					aM486DET	:= ExecBlock("M486DNCC",.F.,.F.,{(cAliasSD)->&(cFilialSD),(cAliasSD)->&(cDocSD),(cAliasSD)->&(cSerieSD),alltrim(cEspecie),(cAliasSD)->&(cClieSD),(cAliasSD)->&(cLojaSD),(cAliasSD)->D1_ITEM,cCodProd})
				EndIf
				If len(aM486DET) > 0
					nValUni		:= aM486DET[1] // Precio Unitario
					nQtdItem	:= aM486DET[2] // Cantidad
					cUniMed		:= aM486DET[3] // Unidad de Medida
					cDesPro		:= aM486DET[4] // Descripción del Producto
					cCodProd	:= aM486DET[5] // Código del Producto
				EndIF
				If ExistBlock("MT486AgDes") .AND. alltrim(cEspecie) $ "NF|NDC|NCC" // PE permite personalizar la Descripción del Producto
					cDesPro := ExecBlock("MT486AgDes",.F.,.F.,{(cAliasSD)->&(cCodProSD)})
				EndIf
				If alltrim(cEspecie) $ 'NCC'
					IIf(nValUni  <= 0, nValUni  := (cAliasSD)->&(cPreVtaSD) + (cAliasSD)->&(cDescSD), ) //Valor unitario
					IIf(nPrecVar <= 0, nPrecVar := (cAliasSD)->&(cTotalSD)  + (cAliasSD)->&(cDescSD), ) //Valor de venta por item

				EndIf
				nProd := aScan(aDetFac,{|x| x[1] == Val((cAliasSD)->&(cItemSD))})
				If nProd == 0
					aAdd(aDetFac,{Val((cAliasSD)->&(cItemSD)),;				//1.Item
					cUniMed,;												//2.Unidad de medida
					nQtdItem,;												//3.Cantidad
					nPrecVar,;												//4.Valor de venta por item
					nValmpDet,;												//5.Acumulado impuestos item
					nDescont,;												//6.Descuento item
					RTRIM(cDesPro),;										//7.Descripcion producto
					cCodProd,;												//8.Codigo producto
					nValUni,;												//9.Vazlor unitario
					IIF(lItemGG,0,nPrecVar/nQtdItem),;						//10.Valor Total Item
					0,;														//11.Precio de venta unitario
					IIf(lItemGrat,.T.,.F.),;								//12.Item gratuito
					aAdd(aImpos,{aImpAux}),;								//13. Arreglo impuestos de item
					(cAliasSD)->&(cDescPor),;								//14. % de descuento
					cCodprd,;												//15. código producto cat sunat
					nAliqImp})
				Else
					aDetFac[nProd][5] += nValmpDet                          	//4. Acumulado impuestos item
					aDetFac[nProd][16] := nAliqImp                          	//4. Acumulado impuestos item
					If aDetFac[nProd][4] == 0 .And. nPrecVar > 0
						aDetFac[nProd][4] := nPrecVar
					EndIf
					If lItemGrat
						aDetFac[nProd][12] := .T.
					EndIf
					If !lItemGG .And. nPrecVar > 0
						aDetFac[nProd][10] := (nPrecVar/nQtdItem)
					EndIf
					AAdd(aDetFac[nProd][13], aClone(aImpAux))				//13. Arreglo impuestos de item
				EndIf

				// Busca las guías de Remisión asociadas a los ítems de la Factura
				If alltrim(cEspecie) == "NF"
					If len(aGRFac) >0 .and. !Empty((cAliasSD)->D2_SERIREM+ (cAliasSD)->D2_REMITO)
						nPosGR := Ascan(aGRFac,{|x| x[1] + x[2] == ((cAliasSD)->D2_SERIREM + STRZERO(VAL((cAliasSD)->D2_REMITO),8) )} )
						If nPosGR == 0
							cGRClave := fGetSerSem(XFILIAL("SF2"), (cAliasSD)->D2_CLIENTE, (cAliasSD)->D2_LOJA, (cAliasSD)->D2_REMITO, (cAliasSD)->D2_SERIREM)
							aAdd(aGRFac,{(cAliasSD)->D2_SERIREM,STRZERO(VAL((cAliasSD)->D2_REMITO),8),cGRClave})
						EndIf
					ElseIf !Empty((cAliasSD)->D2_SERIREM + (cAliasSD)->D2_REMITO)
						cGRClave := fGetSerSem(XFILIAL("SF2"), (cAliasSD)->D2_CLIENTE, (cAliasSD)->D2_LOJA, (cAliasSD)->D2_REMITO, (cAliasSD)->D2_SERIREM)
						aAdd(aGRFac,{(cAliasSD)->D2_SERIREM,STRZERO(VAL((cAliasSD)->D2_REMITO),8),cGRClave})
					EndIf
				EndIf
				If nConGra == nPos .AND. nX == 1
					lGratis := .T.
				EndIf
			Next nX
			(cAliasSD)->(DbSkip())
		EndDo
	EndIf


	For nA := 1 To nPos
		For nX := 1 To Len(aImpFact)
			If aImpFact[nX][4]== "ICB"
				aDetFac[nA][11] := aDetFac[nA][10] + (aDetFac[nA][5] / aDetFac[nA][3])- aDetFac[nA][16]  //12.Precio de venta unitario (Valor Total Item + Impuesto Item / cantidad)
			Else
				aDetFac[nA][11] := aDetFac[nA][10] + (aDetFac[nA][5] / aDetFac[nA][3]) //12.Precio de venta unitario (Valor Total Item + Impuesto Item / cantidad)
			EndIf
		Next nX
	Next nA

	//Total venta (Gravada + Inafecta + Exonerada + IGV + ISC + Otros tributos)
	nTotalVta += nTotalImp
	//Se genera array con totales por tipo de operacióna
	/*
		Estructura del Array
		1. Código Cat no.5
		2. Base de la operación
		3. Valor del Impuesto para la Operación
		4. Descripción (Col 2, Cat 5)
		5. Name code (Col 3, Cat 5)
		6. Category code(Col 4, Cat 5)
	*/
	aValAdic := {{'1000',nTotGrav	,0,ObtColSAT("S005", '1000', 1, 4,48 , 3),ObtColSAT("S005",'1000', 1, 4,45, 3),''},; 	//1001-Operaciones gravadas
				 {'9998',nTotInaf	,0,ObtColSAT("S005", '9998', 1, 4,48 , 3),ObtColSAT("S005",'9998', 1, 4,45, 3),''},;  	//1002-Operaciones inafectas
				 {'9997',nTotExo	,0,ObtColSAT("S005", '9997', 1, 4,48 , 3),ObtColSAT("S005",'9997', 1, 4,45, 3),''},;  	//1003-Operaciones exoneradas
				 {'9996',nTotGrat	,IIF(nTotGrat>0,nTotImpGra,0),ObtColSAT("S005", '9996', 1, 4,48 , 3),ObtColSAT("S005",'9996', 1, 4,45, 3),''},;	//1004-Operaciones gratuitas
				 {'9995',nTotExp	,0,ObtColSAT("S005", '9995', 1, 4,48 , 3),ObtColSAT("S005",'9995', 1, 4,45, 3),''}}	//2002-Exportacion
	RestArea(aArea)
	aAux := aImpFact
	aImpFact := {}

	For nX := 1 to len(aAux)
		nPos := aScan(aImpFact,{|x,y| x[2] == aAux[nX,2]})
		If nPos > 0
			aImpFact[nPos,6] += aAux[nX,6]
		Else
			aAdd(aImpFact, aClone(aAux[nX]))
			aImpFact[Len(aImpFact)][10] := 0
		EndIf

		cTpIGV := POSICIONE("SF4",1,cFilSF4+aAux[nX][13],"F4_CALCIGV") //F4_FILIAL+F4_CODIGO
		If !(aAux[nX][3] == "I" .And. cTpIGV $ "2|3")
			aImpFact[IIf(nPos <> 0, nPos, Len(aImpFact))][10] += aAux[nX,10]
		EndIf

		If aAux[nX][3] == "I"
			nTImp += aAux[nX][6]
		EndIf
	Next nX
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³   M486REF  ³ Autor ³ Luis Enriquez         ³ Data ³ 09.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura de Referencia para XML de acuerdo al estan-³±±
±±³          ³ dar UBL 2.0 (PERU)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486REF(cEspecie,cDoc,cSerie,cCli,cLoja,cTipRef,cMotivo)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cEspecie .-  Especie del documento (NF,NDC o NCC)            ³±±
±±³          ³ cNumDoc .- Numero de documento.                              ³±±
±±³          ³ cSerie .- Serie del Documento.                               ³±±
±±³          ³ cCli .- Codigo del cliente.                                  ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±³          ³ cTipRef .- Tipo de referencia del documento. (01,02,03)      ³±±
±±³          ³ cMotivo .- Motivo de generación del documento.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXMLRef .- Nodo de referencia para XML de estandar UBL 2.0   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486NFXML - M486NDCXML - M486NCCXML                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486REF(cEspecie,cDoc,cSerie,cCli,cLoja,cTipRef,cMotivo)
	Local cAliasRef  := getNextAlias()
	Local cCampos := ""
	Local cTablas := ""
	Local cGroup := ""
	Local aReferen := {}
	Local cTpDoc := ""
	Local cTpDocA1 := ""
	Local cSerie2 := ""
	Local cEspe := ""
	Local nX     := 0
	Local cXMLRef := ""
	Local cCRLF	 := (chr(13)+chr(10))
	Local nTamDoc 	:= TamSX3("F2_DOC")[1]
	Local aArea := GetArea()
	Local cCond	:= ""
	Local cDtEmis:= "0001-01-01"
	Local lExisDoc := .T.
	Local lPERef   := ExistBlock("M486PEREF")
    Local aRefPE   := {}
	Local aGRNCC   := {}
	Local cFilSD2  := xFilial("SD2")
	Local cFilSF2  := xFilial("SF2")


    Private cNFOri   := ""
    Private cSeriOri := ""

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA

	If SA1->(dbSeek(xFilial("SA1") + cCli + cLoja))
		cTpDocA1 := SA1->A1_TIPDOC
	EndIf

	IF alltrim(cEspecie) $ 'NF|NDC'
		cCampos  := "% SD2.D2_SERIORI, SD2.D2_NFORI %"
		cTablas  := "% " + RetSqlName("SD2") + " SD2, "  + RetSqlName("SF2") + " SF2 %"
		cCond    := "% SD2.D2_DOC = '" + cDoc + "'"
		cCond    += " AND SD2.D2_SERIE = '" + cSerie + "'"
		cCond    += " AND SD2.D2_CLIENTE = '" + cCli + "'"
		cCond    += " AND SD2.D2_LOJA = '" + cLoja + "'"
        cCond	 += " AND SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
		cCond	 += " AND SD2.D_E_L_E_T_  = ' ' %"
		cGroup := "% SD2.D2_SERIORI, SD2.D2_NFORI %"

	Else
		cCampos  := "% SD1.D1_SERIORI, SD1.D1_NFORI %"
		cTablas  := "% " + RetSqlName("SD1") + " SD1 %"
		cCond    := "% SD1.D1_DOC = '" + cDoc + "'"
		cCond    += " AND SD1.D1_SERIE = '" + cSerie + "'"
		cCond    += " AND SD1.D1_FORNECE = '" + cCli + "'"
		cCond    += " AND SD1.D1_LOJA = '" + cLoja + "'"
	    cCond	 += " AND SD1.D1_FILIAL = '" + xFilial("SD1") + "'"
		cCond	 += " AND SD1.D_E_L_E_T_  = ' ' %"
		cGroup := "% SD1.D1_SERIORI, SD1.D1_NFORI %"
	EndIf

	BeginSql alias cAliasRef
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		GROUP BY %exp:cGroup%
	EndSql

	dbSelectArea(cAliasRef)

	(cAliasRef)->(DbGoTop())

	While (cAliasRef )->(!Eof())
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		cNFOri 	:= IIf(alltrim(cEspecie) $ 'NF|NDC',(cAliasRef)->D2_NFORI, (cAliasRef)->D1_NFORI)
		cSeriOri:= IIf(alltrim(cEspecie) $ 'NF|NDC',(cAliasRef)->D2_SERIORI, (cAliasRef)->D1_SERIORI)
		lExis  := .T.
		aRefPE := {}
		If SF2->(dbSeek(xFilial("SF2")+ cNfori + cSeriori + cCli + cLoja))
			cSerie2 := SF2->F2_SERIE2
			cEspe 	:= alltrim(SF2->F2_ESPECIE)
			cDtEmis	:= STRZERO(YEAR(SF2->F2_EMISSAO),4) + "-" + STRZERO(MONTH(SF2->F2_EMISSAO),2) + "-" + STRZERO(DAY(SF2->F2_EMISSAO),2)
		Else
			cDtEmis := M486getEmi( cFilSF2 , cNfori , cSeriori , cCli , cLoja, "NF ")
			If alltrim(cEspecie) $ "NDC"
				SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
				If SFP->(DBSEEK(XFILIAL("SFP")+xFilial("SF2")+cSeriori+'1'))
					cSerie2:= SFP->FP_SERIE2
				Else
					cSerie2:= ''
				EndIf
				cEspe := "NF"
			Else
				cSerie2 := ""
				cEspe := ""
				lExis := .F.
			EndIf
		EndIf

		If cEspe $ 'NF' .AND. Substr(cSerie2,1,1) $ 'F'  // Factura
			cTpDoc := '01'
		ElseIf cEspe $ 'NF' .AND. Substr(cSerie2,1,1) $ 'B' .AND. cTpDocA1 <> "06"  // Boleta de Venta
			cTpDoc := '03'
		EndIf
		If !lExis .And. lPERef
			aRefPE := ExecBlock("M486PEREF",.F.,.F.,{cEspecie,cDoc,cSerie,cCli,cLoja})
			aAdd(aReferen,{aRefPE[1],aRefPE[2],aRefPE[3],aRefPE[4]})
		Else
			aAdd(aReferen,{RTRIM(cSerie2),RTRIM(cNFOri),cTpDoc,cDtEmis})
		EndIf

		If Alltrim(cEspecie) $ "NCC"
			M486REM(cFilSD2,cNfori,cSeriori,cCli,cLoja,@aGRNCC)
		EndIf
		(cAliasRef)->(dbskip())
	EndDo
	//Referencia
	//DiscrepancyResponse
	For nX := 1 To Len(aReferen)
		If nX == 1
			cXMLRef += '	<cac:DiscrepancyResponse>' + cCRLF
			If Len(aReferen) == 1
				cXMLRef += '		<cbc:ReferenceID>' + aReferen[nX][1] + '-' + ALLTRIM(STRZERO(VAL(aReferen[nX][2]),8)) + '</cbc:ReferenceID>' + cCRLF
			EndIf
		    cXMLRef += '		<cbc:ResponseCode>' + cTipRef + '</cbc:ResponseCode>' + cCRLF
		    cXMLRef += '		<cbc:Description><![CDATA[' + EncodeUtf8(cMotivo) + ']]></cbc:Description>' + cCRLF
		    cXMLRef += '	</cac:DiscrepancyResponse>' + cCRLF
		Else
			Exit
	    EndIf
    Next nX
    //BillingReference
	For nX := 1 To Len(aReferen)
	    cXMLRef += '	<cac:BillingReference>' + cCRLF
	    cXMLRef += '		<cac:InvoiceDocumentReference>' + cCRLF
	    cXMLRef += '			<cbc:ID>' + aReferen[nX][1] + '-' + ALLTRIM(STRZERO(VAL(aReferen[nX][2]),8))  + '</cbc:ID>' + cCRLF
	    cXMLRef += '			<cbc:IssueDate>' + aReferen[nX][4] + '</cbc:IssueDate>'  + cCRLF
	    cXMLRef += '			<cbc:DocumentTypeCode>' + aReferen[nX][3] + '</cbc:DocumentTypeCode>' + cCRLF
	    cXMLRef += '		</cac:InvoiceDocumentReference>' + cCRLF
	    cXMLRef += '	</cac:BillingReference>' + cCRLF
    Next nX
	// -------------------Guías de Remisión relacionadas a la NF ------------------------
	For nX := 1 to len(aGRNCC)
		cXMLRef += '	<cac:DespatchDocumentReference>' + cCRLF
		cXMLRef += '	   <cbc:ID>' + aGRNCC[nX,3]+"-"+aGRNCC[nX,2]+ '</cbc:ID>'+ cCRLF
		cXMLRef += '	   <cbc:DocumentTypeCode>09</cbc:DocumentTypeCode>'+ cCRLF
		cXMLRef += '	</cac:DespatchDocumentReference>'	 + cCRLF
	Next nI
    RestArea(aArea)
Return cXMLRef

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486UNIMED ³ Autor ³ Luis Enriquez         ³ Data ³ 09.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene codigo de certificado origen de tabla de unidades de ³±±
±±³          ³ medida (PERU)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486UNIMED(cUniMed)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cUniMed .-  Clave de unidad de medida.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cUMSAH .- Cod. Certificacion origen de SAH.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486NFXML - M486NDCXML - M486NCCXML                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486UNIMED(cUniMed)
	Local cUMSAH := ""
	Local aArea := getArea()
	dbSelectArea("SAH")
	SAH->(dbSetOrder(1)) //AH_FILIAL+AH_UNIMED
	If SAH->(dbSeek(xFilial("SAH") + cUniMed))
		cUMSAH := SAH->AH_COD_CO
	EndIf
	RestArea(aArea)
Return cUMSAH

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486TIPIGV ³ Autor ³ Luis Enriquez         ³ Data ³ 09.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene tipo de IGV configurada para impuesto en tipo de en- ³±±
±±³          ³ trada salida (PERU)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486TIPIGV(cTes,cImp)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTes .-  Tipo de entrada/salida.                             ³±±
±±³          ³ cImp .-  Código de impuesto.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cTipoIGV .- Tipo de IGV configurado para el impuesto en tipo ³±±
±±³          ³ de entrada/salida                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486NFXML - M486NDCXML - M486NCCXML                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M486TIPIGV(cTes,cImp)
	Local cTipoIGV := ""
	Local aArea 	:= getArea()
	dbSelectArea("SFC")
	SFC->(dbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
	If SFC->(dbSeek(xFilial("SFC") + cTes + cImp))
		cTipoIGV := SFC->FC_TIPOIGV
	EndIf
	RestArea(aArea)
Return cTipoIGV

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486TIPISC ³ Autor ³ Luis Enriquez         ³ Data ³ 09.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene tipo de ISC configurada para impuesto en tipo de en- ³±±
±±³          ³ trada salida (PERU)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486TIPISC(cTes,cImp)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTes .-  Tipo de entrada/salida.                             ³±±
±±³          ³ cImp .-  Código de impuesto variable                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cTipoISC .- Tipo de ISC configurado para el impuesto en tipo ³±±
±±³          ³ de entrada/salida                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486NFXML - M486NDCXML - M486NCCXML                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M486TIPISC(cTes, cImp)
	Local cTipoISC := ""
	Local aArea 	:= getArea()
	dbSelectArea("SFC")
	SFC->(dbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
	If SFC->(dbSeek(xFilial("SFC") + cTes + cImp))
		cTipoISC := SFC->FC_TIPOISC
	EndIf
	RestArea(aArea)
Return cTipoISC

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486DESPRO ³ Autor ³ Luis Enriquez         ³ Data ³ 09.06.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene codigo de certificado origen de tabla de unidades de ³±±
±±³          ³ medida (PERU)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486DESPRO(cCodPro)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodPro .-  Codigo de Producto.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cDesProd .- Descuento del producto                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486XMLIMP                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M486DESPRO(cCodPro)
	Local cDesProd := ""
	Local aArea 	:= getArea()
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
	If SB1->(dbSeek(xFilial("SB1") + cCodPro))
		cDesProd := SB1->B1_DESC
	EndIf
	RestArea(aArea)
Return cDesProd

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486MODS2 ³ Autor ³ Mayra Camargo          ³ Data ³ 11.07.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Indica si existen registros en SF1/SF2 para una serie 2 dada ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486MODS2(cSer2)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cSer2 .-  Serie 2 a consultar.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet .- retorna T si no encontró registros para la serie 2.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486XMLIMP                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function M486MODS2(cSer2)
	Local lRet 	:= .T.
	Local aArea 	:= getArea()
	Local cTmp	:= getNextAlias()
	Local nCount 	:= 0

	If !Empty(cSer2)
		BeginSql alias cTmp
			SELECT COUNT(F2_SERIE2) NUM
			FROM  %table:SF2% SF2
			WHERE F2_FILIAL = %exp:xfilial("SF2")%
			AND F2_SERIE2 = %exp:cSer2%
			AND SF2.%notDel%
			UNION
			SELECT COUNT(F1_SERIE2) NUM
			FROM  %table:SF1% SF1
			WHERE F1_FILIAL = %exp:xfilial("SF1")%
			AND F1_SERIE2 = %exp:cSer2%
			AND SF1.%notDel%
		EndSql

		While (!(cTmp)->(EOF()))
			nCount += (cTmp)->NUM
			(cTmp)->(dbskip())
		EndDo

		lRet := (nCount == 0)
	EndIf
	RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fCero2Text ³ Autor ³ Mayra Camargo       ³ Data ³ 11.01.18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Coloca moneda a texto para valor 0                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCero2Text(nPar01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NFAEXMLPER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fCero2Text(nMdn)
	Local cText 		:= ""
	Local cIdMoedaS 	:= GetMV("MV_MOEDA" + AllTrim(Str(nMdn)))
	Default nMdn:= 1

	cText := "CERO " + cIdMoedaS + " Y 0 CENTAVOS"

Return cText

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fGetTaxas  ³ Autor ³ Jonathan Gonzalez ³ Data ³ 26.04.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Función para generar los Nodos TaxTotal y LegalMonetaryTotal³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGetTaxas(cPar01, cPar02, cPar03, cPar04)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ { cPar01 , cPar01 }                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FATSCOL.INI                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fGetTaxas(cDOC, cSERIE, cCLIENTE, cLOJA, cEspecie )
Local aArea  	:= GetArea()
Local aImp   	:= {}
Local cTmp   	:= getNextAlias()
Local cTaxas 	:= ""
Local cLegal 	:= ""
Local cSalto 	:= (chr(13)+chr(10))
Local cMoeda 	:= ""
Local nX		:= 0
Local nImp   	:= 0
Local nPos		:= 0
Local nBaseImp	:= 0
Local nValImp	:= 0
Local lTpDocNC	:= !(ALLTRIM(cEspecie) $ "NCC|NDP")
Local cTabDet 	:= IIF(lTpDocNC, "SD2","SD1")
Local nDetOrd	:= IIF(lTpDocNC, 3,1)
Local cPref		:= IIF(lTpDocNC, "D2_","D1_")
Local nTotal	:= 0
Local nValMerc	:= 0
Local nDescto	:= 0
Local cCF		:= ""
Local nY		:= 0
Local aRetFte	:= {}
Local aImpAux	:= {}
Local aImpVRet  := {}
Local nValTaxA  := 0
Local cIDImp    := ""
Local lDif      := .T.
Local nConEnc   := 0
Local cImpMil   := SuperGetMV("MV_IMPMILL",,"")
Local nDesPor   := 2
Local nTasa     := 0
Local nBaseITot := 0
Local aBases    := {}
Local cItem     := ""
// Códigos fiscales por tipo de retención de la fuente
aAdd( aRetFte , { SuperGetMV("MV_RETF053",,"") , "053" } )
aAdd( aRetFte , { SuperGetMV("MV_RETF055",,"") , "055" } )
aAdd( aRetFte , { SuperGetMV("MV_RETF056",,"") , "056" } )
aAdd( aRetFte , { SuperGetMV("MV_RETF057",,"") , "057" } )

cEspecie := ALLTRIM(cEspecie)

	If cEspecie $ "NF/NDC/NCP"
		BeginSql alias cTmp
			SELECT FB_CODIGO,FB_ALIQ,FB_IMPSAT,FB_CPOLVRO,FB_CLASSE,FC_TES,FC_INCDUPL
			FROM %table:SFB% SFB INNER JOIN %table:SFC% SFC ON FB_CODIGO=FC_IMPOSTO
			WHERE FB_FILIAL = %exp:xfilial("SFB")%
			AND FC_FILIAL = %exp:xfilial("SFC")%
			AND SFC.%notDel%
			AND SFB.%notDel%
			AND SFC.FC_TES IN (
				SELECT SD2.D2_TES FROM %table:SD2% SD2
				WHERE SD2.D2_FILIAL = %exp:xfilial("SD2")%
					AND SD2.D2_DOC =  %exp:cDOC%
					AND SD2.D2_SERIE =  %exp:cSERIE%
					AND SD2.D2_CLIENTE = %exp:cCLIENTE%
					AND SD2.D2_LOJA = %exp:cLOJA%
					AND SD2.%notDel%
				GROUP BY SD2.D2_TES
			)
		EndSql
	ElseIf cEspecie $ "NCC|NDP"
		BeginSql alias cTmp
			SELECT FB_CODIGO,FB_ALIQ,FB_IMPSAT,FB_CPOLVRO,FB_CLASSE,FC_TES,FC_INCDUPL
			FROM %table:SFB% SFB INNER JOIN %table:SFC% SFC ON FB_CODIGO=FC_IMPOSTO
			WHERE FB_FILIAL = %exp:xfilial("SFB")%
			AND FC_FILIAL = %exp:xfilial("SFC")%
			AND SFC.%notDel%
			AND SFB.%notDel%
			AND SFC.FC_TES IN (
				SELECT SD1.D1_TES FROM %table:SD1% SD1
				WHERE SD1.D1_FILIAL = %exp:xfilial("SD1")%
					AND SD1.D1_DOC =  %exp:cDOC%
					AND SD1.D1_SERIE =  %exp:cSERIE%
					AND SD1.D1_FORNECE = %exp:cCLIENTE%
					AND SD1.D1_LOJA = %exp:cLOJA%
					AND SD1.%notDel%
				GROUP BY SD1.D1_TES
			)
		EndSql
	EndIf

	dbSelectArea(cTmp)
	(cTmp)->(DbGoTop())
	While (!(cTmp)->(EOF()))
		/*
		Estructura de aImp
		1. Libro Fiscal
		2. Código Impuesto DIAN
		3. Clase de Impuest
		4. Alícuota
		5. Código Impuesto
		6. TES
		7. Base Impuesto
		8. Total Impuesto
		9. 1+, 2-, 3 (Indiferente [Auto-Retención 0A-ZZZ | Impuesto incluido en precio])
		*/
		AADD( aImp , { (cTmp)->FB_CPOLVRO, (cTmp)->FB_IMPSAT, (cTmp)->FB_CLASSE, (cTmp)->FB_ALIQ, (cTmp)->FB_CODIGO, (cTmp)->FC_TES, 0.00, 0.00, FC_INCDUPL })
		(cTmp)->(dbskip())
	EndDo

	(cTmp)->(dbCloseArea())

	If cEspecie $ "NF/NDC/NCP"
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		SF2->(dbSeek(xFilial("SF2")+ cDOC + cSERIE + cCLIENTE + cLOJA))
		nValMerc := SF2->F2_VALMERC
		nTotal := SF2->F2_VALMERC
		nDescto := SF2->F2_DESCONT
	Else
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		SF1->(dbSeek(xFilial("SF1")+ cDOC + cSERIE + cCLIENTE + cLOJA))
		nValMerc := SF1->F1_VALMERC
		nTotal := SF1->F1_VALMERC
		nDescto := SF1->F1_DESCONT
	EndIf

	CTO->(DbSetOrder(1))
	CTO->(dbSeek(xFilial("CTO")+Strzero(SF2->F2_MOEDA,2)))
	cMoeda := ALLTRIM(Posicione("CTO",1,xFilial("CTO")+Strzero(SF2->F2_MOEDA,2),"CTO_MOESAT"))

	dbSelectArea(cTabDet)
	// Para SF2: D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	// Para SF1: D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	&(cTabDet)->(dbSetOrder(nDetOrd))

	If &(cTabDet)->(DbSeek(xFilial(cTabDet)+cDOC + cSERIE + cCLIENTE + cLOJA),.t.)
		While (!&(cTabDet)->(EOF())).and. (cTabDet)->&(cPref+"FILIAL")+&(cPref+"DOC")+&(cPref+"SERIE")+ IIF(lTpDocNC,&("D2_CLIENTE"), &("D1_FORNECE"))+&(cPref+"LOJA") == xFilial(cTabDet)+cDOC + cSERIE + cCLIENTE + cLOJA
			For nX := 1 To Len(aImp)
				nBaseImp:= (cTabDet)->&(cPref+"BASIMP" + aImp[nX,1])
				nValImp :=  (cTabDet)->&(cPref+"VALIMP" + aImp[nX,1])
				cItem   :=  (cTabDet)->&(cPref+"ITEM")
				If  ((cTabDet)->&(cPref+"TES") == aImp[nX,6]) .and. (nBaseImp > 0 .or. nValImp > 0)
					aImp[nX,7] += nBaseImp
					aImp[nX,8] += nValImp

					If Alltrim( aImp[nX,2] ) == "05"
						cCF := Alltrim( (cTabDet)->&(cPref+"CF") )
						For nY := 1 to Len(aRetFte)
							If cCF $ aRetFte[nY][1]
								aImp[nX,2] := aRetFte[nY][2]
								Exit
							Endif
						Next nY
					EndIf

					aImp[nX,4] := (cTabDet)->&(cPref+"ALQIMP" + aImp[nX,1])

					//Acumulado de impuestos
					If aImp[nX,3] == "I"
						If Len(aImpAux) > 0
							nPos := Ascan(aImpAux,{|x| x[2] == aImp[nX,2] .and. x[5] == aImp[nX,5]} )
							If nPos == 0
								aAdd(aImpAux,{aImp[nX,1],aImp[nX,2],aImp[nX,3],aImp[nX,4],aImp[nX,5],aImp[nX,6],aImp[nX,7],aImp[nX,8],aImp[nX,9]})
							Else
								aImpAux[nPos,7] += nBaseImp
								aImpAux[nPos,8] += nValImp
							EndIf
						Else
							aAdd(aImpAux,{aImp[nX,1],aImp[nX,2],aImp[nX,3],aImp[nX,4],aImp[nX,5],aImp[nX,6],aImp[nX,7],aImp[nX,8],aImp[nX,9]})
						EndIf
						//Base imponible
						nPos := aScan(aBases,{|x| x[1] == nBaseImp .And. x[2] == cItem } )
						If nPos == 0
							aAdd(aBases, {nBaseImp, cItem})
						EndIf
					ElseIf aImp[nX,3] == "R"
						If Len(aImpVRet) > 0
							nPos := Ascan(aImpVRet,{|x| x[2] == aImp[nX,2] .and. x[5] == aImp[nX,5]} )
							If nPos == 0
								aAdd(aImpVRet,{aImp[nX,1],aImp[nX,2],aImp[nX,3],aImp[nX,4],aImp[nX,5],aImp[nX,6],aImp[nX,7],aImp[nX,8],aImp[nX,9]})
							Else
								aImpVRet[nPos,7] += nBaseImp
								aImpVRet[nPos,8] += nValImp
							EndIf
						Else
							aAdd(aImpVRet,{aImp[nX,1],aImp[nX,2],aImp[nX,3],aImp[nX,4],aImp[nX,5],aImp[nX,6],aImp[nX,7],aImp[nX,8],aImp[nX,9]})
						EndIf
					EndIf
				EndIf

			Next nX
			(cTabDet)->(dbskip())
		EndDo
	EndIf

	//Impuestos
	ASort(aImpAux,,,{|x,y| x[2] < y[2]})
	If Len(aImpAux) > 0
		For nX := 1 To Len(aImpAux)
			If aImpAux[nX,3] == "I"
				nConEnc += 1
				lDif := cIDImp <> aImpAux[nX,2]
				If lDif
					If nX > 1
						cTaxas += '	</fe:TaxTotal>'  + cSalto
					EndIf
					cTaxas += '	<fe:TaxTotal>'  + cSalto
				    nValTaxA := 0
					AEval(aImpAux, {|x,y| IIf(Alltrim(aImpAux[y][2]) == Alltrim(aImpAux[nX,2]),nValTaxA += aImpAux[y][8],.T.)})
					cTaxas += '		<cbc:TaxAmount currencyID="'+ cMoeda +'">'+  Alltrim(Str(nValTaxA,14,2)) +'</cbc:TaxAmount>'  + cSalto
					cTaxas += '		<cbc:TaxEvidenceIndicator>false</cbc:TaxEvidenceIndicator>'  + cSalto
					cIDImp := aImpAux[nX,2]
				EndIf
				cTaxas += '		<cac:TaxSubtotal>'  + cSalto
				cTaxas += '			<cbc:TaxableAmount currencyID="'+ cMoeda +'">'+ Alltrim(STR(aImpAux[nX,7],14,2))  +'</cbc:TaxableAmount>'  + cSalto
				cTaxas += '			<cbc:TaxAmount currencyID="'+ cMoeda +'">'+ Alltrim(STR(aImpAux[nX,8],14,2)) +'</cbc:TaxAmount>'  + cSalto
				nDesPor := IIf(!Empty(cImpMil) .And. Alltrim(aImpAux[nX,5]) $ cImpMil, 3, 2)
				nTasa   := IIf(!Empty(cImpMil) .And. Alltrim(aImpAux[nX,5]) $ cImpMil, aImpAux[nX,4]/10, aImpAux[nX,4])
				cTaxas += '			<cbc:Percent>'+ Alltrim(STR(nTasa,14,nDesPor))+'</cbc:Percent>'  + cSalto
				cTaxas += '			<cac:TaxCategory>'  + cSalto
				cTaxas += '				<cac:TaxScheme>'  + cSalto
				cTaxas += '					<cbc:ID>'+ Alltrim(aImpAux[nX,2]) +'</cbc:ID>'  + cSalto
				cTaxas += '				</cac:TaxScheme>'  + cSalto
				cTaxas += '			</cac:TaxCategory>'  + cSalto
				cTaxas += '		</cac:TaxSubtotal>'  + cSalto

				If aImpAux[nX,9] == "1" .Or. (aImpAux[nX,9] == "3" .And. !EsAutoReten(aImpAux[nX,2]))
					nImp += aImpAux[nX,8]
				ElseIf aImpAux[nX,9] == "2"
					nImp -= aImpAux[nX,8]
				EndIf
				If cIDImp <> aImpAux[nX,2]
					cTaxas += '	</fe:TaxTotal>'+ cSalto
				EndIf
			EndIf
		Next nX
		If nConEnc > 0
			cTaxas += '	</fe:TaxTotal>'+ cSalto
		EndIf
	EndIf

	//Retenciones
	ASort(aImpVRet,,,{|x,y| x[2] < y[2]})
	If Len(aImpVRet) > 0
		For nX := 1 To Len(aImpVRet)
			If aImpVRet[nX,3] == "R"
				nConEnc += 1
				lDif := cIDImp <> aImpVRet[nX,2]
				If lDif
					If nX > 1
						cTaxas += '	</fe:WithholdingTaxTotal>'  + cSalto
					EndIf
					cTaxas += '	<fe:WithholdingTaxTotal>'  + cSalto
				    nValTaxA := 0
					AEval(aImpVRet, {|x,y| IIf(Alltrim(aImpVRet[y][2]) == Alltrim(aImpVRet[nX,2]),nValTaxA += aImpVRet[y][8],.T.)})
					cTaxas += '		<cbc:TaxAmount currencyID="'+ cMoeda +'">'+  Alltrim(Str(nValTaxA,14,2)) +'</cbc:TaxAmount>'  + cSalto
					cTaxas += '		<cbc:TaxEvidenceIndicator>false</cbc:TaxEvidenceIndicator>'  + cSalto
					cIDImp := aImpVRet[nX,2]
				EndIf
				cTaxas += '		<cac:TaxSubtotal>'  + cSalto
				cTaxas += '			<cbc:TaxableAmount currencyID="'+ cMoeda +'">'+ Alltrim(STR(aImpVRet[nX,7],14,2))  +'</cbc:TaxableAmount>'  + cSalto
				cTaxas += '			<cbc:TaxAmount currencyID="'+ cMoeda +'">'+ Alltrim(STR(aImpVRet[nX,8],14,2)) +'</cbc:TaxAmount>'  + cSalto
				nDesPor := IIf(!Empty(cImpMil) .And. Alltrim(aImpVRet[nX,5]) $ cImpMil, 3, 2)
				nTasa   := IIf(!Empty(cImpMil) .And. Alltrim(aImpVRet[nX,5]) $ cImpMil, aImpVRet[nX,4]/10, aImpVRet[nX,4])
				cTaxas += '			<cbc:Percent>'+ Alltrim(STR(nTasa,14,nDesPor))+'</cbc:Percent>'  + cSalto
				cTaxas += '			<cac:TaxCategory>'  + cSalto
				cTaxas += '				<cac:TaxScheme>'  + cSalto
				cTaxas += '					<cbc:ID>'+ Alltrim(aImpVRet[nX,2]) +'</cbc:ID>'  + cSalto
				cTaxas += '				</cac:TaxScheme>'  + cSalto
				cTaxas += '			</cac:TaxCategory>'  + cSalto
				cTaxas += '		</cac:TaxSubtotal>'  + cSalto

				If cIDImp <> aImpVRet[nX,2]
					cTaxas += '	</fe:WithholdingTaxTotal>'+ cSalto
				EndIf
			EndIf
		Next nX
		If nConEnc > 0
			cTaxas += '	</fe:WithholdingTaxTotal>'+ cSalto
		EndIf
	EndIf

	For nX := 1 To Len(aBases)
		nBaseITot += aBases[nX,1]
	Next nX
	cLegal += '	<fe:LegalMonetaryTotal>'  + cSalto
	cLegal += '		<cbc:LineExtensionAmount currencyID="'+ cMoeda +'">'+ Alltrim(STR(nValMerc,14,2)) +'</cbc:LineExtensionAmount>'  + cSalto
	nTotal += (IIf(nImp >0, nImp, 0))
	If nBaseITot > 0
		cLegal += '		<cbc:TaxExclusiveAmount currencyID="'+ cMoeda +'">'+ Alltrim(STR( nBaseITot ,14,2)) +'</cbc:TaxExclusiveAmount>'  + cSalto
	EndIf
	cLegal += '		<cbc:PayableAmount currencyID="'+ cMoeda +'">'+ Alltrim(STR(nTotal,14,2)) +'</cbc:PayableAmount>'  + cSalto
	If nDescto > 0
		cLegal += '		<cbc:AllowanceTotalAmount currencyID="'+ cMoeda +'">'+ Alltrim(STR(nDescto,14,2)) +'</cbc:AllowanceTotalAmount>'  + cSalto
	EndIf
	cLegal += '	</fe:LegalMonetaryTotal>'

RestArea(aArea)
Return { cTaxas , cLegal }

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³EsAutoReten ³ Autor ³ A Rodriguez       ³ Data ³ 09/10/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Determina si el codigo DIAN es auto-retencion              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EsAutoReten( cCodigo )                                     ³±±
±±³          ³ 00 - 99 = Impuestos o retenciones                          ³±±
±±³          ³ 0A - ZZZ o vacio = [Auto]Retenciones informativas          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet - Es auto-retencion                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486XFUN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function EsAutoReten( cCodigo )
Return (Empty(cCodigo) .Or. !(Substr(cCodigo,1,1) $ "0123456789" .And. Substr(cCodigo,2,1) $ "0123456789") .And. !(cCodigo == "ZZ"))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GetCUFE    ³ Autor ³ Jonathan Gonzalez ³ Data ³ 03.05.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Función para generar el CUFE                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetCUFE(cPar01, cPar02, cPar03, cPar04)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ { cPar01 , cPar01 }                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FATSCOL.INI                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GetCUFE(cDOC, cSERIE, cCLIENTE, cLOJA, cEMISSAO, cHORA, cFILIAL , cESPECIE, cSERIE2, cNIT )
Local aArea   := GetArea()
Local aImp    := {}
Local cTmp    := getNextAlias()
Local nX      := 0
Local nImp1   := 0.00
Local nImp2   := 0.00
Local nImp3   := 0.00
Local cImp1   := ""
Local cImp2   := ""
Local cImp3   := ""
Local cCUFE   := ""
Local cTipAdq := ""
Local cClave  := ""
Local cTipo   := ""

	BeginSql alias cTmp
		SELECT * FROM %table:SFB% SFB
		WHERE FB_FILIAL = %exp:xfilial("SFB")%
			AND FB_CODIGO IN (
				SELECT FC_IMPOSTO FROM %table:SFC%  SFC
				WHERE  FC_FILIAL = %exp:xfilial("SFC")%
					AND FC_TES IN (
						SELECT D2_TES FROM %table:SD2% SD2
						WHERE D2_FILIAL = %exp:xfilial("SD2")%
							AND D2_DOC =  %exp:cDOC%
							AND D2_SERIE =  %exp:cSERIE%
							AND D2_CLIENTE = %exp:cCLIENTE%
							AND D2_LOJA = %exp:cLOJA%
							AND SD2.%notDel%
						GROUP BY D2_TES
					)
					AND SFC.%notDel%
				GROUP BY FC_IMPOSTO
			)
			AND SFB.%notDel%
	EndSql

	dbSelectArea(cTmp)
	(cTmp)->(DbGoTop())
	While (!(cTmp)->(EOF()))
		AADD( aImp , { (cTmp)->FB_CPOLVRO, (cTmp)->FB_IMPSAT } )
		(cTmp)->(dbskip())
	EndDo

	dbSelectArea("SF2")
	SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	SF2->(dbSeek(xFilial("SF2")+ cDOC + cSERIE + cCLIENTE + cLOJA))

	For nX := 1 To Len(aImp)
		Do Case
			Case ALLTRIM(aImp[nX][2]) == "01"
				nImp1 += SF2->&("F2_VALIMP" + aImp[nX][1])
				cImp1 := ALLTRIM(aImp[nX][2])

			Case ALLTRIM(aImp[nX][2]) == "02"
				nImp2 += SF2->&("F2_VALIMP" + aImp[nX][1])
				cImp3 := ALLTRIM(aImp[nX][2])

			Case ALLTRIM(aImp[nX][2]) == "03"
				nImp3 += SF2->&("F2_VALIMP" + aImp[nX][1])
				cImp3 :=  ALLTRIM(aImp[nX][2])
		EndCase
	Next

	dbSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIL + A1_COD + A1_LOJA
	If SA1->(DbSeek(xFilial("SA1")+cCLIENTE+cLOJA))
		cTipAdq := ""
	EndIF

	Do Case
		Case ALLTRIM(cESPECIE) == "NF"
			cTipo := "1"

		Case ALLTRIM(cESPECIE) == "NCC"
			cTipo := "2"

		Case ALLTRIM(cESPECIE) == "NDC"
			cTipo := "3"

		Case ALLTRIM(cESPECIE) == "NDI"
			cTipo := "4"

		Case ALLTRIM(cESPECIE) == "NCI"
			cTipo := "5"
	EndCase

	DbSelectArea("SFP")
	SFP->(DbSetOrder(5)) //FP_FILIAL + FP_FILUSO + FP_SERIE + FP_ESPECIE
	If SFP->(DbSeek(xFilial("SFP") + cFILIAL + cSERIE + cTipo ))
		cClave := ALLTRIM(SFP->FP_NRCERT)
	EndIf

	//Num. Factura
	cCUFE := cSERIE2 + ALLTRIM( substr( cDOC , 4 , 10 ) )

	//Fecha y Hora.
	cCUFE += SubStr(cEMISSAO,1,4) + SubStr(cEMISSAO,7,2)+ SubStr(cEMISSAO,5,2)+ (SubStr(cHORA,1,2) + SubStr(cHORA,4,2) + "00")

	//Valor FActura(Val. Merc)
	cCUFE += Alltrim(STR(SF2->F2_VALMERC,14,2))

	//CodImp1 + ValImp1
	cCUFE +=  cImp1 + Alltrim(STR(nImp1,14,2))

	//CodImp2 + ValImp2
	cCUFE += cImp2 + Alltrim(STR(nImp2,14,2))

	//CodImp3 + ValImp3
	cCUFE += cImp3 + Alltrim(STR(nImp3,14,2))

	//ValPag
	cCUFE += Alltrim(STR(SF2->F2_VALBRUT,14,2))

	//NIT Facturador
	cCUFE += cNIT

	//Tipo Adquiriente
	cCUFE += cTipAdq

	//Numero Adquiriente
	cCUFE += AllTrim(SA1->A1_CGC)

	//Clave Tecnica
	cCUFE += cClave

	cCUFE := SHA1( cCUFE )
	// Graba CUFE en SF2
	RecLock("SF2",.F.)
		SF2->F2_UUID := cCUFE
	SF2->(MsUnlock())
	(cTmp)->(dbCloseArea())
    RestArea(aArea)
Return cCUFE


/*/{Protheus.doc} fGetRef
Genera Elemento BillingReference para NDC/NCC Colombia
@type function
@author mayra.camargo
@since 16/05/2018
@version 1.0
@param cDoc, character,Documento
@param cSerie,character, Serie
@param cCli,character, Cliente
@param cLoja, character, Tienda
@param cEspecie, character, Especie del Documento NDC o NCC
@return cXMLRef, cadena XML con los datos de la NF de referencia
/*/
Function fGetRef(cDoc,cSerie,cCli,cLoja,cEspecie,cTipNota)
	Local aArea := GetArea()
	Local cAliasRef  := getNextAlias()
	Local cAliasSF   := getNextAlias()
	Local cCampos := ""
	Local cTablas := ""
	Local cGroup := ""
	Local aReferen := {}
	Local cTpDoc := ""
	Local cTpDocA1 := ""
	Local cSerie2 := ""
	Local cEspe := ""
	Local cNFOri  := ""
	Local cSeriOri := ""
	Local nX     := 0
	Local cXMLRef := ""
	Local cCRLF	 := (chr(13)+chr(10))
	Local nTamDoc 	:= TamSX3("F2_DOC")[1]
	Local dDtEmis := CTOD(" / / ")
	Local cHrEmis := ""
	Local cCond	:= ""
	Local nPos := 0
	Local cUUID := ""
	Local cCamposSF := "% SF2.F2_SERIE2, SF2.F2_ESPECIE, SF2.F2_EMISSAO EMISSAO, SF2.F2_HORA, SF2.F2_UUID %"
	Local cTablasSF := "% " + RetSqlName("SF2") + " SF2 %"
	Local cCondSF   := ""
	Local nCount := 0
	DEFAULT cTipNota := ""
	
	If alltrim(cEspecie) $ 'NCP|NDP' // Nota Ajuste NCP	NDP
		cCamposSF := "% SF1.F1_SERIE2, SF1.F1_ESPECIE, SF1.F1_EMISSAO EMISSAO, SF1.F1_HORA, SF1.F1_UUID %"
		cTablasSF := "% " + RetSqlName("SF1") + " SF1 %"
	EndIf

	IF alltrim(cEspecie) $ 'NF|NDC|NCP'
		cCampos	:= "% SD2.D2_SERIORI, SD2.D2_NFORI %"
		cTablas	:= "% " + RetSqlName("SD2") + " SD2, "  + RetSqlName("SF2") + " SF2 %"
		cCond  	:= "% SD2.D2_DOC = '" + cDoc + "'"
		cCond  	+= " AND SD2.D2_SERIE = '" + cSerie + "'"
		cCond  	+= " AND SD2.D2_CLIENTE = '" + cCli + "'"
		cCond  	+= " AND SD2.D2_LOJA = '" + cLoja + "'"
      	cCond	+= " AND SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
		cCond	+= " AND SD2.D_E_L_E_T_  = ' ' %"
		cGroup 	:= "% SD2.D2_SERIORI, SD2.D2_NFORI %"
	Else
		cCampos	:= "% SD1.D1_SERIORI, SD1.D1_NFORI %"
		cTablas	:= "% " + RetSqlName("SD1") + " SD1 %"
		cCond  	:= "% SD1.D1_DOC = '" + cDoc + "'"
		cCond  	+= " AND SD1.D1_SERIE = '" + cSerie + "'"
		cCond  	+= " AND SD1.D1_FORNECE = '" + cCli + "'"
		cCond  	+= " AND SD1.D1_LOJA = '" + cLoja + "'"
	   	cCond	+= " AND SD1.D1_FILIAL = '" + xFilial("SD1") + "'"
		cCond 	+= " AND SD1.D_E_L_E_T_  = ' ' %"
		cGroup := "% SD1.D1_SERIORI, SD1.D1_NFORI %"
	EndIf

	BeginSql alias cAliasRef
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		GROUP BY %exp:cGroup%
	EndSql

	dbSelectArea(cAliasRef)
	(cAliasRef)->(DbGoTop())

	While (cAliasRef)->(!Eof())
		cNFOri 	:= IIf(alltrim(cEspecie) $ 'NF|NDC|NCP',(cAliasRef)->D2_NFORI, (cAliasRef)->D1_NFORI)
		cSeriOri:= IIf(alltrim(cEspecie) $ 'NF|NDC|NCP',(cAliasRef)->D2_SERIORI, (cAliasRef)->D1_SERIORI)

		If alltrim(cEspecie) $ 'NCP|NDP' // Nota Ajuste NCP	NDP
			cCondSF  := "% SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
			cCondSF	 += " AND SF1.F1_DOC = '" + cNFOri + "'"
			cCondSF  += " AND SF1.F1_SERIE = '" + cSeriOri + "'"
			cCondSF  += " AND SF1.F1_FORNECE = '" + cCli + "'"
			cCondSF  += " AND SF1.F1_LOJA = '" + cLoja + "'"
			cCondSF	 += " AND SF1.D_E_L_E_T_  = ' ' %"
		Else
			cCondSF  := "% SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
			cCondSF	 += " AND SF2.F2_DOC = '" + cNFOri + "'"
			cCondSF  += " AND SF2.F2_SERIE = '" + cSeriOri + "'"
			cCondSF  += " AND SF2.F2_CLIENTE = '" + cCli + "'"
			cCondSF  += " AND SF2.F2_LOJA = '" + cLoja + "'"	
			cCondSF	 += " AND SF2.D_E_L_E_T_  = ' ' %"
		EndIf

		If Select(cAliasSF) > 0
			(cAliasSF)->(dbCloseArea())
			cAliasSF := getNextAlias()
		EndIf

		BeginSql alias cAliasSF
			SELECT %exp:cCamposSF%
			FROM  %exp:cTablasSF%
			WHERE %exp:cCondSF%
		EndSql

		TCSetField(cAliasSF,"EMISSAO","D")
		Count to nCount

		If nCount > 0
			dbSelectArea(cAliasSF)
			(cAliasSF)->(DbGoTop())
			If alltrim(cEspecie) $ 'NCP|NDP'
				While (cAliasSF)->(!Eof())
					cSerie2 := (cAliasSF)->F1_SERIE2
					cEspe   := alltrim((cAliasSF)->F1_ESPECIE)
					dDtEmis := (cAliasSF)->EMISSAO
					cHrEmis := (cAliasSF)->F1_HORA
					cUUID   := (cAliasSF)->F1_UUID
					(cAliasSF)->(dbskip())
				EndDo
			Else
				While (cAliasSF)->(!Eof())
					cSerie2 := (cAliasSF)->F2_SERIE2
					cEspe   := alltrim((cAliasSF)->F2_ESPECIE)
					dDtEmis := (cAliasSF)->EMISSAO
					cHrEmis := (cAliasSF)->F2_HORA
					cUUID   := (cAliasSF)->F2_UUID
					(cAliasSF)->(dbskip())
				EndDo
			Endif
		Else
			If alltrim(cEspecie) $ "NDC"
				SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
				IF SFP->(DBSEEK(XFILIAL("SFP")+xFilial("SF2")+cSeriori+'1'))
					cSerie2:= SFP->FP_SERIE2
				ELSE
					cSerie2:= ''
				ENDIF
				cEspe := "NF"
			Else
				cSerie2 := ""
				cEspe := ""
			EndIf
		EndIf
		// Deberá reportar solo una vez la NF
		If len(aReferen) > 0
			nPos := ASCAN(aReferen,{|x| x[1] == RTRIM(cSerie2) .and. x[2] == RTRIM(cNFOri) .and. x[3] == DTOS(dDtEmis)} )
			If nPos == 0
				aAdd(aReferen,{RTrim(cSerie2), RTrim(cNFOri), DTOS(dDtEmis), cUUID, cHrEmis, cTipNota})
			EndIf
		Else
			aAdd(aReferen,{RTrim(cSerie2), RTrim(cNFOri), DTOS(dDtEmis), cUUID, cHrEmis, cTipNota})
		EndIf
		(cAliasRef)->(dbskip())
	EndDo
	//Referencia
	For nX := 1 To Len(aReferen)
	    cXMLRef += '	<cac:BillingReference>' + cCRLF
	    cXMLRef += '		<cac:InvoiceDocumentReference>' + cCRLF
	    cXMLRef += '			<cbc:ID>' + aReferen[nX][1]+ Alltrim( Str( Val( Substr( aReferen[nX][2] , 4 , 10) ) ) ) + '</cbc:ID>' + cCRLF
	    cXMLRef += '			<cbc:UUID>' + Alltrim(aReferen[nX][4]) + '</cbc:UUID>' + cCRLF
	    cXMLRef += '			<cbc:IssueDate>' + Left(aReferen[nX,3],4) + "-" + Substr(aReferen[nX,3],5,2)+ "-" + Right(aReferen[nX,3],2) + '</cbc:IssueDate>' + cCRLF
	    cXMLRef += '			<cbc:IssueTime>' + aReferen[nX][5] + '</cbc:IssueTime>' + cCRLF
		cXMLRef += IIF( alltrim(cEspecie) $ 'NCP|NDP', '			<cbc:IssueType>' + aReferen[nX][6] + '</cbc:IssueType>' + cCRLF, "") 
	    cXMLRef += '		</cac:InvoiceDocumentReference>' + cCRLF
	    cXMLRef += '	</cac:BillingReference>'
    Next nX

RestArea(aArea)
Return cXMLRef

/*/{Protheus.doc} fGetTaxDet
Genera Elemento de Impuestos por cada item de la nota de débito
@type function
@author mayra.camargo
@since 16/05/2018
@version 1.0
@param cDOC, character, Número de documento
@param cSERIE, character, Serie
@param cCLIENTE, character, Código de Cliente
@param cLOJA, character, Código de tienda
@param cTES, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function fGetTaxDet(cDOC, cSERIE, cCLIENTE, cLOJA, cTES, cEspecie)
	Local aArea  	:= GetArea()
	Local aImp   	:= {}
	Local cTmp   	:= getNextAlias()
	Local cTaxas 	:= ""
	Local cPrecios	:= ""
	Local cSalto 	:= (chr(13)+chr(10))
	Local cMoeda 	:= ""
	Local nX		:= 0
	Local nBaseImp	:= 0
	Local nValImp	:= 0
	Local nAliqImp	:= 0

	Local cAliasSF	:= IIf(cEspecie $ 'NF|NDC',"SF2","SF1")
	Local cAliasSD	:= IIf(cEspecie $ 'NF|NDC',"SD2","SD1")
	Local nOrder	:= IIf(cEspecie $ 'NF|NDC',3,1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	Local cMoedaSF	:= IIf(cEspecie $ 'NF|NDC',"F2_MOEDA","F1_MOEDA")
	Local cFilialSD	:= IIf(cEspecie $ 'NF|NDC',"D2_FILIAL","D1_FILIAL")
	Local cItemSD	:= IIf(cEspecie $ 'NF|NDC',"D2_ITEM","D1_ITEM")
	Local cCodSD	:= IIf(cEspecie $ 'NF|NDC',"D2_COD","D1_COD")
	Local cUniMedSD	:= IIf(cEspecie $ 'NF|NDC',"D2_UM","D1_UM")
	Local cCantSD	:= IIf(cEspecie $ 'NF|NDC',"D2_QUANT","D1_QUANT")
	Local cTotalSD	:= IIf(cEspecie $ 'NF|NDC',"D2_TOTAL","D1_TOTAL")
	Local cDescSD	:= IIf(cEspecie $ 'NF|NDC',"D2_DESCON","D1_VALDESC")
	Local cPreVtaSD	:= IIf(cEspecie $ 'NF|NDC',"D2_PRCVEN","D1_VUNIT")
	Local cBasImpSD	:= IIf(cEspecie $ 'NF|NDC',"D2_BASIMP","D1_BASIMP")
	Local cValImpSD	:= IIf(cEspecie $ 'NF|NDC',"D2_VALIMP","D1_VALIMP")
	Local cAlqImpSD	:= IIf(cEspecie $ 'NF|NDC',"D2_ALQIMP","D1_ALQIMP")
	Local cCFSD		:= IIf(cEspecie $ 'NF|NDC',"D2_CF","D1_CF")
	Local aRetFte	:= {}
	Local nPrecio	:= 0
	Local nTotal	:= 0
	Local aDetFac	:= {"", 0, 0 ,0}
	Local lItemReg	:= .F.
	Local cCF		:= ""
	Local nY		:= 0
	Local lDif      := .T.
	Local cIDImp    := ""
	Local nConIt    := 0
	Local cImpMil   := SuperGetMV("MV_IMPMILL",,"")
	Local nDesPor   := 2
	Local nTasa     := 0
	Local aPrecio   := {}
	Local cFilSF4   := xFilial("SF4")
	Local lAgrVlrM  := .T.

	// Códigos fiscales por tipo de retención de la fuente
	aAdd( aRetFte , { SuperGetMV("MV_RETF053",,"") , "053" } )
	aAdd( aRetFte , { SuperGetMV("MV_RETF055",,"") , "055" } )
	aAdd( aRetFte , { SuperGetMV("MV_RETF056",,"") , "056" } )
	aAdd( aRetFte , { SuperGetMV("MV_RETF057",,"") , "057" } )
	dbSelectArea("SF4")
	SF4->(dbSetOrder(1)) //F4_FILIAL + F4_CODIGO
	If SF4->(MsSeek(cFilSF4 + cTES)) //Valida si agrega el Valor a Mercaderia
		If Alltrim(SF4->F4_AGREG) == "N"
			lAgrVlrM := .F.
		EndIf
	EndIf

	BeginSql alias cTmp
		SELECT FB_CODIGO,FB_ALIQ,FB_IMPSAT,FB_CPOLVRO,FB_CLASSE,FC_TES,FC_INCDUPL
		FROM %table:SFB% SFB INNER JOIN %table:SFC% SFC ON FB_CODIGO=FC_IMPOSTO
		WHERE FB_FILIAL = %exp:xfilial("SFB")%
		AND FC_FILIAL = %exp:xfilial("SFC")%
		AND SFC.%notDel%
		AND SFB.%notDel%
		AND SFC.FC_TES = %exp:cTES%
	EndSql

	dbSelectArea(cTmp)
	(cTmp)->(DbGoTop())
	While (!(cTmp)->(EOF()))
		/*
		Estructura de aImp
		1. Libro Fiscal
		2. Código Impuesto DIAN
		3. Clase de Impuest
		4. Alícuota
		5. Código Impuesto
		6. TES
		7. Base Impuesto
		8. Total Impuesto
		9. 1+, 2-, 3 (Indiferente [Auto-Retención 0A-ZZZ | Impuesto incluido en precio])
		*/
		AADD( aImp , { (cTmp)->FB_CPOLVRO, (cTmp)->FB_IMPSAT, (cTmp)->FB_CLASSE, (cTmp)->FB_ALIQ, (cTmp)->FB_CODIGO, (cTmp)->FC_TES, 0.00, 0.00, (cTmp)->FC_INCDUPL })
		(cTmp)->(dbskip())
	EndDo

	(cTmp)->(dbCloseArea())

	dbSelectArea(cAliasSF)
	(cAliasSF)->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	(cAliasSF)->(dbSeek(xFilial(cAliasSF)+ cDOC + cSERIE + cCLIENTE + cLOJA))

	CTO->(DbSetOrder(1))
	CTO->(dbSeek(xFilial("CTO")+Strzero((cAliasSF)->&(cMoedaSF),2)))
	cMoeda := ALLTRIM(Posicione("CTO",1,xFilial("CTO")+Strzero((cAliasSF)->&(cMoedaSF),2),"CTO_MOESAT"))
	aDetFac[1] := M486UNIMED((cAliasSD)->&(cUniMedSD))	//1 Unidad de medida

	If Len(aImp) == 0
		aPrecio := M486ACTPRE(cAliasSD, cPreVtaSD, cTotalSD, cDescSD, cCantSD)
		aDetFac[2] := aPrecio[1]	//2 Precio unitario
		aDetFac[3] := aPrecio[2]	//3 Total con descuentos
	EndIf

	For nX := 1 To Len(aImp)
		If aImp[nX,3] == "I"
			nBaseImp:= (cAliasSD)->&(cBasImpSD + aImp[nX,1])
			nValImp := (cAliasSD)->&(cValImpSD + aImp[nX,1])
			nAliqImp := (cAliasSD)->&(cAlqImpSD + aImp[nX,1])

			If (nBaseImp > 0 .or. nValImp > 0 )
				If !lItemReg
					If aImp[nX,9] <> "3"
						// Precio sin IVA incluido
						aPrecio := M486ACTPRE(cAliasSD, cPreVtaSD, cTotalSD, cDescSD, cCantSD)
						nPrecio := aPrecio[1]	//2 Precio unitario
						nTotal  := aPrecio[2]	//3 Total con descuentos
					Else
						// Precio con IVA incluido
						nPrecio := (nBaseImp + (cAliasSD)->&(cDescSD)) / (cAliasSD)->&(cCantSD)
						nTotal := nBaseImp
					Endif

					aDetFac[2] := nPrecio	//2 Precio unitario
					aDetFac[3] := nTotal	//3 Total con descuentos
					aDetFac[4] := nTotal	//4 Total con descuentos e impuestos
					lItemReg := .T.
				EndIf

				If Alltrim( aImp[nX,2] ) == "05"
					cCF := Alltrim( (cAliasSD)->&(cCFSD) )
					For nY := 1 to Len(aRetFte)
						If cCF $ aRetFte[nY][1]
							aImp[nX,2] := aRetFte[nY][2]
							Exit
						Endif
					Next nY
				Endif

				aImp[nX,4] := nAliqImp
				aImp[nX,7] += nBaseImp
				aImp[nX,8] += nValImp

				If aImp[nX,9] == "2"
					aDetFac[4] -= nValImp
				Else
					aDetFac[4] += nValImp
				EndIf
			Else
				aDetFac[2] := nPrecio	//2 Precio unitario
				aDetFac[3] := nTotal	//3 Total con descuentos
			EndIf
		Else
			aPrecio := M486ACTPRE(cAliasSD, cPreVtaSD, cTotalSD, cDescSD, cCantSD)
			aDetFac[2] := aPrecio[1]	//2 Precio unitario
			aDetFac[3] := aPrecio[2]	//3 Total con descuentos
		EndIf
	Next nX

    ASort(aImp,,,{|x,y| x[2] < y[2]})
	For nX := 1 To Len(aImp)
		If aImp[nX][3] == "I"
			nConIt += 1
			lDif := cIDImp <> aImp[nX,2]
			If lDif
				nValTaxA := 0
				AEval(aImp, {|x,y| IIf(Alltrim(aImp[y][2]) == Alltrim(aImp[nX,2]),nValTaxA += aImp[y][8],.T.)})
				If nX > 1
					cTaxas += '		</cac:TaxTotal>'  + cSalto
				EndIf
				cTaxas += '		<cac:TaxTotal>'  + cSalto
				cTaxas += '			<cbc:TaxAmount currencyID="'+ cMoeda +'">'+  Alltrim(STR(nValTaxA,14,2)) +'</cbc:TaxAmount>'  + cSalto
				cTaxas += '			<cbc:TaxEvidenceIndicator>false</cbc:TaxEvidenceIndicator>'  + cSalto
				cIDImp := aImp[nX,2]
			EndIf

			cTaxas += '			<cac:TaxSubtotal>'  + cSalto
			cTaxas += '				<cbc:TaxableAmount currencyID="'+ cMoeda +'">'+ Alltrim(STR(aImp[nX,7],14,2))  +'</cbc:TaxableAmount>'  + cSalto
			cTaxas += '				<cbc:TaxAmount currencyID="'+ cMoeda +'">'+ Alltrim(STR(aImp[nX,8],14,2)) +'</cbc:TaxAmount>'  + cSalto
			nDesPor := IIf(!Empty(cImpMil) .And. Alltrim(aImp[nX,5]) $ cImpMil, 3, 2)
			nTasa   := IIf(!Empty(cImpMil) .And. Alltrim(aImp[nX,5]) $ cImpMil, aImp[nX,4]/10, aImp[nX,4])
			cTaxas += '				<cbc:Percent>'+ Alltrim(STR(nTasa,14,nDesPor))+'</cbc:Percent>'  + cSalto
			cTaxas += '				<cac:TaxCategory>'  + cSalto
			cTaxas += '					<cac:TaxScheme>'  + cSalto
			cTaxas += '						<cbc:ID>'+ Alltrim(aImp[nX,2]) +'</cbc:ID>'  + cSalto
			cTaxas += '					</cac:TaxScheme>'  + cSalto
			cTaxas += '				</cac:TaxCategory>'  + cSalto
			cTaxas += '			</cac:TaxSubtotal>'  + cSalto
			If cIDImp <> aImp[nX,2]
				cTaxas += '		</cac:TaxTotal>' + cSalto
			EndIf
		EndIf
	Next
	If nConIt > 0
		cTaxas += '		</cac:TaxTotal>' + cSalto
	EndIf

	cPrecios += '		<cac:PricingReference>' + cSalto
	cPrecios += '			<cac:AlternativeConditionPrice>' + cSalto	// precioTotalSinImpuestos
	cPrecios += '				<cbc:PriceAmount currencyID="' + cMoeda + '">' + IIf(!lAgrVlrM,"0.00",Alltrim(Transform(aDetFac[3],"99999999999999.99"))) + '</cbc:PriceAmount>' + cSalto
	cPrecios += '				<cbc:PriceTypeCode>01</cbc:PriceTypeCode>' + cSalto
	cPrecios += '			</cac:AlternativeConditionPrice>' + cSalto
	cPrecios += '			<cac:AlternativeConditionPrice>' + cSalto	// precioTotal
	cPrecios += '				<cbc:PriceAmount currencyID="' + cMoeda + '">' +  Alltrim(Transform(aDetFac[4],"99999999999999.99")) + '</cbc:PriceAmount>' + cSalto
	cPrecios += '				<cbc:PriceTypeCode>02</cbc:PriceTypeCode>' + cSalto
	cPrecios += '			</cac:AlternativeConditionPrice>' + cSalto
	cPrecios += '		</cac:PricingReference>' + cSalto

	RestArea(aArea)
Return { cPrecios , cTaxas , aDetFac[1], aDetFac[2] }

/*/{Protheus.doc}M486xHex
Convierte a hexadecimal un texto dado a una longitud dada
@type
@author mayra.camargo
@since 12/07/2018
@version 1.0
@param nValor, numérico,Valor a convertir
@param nDigs , numérico,Tamaño de la cadena a generar
@return cHex, cadena en Hexadecimal
@example
(examples)
@see (links_or_references)
/*/
Function M486xHex(nValor, nDigs)
	Local nRes		:= 0
	Local cHex		:= ""

	If ValType(nValor) == "C"
		nValor := Val( nValor )
	Endif

	If ValType(nValor) == "N"
		While nValor > 0
			nRes := nValor % 16
			nValor := Int( nValor / 16 )
			If nRes >= 10
				cHex := Chr( 55 + nRes ) + cHex
			Else
				cHex := Alltrim( Str(nRes) ) + cHex
			Endif
		End
	Endif

	cHex := Replicate( "0" , nDigs - Len(cHex) ) + cHEx

Return cHex

/*/{Protheus.doc} M486IMPTES
Valida si impuesto existe en TES de detalle
@type function
@author luis.enriquez
@since 31/07/2018
@version 1.0
@param cCodImp, cTes
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function M486IMPTES(cCodImp, cTes)
	Local lRet := .F.
 	dbSelectArea("SFC")
 	dbSetOrder(2) //FC_FILIAL + FC_TES + FC_IMPOSTO
 	If SFC->(DbSeek(xFilial("SFC") + cTes))
		Do While SFC->(!Eof()) .And. (SFC->FC_FILIAL + SFC->FC_TES == xFilial("SFC") + cTes)
			If SFC->FC_IMPOSTO == cCodImp
				lRet := .T.
				Exit
			EndIf
			SFC->(dbSkip())
		EndDo
	EndIf
Return lRet

/*/{Protheus.doc} ValidCat
Valida si un registro  para una tabla dada existe en el catálogo registrado
en f3i y f3h
@type
@author mayra.camargo
@since 24/10/2018
@version 1.0
@param cCodigo	, caracter, Código de la Tabla
@param cConteudo, caracter, Cadena a buscar
@param nPos1, numérico, Posición de inicio de búsqueda
@param nPos2, numérico, Posición de fin de búsqueda
@return lRet, verdadero si encuentra el registro, falso si no lo encuentra
@example
lRet := ValidCat("S006", SA1->A1_TIPDOC,1,1)
@see (links_or_references)
/*/
Function ValidCat(cCodigo,cConteudo,nPos1,nPos2)
	Local lRet := .F.
	Local cTRB := ""
	Local cQry := ""
    Local aArea:= getArea()
	Default nPos1 := 0
	Default nPos2 := 0

	If cCodigo <> Nil .And. cConteudo <> Nil

		If Select("TRBF3I")>0
			TRBF3I->(dbCloseArea())
		EndIf

		cQry := " SELECT F3I_CODIGO,F3I_SEQUEN,F3I_CONTEU "
		cQry += " FROM " + RetsqlName("F3I") + " F3I "
		cQry += " WHERE F3I_FILIAL = '" + xFilial("F3I") + "' "
		cQry += " AND F3I_CODIGO = '" + cCodigo + "' "
		cQry +=" AND F3I.D_E_L_E_T_='' "

		cTRB := ChangeQuery(cQry)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRB ) ,"TRBF3I", .T., .F.)

		dbSelectArea( "TRBF3I" )
		TRBF3I->(dbGoTop())

		While TRBF3I->(!Eof())
			If Alltrim(Substr(TRBF3I->F3I_CONTEU,nPos1,nPos2)) == Alltrim(cConteudo)
				lRet := .T.
				Exit
			EndIf
			TRBF3I->(dBSkip())
		EndDo
	EndIf
	RestArea(aArea)
Return(lRet)

Static Function fGetSerSem(cFilSer, cCliente, cLoja, cNoRemito, cSerRemito)
	Local cRet := ""
	Local cTRB := ""
	Local cQry := ""
	Local cQrTab:= getNextAlias()
	Local aArea := getArea()

	Default cFilSer    := ""
	Default cCliente   := ""
	Default cLoja      := ""
	Default cNoRemito  := ""
	Default cSerRemito := ""

	cQry := " SELECT F2_SERIE2 "
	cQry += " FROM " + RetsqlName("SF2") + " SF2 "
	cQry += " WHERE F2_FILIAL = '" + cFilSer + "' "
	cQry += " AND F2_CLIENTE = '" + cCliente + "' "
	cQry += " AND F2_LOJA = '" + cLoja + "' "
	cQry += " AND F2_DOC = '" + cNoRemito + "' "
	cQry += " AND F2_SERIE = '" + cSerRemito + "' "
	cQry +=" AND SF2.D_E_L_E_T_='' "

	cTRB := ChangeQuery(cQry)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRB ) ,cQrTab, .T., .F.)

	dbSelectArea( cQrTab )
	(cQrTab)->(dbGoTop())

	While (cQrTab)->(!Eof())
		cRet := (cQrTab)->F2_SERIE2
		(cQrTab)->(dBSkip())
	EndDo
	RestArea(aArea)
Return(cRet)

/*/{Protheus.doc} M486SX3
//Genera arreglos de campos para aHeader y aCols; uso en bajas de documentos.
@author Luis Enríquez
@since 18/02/2019
@version 1.0
@return Nil
@type function
/*/
Function M486SX3(aCabsSF1, aCabsSF2, aItensSD1, aItensSD2)
	Default aItensSD1 := {}
	Default aItensSD2 := {}
	Default aCabsSF1  := {}
	Default aCabsSF2  := {}

	SX3->(dbSetOrder(1))
	If SX3->(dbSeek("SF1"))
	   Do While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == "SF1"
	      If SX3->X3_CONTEXT <> 'V'
			  aAdd(aCabsSF1, SX3->X3_CAMPO)
		  EndIf
	      SX3->(dbSkip())
	   EndDo
	EndIf

	SX3->(dbSetOrder(1))
	If SX3->(dbSeek("SF2"))
	   Do While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == "SF2"
	      If SX3->X3_CONTEXT <> 'V'
			  aAdd(aCabsSF2, SX3->X3_CAMPO)
		  EndIf
	      SX3->(dbSkip())
	   Enddo
	EndIf

	If SX3->(dbSeek("SD1"))
	   Do While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == "SD1"
	      If SX3->X3_CONTEXT <> 'V'
		      aAdd(aItensSD1, SX3->X3_CAMPO)
		  EndIf
	      SX3->(dbSkip())
	   EndDo
	EndIf

	If SX3->(dbSeek("SD2"))
	   Do While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == "SD2"
	      If SX3->X3_CONTEXT <> 'V'
		      aAdd(aItensSD2, SX3->X3_CAMPO)
		  EndIf
	      SX3->(dbSkip())
	   EndDo
	EndIf
Return Nil
/*/{Protheus.doc} M486AUTOCB
//Realiza baja automatica de documentos a partir de comunicado de baja autorizado.
@author Luis Enríquez
@since 19/02/2019
@version 1.0
@return Nil
@type function
/*/
Function M486AUTOCB(cEsp)
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
Return

/*/{Protheus.doc} M486ACTSTA
//Actualiza campo FLFTEX de estatus de comunidado de baja.
@author Luis Enríquez
@since 19/02/2019
@version 1.0
@return Nil
@type function
/*/
Function M486ACTSTA(cEspecie, nStaTss, dFecBaja)
	Local cFlfTex  := IIf(Alltrim(cEspecie) $ "NF|NDC","F2_FLFTEX","F1_FLFTEX")
	Local cDtCBaja := IIf(Alltrim(cEspecie) $ "NF|NDC","F2_DTCBAJA","F1_DTCBAJA")
	Local cAliasSF := IIf(Alltrim(cEspecie) $ "NF|NDC","SF2","SF1")
	Local cStaPro  := ""

	Do Case
		Case nStaTss == 6 //Autorizado
			cStaPro := "8"
		Case nStaTss == 4 //Pendiente
			cStaPro := "7"
	EndCase

	If !Empty(cStaPro)
		RecLock(cAliasSF,.F.)
		(cAliasSF)->&(cFlfTex) := cStaPro //STATUS
		If nStaTss == 6
			(cAliasSF)->&(cDtCBaja) := dFecBaja //FECHA DE BAJA
		EndIF
		(cAliasSF)->(MsUnlock())
	EndIf
Return

/*/{Protheus.doc} M486VALGEN
//Valida que hayan sido seleccionado al menos un documento para comunicado de baja.
@author Luis Enríquez
@since 19/02/2019
@version 1.0
@return Nil
@type function
/*/
Function M486VALGEN(oLbx1, oDlgFat, nOpc, aItems)
	Local lRet  := .F.
	Local nPos  := 0

	nPos := aScan(aItems, {|aVal| aVal[2] == .T.} )
	If  nPos>0
		lRet := .T.
		nOpc := 1
		oDlgFat:End()
	Else
		Aviso(STR0198, STR0212 ,{STR0066}) //"Comunicado de Baja" //"Es necesario selecionar al menos una factura." //"Ok"
	EndIf
Return lRet

/*/{Protheus.doc} M486VLDEDO
//Valida status para selección de documentos para comunicado de baja.
@author Luis Enríquez
@since 19/02/2019
@version 1.0
@return Nil
@type function
/*/
Function M486VLDEDO(cSerie, cDoc, cEstatus, dFecAut)
	If Empty(cEstatus) .Or. cEstatus $ "0|3|5"
		Aviso(STR0015, STR0213 + Alltrim(cSerie) + "-" + Alltrim(cDoc) + STR0214,{STR0066}) //"El documento no ha sido transmitido. Utilice la rutina de registro de documentos correspondiente para borrar/anular."
	ElseIf cEstatus $ "1|4"
		Aviso(STR0015, STR0213 + Alltrim(cSerie) + "-" + Alltrim(cDoc) + STR0215,{STR0066}) //"El documento está en proceso, actualice antes el estado de transmisión."
	ElseIf dFecAut < dFecLim
		Aviso(STR0015, STR0213 + Alltrim(cSerie) + "-" + Alltrim(cDoc) + STR0216,{STR0066}) //"El documento está en proceso, actualice antes el estado de transmisión."
	Else
		Aviso(STR0015, STR0213 + Alltrim(cSerie) + "-" + Alltrim(cDoc) + STR0217,{STR0066}) //"El documento tiene documentos relacionados, no se puede cancelar."
	EndIf
Return

/*/{Protheus.doc} M486BUSCVE
//Valida posición de documentos para comunicado de baja.
@author Luis Enríquez
@since 19/02/2019
@version 1.0
@return Nil
@type function
/*/
Function M486BUSCVE(oLbx1,aItems,cBusca,nIndx)
	Local nPos := 0

	cBusca := Upper(Alltrim(cBusca))

	If  nIndx == 1    //"Factura + Serie"
		nPos := aScan(aItems, {|aVal| aVal[4] + aVal[3] = Alltrim(cBusca)} ) // valor corto de lado derecho del '=' puede coincidir; es como softseek
	EndIf
	If  nPos == 0
		nPos := oLbx1:nAt
	EndIf
Return nPos

/*/{Protheus.doc} M486MarcaI
//Marca el item para comunicado de baja.
@author Luis Enríquez
@since 19/02/2019
@version 1.0
@return Nil
@type function
/*/
Function M486MarcaI(oLbx1,aItems,oDlgRec,cMarckTip)
	Default cMarckTip := ""
	If Empty( cMarckTip )
		aItems[oLbx1:nAt,2]:= !aItems[oLbx1:nAt,2]
	ElseIf cMarckTip == "M"
		aEval( aItems , { |x,y| aItems[y,2] := .T. } )
	ElseIf cMarckTip == "D"
		aEval( aItems , { |x,y| aItems[y,2] := .F. } )
	ElseIf cMarckTip == "I"
		aEval( aItems , { |x,y| aItems[y,2] := !aItems[y,2] } )
	EndIf
Return Nil
/*/{Protheus.doc} M486getEmi
oBTIENE LA FECHA DE EMISIÓN DEL DOCUMENTO DE REFERENCIA
@type function
@author mayra.camargo
@since 23/07/2019
@version 1.0
@param cFilDoc, caracter, Filial de tabla SF2
@param cNfori, caracter, Folio del Documento
@param cSeriori, caracter, Serie del Documento
@param cCli, caracter, Código de Cliente del Documento
@param cLoja, caracter, Código de tienda del documento
@param cEspNF, string, Especie del documento de Referencia
@return cRet, String con fecha de emisión del documento.
/*/
Static Function M486getEmi(cFilDoc,cNfori,cSeriori,cCli,cLoja,CEspNF)
	Local cRet 		:= ""
	Local cTabSF2 	:= getNextAlias()
	Default cFilDoc := xFilial("SF2")
	Default cNfori  := ""
	Default cSeriori:= ""
	Default cCli    := ""
	Default cLoja 	:= ""
	Default cEspNF := "NF "

	BEGINSQL ALIAS cTabSF2
		SELECT  F2_EMISSAO
		FROM %TABLE:SF2% SF2
		WHERE F2_FILIAL = %EXP:cFilDoc%
		AND F2_DOC = %EXP:cNfori%
		AND F2_SERIE = %EXP:cSeriori%
		AND F2_CLIENTE = %EXP:cCli%
		AND F2_LOJA = %EXP:cLoja%
		AND F2_ESPECIE = %EXP:CEspNF%
		AND SF2.%NOTDEL%
	ENDSQL
	TCSetField(cTabSF2,"F2_EMISSAO","D")

	While (cTabSF2 )->(!Eof())
		cRet := STRZERO(YEAR((cTabSF2 )->F2_EMISSAO),4) + "-" + STRZERO(MONTH((cTabSF2 )->F2_EMISSAO),2) + "-" + STRZERO(DAY((cTabSF2 )->F2_EMISSAO),2)
		(cTabSF2 )->(DBSKIP())
	EndDo
	(cTabSF2 )->(dbCloseArea())

Return cRet

/*/{Protheus.doc} M486VLDPER
Validaciones para guardado de Pedido de Venta (PERU)
@type function
@author luis.enríquez
@since 22/08/2019
@version 1.0
@param cPedido, string, Código del Pedido de Venta
@return lRet, boolean, Valor lógico que retorna .F.
        si hay algún problema, caso contrario retorna .T.
/*/
Function M486VLDPER(cPedido)
	Local lRet			:= .T.
	Local cProvFE		:= SuperGetMV("MV_PROVFE",,"")
	Local nI			:= 0
	Local cCRLF			:= (chr(13) + chr(10))
	Local cErrGR		:= ""
	Local lRelOk		:= .T.
	Local cModTras		:= ""
	Local cFilSA4		:= xFilial("SA4")
	Local nManCar		:= 0
	Local lPEVldCmp		:= ExistBlock("M486VLDCMP") //PE que retorna rutinas que no validaran campos
	Local lVldCmpRem	:= .F.
	Local cCampo        := ""
	Local cDetra        := ""
	Local cProblem      := STR0276 //"Para guías de remisión electrónicas:"

	If lPEVldCmp
		lVldCmpRem := FunName() $ Upper(AllTrim(ExecBlock("M486VLDCMP", .F., .F.))) //No valida si es Pedido de Venta
	EndIf

	If !Empty(cProvFE) .And. !lVldCmpRem
		If M->C5_DOCGER == "2" //Doc Gener. (Remisión)
			//Modalidad de traslado
			If Empty(M->C5_TRANSP)
				cErrGR += STR0262 + cCRLF //"-El campo Transportadora(C5_TRANSP) es requerido, para definir si el transporte es público o privado."
			Else
				dbSelectArea("SA4")
				SA4->(dbSetOrder(1)) //A4_FILIAL + A4_COD
				If SA4->(dbSeek(cFilSA4 + M->C5_TRANSP))
					cModTras  := SA4->A4_TIPOTRA
				EndIf

				If Empty(cModTras)
					cErrGR += STR0263 + cCRLF //"-La Transportadora(C5_TRANSP), no tiene definido si es transporte público o privado(A4_TIPOTRA)."
				ElseIf Alltrim(cModTras) == "02" //Trasporte privado
					If Empty(M->C5_VEICULO)
						cErrGR += STR0264 + cCRLF //"-Para Transportadora(C5_TRANSP) de tipo privado(A4_TIPOTRA), se debe informar el vehículo de transporte(C5_VEICULO)."
					EndIf
				EndIf

				//Peso Bruto
				If Empty(M->C5_PBRUTO)
					cErrGR += STR0273 + cCRLF //"El peso bruto debe ser informado (C5_PBRUTO)."
				EndIf

				//Cliente de entrega
				If Empty(M->C5_CLIENT) .Or. Empty(M->C5_LOJAENT)
					cErrGR += STR0274 + cCRLF //"-Cliente de entrega no existe o no ha sido informado (C5_CLIENT + C5_LOJAENT)"
				EndIf

				//Fecha de inicio de traslado
				If Empty(M->C5_FECDSE)
					cErrGR += STR0275 + cCRLF //"-La fecha de inicio de traslado debe ser informada (C5_FECDSE)."
				EndIf

				//Motivo de traslado
				If Empty(M->C5_MODTRAD)
					cErrGR += STR0265 + cCRLF //"-El Pedido no tiene el motivo del traslado (C5_MODTRAD)"
				Else
					If ValidCat("S020",Alltrim(M->C5_MODTRAD),1,2)
						//Motivo de importación
						If Alltrim(M->C5_MODTRAD) = "08"
							If Empty(M->C5_UUIDREL)
								cErrGR += STR0266 + cCRLF //"-El manifiesto de carga en documentos relacionados(C5_UUIDREL), es requerido para motivo de traslado de importacion."
							Else
								//Documentos relacionados
								aUUIDRel := StrTokArr(M->C5_UUIDREL, cCRLF)

								For nI := 1 To Len(aUUIDRel)
									aDocRel := StrTokArr(aUUIDRel[nI], "/")
									If Len(aDocRel) == 2
										If ValidCat("S021",Alltrim(aDocRel[1]),1,2)
											If Alltrim(aDocRel[1]) $ "01|04"
												nManCar += 1
											EndIf
										Else
											cErrGR += STR0267 + Alltrim(aUUIDRel[nI]) + STR0268 + cCRLF //"-El tipo del documento relacionado al Pedido " //", no existe en el Catálogo No. 21 de la SUNAT (C5_UUIDREL)."
											lRelOk := .F.
										EndIf
									Else
										cErrGR += STR0269 + Alltrim(aUUIDRel[nI]) + STR0270 + cCRLF //"-El documento relacionado al Pedido " //", no cumple con el formato requerido Tipo documento/No. documento (C5_UUIDREL)."
										lRelOk := .F.
									EndIf
								Next nI

								If lRelOk .And. nManCar == 0
									cErrGR += STR0271 + cCRLF //"-El Pedido no tiene relacionado documento de tipo manifiesto de carga (04 o 01), para motivo de importación."
								EndIf
							EndIf
						EndIf
					Else
						cErrGR += STR0272 //"-El motivo del traslado(C5_MODTRAD) del Pedido, no corresponde a un valor del Catálogo No. 20 de la SUNAT."
					EndIf
				EndIf
			EndIf
		ElseIf M->C5_DOCGER == "1" //Doc Gener. (Factura)
			If SC5->(FieldPos("C5_TIPONF")) > 0
				If M->C5_TIPONF $ "1001|1002|1003|1004" //Operación sujeta a Detracción
					If SC5->(FieldPos("C5_CODVGLP")) > 0
						If Empty(M->C5_CODVGLP)
							cCampo := FWX3Titulo("C5_CODVGLP") + " (C5_CODVGLP)"
							cDetra += StrTran(STR0325, '###', cCampo) + cCRLF //"El campo ### es requerido."
						EndIf
					EndIf
					If SC5->(FieldPos("C5_MODANP")) > 0
						If Empty(M->C5_MODANP)
							cCampo := FWX3Titulo("C5_MODANP") + " (C5_MODANP)"
							cDetra += StrTran(STR0325, '###', cCampo) + cCRLF //"El campo ### es requerido"
						EndIf
					EndIf
				EndIf
			EndIf
			If !Empty(cDetra)
				cProblem := STR0326 //"El tipo de operación es de tipo Operación Sujeta a Detracción (C5_TIPONF):"
				cErrGR += cDetra
			EndIf
		EndIf
		If !Empty(cErrGR)
			lRet := .F.
			Help(" ",1,"M486VLDGR",,cProblem + cCRLF + cErrGR,1,0)
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} M486VLDRFN
Validaciones para transmisión electrónica de guías de remisión (PERU)
@type function
@author luis.enríquez
@since 27/08/2019
@version 1.0
@param aError, array, arreglo de errores
@param nRegSF2, numeric, Recno del registro de la tabla SF2
@return lRet, boolean, Valor lógico que retorna .F.
        si hay algún problema, caso contrario retorna .T.
/*/
Function M486VLDRFN(aError, nRegSF2)
	Local lRet    := .T.
	Local nI      := 0
	Local cCRLF   := (chr(13) + chr(10))
	Local lRelOk  := .T.
	Local cModTras := ""
	Local cFilSA4  := xFilial("SA4")
	Local cFilSA1  := xFilial("SA1")
	Local cFilDA3  := xFilial("DA3")
	Local cFilDA4  := xFilial("DA4")
	Local nManCar  := 0
	Local cRUCTrans:= ""
	Local cNomTrans:= ""

	Default nRegSF2 := 0

	SF2->(dbGoto(nRegSF2))

	//Modalidad de traslado
	If Empty(SF2->F2_TRANSP)
		aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0277}) //"El campo Transportadora(F2_TRANSP) es requerido."
	Else
		dbSelectArea("SA4")
		SA4->(dbSetOrder(1)) //A4_FILIAL + A4_COD
		If SA4->(dbSeek(cFilSA4 + SF2->F2_TRANSP))
			cModTras  := SA4->A4_TIPOTRA
			cRUCTrans := AllTrim(SA4->A4_CGC)
			cNomTrans := SA4->A4_NOME
		EndIf

		If Empty(cModTras)
			aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0278}) //"El tipo de transporte de La Transportadora(A4_TIPOTRA) es requerido."
			lRet := .F.
		ElseIf Alltrim(cModTras) == "02" //Trasporte privado
			If Empty(SF2->F2_VEICULO)
				aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0279}) //"El vehículo de transporte(F2_VEICULO) es requerido."
				lRet := .F.
			Else
				//Vehículo
				dbSelectArea("DA3")
				DA3->(dbSetOrder(1)) //DA3_FILIAL + DA3_COD
				If DA3->(dbSeek(cFilDA3 + SF2->F2_VEICULO))
					If Empty(DA3->DA3_PLACA)
						aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0280}) //"Las placas del vehículo deben ser informadas (DA3_PLACA)"
						lRet := .F.
					EndIf
					If Empty(DA3->DA3_MOTORI)
						aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0281}) //"El conductor del vehículo debe ser informado (DA3_MOTORI)"
						lRet := .F.
					Else
						//Conductor
						dbSelectArea("DA4")
						DA4->(dbSetOrder(1)) //DA4_FILIAL + DA4_COD
						If DA4->(dbSeek(cFilDA4 + DA3->DA3_MOTORI))
							If Empty(DA4->DA4_TIPOID) //Tipo de documento de identidad
								aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0282}) //"El tipo de documento de identidad del conductor debe ser informado (DA4_TIPOID)"
								lRet := .F.
							Else
								If !(ValidCat("S006",Alltrim(DA4->DA4_TIPOID),1,1)) .Or. DA4->DA4_TIPOID == "6"
									aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0283}) //"El tipo de documento de identidad del conductor no existe o es 6-RUC (DA4_TIPOID)"
									lRet := .F.
								EndIf
							EndIf
							If Empty(DA4->DA4_RG)
								aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0284}) //"El número de documento de identidad del conductor debe ser informado (DA4_RG)"
								lRet := .F.
							EndIf
							If Empty(DA4->DA4_PRNOME) .And. Empty(DA4->DA4_SENOME)
								aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0285}) //"El conductor debe tener informado el nombre (DA4_PRNOME - DA4_SENOME)"
								lRet := .F.
							EndIf
							If Empty(DA4->DA4_APATER)
								aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0286}) //"El apellido paterno del conductor debe ser informado (DA4_APATER)"
								lRet := .F.
							EndIf
							If Empty(DA4->DA4_AMATER)
								aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0287}) //"El apellido materno del conductor debe ser informado (DA4_AMATER)"
								lRet := .F.
							EndIf
						Else
							aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0288}) //"El conductor del vehículo no existe (DA3_MOTORI)"
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf Alltrim(cModTras) == "01" //Trasporte público
			If Empty(cRUCTrans)
				aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0289}) //"El RUC de la transportadora es requerido (A4_CGC)"
				lRet := .F.
			EndIf
			If Empty(cNomTrans)
				aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0290}) //"El nombre de la transportadora es requerido (A4_NOME)"
				lRet := .F.
			EndIf
		EndIf

		//Peso Bruto
		If Empty(SF2->F2_PBRUTO)
			aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0291}) //"El peso bruto debe ser informado (F2_PBRUTO)."
			lRet := .F.
		EndIf

		//Cliente de entrega
		If Empty(SF2->F2_CLIENT) .Or. Empty(SF2->F2_LOJENT)
			aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0292}) //"El cliente destino debe ser informado (F2_CLIENT-F2_LOJENT)."
			lRet := .F.
		Else
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
			If SA1->(dbSeek(cFilSA1 + SF2->F2_CLIENT + SF2->F2_LOJENT))
				If Empty(SA1->A1_CEPE)
					aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0293}) //"El peso bruto debe ser informado (F2_PBRUTO)."
					lRet := .F.
				EndIf
				If Empty(SA1->A1_ENDENT)
					aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0294}) //"La dirección de entrega del cliente (SA1->A1_ENDENT) es requerida."
					lRet := .F.
				EndIf
			EndIf

		EndIf

		//Fecha de inicio de traslado
		If Empty(SF2->F2_FECDSE)
			aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0295}) //"La fecha de inicio de traslado debe ser informada (F2_FECDSE)."
			lRet := .F.
		EndIf

		//Motivo de traslado
		If Empty(SF2->F2_MODTRAD)
			aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0296}) //"El motivo del traslado (F2_MODTRAD) es requerido."
			lRet := .F.
		Else
			If ValidCat("S020",Alltrim(SF2->F2_MODTRAD),1,2)
				//Motivo de importación
				If Alltrim(SF2->F2_MODTRAD) = "08"
					If Empty(SF2->F2_UUIDREL)
					 	aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0297}) //"El manifiesto de carga en documentos relacionados(F2_UUIDREL), es requerido para motivo de traslado de importación."
					 	lRet := .F.
					Else
						//Documentos relacionados
						aUUIDRel := StrTokArr(SF2->F2_UUIDREL, cCRLF)

						For nI := 1 To Len(aUUIDRel)
							aDocRel := StrTokArr(aUUIDRel[nI], "/")
							If Len(aDocRel) == 2
								If ValidCat("S021",Alltrim(aDocRel[1]),1,2)
									If Alltrim(aDocRel[1]) $ "01|04"
										nManCar += 1
									EndIf
								Else
									aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0298}) //"El tipo del documento relacionado, no existe en el Catálogo No. 21 de la SUNAT (F2_UUIDREL)."
									lRelOk := .F.
									lRet := .F.
								EndIf
							Else
								aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0299}) //"El documento relacionado, no cumple con el formato requerido Tipo documento/No. documento (F2_UUIDREL)."
								lRelOk := .F.
								lRet := .F.
							EndIf
						Next nI

						If lRelOk .And. nManCar == 0
							aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0300}) //"Es necesario documento relacionado de tipo manifiesto de carga (04 o 01), para motivo de importación."
							lRet := .F.
						EndIf
					EndIf
				EndIf
			Else
				aAdd(aError, {SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE, SF2->F2_LOJA, STR0301}) //"El motivo del traslado(F2_MODTRAD), no corresponde a un valor del Catálogo No. 20 de la SUNAT."
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} M486ACTPRE
Obtiene valor unitario y valor total del detalle del documento (SD1/SD2)
@type function
@author luis.enríquez
@since 06/11/2019
@version 1.0
@param cAliasSD, caracter, Alias de la tabla (SD1)/SD2
@param cPreVtaSD, caracter, Nombre del campo para Valor Unitario
@param cTotalSD, caracter, Nombre del campo para valor Total
@param cDescSD, caracter, Nombre del campo para valor Descuento
@param cCantSD, caracter, Nombre del campo para Cantidad
@return {nPrec, nTot}, array, nPrec = Precio Unitario del ítem y
        nTot = Valor Total por ítem
/*/
Static Function M486ACTPRE(cAliasSD, cPreVtaSD, cTotalSD, cDescSD, cCantSD)
	Local nPrec := 0
	Local nTot  := 0

	If (cAliasSD)->&(cDescSD) == 0 .Or. cAliasSD == "SD1"
		// Sin descuento o SD1
		nPrec := (cAliasSD)->&(cPreVtaSD)
		nTot := (cAliasSD)->&(cTotalSD)
	Else // Con descuento y SD2
		nPrec := ((cAliasSD)->&(cTotalSD) + (cAliasSD)->&(cDescSD)) / (cAliasSD)->&(cCantSD)
		nTot := (cAliasSD)->&(cTotalSD)
	EndIf
Return {nPrec, nTot}

/*/{Protheus.doc} M486TPPAG
Obtiene el tipo de pago configurado para la Condición de Pago
@type function
@author luis.enríquez
@since 03/02/2021
@version 1.0
@param cFilSE4, caracter, Alias de la tabla SE4
@param cCondPago, caracter, Código de la Condición de Pago
@return cTPago, caracter, Opción de tipo de pago 1-Contado o 2-Crédito
/*/
Function M486TPPAG(cFilSE4, cCondPago)
	Local aArea   := getArea()
	Local cTPago  := ""

	dbSelectAre("SE4")
	SE4->(dbSetOrder(1)) //E4_FILIAL + E4_CODIGO
	If SE4->(MsSeek(cFilSE4 + cCondPago))
		cTPago := SE4->E4_MPAGSAT
	EndIf
	RestArea(aArea)
Return cTPago

/*/{Protheus.doc} M486CUOTA
Obtiene datos requeridos para las cuotas y el saldo acumulado de todas las cuotas del documento
@type function
@author luis.enríquez
@since 03/02/2021
@version 1.0
@param cFilOri, caracter, Filial del documento
@param cCliente, caracter, Código del cliente del documento
@param cLoja, caracter, Código de tienda del documento
@param cSerie, caracter, Serie del documento
@param cDoc, caracter, Folio del documento
@param cEspecie, caracter, Especie del documento
@return aParcelas, array, Arreglo con identificador, valor y fecha de vencimiento de la cuota
@return nSalAcum, numerico, Acumulado del saldo de las cuotas
/*/
Function M486CUOTA(cFilOri,cCliente,cLoja,cSerie,cDoc,cEspecie,aParcelas,nSalAcum)
	Local aArea     := getArea()
	Local cTRBSE1   := getNextAlias()
	Local nCuota    := 0
	Local cStrCuota := ""
	Local cFecPar   := ""

	BeginSql alias cTRBSE1
		SELECT E1_FILORIG, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VENCTO FECVEN, E1_VALOR VALOR, E1_SALDO SALDO
		FROM  %table:SE1% SE1
		WHERE E1_FILORIG = %exp:cFilOri%
			AND E1_CLIENTE = %exp:cCliente%
			AND E1_LOJA = %exp:cLoja%
			AND E1_PREFIXO = %exp:cSerie%
			AND E1_NUM = %exp:cDoc%
			AND E1_TIPO = %exp:cEspecie%
			AND SE1.%notDel%
		ORDER BY E1_FILORIG, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
	EndSql

	TCSetField(cTRBSE1,'FECVEN','D')

	dbSelectArea(cTRBSE1)

	While (cTRBSE1)->(!EOF())
		nCuota += 1
		cStrCuota := "Cuota" + Padl(Alltrim(Str(nCuota)),3,'0')
		cFecPar := Alltrim(Str(YEAR((cTRBSE1)->FECVEN))) + "-" + Padl(Alltrim(Str(MONTH((cTRBSE1)->FECVEN))),2,'0') + "-" +;
		Padl(Alltrim(Str(DAY((cTRBSE1)->FECVEN))),2,'0')
		nSalAcum += (cTRBSE1)->VALOR
		aAdd(aParcelas, {cStrCuota, (cTRBSE1)->VALOR, cFecPar})
		(cTRBSE1)->(dbSkip())
	EndDo

	(cTRBSE1)->(dbcloseArea())

	RestArea(aArea)
Return

/*/{Protheus.doc} M486FOPAGO
Genera el nodo PaymentTerms para Forma de Pago
@type function
@author luis.enríquez
@since 03/02/2021
@version 1.0
@param cMoneda, caracter, Moneda del documento
@param cTipoPago, caracter, Tipo de Pago (1-Contado,2-Crédito)
@param nTotPago, numeric, Acumulado de saldo de pagos
@param aParc, array, Arreglo con identificador, valor y fecha de vencimiento de la cuota
@return cXMLTPago, caracter, estructura de XML para forma de pago
/*/
Function M486FOPAGO(cMoneda, cTipoPago, nTotPago, aParc,nDetrac,nTImp)
	Local cXMLTPago := ""
	Local nP := 0
	Local cDesPago := ""
	Local nParcDed := 0
	Local nTotNeto := 0
	Local nParcForm:= 0
	Local nTotForm := 0

	Default cMoneda := ""
	Default cTipoPago := ""
	Default nTotPago := 0
	Default aParc := {}
	Default nDetrac := 0
	Default nTImp	:= 0

	//Forma de Pago
	If cTipoPago $ "1|2"
		cDesPago := IIf(cTipoPago == "1","Contado","Credito")

		cXMLTPago += '	<cac:PaymentTerms>' + cCRLF
		cXMLTPago += '		<cbc:ID>FormaPago</cbc:ID>' + cCRLF
		cXMLTPago += '		<cbc:PaymentMeansID>' + cDesPago + '</cbc:PaymentMeansID>' + cCRLF
		nTotForm := nTotPago - nDetrac 
		If cTipoPago == "2"
			cXMLTPago += '		<cbc:Amount currencyID="' + cMoneda + '">' + Alltrim(Transform(nTotForm,"999999999999.99")) + '</cbc:Amount>' + cCRLF
		EndIf
		cXMLTPago += '	</cac:PaymentTerms>' + cCRLF


		If cTipoPago == "2" //Crédito
			If Len(aParc) > 0
				nParcDed := (nDetrac) /Len(aParc)
			Endif
			For nP := 1 to Len(aParc)
				nParcForm := Round(aParc[nP][2] -nParcDed,2)
				nTotNeto += nParcForm
				If nP == Len(aParc)
					If  !(nTotForm == nTotNeto)
						nParcForm += (nTotForm - nTotNeto)
					Endif
				EndIf

				cXMLTPago += '	<cac:PaymentTerms>' + cCRLF
				cXMLTPago += '		<cbc:ID>FormaPago</cbc:ID>' + cCRLF
				cXMLTPago += '		<cbc:PaymentMeansID>' + aParc[nP][1] + '</cbc:PaymentMeansID>' + cCRLF
				cXMLTPago += '		<cbc:Amount currencyID="' + cMoneda + '">' + Alltrim(Transform(nParcForm,"999999999999.99")) + '</cbc:Amount>' + cCRLF
				cXMLTPago += '		<cbc:PaymentDueDate>' + aParc[nP][3] + '</cbc:PaymentDueDate>' + cCRLF
				cXMLTPago += '	</cac:PaymentTerms>' + cCRLF
			Next nP
		EndIf
    EndIf
Return cXMLTPago

/*/{Protheus.doc} M486REM
Función que recupera las remisiones vinculadas a cada item de la tabla SD2
@type function
@author eduardo.manríquez
@since 14/10/2021
@version 1.0
@param cFilSD2, caracter, Filial Tabla SD2
@param cDoc, caracter, Número de Documento
@param cSer, caracter, Serie de Documento
@param cCli, caracter, Cliente de la factura
@return cLoja, caracter, Tienda del cliente
@param aGRNCC, array, Arreglo con los datos de guía de remisión

/*/
Function M486REM(cFilSD2,cDoc,cSer,cCli,cLoja,aGRNCC)
	Local cCampos    := "% SD2.D2_SERIREM, SD2.D2_REMITO %"
	Local cCond      := ""
	Local cGroup     := "% SD2.D2_SERIREM, SD2.D2_REMITO %"
	Local cGRClave   := ""
	Local cAliasRem  := getNextAlias()
	Local nPosGR     := 0

	DEFAULT cDoc   := ""
	DEFAULT cSer   := ""
	DEFAULT cCli   := ""
	DEFAULT cLoja  := ""
	DEFAULT cFilSD2 := XFILIAL("SD2")
	DEFAULT aGRNCC := {}

	cCond    := "% SD2.D2_DOC = '" + cDoc + "'"
	cCond    += " AND SD2.D2_SERIE = '" + cSer + "'"
	cCond    += " AND SD2.D2_CLIENTE = '" + cCli + "'"
	cCond    += " AND SD2.D2_LOJA = '" + cLoja + "'"
    cCond	 += " AND SD2.D2_FILIAL = '" + cFilSD2 + "'"
	cCond    += " AND SD2.D2_SERIREM <> '' AND SD2.D2_REMITO <> ''"
	cCond	 += " AND SD2.D_E_L_E_T_  = ' ' %"

	BeginSql alias cAliasRem
		SELECT %exp:cCampos%
		FROM  %Table:SD2% SD2
		WHERE %exp:cCond%
		GROUP BY %exp:cGroup%
	EndSql

	dbSelectArea(cAliasRem)
	(cAliasRem)->(DbGoTop())

	While (cAliasRem)->(!EOF())
		If len(aGRNCC) >0
			nPosGR := Ascan(aGRNCC,{|x| x[1] + x[2] == ((cAliasRem)->D2_SERIREM + STRZERO(VAL((cAliasRem)->D2_REMITO),8) )} )
			If nPosGR == 0
				cGRClave := fGetSerSem(cFilSD2, cCli, cLoja, (cAliasRem)->D2_REMITO, (cAliasRem)->D2_SERIREM)
				aAdd(aGRNCC,{(cAliasRem)->D2_SERIREM,STRZERO(VAL((cAliasRem)->D2_REMITO),8),cGRClave})
			EndIf
		Else
			cGRClave := fGetSerSem(cFilSD2, cCli, cLoja, (cAliasRem)->D2_REMITO, (cAliasRem)->D2_SERIREM)
			aAdd(aGRNCC,{(cAliasRem)->D2_SERIREM,STRZERO(VAL((cAliasRem)->D2_REMITO),8),cGRClave})
		EndIf
		(cAliasRem)->(dbskip())
	EndDo

	(cAliasRem)->(dbcloseArea())
Return

/*/{Protheus.doc} ObtBasVal
Función que recupera el valor de Base y Valor de impuesto para cada TES
a partir de la tabla SD1/SD2.
@type static function
@author oscar.lopez
@since 09/12/2021
@version 1.0
@param cCposDet, caracter, Campos a sumar en Query
@param cAliasSD, caracter, Tabla a usar en Query
@param cConDet, caracter, Condicion auxiliar para Query
@param cTES, caracter, Codigo TES para WHERE de Query
@param cTotalSD, caracter, Campo Total para Base de impuesto
@param cCpoBasImp, caracter, Campo _BASIMP para Base de impuesto
@param cValimpSD, caracter, Campo _VALIMP para Valor de impuesto
@return aRet, arreglo, Valor de Base e Impuesto calculado para impuesto en LF
@example
	aValores := ObtBasVal(cCposDet, cAliasSD, cConDet, cTES, cTotalSD, cCpoBasImp, cValimpSD)
/*/
Static Function ObtBasVal(cCposDet, cAliasSD, cConDet, cTES, cTotalSD, cCpoBasImp, cValimpSD)
	Local cAlias	:= GetNextAlias()
	Local cTabla	:= "% " + RetSqlName(cAliasSD) + " %"
	Local cCond		:= cConDet +"'"+  cTES + "' AND D_E_L_E_T_ = ''%"
	Local aArea		:= GetArea()
	Local aRet		:= {0,0}

	BeginSql alias cAlias
		SELECT %exp:cCposDet%
		FROM  %exp:cTabla%
		WHERE %exp:cCond%
	EndSql
	count to nCount
	DBSelectArea(cAlias)
	If nCount > 0
		(cAlias)->(DbGoTop())
		While (cAlias)->(!Eof())
			If(cAlias)->&(cCpoBasImp) > 0
				aRet := {(cAlias)->&(cCpoBasImp), (cAlias)->&(cValimpSD)}
			Else
				aRet := {(cAlias)->&(cTotalSD), (cAlias)->&(cValimpSD)}
			EndIf
			(cAlias)->(DbSkip())
		EndDo
	EndIf
	(cAlias)->(DBCloseArea())
	RestArea(aArea)
Return aRet

/*/{Protheus.doc} M486DOCANT
Obtiene los documentos de anticipo relacionados a la NF que se transmite.
@type static function
@author luis.enriquez
@since 08/08/2022
@version 1.0
@param CFilFR3, caracter, Filial de tabla FR3
@param cCliente, caracter, Códgo de Cliente del Documento
@param cLoja, caracter, Códgo de Tienda del Documento
@param cDoc, caracter, Folio del Documento
@param cSerie, caracter, Serie del Documento
@param lAdtCompart, lógico, Bandera que indica si la tabla se encuentra en modo compartido.
@return aDocAnt, arreglo, Arreglo de documentos de anticipos relacionados al Documento
/*/
Function M486DOCANT(CFilFR3, cCliente, cLoja, cDoc, cSerie, lAdtCompart)
	Local aArea		  := GetArea()
	Local cQuery      := ""
	Local aDocAnt     := {}
	Local cTipoCom    := ""
	Local cFolio      := ""
	Local cTabFR3     := RetSqlName("FR3")
	Local cTabSF2     := RetSqlName("SF2") 
	Local cFecBaja    := ""
	Local cFilSA1     := xFilial("SA1")
	Local cFilSE1     := xFilial("SE1")

	Default CFilFR3     := xFilial("FR3")
	Default cCliente    := ""
	Default cLoja       := ""
	Default cDoc        := ""
	Default cSerie      := ""
	Default lAdtCompart := .F.

	cQuery := "SELECT SUM(FR3_VALOR) AS VALOR,FR3_FILIAL,FR3_FILORI FILORI,FR3_CART,FR3_PEDIDO,FR3_PREFIX PREFIJO,FR3_PARCEL,FR3_TIPO,FR3_CLIENT CLIENTE,FR3_FORNEC,FR3_LOJA LOJA,FR3_DOC,FR3_SERIE,FR3_DATAE,FR3_NUM NUMERO, F2_SERIE2 SERIE2 "

	cQuery += "FROM " + cTabFR3 + " "
	cQuery += "INNER JOIN " + cTabSF2 + " ON FR3_NUM = F2_DOC AND FR3_PREFIX = F2_SERIE AND FR3_FILORI = F2_FILIAL "
	cQuery += "WHERE FR3_FILIAL = '"+ CFilFR3 + "' "
	If lAdtCompart
		cQuery += " AND (FR3_FILORI = '" + cFilAnt + "' OR FR3_FILORI = ' ') "
	EndIf
	cQuery += "AND FR3_CART = 'R' "
	cQuery += "AND FR3_TIPO IN " + FormatIn(MVRECANT,"/") + " "
	cQuery += "AND FR3_CLIENT = '" + cCliente + "' "
	cQuery += "AND FR3_LOJA = '" + cLoja + "' "
	cQuery += "AND FR3_DOC = '" + cDoc + "' "
	cQuery += "AND FR3_SERIE = '" + cSerie + "' "
	cQuery += "AND " + cTabFR3 + ".D_E_L_E_T_= ' ' "
	cQuery += "AND " + cTabSF2 + ".D_E_L_E_T_= ' ' "

	cQuery += "GROUP BY FR3_FILIAL, FR3_FILORI,FR3_CART,FR3_PEDIDO,FR3_PREFIX,FR3_PARCEL,FR3_TIPO,FR3_CLIENT,FR3_FORNEC,FR3_LOJA,FR3_DOC,FR3_SERIE,FR3_DATAE,FR3_NUM,F2_SERIE2"

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBFR3",.T.,.T.)

	dbSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIL + A1_COD + A1_LOJA

	dbSelectArea("SE1")
	SE1->(DbSetOrder(2)) //E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

	While !(TRBFR3->(Eof()))
		cTipoCom := ""
		If Substr(TRBFR3->SERIE2,1,1) $ 'F'     
			cTipoCom := '02' //Factura – emitida por anticipos
		ElseIf Substr(TRBFR3->SERIE2,1,1) $ 'B' 
			cTipoCom := '03' //Boleta de Venta – emitida por anticipos
		EndIf
		cFolio := RTRIM(TRBFR3->SERIE2) + "-" + STRZERO(VAL(TRBFR3->NUMERO),8)
		
		If SA1->(DbSeek(cFilSA1 + TRBFR3->CLIENTE + TRBFR3->LOJA))
			cTipDocId := Alltrim(SA1->A1_TIPDOC)
		EndIF
		If SE1->(DbSeek(cFilSE1 + TRBFR3->CLIENTE + TRBFR3->LOJA + TRBFR3->PREFIJO + TRBFR3->NUMERO))
			cFecBaja := ""
			If !Empty(E1_BAIXA)
				cFecBaja := Alltrim(Str(YEAR(SE1->E1_BAIXA))) + "-" + Padl(Alltrim(Str(MONTH(SE1->E1_BAIXA))),2,'0') + "-" +;
				Padl(Alltrim(Str(DAY(SE1->E1_BAIXA))),2,'0')
			EndIf
		EndIf
		aAdd(aDocAnt,{TRBFR3->FILORI, cTipoCom, cTipDocId, "", TRBFR3->VALOR, TRBFR3->NUMERO, TRBFR3->PREFIJO, TRBFR3->CLIENTE, TRBFR3->LOJA,cFolio,"",Nil,cFecBaja})
		TRBFR3->(DbSkip())
	EndDo
	TRBFR3->(dbCloseArea())
	RestArea(aArea)
Return aDocAnt

/*/{Protheus.doc} M486CFGADT
Retorna el modo de compartimento de tablas FIE, FR3, SE1 
@author Financeiro (SIGAFIN)
@since Mar/2020
@version 1.0
@return aRet
/*/
Static Function M486CFGADT()
Local aRet := { {FwModeAccess('FIE',1),;
                 FwModeAccess('FIE',2),;
                 FwModeAccess('FIE',3),;
                 FWSIXUtil():ExistIndex('FIE', '4'),;
                 FWSIXUtil():ExistIndex('FIE', '5')},;
                 {FwModeAccess('FR3',1),;
                 FwModeAccess('FR3',2),;
                 FwModeAccess('FR3',3),;
                 FWSIXUtil():ExistIndex('FR3', '8'),;
                 FWSIXUtil():ExistIndex('FR3', '9')},;
                 {FwModeAccess('SE1',3)} }
Return(aRet)

/*/{Protheus.doc} M486IMPANT
Obtiene los impuestos de cada uno de los documentos de anticipo relacionados a la NF que se transmite.
@type static function
@author luis.enriquez
@since 08/08/2022
@version 1.0
@param cFilSF2, caracter, Filial de tabla SF2
@param cSerie, caracter, Serie del Documento
@param cCliente, caracter, Códgo de Cliente del Documento
@param cLoja, caracter, Códgo de Tienda del Documento
@param cDoc, caracter, Folio del Documento
@param cEspDoc, caracter, Especie del Documento
@param aImpDoc, arreglo, Impuestos Totales del Documento
@param aDetDoc, arreglo, Detalle del Documento
@param nValorA, numérico, Valor del Anticipo del Documento
@param cMonAnt, caracter, Moneda SAT del Anticipo
@param aImpAfe, arreglo, Acumulado de importes por Tipo de Afectación del IGV
/*/
Function M486IMPANT(cFilSF2, cSerie, cCliente, cLoja, cNumDoc, cEspDoc, aImpDoc, aDetDoc, nValorA, cMonAnt, aImpAfe) 
	Local aArea  	:= getArea()
	Local aValAdic 	:= {}	
	Local nTotalFac	:= 0
	Local lFacGra 	:= .F.
	Local aGRNF		:= {} 
	Local nTotImp	:= 0
	Local lIvap 	:= .F.
	Local cQuery    := ""
	Local cOpeExp   := ""
	Local cAliasF2  := getNextAlias()
	Local cTabSF2   := RetSqlName("SF2")
	Local lDocExp 	:= .F.	

	Default cFilSF2  := xFilial("SF2")
	Default cSerie   := ""
	Default cCliente := "" 
	Default cLoja    := "" 
	Default cNumDoc  := "" 
	Default cEspDoc  := "" 
	Default aImpDoc  := {} 
	Default aDetDoc  := {}
	Default nValorA  := 0
	Default cMonAnt  := ""
	Default aImpAfe  := {}

	cQuery := "SELECT F2_ESPECIE,F2_TIPONF,F2_SERIE2,F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,F2_VALBRUT,F2_MOEDA "
	cQuery += "FROM " + cTabSF2 + " "
	cQuery += "WHERE F2_FILIAL = '"+ cFilSF2 + "' "
	cQuery += "AND F2_DOC = '"+ cNumDoc + "' "
	cQuery += "AND F2_SERIE = '"+ cSerie + "' "
	cQuery += "AND F2_CLIENTE = '"+ cCliente + "' "
	cQuery += "AND F2_LOJA = '"+ cLoja + "' "
	cQuery += "AND D_E_L_E_T_= ' ' "

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasF2,.T.,.T.)
	dbSelectArea(cAliasF2)

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

	While !((cAliasF2)->(Eof()))
		nValorA := (cAliasF2)->F2_VALBRUT
		cMonAnt := ALLTRIM(Posicione("CTO",1,xFilial("CTO")+Strzero((cAliasF2)->F2_MOEDA,2),"CTO_MOESAT"))
		
		If dbSeek(xFilial("SA1") + (cAliasF2)->F2_CLIENTE + (cAliasF2)->F2_LOJA)
			If alltrim(cEspDoc) == "NF" .And. (Substr((cAliasF2)->F2_SERIE2,1,1) $ 'F' .Or. (Substr((cAliasF2)->F2_SERIE2,1,1) $ 'B' .And. SA1->A1_TIPDOC # "06"))
				cOpeExp := IIf(Substr((cAliasF2)->F2_SERIE2,1,1) $ 'F',"0200|0201|0202|0203|0204|0205|0206|0207|0208","0200|0201|0203|0204|0206|0207|0208")
			EndIf	
			lDocExp := IIf(SA1->A1_EST == "EX" .And. (cAliasF2)->F2_TIPONF $ cOpeExp,.T.,.F.)
		EndIf	

		//Impuestos				
		M486XMLIMP((cAliasF2)->F2_ESPECIE,(cAliasF2)->F2_DOC,(cAliasF2)->F2_SERIE,(cAliasF2)->F2_CLIENTE,(cAliasF2)->F2_LOJA, lDocExp, @aImpDoc, @aDetDoc, @aValAdic, @nTotalFac, @lFacGra,@aGRNF, @nTotImp,@lIvap,@nValorA)
		
		(cAliasF2)->(DbSkip())
	EndDo

	(cAliasF2)->(dbCloseArea())

	RestArea(aArea)	
Return Nil

/*/{Protheus.doc} M486ANTITM
Obtiene los impuestos de cada uno de los documentos de anticipo relacionados a la NF que se transmite.
@type static function
@author luis.enriquez
@since 08/08/2022
@version 1.0
@param cFilFR3, caracter, Filial de tabla FR3
@param cCliente, caracter, Códgo de Cliente del Documento
@param cLoja, caracter, Códgo de Tienda del Documento
@param cDoc, caracter, Folio del Documento
@param cSerie, caracter, Serie del Documento
@param cItem, caracter, Número de Ítem del Documento
@param @param lAdtCompart, lógico, Bandera que indica si la tabla se encuentra en modo compartido.
@return aDocAntIt, arreglo, Arreglo de Impuestos de documentos de anticipos relacionados al Documento
/*/
Function M486ANTITM(cFilFR3, cCliente, cLoja, cDoc, cSerie, cItem, lAdtCompart)
	Local aArea		  := GetArea()
	Local cQuery      := ""
	Local aDocAntIt   := {}
	Local cTabFR3     := RetSqlName("FR3")
	Local TRBFR3I     := getNextAlias()

	Default cFilFR3     := xFilial("FR3")
	Default cCliente    := ""
	Default cLoja       := ""
	Default cDoc        := ""
	Default cSerie      := ""
	Default cItem       := ""
	Default lAdtCompart := .F.

	cQuery := "SELECT  FR3_FILIAL, FR3_FILORI FILORI,FR3_PREFIX PREFIJO, FR3_NUM NUMERO, FR3_CLIENT CLIENTE, FR3_LOJA LOJA, FR3_VALOR VALOR"

	cQuery += "FROM " + cTabFR3 + " "
	cQuery += "WHERE FR3_FILIAL = '" + cFilFR3 + "' "
	If lAdtCompart
		cQuery += " AND (FR3_FILORI = '" + cFilAnt + "' OR FR3_FILORI = ' ') "
	EndIf
	cQuery += "AND FR3_CART = 'R' "
	cQuery += "AND FR3_TIPO IN " + FormatIn(MVRECANT,"/") + " "
	cQuery += "AND FR3_CLIENT = '" + cCliente + "' "
	cQuery += "AND FR3_LOJA = '" + cLoja + "' "
	cQuery += "AND FR3_DOC = '" + cDoc + "' "
	cQuery += "AND FR3_SERIE = '" + cSerie + "' "
	cQuery += "AND FR3_ITEM = '" + cItem + "' "
	cQuery += "AND D_E_L_E_T_= ' ' "

	cQuery += "GROUP BY FR3_FILIAL, FR3_FILORI, FR3_PREFIX, FR3_NUM, FR3_CLIENT, FR3_LOJA, FR3_VALOR"

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),TRBFR3I,.T.,.T.)

	While !((TRBFR3I)->(Eof()))
		aAdd(aDocAntIt,{(TRBFR3I)->FILORI, (TRBFR3I)->PREFIJO, (TRBFR3I)->NUMERO, (TRBFR3I)->CLIENTE, (TRBFR3I)->LOJA, (TRBFR3I)->VALOR})
		(TRBFR3I)->(DbSkip())
	EndDo
	(TRBFR3I)->(dbCloseArea())
	RestArea(aArea)
Return aDocAntIt
