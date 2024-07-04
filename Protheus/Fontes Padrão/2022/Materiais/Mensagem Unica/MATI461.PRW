#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI461.CH"
#INCLUDE "TBICONN.CH"

Static _lBRetail := ExistFunc("A410BRETAIL")

//-------------------------------------------------------------------
/*{Protheus.doc} MATI461
Programa de interpretacao da mensagem unica

@since 09/11/2012
@version P11.5

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem
*/
//-------------------------------------------------------------------
Function MATI461(cXML, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local lRet      	:= .T.
Local cXMLRet		:= ""
Local aArea			:= GetArea()
Local aAreaSF2		:= SF2->(GetArea())
Local aAreaSD2		:= SD2->(GetArea())
Local nCount		:= 0
Local aRetEAI       := {}

Local oXmlProc  	:= Nil
Local cXmlErr   	:= " "
Local cXmlWarn  	:= " "

Local cError		:= ""
Local cMarca		:= ""
Local cIntIDName	:= ""

If cTypeTrans == TRANS_RECEIVE

	If cTypeMsg == EAI_MESSAGE_BUSINESS
		lRet    := .F.
		cXmlRet := STR0004 //"Está operação não é suportada por está integração"

	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE

		oXmlProc := XmlParser( cXML, '_', @cXmlErr, @cXmlWarn )

		If oXmlProc <> Nil .And. Empty(cError) .And. Empty(cXmlWarn)
			cMarca   := oXmlProc:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			oXmlProc := oXmlProc:_TotvsMessage

			//  Identifica se o processamento pelo parceiro ocorreu com sucesso.
			If XmlChildEx( oXmlProc:_ResponseMessage:_ProcessingInformation, '_STATUS' ) <> Nil .And. ;
                   Upper(oXmlProc:_ResponseMessage:_ProcessingInformation:_Status:Text) == 'OK'

				If XmlChildEx( oXmlProc:_ResponseMessage:_ReturnContent, '_LISTOFINTERNALID' ) <> Nil .And. ;
					XmlChildEx( oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId, '_INVOICEINTERNALID') <> Nil

					If !( XmlChildEx( oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InvoiceInternalId, '_ORIGIN') <> Nil .And. ;
					      XmlChildEx( oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InvoiceInternalId, '_DESTINATION') <> Nil .And. ;
					      CFGA070Mnt( cMarca, 'SF2', 'F2_DOC', ;
					                  oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InvoiceInternalId:_Destination:Text,;
					                  oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InvoiceInternalId:_Origin:Text ) )
						lRet    := .F.
						cXmlRet := STR0001 //"De-Para não pode ser gravado a integração poderá ter falhas"
					EndIf
				ElseIf XmlChildEx( oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId, '_InternalId' ) <> Nil .And. ;
					XmlChildEx( oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, '_Name') <> Nil
					cIntIDName := upper(rtrim(oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Name:Text))
					If cIntIDName == "INVOICE" .or. cIntIDName == "INTERNALID"
						CFGA070Mnt(cMarca, 'SF2', 'F2_DOC',;
							oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InvoiceInternalId:_Destination:Text,;
							oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InvoiceInternalId:_Origin:Text )
					ElseIf cIntIDName == "ACCOUNTRECEIVABLEDOCUMENT"
						CFGA070Mnt(cMarca, 'SE1', 'E1_NUM',;
							oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InvoiceInternalId:_Destination:Text,;
							oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InvoiceInternalId:_Origin:Text )
					ElseIf cIntIDName == "ACCOUNTPAYABLEDOCUMENT"
						CFGA070Mnt(cMarca, 'SE2', 'E2_NUM',;
							oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InvoiceInternalId:_Destination:Text,;
							oXmlProc:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InvoiceInternalId:_Origin:Text )
					Endif
				EndIf
			Else
				lRet    := .F.
				cXmlRet := STR0002 //"Processamento pela outra aplicação não teve sucesso"

				//------------------------------------------------------------------
				//  Transforma estrutura das mensagens de erro em array
				// para concatenar com a mensagem de retorno
				If XmlChildEx( oXmlProc:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) <> Nil .And. ;
					ValType(oXmlProc:_ResponseMessage:_ProcessingInformation:_ListOfMessages)<>'A'

					XmlNode2Arr(oXmlProc:_ResponseMessage:_ProcessingInformation:_ListOfMessages, "_ListOfMessages")
				EndIf

				For nCount := 1 To Len( oXmlProc:_ResponseMessage:_ProcessingInformation:_ListOfMessages )

					If XmlChildEx( oXmlProc:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount], '_MESSAGE' ) <> Nil
						cXmlRet += ' | ' + oXmlProc:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount]:_Message:Text
					EndIf

				Next nCount
				If InTransaction()
					DisarmTransaction()
				EndIf
			EndIf

		Else
			lRet    := .F.
			cXmlRet := STR0003 + cXmlErr + ' | ' + cXmlWarn //"Xml mal formatado. "
		EndIf

	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
		cXMLRet := '3.009|3.013|3.014|4.000|4.001'
 	Endif

	aRetEAI := {lRet, cXMLRet, "INVOICE"}
ElseIf cTypeTrans == TRANS_SEND

    //Checando a Versão
	If cVersion = "3."
		aRetEAI := v3000(cXML, cTypeTrans, cTypeMsg, cVersion, cTransac)
	ElseIf cVersion = "4."
		aRetEAI := v4000(cXML, cTypeTrans, cTypeMsg, cVersion, cTransac)
	Else
		lRet := .F.
		cXMLRet := STR0005	//"A versão da mensagem informada não foi implementada!"
		aRetEAI := {lRet, cXMLRet, "INVOICE"}
	EndIf
EndIf

RestArea(aAreaSD2)
RestArea(aAreaSF2)
RestArea(aArea)
aSize(aAreaSD2,0)
aSize(aAreaSF2,0)
aSize(aArea,0)

Return aRetEAI

