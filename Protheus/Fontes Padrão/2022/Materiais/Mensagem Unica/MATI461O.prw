#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI461.CH" 
#INCLUDE "TBICONN.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATI461O   ºAutor  ³Totvs Cascavel     º Data ³  03/07/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para envio e   	  º±±
±±º          ³ recebimento do Nota Fiscal Saida (SF2/SD2)  utilizando o   º±±
±±º          ³ conceito de mensagem unica (Invoice).				      º±±
±±º          ³                                                            º±±
±±º          ³ Versao convertida 3.011                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATI461O                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATI461O(oEAIObEt, nTypeTrans, cTypeMessage)

Local lRet      	:= .T.
Local cEvent		:= "upsert"
Local aAreaOld		:= (Alias())->(GetArea())
Local aAreaSF2		:= SF2->(GetArea())
Local aAreaSD2		:= SD2->(GetArea())
Local cFilSD2		:= ""
Local cFilSB1		:= ""
Local cFilSC5		:= ""
Local cFilSC6		:= ""
Local cFilSAH		:= ""
Local cFilNNR		:= ""
Local cMarca		:= " "
Local cConVer		:= RTrim(PmsMsgUVer('PAYMENTCONDITION', 'MATA360')) //Versão da Condição de Pagamento
Local cChave		:= ""	//Chave para pesquisa da CD2
Local nTmCD2Item	:= 0
Local vProd			:= 0	//Valor Total do Produto
Local nDesconto		:= 0	//Desconto aplicado
Local cNatOper		:= ""	//Natureza de Operacao
Local cDescProd		:= ""	//Descricao do Produto
Local cPdVVer       := RTrim(PmsMsgUVer('ORDER','MATA410')) //Versão do Pedido de Venda
Local aRetSale		:= {}
Local cRetSaleId	:= ""
Local cPurpose		:= "1" //Proposito da Nota Fiscal -  Código da finalidade da nota fiscal de entrada
							// 1 - normal,
 							// 2 - Complemento
 							// 3 - Ajuste
 							// 4 - Devolução
//Instancia objeto JSON
Local ofwEAIObj		:= FWEAIObj():New()
Local cMsgUnica		:= "INVOICE"
Local nX			:= 0
Local lDelete		:= .F.
Local lA410BRetail	:= FindFunction("A410BRETAIL")

//--------------------------------------
//recebimento mensagem
//--------------------------------------
If nTypeTrans == TRANS_RECEIVE .And. ValType(oEAIObEt) == 'O'

	//--------------------------------------
	//chegada de mensagem de negocios
	//--------------------------------------
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		lRet     := .F.
		cLogErro := ""
		ofwEAIObj:Activate()
		ofwEAIObj:setProp("ReturnContent")
		cLogErro := STR0004 //"Está operação não é suportada por está integração"
		ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)

	//--------------------------------------
	//resposta da mensagem Unica TOTVS
	//--------------------------------------
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

		// ------------------------------------------------------------
		//  Identifica se o processamento pelo parceiro ocorreu com
		// sucesso.
		If Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK"

			cMarca := oEAIObEt:getHeaderValue("ProductName")

			//Verifica se o evento e delete
			If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "DELETE"
				lDelete := .T.
			Endif

			If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID") !=  nil
				If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil  .And.;
					oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") != nil .And.;
					CFGA070Mnt(cMarca, 'SF2', 'F2_DOC',;
					           oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination"),;
					           oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin"), lDelete)
				Else
					lRet     := .F.
					cLogErro := ""
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0001 //"De-Para não pode ser gravado a integração poderá ter falhas"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
				EndIf
			EndIf
		Else
			lRet     := .F.
			cLogErro := STR0002 //"Processamento pela outra aplicação não teve sucesso"
			If oEAIObEt:getpropvalue('ProcessingInformation') != nil
				oMsgError := oEAIObEt:getpropvalue('ProcessingInformation'):getpropvalue("ListOfMessages")
				For nX := 1 To Len( oMsgError )
					cLogErro += oMsgError[nX]:getpropvalue('Message') + CRLF
				Next nX
			EndIf
			ofwEAIObj:Activate()
			ofwEAIObj:setProp("ReturnContent")
			ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)

			If InTransaction()
				DisarmTransaction()
			EndIf
		EndIf

	//--------------------------------------
	//whois
	//--------------------------------------
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		Return {.T., '3.009', cMsgUnica}
 	Endif

