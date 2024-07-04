#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'
#Include 'MATI410.CH'

Function MATI410(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Local aArea		:= GetArea()
Local cError   := ""
Local cWarning := ""
Local cVersao  := ""
Local lRet     := .T.
Local cXmlRet  := ""
Local aRet     := {}

Private oXML   := Nil

If cTypeTrans == TRANS_RECEIVE
	If cTypeMsg == EAI_MESSAGE_BUSINESS .Or. cTypeMsg == EAI_MESSAGE_RESPONSE
		oXML	:= xmlParser(cXml, "_", @cError, @cWarning)

		If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
			If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXML:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao	:= StrTokArr(oXML:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
			Else
				lRet		:= .F.
				cXmlRet	:= STR0006 // "Versão da mensagem não informada!"
				Return  {lRet, cXmlRet, "ORDER"}
			EndIf
		Else
			lRet		:= .F.
			cXmlRet	:= STR0007 // "Erro no parser!"
			Return  {lRet, cXmlRet, "ORDER"}
		EndIf

		If cVersao == "1"
			aRet	:= v2000(cXml, cTypeTrans, cTypeMsg)
		ElseIf cVersao == "3"
			aRet	:= v3002(cXml, cTypeTrans, cTypeMsg)
		ElseIf cVersao == "4"
			aRet	:= v4003(cXml, cTypeTrans, cTypeMsg)
		Else
			lRet		:= .F.
			cXmlRet	:= STR0008 // "A versão da mensagem informada não foi implementada!"
			Return  {lRet, cXmlRet, "ORDER"}
		EndIf
	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
		aRet	:= v4003(cXml, cTypeTrans, cTypeMsg)
	EndIf

ElseIf cTypeTrans == TRANS_SEND
	If XX4->(ColumnPos("XX4_SNDVER")) > 0
		If Empty(cVersion)
			lRet		:= .F.
			cXmlRet	:= STR0009 // "Versão não informada no cadastro do adapter."
			Return {lRet, cXmlRet, "ORDER"}
		Else
			cVersao	:= StrTokArr(cVersion, ".")[1]
		EndIf
		If cVersao == "1"
			aRet	:= v2000(cXml, cTypeTrans, cTypeMsg)
		ElseIf cVersao == "3"
			aRet	:= v3002(cXml, cTypeTrans, cTypeMsg)
		Elseif  cVersao == "4"
			aRet	:= v4003(cXml, cTypeTrans, cTypeMsg)
		Else
			lRet		:= .F.
			cXmlRet	:= STR0011 // "A versão da mensagem informada não foi implementada!"
			Return {lRet, cXmlRet, "ORDER"}
		EndIf
	Else
		ConOut(STR0049)	//"A LIB da Framework Protheus está desatualizada!"
		aRet		:= v2000(cXml, cTypeTrans, cTypeMsg) //Se o campo versão não existir chamar a versão 1
	EndIf
EndIf

RestArea(aArea)
lRet		:= aRet[1]
cXmlRet	:= aRet[2]
Return {lRet, cXmlRet, "ORDER"}

//-------------------------------------
/*  Definição de Integração
@author     Jefferson Tomaz
@version    P10 R1.4
@build      7.00.101202A
@since      15/08/2011
@return         { lRet, cXml }*/
//-------------------------------------
Static Function v2000( cXML, cTypeTrans, cTypeMsg )

Local aArea     := GetArea()
Local aAreaSC5  := SC5->( GetArea() )
Local aAreaSC6  := SC6->( GetArea() )

Local lRet      := .T.
Local aCab          := {}
Local aItens        := {}
Local aErroAuto := {}
Local nCount      := 0
Local nPrcVen     := 0
Local nOpcx         := 0
Local nContAux    := 0
Local nValDesc    := 0
Local nContAux2   := 0
Local nValor      := 0
Local nItens      := 1
Local cLogErro  := ""
Local cXMLRet   := ""
Local cError        := ""
Local cWarning  := ""
Local cInfAd      := ""
Local cMenNota    := ""
Local nTamSX3ITEM := TamSx3("C6_ITEM")[1]
Local cNfOri      := ""
Local cSerieOri   := ""
Local cItemOri    := ""
Local nQtdeOri    := 0
Local cProd       := ""
Local cIdentB6    := ""
Local cOrderItem  := StrZero(0, TamSx3("C6_ITEM")[1])
Local cData       := ""
Local cTes        := ""
Local cValExt     := ""
Local cValInt     := ""
Local cMarca      := ""
Local cItemCode   := ""
Local cCodCli     := ""
Local cLojCli     := ""
Local cEvent        := 'upsert'
Local cNumPedido    := ''
Local oXmlEvent := Nil                  //Objeto Xml com o conteudo da BusinessEvent apenas
Local oXmlContent   := Nil                  //Objeto Xml com o conteudo da BusinessContent apenas

Private oXmlM410          := Nil
Private nCountM410    := 1
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata recebimento de mensagens                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTypeTrans == TRANS_RECEIVE

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Recebimento da Business Message                              ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cTypeMsg == EAI_MESSAGE_BUSINESS

        oXmlM410 := XmlParser(cXml, "_", @cError, @cWarning)

        If oXmlM410 <> Nil .And. Empty(cError) .And. Empty(cWarning)

            oXmlEvent       := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessEvent
            oXmlContent := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent

            Begin  Sequence

                //Verifica qual a operação realizada (Inclusão, Alteração ou Exclusão)
                If ( Upper( oXmlEvent:_Event:Text ) == 'UPSERT' )
                    If ( XmlChildEx( oXmlContent, '_ORDERID' ) != Nil )
                        If ( Empty( oXmlContent:_OrderId:Text ) )
                            nOpcx:= 3
                        Else
                            nOpcx:= 4
                        EndIf
                    Else
                        nOpcx:= 3
                    EndIf
                ElseIf ( ( Upper( oXmlEvent:_Event:Text ) == 'DELETE' ) )
                    nOpcx := 5
                EndIf

                aAdd( aCab, { 'C5_FILIAL', xFilial('SC5'), Nil } )

                If ( XmlChildEx( oXmlContent, '_ORDERID' ) != Nil ) .And. ( nOpcx != 3 )
                    If ( !Empty( oXmlContent:_OrderID:Text ) )
                        aAdd( aCab, { 'C5_NUM', oXmlContent:_OrderId:Text, Nil } )
                    EndIf
                EndIf

                If ( nOpcx <> 5 )

                    aAdd( aCab, { 'C5_TIPO', 'N', Nil } )

                    If ( XmlChildEx( oXmlM410:_TotvsMessage:_MessageInformation:_Product, '_NAME' ) != Nil )
                        cMarca := oXmlM410:_TotvsMessage:_MessageInformation:_Product:_Name:Text
                    EndIf

                    If ( XmlChildEx( oXmlContent, '_CUSTOMERCODE' ) != Nil )

                        //--------------------------------------------------------------------------------------
                        //-- Tratamento utilizando a tabela XXF com um De/Para de codigos
                        //--------------------------------------------------------------------------------------
                        cValExt := AllTrim( oXmlContent:_CustomerCode:Text )

                        If ( FindFunction("CFGA070INT") )

                            //CFGA070INT( cMarca, cAlias , cCampo, "Valor Externo" , @"Valor Interno" )
                            cValInt := CFGA070INT( cMarca, 'SA1', 'A1_COD', cValExt )
                            cCodCli := SubStr( cValInt, 1, TamSX3('A1_COD')[1] )
                            cLojCli := SubStr( cValInt, TamSX3('A1_COD')[1]+1, TamSX3('A1_LOJA')[1] )

                            aAdd( aCab, { 'C5_CLIENTE', cCodCli, Nil } )
                            aAdd( aCab, { 'C5_LOJACLI', cLojCli, Nil } )

                            If ( XmlChildEx( oXmlContent, '_DELIVERYCUSTOMERCODE' ) != Nil )

                                If ( AllTrim( oXmlContent:_CustomerCode:Text) == AllTrim( oXmlContent:_DeliveryCustomerCode:Text ) )
                                    aAdd( aCab, { 'C5_CLIENT', cCodCli, Nil } )
                                    aAdd( aCab, { 'C5_LOJAENT', cLojCli, Nil } )
                                Else
                                    cValExt := oXmlContent:_DeliveryCustomerCode:Text

                                    If ( !Empty( cValInt := CFGA070INT( cMarca, 'SA1', 'A1_COD', cValExt ) ) )
                                        cCodCli := Substr(cValInt,1,TamSX3('A1_COD')[1])
                                        cLojCli := Substr(cValInt,TamSX3('A1_COD')[1]+1,TamSX3('A1_LOJA')[1])

                                        aAdd(aCab,{"C5_CLIENT"      ,cCodCli                    , Nil })
                                        aAdd(aCab,{"C5_LOJAENT"     ,cLojCli                    , Nil })

                                    EndIf
                                EndIf
                            EndIf
                        Else
                            lRet     := .F.
                            cXMLRet  := STR0002   //-- Atualize EAI
                            ConOut(STR0002)     //-- Atualize EAI
                            Break
                        EndIf

                    EndIf

                    //Código da Tabela de Preços
                    If ( XmlChildEx( oXmlContent, '_PRICETABLENUMBER' ) != Nil )
                        aAdd( aCab, { 'C5_TABELA', oXmlContent:_PriceTableNumber:Text, Nil } )
                    EndIf

                    //Código de Vendedor
                    If ( XmlChildEx( oXmlContent, '_SELLERCODE' ) != Nil )
                        aAdd( aCab, { 'C5_VEND1', oXmlContent:_SellerCode:Text, Nil } )
                    EndIf

                    //Desconto do Pedido de Venda
                    If ( XmlChildEx( oXmlContent:_Discounts, '_DISCOUNT' ) != Nil )
                        aAdd( aCab, { 'C5_DESC1', Val( oXmlContent:_Discounts:_Discount:Text ), Nil } )
                    EndIf

                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CarrierCode:Text") <> "U"
                        SA4->(DbSetOrder(1)) //-- A4_FILIAL + A4_COD
                        If SA4->(MsSeek(xFilial("SA4")+(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CarrierCode:Text) ))
                            aAdd(aCab,{"C5_TRANSP"          ,SA4->A4_COD            , Nil })
                        EndIf
                    EndIf
                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text") <> "U"
                        aAdd(aCab,{"C5_CONDPAG"          ,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text       , Nil })
                    EndIf
                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialDiscount:Text") <> "U"
                        aAdd(aCab,{"C5_DESCFI"          ,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialDiscount:Text)  , Nil })
                    EndIf
                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text") <> "U"
                        //--Tratamento para data no formato Ano/Mes/Dia
                        cData := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text
                        aAdd(aCab,{"C5_EMISSAO"         ,  cTod( Substr( cData, 9, 2 ) + '/' + SubStr( cData, 6, 2 ) + '/' + SubStr( cData, 1, 4 ) )    , Nil })
                    EndIf
                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text") <> "U"
                        If ( !Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text))
                            aAdd(aCab,{"C5_TPFRETE"         ,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text             , Nil })
                        EndIf
                    EndIf
                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text") <> "U"
                        aAdd(aCab,{"C5_FRETE"           ,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text)       , Nil })
                    EndIf
                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RedeliveryCarrierCode:Text") <> "U"
                        aAdd(aCab,{"C5_REDESP"          ,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RedeliveryCarrierCode:Text   , Nil })
                    EndIf

                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage") <> "U"
                        If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage) <> "A"
                            XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage, "_InvoiceMessage")
                        EndIf
                        For nContAux := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage)
                            If !Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage[nContAux]:Text)
                                cMenNota += oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage[nContAux]:Text
                            EndIf
                        Next nCountAux

                        If !Empty(cMenNota)
                            aAdd(aCab,{"C5_MENNOTA"         ,cMenNota           , Nil })
                        EndIf
                    EndIf

                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text") <> "U"
                        aAdd(aCab,{"C5_SEGURO"          ,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text)      , Nil })
                    EndIf
                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetWeight:Text") <> "U"
                        aAdd(aCab,{"C5_PESOL"           ,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NetWeight:Text)      , Nil })
                    EndIf
                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text") <> "U"
                        aAdd(aCab,{"C5_PBRUTO"          ,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text)        , Nil })
                    EndIf
                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NumberOfVolumes:Text") <> "U"
                        aAdd(aCab,{"C5_VOLUME1"         ,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NumberOfVolumes:Text)   , Nil })
                    EndIf
                    If SC5->(FieldPos('C5_ORIGEM')) > 0
                        If Upper(AllTrim(cMarca)) == "LOGIX"
								aAdd(aCab,{"C5_ORIGEM",Upper(AllTrim(cMarca)), Nil })
							Else
								aAdd(aCab,{"C5_ORIGEM","MSGEAI", Nil })
							Endif
                    EndIf

                    If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item) <> "A"
                        XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item, "_ITEM")
                    EndIf

                    For nCount:= 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item)
                        nCountM410 := nCount

                        If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+Str(nCountM410) + "]:_ListOfReturnedInputDocuments:_ReturnedInputDocument") <> "U"

                            If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument) <> "A"
                                XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument,"_ReturnedInputDocument")
                            EndIf

                            For nContAux := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument)

                                aAdd(aItens, {})
                                nValDesc   := 0
                                cInfAd     := ""
                                cOrderItem := RetAsc(Soma1(cOrderItem), nTamSX3ITEM,.T.)

                                aAdd(aItens[nItens], {"C6_FILIAL"    ,xFilial("SC6"), Nil })
                                aAdd(aItens[nItens], {"C6_ITEM"      , cOrderItem   , Nil })

                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemCode:Text") <> "U"
                                    cItemCode := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemCode:Text
                                    cProd     := CFGA070INT( cMarca , "SB1", 'B1_COD', cItemCode )
                                    cProd     := PADR(cProd, TamSX3("B1_COD")[1])
                                    aAdd(aItens[nItens], {"C6_PRODUTO", cProd        , Nil })
                                EndIf
                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_TypeOperation:Text") <> "U"
                                    cTes := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_TypeOperation:Text
                                    aAdd(aItens[nItens], {"C6_TES"  ,cTes                , Nil })
                                EndIf
                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ListOfReturnedInputDocuments:_ReturnedInputDocument[" + STR(nContAux) +"]:_InputDocumentQuantity:Text") <> "U"
                                  //-- Quantidade retornada por nota de entrada
                                  nQtdeOri := Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument[nContAux]:_InputDocumentQuantity:Text)
                                EndIf
                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_Quantity:Text") <> "U"
                                    aAdd(aItens[nItens], {"C6_QTDVEN", nQtdeOri      , Nil })
                                    aAdd(aItens[nItens], {"C6_QTDLIB", 0             , Nil })
                                EndIf
                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_UnityPrice:Text") <> "U"
                                    nPrcVen := Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_UnityPrice:Text)
                                    nValor  := nQtdeOri * nPrcVen
                                    aAdd(aItens[nItens], {"C6_PRCVEN",nPrcVen            , Nil })
                                    aAdd(aItens[nItens], {"C6_PRUNIT",nPrcVen            , Nil })
                                    aAdd(aItens[nItens], {"C6_VALOR"    ,nValor          , Nil })
                                EndIf
                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDescription:Text") <> "U"
                                    aAdd(aItens[nItens], {"C6_DESCRI"   ,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDescription:Text      , Nil })
                                EndIf
                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_DeliveryDate:Text") <> "U"
                                    aAdd(aItens[nItens], {"C6_ENTREG"   ,CtoD(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_DeliveryDate:Text)       , Nil })
                                EndIf
                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_OrderID:Text") <> "U"
                                    aAdd(aItens[nItens], {"C6_NUM"      ,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_OrderID:Text                      , Nil })
                                EndIf
                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_CustomerOrderNumber:Text") <> "U"
                                    aAdd(aItens[nItens], {"C6_PEDCLI"   ,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_CustomerOrderNumber:Text      , Nil })
                                EndIf
                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_DiscountPercentage:Text") <> "U"
                                    aAdd(aItens[nItens], {"C6_DESCONT"  ,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_DiscountPercentage:Text) , Nil })
                                EndIf

                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[" +STR(nCountM410) +"]:_ItemDiscounts:_ItemDiscount") <> "U"
                                    If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount) <> "A"
                                        XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount, "_ItemDiscount")
                                    EndIf
                                    For nContAux2 := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount)
                                        If !Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount[nContAux2]:Text)
                                            nValDesc += Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount[nContAux2]:Text)
                                        EndIf
                                    Next nContAux2

                                    If nValDesc <> 0
                                      aAdd(aItens[nItens], {"C6_VALDESC"    , nValDesc , Nil})
                                    EndIf
                                EndIf

                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ListOfReturnedInputDocuments:_ReturnedInputDocument["+ STR(nContAux) +"]:_InputDocumentNumber:Text") <> "U"
                                    cNfOri := PADR(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument[nContAux]:_InputDocumentNumber:Text,TamSx3("D1_DOC")[1] )
                                   aAdd(aItens[nItens], {"C6_NFORI" , cNfOri , NIL })
                                EndIf
                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ListOfReturnedInputDocuments:_ReturnedInputDocument["+ STR(nContAux) +"]:_InputDocumentSerie:Text") <> "U"
                                cSerieOri := PADR(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument[nContAux]:_InputDocumentSerie:Text, TamSx3("D1_SERIE")[1])
                                    aAdd(aItens[nItens], {"C6_SERIORI" , cSerieOri , NIL })
                               EndIf
                               If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item["+ STR(nCountM410) +"]:_ListOfReturnedInputDocuments:_ReturnedInputDocument["+ STR(nContAux) +"]:_InputDocumentSequence:Text") <> "U"
                                  cItemOri := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ListOfReturnedInputDocuments:_ReturnedInputDocument[nContAux]:_InputDocumentSequence:Text
                                  cItemOri := StrZero(Val(cItemOri), TamSX3("D1_ITEM")[1])
                                  aAdd(aItens[nItens], {"C6_ITEMORI" , cItemOri , NIL })
                               EndIf

                                SD1->(dbSetOrder(1)) //-- D1_FILIAL + D1_DOC + D1_SERIE +  D1_FORNEC + D1_LOJA  + D1_COD + D1_ITEM
                                If SD1->(MsSeek(     xFilial("SD1") + cNfOri + cSerieOri+ cCodCli + cLojCli + cProd  + cItemOri))
                                    cIdentB6 := SD1->D1_IDENTB6
                                    aAdd(aItens[nItens], {"C6_IDENTB6" , cIdentB6 , NIL })
                                EndIf

                                If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[" + STR(nCountM410) +" ]:_ItemMessages:_ItemMessage") <> "U" ;
                                    .And. SC6->(FieldPos('C6_CODINF')) > 0
                                    If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage) <> "A"
                                        XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage, "_ItemMessage")
                                    EndIf
                                    For nContAux2 := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage)
                                        If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[" + STR(nCountM410) +"]:_ItemMessages:_ItemMessage[" + STR(nContAux2) + "]:Text") <> "U"
                                            cInfAd += oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage[nContAux2]:Text
                                        EndIf
                                    Next nContAux2

                                    If !Empty(cInfAd)
                                      aAdd(aItens[nItens], {"C6_INFAD"  ,cInfAd , Nil })
                                    EndIf
                                EndIf
                                nItens++
                            Next nContAux

                        Else

                            aAdd(aItens, {})
                            nValDesc   := 0
                            cInfAd     := ""

                            aAdd(aItens[nItens], {"C6_FILIAL"   ,xFilial("SC6")                                                                                                                         , Nil })
                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_OrderItem:Text") <> "U"
                                cOrderItem := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_OrderItem:Text
                                cOrderItem := RetAsc(cOrderItem, nTamSX3ITEM,.T.)
                                aAdd(aItens[nItens], {"C6_ITEM",       cOrderItem ,Nil })
                            EndIf
                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemCode:Text") <> "U"
                                cItemCode := oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemCode:Text
                                cProd     := CFGA070INT( cMarca , 'SB1', 'B1_COD', cItemCode )
                                cProd     := PADR(cProd, TamSX3("B1_COD")[1])
                                aAdd(aItens[nItens], {"C6_PRODUTO", cProd      ,Nil })
                            EndIf
                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_Quantity:Text") <> "U"
                                aAdd(aItens[nItens], {"C6_QTDVEN" ,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_Quantity:Text)              , Nil })
                                aAdd(aItens[nItens], {"C6_QTDLIB" , 0          ,Nil})
                            EndIf
                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_UnityPrice:Text") <> "U"
                                aAdd(aItens[nItens], {"C6_PRCVEN" ,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_UnityPrice:Text)            , Nil })
                            EndIf

                            //Preço unitário da Tabela de Preços
                            If ( XmlChildEx( oXmlContent:_SalesOrderItens:_Item[nCountM410], '_PRICEOFPRICETABLE' ) != Nil )
                                aAdd( aItens[nItens], { 'C6_PRUNIT', Val( oXmlContent:_SalesOrderItens:_Item[nCountM410]:_PriceOfPriceTable:Text ), Nil } )
                            EndIf

                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_TotalPrice:Text") <> "U"
                                aAdd(aItens[nItens], {"C6_VALOR"    ,Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_TotalPrice:Text)          , Nil })
                            EndIf
                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_TypeOperation:Text") <> "U"
                                aAdd(aItens[nItens], {"C6_TES"      ,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_TypeOperation:Text                , Nil })
                            EndIf
                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDescription:Text") <> "U"
                                aAdd(aItens[nItens], {"C6_DESCRI"   ,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDescription:Text      , Nil })
                            EndIf
                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_DeliveryDate:Text") <> "U"
                                aAdd(aItens[nItens], {"C6_ENTREG"   ,CtoD(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_DeliveryDate:Text)       , Nil })
                            EndIf
                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_OrderID:Text") <> "U"
                                aAdd(aItens[nItens], {"C6_NUM"      ,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_OrderID:Text                      , Nil })
                            EndIf
                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_CustomerOrderNumber:Text") <> "U"
                                aAdd(aItens[nItens], {"C6_PEDCLI"   ,oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_CustomerOrderNumber:Text      , Nil })
                            EndIf

                            //Percentual de desconto do item
                            If ( XmlChildEx( oXmlContent:_SalesOrderItens:_Item[nCountM410], '_DISCOUNTPERCENTAGE' ) != Nil)
                                aAdd( aItens[nItens], { 'C6_DESCONT', Val( oXmlContent:_SalesOrderItens:_Item[nCountM410]:_DiscountPercentage:Text ), Nil } )
                            EndIf

                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount") <> "U"
                                If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount) <> "A"
                                    XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount, "_ItemDiscount")
                                EndIf
                                For nContAux := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount)
                                    If !Empty(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount[nContAux]:Text)
                                        nValDesc += Val(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemDiscounts:_ItemDiscount[nContAux]:Text)
                                    EndIf
                                Next nContAux

                                If nValDesc <> 0
                                    aAdd(aItens[nItens], {"C6_VALDESC",nValDesc , Nil})
                                EndIf
                            EndIf

                            If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage") <> "U" .And. SC6->(FieldPos('C6_CODINF')) > 0
                                If ValType(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage) <> "A"
                                    XmlNode2Arr(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage, "_ItemMessage")
                                EndIf
                                For nContAux := 1 To Len(oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage)
                                    If Type("oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage[nContAux]:Text") <> "U"
                                        cInfAd += oXmlM410:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nCountM410]:_ItemMessages:_ItemMessage[nContAux]:Text
                                    EndIf
                                Next nContAux

                                If !Empty(cInfAd)
                                    aAdd(aItens[nItens], {"C6_INFAD"  ,cInfAd    , Nil })
                                EndIf
                            EndIf
                            nItens++
                        EndIf

                    Next nCount

                EndIf

                // ponto de entrada inserido para controlar dados especificos do cliente
				  If ExistBlock("MT410EAI")
					  	aRetPe := ExecBlock("MT410EAI",.F.,.F.,{aCab,aItens})
						If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
							aCab 	:= aClone(aRetPe[1])
							aItens := aClone(aRetPe[2])
						EndIf
			      EndIf

                SC5->(DbSetOrder(1))

                If ( nOpcx == 5 ) .And. ( !SC5->( MsSeek(xFilial('SC5') + oXmlContent:_OrderID:Text ) ) )
                    lMsErroAuto := .F.
                Else
                    MSExecAuto( { |x, y, z| Mata410(x, y, z) }, aCab, aItens, nOpcx )
                EndIf


                If ( lMsErroAuto )
                    aErroAuto := GetAutoGRLog()
                    ConOut(STR0001) //-- Erro IntegDef() - Mata410

                    For nCount := 1 To Len(aErroAuto)
                        cLogErro += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ")
                        ConOut(aErroAuto[nCount])
                    Next nCount

                    // Monta XML de Erro de execução da rotina automatica.
                    lRet := .F.
                    cXMLRet := cLogErro
                Else
                    // Monta xml com status do processamento da rotina automatica OK.
                    cXMLRet := '<OrderId>' + SC5->C5_NUM + '</OrderId>'
                EndIf

            End Sequence

        Else
            // "Falha ao gerar o objeto XML"
            lRet := .F.
            cXMLRet := STR0003  //"Falha ao manipular o XML"
        EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Recebimento da Response Message                              ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    ElseIf ( cTypeMsg == EAI_MESSAGE_RESPONSE )

        cXMLRet := STR0004  //'Mensagem processada.'

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Recebimento da WhoIs                                         ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    ElseIf ( cTypeMsg == EAI_MESSAGE_WHOIS )

        cXMLRet := "1.000"

    EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata o envio de mensagem                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf ( cTypeTrans == TRANS_SEND )

    If ( INCLUI )
        cEvent := 'upsert'
        cNumPedido := ''
    ElseIf ( ALTERA )
        cEvent := 'upsert'
        cNumPedido := SC5->C5_NUM
    Else
        cEvent := 'delete'
        cNumPedido := SC5->C5_NUM
    EndIf

    cXMLRet := '<BusinessEvent>'
    cXMLRet +=     '<Entity>ORDER</Entity>'
    cXMLRet +=     '<Event>' + cEvent + '</Event>'  //Tipo de evento (upsert/delete)
    cXMLRet +=     '<Identification>'
    cXMLRet +=         '<key name="InternalId">' + SC5->C5_FILIAL + SC5->C5_NUM + '</key>'
    cXMLRet +=     '</Identification>'
    cXMLRet += '</BusinessEvent>'

    cXMLRet += '<BusinessContent>'
    cXmlRet +=  '<CompanyId>' + cEmpAnt + '</CompanyId>'
    cXmlRet +=  '<BranchId>' + SC5->C5_FILIAL + '</BranchId>'
    cXmlRet +=  '<OrderTypeCode>' + SC5->C5_TIPO + '</OrderTypeCode>'
    cXmlRet +=  '<CustomerOrderId>' + '</CustomerOrderId>'
    cXmlRet +=  '<RegisterDate>' + '</RegisterDate>'
    cXmlRet +=  '<OrderId>' + cNumPedido + '</OrderId>'
    cXmlRet +=  '<RequestDate>' + '</RequestDate>'
    cXmlRet +=  '<FreightType>' + SC5->C5_TPFRETE + '</FreightType>'
    cXmlRet +=  '<FreightValue>' + cValToChar( SC5->C5_FRETE ) + '</FreightValue>'
    cXmlRet +=  '<RedeliveryCarrierCode>' + '</RedeliveryCarrierCode>'
    cXmlRet +=  '<InvoiceMessages>'
    cXmlRet +=      '<InvoiceMessage>' + '</InvoiceMessage>'
    cXmlRet +=  '</InvoiceMessages>'
    cXmlRet +=  '<NetWeight>' + '</NetWeight>'
    cXmlRet +=  '<GrossWeight>' + '</GrossWeight>'
    cXmlRet +=  '<TareWeight>' + '</TareWeight>'
    cXmlRet +=  '<CubicVolume>' + '</CubicVolume>'
    cXmlRet +=  '<NumberOfVolumes>' + '</NumberOfVolumes>'
    cXmlRet +=  '<Finality>' + '</Finality>'
    cXmlRet +=  '<InsuranceValue>' + '</InsuranceValue>'
    cXmlRet +=  '<CurrencyCode>' + '</CurrencyCode>'
    cXmlRet +=  '<Status>' + '</Status>'
    cXmlRet +=  '<PriceTableNumber>' + SC5->C5_TABELA + '</PriceTableNumber>'
    cXmlRet +=  '<CustomerCode>' + SC5->C5_CLIENT + SC5->C5_LOJAENT + '</CustomerCode>'
    cXmlRet +=  '<DeliveryCustomerCode>' + SC5->C5_CLIENT + SC5->C5_LOJAENT + '</DeliveryCustomerCode>'
    cXmlRet +=  '<DeliveryCustomerGovernmentalInformation>'
    cXMLRet +=      '<Id scope="State" name="INSCRICAO ESTADUAL" issueOn="" expiresOn="">' + '</Id>'
    cXMLRet +=          '<Id scope="Municipal" name="INSCRICAO MUNICIPAL" issueOn="" expiresOn="">' + '</Id>'
    cXMLRet +=          '<Id scope="Federal" name="SUFRAMA" issueOn="" expiresOn="">' + '</Id>'
    cXMLRet +=      '<Id scope="Federal" name="CPF/CNPJ" issueOn="" expiresOn="">' + '</Id>'
    cXmlRet +=  '</DeliveryCustomerGovernmentalInformation>'
    cXMLRet +=  '<DeliveryAddress>'
    cXMLRet +=          '<Address>' + '</Address>'
    cXMLRet +=          '<Complement>' + '</Complement>'
    cXMLRet +=          '<City>'
    cXMLRet +=              '<Code>' + '</Code>'
    cXMLRet +=              '<Description>' + '</Description>'
    cXMLRet +=          '</City>'
    cXMLRet +=          '<District>' + '</District>'
    cXMLRet +=          '<State>'
    cXMLRet +=              '<Code>' + '</Code>'
    cXMLRet +=              '<Description>' + '</Description>'
    cXMLRet +=          '</State>'
    cXMLRet +=          '<ZIPCode>' + '</ZIPCode>'
    cXMLRet +=          '<POBox>' + '</POBox>'
    cXMLRet +=  '</DeliveryAddress>'
    cXmlRet +=  '<CarrierCode>' + SC5->C5_TRANSP + '</CarrierCode>'
    cXmlRet +=  '<PaymentTermCode>' + SC5->C5_CONDPAG + '</PaymentTermCode>'
    cXmlRet +=  '<Discounts>'
    cXmlRet +=      '<Discount>' + cValToChar( SC5->C5_DESC1 ) + '</Discount>'
    cXmlRet +=  '</Discounts>'
    cXmlRet +=  '<FinancialDiscount>' + cValToChar( SC5->C5_DESCFI ) + '</FinancialDiscount>'
    cXmlRet +=  '<TotalDiscount>' + '</TotalDiscount>'

    cXmlRet +=  '<SalesOrderItens>'

    dbSelectArea('SC6')
    SC6->( dbSetOrder(1) )  //C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO

    If ( SC6->( dbSeek( SC5->C5_FILIAL + SC5->C5_NUM ) ) )

        While ( SC6->C6_FILIAL + SC6->C6_NUM == SC5->C5_FILIAL + SC5->C5_NUM )

            cXmlRet +=      '<Item>'
            cXmlRet +=          '<CompanyId>' + cEmpAnt + '</CompanyId>'
            cXmlRet +=          '<BranchId>' + SC6->C6_FILIAL + '</BranchId>'
            cXmlRet +=          '<OrderId>' + SC6->C6_NUM + '</OrderId>'
            cXmlRet +=          '<OrderItem>' + SC6->C6_ITEM + '</OrderItem>'
            cXmlRet +=          '<ItemCode>' + SC6->C6_PRODUTO + '</ItemCode>'
            cXmlRet +=          '<ItemDescription>' + SC6->C6_DESCRI + '</ItemDescription>'
            cXmlRet +=          '<Quantity>' + cValToChar( SC6->C6_QTDVEN ) + '</Quantity>'
            cXmlRet +=          '<UnityPrice>' + cValToChar( SC6->C6_PRCVEN ) + '</UnityPrice>'
            cXmlRet +=          '<TotalPrice>' + cValToChar( SC6->C6_VALOR ) + '</TotalPrice>'
            cXmlRet +=          '<TypeOperation>' + SC6->C6_TES + '</TypeOperation>'
            cXmlRet +=          '<CustomerOrderNumber>' + '</CustomerOrderNumber>'
            cXmlRet +=          '<DiscountPercentage>' + cValToChar( SC6->C6_DESCONT ) + '</DiscountPercentage>'
            cXmlRet +=          '<ItemDiscounts>'
            cXmlRet +=              '<ItemDiscount>' + '</ItemDiscount>'
            cXmlRet +=          '</ItemDiscounts>'
            cXmlRet +=          '<FreightValue>' + '</FreightValue>'
            cXmlRet +=          '<InsuranceValue>' + '</InsuranceValue>'
            cXmlRet +=          '<UnitWeight>' + '</UnitWeight>'
            cXmlRet +=          '<ItemMessages>'
            cXmlRet +=              '<ItemMessage>' + '</ItemMessage>'
            cXmlRet +=          '</ItemMessages>'
            cXmlRet +=          '<PriceOfPriceTable>' + cValToChar( SC6->C6_PRUNIT ) + '</PriceOfPriceTable>'
            cXmlRet +=      '</Item>'

            SC6->( dbSkip() )

        EndDo
    EndIf

    cXmlRet +=  '</SalesOrderItens>'
    cXmlRet +=  '<SellerCode>' + SC5->C5_VEND1 + '</SellerCode>'
    cXMLRet += '</BusinessContent>'