//------------------------------------------------------------------------------------
/*/{Protheus.doc} v3000
Implementação do adapter EAI, versão 3.x

@author  Alison Kaique
@version P12
@since   Jan/2019
/*/
//------------------------------------------------------------------------------------
Static Function v3000(cXML, cTypeTrans, cTypeMsg, cVersion, cTransac)
	Local lRet      	:= .T.
	Local cXMLRet		:= ""
	Local cEvent		:= "upsert"
	Local cChave		:= "" //Chave para pesquisa da CD2

	Local cUndVer		:= MsgUVer('QIEA030', 'UNITOFMEASURE') //Versão da Unidade de Medida
	Local cConVer		:= MsgUVer('MATA360', 'PAYMENTCONDITION') //Versão da Condição de Pagamento
	Local cPrdVer		:= MsgUVer('MATA010', 'ITEM') //Versão do Produto
	Local cLocVer		:= MsgUVer('AGRA045', 'WAREHOUSE') //Versão do Local de Estoque

	Local vProd			:= 0 //Valor Total do Produto
	Local nDesconto		:= 0 //Desconto aplicado
	Local cNatOper		:= ""//Natureza de Operacao
	Local cDescProd		:= ""//Descricao do Produto
	Local cPdVVer       := MsgUVer('MATA410', 'ORDER') //Versão do Pedido de Venda
	Local cRetSaleId	:= ""

	Local lD2FECP		:= SD2->(ColumnPos( "D2_ALQFECP" )) > 0 .And. SD2->(ColumnPos( "D2_VALFECP" )) > 0 .And. SD2->(ColumnPos( "D2_BASFECP" )) > 0// Verifica se os campos FECP existem
	Local lD2FECPST		:= SD2->(ColumnPos( "D2_ALFCPST" )) > 0 .And. SD2->(ColumnPos( "D2_VFECPST" )) > 0 .And. SD2->(ColumnPos( "D2_BSFCPST" )) > 0// Verifica se os campos FECP_ST existem
	Local aRetSale		:= {}

	Local cPurpose		:= "1" //Proposito da Nota Fiscal -  Código da finalidade da nota fiscal de entrada
							// 1 - normal,
 							// 2 - Complemento
 							// 3 - Ajuste
 							// 4 - Devolução

 	Local cFilSF2		:= xFilial("SF2")
 	Local cFilSD2		:= xFilial("SD2")
 	Local cFilSC5		:= xFilial("SC5")

	If  !IsInCallStack("MATI461EAI") .And. !IsInCallStack("MATA310") //protege, Transferência de Filiais não inicializa Inclui/Altera (é sempre inclusão)
		If !Inclui .AND. !Altera
			cEvent	:=	"delete"
		EndIf
	Endif

	If SF2->F2_TIPO == "D" //DEVOLUCAO
		cPurpose := "4"
	ElseIf SF2->F2_TIPO $ ("C|P|I|B") //COMPLEMENTO
		cPurpose := "2"
	// 3 - Ajuste
	Endif

	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>INVOICE</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="InternalId">'  	+ SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)	+ '</key>'
	cXMLRet +=         '<key name="InvoiceNumber">'	+ SF2->F2_DOC		+ '</key>'
	cXMLRet +=         '<key name="InvoiceSerie">' 	+ SF2->F2_SERIE		+ '</key>'
	cXMLRet +=         '<key name="CustomerCode">'  	+ SF2->F2_CLIENTE	+ '</key>'
	cXMLRet +=         '<key name="ShopCode">' 		+ SF2->F2_LOJA		+ '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'

	cXMLRet += ' <BusinessContent> '
    cXMLRet += ' 	 <CompanyId>' 				+ cEmpAnt + '</CompanyId> '
    cXMLRet += ' 	 <BranchId>'				+ cFilAnt + '</BranchId> '
   	cXMLRet +=      '<CompanyInternalId>' 		+ cEmpAnt + '|' + RTrim(cFilSF2) + '</CompanyInternalId>'
	cXMLRet +=      '<InternalId>'				+ cEmpAnt +'|'+SF2->F2_FILIAL+'|'+SF2->F2_DOC+'|'+SF2->F2_SERIE+'|'+SF2->F2_CLIENTE+'|'+SF2->F2_LOJA+'</InternalId>'
	cXMLRet += '     <InvoiceNumber>' 			+ SF2->F2_DOC + '</InvoiceNumber> '
	cXMLRet += '     <InvoiceSerie>' 			+ SF2->F2_SERIE + '</InvoiceSerie> '
	cXMLRet += '     <InvoiceSituation>1</InvoiceSituation> '
	cXMLRet += '     <IssueDate>' 				+ DTOS(SF2->F2_EMISSAO) + '</IssueDate> '
	cXMLRet += '     <InvoiceAmount>' 			+ cValtoChar(SF2->F2_VALBRUT) + '</InvoiceAmount> '
	cXMLRet += '     <ValueofGoods>' 			+ cValtoChar(SF2->F2_VALMERC) + '</ValueofGoods> '
	cXMLRet += '     <FreightAmount>' 			+ cValtoChar(SF2->F2_FRETE) + '</FreightAmount> '
	cXMLRet += '     <InsuranceAmount>' 		+ cValtoChar(SF2->F2_SEGURO) + '</InsuranceAmount> '
	cXMLRet += '     <DiscountAmount>' 		+ cValtoChar(SF2->F2_DESCONT) + '</DiscountAmount> '
	cXMLRet += '     <CurrencyRate>' 			+ '</CurrencyRate> '
	cXMLRet += '     <PaymentConditionCode>' 	+ IntConExt(/*Empresa*/,/*Filial*/, SF2->F2_COND, cConVer)[2] + '</PaymentConditionCode> '
	cXMLRet += '     <CustomerCode>' 			+ SF2->F2_CLIENTE + '</CustomerCode> '
	cXMLRet += '     <StoreCode>' 				+ SF2->F2_LOJA + '</StoreCode> '
	cXmlRet += '     <CustomerInternalId>'      + IntCliExt(,, SF2->F2_CLIENTE, SF2->F2_LOJA)[2] + '</CustomerInternalId>'
	cXMLRet += '     <ElectronicAccessKey>'	+ SF2->F2_CHVNFE +'</ElectronicAccessKey>
	cXMLRet += '     <Purpose>'					+ cPurpose +'</Purpose>
	cXMLRet += '     <FinalConsumerIndicator>'+ IIF(SF2->F2_TIPOCLI == "F","1","0") +'</FinalConsumerIndicator >
	cXMLRet += '     <IcmsPayTaxIndicator>'	+ POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_CONTRIB") +'</IcmsPayTaxIndicator>

	//Lista de Impostos da venda
	cXmlRet += '		<ListOfTaxes>'
	cXmlRet += '			<Tax>'
	cXmlRet += '   			<Taxe>COFINS</Taxe>'
	cXmlRet += '  			<Value>' + CValToChar(SF2->F2_VALIMP5) + '</Value>'
	cXmlRet += '			</Tax>'
	cXmlRet += '			<Tax>'
	cXmlRet += '  			<Taxe>CSLL</Taxe>'
	cXmlRet += '  			<Value>' + CValToChar(SF2->F2_VALCSLL) + '</Value>'
	cXmlRet += '			</Tax>'
	cXmlRet += '			<Tax>'
	cXmlRet += '  			<Taxe>ISS</Taxe>'
	cXmlRet += '  			<Value>' + CValToChar(SF2->F2_VALISS) + '</Value>'
	cXmlRet += '			</Tax>'
	cXmlRet += '			<Tax>'
	cXmlRet += '  			<Taxe>PIS</Taxe>'
	cXmlRet += '  			<Value>' + CValToChar(SF2->F2_VALIMP6) + '</Value>'
	cXmlRet += '			</Tax>'
	cXmlRet += '			<Tax>'
	cXmlRet += '  			<Taxe>IPI</Taxe>'
	cXmlRet += '  			<Value>' + CValToChar(SF2->F2_VALIPI) + '</Value>'
	cXmlRet += '			</Tax>'
	cXmlRet += '			<Tax>'
	cXmlRet += ' 			<Taxe>ICM</Taxe>'
	cXmlRet += '  			<Value>' + CValToChar(SF2->F2_VALICM) + '</Value>'
	cXmlRet += '			</Tax>'
	cXmlRet += '			<Tax>'
	cXmlRet += ' 			<Taxe>ICMS_ST</Taxe>'
	cXmlRet += '  			<Value>' + CValToChar(SF2->F2_ICMSRET) + '</Value>'
	cXmlRet += '			</Tax>'
	cXmlRet += ' 		</ListOfTaxes>'
	cXMLRet += '     <ListOfItens> '
	SD2->(DbSetOrder(3))
	If SD2->(DbSeek(cFilSD2+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA), .F.))
		While (SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(cFilSD2+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)) .AND. SD2->(!EOF())

			//Tratamentos retirados no programa de geração de xml para SEFAZ (NFESEFAZ.PRW)
			//INICIO
			If /*lNfCup .Or. */SD2->D2_ORIGLAN == "VD"
				nDesconto := Round(SD2->D2_QUANT* SD2->D2_PRUNIT,2)+ SD2->D2_VALACRS - SD2->D2_TOTAL
			Else
				nDesconto := SD2->D2_DESCON
			 EndIf

			cDescProd	:= Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")
			cNatOper	:= SF3->F3_ISSST
			vProd	 	:= IIF(!SD2->D2_TIPO$"IP",SD2->D2_TOTAL+nDesconto+SD2->D2_DESCZFR,IIF((SD2->D2_TIPO=="I" .And. SF4->F4_AJUSTE == "S" .And. SubStr(SM0->M0_CODMUN,1,2) == "31") .Or.;
								(SD2->D2_TIPO=="I" .And. SF4->F4_AJUSTE == "S" .And. "RESSARCIMENTO" $ Upper(cNatOper) .And. "RESSARCIMENTO" $ Upper(cDescProd)),SD2->D2_TOTAL,0))
			vUnCom		:= vProd/SD2->D2_QUANT
			//FIM

			cXMLRet += '         <Item> '
			cXMLRet += '             <InvoiceSequence>'		+ SD2->D2_NUMSEQ															+ '</InvoiceSequence> '
			cXMLRet += '             <ItemInvoice>'			+ LTrim(Str(DecodSoma1(SD2->D2_ITEM)))										+ '</ItemInvoice> '
			cXMLRet += '             <OrderNumber>'			+ xFilial('SC6')+SD2->D2_PEDIDO												+ '</OrderNumber> '
			cXMLRet += '             <OrderInternalId>'		+ IntPdVExt(cEmpAnt, xFilial("SC5"), SD2->D2_PEDIDO,/*cItem*/, cPdVVer)[2]	+ '</OrderInternalId>'
			cXMLRet += '             <OrdemItem>'			+ SD2->D2_ITEMPV					 										+ '</OrdemItem> '
			cXmlRet += '             <ItemCode>'			+ IntProExt(cEmpAnt,xFilial("SB1"),SD2->D2_COD,cPrdVer)[2]					+ '</ItemCode>'
			cXMLRet += '             <Quantity>'			+ cValtoChar(SD2->D2_QUANT)													+ '</Quantity> '
			cXmlRet += '             <UnitofMeasureCode>'	+ IntUndExt(cEmpAnt,xFilial('SAH'),SD2->D2_UM,cUndVer)[2]					+ '</UnitofMeasureCode>'
			cXMLRet += '             <UnityPrice>'			+ cValtoChar(vUnCom)														+ '</UnityPrice> '
			cXMLRet += '             <GrossValue>'			+ cValtoChar(vProd)															+ '</GrossValue> '
			cXMLRet += '             <FreightValue>'		+ cValtoChar(SD2->D2_VALFRE)												+ '</FreightValue> '
			cXMLRet += '             <InsuranceValue>'		+ cValtoChar(SD2->D2_SEGURO)												+ '</InsuranceValue> '
			cXMLRet += '             <DiscountValue>'		+ cValtoChar(SD2->D2_DESCON)												+ '</DiscountValue> '
			cXMLRet += '             <NetValue>'			+ cValToChar(SD2->D2_PESO)													+ '</NetValue> '
			cXMLRet += '             <WarehouseId>'			+ IntLocExt(cEmpAnt,xFilial('NNR'),SD2->D2_LOCAL,cLocVer)[2]				+ '</WarehouseId> '
			cXMLRet += '             <LotNumber>'			+ SD2->D2_LOTECTL															+ '</LotNumber> '
			cXMLRet += '             <SubLotNumber>'		+ SD2->D2_NUMLOTE															+ '</SubLotNumber> '
			cXMLRet += '             <ExpirationDate>'		+ DTOS(SD2->D2_DTVALID)														+ '</ExpirationDate> '
            cXMLRet += '             <TaxOpCodeItem>'		+ SD2->D2_CF																+ '</TaxOpCodeItem> '

			//Venda Varejo que originou Pedido de Venda
			cRetSaleId := ""

			If _lBRetail
				SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM
				If SC5->(MsSeek(cFilSC5+SD2->D2_PEDIDO, .F.)) .and. !Empty(SC5->C5_ORCRES)
					LjGrvLog("MATI461" , "SC5->C5_ORCRES:= " + SC5->C5_ORCRES )
					LjGrvLog("MATI461" , "SC5->C5_FILIAL:= " + SC5->C5_FILIAL )

					aRetSale := A410BRETAIL(SC5->C5_ORCRES, SC5->C5_FILIAL)

					If Len(aRetSale) > 0
						cRetSaleId := IntVendExt(,aRetSale[1],aRetSale[2],aRetSale[3],aRetSale[4])[2]
					EndIf
				EndIf
			EndIf

			cXmlRet += '			<RetailSalesInternalId>' + cRetSaleId + '</RetailSalesInternalId>'

			// Lista de Impostos do item
			cChave := xFilial("CD2") + "S" + SD2->D2_SERIE + SD2->D2_DOC + SD2->D2_CLIENTE + SD2->D2_LOJA + PADR(SD2->D2_ITEM, TamSX3('CD2_ITEM')[1]) + SD2->D2_COD
			cXmlRet += '				<ListOfTaxes>'
			cXmlRet += '					<Tax>'
			cXmlRet += '  						<Taxe>COFINS</Taxe>'
			cXmlRet += '  						<Value>' 				+ CValToChar(POSICIONE("CD2",1,cChave+PADR("CF2",6),"CD2_VLTRIB"))	+ '</Value>'
			cXmlRet += '  						<CalculationBasis>' 	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("CF2",6),"CD2_BC"))		+ '</CalculationBasis>'
			cXmlRet += '						<Percentage>'			+ CValToChar(POSICIONE("CD2",1,cChave+PADR("CF2",6),"CD2_ALIQ")) 	+ '</Percentage>'
			cXmlRet += '						<CodeTaxSituation>'	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("CF2",6),"CD2_CST"))	+ '</CodeTaxSituation>'
			cXmlRet += '					</Tax>'
			cXmlRet += '					<Tax>'
			cXmlRet += '  						<Taxe>CSLL</Taxe>'
			cXmlRet += '  						<Value>' 				+ CValToChar(POSICIONE("CD2",1,cChave+PADR("CSL",6),"CD2_VLTRIB"))	+ '</Value>'
			cXmlRet += '  						<CalculationBasis>' 	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("CSL",6),"CD2_BC")) 	+ '</CalculationBasis>'
			cXmlRet += '						<Percentage>'			+ CValToChar(POSICIONE("CD2",1,cChave+PADR("CSL",6),"CD2_ALIQ"))	+ '</Percentage>'
			cXmlRet += '						<CodeTaxSituation>'	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("CSL",6),"CD2_CST"))	+ '</CodeTaxSituation>'
			cXmlRet += '					</Tax>'
			cXmlRet += '					<Tax>'
			cXmlRet += '  						<Taxe>ISS</Taxe>'
			cXmlRet += '  						<Value>' 				+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ISS",6),"CD2_VLTRIB"))	+ '</Value>'
			cXmlRet += '  						<CalculationBasis>' 	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ISS",6),"CD2_BC")) 	+ '</CalculationBasis>'
			cXmlRet += '						<Percentage>'			+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ISS",6),"CD2_ALIQ"))	+ '</Percentage>'
			cXmlRet += '						<CodeTaxSituation>'	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ISS",6),"CD2_CST"))	+ '</CodeTaxSituation>'
			cXmlRet += '					</Tax>'
			cXmlRet += '					<Tax>'
			cXmlRet += '  						<Taxe>PIS</Taxe>'
			cXmlRet += '  						<Value>' 				+ CValToChar(POSICIONE("CD2",1,cChave+PADR("PS2",6),"CD2_VLTRIB"))	+ '</Value>'
			cXmlRet += '  						<CalculationBasis>' 	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("PS2",6),"CD2_BC"))		+ '</CalculationBasis>'
			cXmlRet += '						<Percentage>'			+ CValToChar(POSICIONE("CD2",1,cChave+PADR("PS2",6),"CD2_ALIQ"))	+ '</Percentage>'
			cXmlRet += '						<CodeTaxSituation>'	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("PS2",6),"CD2_CST"))	+ '</CodeTaxSituation>'
			cXmlRet += '					</Tax>'
			cXmlRet += '					<Tax>'
			cXmlRet += '  						<Taxe>IPI</Taxe>'
			cXmlRet += '  						<Value>' 				+ CValToChar(POSICIONE("CD2",1,cChave+PADR("IPI",6),"CD2_VLTRIB"))	+ '</Value>'
			cXmlRet += '  						<CalculationBasis>' 	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("IPI",6),"CD2_BC")) 	+ '</CalculationBasis>'
			cXmlRet += '						<Percentage>'			+ CValToChar(POSICIONE("CD2",1,cChave+PADR("IPI",6),"CD2_ALIQ")) 	+ '</Percentage>'
			cXmlRet += '						<CodeTaxSituation>'	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("IPI",6),"CD2_CST"))	+ '</CodeTaxSituation>'
			cXmlRet += '					</Tax>'
			cXmlRet += '					<Tax>'
			cXmlRet += '  						<Taxe>ICM</Taxe>'
			cXmlRet += '  						<Value>' 				+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ICM",6),"CD2_VLTRIB"))	+ '</Value>'
			cXmlRet += '  						<CalculationBasis>' 	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ICM",6),"CD2_BC")) 	+ '</CalculationBasis>'
			cXmlRet += '						<Percentage>'			+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ICM",6),"CD2_ALIQ")) 	+ '</Percentage>'
			cXmlRet += '						<CodeTaxSituation>'	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ICM",6),"CD2_ORIGEM")+POSICIONE("CD2",1,cChave+PADR("ICM",6),"CD2_CST"))+ '</CodeTaxSituation>'
			cXmlRet += '					</Tax>'
			cXmlRet += '					<Tax>'
			cXmlRet += '  						<Taxe>ICMS_ST</Taxe>'
			cXmlRet += '  						<Value>' 				+ CValToChar(POSICIONE("CD2",1,cChave+PADR("SOL",6),"CD2_VLTRIB"))	+ '</Value>'
			cXmlRet += '  						<CalculationBasis>' 	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("SOL",6),"CD2_BC")) 	+ '</CalculationBasis>'
			cXmlRet += '						<Percentage>'			+ CValToChar(POSICIONE("CD2",1,cChave+PADR("SOL",6),"CD2_ALIQ")) 	+ '</Percentage>'
			cXmlRet += '						<CodeTaxSituation>'	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("SOL",6),"CD2_CST"))	+ '</CodeTaxSituation>'
			cXmlRet += '					</Tax>'

			If lD2FECP
				cXmlRet += '					<Tax>'
				cXmlRet += '  						<Taxe>FECP</Taxe>'
				cXmlRet += '  						<Value>' 				+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ICM",6),"CD2_VFCP"))	+ '</Value>'
				cXmlRet += '  						<CalculationBasis>' 	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ICM",6),"CD2_BFCP")) 	+ '</CalculationBasis>'
				cXmlRet += '						<Percentage>'			+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ICM",6),"CD2_PFCP")) 	+ '</Percentage>'
				cXmlRet += '						<CodeTaxSituation>'	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("ICM",6),"CD2_CST"))	+ '</CodeTaxSituation>'
				cXmlRet += '					</Tax>'
			EndIf

			If lD2FECPST
				cXmlRet += '					<Tax>'
				cXmlRet += '  						<Taxe>FECP_ST</Taxe>'
				cXmlRet += '  						<Value>' 				+ CValToChar(POSICIONE("CD2",1,cChave+PADR("SOL",6),"CD2_VFCP"))	+ '</Value>'
				cXmlRet += '  						<CalculationBasis>' 	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("SOL",6),"CD2_BFCP")) 	+ '</CalculationBasis>'
				cXmlRet += '						<Percentage>'			+ CValToChar(POSICIONE("CD2",1,cChave+PADR("SOL",6),"CD2_PFCP")) 	+ '</Percentage>'
				cXmlRet += '						<CodeTaxSituation>'	+ CValToChar(POSICIONE("CD2",1,cChave+PADR("SOL",6),"CD2_CST"))	+ '</CodeTaxSituation>'
				cXmlRet += '					</Tax>'
			EndIf

			cXmlRet += '			</ListOfTaxes>'
			cXMLRet += '         </Item> '
			SD2->(dbSkip())
			cChave := ""
		End
	Endif
	cXMLRet += '     </ListOfItens> '
	cXMLRet += ' </BusinessContent> '