//--------------------------------------
//envio mensagem
//--------------------------------------
ElseIf nTypeTrans == TRANS_SEND

	If  !IsInCallStack("MATI461EAI") .And. !IsInCallStack("MATA310") //protege, Transferência de Filiais não inicializa Inclui/Altera (é sempre inclusão)
		If !Inclui .AND. !Altera
			cEvent	:=	"Delete"
		EndIf
	Endif

	If SF2->F2_TIPO == "D" //DEVOLUCAO
		cPurpose := "4"
	ElseIf SF2->F2_TIPO $ ("C|P|I|B") //COMPLEMENTO
		cPurpose := "2"
	// 3 - Ajuste
	Endif

	ofwEAIObj:Activate()

	ofwEAIObj:setEvent(cEvent)

	ofwEAIObj:setprop("CompanyId",              cEmpAnt)
	ofwEAIObj:setprop("BranchId",               cFilAnt)
	ofwEAIObj:setprop("CompanyInternalId",      cEmpAnt + '|' + RTrim(xFilial("SF2")))
	ofwEAIObj:setprop("InternalId",             cEmpAnt + '|' + SF2->F2_FILIAL + '|' + SF2->F2_DOC + '|' + SF2->F2_SERIE + '|' + SF2->F2_CLIENTE + '|' + SF2->F2_LOJA)
	ofwEAIObj:setprop("InvoiceNumber",          AllTrim(SF2->F2_DOC))
	ofwEAIObj:setprop("InvoiceSerie",           AllTrim(SF2->F2_SERIE))
	ofwEAIObj:setprop("InvoiceSituation",       "1")
	ofwEAIObj:setprop("IssueDate",              Transform(DtoS(SF2->F2_EMISSAO),'@R 9999-99-99'))
	ofwEAIObj:setprop("InvoiceAmount",          SF2->F2_VALBRUT)
	ofwEAIObj:setprop("ValueofGoods",           SF2->F2_VALMERC)
	ofwEAIObj:setprop("FreightAmount",          SF2->F2_FRETE)
	ofwEAIObj:setprop("InsuranceAmount",        SF2->F2_SEGURO)
	ofwEAIObj:setprop("DiscountAmount",         SF2->F2_DESCONT)
	ofwEAIObj:setprop("CurrencyRate",           "")
	ofwEAIObj:setprop("PaymentConditionCode",   IntConExt(/*Empresa*/,/*Filial*/, SF2->F2_COND, cConVer)[2])
	ofwEAIObj:setprop("CustomerCode",           SF2->F2_CLIENTE)
	ofwEAIObj:setprop("StoreCode",              SF2->F2_LOJA)
	ofwEAIObj:setprop("CustomerInternalId",     IntCliExt(,, SF2->F2_CLIENTE, SF2->F2_LOJA)[2])
	ofwEAIObj:setprop("ElectronicAccessKey",    AllTrim(SF2->F2_CHVNFE))
	ofwEAIObj:setprop("Purpose",                cPurpose)
	ofwEAIObj:setprop("FinalConsumerIndicator", IIF(SF2->F2_TIPOCLI == "F","1","0"))
	ofwEAIObj:setprop("IcmsPayTaxIndicator",    AllTrim(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_CONTRIB")))

	ofwEAIObj:setprop("InvoiceTime"    ,   RTrim(SF2->F2_HORA     ))
	ofwEAIObj:setprop("InvoiceMessage" ,   RTrim(SF2->F2_MENNOTA  ))
	//Lista de Vendedores
	//vend1
	oObjLSe := ofwEAIObj:setprop('ListOfSeller',{},'Seller',,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("Code"       ,  RTrim(SF2->F2_VEND1),        ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("InternalId" ,  Iif(!Empty(SF2->F2_VEND1),cEmpAnt + '|' + Alltrim(xFilial("SA3")) + '|' + SF2->F2_VEND1     , ""),        ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("SellerName" ,  Iif(!Empty(SF2->F2_VEND1),AllTrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_NOME")), ""), ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("Name"       , "Seller1", ,.T.)

	//vend2
	oObjLSe := ofwEAIObj:setprop('ListOfSeller',{},'Seller',,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("Code"       ,  RTrim(SF2->F2_VEND2),        ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("InternalId" ,  Iif(!Empty(SF2->F2_VEND2),cEmpAnt + '|' + Alltrim(xFilial("SA3")) + '|' + SF2->F2_VEND2     , "")     ,  ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("SellerName" ,  Iif(!Empty(SF2->F2_VEND2),AllTrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND2,"A3_NOME")), ""), ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("Name"       , "Seller2", ,.T.)

	//vend3
	oObjLSe := ofwEAIObj:setprop('ListOfSeller',{},'Seller',,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("Code"       ,  RTrim(SF2->F2_VEND3),        ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("InternalId" ,  Iif(!Empty(SF2->F2_VEND3),cEmpAnt + '|' + Alltrim(xFilial("SA3")) + '|' + SF2->F2_VEND3, ""),        ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("SellerName" ,  Iif(!Empty(SF2->F2_VEND3),AllTrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND3,"A3_NOME")), ""), ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("Name"       , "Seller3", ,.T.)

	//vend4
	oObjLSe := ofwEAIObj:setprop('ListOfSeller',{},'Seller',,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("Code"       ,  RTrim(SF2->F2_VEND4),        ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("InternalId" ,  Iif(!Empty(SF2->F2_VEND4),cEmpAnt + '|' + Alltrim(xFilial("SA3")) + '|' + SF2->F2_VEND4, ""),        ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("SellerName" ,  Iif(!Empty(SF2->F2_VEND4),AllTrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND4,"A3_NOME")), ""), ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("Name"       , "Seller4", ,.T.)

	//vend5
	oObjLSe := ofwEAIObj:setprop('ListOfSeller',{},'Seller',,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("Code"       ,  RTrim(SF2->F2_VEND5),        ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("InternalId" ,  Iif(!Empty(SF2->F2_VEND5),cEmpAnt + '|' + Alltrim(xFilial("SA3")) + '|' + SF2->F2_VEND5, ""),        ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("SellerName" ,  Iif(!Empty(SF2->F2_VEND5),AllTrim(Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND5,"A3_NOME")), ""), ,.T.)
	oObjLSe[Len(oObjLSe)]:setprop("Name"       , "Seller5", ,.T.)

	//Lista de Impostos da venda
	//COFINS
	oObjLTax := ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Taxe",  "COFINS",        ,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Value", SF2->F2_VALIMP5, ,.T.)
	//CSLL
	oObjLTax := ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Taxe",  "CSLL",          ,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Value", SF2->F2_VALCSLL, ,.T.)
	//ISS
	oObjLTax := ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Taxe",  "ISS",           ,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Value", SF2->F2_VALISS,  ,.T.)
	//PIS
	oObjLTax := ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Taxe",  "PIS",           ,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Value", SF2->F2_VALIMP6, ,.T.)
	//IPI
	oObjLTax := ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Taxe",  "IPI",           ,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Value", SF2->F2_VALIPI,  ,.T.)
	//ICM
	oObjLTax := ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Taxe",  "ICM",           ,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Value", SF2->F2_VALICM,  ,.T.)
	//ICMS_ST
	oObjLTax := ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Taxe",  "ICMS_ST",       ,.T.)
	oObjLTax[Len(oObjLTax)]:setprop("Value", SF2->F2_ICMSRET, ,.T.)

	cFilSD2		:= xFilial("SD2")
	cFilSB1		:= xFilial("SB1")
	cFilSC5		:= xFilial("SC5")
	cFilSC6		:= xFilial("SC6")
	cFilSAH		:= xFilial("SAH")
	cFilNNR		:= xFilial('NNR')
	nTmCD2Item	:= TamSX3('CD2_ITEM')[1]
	SD2->(DbSetOrder(3))
	If SD2->(DbSeek(cFilSD2+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		While SD2->(!Eof()) .AND. SD2->D2_FILIAL == cFilSD2 .AND. SD2->D2_DOC == SF2->F2_DOC .AND. SD2->D2_SERIE == SF2->F2_SERIE .AND. SD2->D2_CLIENTE == SF2->F2_CLIENTE .AND. SD2->D2_LOJA == SF2->F2_LOJA

			cChave := cFilAnt + "S" + SD2->D2_SERIE + SD2->D2_DOC + SD2->D2_CLIENTE + SD2->D2_LOJA + PADR(SD2->D2_ITEM,nTmCD2Item) + SD2->D2_COD

			//Tratamentos retirados no programa de geração de xml para SEFAZ (NFESEFAZ.PRW)
			//INICIO
			If SD2->D2_ORIGLAN == "VD"
				nDesconto := Round(SD2->D2_QUANT * SD2->D2_PRUNIT, 2) + SD2->D2_VALACRS - SD2->D2_TOTAL
			Else 
				nDesconto := SD2->D2_DESCON
			EndIf

			cDescProd	:= Posicione("SB1", 1, cFilSB1 + SD2->D2_COD, "B1_DESC")
			cNatOper	:= SF3->F3_ISSST
			vProd	 	:= IIf(!SD2->D2_TIPO $ "IP",;
			                   SD2->D2_TOTAL + nDesconto + SD2->D2_DESCZFR,;
			                   IIf((SD2->D2_TIPO=="I" .And. SF4->F4_AJUSTE == "S" .And. SubStr(SM0->M0_CODMUN,1,2) == "31") .Or.;
			                       (SD2->D2_TIPO=="I" .And. SF4->F4_AJUSTE == "S" .And. "RESSARCIMENTO" $ Upper(cNatOper) .And. "RESSARCIMENTO" $ Upper(cDescProd)),;
								   SD2->D2_TOTAL,;
								   0))
			vUnCom		:= vProd / SD2->D2_QUANT
			//FIM

			oObjLItem := ofwEAIObj:setprop('ListOfItens', {}, 'Item', , .T.)
			oObjLItem[Len(oObjLItem)]:setprop("InvoiceSequence",   SD2->D2_NUMSEQ,                                                           ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("OrderNumber",       cFilSC6 + SD2->D2_PEDIDO,                                                 ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("OrderInternalId",   IntPdVExt(cEmpAnt, cFilSC5, SD2->D2_PEDIDO,/*cItem*/, cPdVVer)[2],        ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("OrdemItem",         SD2->D2_ITEMPV,                                                           ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("ItemCode",          IntProExt(cEmpAnt, cFilSB1, SD2->D2_COD,/*cPrdVer*/)[2],                  ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("Quantity",          SD2->D2_QUANT,                                                            ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("UnitofMeasureCode", IntUndExt(cEmpAnt, cFilSAH, SD2->D2_UM,/*cUndVer*/)[2],                   ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("UnityPrice",        vUnCom,                                                                   ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("GrossValue",        vProd,                                                                    ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("FreightValue",      SD2->D2_VALFRE,                                                           ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("InsuranceValue",    SD2->D2_SEGURO,                                                           ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("DiscountValue",     SD2->D2_DESCON,                                                           ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("NetValue",          SD2->D2_PESO,                                                             ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("WarehouseId",       IntLocExt(cEmpAnt, cFilNNR, SD2->D2_LOCAL,/*cLocVer*/)[2],                ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("LotNumber",         AllTrim(SD2->D2_LOTECTL),                                                 ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("SubLotNumber",      SD2->D2_NUMLOTE,                                                          ,.T.)
			oObjLItem[Len(oObjLItem)]:setprop("ExpirationDate",    Transform(DtoS(SD2->D2_DTVALID),'@R 9999-99-99'),                         ,.T.)

			oObjLItem[Len(oObjLItem)]:setprop("OperFiscalCode", RTrim(SD2->D2_CF)  ,                         ,.T.)


			//Venda Varejo que originou Pedido de Venda
			cRetSaleId := ""

			SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM
			If lA410BRetail .And. SC5->(DbSeek(cFilSC5 + SD2->D2_PEDIDO)) .AND. !Empty(SC5->C5_ORCRES)
				aRetSale := A410BRETAIL(SC5->C5_ORCRES)
				If Len(aRetSale) > 0
					cRetSaleId := IntVendExt(,aRetSale[1],aRetSale[2],aRetSale[3],aRetSale[4])[2]
				EndIf
			EndIf

			oObjLItem[Len(oObjLItem)]:setprop("RetailSalesInternalId", cRetSaleId ,,.T.)

			//Lista de Impostos do item
			//COFINS
			oObjItTx := oObjLItem[Len(oObjLItem)]:setprop('ListOfTaxes',{},'Tax',,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Taxe",             "COFINS",                                                   ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Value",            Posicione("CD2",1,cChave+PADR("CF2",6),"CD2_VLTRIB"),       ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CalculationBasis", Posicione("CD2",1,cChave+PADR("CF2",6),"CD2_BC"),           ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Percentage",       Posicione("CD2",1,cChave+PADR("CF2",6),"CD2_ALIQ"),         ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CodeTaxSituation", AllTrim(Posicione("CD2",1,cChave+PADR("CF2",6),"CD2_CST")), ,.T.)
			//CSLL
			oObjItTx := oObjLItem[Len(oObjLItem)]:setprop('ListOfTaxes',{},'Tax',,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Taxe",             "CSLL",                                               ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Value",            Posicione("CD2",1,cChave+PADR("CSL",6),"CD2_VLTRIB"), ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CalculationBasis", Posicione("CD2",1,cChave+PADR("CSL",6),"CD2_BC"),     ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Percentage",       Posicione("CD2",1,cChave+PADR("CSL",6),"CD2_ALIQ"),   ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CodeTaxSituation", Posicione("CD2",1,cChave+PADR("CSL",6),"CD2_CST"),    ,.T.)
			//ISS
			oObjItTx := oObjLItem[Len(oObjLItem)]:setprop('ListOfTaxes',{},'Tax',,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Taxe",             "ISS",                                                ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Value",            Posicione("CD2",1,cChave+PADR("ISS",6),"CD2_VLTRIB"), ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CalculationBasis", Posicione("CD2",1,cChave+PADR("ISS",6),"CD2_BC"),     ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Percentage",       Posicione("CD2",1,cChave+PADR("ISS",6),"CD2_ALIQ"),   ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CodeTaxSituation", Posicione("CD2",1,cChave+PADR("ISS",6),"CD2_CST"),    ,.T.)
			//PIS
			oObjItTx := oObjLItem[Len(oObjLItem)]:setprop('ListOfTaxes',{},'Tax',,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Taxe",             "PIS",                                                ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Value",            Posicione("CD2",1,cChave+PADR("PS2",6),"CD2_VLTRIB"), ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CalculationBasis", Posicione("CD2",1,cChave+PADR("PS2",6),"CD2_BC"),     ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Percentage",       Posicione("CD2",1,cChave+PADR("PS2",6),"CD2_ALIQ"),   ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CodeTaxSituation", Posicione("CD2",1,cChave+PADR("PS2",6),"CD2_CST"),    ,.T.)
			//IPI
			oObjItTx := oObjLItem[Len(oObjLItem)]:setprop('ListOfTaxes',{},'Tax',,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Taxe",             "IPI",                                                ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Value",            Posicione("CD2",1,cChave+PADR("IPI",6),"CD2_VLTRIB"), ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CalculationBasis", Posicione("CD2",1,cChave+PADR("IPI",6),"CD2_BC"),     ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Percentage",       Posicione("CD2",1,cChave+PADR("IPI",6),"CD2_ALIQ"),   ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CodeTaxSituation", Posicione("CD2",1,cChave+PADR("IPI",6),"CD2_CST"),    ,.T.)
			//ICM
			oObjItTx := oObjLItem[Len(oObjLItem)]:setprop('ListOfTaxes',{},'Tax',,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Taxe",             "ICM",                                                ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Value",            Posicione("CD2",1,cChave+PADR("ICM",6),"CD2_VLTRIB"), ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CalculationBasis", Posicione("CD2",1,cChave+PADR("ICM",6),"CD2_BC"),     ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Percentage",       Posicione("CD2",1,cChave+PADR("ICM",6),"CD2_ALIQ"),   ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CodeTaxSituation", Posicione("CD2",1,cChave+PADR("ICM",6),"CD2_ORIGEM") + Posicione("CD2",1,cChave+PADR("ICM",6),"CD2_CST"), ,.T.)
			//ICMS_ST
			oObjItTx := oObjLItem[Len(oObjLItem)]:setprop('ListOfTaxes',{},'Tax',,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Taxe",             "ICMS_ST",                                            ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Value",            Posicione("CD2",1,cChave+PADR("SOL",6),"CD2_VLTRIB"), ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CalculationBasis", Posicione("CD2",1,cChave+PADR("SOL",6),"CD2_BC"),     ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("Percentage",       Posicione("CD2",1,cChave+PADR("SOL",6),"CD2_ALIQ"),   ,.T.)
			oObjItTx[Len(oObjItTx)]:setprop("CodeTaxSituation", Posicione("CD2",1,cChave+PADR("SOL",6),"CD2_CST"),    ,.T.)

			SD2->(DbSkip())
			cChave := ""
		EndDo
	Endif
	SD2->(DbSetOrder(1))
EndIf

RestArea(aAreaSF2)
RestArea(aAreaSD2)
RestArea(aAreaOld)
aSize(aAreaSF2,0)
aSize(aAreaSD2,0)
aSize(aAreaOld,0)
Return {lRet, ofwEAIObj, cMsgUnica}