EndIf

RestArea( aAreaSC5 )
RestArea( aAreaSC6 )
RestArea( aArea )

Return { lRet, cXMLRet }

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MATI410
Funcao de integracao com o adapter EAI para envio e recebimento do
Pedido de Venda (SC5/SC6/AGG) utilizando o conceito de mensagem unica
(Order).

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   cTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMsg  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Leandro Luiz da Cruz
@version P11
@since   04/06/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//----------------------------------------------------------------------------------

Static Function v3002(cXml, cTypeTrans, cTypeMsg)
   Local lRet             := .T.
   Local cAlias           := "SC5"
   Local cField           := "C5_NUM"
   Local cEvent           := "upsert"
   Local cXmlRet          := ""
   Local cError           := ""
   Local cWarning         := ""
   Local cValExt          := ""
   Local cValInt          := ""
   Local cMarca           := ""
   Local cNumPed          := ""
   Local cCliente         := ""
   Local cLoja            := ""
   Local cDatEmis         := ""
   Local cItemSC6         := ""
   Local cTES             := ""
   Local cAux             := ""
   Local aCab             := {}
   Local aItens           := {}
   Local aErroAuto        := {}
   Local aAux             := {}
   Local aCCusto          := {}
   Local aProjeto         := {}
   Local aItemRat         := {}
   Local aLinha           := {}
   Local aDePara          := {}
   Local aItemAux         := {}
   Local aRateio          := {}
   Local aRet             := {}
   Local nOpcx            := 0
   Local nI               := 0
   Local nJ               := 0
   Local nLin             := 0
   Local nItemRat         := 1
   Local nPrcTtl          := 0
   Local nPercDesc        := 0
   Local nValDesc         := 0
   Local nK               := 0
   Local nTamC6ITEM       := TamSx3("C6_ITEM")[1]
   Local aAdtPC           := {}
   Local cCond            := ""
   Local cNameInternalId  := ""
   Local cCusVer          := RTrim(PmsMsgUVer('CUSTOMERVENDOR',            'MATA030' .OR. 'CRMA980')) //Versão do Cliente/Fornecedor
   Local cCosVer          := RTrim(PmsMsgUVer('COSTCENTER',                'CTBA030')) //Versão do Centro de Custo
   Local cUndVer          := RTrim(PmsMsgUVer('UNITOFMEASURE',             'QIEA030')) //Versão da Unidade de Medida
   Local cConVer          := RTrim(PmsMsgUVer('PAYMENTCONDITION',          'MATA360')) //Versão da Condição de Pagamento
   Local cMoeVer          := RTrim(PmsMsgUVer('CURRENCY',                  'CTBA140')) //Versão da Moeda
   Local cLocVer          := RTrim(PmsMsgUVer('WAREHOUSE',                 'AGRA045')) //Versão do Local de Estoque
   Local cPrdVer          := RTrim(PmsMsgUVer('ITEM',                      'MATA010')) //Versão do Produto
   Local cPrjVer          := RTrim(PmsMsgUVer('PROJECT',                   'PMSA200')) //Versão do Projeto
   Local cTrfVer          := RTrim(PmsMsgUVer('TASKPROJECT',               'PMSA203')) //Versão da Tarefa
   Local cTRcVer          := RTrim(PmsMsgUVer('ACCOUNTRECEIVABLEDOCUMENT', 'FINA040')) //Versão do Título a Receber
   Local cPdVVer          := RTrim(PmsMsgUVer('ORDER',                     'MATA410')) //Versão do Pedido de Venda
   Local cCCusto          := ""
   Local nTotPrcRat       := 0
   Local lLOCAXRMC        := ExistBlock("LOCAXRMC")
   Local lLOCAXRMI        := ExistBlock("LOCAXRMI")
   Local lMT410TCOD       := ExistBlock("MT410TCODE")

   Private oXml           := Nil
   Private oXmlAux        := Nil
   Private oXmlRat        := Nil
   Private oXMLRatCC      := Nil
   Private lMsErroAuto    := .F.
   Private lAutoErrNoFile := .T.

   AdpLogEAI(1, "MATI410", cTypeTrans, cTypeMsg, cXML)

   //Mensagem de Entrada
   If cTypeTrans == TRANS_RECEIVE
      //Regra de Negócio
      If cTypeMsg == EAI_MESSAGE_BUSINESS
         oXml := XmlParser(cXml, "_", @cError, @cWarning)

         //Se não houve erro no parser
         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text)
               If AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text) == "2"
                  //Marca
                  If Type("oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
                     cMarca := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
                  Else
                     lRet := .F.
                     cXmlRet := STR0013 // "Informe a Marca!"
                     AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                     Return {lRet, cXmlRet, "ORDER"}
                  EndIf

                  //InternalId do pedido
                  If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
                     cValExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
                  Else
                     lRet := .F.
                     cXmlRet := STR0014 // "O InternalId é obrigatório!"
                     AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                     Return {lRet, cXmlRet, "ORDER"}
                  EndIf

                  //Obtém o InternalId
                  cValInt := RTrim(CFGA070INT(cMarca, cAlias, cField, cValExt))

                  //Se encontrou no de/para
                  If !Empty(cValInt)
                     cNumPed := PadR(StrTokArr(cValInt, "|")[3], TamSX3("C5_NUM")[1])

                     If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
                        nOpcx := 4 //UPDATE
                     Else
                        nOpcx := 5 //DELETE

                        If SC6->(dbSeek(xFilial("SC6") + cNumPed))
                           While xFilial("SC6") + cNumPed == SC6->C6_FILIAL + SC6->C6_NUM
                              cAux := IntPdVExt(/*cEmpresa*/, SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, cPdVVer)[2]

                              // Array que será usado ao manipular o de/para de itens
                              aAdd(aItemAux, RTrim(CFGA070Ext(cMarca, "SC6", "C6_ITEM", cAux)))
                              aAdd(aItemAux, cAux)
                              aAdd(aItemAux, "SC6")
                              aAdd(aItemAux, "C6_ITEM")
                              aAdd(aDePara, aItemAux)

                              SC6->(dbSkip())
                           EndDo
                        EndIf
                     EndIf

                     aAdd(aCab, {"C5_FILIAL", xFilial("SC5"), Nil})
                     aAdd(aCab, {"C5_NUM",    cNumPed,         Nil})
                  Else
                     If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
                        nOpcx := 3 //INSERT
                     Else
                        lRet := .F.
                        cXmlRet := STR0017 // "O registro a ser excluído não foi encontrado na base Protheus."
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     EndIf
                  EndIf

                  //Se não é exclusão
                  If nOpcx != 5
                     // Tipo pedido
                     aAdd(aCab, {"C5_TIPO", "N", Nil})

                     // Obtém o Código Interno do Cliente e a Loja
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text)
                        aAux := IntCliInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text, cMarca, cCusVer)
                        If !aAux[1]
                           lRet := aAux[1]
                           cXmlRet := aAux[2]
                           AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                           Return {lRet, cXmlRet, "ORDER"}
                        Else
                           cCliente := aAux[2][3]
                           cLoja := aAux[2][4]
                           aAdd(aCab, {"C5_CLIENTE", cCliente, Nil})
                           aAdd(aCab, {"C5_LOJACLI",    cLoja,    Nil})
                        EndIf
                     ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text)
                        If Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text) > TamSX3("C5_CLIENTE")[1]
                           cCliente := SubStr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text, 1, TamSX3("C5_CLIENTE")[1])
                           cLoja    := PadR(SubStr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text, TamSX3("C5_CLIENTE")[1] + 1), TamSX3("C5_LOJACLI")[1])
                        Else
                           cCliente := PadR(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text, TamSX3("C5_CLIENTE")[1])
                           cLoja   := ""
                        EndIf
                        aAdd(aCab, {"C5_CLIENTE", cCliente, Nil})
                        aAdd(aCab, {"C5_LOJACLI",    cLoja,    Nil})
                     EndIf

                     //Obtém o Código Interno da Condição de Pagamento
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentConditionInternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentConditionInternalId:Text)
                        aAux := IntConInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentConditionInternalId:Text, cMarca, cConVer)
                        If !aAux[1]
                           lRet := aAux[1]
                           cXmlRet := aAux[2]
                           AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                           Return {lRet, cXmlRet, "ORDER"}
                        Else
                           cCond := aAux[2][3]
                           aAdd(aCab, {"C5_CONDPAG", cCond, Nil})
                        EndIf
                     ElseIf IsIntegTop() .Or. Upper(AllTrim(cMarca)) == "HIS"
                        cCond := SuperGetMV("MV_SLMCOND", .F., "")
                        aAdd(aCab, {"C5_CONDPAG", cCond, Nil})
                     ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text)
                        cCond := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text
                        aAdd(aCab, {"C5_CONDPAG", cCond, Nil})
                     EndIf

                     // Data de Emissão
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text") <> "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text)
                        cDatEmis := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text
                        aAdd(aCab, {"C5_EMISSAO", cTod(SubStr(cDatEmis, 9, 2) + "/" + SubStr(cDatEmis, 6, 2 ) + "/" + SubStr(cDatEmis, 1, 4 )), Nil})
                     EndIf

                     // Tipo de Frete
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text)
                        aAdd(aCab, {"C5_TPFRETE", getTpFre(AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text), cTypeTrans), Nil})
                     EndIf

                     // Frete
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text)
                        aAdd(aCab, {"C5_FRETE", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text), Nil})
                     EndIf

                     // Peso Bruto
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text)
                        aAdd(aCab, {"C5_PBRUTO", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text), Nil})
                     EndIf

                     // Valor do Seguro
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text)
                        aAdd(aCab, {"C5_SEGURO", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text), Nil})
                     EndIf

                     //Moeda
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyId:Text)
                     	cAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyId:Text
                     	aAux := GetCurrId(cAux,cMarca, cMoeVer)
                        If !aAux[1]
                           lRet := aAux[1]
                           cXmlRet := aAux[2]
                           AdpLogEAI(1, "MATI410", cTypeTrans, cTypeMsg, cXML)
                           Return {lRet, cXmlRet, "ORDER"}
                        Else
                           aAdd(aCab, {"C5_MOEDA", Val(aAux[2][3]), Nil})
                        EndIf
                     ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text)
                        aAdd(aCab, {"C5_MOEDA", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text), Nil})
                     EndIf

                     //Natureza
                     If IsIntegTop() .Or. Upper(AllTrim(cMarca)) == "HIS"
                        aAdd(aCab, {"C5_NATUREZ", GetNewPar("MV_SLMNTPV", .F., ""), Nil})
                     EndIf

                     //Origem
                     If Upper(AllTrim(cMarca)) == "LOGIX"
						aAdd(aCab,{"C5_ORIGEM",Upper(AllTrim(cMarca)), Nil })
					Else
						aAdd(aCab,{"C5_ORIGEM","MSGEAI", Nil})
					Endif

               // Se não for array
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item") != "A"
                     XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item, "_Item")
               EndIf

               For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item)
                  cItemSC6 := RetAsc(nI,nTamC6ITEM,.T.)

                  // Atualiza o objeto com a posição atual
                  oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nI]

                  // Array que será usado ao manipular o de/para de itens
                  aAdd(aDePara, Array(4))
                  aDePara[nI][1] := oXmlAux:_InternalId:Text
                  aDePara[nI][2] := PadL(oXmlAux:_OrderItem:Text, nTamC6ITEM, "0")
                  aDePara[nI][3] := "SC6"
                  aDePara[nI][4] := "C6_ITEM"

                  aAdd(aItemAux, {"C6_ITEM", cItemSC6, Nil})

                  // Obtém o Código Interno do produto
                  If Type("oXmlAux:_ItemInternalId:Text") != "U" .And. !Empty(oXmlAux:_ItemInternalId:Text)
                     aAux := IntProInt(oXmlAux:_ItemInternalId:Text, cMarca)
                     If !aAux[1]
                        lRet := aAux[1]
                        cXmlRet := aAux[2]
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     Else
                        aAdd(aItemAux, {"C6_PRODUTO", aAux[2][3], Nil})
                     EndIf
                  ElseIf Type("oXmlAux:_ItemCode:Text") != "U" .And. !Empty(oXmlAux:_ItemCode:Text)
                     aAdd(aItemAux, {"C6_PRODUTO", oXmlAux:_ItemCode:Text, Nil})
                  EndIf

                  // Descrição do produto
                  If Type("oXmlAux:_ItemDescription:Text") != "U" .And. !Empty(oXmlAux:_ItemDescription:Text)
                     aAdd(aItemAux , {"C6_DESCRI" , AllTrim(oXmlAux:_ItemDescription:Text) , Nil } )
                  EndIf

                  // Obtém o código interno do local de estoque
                  If Type("oXmlAux:_WarehouseInternalId:Text") != "U" .And. !Empty(oXmlAux:_WarehouseInternalId:Text)
                     aAux := IntLocInt(oXmlAux:_WarehouseInternalId:Text, cMarca)
                     If !aAux[1]
                        lRet := aAux[1]
                        cXmlRet := aAux[2]
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     Else
                        aAdd(aItemAux, {"C6_LOCAL", aAux[2][3], Nil})
                     EndIf
                  EndIf

                  // Unidade de Medida do Item
                  If Type("oXmlAux:_UnitOfMeasureInternalIdIf:Text") != "U" .And. !Empty(oXmlAux:_UnitOfMeasureInternalIdIf:Text)
                     aAux := IntUndInt(oXmlAux:_UnitOfMeasureInternalIdIf:Text, cMarca, cUndVer)
                     If !aAux[1]
                        lRet := aAux[1]
                        cXmlRet := aAux[2]
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     Else
                        aAdd(aItemAux, {"C6_UM", aAux[2][3], Nil})
                     EndIf
                  ElseIf Type("oXmlAux:_itemunitofmeasure:Text") != "U" .And. !Empty(oXmlAux:_itemunitofmeasure:Text)
                     aAdd(aItemAux, {"C6_UM", oXmlAux:_itemunitofmeasure:Text, Nil})
                  EndIf
						
						//-- Se informações de rateio em item único, transforma em array para facilitar a codificação
						If Type("oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem") != "U" .And. Type("oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem") != "A"
							XmlNode2Arr(oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem, "_ApportionOrderItem")
						Endif

                  If Type("oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem") != "U"
							//-- Projeto
							For nK := 1 to Len(oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem)
								oXmlPrj := oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem[nK]

								If Type("oXmlPrj:_ProjectInternalId:Text") != "U" .And. !Empty(oXmlPrj:_ProjectInternalId:Text)
									aAux := IntPrjInt(oXmlPrj:_ProjectInternalId:Text, cMarca)

									If !aAux[1]
										lRet := aAux[1]
										cXmlRet := aAux[2]
										IIf(lLog, AdpLogEAI(5, "MATI410", cXMLRet, lRet), ConOut(STR0012))
										Return {lRet, cXmlRet, "ORDER"}
									Else
										aAdd(aItemAux, {"C6_PROJPMS", aAux[2][3], Nil})
										Exit
									EndIf
								Endif
							Next nK
							
							//-- Tarefa
							For  nK := 1 to Len(oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem)
								oXmlTask := oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem[nK]

								If Type("oXmlTask:_TaskInternalId:Text") != "U" .And. !Empty(oXmlTask:_TaskInternalId:Text)
									aAux := IntTrfInt(oXmlTask:_TaskInternalId:Text, cMarca)

									If !aAux[1]
										lRet := aAux[1]
										cXmlRet := aAux[2]
										IIf(lLog, AdpLogEAI(5, "MATI410", cXMLRet, lRet), ConOut(STR0012))
										Return {lRet, cXmlRet, "ORDER"}
									Else
										aAdd(aItemAux, {"C6_TASKPMS", aAux[2][5], Nil})
										Exit
									EndIf
								Endif
							Next nK
                  
                  EndIf

                  // Quantidade
                  If Type("oXmlAux:_Quantity:Text") != "U" .And. !Empty(oXmlAux:_Quantity:Text)
                     aAdd(aItemAux, {"C6_QTDVEN", Val(AllTrim(oXmlAux:_Quantity:Text)), Nil})
                  EndIf

                  // Preço unitário
                  If Type("oXmlAux:_UnityPrice:Text") != "U" .And. !Empty(oXmlAux:_UnityPrice:Text)
                     aAdd(aItemAux, {"C6_PRCVEN", Val(AllTrim(oXmlAux:_UnityPrice:Text)), Nil})
                     aAdd(aItemAux, {"C6_PRUNIT", Val(AllTrim(oXmlAux:_UnityPrice:Text)), Nil})
                  EndIf

                  // Preço total
                  If Type("oXmlAux:_TotalPrice:Text") != "U" .And. !Empty(oXmlAux:_TotalPrice:Text)
                     nPrcTtl += A410Arred(Val(oXmlAux:_TotalPrice:Text),"C6_VALOR")
                     aAdd(aItemAux, {"C6_VALOR", A410Arred(Val(oXmlAux:_TotalPrice:Text),"C6_VALOR"), Nil})
                  Else
                     nPrcTtl += A410Arred(Val(oXmlAux:_Quantity:Text) * Val(oXmlAux:_UnityPrice:Text),"C6_VALOR")
                     aAdd(aItemAux, {"C6_VALOR", A410Arred(Val(oXmlAux:_Quantity:Text) * Val(oXmlAux:_UnityPrice:Text),"C6_VALOR"), Nil})
                  EndIf

                  // Valor de desconto do item
                  If Type("oXmlAux:_ItemDiscounts:Text") != "U" .And. !Empty(oXmlAux:_ItemDiscounts:_ITEMDISCOUNT:Text)
                     aAdd(aItemAux, {"C6_VALDESC", Val(oXmlAux:_ItemDiscounts:_ITEMDISCOUNT:Text), Nil})      
                  EndIf

                  // Tipo de entrada e saída - TES
                  If Type("oXmlAux:_TypeOperation:Text") <> "U" .And. !Empty(oXmlAux:_TypeOperation:Text)
                     aAdd(aItemAux, {"C6_TES", oXmlAux:_TypeOperation:Text, Nil})
                  Else
                     // Se possui integração com o TOP
                     If IsIntegTop() .Or. Upper(AllTrim(cMarca)) == "HIS"
                        // Caso a TES não tenha sido informada, assume a TES do parametro MV_SLMTS
                        cTES := AllTrim(GetMV("MV_SLMTS"))
                        If !Empty(cTES)
                           aAdd(aItemAux, {"C6_TES", cTES, Nil})
                        Else
                           lRet := .F.
                           cXmlRet := STR0020 //"Preencha o parâmetro MV_SLMTS no Protheus."
                           AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                           Return {lRet, cXmlRet, "ORDER"}
                        EndIf
                     EndIf
                  EndIf    

                  // Centro de custo
                  //-- Ainda que centro de custo informado no rateio, grava o centro de custo informado no item
					   If Type("oXmlAux:_CostCenterInternalID:Text") != "U" .And. !Empty(oXmlAux:_CostCenterInternalID:Text) //-- Pelo InternalID
                     // O centro de Custo existe no de/para e na base
						   cCCusto := GetCCusto(oXmlAux:_CostCenterInternalId:Text, cMarca, cCosVer, oXmlAux:_OrderItem:Text, @cXMLRet)
					   ElseIf Type("oXmlAux:_CostCenterCode:Text") != "U" .And. !Empty(oXmlAux:_CostCenterCode:Text)  //-- Pelo código
						   cCCusto := oXmlAux:_CostCenterCode:Text
					   EndIf

					    // Preencher no item o Centro de Custo obtido ou retornar a falha na obtencao do Codigo do CC via Internal ID
					   If !Empty(cXMLRet)
						   lRet := .F.
						   AdpLogEAI(5, "MATI410", cXMLRet, lRet)
						   Return {lRet, cXmlRet, "ORDER"}
					   ElseIf !Empty(cCCusto)
						   aAdd(aItemAux, {"C6_CC", cCCusto, Nil})
					   EndIf
						   
                  If Type("oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem") != "U"	//-- Tem rateio
                           
                     aAdd(aItemAux, {"C6_RATEIO", "1", Nil})

                     For nJ := 1 To Len(oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem)
                        cCCusto := ""
                        // Atualiza objeto com a posição atual
                        oXmlRat := oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem[nJ]

                        // Possui centro de custo e percentual informado
                        If Type("oXmlRat:_CostCenterInternalId:Text") != "U" .And. !Empty(oXmlRat:_CostCenterInternalId:Text)
                           // Possui percentual informado
                           If Type("oXmlRat:_Percentual:Text") != "U" .And. !Empty(oXmlRat:_Percentual:Text)
                              // O centro de Custo existe no de/para e na base
                              cCCusto := GetCCusto(oXmlRat:_CostCenterInternalId:Text, cMarca, cCosVer, oXmlAux:_OrderItem:Text, @cXMLRet)
                              If !Empty(cXMLRet)
                                 lRet := .F.
                                 AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                                 Return {lRet, cXmlRet, "ORDER"}
                              EndIf

                              // Verifica se já existe o centro de custo para este item
                              nLin := aScan(aCCusto, {|x| x[3] == cCCusto})

                              // Caso já exista o centro de custo para o item somar o %
                              If nLin > 0
                                 aCCusto[nLin][2] += Val(oXmlRat:_Percentual:Text)
                              Else
                                 aAdd(aCCusto, {cItemSC6, Val(oXmlRat:_Percentual:Text), cCCusto})
                              EndIf
                           Else
                              lRet := .F.
                              cXmlRet := STR0023 /*"Percentual de rateio inválido para o item "*/ + cItemSC6 + "."
                              AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                              Return {lRet, cXmlRet, "ORDER"}
                           EndIf
                        EndIf
                     Next nJ

                     // Monta o array com os itens do rateio de centro de custo agrupados por centro de custo
                     aAux := {}
                     nTotPrcRat := 0

                     For nJ := 1 To Len(aCCusto)
                        aAdd(aLinha, {"AGG_FILIAL",  xFilial("AGG"),                           Nil})
                        aAdd(aLinha, {"AGG_PEDIDO",  "",                                       Nil})
                        aAdd(aLinha, {"AGG_FORNECE", cCliente,                                 Nil})
                        aAdd(aLinha, {"AGG_LOJA",    cLoja,                                    Nil})
                        aAdd(aLinha, {"AGG_ITEMPD",  aCCusto[nJ][1],                           Nil})
                        aAdd(aLinha, {"AGG_ITEM",    StrZero(nJ, TamSx3("AGG_ITEM")[1]),       Nil})
                        aAdd(aLinha, {"AGG_PERC",    aCCusto[nJ][2],                           Nil})
                        aAdd(aLinha, {"AGG_CC",      aCCusto[nJ][3],                           Nil})
                        aAdd(aLinha, {"AGG_CONTA",   "",                                       Nil})
                        aAdd(aLinha, {"AGG_ITEMCT",  "",                                       Nil})
                        aAdd(aLinha, {"AGG_CLVL",    "",                                       Nil})
                        aAdd(aAux, aLinha)
                        aLinha := {}
                        nTotPrcRat += aCCusto[nJ][2]
                     Next nJ

                     // Verificar se o percentual eh diferente do que 100%
                     If nTotPrcRat <> 100
                        cXmlRet := STR0050 /*"O total do percentual de rateio é diferente de 100% para o item "*/ + cItemSC6 + "."
                        lRet := .F.                        
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     EndIf

                     aCCusto := {}

                     aAdd(aItemRat, {cItemSC6, aAux})
                  
                  EndIf

                  aAdd(aItens, aClone(aItemAux))
                  aItemAux := {}
                  
               Next nI

               //Se não for array
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument)
                  If !Adiantamento(cCond)
                     lRet    := .F.
                     cXmlRet := STR0033 //"Para utilizar título de adiantamento a condição de pagamento do pedido deve ser do tipo adiantamento."
                     AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                     Return {lRet, cXmlRet, "ORDER"}
                  EndIf

                  If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument") != "A"
                     //Transforma em array
                     XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument, "_CreditDocument")
                  EndIf

                  For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument)
                     //Atualiza objeto com a posição atual
                     oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument[nI]

                     //Adiantamentos
                     If Type("oXmlAux:_CreditDocumentInternalId:Text") != "U" .And. !Empty(oXmlAux:_CreditDocumentInternalId:Text)
                        aAux := IntTRcInt(oXmlAux:_CreditDocumentInternalId:Text, cMarca, cTRcVer)

                        If !aAux[1]
                           lRet    := aAux[1]
                           cXmlRet := aAux[2]
                           AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                           Return {lRet, cXmlRet, "ORDER"}
                        EndIf
                     Else
                        lRet    := .F.
                        cXmlRet := STR0034 //"O InternalID do título de adiantamento não foi informado."
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     EndIf

                     dbSelectArea("SE1")
                     SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

                     If SE1->(dbSeek(xFilial("SE1") + PadR(aAux[2][3], TamSX3("FIE_PREFIX")[1]) + PadR(aAux[2][4], TamSX3("FIE_NUM")[1]) + PadR(aAux[2][5], TamSX3("FIE_PARCEL")[1]) + PadR(aAux[2][6], TamSX3("FIE_TIPO")[1])))
                        cCliente := SE1->E1_CLIENTE
                        cLoja    := SE1->E1_LOJA
                     Else
                        lRet    := .F.
                        cXmlRet := STR0035 + AllTrim(oXmlAux:_CreditDocumentInternalId:Text) + STR0036 //"Título de adiantamento " " não encontrado na base."
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     EndIf

                     If Type("oXmlAux:_Value:Text") == "U" .Or. Empty(oXmlAux:_Value:Text)
                        lRet    := .F.
                        cXmlRet := STR0037 //"O valor a ser abatido no título de adiantamento não foi informado."
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     EndIf

                     aAdd(aLinha, {"FIE_FILIAL", xFilial("FIE"),                            Nil})
                     aAdd(aLinha, {"FIE_CART",   "R",                                       Nil}) // Carteira receber
                     aAdd(aLinha, {"FIE_PEDIDO", "",                                        Nil})
                     aAdd(aLinha, {"FIE_PREFIX", PadR(aAux[2][3], TamSX3("FIE_PREFIX")[1]), Nil})
                     aAdd(aLinha, {"FIE_NUM",    PadR(aAux[2][4], TamSX3("FIE_NUM")[1]),    Nil})
                     aAdd(aLinha, {"FIE_PARCEL", PadR(aAux[2][5], TamSX3("FIE_PARCEL")[1]), Nil})
                     aAdd(aLinha, {"FIE_TIPO",   PadR(aAux[2][6], TamSX3("FIE_TIPO")[1]),   Nil})
                     aAdd(aLinha, {"FIE_CLIENT", PadR(cCliente,   TamSX3("FIE_CLIENT")[1]), Nil})
                     aAdd(aLinha, {"FIE_LOJA",   PadR(cLoja,      TamSX3("FIE_LOJA")[1]),   Nil})
                     aAdd(aLinha, {"FIE_VALOR",  Val(oXmlAux:_Value:Text),                  Nil}) // Valor do ra que está vinculado ao pedido

                     aAdd(aAdtPC, aClone(aLinha))
                     aLinha := {}
                  Next nI
               EndIf

                     //Valor do Desconto
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount)
                        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount") != "A"
                           XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount, "_Discount")
                        EndIf

                        //Valor de desconto
                        nValDesc += Round(Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount[1]:Text),TamSx3("C6_VALDESC")[2])

                        nPercDesc := Round(nPrcTtl / nValDesc,2)
                        nSomaDesc := 0
                        nDescIt := 0

                        For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item)
                           // Atualiza o objeto com a posição atual
                           oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nI]

                           nDescIt := Val(oXmlAux:_UnityPrice:Text) * nPercDesc / 100

                           nSomaDesc += nDescIt

                           If nI == Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item)
                           		If nSomaDesc <> nValDesc
                           			nDescIt += nValDesc - nSomaDesc
                           		Endif
                           Endif

                           // Verifica se já existe valor de desconto do item
                           nJ := aScan(aItens[nI], {|x| x[1] == "C6_VALDESC"})

                           // Caso já exista somar o valor
                           If nJ > 0
                              aItens[nI][nJ][2] := nDescIt
                           Else
                              aAdd(aItens[nI], {"C6_VALDESC", nDescIt, Nil})
                           EndIf
                        Next nI
                     EndIf
                  EndIf

				 // ponto de entrada inserido para controlar dados especificos do cliente
				  If ExistBlock("MT410EAI")
					  	aRetPe := ExecBlock("MT410EAI",.F.,.F.,{aCab,aItens})
						If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
							aCab 	:= aClone(aRetPe[1])
							aItens := aClone(aRetPe[2])
						EndIf
			      EndIf

	             AdpLogEAI(4, nOpcx)
	             AdpLogEAI(3, "aCab: ", aCab)
	             AdpLogEAI(3, "aItens: ", aItens)
	             AdpLogEAI(3, "aItemRat: ", aItemRat)
	             AdpLogEAI(3, "aAdtPC: ", aAdtPC)
	             AdpLogEAI(3, "aDePara: ", aDePara)

                  Begin Transaction

                  If nOpcx == 5
                     MSExecAuto({|x,y,z|MATA410(x,y,z)},aCab,aItens,nOpcx)
                  Else
                     MsExecAuto({|a,b,c,d,e,f| MATA410(a, b, c, d, , , , e, f)}, aCab, aItens, nOpcx, .F., aItemRat, aAdtPC)
                  EndIf

                  // Se houve erros no processamento do MSExecAuto
                  If lMsErroAuto
                     aErroAuto := GetAutoGRLog()

                     cXmlRet := "<![CDATA["
                     For nI := 1 To Len(aErroAuto)
                        cXmlRet += aErroAuto[nI] + Chr(10)
                     Next nI
                     cXmlRet += "]]>"

                     lRet := .F.

                     //Desfaz a transacao
                     DisarmTransaction()
                     msUnlockAll()
                  Else
                  	If nOpcx <> 5
	                     dbSelectArea("SC6")
	                     SC6->(dbsetorder(1))

	                     SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM))
	                     While SC6->(!EOF()) .And. SC6->(C6_FILIAL + C6_NUM) == SC5->(C5_FILIAL + C5_NUM)
	                        RecLock("SC6", .F.)
	                           SC6->C6_PMSID := C6_NUM
	                        msUnlock()

	                        SC6->(dbSkip())
	                     EndDo
	                  Endif

                     If nOpcx == 3 // INSERT
                        // Obtém o valor inserido pelo inicializador padrão após a execução da rotina automática
                        cValInt := IntPdVExt(cEmpAnt, xFilial("SC5"), SC5->C5_NUM, /*cItem*/, cPdVVer)[2] // EMPRESA|FILIAL|PEDIDO
                     EndIf

                     AdpLogEAI(3, "cValInt: ", cValInt)
                     AdpLogEAI(3, "cValExt: ", cValExt)

                     If nOpcx != 5
                        // Insere ou atualiza o registro na tabela XXF (de/para)
                        CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)
                     Else
                        // Exclui o registro na tabela XXF (de/para)
                        CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T., 1)
                     EndIf

                     // Loop para manipular os Itens na tabela XXF (de/para)
                     For nI := 1 To Len(aDePara)
                        If nOpcx != 5
                           cAux := IntPdVExt(cEmpAnt, xFilial("SC6"), SC5->C5_NUM, aDePara[nI][2], cPdVVer)[2]
                           CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], cAux, .F., 1)
                        Else
                           CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], aDePara[nI][2], .T., 1)
                        EndIf
                     Next nI

                     // Monta o XML de retorno (Cabeçalho)
                     cXMLRet := "<ListOfInternalId>"
                     cXMLRet +=    "<InternalId>"
                     cXMLRet +=       "<Name>OrderInternalId</Name>"
                     cXMLRet +=       "<Origin>" + cValExt + "</Origin>"
                     cXMLRet +=       "<Destination>" + cValInt + "</Destination>"
                     cXMLRet +=    "</InternalId>"
                     For nI := 1 To Len(aDePara)
                        cXMLRet += "<InternalId>"
                        cXMLRet +=    "<Name>ItemInternalId</Name>"
                        cXMLRet +=    "<Origin>" + aDePara[nI][1] + "</Origin>"
                        If nOpcx == 3 // INSERT
                        		cXMLRet += "<Destination>" + cEmpAnt + "|" + xFilial("SC5") + "|" + SC5->C5_NUM + "|" + aDePara[nI][2] + "|2" + "</Destination>"
                        Else
                        	  	cXMLRet += "<Destination>" + aDePara[nI][2] + "</Destination>"
                        EndIf
                        cXMLRet += "</InternalId>"
                     Next nI
                     cXMLRet += "</ListOfInternalId>"
                  EndIf

                  End Transaction
                  MsUnlockAll()

               ElseIf AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text) == "1"
                  aAdd(aRet, FWIntegDef("MATA120", cTypeMsg, cTypeTrans, cXML))

                  If !Empty(aRet)
                     lRet := aRet[1][1]
                     cXmlRet += aRet[1][2]
                  EndIf
               Else
                  lRet:= .F.
                  cXmlRet := STR0024 // "Tipo de Pedido inválido!"
                  AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                  Return {lRet, cXmlRet, "ORDER"}
               EndIf
            Else
               lRet := .F.
               cXmlRet := STR0025 // "Tipo de pedido não enviado."
               AdpLogEAI(5, "MATI410", cXMLRet, lRet)
               Return {lRet, cXmlRet, "ORDER"}
            EndIf
         Else
            lRet := .F.
            cXMLRet := STR0026 // "Erro no parser!"
            AdpLogEAI(5, "MATI410", cXMLRet, lRet)
            Return {lRet, cXmlRet, "ORDER"}
         EndIf
      ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
         //Faz o parser do XML de retorno em um objeto
         oXml := xmlParser(cXML, "_", @cError, @cWarning)

         //Se não houve erros na resposta
         If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
            //Verifica se a marca foi informada
            If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
               cMarca := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
            Else
               lRet := .F.
               cXmlRet := STR0027 // "Erro no retorno. O Product é obrigatório!"
               AdpLogEAI(5, "MATI410", cXMLRet, lRet)
               Return {lRet, EncodeUTF8(cXmlRet)}
            EndIf

            //Se não for array
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "A"
               //Transforma em array
               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
            EndIf

            For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)
            	 cNameInternalId := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Name:Text
               aAdd(aDePara, Array(4))

               //Verifica se o InternalId foi informado
               If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text)
                  //Não armazena Rateio
                  If 'ORDER' $ AllTrim(Upper(cNameInternalId)) .Or. 'ITEMINTERNALID' == AllTrim(Upper(cNameInternalId))
                     aDePara[nI][3] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text
                  EndIf
               Else
                  lRet    := .F.
                  cXmlRet := STR0028 // "Erro no retorno. O OriginalInternalId é obrigatório!"
                  AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                  Return {lRet, EncodeUTF8(cXmlRet)}
               EndIf

               //Verifica se o código externo foi informado
               If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text)
                  //Não armazena Rateio
                  If 'ORDER' $ AllTrim(Upper(cNameInternalId)) .Or. 'ITEM' $ AllTrim(Upper(cNameInternalId))
                     aDePara[nI][4] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text
                  EndIf
               Else
                  lRet    := .F.
                  cXmlRet := STR0029 // "Erro no retorno. O DestinationInternalId é obrigatório!"
                  AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                  Return {lRet, EncodeUTF8(cXmlRet)}
               EndIf

               //Envia os valores de InternalId e ExternalId para o Log
               AdpLogEAI(3, "cValInt" + Str(nI) + ": ", aDePara[nI][2]) // InternalId
               AdpLogEAI(3, "cValExt" + Str(nI) + ": ", aDePara[nI][3]) // ExternalId

               If 'ITEM' $ AllTrim(Upper(cNameInternalId))
                  aDePara[nI][1] := "SC6"
                  aDePara[nI][2] := "C6_ITEM"
               ElseIf 'ORDER' $ AllTrim(Upper(cNameInternalId))
                  aDePara[nI][1] := "SC5"
                  aDePara[nI][2] := cField
               EndIf
            Next nI

            //Obtém a mensagem original enviada
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
               cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
            Else
               lRet := .F.
               cXmlRet := STR0030 // "Conteúdo do MessageContent vazio!"
               AdpLogEAI(5, "MATI410", cXMLRet, lRet)
               Return {lRet, EncodeUTF8(cXmlRet)}
            EndIf

            //Faz o parse do XML em um objeto
            oXML := XmlParser(cXML, "_", @cError, @cWarning)

            If Empty(oXML) .And. "UTF-8" $ Upper(cXML)
               oXML := xmlParser(EncodeUTF8(cXML), "_", @cError, @cWarning)
            EndIf

            //Se não houve erros no parse
            If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
               //Loop para manipular os InternalId no de/para
               For nI := 1 To Len(aDePara)
                  If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
                     CFGA070Mnt(cMarca, aDePara[nI][1], aDePara[nI][2], aDePara[nI][4], aDePara[nI][3], .F., 1)
                  ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
                     CFGA070Mnt(cMarca, aDePara[nI][1], aDePara[nI][2], aDePara[nI][4], aDePara[nI][3], .T., 1)
                  Else
                     lRet := .F.
                     cXmlRet := STR0031 // "Evento do retorno inválido!"
                  EndIf
               Next nI
            Else
               lRet := .F.
               cXmlRet := STR0032 // "Erro no parser do retorno!"
               AdpLogEAI(5, "MATI410", cXMLRet, lRet)
               Return {lRet, EncodeUTF8(cXmlRet)}
            EndIf
         Else
            //Se não for array
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
               //Transforma em array
               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            EndIf

            //Percorre o array para obter os erros gerados
            For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
               cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + Chr(10)
            Next nI

            lRet := .F.
            cXmlRet := cError
         EndIf
      ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
         cXMLRet := "1.000|3.000|3.001|3.002|3.004|3.005|4.003"
      EndIf
      // Mensagem de Saída
   ElseIf cTypeTrans == TRANS_SEND
      //Verica operação realizada e insere no LOG
      Do Case
         Case Inclui
            AdpLogEAI(4, 3)
         Case Altera
            AdpLogEAI(4, 4)
         OtherWise
            AdpLogEAI(4, 5)
            cEvent := "delete"
      EndCase

      If  cEvent <> "delete" // Não faz o seek no Delete, pois o registro ja foi deletado e desposiciona o numero do pedido
         SC5->(dbSeek(xFilial("SC5") + SC5->C5_NUM))
      EndIf   

      cXMLRet := '<BusinessEvent>'
      cXMLRet +=    '<Entity>Order</Entity>'
      cXMLRet +=    '<Event>' + cEvent + '</Event>'
      cXMLRet +=    '<Identification>'
      cXMLRet +=       '<key name="InternalId">' + IntPdVExt(cEmpAnt, xFilial("SC5"), SC5->C5_NUM, Nil, cPdVVer)[2] + '</key>'
      cXMLRet +=    '</Identification>'
      cXMLRet += '</BusinessEvent>'
      cXMLRet += '<BusinessContent>'
      cXMLRet +=    '<InternalId>' + IntPdVExt(cEmpAnt, xFilial("SC5"), SC5->C5_NUM, Nil, cPdVVer)[2] + '</InternalId>'
      cXmlRet +=    '<OrderPurpose>2</OrderPurpose>' // 2 - pedido de venda
      // SIGALOC - módulo 94 - Frank Fuga 19/09/2022
      // ordertypecode específico para integracao com o SIGALOC e RM
      If lMT410TCOD
	 	   cXmlRet += ExecBlock("MT410TCODE",.F.,.F.,{})
      Else
         cXmlRet +=  '<ordertypecode>' + SC5->C5_TIPO + '</ordertypecode>'
      EndIF
      cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
      cXMLRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
      cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '</CompanyInternalId>'
      cXMLRet +=    '<OrderId>' + RTrim(SC5->C5_NUM) + '</OrderId>'

      If Inclui .Or. Altera
         cXmlRet += '<CustomerInternalId>' + IntCliExt(/*Empresa*/, /*Filial*/, SC5->C5_CLIENTE, SC5->C5_LOJACLI, cCusVer)[2] + '</CustomerInternalId>'
         cXmlRet += '<CustomerCode>' + RTrim(SC5->C5_CLIENTE) + RTrim(SC5->C5_LOJACLI) + '</CustomerCode>'
         cXMLRet += '<CurrencyCode>' + PadR(RTrim(cValToChar(SC5->C5_MOEDA)), TamSx3('C5_MOEDA')[1] ) + '</CurrencyCode>'
         cXMLRet += '<CurrencyId>' + IntMoeExt(/*cEmpresa*/, /*Filial*/, PadR(RTrim(cValToChar(SC5->C5_MOEDA)),TamSx3('C5_MOEDA')[1] ), cMoeVer)[2] + '</CurrencyId>'
         cXMLRet += '<PaymentTermCode>' + RTrim(SC5->C5_CONDPAG) + '</PaymentTermCode>'
         cXmlRet += '<PaymentConditionInternalId >' + IntConExt(/*Empresa*/, /*Filial*/, SC5->C5_CONDPAG, cConVer)[2] + '</PaymentConditionInternalId >'
         cXMLRet += '<RegisterDate>' + Transform(DtoS( SC5->C5_EMISSAO),'@R 9999-99-99') + '</RegisterDate>'
         cXmlRet += '<FreightType>' + getTpFre(SC5->C5_TPFRETE, cTypeTrans) + '</FreightType>'
         cXmlRet += '<FreightValue>' + RTrim(cValToChar(SC5->C5_FRETE)) + '</FreightValue>'
         cXmlRet += '<GrossWeight>' + RTrim(cValToChar(SC5->C5_PBRUTO))  + '</GrossWeight>'
         cXmlRet += '<InsuranceValue>' + RTrim(cValToChar(SC5->C5_SEGURO)) + '</InsuranceValue>'
         cXmlRet += '<Discounts>'
         cXmlRet +=    '<Discount>' + RTrim(cValToChar(SC5->C5_DESC1)) + '</Discount>'
         cXmlRet +=    '<Discount>' + RTrim(cValToChar(SC5->C5_DESC2)) + '</Discount>'
         cXmlRet +=    '<Discount>' + RTrim(cValToChar(SC5->C5_DESC3)) + '</Discount>'
         cXmlRet +=    '<Discount>' + RTrim(cValToChar(SC5->C5_DESC4)) + '</Discount>'
         cXmlRet += '</Discounts>'
         // SIGALOC - módulo 94 - Frank Fuga 19/09/2022
         // inserção de novas tags específicas na integracao entre o Rental e RM
         If lLOCAXRMC 
            cXmlRet := ExecBlock("LOCAXRMC", .F., .F., {cXmlRet})
         EndIF
         cXMLRet += '<SalesOrderItens>'

         // Itens Pedido de Venda
         SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

         If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
            While SC6->(!EOF()) .And. SC6->C6_FILIAL + SC6->C6_NUM == SC5->C5_FILIAL + SC5->C5_NUM
               cXmlRet += '<Item>'
               cXmlRet +=    '<InternalId>' + IntPdVExt(cEmpAnt, xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, cPdVVer)[2] + '</InternalId>'
               cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
               cXmlRet +=    '<BranchId>' + RTrim(cFilAnt) + '</BranchId>'
               cXmlRet +=    '<OrderId>' + RTrim(SC6->C6_NUM) + '</OrderId>'
               cXMLRet +=    '<OrderItem>' + RTrim(SC6->C6_ITEM) + '</OrderItem>'
               cXMLRet +=    '<ItemCode>' + RTrim(SC6->C6_PRODUTO) + '</ItemCode>'
               cXmlRet +=    '<ItemDescription>' + RTrim(SC6->C6_DESCRI) + '</ItemDescription>'
               cXmlRet +=    '<ItemInternalId>' + IntProExt(/*cEmpresa*/, /*cFilial*/, SC6->C6_PRODUTO)[2] + '</ItemInternalId>'
               cXmlRet +=    '<itemunitofmeasure>' + RTrim(SC6->C6_UM) + '</itemunitofmeasure>'
               cXmlRet +=    '<UnitOfMeasureInternalId>' + IntUndExt(/*Empresa*/, /*Filial*/, SC6->C6_UM, cUndVer)[2] + '</UnitOfMeasureInternalId>'
               cXmlRet +=    '<Quantity>' + cValToChar(SC6->C6_QTDVEN) + '</Quantity>'
               cXmlRet +=    '<QuantityReached/>'
               cXmlRet +=    '<UnityPrice>' + cValToChar(SC6->C6_PRCVEN) + '</UnityPrice>'
               cXmlRet +=    '<TotalPrice>' + cValToChar(SC6->C6_VALOR) + '</TotalPrice>'
               cXmlRet +=    '<CostCenterCode>' + RTrim(SC6->C6_CC) + '</CostCenterCode>'
               cXmlRet +=    '<CostCenterInternalId>' +IntCusExt(/*cEmpresa*/,/*cFilial*/, SC6->C6_CC, cCosVer)[2] + '</CostCenterInternalId>'
               cXmlRet +=    '<ItemDiscounts>'
               cXmlRet +=       '<ItemDiscount>' + cValToChar(SC6->C6_VALDESC) + '</ItemDiscount>'
               cXmlRet +=    '</ItemDiscounts>'
               cXmlRet +=    '<WarehouseInternalId>' + IntLocExt(/*Empresa*/, /*Filial*/, SC6->C6_LOCAL)[2] + '</WarehouseInternalId>'
               cXmlRet +=    '<TypeOperation>' + RTrim(SC6->C6_TES) + '</TypeOperation>'
               cXmlRet +=    '<RequestItemInternalId/>'

               // SIGALOC - módulo 94 - Frank Fuga 19/09/2022
               // Novas tags na integracao entre o SIGALOC e RM
				   If lLOCAXRMI 
   					cXmlRet := ExecBlock("LOCAXRMI", .F., .F., {cXmlRet})
				   EndIF
               // Integração com o TOTVS Obras e Projetos
               If IsIntegTop()
                 aRateio := RatPV(SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_CLI + SC6->C6_LOJA + SC6->C6_ITEM)

                 IIf(!Empty(aRateio), cXMLRet += '<ListOfApportionOrderItem>', '')

                 For nI := 1 To Len(aRateio)
                    cXmlRet += '<ApportionOrderItem>'
                    cXmlRet +=    '<InternalId>' + IntPdVExt(cEmpAnt, xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, cPdVVer)[2] + RTrim(cValToChar(nI)) + '</InternalId>'
                    cXMLRet +=    '<DepartamentCode/>'
                    cXMLRet +=    '<DepartamentInternalId/>'
                    cXmlRet +=    '<CostCenterInternalId>' + IIf(!Empty(aRateio[nI][1]), IntCusExt(/*cEmpresa*/, /*cFilial*/, aRateio[nI][1], cCosVer)[2], '') + '</CostCenterInternalId>'
                    cXmlRet +=    '<AccountantAcountInternalId>' + IIf(!Empty(aRateio[nI][2]), cEmpAnt + "|" + xFilial("CT1") + "|" + AllTrim(aRateio[nI][2]), '') + '</AccountantAcountInternalId>' //CTBI020
                    cXMLRet +=    '<ProjectInternalId>' + IIf(!Empty(aRateio[nI][6]), IntPrjExt(/*cEmpresa*/, /*cFilial*/, aRateio[nI][6])[2], '') + '</ProjectInternalId>'
                    cXMLRet +=    '<SubProjectInternalId/>'
                    cXMLRet +=    '<TaskInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][7])), IntTrfExt(/*cEmpresa*/, /*cFilial*/, aRateio[nI][6], '0001', aRateio[nI][7])[2], '') + '</TaskInternalId>'
                    cXMLRet +=    IIf(Empty(aRateio[nI][5]) .Or. aRateio[nI][5] == 0, '<Value/>', '<Value>' + cValToChar(aRateio[nI][5] * SC6->C6_PRCVEN * SC6->C6_QTDVEN / 100) + '</Value>')
                    cXMLRet +=    '<Percentual>' + cValToChar(aRateio[nI][5]) + '</Percentual>'
                    cXMLRet +=    '<Quantity>' + cValToChar(aRateio[nI][8]) + '</Quantity>'
                    cXMLRet +=    '<Observation/>'
                    cXmlRet += '</ApportionOrderItem>'
                 Next nI

                 IIf(!Empty(aRateio), cXMLRet += '</ListOfApportionOrderItem>', '<ListOfApportionOrderItem/>')
               Else
                  // Rateio por Centro de Custo
                  If SC6->C6_RATEIO == '1'
                     AGG->(DbSetOrder(1)) // AGG_FILIAL+AGG_PEDIDO+AGG_FORNEC+AGG_LOJA+AGG_ITEMPD+AGG_ITEM

                     If AGG->(DbSeek(xFilial('SC6') + SC6->C6_NUM + SC6->C6_CLI + SC6->C6_LOJA + SC6->C6_ITEM))
                        cXmlRet += '<ListOfApportionOrderItem>'

                        While AGG->(!EOF() .And. AGG->AGG_FILIAL + AGG->AGG_PEDIDO + AGG->AGG_FORNEC + AGG->AGG_LOJA + AGG->AGG_ITEMPD == xFilial('SC6') + SC6->C6_NUM + SC6->C6_CLI + SC6->C6_LOJA + SC6->C6_ITEM)
                           cXmlRet += '<ApportionOrderItem>'
                           cXMLRet +=    '<InternalId>' + IntPdVExt(cEmpAnt, xFilial('AGG'), AGG->AGG_PEDIDO, AGG->AGG_ITEMPD, cPdVVer)[2] + '|' + RTrim(AGG->AGG_ITEM) + '</InternalId>'
                           cXmlRet +=    '<CostCenterInternalId>' + IIf(!Empty(AllTrim(AGG->AGG_CC)), IntCusExt(/*cEmpresa*/, /*cFilial*/, AGG->AGG_CC, cCosVer)[2], '') + '</CostCenterInternalId>'
                           cXMLRet +=    '<AccountantAcountInternalId>' + IIf(!Empty(AGG->AGG_CONTA), cEmpAnt + "|" + xFilial("CT1") + "|" + AllTrim(AGG->AGG_CONTA), '') + '</AccountantAcountInternalId>' //CTBI020
                           cXMLRet +=    '<Percentual>' + cValToChar(AGG->AGG_PERC) + '</Percentual>'
                           cXmlRet += '</ApportionOrderItem>'
                           AGG->(DbSkip())
                        EndDo

                        cXmlRet += '</ListOfApportionOrderItem>'
                     EndIf
                  EndIf
               EndIf

               cXmlRet+= '</Item>'
               SC6->(dbSkip())
            EndDo

            SC6->(dbCloseArea())
         EndIf

         cXmlRet +=    '</SalesOrderItens>'
      EndIf

      cXmlRet += '</BusinessContent>'
   EndIf

   AdpLogEAI(5, "MATI410", cXMLRet, lRet)