Return {lRet, cXMLRet, "INVOICE"}

//-------------------------------------------------------------------
/*/{Protheus.doc} v4000
Implementação do adapter EAI, versão 4.x

@author  Alison Kaique
@version P12
@since   Jan/2019
/*/
//-------------------------------------------------------------------
Static Function v4000(cXML, cTypeTrans, cTypeMsg, cVersion, cTransac)

	Local lRet			:= .T.
	Local cXMLRet		:= ""
	Local cErroRet		:= ""
	Local cEvent		:= "upsert"
	Local cChave		:= ""
	Local nX

	Local cUndVer		:= MsgUVer('QIEA030', 'UNITOFMEASURE') //Versão da Unidade de Medida
	Local cConVer		:= MsgUVer('MATA360', 'PAYMENTCONDITION') //Versão da Condição de Pagamento
	Local cPrdVer		:= MsgUVer('MATA010', 'ITEM') //Versão do Produto
	Local cLocVer		:= MsgUVer('AGRA045', 'WAREHOUSE') //Versão do Local de Estoque

	Local aRestSE1		:= {}
	Local aRestSE2		:= {}
	Local aSE2RecNo		:= {}
	Local nTamPai		:= 0
	Local nProd			:= 0 //Valor Total do Produto
	Local nUnCom		:= 0
	Local nDesconto		:= 0 //Desconto aplicado
	Local cNatOper		:= ""//Natureza de Operacao
	Local cDescProd		:= ""//Descricao do Produto
	Local cPdVVer		:= MsgUVer('MATA410', 'ORDER') //Versão do Pedido de Venda
	Local cRetSaleId	:= ""
	Local aTaxesC		:= {}
	Local aTaxesI		:= {}
	Local aTaxVal       := {}

	Local cIntID		:= cEmpAnt + '|' + SF2->F2_FILIAL+ '|' + SF2->F2_DOC+ '|' + SF2->F2_SERIE+ '|' + SF2->F2_CLIENTE+ '|' + SF2->F2_LOJA
	Local aIntID		:= {}
	Local lD2FECP		:= SD2->(ColumnPos( "D2_ALQFECP" )) > 0 .And. SD2->(ColumnPos( "D2_VALFECP" )) > 0 .And. SD2->(ColumnPos( "D2_BASFECP" )) > 0// Verifica se os campos FECP existem
	Local lD2FECPST		:= SD2->(ColumnPos( "D2_ALFCPST" )) > 0 .And. SD2->(ColumnPos( "D2_VFECPST" )) > 0 .And. SD2->(ColumnPos( "D2_BSFCPST" )) > 0// Verifica se os campos FECP_ST existem

	Local aRetSale		:= {}

	Local cPurpose		:= "1"	// Propósito da nota fiscal - código da finalidade da nota fiscal de entrada.
								// 1 - Normal,
								// 2 - Complemento
								// 3 - Ajuste
								// 4 - Devolução

	Local cFilSAH		:= xFilial("SAH")
	Local cFilSB1		:= xFilial("SB1")
	Local cFilSE1		:= xFilial("SE1")
	Local cFilSE2 		:= xFilial("SE2")
	Local cFilSF4		:= xFilial("SF4")
	Local cFilSC5		:= xFilial("SC5")
	Local cFilSD2		:= xFilial("SD2")
	Local cFilNNR		:= xFilial("NNR")
	Local nTmCD2Item	:= TamSX3('CD2_ITEM')[1]

	If  !IsInCallStack("MATI461EAI") .And. !IsInCallStack("MATA310") //protege, Transferência de Filiais não inicializa Inclui/Altera (é sempre inclusão)
		If !Inclui .AND. !Altera
			cEvent := "delete"
		EndIf
	Endif

	If SF2->F2_TIPO == "D" //DEVOLUCAO
		cPurpose := "4"
	ElseIf SF2->F2_TIPO $ ("C|P|I|B") //COMPLEMENTO
		cPurpose := "2"
	Endif

	// Lista de impostos do cabeçalho.
	aAdd(aTaxesC, {"IPI",     SF2->F2_BASEIPI, SF2->F2_VALIPI,  .F.})
	aAdd(aTaxesC, {"ICM",     SF2->F2_BASEICM, SF2->F2_VALICM,  .F.})
	aAdd(aTaxesC, {"ICMS_ST", SF2->F2_BRICMS,  SF2->F2_ICMSRET, .F.})
	aAdd(aTaxesC, {"ISS",     SF2->F2_BASEISS, SF2->F2_VALISS,  SF2->F2_RECISS = "2"})
	aAdd(aTaxesC, {"PIS",     SF2->F2_BASIMP6, SF2->F2_VALIMP6, .F.})
	aAdd(aTaxesC, {"COFINS",  SF2->F2_BASIMP5, SF2->F2_VALIMP5, .F.})
	aAdd(aTaxesC, {"PIS",     SF2->F2_BASPIS,  SF2->F2_VALPIS,  .T.})
	aAdd(aTaxesC, {"COFINS",  SF2->F2_BASCOFI, SF2->F2_VALCOFI, .T.})
	aAdd(aTaxesC, {"CSLL",    SF2->F2_BASCSLL, SF2->F2_VALCSLL, .T.})
	aAdd(aTaxesC, {"IRRF",    SF2->F2_BASEIRR, SF2->F2_VALIRRF, .T.})
	aAdd(aTaxesC, {"INSS",    SF2->F2_BASEINS, SF2->F2_VALINSS, .T.})

	// Lista de impostos do item.
	aAdd(aTaxesI, {|| {"IPI",     "IPI", SD2->D2_BASEIPI, SD2->D2_IPI,     SD2->D2_VALIPI,  .F.}})
	aAdd(aTaxesI, {|| {"ICM",     "ICM", SD2->D2_BASEICM, SD2->D2_PICM,    SD2->D2_VALICM,  .F.}})
	aAdd(aTaxesI, {|| {"ICMS_ST", "SOL", SD2->D2_BRICMS,  SD2->D2_ALIQSOL, SD2->D2_ICMSRET, .F.}})
	aAdd(aTaxesI, {|| {"ISS",     "ISS", SD2->D2_BASEISS, SD2->D2_ALIQISS, SD2->D2_VALISS,  SF2->F2_RECISS = "2"}})
	aAdd(aTaxesI, {|| {"PIS",     "PS2", SD2->D2_BASIMP6, SD2->D2_ALQIMP6, SD2->D2_VALIMP6, .F.}})
	aAdd(aTaxesI, {|| {"COFINS",  "CF2", SD2->D2_BASIMP5, SD2->D2_ALQIMP5, SD2->D2_VALIMP5, .F.}})
	aAdd(aTaxesI, {|| {"PIS",     "   ", SD2->D2_BASEPIS, SD2->D2_ALQPIS,  SD2->D2_VALPIS,  .T.}})
	aAdd(aTaxesI, {|| {"COFINS",  "   ", SD2->D2_BASECOF, SD2->D2_ALQCOF,  SD2->D2_VALCOF,  .T.}})
	aAdd(aTaxesI, {|| {"CSLL",    "   ", SD2->D2_BASECSL, SD2->D2_ALQCSL,  SD2->D2_VALCSL,  .T.}})
	aAdd(aTaxesI, {|| {"IRRF",    "   ", SD2->D2_BASEIRR, SD2->D2_ALQIRRF, SD2->D2_VALIRRF, .T.}})
	aAdd(aTaxesI, {|| {"INSS",    "ISS", SD2->D2_BASEINS, SD2->D2_ALIQINS, SD2->D2_VALINS,  .T.}})

	//FECP
	If (lD2FECP)
		aAdd(aTaxesI, {|| {"FECP", "ICM", SD2->D2_BASFECP, SD2->D2_ALQFECP, SD2->D2_VALFECP,  .F.}})
	EndIf

	//FECP-ST
	If (lD2FECPST)
		aAdd(aTaxesI, {|| {"FECP_ST", "SOL", SD2->D2_BSFCPST, SD2->D2_ALFCPST, SD2->D2_VFECPST,  .T.}})
	EndIf

	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>INVOICE</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="InternalId">'	+ cIntID + '</key>'
	cXMLRet +=         '<key name="InvoiceNumber">'	+ RTrim(SF2->F2_DOC)		+ '</key>'
	cXMLRet +=         '<key name="InvoiceSerie">'	+ RTrim(SF2->F2_SERIE)		+ '</key>'
	cXMLRet +=         '<key name="CustomerCode">'	+ RTrim(SF2->F2_CLIENTE)	+ '</key>'
	cXMLRet +=         '<key name="ShopCode">'		+ RTrim(SF2->F2_LOJA)		+ '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'

	cXMLRet += '<BusinessContent>'
    cXMLRet +=      '<CompanyId>' 				+ RTrim(cEmpAnt) + '</CompanyId>'
    cXMLRet +=      '<BranchId>' 				+ RTrim(cFilAnt) + '</BranchId>'
   	cXMLRet +=      '<CompanyInternalId>'		+ RTrim(cEmpAnt) + '|' + RTrim(cFilAnt) + '</CompanyInternalId>'
	cXMLRet +=      '<InternalId>'				+ cIntID + '</InternalId>'
	cXMLRet +=      '<InvoiceNumber>'			+ RTrim(SF2->F2_DOC) + '</InvoiceNumber>'
	cXMLRet +=      '<InvoiceSerie>'			+ RTrim(SF2->F2_SERIE) + '</InvoiceSerie>'
	cXMLRet +=      '<InvoiceSituation>1</InvoiceSituation>'
	If SF2->F2_TIPO $ "DB"
		cXmlRet +=      '<VendorInternalId>'	+ IntForExt(,, SF2->F2_CLIENTE, SF2->F2_LOJA)[2] + '</VendorInternalId>'
	Else
		cXmlRet +=      '<CustomerInternalId>'	+ IntCliExt(,, SF2->F2_CLIENTE, SF2->F2_LOJA)[2] + '</CustomerInternalId>'
	Endif
	cXMLRet +=      '<IssueDate>'				+ Transform(DToS(SF2->F2_EMISSAO), "@R 9999-99-99") + '</IssueDate>'
	cXMLRet +=      '<InvoiceAmount>'			+ cValtoChar(SF2->F2_VALBRUT) + '</InvoiceAmount>'
	cXMLRet +=      '<ValueofGoods>'			+ cValtoChar(SF2->F2_VALMERC) + '</ValueofGoods>'
	cXMLRet +=      '<FreightAmount>'			+ cValtoChar(SF2->F2_FRETE) + '</FreightAmount>'
	cXMLRet +=      '<InsuranceAmount>'			+ cValtoChar(SF2->F2_SEGURO) + '</InsuranceAmount>'
	cXMLRet +=      '<DiscountAmount>'			+ cValtoChar(SF2->F2_DESCONT) + '</DiscountAmount>'
	//Tag CurrencyRate é utilizada em Documento de Entrada (F1_TXMOEDA), não enviar aqui no Documento de Saída
	cXMLRet +=      '<PaymentConditionCode>'	+ RTrim(SF2->F2_COND) + '</PaymentConditionCode>'
	cXMLRet +=      '<PaymentConditionInternalId>'	+ IntConExt(/*Empresa*/,/*Filial*/, SF2->F2_COND, cConVer)[2] + '</PaymentConditionInternalId>'
	cXMLRet +=      '<CustomerCode>'			+ RTrim(SF2->F2_CLIENTE) + '</CustomerCode>'
	cXMLRet +=      '<StoreCode>'				+ RTrim(SF2->F2_LOJA) + '</StoreCode>'
	cXMLRet +=      '<Purpose>'					+ cPurpose + '</Purpose>'
	cXMLRet +=      '<FinalConsumerIndicator>'	+ IIF(SF2->F2_TIPOCLI == "F", "1", "0") + '</FinalConsumerIndicator>'
	cXMLRet +=      '<IcmsPayTaxIndicator>'		+ RTrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_CONTRIB")) + '</IcmsPayTaxIndicator>'
	cXMLRet +=      '<ElectronicAccessKey>'		+ RTrim(SF2->F2_CHVNFE) + '</ElectronicAccessKey>'

	cXMLRet +=      '<InvoiceTime>'		    + RTrim(SF2->F2_HORA   ) + '</InvoiceTime>'
	cXMLRet +=      '<InvoiceMessage>'		+ RTrim(SF2->F2_MENNOTA) + '</InvoiceMessage>'
	
	cXmlRet +=      '<ListOfSeller>'
    cXMLRet +=        Iif(!Empty(SF2->F2_VEND1),'<InternalId Name="Seller1" SellerName="' + RTrim(AllTrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_NOME"))) + '" Code="' + RTrim(SF2->F2_VEND1) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SA3")) + "|" + Rtrim(SF2->F2_VEND1)   + '</InternalId>', "")
    cXMLRet +=        Iif(!Empty(SF2->F2_VEND2),'<InternalId Name="Seller2" SellerName="' + RTrim(AllTrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND2,"A3_NOME"))) + '" Code="' + RTrim(SF2->F2_VEND2) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SA3")) + "|" + Rtrim(SF2->F2_VEND2)   + '</InternalId>', "")
    cXMLRet +=        Iif(!Empty(SF2->F2_VEND3),'<InternalId Name="Seller3" SellerName="' + RTrim(AllTrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND3,"A3_NOME"))) + '" Code="' + RTrim(SF2->F2_VEND3) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SA3")) + "|" + Rtrim(SF2->F2_VEND3)   + '</InternalId>', "")
    cXMLRet +=        Iif(!Empty(SF2->F2_VEND4),'<InternalId Name="Seller4" SellerName="' + RTrim(AllTrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND4,"A3_NOME"))) + '" Code="' + RTrim(SF2->F2_VEND4) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SA3")) + "|" + Rtrim(SF2->F2_VEND4)   + '</InternalId>', "")
    cXMLRet +=        Iif(!Empty(SF2->F2_VEND5),'<InternalId Name="Seller5" SellerName="' + RTrim(AllTrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND5,"A3_NOME"))) + '" Code="' + RTrim(SF2->F2_VEND5) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SA3")) + "|" + Rtrim(SF2->F2_VEND5)   + '</InternalId>', "")				
	cXmlRet +=      '</ListOfSeller>'

	cXmlRet +=      '<ListOfTaxes>'
	For nX := 1 to len(aTaxesC)
		If aTaxesC[nX, 3] <> 0
			cXmlRet +=           '<Tax>'
			cXmlRet +=                '<Tax>' + aTaxesC[nX, 1] + '</Tax>'
			cXMLRet +=                '<CalculationBasis>' + cValToChar(aTaxesC[nX, 2]) + '</CalculationBasis>'
			cXmlRet +=                '<Value>' + cValToChar(aTaxesC[nX, 3]) + '</Value>'
			cXMLRet +=                '<WithHoldingTax>' + If(aTaxesC[nX, 4], 'true', 'false') + '</WithHoldingTax>'
			cXmlRet +=           '</Tax>'
		Endif
	Next nX
	cXmlRet +=      '</ListOfTaxes>'

	// Lista de títulos financeiros.
	If val(cVersion) >= 4.001
		cXMLRet +=    '<ListOfFinancialDocument>'

		aRestSE1 := SE1->(GetArea())
		aRestSE2 := SE2->(GetArea())
		nTamPai  := TamSX3("E2_TITPAI")[1]

		// Títulos a receber.
		SE1->(dbSetOrder(1))  // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		SE1->(dbSeek(cFilSE1 + SF2->F2_PREFIXO + SF2->F2_DUPL))
		Do While SE1->(! Eof()) .and. SE1->E1_FILIAL == cFilSE1 .and. SE1->E1_PREFIXO == SF2->F2_PREFIXO .and. SE1->E1_NUM == SF2->F2_DUPL
			cXMLRet +=    '<FinancialDocument>'
			cXMLRet +=      '<FinancialAccount>Receivable</FinancialAccount>'
			cXMLRet +=      '<DocumentPrefix>' + RTrim(SE1->E1_PREFIXO) + '</DocumentPrefix>'
			cXMLRet +=      '<DocumentNumber>' + RTrim(SE1->E1_NUM) + '</DocumentNumber>'
			cXMLRet +=      '<DocumentParcel>' + RTrim(SE1->E1_PARCELA) + '</DocumentParcel>'
			cXMLRet +=      '<DocumentTypeCode>' + RTrim(SE1->E1_TIPO) + '</DocumentTypeCode>'
			cXMLRet +=      '<CustomerVendorInternalId>' + IntCliExt(,, SE1->E1_CLIENTE, SE1->E1_LOJA)[2] + '</CustomerVendorInternalId>'
			cXMLRet +=      '<FinancialDocumentInternalId>' + SE1->(IntTRcExt(, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO)[2]) + '</FinancialDocumentInternalId>'
			cXMLRet +=      '<DueDate>' + INTDTANO(SE1->E1_VENCTO) + '</DueDate>'
			cXMLRet +=      '<RealDueDate>' + INTDTANO(SE1->E1_VENCREA) + '</RealDueDate>'
			cXMLRet +=      '<Value>' + cValToChar(SE1->E1_VALOR) + '</Value>'
			cXMLRet +=      '<CurrencyCode>' + PadL(SE1->E1_MOEDA, 2, '0') +'</CurrencyCode>'
			cXmlRet +=      '<CurrencyInternalId>' + IntMoeExt(,, PadL(SE1->E1_MOEDA, 2, '0'), MsgUVer('CTBA140', 'CURRENCY'))[2] + '</CurrencyInternalId>'
			cXMLRet +=      '<FinancialNatureInternalId>' + F10MontInt(, SE1->E1_NATUREZ) + '</FinancialNatureInternalId>'
			cXMLRet +=    '</FinancialDocument>'

			// Pega títulos de taxa a pagar atrelados ao título a receber posicionado.
			SE2->(dbSetOrder(17))  // E2_FILIAL, E2_TITPAI.
			cChave := PadR(SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA, nTamPai)
			SE2->(dbSeek(cFilSE2 + cChave, .F.))
			Do While SE2->(! Eof()) .and. SE2->E2_FILIAL == cFilSE2 .and. SE2->E2_TITPAI == cChave
				aAdd(aSE2RecNo, SE2->(RecNo()))
				SE2->(dbSkip())
			EndDo

			SE1->(dbSkip())
		EndDo

		// Títulos a pagar.
		For nX := 1 to len(aSE2RecNo)
			SE2->(dbGoTo(aSE2RecNo[nX]))
			cXMLRet +=    '<FinancialDocument>'
			cXMLRet +=      '<FinancialAccount>Payable</FinancialAccount>'
			cXMLRet +=      '<DocumentPrefix>' + RTrim(SE2->E2_PREFIXO) + '</DocumentPrefix>'
			cXMLRet +=      '<DocumentNumber>' + RTrim(SE2->E2_NUM) + '</DocumentNumber>'
			cXMLRet +=      '<DocumentParcel>' + RTrim(SE2->E2_PARCELA) + '</DocumentParcel>'
			cXMLRet +=      '<DocumentTypeCode>' + RTrim(SE2->E2_TIPO) + '</DocumentTypeCode>'
			cXMLRet +=      '<CustomerVendorInternalId>' + IntForExt(,, SE2->E2_FORNECE, SE2->E2_LOJA)[2] + '</CustomerVendorInternalId>'
			cXMLRet +=      '<FinancialDocumentInternalId>' + SE2->(IntTPgExt(, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA)[2]) + '</FinancialDocumentInternalId>'
			cXMLRet +=      '<DueDate>' + INTDTANO(SE2->E2_VENCTO) + '</DueDate>'
			cXMLRet +=      '<RealDueDate>' + INTDTANO(SE2->E2_VENCREA) + '</RealDueDate>'
			cXMLRet +=      '<Value>' + cValToChar(SE2->E2_VALOR) + '</Value>'
			cXMLRet +=      '<CurrencyCode>' + PadL(SE2->E2_MOEDA, 2, '0') +'</CurrencyCode>'
			cXmlRet +=      '<CurrencyInternalId>' + IntMoeExt(,, PadL(SE2->E2_MOEDA, 2, '0'), MsgUVer('CTBA140', 'CURRENCY'))[2] + '</CurrencyInternalId>'
			cXMLRet +=      '<FinancialNatureInternalId>' + F10MontInt(, SE2->E2_NATUREZ) + '</FinancialNatureInternalId>'
			cXMLRet +=    '</FinancialDocument>'
		Next nX

		RestArea(aRestSE1)
		RestArea(aRestSE2)
		aSize(aRestSE1,  0)
		aSize(aRestSE2,  0)
		aSize(aSE2RecNo, 0)

		cXMLRet +=    '</ListOfFinancialDocument>'
	Endif

	cXMLRet +=      '<ListOfItems>'
	SD2->(DbSetOrder(3))  // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM.
	SD2->(DbSeek(cFilSD2 + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA, .F.))
	While SD2->(! EOF())                     .AND.;
	      SD2->D2_FILIAL  == cFilSD2         .AND.;
	      SD2->D2_DOC     == SF2->F2_DOC     .AND.;
	      SD2->D2_SERIE   == SF2->F2_SERIE   .AND.;
	      SD2->D2_CLIENTE == SF2->F2_CLIENTE .AND.;
	      SD2->D2_LOJA    == SF2->F2_LOJA

		//Tratamentos retirados no programa de geração de xml para SEFAZ (NFESEFAZ.PRW)
		If SD2->D2_ORIGLAN == "VD"
			nDesconto := Round(SD2->D2_QUANT * SD2->D2_PRUNIT, 2) + SD2->D2_VALACRS - SD2->D2_TOTAL
		Else
			nDesconto := SD2->D2_DESCON
		EndIf

		cDescProd	:= Posicione("SB1",1,cFilSB1+SD2->D2_COD,"B1_DESC")
		cNatOper	:= SF3->F3_ISSST
		nProd	 	:= IIF(!SD2->D2_TIPO $ "IP",;
		     		       SD2->D2_TOTAL + nDesconto + SD2->D2_DESCZFR,;
		     		       IIF((SD2->D2_TIPO == "I" .And. SF4->F4_AJUSTE == "S" .And. SubStr(SM0->M0_CODMUN,1,2) == "31") .Or.;
		     		           (SD2->D2_TIPO == "I" .And. SF4->F4_AJUSTE == "S" .And. "RESSARCIMENTO" $ Upper(cNatOper) .And. "RESSARCIMENTO" $ Upper(cDescProd)),;
		     		            SD2->D2_TOTAL,;
		     		            0))
		nUnCom		:= nProd / SD2->D2_QUANT

		cXMLRet +=           '<Item>'
		cXMLRet +=                '<InvoiceSequence>' 	+ RTrim(SD2->D2_NUMSEQ)					+ '</InvoiceSequence>'
		cXMLRet +=                '<ItemInvoice>' 		+ LTrim(Str(DecodSoma1(SD2->D2_ITEM)))	+ '</ItemInvoice>'
		cXMLRet +=                '<OrderNumber>' 		+ RTrim(SD2->D2_PEDIDO)					+ '</OrderNumber>'
		//OrderInternalId --> Retorna e Verifica
		aIntID := IntPdVExt(cEmpAnt, cFilSC5, SD2->D2_PEDIDO,/*cItem*/, cPdVVer)
		If (aIntID[01])
			cXMLRet +=                '<OrderInternalId>'  + aIntID[02] + '</OrderInternalId>'
		Else
			cErroRet += aIntID[02] + CRLF + CRLF
		EndIf
		cXMLRet +=                '<OrdemItem>' 		+ RTrim(SD2->D2_ITEMPV)	+ '</OrdemItem>'
		cXmlRet +=                '<ItemCode>'			+ RTrim(SD2->D2_COD)	+ '</ItemCode>'
		//OrderInternalId --> Retorna e Verifica
		aIntID := IntProExt(cEmpAnt,cFilSB1,SD2->D2_COD,cPrdVer)
		If (aIntID[01])
			cXmlRet +=                '<ItemInternalId>' + aIntID[02] + '</ItemInternalId>'
		Else
			cErroRet += aIntID[02] + CRLF + CRLF
		EndIf
		cXMLRet +=                '<Quantity>'			+ cValtoChar(SD2->D2_QUANT)	+ '</Quantity>'
		cXmlRet +=                '<UnitofMeasureCode>'	+ RTrim(SD2->D2_UM)			+ '</UnitofMeasureCode>'
		//OrderInternalId --> Retorna e Verifica
		aIntID := IntUndExt(cEmpAnt,cFilSAH,SD2->D2_UM,cUndVer)
		If (aIntID[01])
			cXmlRet +=                '<UnitofMeasureInternalId>' + aIntID[02] + '</UnitofMeasureInternalId>'
		Else
			cErroRet += aIntID[02] + CRLF + CRLF
		EndIf
		cXMLRet +=                '<UnityPrice>'		+ cValtoChar(nUnCom)			+ '</UnityPrice>'
		cXMLRet +=                '<GrossValue>'		+ cValtoChar(nProd)				+ '</GrossValue>'
		cXMLRet +=                '<FreightValue>'		+ cValtoChar(SD2->D2_VALFRE)	+ '</FreightValue>'
		cXMLRet +=                '<InsuranceValue>'	+ cValtoChar(SD2->D2_SEGURO)	+ '</InsuranceValue>'
		cXMLRet +=                '<DiscountValue>'		+ cValtoChar(SD2->D2_DESCON)	+ '</DiscountValue>'
		cXMLRet +=                '<NetValue>'			+ cValToChar(SD2->D2_PESO)		+ '</NetValue>'
		cXMLRet +=                '<WarehouseCode>'		+ RTrim(SD2->D2_LOCAL)			+ '</WarehouseCode>'
		cXMLRet +=                '<OperFiscalCode>'	+ RTrim(SD2->D2_CF)			    + '</OperFiscalCode>'

		//OrderInternalId --> Retorna e Verifica
		aIntID := IntLocExt(cEmpAnt,cFilNNR,SD2->D2_LOCAL,cLocVer)
		If (aIntID[01])
			cXMLRet +=                '<WarehouseInternalId>' + aIntID[02] + '</WarehouseInternalId>'
		Else
			cErroRet += aIntID[02] + CRLF + CRLF
		EndIf
		cXMLRet +=                '<LotNumber>'		+ RTrim(SD2->D2_LOTECTL)	+ '</LotNumber>'
		cXMLRet +=                '<SubLotNumber>' 	+ RTrim(SD2->D2_NUMLOTE)	+ '</SubLotNumber>'
		If !(Empty(SD2->D2_DTVALID))
			cXMLRet +=                '<LotExpirationDate>' + Transform(DToS(SD2->D2_DTVALID), "@R 9999-99-99") + '</LotExpirationDate>'
		EndIf
		cXMLRet +=                '<TaxOpCodeItem>' + RTrim(SD2->D2_CF) + '</TaxOpCodeItem>'
		cXmlRet +=                '<ListOfTaxes>'
		cChave := cFilSD2 + "S" + SD2->D2_SERIE + SD2->D2_DOC + SD2->D2_CLIENTE + SD2->D2_LOJA + PadR(SD2->D2_ITEM, nTmCD2Item) + SD2->D2_COD
		For nX := 1 to len(aTaxesI)
			aTaxVal := Eval(aTaxesI[nX])
			If aTaxVal[5] <> 0
				cXmlRet +=                     '<Tax>'
				cXmlRet +=                          '<Tax>' + aTaxVal[1] + '</Tax>'
				cXMLRet +=                          '<CalculationBasis>' + cValToChar(aTaxVal[3]) + '</CalculationBasis>'
				cXMLRet +=                          '<Percentage>' + cValToChar(aTaxVal[4]) + '</Percentage>'
				cXmlRet +=                          '<Value>' + cValToChar(aTaxVal[5]) + '</Value>'
				If !empty(aTaxVal[2])
					CD2->(dbSetOrder(1))  // CD2_FILIAL, CD2_TPMOV, CD2_SERIE, CD2_DOC, CD2_CODCLI, CD2_LOJCLI, CD2_ITEM, CD2_CODPRO, CD2_IMP.
					If CD2->(dbSeek(cChave + PadR(aTaxVal[2], 6), .F.))
						cXMLRet +=                          '<CodeTaxSituation>' + RTrim(CD2->CD2_CST) + '</CodeTaxSituation>'
					Endif
				Endif
				cXMLRet +=                          '<WithHoldingTax>' + If(aTaxVal[6], 'true', 'false') + '</WithHoldingTax>'
				cXmlRet +=                     '</Tax>'
			Endif
		Next nX
		cXmlRet +=                '</ListOfTaxes>'

		SF4->(dbSetOrder(1))  // F4_FILIAL, F4_CODIGO.
		If SF4->(msSeek(cFilSF4 + SD2->D2_TES, .F.))
			cXMLRet +=    '<UpdateStock>' + If(SF4->F4_ESTOQUE == 'S', 'true', 'false') + '</UpdateStock>'
		EndIf

		//Venda Varejo que originou Pedido de Venda
		cRetSaleId := ""
		If _lBRetail
			SC5->(dbSetOrder(1)) // C5_FILIAL + C5_NUM
			If SC5->(MsSeek(cFilSC5 + SD2->D2_PEDIDO, .F.)) .and. !Empty(SC5->C5_ORCRES)
				LjGrvLog("MATI461" , "SC5->C5_ORCRES:= " + SC5->C5_ORCRES)
				LjGrvLog("MATI461" , "SC5->C5_FILIAL:= " + SC5->C5_FILIAL)

				aRetSale := A410BRETAIL(SC5->C5_ORCRES, SC5->C5_FILIAL)

				If Len(aRetSale) > 0
					cRetSaleId := IntVendExt(,aRetSale[1],aRetSale[2],aRetSale[3],aRetSale[4])[2]
				EndIf
			EndIf
		EndIf
		cXmlRet +=                '<RetailSalesInternalId>' + cRetSaleId + '</RetailSalesInternalId>'

		cXMLRet +=           '</Item>'
		SD2->(dbSkip())
		cChave := ""
	EndDo

	cXMLRet +=      '</ListOfItems>'
	cXMLRet += '</BusinessContent>'

Return {lRet, cXMLRet, "INVOICE"}

//-------------------------------------------------------------------
/*{Protheus.doc} MATI461EAI
Funcao para chamada do MATI461 devido a alteracao do xsd Invoice 3.009
que envia a chave da NFe. A chamada desta funcao esta no autoNfeBusiness
na funcion monitorUpd.
@since 18//08/2017
@version P12.1.17
@param	cEmpant	- Empresa corrente.
@param	cFilAnt 	- Filial corrente.
@param	sf2doc 	- Número da Nota Fiscal Autorizada pela Sefaz
@param sf2serie 	- Serie da Nota Fiscal Autorizada pela Sefaz

*/
//-------------------------------------------------------------------

Function MATI461EAI (cEmpant,cFilAnt,sf2doc,sf2serie)

Local aAreaSD2		:= {}

	//Inicia Ambiente
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cEmpant  FILIAL cFilAnt Modulo "FAT"

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))

	If SF2->(DbSeek(xFilial("SF2")+sf2doc+sf2serie ) )
		DbSelectArea("SD2")
		SD2->(DbSetOrder(3)) //D2_FILIAL, D2_DOC, D2_SERIE
		If SD2->(DbSeek(xFilial("SD2")+sf2doc+sf2serie ) )

			//Envio nota fiscal de saida
			aAreaSD2 := SD2->(GetArea())
			If FWHasEAI("MATA461",.T.,,.T.)
				FwIntegDef("MATA461",,,, "MATA461")
			EndIf
			RestArea(aAreaSD2)

			DbSelectArea("SC5")
			SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM
			If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO ) )

				//Envio rastreabilidade de pedidos
				If FWHasEAI("MATA410B",.T.,,.T.)

					//Verifica se é um pedido gerado pelo Loja e atualiza status do pedido (C5_STATUS)
					If ExistFunc("LjxjAtStTr") .And. !Empty(SC5->C5_ORCRES)
						LjxjAtStTr()
					EndIf

					FwIntegDef("MATA410B")
				EndIf
			EndIf
		EndIf
	EndIf