Return {lRet, cXmlRet, "ORDER"}

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MATI410
Funcao de integracao com o adapter EAI para envio e recebimento do
Pedido de Venda (SC5/SC6/AGG) utilizando o conceito de mensagem unica
(Order).

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   cTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMsg      Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Alan Oliveira
@version P12
@since   23/10/2017
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//----------------------------------------------------------------------------------

Static Function v4003(cXml, cTypeTrans, cTypeMsg)

   Local lRet             := .T.
   Local cAlias           := "SC5"
   Local cField           := "C5_NUM"
   Local cEvent           := "upsert"
   Local cXmlRet          := ""
   Local cError           := ""
   Local cWarning         := ""
   Local cValExt          := ""
   Local cValInt          := ""
   Local cMarca           := ""
   Local cNumPed          := ""
   Local cCliente         := ""
   Local cLoja            := ""
   Local cDatEmis         := ""
   Local cItemSC6         := ""
   Local cTES             := ""
   Local cAux             := ""
   Local aCab             := {}
   Local aItens           := {}
   Local aErroAuto        := {}
   Local aAux             := {}
   Local aCCusto          := {}
   Local aProjeto         := {}
   Local aItemRat         := {}
   Local aLinha           := {}
   Local aDePara          := {}
   Local aItemAux         := {}
   Local aRateio          := {}
   Local aRet             := {}
   Local aAreaSON         := {}
   Local nOpcx            := 0
   Local nI               := 0
   Local nJ               := 0
   Local nLin             := 0
   Local nItemRat         := 1
   Local nPrcTtl          := 0
   Local nPercDesc        := 0
   Local nValDesc         := 0
   Local nK               := 0
   Local nTamC6ITEM       := TamSx3("C6_ITEM")[1]
   Local aAdtPC           := {}
   Local cCond            := ""
   Local cNameInternalId  := ""
   Local cCusVer          := RTrim(PmsMsgUVer('CUSTOMERVENDOR',            'MATA030' .OR. 'CRMA980')) //Versão do Cliente/Fornecedor
   Local cCosVer          := RTrim(PmsMsgUVer('COSTCENTER',                'CTBA030')) //Versão do Centro de Custo
   Local cUndVer          := RTrim(PmsMsgUVer('UNITOFMEASURE',             'QIEA030')) //Versão da Unidade de Medida
   Local cConVer          := RTrim(PmsMsgUVer('PAYMENTCONDITION',          'MATA360')) //Versão da Condição de Pagamento
   Local cMoeVer          := RTrim(PmsMsgUVer('CURRENCY',                  'CTBA140')) //Versão da Moeda
   Local cLocVer          := RTrim(PmsMsgUVer('WAREHOUSE',                 'AGRA045')) //Versão do Local de Estoque
   Local cPrdVer          := RTrim(PmsMsgUVer('ITEM',                      'MATA010')) //Versão do Produto
   Local cPrjVer          := RTrim(PmsMsgUVer('PROJECT',                   'PMSA200')) //Versão do Projeto
   Local cTrfVer          := RTrim(PmsMsgUVer('TASKPROJECT',               'PMSA203')) //Versão da Tarefa
   Local cTRcVer          := RTrim(PmsMsgUVer('ACCOUNTRECEIVABLEDOCUMENT', 'FINA040')) //Versão do Título a Receber
   Local cPdVVer          := RTrim(PmsMsgUVer('ORDER',                     'MATA410')) //Versão do Pedido de Venda
   Local aCodcfop		  := {}
   Local cTpOpera         := ""
   Local cCodProd		  := ""
   Local cSONCodExt       := ""
   Local lWorkCode        := AF8->(ColumnPos("AF8_CNO"))>0
   Local aItemAPos        := {}
   Local aAposEsp         := {}
   Local n15Anos          := 0
   Local n20Anos          := 0
   Local n25Anos          := 0
   Local cLote			  := ""
   Local cSubLote		  := ""
   Local cSerie			  := ""
   Local cLocaliz		  := ""
   Local aReserva		  := ""
   Local aReserv		  := {} //Array com as Reservas que devem ser processadas junto com a Venda.
   Local cValExtRes       := ""
   Local cDocRes          := "" //Documento Responsável pela Reserva
   Local lIntegSC0		  := FWHasEAI("LOJA704",,.T., .T.) //Flag integracao da ItemReserve
   Local cMenNota         := "" //Mensagem para nota.
   Local nContAux         := 0
   Local cCCusto          := ""
   Local nTotPrcRat       := 0
   Local cDatFat          := ""
   Local cDataEnt         := ""
   Local cNota            := ""
   Local lLock            := .F.

   Private oXml           := Nil
   Private oXmlAux        := Nil
   Private oXmlRat        := Nil
   Private oXMLRatCC      := Nil
   Private lMsErroAuto    := .F.
   Private lAutoErrNoFile := .T.

   AdpLogEAI(1, "MATI410", cTypeTrans, cTypeMsg, cXML)

   //Mensagem de Entrada
   If cTypeTrans == TRANS_RECEIVE
      //Regra de Negócio
      If cTypeMsg == EAI_MESSAGE_BUSINESS
         oXml := XmlParser(cXml, "_", @cError, @cWarning)

         //Se não houve erro no parser
         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text)
               If AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text) == "2"
                  //Marca
                  If Type("oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
                     cMarca := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
                  Else
                     lRet := .F.
                     cXmlRet := STR0013 // "Informe a Marca!"
                     AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                     Return {lRet, cXmlRet, "ORDER"}
                  EndIf

                  //InternalId do pedido
                  If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
                     cValExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
                  Else
                     lRet := .F.
                     cXmlRet := STR0014 // "O InternalId é obrigatório!"
                     AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                     Return {lRet, cXmlRet, "ORDER"}
                  EndIf

                  //Obtém o InternalId
                  cValInt := RTrim(CFGA070INT(cMarca, cAlias, cField, cValExt))

                  //Se encontrou no de/para
                  If !Empty(cValInt)
                     cNumPed := PadR(StrTokArr(cValInt, "|")[3], TamSX3("C5_NUM")[1])

                     If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
                        nOpcx := 4 //UPDATE
                     Else
                        nOpcx := 5 //DELETE


                        If SC6->(dbSeek(xFilial("SC6") + cNumPed))
                           While xFilial("SC6") + cNumPed == SC6->C6_FILIAL + SC6->C6_NUM
                              cAux := IntPdVExt(/*cEmpresa*/, SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, cPdVVer)[2]

                              // Array que será usado ao manipular o de/para de itens
                              aAdd(aItemAux, RTrim(CFGA070Ext(cMarca, "SC6", "C6_ITEM", cAux)))
                              aAdd(aItemAux, cAux)
                              aAdd(aItemAux, "SC6")
                              aAdd(aItemAux, "C6_ITEM")
                              aAdd(aDePara, aItemAux)

                              SC6->(dbSkip())
                           EndDo
                        EndIf
                     EndIf

                     aAdd(aCab, {"C5_FILIAL", xFilial("SC5"), Nil})
                     aAdd(aCab, {"C5_NUM",    cNumPed,         Nil})
                  Else
                     If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
                        nOpcx := 3 //INSERT
                     Else
                        lRet := .F.
                        cXmlRet := STR0017 // "O registro a ser excluído não foi encontrado na base Protheus."
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     EndIf
                  EndIf

                  //Se não é exclusão
                  If nOpcx != 5
                     // Tipo pedido
                     aAdd(aCab, {"C5_TIPO", "N", Nil})

                     // Obtém o Código Interno do Cliente e a Loja
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text)
                        aAux := IntCliInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text, cMarca, cCusVer)
                        If !aAux[1]
                           lRet := aAux[1]
                           cXmlRet := aAux[2]
                           AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                           Return {lRet, cXmlRet, "ORDER"}
                        Else
                           cCliente := aAux[2][3]
                           cLoja := aAux[2][4]
                           aAdd(aCab, {"C5_CLIENTE", cCliente, Nil})
                           aAdd(aCab, {"C5_LOJACLI",    cLoja,    Nil})
                        EndIf
                     ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text)
                        If Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text) > TamSX3("C5_CLIENTE")[1]
                           cCliente := SubStr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text, 1, TamSX3("C5_CLIENTE")[1])
                           cLoja    := PadR(SubStr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text, TamSX3("C5_CLIENTE")[1] + 1), TamSX3("C5_LOJACLI")[1])
                        Else
                           cCliente := PadR(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text, TamSX3("C5_CLIENTE")[1])
                           cLoja   := "01"
                        EndIf
                        aAdd(aCab, {"C5_CLIENTE", cCliente, Nil})
                        aAdd(aCab, {"C5_LOJACLI",    cLoja,    Nil})
                     EndIf

                     //Obtém o Código Interno da Condição de Pagamento
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentConditionInternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentConditionInternalId:Text)
                        aAux := IntConInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentConditionInternalId:Text, cMarca, cConVer)
                        If !aAux[1]
                           lRet := aAux[1]
                           cXmlRet := aAux[2]
                           AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                           Return {lRet, cXmlRet, "ORDER"}
                        Else
                           cCond := aAux[2][3]
                           aAdd(aCab, {"C5_CONDPAG", cCond, Nil})
                        EndIf
                     ElseIf IsIntegTop() .Or. Upper(AllTrim(cMarca)) == "HIS"
                        cCond := SuperGetMV("MV_SLMCOND", .F., "")
                        aAdd(aCab, {"C5_CONDPAG", cCond, Nil})
                     ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text)
                        cCond := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text
                        aAdd(aCab, {"C5_CONDPAG", cCond, Nil})
                     EndIf

                     // Data de Emissão
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text") <> "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text)
                        cDatEmis := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text
                        aAdd(aCab, {"C5_EMISSAO", cTod(SubStr(cDatEmis, 9, 2) + "/" + SubStr(cDatEmis, 6, 2 ) + "/" + SubStr(cDatEmis, 1, 4 )), Nil})
                     EndIf

                     // Tipo de Frete
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text)
                        aAdd(aCab, {"C5_TPFRETE", getTpFre(AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text), cTypeTrans), Nil})
                     EndIf

                     // Frete
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text)
                        aAdd(aCab, {"C5_FRETE", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text), Nil})
                     EndIf

                     // Peso Bruto
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text)
                        aAdd(aCab, {"C5_PBRUTO", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text), Nil})
                     EndIf

                     // Valor do Seguro
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text)
                        aAdd(aCab, {"C5_SEGURO", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text), Nil})
                     EndIf

                     //Moeda
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyId:Text)
                     	cAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyId:Text
                     	aAux := GetCurrId(cAux,cMarca, cMoeVer)
                        If !aAux[1]
                           lRet := aAux[1]
                           cXmlRet := aAux[2]
                           AdpLogEAI(1, "MATI410", cTypeTrans, cTypeMsg, cXML)
                           Return {lRet, cXmlRet, "ORDER"}
                        Else
                           aAdd(aCab, {"C5_MOEDA", Val(aAux[2][3]), Nil})
                        EndIf
                     ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text)
                        aAdd(aCab, {"C5_MOEDA", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text), Nil})
                     EndIf

                     //Natureza
                     If IsIntegTop() .Or. Upper(AllTrim(cMarca)) == "HIS"
                        aAdd(aCab, {"C5_NATUREZ", GetNewPar("MV_SLMNTPV", .F., ""), Nil})
                     EndIf

                     If lWorkCode
	                     //Codigo da Obra - Utilizamos o codigo da obra externo
	                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkCode:Text") != "U"
		                     If !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkCode:Text)
		                 		aAreaSON := SON->(GetArea())
		                        cSONCodExt := AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WorkCode:Text)
		                        SON->(DbSetOrder(3))
		                        If SON->( DBSeek( xFilial("SON") + cSONCodExt ) )
		                        	aAdd(aCab,{"C5_CNO", SON->ON_CODIGO, Nil})
		                        Else
		                            lRet := .F.
		                            cXmlRet := STR0046 //"Código da obra não localizado no Cadastro Nacional de Obras!"
		                            AdpLogEAI(5, "MATI410", cXMLRet, lRet)
		                            Return {lRet, cXmlRet, "ORDER"}
		                        EndIf
		                        RestArea(aAreaSON)
			                 Else
			                 	aAdd(aCab,{"C5_CNO"," ", Nil})
			                 EndIf
	                     EndIf
                     EndIf
                     //Msg. P/ Nota
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage") <> "U"
                        If ValType(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage) <> "A"
                            XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage, "_InvoiceMessage")
                        EndIf
                        For nContAux := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage)
                            If !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage[nContAux]:Text)
                                cMenNota += oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceMessages:_InvoiceMessage[nContAux]:Text
                            EndIf
                        Next nCountAux

                        If !Empty(cMenNota)
                            aAdd(aCab,{"C5_MENNOTA"         ,cMenNota           , Nil })
                        EndIf
                    EndIf
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceNumber:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceNumber:Text)
                        cNota := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceNumber:Text
                        aAdd(aCab,{"C5_NOTA", cNota           , Nil })
                     Endif
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceSerie:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceSerie:Text)
                        cSerie := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InvoiceSerie:Text
                        aAdd(aCab,{"C5_SERIE", cSerie           , Nil })
                     Endif
                     //Origem
                     If Upper(AllTrim(cMarca)) == "LOGIX"
                        aAdd(aCab,{"C5_ORIGEM",Upper(AllTrim(cMarca)), Nil })
                     Else
                        aAdd(aCab,{"C5_ORIGEM","MSGEAI", Nil})
                     Endif

               // Se não for array
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item") != "A"
                     XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item, "_Item")
               EndIf

               For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item)
                  cItemSC6 := RetAsc(nI,nTamC6ITEM,.T.)
                  cCodProd := ""
                  aItemAPos:= {}
                  aReserva := ""
                  cLote	 := ""
                  cSubLote := ""
                  cSerie	 := ""
                  cLocaliz := ""

                  // Atualiza o objeto com a posição atual
                  oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nI]

                  // Array que será usado ao manipular o de/para de itens
                  aAdd(aDePara, Array(4))
                  aDePara[nI][1] := oXmlAux:_InternalId:Text
                  aDePara[nI][2] := PadL(oXmlAux:_OrderItem:Text, nTamC6ITEM, "0")
                  aDePara[nI][3] := "SC6"
                  aDePara[nI][4] := "C6_ITEM"

                  aAdd(aItemAux, {"C6_ITEM", cItemSC6, Nil})

                  // Obtém o Código Interno do produto
                  If Type("oXmlAux:_ItemInternalId:Text") != "U" .And. !Empty(oXmlAux:_ItemInternalId:Text)
                     aAux := IntProInt(oXmlAux:_ItemInternalId:Text, cMarca)
                     If !aAux[1]
                        lRet := aAux[1]
                        cXmlRet := aAux[2]
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     Else
                        cCodProd := PadR(aAux[2][3], TamSX3("C6_PRODUTO")[1])
                        aAdd(aItemAux, {"C6_PRODUTO",cCodProd , Nil})
                     EndIf
                  ElseIf Type("oXmlAux:_ItemCode:Text") != "U" .And. !Empty(oXmlAux:_ItemCode:Text)
                     cCodProd := PadR(oXmlAux:_ItemCode:Text, TamSX3("C6_PRODUTO")[1])
                     aAdd(aItemAux, {"C6_PRODUTO", cCodProd, Nil})
                  EndIf

                  // Descrição do produto
                  If Type("oXmlAux:_ItemDescription:Text") != "U" .And. !Empty(oXmlAux:_ItemDescription:Text)
                     aAdd(aItemAux , {"C6_DESCRI" , AllTrim(oXmlAux:_ItemDescription:Text) , Nil } )
                  EndIf

                  // Obtém o código interno do local de estoque
                  If Type("oXmlAux:_WarehouseInternalId:Text") != "U" .And. !Empty(oXmlAux:_WarehouseInternalId:Text)
                     aAux := IntLocInt(oXmlAux:_WarehouseInternalId:Text, cMarca)
                     If !aAux[1]
                        lRet := aAux[1]
                        cXmlRet := aAux[2]
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet,"ORDER"}
                     Else
                        aAdd(aItemAux, {"C6_LOCAL", aAux[2][3], Nil})
                     EndIf
                  EndIf

                  // Unidade de Medida do Item
                  If Type("oXmlAux:_UnitOfMeasureInternalIdIf:Text") != "U" .And. !Empty(oXmlAux:_UnitOfMeasureInternalIdIf:Text)
                     aAux := IntUndInt(oXmlAux:_UnitOfMeasureInternalIdIf:Text, cMarca, cUndVer)
                     If !aAux[1]
                        lRet := aAux[1]
                        cXmlRet := aAux[2]
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     Else
                        aAdd(aItemAux, {"C6_UM", aAux[2][3], Nil})
                     EndIf
                  ElseIf Type("oXmlAux:_itemunitofmeasure:Text") != "U" .And. !Empty(oXmlAux:_itemunitofmeasure:Text)
                     aAdd(aItemAux, {"C6_UM", oXmlAux:_itemunitofmeasure:Text, Nil})
                  EndIf

                  //-- Se informações de rateio em item único, transforma em array para facilitar a codificação
						If Type("oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem") != "U" .And. Type("oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem") != "A"
							XmlNode2Arr(oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem, "_ApportionOrderItem")
						Endif

                  If Type("oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem") != "U"
							//-- Projeto
							For nK := 1 to Len(oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem)
								oXmlPrj := oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem[nK]

								If Type("oXmlPrj:_ProjectInternalId:Text") != "U" .And. !Empty(oXmlPrj:_ProjectInternalId:Text)
									aAux := IntPrjInt(oXmlPrj:_ProjectInternalId:Text, cMarca)

									If !aAux[1]
										lRet := aAux[1]
										cXmlRet := aAux[2]
										IIf(lLog, AdpLogEAI(5, "MATI410", cXMLRet, lRet), ConOut(STR0012))
										Return {lRet, cXmlRet, "ORDER"}
									Else
										aAdd(aItemAux, {"C6_PROJPMS", aAux[2][3], Nil})
										Exit
									EndIf
								Endif
							Next nK
							
							//-- Tarefa
							For  nK := 1 to Len(oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem)
								oXmlTask := oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem[nK]

								If Type("oXmlTask:_TaskInternalId:Text") != "U" .And. !Empty(oXmlTask:_TaskInternalId:Text)
									aAux := IntTrfInt(oXmlTask:_TaskInternalId:Text, cMarca)

									If !aAux[1]
										lRet := aAux[1]
										cXmlRet := aAux[2]
										IIf(lLog, AdpLogEAI(5, "MATI410", cXMLRet, lRet), ConOut(STR0012))
										Return {lRet, cXmlRet, "ORDER"}
									Else
										aAdd(aItemAux, {"C6_TASKPMS", aAux[2][5], Nil})
										Exit
									EndIf
								Endif
							Next nK
                  EndIf

                  // Quantidade
                  If Type("oXmlAux:_Quantity:Text") != "U" .And. !Empty(oXmlAux:_Quantity:Text)
                     aAdd(aItemAux, {"C6_QTDVEN", Val(AllTrim(oXmlAux:_Quantity:Text)), Nil})
                  EndIf

                  // Preço unitário
                  If Type("oXmlAux:_UnityPrice:Text") != "U" .And. !Empty(oXmlAux:_UnityPrice:Text)
                     aAdd(aItemAux, {"C6_PRCVEN", Val(AllTrim(oXmlAux:_UnityPrice:Text)), Nil})

                     aAdd(aItemAux, {"C6_PRUNIT", Val(AllTrim(oXmlAux:_UnityPrice:Text)), Nil})
                  EndIf

                  // Preço total
                  If Type("oXmlAux:_TotalPrice:Text") != "U" .And. !Empty(oXmlAux:_TotalPrice:Text)
                     nPrcTtl += A410Arred(Val(oXmlAux:_TotalPrice:Text),"C6_VALOR")
                     aAdd(aItemAux, {"C6_VALOR", A410Arred(Val(oXmlAux:_TotalPrice:Text),"C6_VALOR"), Nil})
                  Else
                     nPrcTtl += A410Arred(Val(oXmlAux:_Quantity:Text) * Val(oXmlAux:_UnityPrice:Text),"C6_VALOR")
                     aAdd(aItemAux, {"C6_VALOR", A410Arred(Val(oXmlAux:_Quantity:Text) * Val(oXmlAux:_UnityPrice:Text),"C6_VALOR"), Nil})
                  EndIf

                  // Valor de desconto do item
                  If Type("oXmlAux:_ItemDiscounts:Text") != "U" .And. !Empty(oXmlAux:_ItemDiscounts:_ITEMDISCOUNT:Text)
                     aAdd(aItemAux, {"C6_VALDESC", Val(oXmlAux:_ItemDiscounts:_ITEMDISCOUNT:Text), Nil})
                  EndIf

						//INICIO TRATAMENTO TES
						If Type("oXmlAux:_TypeOperation:Text") <> "U" .And. !Empty(oXmlAux:_TypeOperation:Text)

							If Len(Alltrim(oXmlAux:_TypeOperation:Text)) <= 2

								cTpOpera := PADR(oXmlAux:_TypeOperation:Text,TamSX3('FM_TIPO')[1] )
                        
								cTesPrd  := MaTesInt(2, cTpOpera, PADR(cCliente, TamSX3('FM_CLIENTE')[1] );
                                             , PADR(cLoja,TamSX3('FM_LOJACLI')[1] );
                                             , "C", PADR(cCodProd,TamSX3('FM_PRODUTO')[1] ))

								If !Empty(cTesPrd)
									aAdd(aItemAux, {"C6_TES", cTesPrd, Nil})
                           aAdd(aItemAux, {"C6_OPER", cTpOpera , Nil})
								Elseif Empty(cTesPrd) .AND. Type("oXmlAux:_TaxOpCode:Text") <> "U" .And. !Empty(oXmlAux:_TaxOpCode:Text)

									aCodcfop 	:= StrTokArr2(CFGA070Int(cMarca, "SF4", "F4_CODIGO", oXmlAux:_TaxOpCode:Text),"|",.T.)
									If !Empty(aCodcfop[3])
										aAdd(aItemAux, {"C6_TES", aCodcfop[3] , Nil})
									Else
										lRet := .F.
                              cXmlRet := STR0044 //"CFOP não relacionada a nenhuma TES no De/Para de Mensagem"
                              AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                              Return {lRet, cXmlRet, "ORDER"}
									Endif
								Else
									lRet := .F.
			                        cXmlRet := STR0045 //"Tipo de operação não possui nenhuma TES atrelada."
			                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
			                        Return {lRet, cXmlRet, "ORDER"}
								Endif
							Else

                        // Tipo de entrada e saída - TES
                           If Type("oXmlAux:_TypeOperation:Text") <> "U" .And. !Empty(oXmlAux:_TypeOperation:Text)
                              aAdd(aItemAux, {"C6_TES", oXmlAux:_TypeOperation:Text, Nil})
                           Else
                              // Se possui integração com o TOP
                              If IsIntegTop() .Or. Upper(AllTrim(cMarca)) == "HIS"
                                 // Caso a TES não tenha sido informada, assume a TES do parametro MV_SLMTS
                                 cTES := AllTrim(GetMV("MV_SLMTS"))
                                    If !Empty(cTES)
                                    aAdd(aItemAux, {"C6_TES", cTES, Nil})
                                    Else
                                       lRet := .F.
                                       cXmlRet := STR0020 //"Preencha o parâmetro MV_SLMTS no Protheus."
                                       AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                                       Return {lRet, cXmlRet, "ORDER"}
                                    EndIf
                              EndIf

                           Endif
		               Endif
		            Endif
		            //FIM - TRATAMENTO TES
                  
                  //Aposentadoria Especial REINF
                  If Type("oXmlAux:_Retirement15Years:Text") <> "U" .And. !Empty(oXmlAux:_Retirement15Years:Text) // Apos Especial 15 anos
                     n15Anos := Val(oXmlAux:_Retirement15Years:Text)
                  EndIf
                  If Type("oXmlAux:_Retirement20Years:Text") <> "U" .And. !Empty(oXmlAux:_Retirement20Years:Text) // Apos Especial 20 anos
                     n20Anos := Val(oXmlAux:_Retirement20Years:Text)
                  EndIf
                  If Type("oXmlAux:_Retirement25Years:Text") <> "U" .And. !Empty(oXmlAux:_Retirement25Years:Text) // Apos Especial 25 anos
                     n25Anos := Val(oXmlAux:_Retirement25Years:Text)
                  EndIf
                  If (n15Anos + n20Anos + n25Anos) > 0
                     aAdd(aItemAPos, {cItemSC6,n15Anos,n20Anos,n25Anos})
                  EndIf
                  If Len(aItemAPos) > 0
                     aAdd(aAposEsp, {cItemSC6, aItemAPos})
                  EndIf

						//Verifica Lote do Item
                  If Type("oXmlAux:_LotNumber:Text") != "U" .And. !Empty(oXmlAux:_LotNumber:Text)
                     cLote := oXmlAux:_LotNumber:Text
                     aAdd(aItemAux, {"C6_LOTECTL", cLote , Nil} )
                  Endif

                  //Verifica SubLote do Item
                  If Type("oXmlAux:_SubLotNumber:Text") != "U" .And. !Empty(oXmlAux:_SubLotNumber:Text)
                     cSubLote := oXmlAux:_SubLotNumber:Text
                     aAdd(aItemAux, {"C6_NUMLOTE", cSubLote , Nil} )
                  Endif

                  //Verifica Serie do Item
                  If Type("oXmlAux:_SeriesItem:Text") != "U" .And. !Empty(oXmlAux:_SeriesItem:Text)
                     cSerie := oXmlAux:_SeriesItem:Text
                     aAdd(aItemAux, {"C6_NUMSERI", cSerie , Nil} )
                  Endif

                  //Verifica Endereço do Item
                  If Type("oXmlAux:_AddressingItem:Text") != "U" .And. !Empty(oXmlAux:_AddressingItem:Text)
                     cLocaliz := oXmlAux:_AddressingItem:Text
                     aAdd(aItemAux, {"C6_LOCALIZ", cLocaliz, Nil} )
                  Endif

                  If Type("oXmlAux:_InvoicingDate:Text") != "U" .And. !Empty(oXmlAux:_InvoicingDate:Text)
                     cDatFat := oXmlAux:_InvoicingDate:Text
                     cDatFat := cTod(SubStr(cDatFat, 9, 2) + "/" + SubStr(cDatFat, 6, 2 ) + "/" + SubStr(cDatFat, 1, 4 ))
                     aAdd(aItemAux, {"C6_DATFAT", cDatFat, Nil} )
                  Endif
                  If Type("oXmlAux:_DeliveryDate:Text") != "U" .And. !Empty(oXmlAux:_DeliveryDate:Text)
                     cDataEnt := oXmlAux:_DeliveryDate:Text
                     cDataEnt := cTod(SubStr(cDataEnt, 9, 2) + "/" + SubStr(cDataEnt, 6, 2 ) + "/" + SubStr(cDataEnt, 1, 4 ))
                     aAdd(aItemAux, {"C6_ENTREG",cDataEnt, Nil} )
                  Endif
                  If Type("oXmlAux:_InvoiceNumber:Text") != "U" .And. !Empty(oXmlAux:_InvoiceNumber:Text)
                     aAdd(aItemAux, {"C6_NOTA", oXmlAux:_InvoiceNumber:Text, Nil} )
                  Endif
                  If Type("oXmlAux:_InvoiceSerie:Text") != "U" .And. !Empty(oXmlAux:_InvoiceSerie:Text)
                     aAdd(aItemAux, {"C6_SERIE", oXmlAux:_InvoiceSerie:Text, Nil} )
                  Endif                  
                  If Type("oXmlAux:_AlloccatedQuantity:Text") != "U" .And. !Empty(oXmlAux:_AlloccatedQuantity:Text)
                     aAdd(aItemAux, {"C6_QTDEMP", Val(oXmlAux:_AlloccatedQuantity:Text), Nil} )
                  Endif
                  If Type("oXmlAux:_QuantityDelivered:Text") != "U" .And. !Empty(oXmlAux:_QuantityDelivered:Text)
                     aAdd(aItemAux, {"C6_QTDENT", Val(oXmlAux:_QuantityDelivered:Text), Nil} )
                  Endif

		            //Verifica Reserva do Item
		            If Type("oXmlAux:_ItemReserveInternalId:Text") != "U" .And. !Empty(oXmlAux:_ItemReserveInternalId:Text)

							cValExtRes:= oXmlAux:_ItemReserveInternalId:Text
							aAux      := StrTokArr(CFGA070Int(cMarca, "SC0", "C0_DOCRES", cValExtRes), "|")

							If ValType(aAux) == "A" .And. Len(aAux) > 0

			               aReserva:= ReserItEai( cFilAnt,;
			                 			 			   aAux[3],;
						                 			   cCodProd,;
			    			             			   cLote,;
			    			             			   cSubLote,;
						    	            		   cLocaliz,;
			                 						   cSerie)
		                 	If len(aReserva) > 0
		                 		aadd(aReserv,{aReserva[1][1],aReserva[1][2] })
                        	aAdd(aItemAux, {"C6_RESERVA", aReserva[1][2], Nil} )
                        Else
                        	lRet := .F.
                        Endif
				         Endif

                     If !lRet
                     	cXmlRet := STR0047+Alltrim(cValExtRes)+STR0048 //"A Reserva :" " não existe no De\Para Protheus."
                     	AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                     	Return {lRet, cXmlRet, "ORDER"}

                     Endif
                  Endif
		            //Fim - Reserva

                  // Centro de custo
                  //-- Ainda que centro de custo informado no rateio, grava o centro de custo informado no item
					   If Type("oXmlAux:_CostCenterInternalID:Text") != "U" .And. !Empty(oXmlAux:_CostCenterInternalID:Text) //-- Pelo InternalID
						   // O centro de Custo existe no de/para e na base
						   cCCusto := GetCCusto(oXmlAux:_CostCenterInternalId:Text, cMarca, cCosVer, oXmlAux:_OrderItem:Text, @cXMLRet)
					   ElseIf Type("oXmlAux:_CostCenterCode:Text") != "U" .And. !Empty(oXmlAux:_CostCenterCode:Text)  //-- Pelo código
						   cCCusto := oXmlAux:_CostCenterCode:Text
					   EndIf

					    // Preencher no item o Centro de Custo obtido ou retornar a falha na obtencao do Codigo do CC via Internal ID
					   If !Empty(cXMLRet)
						   lRet := .F.
						   AdpLogEAI(5, "MATI410", cXMLRet, lRet)
						   Return {lRet, cXmlRet, "ORDER"}
					   ElseIf !Empty(cCCusto)
						   aAdd(aItemAux, {"C6_CC", cCCusto, Nil})
					   EndIf
						   
                  If Type("oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem") != "U"	//-- Tem rateio
                           
                     aAdd(aItemAux, {"C6_RATEIO", "1", Nil})

                     For nJ := 1 To Len(oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem)
                        cCCusto := ""
                        // Atualiza objeto com a posição atual
                        oXmlRat := oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem[nJ]

                        // Possui centro de custo e percentual informado
                        If Type("oXmlRat:_CostCenterInternalId:Text") != "U" .And. !Empty(oXmlRat:_CostCenterInternalId:Text)
                           // Possui percentual informado
                           If Type("oXmlRat:_Percentual:Text") != "U" .And. !Empty(oXmlRat:_Percentual:Text)
                              // O centro de Custo existe no de/para e na base
                              cCCusto := GetCCusto(oXmlRat:_CostCenterInternalId:Text, cMarca, cCosVer, oXmlAux:_OrderItem:Text, @cXMLRet)         
                              If !Empty(cXMLRet)
                                 lRet := .F.
                                 AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                                 Return {lRet, cXmlRet, "ORDER"}
                              EndIf

                              // Verifica se já existe o centro de custo para este item
                              nLin := aScan(aCCusto, {|x| x[3] == cCCusto})

                              // Caso já exista o centro de custo para o item somar o %
                              If nLin > 0
                                 aCCusto[nLin][2] += Val(oXmlRat:_Percentual:Text)
                              Else
                                 aAdd(aCCusto, {cItemSC6, Val(oXmlRat:_Percentual:Text), cCCusto})
                              EndIf
                           Else
                              lRet := .F.
                              cXmlRet := STR0023 /*"Percentual de rateio inválido para o item "*/ + cItemSC6 + "."
                              AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                              Return {lRet, cXmlRet, "ORDER"}
                           EndIf
                        EndIf
                     Next nJ

                     // Monta o array com os itens do rateio de centro de custo agrupados por centro de custo
                     aAux := {}
                     nTotPrcRat := 0

                     For nJ := 1 To Len(aCCusto)
                        aAdd(aLinha, {"AGG_FILIAL",  xFilial("AGG"),                           Nil})
                        aAdd(aLinha, {"AGG_PEDIDO",  "",                                       Nil})
                        aAdd(aLinha, {"AGG_FORNECE", cCliente,                                 Nil})
                        aAdd(aLinha, {"AGG_LOJA",    cLoja,                                    Nil})
                        aAdd(aLinha, {"AGG_ITEMPD",  aCCusto[nJ][1],                           Nil})
                        aAdd(aLinha, {"AGG_ITEM",    StrZero(nJ, TamSx3("AGG_ITEM")[1]),       Nil})
                        aAdd(aLinha, {"AGG_PERC",    aCCusto[nJ][2],                           Nil})
                        aAdd(aLinha, {"AGG_CC",      aCCusto[nJ][3],                           Nil})
                        aAdd(aLinha, {"AGG_CONTA",   "",                                       Nil})
                        aAdd(aLinha, {"AGG_ITEMCT",  "",                                       Nil})
                        aAdd(aLinha, {"AGG_CLVL",    "",                                       Nil})
                        aAdd(aAux, aLinha)
                        aLinha := {}
                        nTotPrcRat += aCCusto[nJ][2]
                     Next nJ

                     aCCusto := {}

                     // Verificar se o percentual eh diferente do que 100%
                     If nTotPrcRat <> 100
                        cXmlRet := STR0050 /*"O total do percentual de rateio é diferente de 100% para o item "*/ + cItemSC6 + "."
                        lRet := .F.                        
                        AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                        Return {lRet, cXmlRet, "ORDER"}
                     EndIf

                     aAdd(aItemRat, {cItemSC6, aAux})
                  EndIf

                  aAdd(aItens, aClone(aItemAux))
                  aItemAux := {}
               Next nI

                     //Se não for array
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument)
                        If !Adiantamento(cCond)
                           lRet    := .F.
                           cXmlRet := STR0033 //"Para utilizar título de adiantamento a condição de pagamento do pedido deve ser do tipo adiantamento."
                           AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                           Return {lRet, cXmlRet, "ORDER"}
                        EndIf

                        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument") != "A"
                           //Transforma em array
                           XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument, "_CreditDocument")
                        EndIf

                        For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument)
                           //Atualiza objeto com a posição atual
                           oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument[nI]

                           //Adiantamentos
                           If Type("oXmlAux:_CreditDocumentInternalId:Text") != "U" .And. !Empty(oXmlAux:_CreditDocumentInternalId:Text)
                              aAux := IntTRcInt(oXmlAux:_CreditDocumentInternalId:Text, cMarca, cTRcVer)

                              If !aAux[1]
                                 lRet    := aAux[1]
                                 cXmlRet := aAux[2]
                                 AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                                 Return {lRet, cXmlRet, "ORDER"}
                              EndIf
                           Else
                              lRet    := .F.
                              cXmlRet := STR0034 //"O InternalID do título de adiantamento não foi informado."
                              AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                              Return {lRet, cXmlRet,"ORDER"}
                           EndIf

                           dbSelectArea("SE1")
                           SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

                           If SE1->(dbSeek(xFilial("SE1") + PadR(aAux[2][3], TamSX3("FIE_PREFIX")[1]) + PadR(aAux[2][4], TamSX3("FIE_NUM")[1]) + PadR(aAux[2][5], TamSX3("FIE_PARCEL")[1]) + PadR(aAux[2][6], TamSX3("FIE_TIPO")[1])))
                              cCliente := SE1->E1_CLIENTE
                              cLoja    := SE1->E1_LOJA
                           Else
                              lRet    := .F.
                              cXmlRet := STR0035 + AllTrim(oXmlAux:_CreditDocumentInternalId:Text) + STR0036 //"Título de adiantamento " " não encontrado na base."
                              AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                              Return {lRet, cXmlRet,"ORDER"}
                           EndIf

                           If Type("oXmlAux:_Value:Text") == "U" .Or. Empty(oXmlAux:_Value:Text)
                              lRet    := .F.
                              cXmlRet := STR0037 //"O valor a ser abatido no título de adiantamento não foi informado."
                              AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                              Return {lRet, cXmlRet,"ORDER"}
                           EndIf

                           aAdd(aLinha, {"FIE_FILIAL", xFilial("FIE"),                            Nil})
                           aAdd(aLinha, {"FIE_CART",   "R",                                       Nil}) // Carteira receber
                           aAdd(aLinha, {"FIE_PEDIDO", "",                                        Nil})
                           aAdd(aLinha, {"FIE_PREFIX", PadR(aAux[2][3], TamSX3("FIE_PREFIX")[1]), Nil})
                           aAdd(aLinha, {"FIE_NUM",    PadR(aAux[2][4], TamSX3("FIE_NUM")[1]),    Nil})
                           aAdd(aLinha, {"FIE_PARCEL", PadR(aAux[2][5], TamSX3("FIE_PARCEL")[1]), Nil})
                           aAdd(aLinha, {"FIE_TIPO",   PadR(aAux[2][6], TamSX3("FIE_TIPO")[1]),   Nil})
                           aAdd(aLinha, {"FIE_CLIENT", PadR(cCliente,   TamSX3("FIE_CLIENT")[1]), Nil})
                           aAdd(aLinha, {"FIE_LOJA",   PadR(cLoja,      TamSX3("FIE_LOJA")[1]),   Nil})
                           aAdd(aLinha, {"FIE_VALOR",  Val(oXmlAux:_Value:Text),                  Nil}) // Valor do ra que está vinculado ao pedido

                           aAdd(aAdtPC, aClone(aLinha))
                           aLinha := {}
                        Next nI
                     EndIf

                     //Valor do Desconto
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount)
                        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount") != "A"
                           XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount, "_Discount")
                        EndIf

                        //Valor de desconto
                        nValDesc := Round(Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount[1]:Text),TamSx3("C6_VALDESC")[2])

                        nPercDesc := nValDesc / nPrcTtl 
                        nSomaDesc := 0
                        nDescIt   := 0

                        For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item)
                           // Atualiza o objeto com a posição atual
                           oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nI]

                           nDescIt := Val(oXmlAux:_UnityPrice:Text) * nPercDesc

                           nSomaDesc += nDescIt

                           // Verifica se já existe valor de desconto do item
                           nJ := aScan(aItens[nI], {|x| x[1] == "C6_VALDESC"})

                           // Caso já exista somar o valor
                           If nJ > 0
                              aItens[nI][nJ][2] += nSomaDesc
                           Else
                              aAdd(aItens[nI], {"C6_VALDESC", nSomaDesc, Nil})
                           EndIf
                           nSomaDesc := 0
                        Next nI
                     EndIf
                  EndIf

				 // ponto de entrada inserido para controlar dados especificos do cliente
				  If ExistBlock("MT410EAI")
					  	aRetPe := ExecBlock("MT410EAI",.F.,.F.,{aCab,aItens})
						If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
							aCab 	:= aClone(aRetPe[1])
							aItens := aClone(aRetPe[2])
						EndIf
			      EndIf

	             AdpLogEAI(4, nOpcx)
	             AdpLogEAI(3, "aCab: ", aCab)
	             AdpLogEAI(3, "aItens: ", aItens)
	             AdpLogEAI(3, "aItemRat: ", aItemRat)
	             AdpLogEAI(3, "aAdtPC: ", aAdtPC)
	             AdpLogEAI(3, "aDePara: ", aDePara)

                  Begin Transaction

				  //Inclusão das Reservas nos Itens, esse processo tem que ser feito dentro
				  //da transação, devido à regra usada pelo varejo.
				  If Len(aReserv) > 0 .AND. FindFunction("LJ704ESTR") .AND. lIntegSC0
				     LJ704ESTR(aReserv,nOpcx)
				  Endif

                  If nOpcx == 5
                  	 If FindFunction("LJ704LRES") .AND. lIntegSC0
                  	 	//Localiza Número do Documento responsável de uma reserva válida
                  	 	//antes da exclusão do Pedido.
                  	 	LJ704LRES(xFilial("SC5"),cNumPed,@cDocRes)
                  	 Endif
                     MSExecAuto({|x,y,z|MATA410(x,y,z)},aCab,aItens,nOpcx)
                  Else
                     If nOpcx == 3
                        lLock:= LockByName("MATI410"+cEmpAnt+cFilAnt+cValExt)
						If !lLock 
							DisarmTransaction()
						    lRet := .F.
						    cXmlRet := STR0051 //"Esse registro encontra-se bloqueado por outro usuário, tente novamente mais tarde."
						    AdpLogEAI(5, "MATI410", cXMLRet, lRet)
						    Return {lRet, cXmlRet, "ORDER"}
						EndIf
                     EndIf
                     MsExecAuto({|a,b,c,d,e,f,g| MATA410(a, b, c, d, , , , e, f, , , , , ,g)}, aCab, aItens, nOpcx, .F., aItemRat, aAdtPC, aAposEsp)
                  EndIf

                  // Se houve erros no processamento do MSExecAuto
                  If lMsErroAuto
                     aErroAuto := GetAutoGRLog()

                     cXmlRet := "<![CDATA["
                     For nI := 1 To Len(aErroAuto)
                        cXmlRet += aErroAuto[nI] + Chr(10)
                     Next nI
                     cXmlRet += "]]>"

                     lRet := .F.

                     //Desfaz a transacao
                     DisarmTransaction()
                     msUnlockAll()
                     If nOpcx == 3
                        UnLockByName("MATI410"+cEmpAnt+cFilAnt+cValExt)
                     EndIf
                  Else
					//Exclusão das reservas nos itens, esse processo tem que ser feito dentro
					//da transação, devido à regras usada pelo varejo.
					If nOpcx == 5 .AND. !Empty(cDocRes)
						If FindFunction("LJ704ESTR") .AND. lIntegSC0
							LJ704ESTR(,nOpcx,cDocRes,xFilial("SC5"),cMarca)
						Endif
					Endif

                  	If nOpcx <> 5
	                     dbSelectArea("SC6")
	                     SC6->(dbsetorder(1))

	                     SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM))
	                     While SC6->(!EOF()) .And. SC6->(C6_FILIAL + C6_NUM) == SC5->(C5_FILIAL + C5_NUM)
	                        RecLock("SC6", .F.)
	                           SC6->C6_PMSID := C6_NUM
	                        msUnlock()

	                        SC6->(dbSkip())
	                     EndDo
	                  Endif

                     If nOpcx == 3 // INSERT
                        // Obtém o valor inserido pelo inicializador padrão após a execução da rotina automática
                        cValInt := IntPdVExt(cEmpAnt, xFilial("SC5"), SC5->C5_NUM, /*cItem*/, cPdVVer)[2] // EMPRESA|FILIAL|PEDIDO
                     EndIf

                     AdpLogEAI(3, "cValInt: ", cValInt)
                     AdpLogEAI(3, "cValExt: ", cValExt)

                     If nOpcx != 5
                        // Insere ou atualiza o registro na tabela XXF (de/para)
                        CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)
                     Else
                        // Exclui o registro na tabela XXF (de/para)
                        CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T., 1)
                     EndIf

                     // Loop para manipular os Itens na tabela XXF (de/para)
                     For nI := 1 To Len(aDePara)
                        If nOpcx != 5
                           cAux := IntPdVExt(cEmpAnt, xFilial("SC6"), SC5->C5_NUM, aDePara[nI][2], cPdVVer)[2]
                           CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], cAux, .F., 1)
                        Else
                           CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], aDePara[nI][2], .T., 1)
                        EndIf
                     Next nI

                     // Monta o XML de retorno (Cabeçalho)
                     cXMLRet := "<ListOfInternalId>"
                     cXMLRet +=    "<InternalId>"
                     cXMLRet +=       "<Name>OrderInternalId</Name>"
                     cXMLRet +=       "<Origin>" + cValExt + "</Origin>"
                     cXMLRet +=       "<Destination>" + cValInt + "</Destination>"
                     cXMLRet +=    "</InternalId>"
                     For nI := 1 To Len(aDePara)
                        cXMLRet += "<InternalId>"
                        cXMLRet +=    "<Name>ItemInternalId</Name>"
                        cXMLRet +=    "<Origin>" + aDePara[nI][1] + "</Origin>"
                        If nOpcx == 3 // INSERT
                        		cXMLRet += "<Destination>" + cEmpAnt + "|" + xFilial("SC5") + "|" + SC5->C5_NUM + "|" + aDePara[nI][2] + "|2" + "</Destination>"
                        Else
                        	  	cXMLRet += "<Destination>" + aDePara[nI][2] + "</Destination>"
                        EndIf
                        cXMLRet += "</InternalId>"
                     Next nI
                     cXMLRet += "</ListOfInternalId>"
                  EndIf

                  End Transaction
                  MsUnlockAll()
                  If nOpcx == 3
                     UnLockByName("MATI410"+cEmpAnt+cFilAnt+cValExt)
                  EndIf
               ElseIf AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text) == "1"
                  aAdd(aRet, FWIntegDef("MATA120", cTypeMsg, cTypeTrans, cXML))

                  If !Empty(aRet)
                     lRet := aRet[1][1]
                     cXmlRet += aRet[1][2]
                  EndIf
               Else
                  lRet:= .F.
                  cXmlRet := STR0024 // "Tipo de Pedido inválido!"
                  AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                  Return {lRet, cXmlRet, "ORDER"}
               EndIf
            Else
               lRet := .F.
               cXmlRet := STR0025 // "Tipo de pedido não enviado."
               AdpLogEAI(5, "MATI410", cXMLRet, lRet)
               Return {lRet, cXmlRet, "ORDER"}
            EndIf
         Else
            lRet := .F.
            cXMLRet := STR0026 // "Erro no parser!"
            AdpLogEAI(5, "MATI410", cXMLRet, lRet)
            Return {lRet, cXmlRet, "ORDER"}
         EndIf
      ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
         //Faz o parser do XML de retorno em um objeto
         oXml := xmlParser(cXML, "_", @cError, @cWarning)

         //Se não houve erros na resposta
         If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
            //Verifica se a marca foi informada
            If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
               cMarca := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
            Else
               lRet := .F.
               cXmlRet := STR0027 // "Erro no retorno. O Product é obrigatório!"
               AdpLogEAI(5, "MATI410", cXMLRet, lRet)
               Return {lRet, EncodeUTF8(cXmlRet)}
            EndIf

            //Se não for array
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "A"
               //Transforma em array
               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
            EndIf

            For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)
            	 cNameInternalId := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Name:Text
               aAdd(aDePara, Array(4))

               //Verifica se o InternalId foi informado
               If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text)
                  //Não armazena Rateio
                  If 'ORDERINTERNALID' == AllTrim(Upper(cNameInternalId)) .Or. 'ITEMINTERNALID' == AllTrim(Upper(cNameInternalId))
                     aDePara[nI][3] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text
                  EndIf
               Else
                  lRet    := .F.
                  cXmlRet := STR0028 // "Erro no retorno. O OriginalInternalId é obrigatório!"
                  AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                  Return {lRet, EncodeUTF8(cXmlRet)}
               EndIf

               //Verifica se o código externo foi informado
               If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text)
                  //Não armazena Rateio
                  If 'ORDERINTERNALID' == AllTrim(Upper(cNameInternalId)) .Or. 'ITEMINTERNALID' == AllTrim(Upper(cNameInternalId))
                     aDePara[nI][4] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text
                  EndIf
               Else
                  lRet    := .F.
                  cXmlRet := STR0029 // "Erro no retorno. O DestinationInternalId é obrigatório!"
                  AdpLogEAI(5, "MATI410", cXMLRet, lRet)
                  Return {lRet, EncodeUTF8(cXmlRet)}
               EndIf

               //Envia os valores de InternalId e ExternalId para o Log
               AdpLogEAI(3, "cValInt" + Str(nI) + ": ", aDePara[nI][2]) // InternalId
               AdpLogEAI(3, "cValExt" + Str(nI) + ": ", aDePara[nI][3]) // ExternalId

               If 'ORDERINTERNALID' == AllTrim(Upper(cNameInternalId))
                  aDePara[nI][1] := "SC5"
                  aDePara[nI][2] := cField
               ElseIf 'ITEMINTERNALID' == AllTrim(Upper(cNameInternalId))
                  aDePara[nI][1] := "SC6"
                  aDePara[nI][2] := "C6_ITEM"
               EndIf
            Next nI

            //Obtém a mensagem original enviada
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
               cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
            Else
               lRet := .F.
               cXmlRet := STR0030 // "Conteúdo do MessageContent vazio!"
               AdpLogEAI(5, "MATI410", cXMLRet, lRet)
               Return {lRet, EncodeUTF8(cXmlRet)}
            EndIf

            //Faz o parse do XML em um objeto
            oXML := XmlParser(cXML, "_", @cError, @cWarning)

            If Empty(oXML) .And. "UTF-8" $ Upper(cXML)
               oXML := xmlParser(EncodeUTF8(cXML), "_", @cError, @cWarning)
            EndIf

            //Se não houve erros no parse
            If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
               //Loop para manipular os InternalId no de/para
               For nI := 1 To Len(aDePara)
                  If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
                     CFGA070Mnt(cMarca, aDePara[nI][1], aDePara[nI][2], aDePara[nI][4], aDePara[nI][3], .F., 1)
                  ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
                     CFGA070Mnt(cMarca, aDePara[nI][1], aDePara[nI][2], aDePara[nI][4], aDePara[nI][3], .T., 1)
                  Else
                     lRet := .F.
                     cXmlRet := STR0031 // "Evento do retorno inválido!"
                  EndIf
               Next nI
            Else
               lRet := .F.
               cXmlRet := STR0032 // "Erro no parser do retorno!"
               AdpLogEAI(5, "MATI410", cXMLRet, lRet)
               Return {lRet, EncodeUTF8(cXmlRet)}
            EndIf
         Else
            //Se não for array
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
               //Transforma em array
               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            EndIf

            //Percorre o array para obter os erros gerados
            For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
               cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + Chr(10)
            Next nI

            lRet := .F.
            cXmlRet := cError
         EndIf
      ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
         cXMLRet := "1.000|3.000|3.001|3.002|3.004|3.005|4.003"
      EndIf
      // Mensagem de Saída
   ElseIf cTypeTrans == TRANS_SEND
      //Verica operação realizada e insere no LOG
      Do Case
         Case Inclui
            AdpLogEAI(4, 3)
         Case Altera
            AdpLogEAI(4, 4)
         OtherWise
            AdpLogEAI(4, 5)
            cEvent := "delete"
      EndCase

      SC5->(dbSeek(xFilial("SC5") + SC5->C5_NUM))

      cXMLRet := '<BusinessEvent>'
      cXMLRet +=    '<Entity>Order</Entity>'
      cXMLRet +=    '<Event>' + cEvent + '</Event>'
      cXMLRet +=    '<Identification>'
      cXMLRet +=       '<key name="InternalId">' + IntPdVExt(cEmpAnt, xFilial("SC5"), SC5->C5_NUM, Nil, cPdVVer)[2] + '</key>'
      cXMLRet +=    '</Identification>'
      cXMLRet += '</BusinessEvent>'
      cXMLRet += '<BusinessContent>'
      cXMLRet +=    '<InternalId>' + IntPdVExt(cEmpAnt, xFilial("SC5"), SC5->C5_NUM, Nil, cPdVVer)[2] + '</InternalId>'
      cXmlRet +=    '<OrderPurpose>2</OrderPurpose>' // 2 - pedido de venda
      cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
      cXMLRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
      cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '</CompanyInternalId>'
      cXMLRet +=    '<OrderId>' + RTrim(SC5->C5_NUM) + '</OrderId>'

      If Inclui .Or. Altera
         cXmlRet += '<CustomerInternalId>' + IntCliExt(/*Empresa*/, /*Filial*/, SC5->C5_CLIENTE, SC5->C5_LOJACLI, cCusVer)[2] + '</CustomerInternalId>'
         cXmlRet += '<CustomerCode>' + RTrim(SC5->C5_CLIENTE) + RTrim(SC5->C5_LOJACLI) + '</CustomerCode>'
         cXMLRet += '<CurrencyCode>' + PadR(RTrim(cValToChar(SC5->C5_MOEDA)), TamSx3('C5_MOEDA')[1] ) + '</CurrencyCode>'
         cXMLRet += '<CurrencyId>' + IntMoeExt(/*cEmpresa*/, /*Filial*/, PadR(RTrim(cValToChar(SC5->C5_MOEDA)), TamSx3('C5_MOEDA')[1] ), cMoeVer)[2] + '</CurrencyId>'
         cXMLRet += '<PaymentTermCode>' + RTrim(SC5->C5_CONDPAG) + '</PaymentTermCode>'
         cXmlRet += '<PaymentConditionInternalId >' + IntConExt(/*Empresa*/, /*Filial*/, SC5->C5_CONDPAG, cConVer)[2] + '</PaymentConditionInternalId >'
         cXMLRet += '<RegisterDate>' + Transform(DtoS( SC5->C5_EMISSAO),'@R 9999-99-99') + '</RegisterDate>'
         cXmlRet += '<FreightType>' + getTpFre(SC5->C5_TPFRETE, cTypeTrans) + '</FreightType>'
         cXmlRet += '<FreightValue>' + RTrim(cValToChar(SC5->C5_FRETE)) + '</FreightValue>'
         cXmlRet += '<GrossWeight>' + RTrim(cValToChar(SC5->C5_PBRUTO))  + '</GrossWeight>'
         cXmlRet += '<InsuranceValue>' + RTrim(cValToChar(SC5->C5_SEGURO)) + '</InsuranceValue>'
         cXmlRet += '<Discounts>'
         cXmlRet +=    '<Discount>' + RTrim(cValToChar(SC5->C5_DESC1)) + '</Discount>'
         cXmlRet +=    '<Discount>' + RTrim(cValToChar(SC5->C5_DESC2)) + '</Discount>'
         cXmlRet +=    '<Discount>' + RTrim(cValToChar(SC5->C5_DESC3)) + '</Discount>'
         cXmlRet +=    '<Discount>' + RTrim(cValToChar(SC5->C5_DESC4)) + '</Discount>'
         cXmlRet += '</Discounts>'

   		cXmlRet +=  '<InvoiceMessages>'
    		cXmlRet +=      '<InvoiceMessage>' +ALLTRIM(SC5->C5_MENNOTA)+ '</InvoiceMessage>'
       	cXmlRet +=  '</InvoiceMessages>'
         cXmlRet += '<InvoiceNumber>' + RTrim(SC5->C5_NOTA) + '</InvoiceNumber>'
         cXmlRet += '<InvoiceSerie>' + RTrim(SC5->C5_SERIE) + '</InvoiceSerie>'
         
         If lWorkCode
	         //Codigo da Obra - Utilizamos o codigo da obra externo.
	         If !Empty( SC5->C5_CNO )
	            SON->(DbSetOrder(1))
	            If SON->( MsSeek( xFilial("SON") + SC5->C5_CNO ) )
	                cSONCodExt := SON->ON_CNO
	            EndIf
	         EndIf

	         cXmlRet += '<WorkCode>' + cSONCodExt + '</WorkCode>'
         EndIf

         cXMLRet += '<SalesOrderItens>'

         // Itens Pedido de Venda
         SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

         If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
            While SC6->(!EOF()) .And. SC6->C6_FILIAL + SC6->C6_NUM == SC5->C5_FILIAL + SC5->C5_NUM
               cXmlRet += '<Item>'
               cXmlRet +=    '<InternalId>' + IntPdVExt(cEmpAnt, xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, cPdVVer)[2] + '</InternalId>'
               cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
               cXmlRet +=    '<BranchId>' + RTrim(cFilAnt) + '</BranchId>'
               cXmlRet +=    '<OrderId>' + RTrim(SC6->C6_NUM) + '</OrderId>'
               cXMLRet +=    '<OrderItem>' + RTrim(SC6->C6_ITEM) + '</OrderItem>'
               cXMLRet +=    '<ItemCode>' + RTrim(SC6->C6_PRODUTO) + '</ItemCode>'
               cXmlRet +=    '<ItemDescription>' + RTrim(SC6->C6_DESCRI) + '</ItemDescription>'
               cXmlRet +=    '<ItemInternalId>' + IntProExt(/*cEmpresa*/, /*cFilial*/, SC6->C6_PRODUTO)[2] + '</ItemInternalId>'
               cXmlRet +=    '<itemunitofmeasure>' + RTrim(SC6->C6_UM) + '</itemunitofmeasure>'
               cXmlRet +=    '<UnitOfMeasureInternalId>' + IntUndExt(/*Empresa*/, /*Filial*/, SC6->C6_UM, cUndVer)[2] + '</UnitOfMeasureInternalId>'
               cXmlRet +=    '<Quantity>' + cValToChar(SC6->C6_QTDVEN) + '</Quantity>'
               cXmlRet +=    '<QuantityReached/>'
               cXmlRet +=    '<UnityPrice>' + cValToChar(SC6->C6_PRCVEN) + '</UnityPrice>'
               cXmlRet +=    '<TotalPrice>' + cValToChar(SC6->C6_VALOR) + '</TotalPrice>'
               cXmlRet +=    '<CostCenterCode>' + cValToChar(SC6->C6_CC) + '</CostCenterCode>'
               cXmlRet +=    '<CostCenterInternalId>' + IntCusExt(/*cEmpresa*/, /*cFilial*/, SC6->C6_CC, cCosVer)[2] +'</CostCenterInternalId>'
               cXmlRet +=    '<ItemDiscounts>'
               cXmlRet +=       '<ItemDiscount>' + cValToChar(SC6->C6_VALDESC) + '</ItemDiscount>'
               cXmlRet +=    '</ItemDiscounts>'
               cXmlRet +=    '<WarehouseInternalId>' + IntLocExt(/*Empresa*/, /*Filial*/, SC6->C6_LOCAL)[2] + '</WarehouseInternalId>'
               cXmlRet +=    '<TypeOperation>' + RTrim(SC6->C6_TES) + '</TypeOperation>'
               cXMLRet +=    '<InvoicingDate>' + Transform(DtoS( SC6->C6_DATFAT ),'@R 9999-99-99') + '</InvoicingDate>'
               cXMLRet +=    '<DeliveryDate>'  + Transform(DtoS( SC6->C6_ENTREG ),'@R 9999-99-99') + '</DeliveryDate>'
               cXmlRet +=    '<InvoiceNumber>' + RTrim(SC6->C6_NOTA) + '</InvoiceNumber>'
               cXmlRet +=    '<InvoiceSerie>' + RTrim(SC6->C6_SERIE) + '</InvoiceSerie>'
               cXmlRet +=    '<AlloccatedQuantity>' + cValToChar(SC6->C6_QTDEMP) + '</AlloccatedQuantity>'
               cXmlRet +=    '<QuantityDelivered>' + cValToChar(SC6->C6_QTDENT) + '</QuantityDelivered>'
               
               cXmlRet +=    '<RequestItemInternalId/>'

               // Integração com o TOTVS Obras e Projetos
               If IsIntegTop()
                 aRateio := RatPV(SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_CLI + SC6->C6_LOJA + SC6->C6_ITEM)

                 IIf(!Empty(aRateio), cXMLRet += '<ListOfApportionOrderItem>', '')

                 For nI := 1 To Len(aRateio)
                    cXmlRet += '<ApportionOrderItem>'
                    cXmlRet +=    '<InternalId>' + IntPdVExt(cEmpAnt, xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, cPdVVer)[2] + RTrim(cValToChar(nI)) + '</InternalId>'
                    cXMLRet +=    '<DepartamentCode/>'
                    cXMLRet +=    '<DepartamentInternalId/>'
                    cXmlRet +=    '<CostCenterInternalId>' + IIf(!Empty(aRateio[nI][1]), IntCusExt(/*cEmpresa*/, /*cFilial*/, aRateio[nI][1], cCosVer)[2], '') + '</CostCenterInternalId>'
                    cXmlRet +=    '<AccountantAcountInternalId>' + IIf(!Empty(aRateio[nI][2]), cEmpAnt + "|" + xFilial("CT1") + "|" + AllTrim(aRateio[nI][2]), '') + '</AccountantAcountInternalId>' //CTBI020
                    cXMLRet +=    '<ProjectInternalId>' + IIf(!Empty(aRateio[nI][6]), IntPrjExt(/*cEmpresa*/, /*cFilial*/, aRateio[nI][6])[2], '') + '</ProjectInternalId>'
                    cXMLRet +=    '<SubProjectInternalId/>'
                    cXMLRet +=    '<TaskInternalId>' + IIf(!Empty(AllTrim(aRateio[nI][7])), IntTrfExt(/*cEmpresa*/, /*cFilial*/, aRateio[nI][6], '0001', aRateio[nI][7])[2], '') + '</TaskInternalId>'
                    cXMLRet +=    IIf(Empty(aRateio[nI][5]) .Or. aRateio[nI][5] == 0, '<Value/>', '<Value>' + cValToChar(aRateio[nI][5] * SC6->C6_PRCVEN * SC6->C6_QTDVEN / 100) + '</Value>')
                    cXMLRet +=    '<Percentual>' + cValToChar(aRateio[nI][5]) + '</Percentual>'
                    cXMLRet +=    '<Quantity>' + cValToChar(aRateio[nI][8]) + '</Quantity>'
                    cXMLRet +=    '<Observation/>'
                    cXmlRet += '</ApportionOrderItem>'
                 Next nI

                 IIf(!Empty(aRateio), cXMLRet += '</ListOfApportionOrderItem>', '<ListOfApportionOrderItem/>')
               Else
                  // Rateio por Centro de Custo
                  If SC6->C6_RATEIO == '1'
                     AGG->(DbSetOrder(1)) // AGG_FILIAL+AGG_PEDIDO+AGG_FORNEC+AGG_LOJA+AGG_ITEMPD+AGG_ITEM

                     If AGG->(DbSeek(xFilial('SC6') + SC6->C6_NUM + SC6->C6_CLI + SC6->C6_LOJA + SC6->C6_ITEM))
                        cXmlRet += '<ListOfApportionOrderItem>'

                        While AGG->(!EOF() .And. AGG->AGG_FILIAL + AGG->AGG_PEDIDO + AGG->AGG_FORNEC + AGG->AGG_LOJA + AGG->AGG_ITEMPD == xFilial('SC6') + SC6->C6_NUM + SC6->C6_CLI + SC6->C6_LOJA + SC6->C6_ITEM)
                           cXmlRet += '<ApportionOrderItem>'
                           cXMLRet +=    '<InternalId>' + IntPdVExt(cEmpAnt, xFilial('AGG'), AGG->AGG_PEDIDO, AGG->AGG_ITEMPD, cPdVVer)[2] + '|' + RTrim(AGG->AGG_ITEM) + '</InternalId>'
                           cXmlRet +=    '<CostCenterInternalId>' + IIf(!Empty(AllTrim(AGG->AGG_CC)), IntCusExt(/*cEmpresa*/, /*cFilial*/, AGG->AGG_CC, cCosVer)[2], '') + '</CostCenterInternalId>'
                           cXMLRet +=    '<AccountantAcountInternalId>' + IIf(!Empty(AGG->AGG_CONTA), cEmpAnt + "|" + xFilial("CT1") + "|" + AllTrim(AGG->AGG_CONTA), '') + '</AccountantAcountInternalId>' //CTBI020
                           cXMLRet +=    '<Percentual>' + cValToChar(AGG->AGG_PERC) + '</Percentual>'
                           cXmlRet += '</ApportionOrderItem>'
                           AGG->(DbSkip())
                        EndDo

                        cXmlRet += '</ListOfApportionOrderItem>'
                     EndIf
                  EndIf
               EndIf

               cXmlRet+= '</Item>'
               SC6->(dbSkip())
            EndDo

            SC6->(dbCloseArea())
         EndIf

         cXmlRet +=    '</SalesOrderItens>'
      EndIf

      cXmlRet += '</BusinessContent>'
   EndIf

   AdpLogEAI(5, "MATI410", cXMLRet, lRet)