aSize(aAreaSD2,0)
Return

/*/{Protheus.doc} MsgUVer
	Função que verifica a versão de uma mensagem única cadastrada no adapter EAI.

	Essa função deverá ser EXCLUÍDA e substituída pela função FwAdapterVersion()
	após sua publicação na Lib de 2019.

	@param cRotina		Rotina que possui a IntegDef da Mensagem Unica
	@param cMensagem	Nome da Mensagem única a ser pesquisada

	@author		Felipe Raposo
	@version	P12
	@since		23/11/2018
	@return		xVersion - versão da mensagem única cadastrada. Se não encontrar, retorna nulo.
/*/
Static Function MsgUVer(cRotina, cMensagem)

Local aArea    := GetArea()
Local aAreaXX4 := XX4->(GetArea())
Local xVersion

If FindFunction("FwAdapterVersion")
	xVersion := FwAdapterVersion(cRotina, cMensagem)
ElseIf XX4->(ColumnPos('XX4_SNDVER')) > 0
	cMensagem := Padr(cMensagem, Len(XX4->XX4_MODEL))
	cRotina   := Padr(cRotina,   Len(XX4->XX4_ROTINA))
	XX4->(dbSetOrder(1))  // XX4_FILIAL+XX4_ROTINA+XX4_MODEL+XX4_FILEXE
	If XX4->(msSeek(xFilial() + cRotina + cMensagem, .F.) .and. !empty(XX4_SNDVER))
		xVersion := AllTrim(XX4->XX4_SNDVER)
	Endif
Endif

RestArea(aAreaXX4)
RestArea(aArea)
aSize(aAreaXX4,0)
aSize(aArea,0)

Return xVersion