Return  {lRet, cXmlRet, "ORDER"}

// --------------------------------------------------------------------------------------
/*/{Protheus.doc} getTpFre
Faz o de/para do Tipo de Frete

@param   cTipo      Tipo do frete
@param   cTypeTrans Tipo da transação

@author  Leandro Luiz da Cruz
@version P11
@since   06/06/2013
@return  cResult Variavel com o valor obtido
/*/
// --------------------------------------------------------------------------------------
Static Function getTpFre(cTipo, cTypeTrans)
   Local cResult := ""

   If cTypeTrans == TRANS_RECEIVE
      Do Case
         Case cTipo == "1"
            cResult := "CIF"
         Case cTipo == "2"
            cResult := "FOB"
         Case cTipo == "3"
            cResult := "SFT"
      EndCase
   ElseIf cTypeTrans == TRANS_SEND
      Do Case
         Case cTipo == "CIF"
            cResult := "1"
         Case cTipo == "FOB"
            cResult := "2"
         Case cTipo == "STF"
            cResult := "3"
      EndCase
   EndIf
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} RatPV
Recebe a chave de busca do Pedido de Venda e monta o rateio.

@author  Leandro Luiz da Cruz
@version P11
@since   13/06/2013

@return aResult
/*/
//-------------------------------------------------------------------
Static Function RatPV(cChave)
   Local aResult  := {}
   Local aPrjtTrf := {}
   Local aCntrCst := {}
   Local nI       := 0

   AGG->(DbSetOrder(1)) // Rateio por Centro de Custo - AGG_FILIAL+AGG_PEDIDO+AGG_FORNEC+AGG_LOJA+AGG_ITEMPD+AGG_ITEM

   //Povoa o array de Centro de Custo
   If Upper(SC6->C6_RATEIO) == '1' //Possui rateio por Centro de Custo
      If AGG->(dbSeek(cChave))
         While AGG->(!EOF()) .And. AGG->AGG_FILIAL + AGG->AGG_PEDIDO + AGG->AGG_FORNEC + AGG->AGG_LOJA + AGG->AGG_ITEMPD == cChave
            aAdd(aCntrCst, Array(5))
            nI++
            aCntrCst[nI][1] := AGG->AGG_CC
            aCntrCst[nI][2] := AGG->AGG_CONTA
            aCntrCst[nI][3] := AGG->AGG_ITEMCT
            aCntrCst[nI][4] := AGG->AGG_CLVL
            aCntrCst[nI][5] := AGG->AGG_PERC
            AGG->(dbSkip())
         EndDo
      EndIf
   EndIf

   // Não há Rateio por Projeto/Tarefa no Pedido de Venda.
   // Aqui estão sendo passados os dados de Projeto/Tarefa do item
   aAdd(aPrjtTrf, {SC6->C6_PROJPMS, Nil, SC6->C6_TASKPMS, SC6->C6_QTDVEN})

   aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntPdVExt
Monta o InternalID do Pedido de Venda ou dos itens de acordo
com os parâmetros passados

@param   cEmpresa Código da empresa (Default cEmpAnt)
@param   cFil     Código da Filial (Default xFilial(SC1))
@param   cNum     Número do Pedido de Venda
@param   cItem    Item do Pedido de Venda
@param   cVersao  Versão da mensagem única (Default 3.002)

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   12/12/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntPdVExt(,,'0001','01') irá retornar {.T.,'01|01|00001|001|2'}
/*/
//-------------------------------------------------------------------
Function IntPdVExt(cEmpresa, cFil, cNum, cItem, cVersao)
   Local   aResult  := {}
   Local   cTemp    := ""
   Default cEmpresa := cEmpAnt
   Default cFil     := FWxFilial('SC5')
   Default cVersao  := '3.002'

   If cVersao = "1."
      cTemp := cFil + cNum
      aAdd(aResult, .T.)
      aAdd(aResult, cTemp)
   ElseIf cVersao = "3." .OR. cVersao = "4."
      If Empty(cItem)
         // Montagem do InternalId de cabeçalho (SC5)
         cTemp := cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cNum) + "|2"
      Else
         // Montagem do InternalId do item (SC6)
         cFil  := xFilial('SC6')
         cTemp := cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cNum) + "|" + RTrim(cItem) + "|2"
      EndIf
      aAdd(aResult, .T.)
      aAdd(aResult, cTemp)
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0038 + Chr(10) + STR0039 + "1.~, 3.~, 4.~") //"Versão do Pedido de Venda não suportada." "As versões suportadas são: "
   EndIf
Return aResult

//--------------------------------------------------------------------
/*/{Protheus.doc} IntPdVInt
Recebe um InternalID e retorna o código do Pedido de Venda.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 3.002)

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   12/12/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,
         filial, o número do pedido e o item do pedido caso seja o
         InternalID do item.

@sample  IntPdVInt('01|01|001') irá retornar {.T., {'01', '01', '001'}}
/*/
//--------------------------------------------------------------------
Function IntPdVInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   aTemp    := {}
   Local   cTemp    := ''
   Local   cAlias   := 'SC5'
   Local   cField   := 'C5_NUM'
   Default cVersao  := '3.002'

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

   If Empty(cTemp)
      cTemp := CFGA070Int(cRefer, "SC6", "C6_ITEM", cInternalID)
   EndIf

   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, STR0040 + AllTrim(cInternalID) + STR0041) //"Pedido de Venda " " não encontrado no de/para"
   Else
      If cVersao = "1."
         aAdd(aResult, .T.)
         aAdd(aTemp, SubStr(cTemp, 1, TamSX3('C5_FILIAL')[1]))
         aAdd(aTemp, SubStr(cTemp, 1 + TamSX3('C5_FILIAL')[1], TamSX3('C5_NUM')[1]))
         aAdd(aResult, aTemp)
      ElseIf cVersao = "3." .OR. cVersao = "4."
         aAdd(aResult, .T.)
         aTemp := Separa(cTemp, '|')
         aAdd(aResult, aTemp)
      Else
         aAdd(aResult, .F.)
         aAdd(aResult, STR0038 + Chr(10) + STR0039 + "1.000, 3.000, 3.001, 3.002, 3.004, 3.005 e 4.003") //"Versão do Pedido de Venda não suportada." "As versões suportadas são: "
      EndIf
   EndIf
Return aResult

//--------------------------------------------------------------------
/*/{Protheus.doc} Adiantamento
Recebe uma condição de pagamento e retorna se ela é do tipo adiantamento.

@param   cCond Código da condição de pagamento.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   10/12/2013
@return  cResult Valor lógico indicando se a condição de pagamento é do
          tipo adiantamento.
/*/
//--------------------------------------------------------------------
Static Function Adiantamento(cCond)
Local cResult    := .F.
Local cE4_CTRADT := ""

cE4_CTRADT := Posicione("SE4", 1, xFilial("SE4") + PadR(cCond, GetSX3Cache("E4_CODIGO","X3_TAMANHO")), "E4_CTRADT")

If cE4_CTRADT == "1"
	cResult := .T.
EndIf
Return cResult

//--------------------------------------------------------------------
/*/{Protheus.doc} GetCurrId
Get Currency ID - Utilizado para identificar se o id da moeda já existe,
antes de acrescentar '0'.

@param   cAux   , Char, Código da Moeda
@param   cMarca , Char, Marca da integração
@param   cMoeVer, Char, Versão do Adapter Currency

@author  Squad CRM/Faturamento
@version P12
@since   19/06/2018
@return  IntMoeInt() função que retorna os dados da moeda.
/*/
//--------------------------------------------------------------------
Static Function GetCurrId(cAux, cMarca, cMoeVer)
If Empty( CFGA070Int( cMarca, 'CTO', 'CTO_MOEDA', cAux) )
	cAux := SubStr(cAux,1,Len(cAux)-2) + PadL(cAux, 2, "0")
EndIf
Return IntMoeInt(cAux, cMarca, cMoeVer)



//--------------------------------------------------------------------
/*/{Protheus.doc} GetCCusto
Funcao para obter o codigo do centro de Custo por meio do Internal ID
do Código do Centro de Custo. Esta funcao também valida o Centro de Custo
Encontrado

@param   cCCInterID   , Char, Internal ID do Centro de Custo
@param   cMarca       , Char, Marca da integração
@param   cCosVer      , Char, Versão do Adapter Centro de Custo
@param   cItem        , Char, Item do pedido de venda
@param   cMensagem    , Char, Mensagem a ser retornada caso nao seja 
                              possivel obter o Codigo do Centro de 
                              Custo ou se o Codigo do Centro de Custo
                              obtido nao eh valido

@author  Squad CRM/Faturamento
@version P12
@since   08/07/2020
@return  cCusto Codigo do Centro de Custo
/*/
//--------------------------------------------------------------------
Static Function GetCCusto(cCCInterID, cMarca, cCosVer, cItem, cMensagem)
   Local aAux      := {}
   Local cCusto    := ""
   Local lCCAchou  := .F.

   Default cCCInterID := ""
   Default cMarca     := ""
   Default cCosVer    := ""
   Default cItem      := ""
   Default cMensagem  := ""

   // O centro de Custo existe no de/para e na base
   aAux := IntCusInt(cCCInterID, cMarca, cCosVer)
   lCCAchou := aAux[1]
   
   If lCCAchou
      cCusto := aAux[2][3]
      // Valida o Centro de Custo obtido
      If !IntVldCC(cCusto, Date(), "MATI410")[1]
         cMensagem := STR0042 + STR0022 + AllTrim(cItem) + "."   //#"Centro de custo é inválido ou é sintético." #" Item "
      EndIf
   Else
      cMensagem := aAux[2] + STR0022 + AllTrim(cItem) + "." //#" Item "
   EndIf

   FreeObj(aAux)
Return cCusto
