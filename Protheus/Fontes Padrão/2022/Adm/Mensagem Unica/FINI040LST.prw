#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FINI040LST.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINI040LST
Adapter de Inclusão de títulos - Projeto VTEX EAI Mensagem única

@type   function
@param  oEaiObjEnt, FwEaiObj, Conteúdo para envio ou recebimento
@param  cType, Caractere, Tipo de transacao (TRANS_RECEIVE, TRANS_SEND)
@param  cTypeMessage, Caractere, Tipo de mensagem (EAI_MESSAGE_BUSINESS, EAI_MESSAGE_RESPONSE, EAI_MESSAGE_RECEIPT, EAI_MESSAGE_WHOIS)
@return Array, Com 3 posições com o resultado da integração {Lógico, FwEaiObj, Caractere}

@author DS2U [L. Fini]
@since  09/06/2021
/*/
//-------------------------------------------------------------------    
Function FINI040LST(oEaiObjEnt, cType, cTypeMessage, lEaiObj)

    Local cVersao   := ""
    Local aRet		:= {.T., ""} 		//Array de retorno da execucao

    If cType == TRANS_RECEIVE

        Do Case

            Case cTypeMessage == EAI_MESSAGE_WHOIS

                aRet[1] := .T.
                aRet[2] := "1.000"

            Case cTypeMessage == EAI_MESSAGE_BUSINESS

                If !lEaiObj

                    aRet[1] := .F.
                    aRet[2] := I18n(STR0026, {"FwEaiObj"})      //"Este adapter só trabalha com o padrão #1!"

                ElseIf !Empty( oEaiObjEnt:getHeaderValue("Version") )

                    cVersao := StrTokArr( oEaiObjEnt:getHeaderValue("Version"), ".")[1]

                    If cVersao == "1"

                        aRet := v1000(oEaiObjEnt, cType, cTypeMessage)
                    Else

                        aRet[1] := .F.
                        aRet[2] := STR0001          //"A versao da mensagem informada nao foi implementada!"
                    EndIf
                    
                Else

                    aRet[1] := .F.
                    aRet[2] := STR0002              //"Versao da mensagem nao informada!"
                EndIf

            OTherWise

                aRet[1] := .F.
                aRet[2] := STR0027 + cTypeMessage   //"Tipo de mensagem não implementado: "

        End Case

    Else

        aRet[1] := .F.
        aRet[2] := I18n(STR0007, {"TRANS_SEND"})    //"#1 - Não implementado!"
    EndIf

Return {aRet[1], aRet[2], "LISTOFACCOUNTRECEIVABLEDOCUMENT"}

//-------------------------------------------------------------------
/*/{Protheus.doc} v1000
Processamento da mensagem unica LISTOFACCOUNTRECEIVABLEDOCUMENT versão 1.000

@type   function
@param  oEaiObjEnt, FwEaiObj, Conteúdo para envio ou recebimento
@param  cType, Caractere, Tipo de transacao (TRANS_RECEIVE, TRANS_SEND)
@param  cTypeMessage, Caractere, Tipo de mensagem (EAI_MESSAGE_BUSINESS, EAI_MESSAGE_RESPONSE, EAI_MESSAGE_RECEIPT, EAI_MESSAGE_WHOIS)
@return Array, Com 2 posições com o resultado da integração {Lógico, FwEaiObj}

@author DS2U [L. Fini]
@since  09/06/2021
/*/
//-------------------------------------------------------------------
Static Function v1000(oEaiObjEnt, cType, cTypeMessage)

	Local cMsgRet		:= ""
	Local cMsgErro		:= ""
	Local aErroAuto		:= {}
	Local aRetTit		:= {}
	Local lRet			:= .T.
	Local oEaiObjSai    := FwEaiObj():New()	                //Objeto EAI
	Local nX 			:= 1
	Local nY			:= 1
	Local nZ			:= 1
	Local nC 			:= 1
	Local aTitulos		:= {}
	Local aTitulosTx	:= {}
	Local aTitVld		:= {}
	Local aTitSE1		:= {}
	Local aTitSE2		:= {}
	Local aTitBkp		:= {}
	Local aVtexF78		:= {}                               //Guarda os títulos provenientes da VTEX para serem gravados na tabela F78
	Local aVtexTit		:= {}
	Local aVtexBkp		:= {}
	Local aBaixa		:= {}
	Local aBaixas		:= {}
	Local cMarca		:= ""
	Local lAglutTit		:= .F.                              //Aglutina títulos da operadora quando pagamento for crédito parcelado? (SAE->E1_AGLPARC = 1 -> Aglutina, 2 -> Não aglutina)
	Local lGeraTaxa 	:= SuperGetMV("MV_LJGERTX",,.F.)    //Verifica se ira gerar um Contas a Pagar quando existir taxa na admistradora do cartao.
	Local oTitulos		:= nil
	Local oPgtos		:= nil
	Local cCodCli		:= ""                               //CustomerCode ou CustomerVendorInternalId
	Local cLojaCli		:= ""                               //CustomerStore
	Local nVlrTotal		:= 0                                //TotalPrice
	Local cCodFinan		:= ""                               //FinancialManagerCode
	Local cPrefix		:= ""                               //Prefix
	Local cNumTit		:= ""                               //DocumentCode
	Local cNaturez		:= ""                               //FinanceNature
    Local dDtEmissao    := CtoD("")                         //IssueDate
	Local dDataVenc		:= CtoD("")                         //RealDate
	Local dDtVencReal	:= CtoD("")                         //RealDate
	Local nDesconto		:= 0                                //DiscountPercentage
	Local nMoeda		:= 1
	Local cEcomOrder	:= ""
	Local cParcelas		:= ""
	Local nValorParc	:= 0
	Local cNSUTef		:= ""                               //UniqueSerialNumber - TEF
	Local nTaxaOper		:= 0                                //Taxa da operadora --> SAE
    Local cParcIni      := SuperGetMv("MV_1DUP",,"1")
	Local cParcela		:= ""
	Local cCodFor		:= ""
	Local cFilVld		:= ""
	Local cPrefVld		:= ""
	Local cNumVld		:= ""
	Local cParcVld		:= ""
	Local cTipoVld		:= ""
	Local nPos			:= 0

	Private nOpcx		:= 1                                //1=Inclusão - 2=Alteração - 3=Exclusão
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile:= .T.

	If ValType(oEaiObjEnt) <> "O"

        lRet    := .F.
        cMsgRet := STR0028      //"Mensagem recebida inválida!"

    Else

        //Efetua a validação do Objeto
        aRet := validObj(oEaiObjEnt)

        if aRet[1] //Se estrutura do obj está válida.

            aTitulos 	:= {}
            aTitulosTx	:= {}
            aBaixas		:= {}
            aTitVld		:= {}
            aVtexF78	:= {}
            cMarca 		:= Alltrim(oEaiObjEnt:getHeaderValue("ProductName"))

            oTitulos := oEaiObjEnt:getPropValue("Documents") //Lista de títulos a serem processados.

            DbSelectArea("SAE")
            SAE->(DbSetOrder(1)) //AE_FILIAL + AE_COD

            for nX := 1 to Len(oTitulos)

                aTitSE1 	:= {}
                aBaixa		:= {}
                aVtexTit	:= {}
                dDtEmissao	:= dDataBase                            //IssueDate
                dDataVenc	:= dDataBase                            //RealDate
                dDtVencReal	:= dataValida(dDataBase)                //RealDate
                cCodCli		:= ""                                   //CustomerCode ou CustomerVendorInternalId
                cLojaCli	:= ""                                   //CustomerStore
                cPrefix		:= PadR("", TamSx3("E1_PREFIXO")[1])    //Prefix
                cNumTit		:= ""                                   //DocumentCode
                nMoeda		:= 1
                cNaturez	:= ""                                   //FinanceNature
                cEcomOrder	:= ""                                   //ECommerceOrder

                //Inicializo variáveis do título.
                aAdd(aTitSE1, {"E1_FILIAL", fwxFilial('SE1'),Nil})

                if oTitulos[nX]:getPropValue("Prefix") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("Prefix"))
                    cPrefix := oTitulos[nX]:getPropValue("Prefix")
                endif
                aAdd(aTitSE1, {"E1_PREFIXO", cPrefix, Nil})

                if oTitulos[nX]:getPropValue("DocumentCode") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("DocumentCode"))
                    cNumTit := oTitulos[nX]:getPropValue("DocumentCode")
                else
                    cNumTit := a460PrxNum(fwxFilial('SE1'), oTitulos[nX]:getPropValue("PaymentMethodCode"), cPrefix)
                endif

                aAdd(aTitSE1, {"E1_NUM" , cNumTit,Nil})
                aAdd(aTitSE1, {"E1_TIPO", oTitulos[nX]:getPropValue("PaymentMethodCode"),Nil})

                if oTitulos[nX]:getPropValue("CurrencyCode") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("CurrencyCode"))
                    nMoeda := Val(oTitulos[nX]:getPropValue("CurrencyCode"))
                    aAdd(aTitSE1, {"E1_MOEDA", nMoeda, Nil})
                endif

                if oTitulos[nX]:getPropValue("TotalPrice") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("TotalPrice"))
                    nVlrTotal := oTitulos[nX]:getPropValue("TotalPrice")
                endif

                if oTitulos[nX]:getPropValue("CustomerCode") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("CustomerCode")) .AND. oTitulos[nX]:getPropValue("CustomerStore") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("CustomerStore"))
                    cCodCli := oTitulos[nX]:getPropValue("CustomerCode")
                    cLojaCli := oTitulos[nX]:getPropValue("CustomerStore")
                elseif oTitulos[nX]:getPropValue("CustomerVendorInternalId") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("CustomerVendorInternalId"))
                    //tratativa para pegar da XXF
                    cCodCli := ALLTRIM(CFGA070Int( cMarca, "SA1","A1_COD", oTitulos[nX]:getPropValue("CustomerVendorInternalId"), RetSqlName("SA1")))

                    if !empty(cCodCli)
                        cLojaCli	:= StrTokArr(cCodCli, "|")[4]
                        cCodCli 	:= StrTokArr(cCodCli, "|")[3]
                    else
                        lRet := .F.
                        cMsgRet += Chr(10) +  STR0003//"[CustomerVendorInternalId] - Não foi encontrado cliente correspondente ao valor enviado."
                        exit
                    endif

                endif

                //se o tipo do título for diferente de cartão de crédito, posso adicionar o cliente.
                //caso contrário mais para frente será adicionado a operadora como cliente.
                if oTitulos[nX]:getPropValue("PaymentMethodCode") <> "CC"
                    aAdd(aTitSE1, {"E1_CLIENTE", cCodCli , Nil})
                    aAdd(aTitSE1, {"E1_LOJA",    cLojaCli, Nil})
                endif

                if oTitulos[nX]:getPropValue("FinanceNature") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("FinanceNature"))
                    cNaturez := oTitulos[nX]:getPropValue("FinanceNature")
                    aAdd(aTitSE1, {"E1_NATUREZ", cNaturez, Nil})
                else
                    cNaturez := getNatur(oTitulos[nX]:getPropValue("PaymentMethodCode"))

                    if !empty(cNaturez)
                        aAdd(aTitSE1, {"E1_NATUREZ", cNaturez, Nil})
                    else
                        lRet := .F.
                        cMsgRet += Chr(10) + STR0004    //"Natureza em branco, verifique os parâmetros de acordo com o tipo do pagamento e preencha corramente: MV_NATVALE;MV_NATCART;MV_NATTEF;MV_NATCONV;MV_LJNATFI;MV_NATFIN;MV_NATPGDG;MV_NATOUTR;MV_NATPGPX "
                        exit
                    endif
                endif

                if oTitulos[nX]:getPropValue("IssueDate") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("IssueDate"))
                    dDtEmissao := CtoD(oTitulos[nX]:getPropValue("IssueDate"))
                endif
                aAdd(aTitSE1, {"E1_EMISSAO", dDtEmissao , Nil})

                if oTitulos[nX]:getPropValue("RealDate") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("RealDate"))
                    dDataVenc   := CtoD(oTitulos[nX]:getPropValue("RealDate"))
                    dDtVencReal := dataValida(dDataVenc)
                endif
                aAdd(aTitSE1, {"E1_VENCTO" , dDataVenc  , Nil})
                aAdd(aTitSE1, {"E1_VENCREA", dDtVencReal, Nil})

                if oTitulos[nX]:getPropValue("DiscountPercentage") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("DiscountPercentage"))
                    nDesconto := oTitulos[nX]:getPropValue("DiscountPercentage")
                endif

                if oTitulos[nX]:getPropValue("Observation") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("Observation"))
                    aAdd(aTitSE1, {"E1_HIST", Alltrim(oTitulos[nX]:getPropValue("Observation")), Nil})
                endif

                if oTitulos[nX]:getPropValue("ECommerceOrder") <> NIL .AND. !empty(oTitulos[nX]:getPropValue("ECommerceOrder"))
                    cEcomOrder := oTitulos[nX]:getPropValue("ECommerceOrder")
                endif

                If Upper(cMarca) $ "VTEX|ECOMMERCE"

                    aAdd(aVtexTit, cEcomOrder)                                      //Filial
                    aAdd(aVtexTit, fwxFilial('SE1'))                                //Código ecom
                    aAdd(aVtexTit, cPrefix)                                         //Prefixo
                    aAdd(aVtexTit, cNumTit)                                         //Número do título
                    aAdd(aVtexTit, oTitulos[nX]:getPropValue("PaymentMethodCode"))  //Tipo

                    aVtexBkp := aClone(aVtexTit)
                EndIf

                if oTitulos[nX]:getPropValue("PaymentMethodCode") <> "CC"

                    aAdd(aTitSE1, {"E1_VALOR"  , nVlrTotal                          , Nil})
                    aAdd(aTitSE1, {"E1_PARCELA", PadR("", TAMSX3("E1_PARCELA")[1])  , Nil})

                    If Upper(cMarca) $ "VTEX|ECOMMERCE"
                        aAdd(aVtexTit, PadR("", TAMSX3("E1_PARCELA")[1]))
                        aAdd(aVtexF78, aVtexTit)
                    EndIf

                    aAdd(aTitulos, aTitSE1)

                    //Se for VTEX e tipo BOLETO, deverá nascer 'baixado' pois o cliente já efetuou o pagamento.
                    if oTitulos[nX]:getPropValue("PaymentMethodCode") == "BOL"

                        if ( oTitulos[nX]:getPropValue("BankCode") <> nil .AND. !empty(oTitulos[nX]:getPropValue("BankCode")) ) .AND. ( oTitulos[nX]:getPropValue("AgencyCode") <> nil .AND. !empty(oTitulos[nX]:getPropValue("AgencyCode")) ) .AND. ( oTitulos[nX]:getPropValue("AccountCode") <> nil .AND. !empty(oTitulos[nX]:getPropValue("AccountCode")) )

                            aBaixa := { {"E1_PREFIXO"  ,cPrefix                 						,Nil    },;
                                        {"E1_NUM"      ,cNumTit		            						,Nil    },;
                                        {"E1_TIPO"     ,oTitulos[nX]:getPropValue("PaymentMethodCode")  ,Nil    },;
                                        {"AUTMOTBX"    ,"NOR"                  							,Nil    },;
                                        {"AUTBANCO"    ,oTitulos[nX]:getPropValue("BankCode")           ,Nil    },;
                                        {"AUTAGENCIA"  ,oTitulos[nX]:getPropValue("AgencyCode")         ,Nil    },;
                                        {"AUTCONTA"    ,oTitulos[nX]:getPropValue("AccountCode")        ,Nil    },;
                                        {"AUTDTBAIXA"  ,dDtVencReal              						,Nil    },;
                                        {"AUTDTCREDITO",dDtVencReal              						,Nil    },;
                                        {"AUTHIST"     ,"BAIXA AUTOMATICA"          				    ,Nil    },;
                                        {"AUTJUROS"    ,0                      							,Nil,.T.},;
                                        {"AUTVALREC"   ,nVlrTotal                    					,Nil    }}


                            aAdd(aBaixas, aBaixa)
                        endif
                    endif

                elseif oTitulos[nX]:getPropValue("PaymentMethodCode") $ "CC"

                    oPgtos := oTitulos[nX]:getPropValue("PaymentDetail")

                    aTitBkp  := {}
                    aTitBkp  := aClone(aTitSE1)
                    cParcela := cParcIni

                    for nY := 1 to Len(oPgtos)
                        aTitSE1 := {}
                        aTitSE1 := aClone(aTitBkp) //Atribuo o bkp caso tenha mais de uma forma de pgto, como 2 cartões de crédito.

                        cCodFinan 	:= oPgtos[nY]:getPropValue("FinancialManagerCode")
                        cParcelas 	:= oPgtos[nY]:getPropValue("Parcel")
                        nValorParc 	:= oPgtos[nY]:getPropValue("PaymentValue")
                        cNSUTef		:= IIF(oPgtos[nY]:getPropValue("UniqueSerialNumber") <> NIL, oPgtos[nY]:getPropValue("UniqueSerialNumber"), "")

                        if SAE->(dbseek(fwXFilial("SAE") + cCodFinan))
                            lAglutTit := SAE->AE_AGLPARC == 1 //Aglutina títulos contra operadora.

                            nTaxaOper := ( SAE->AE_TAXA / 100 )

                            if SAE->( ColumnPos("AE_LOJCLI") ) > 0 .And. !Empty(SAE->AE_CODCLI) .And. !Empty(SAE->AE_LOJCLI)

                                cCodCli  := PADR(Alltrim(SAE->AE_CODCLI), TAMSX3("A1_COD")[1])
                                cLojaCli := IIF(EMPTY(Alltrim(SAE->AE_LOJCLI)), "01", Alltrim(SAE->AE_LOJCLI))
                            else

                                //Inclui Administradora como cliente para geração do contas a receber
                                L070IncSA1()

                                cCodCli		:= PADR(Alltrim(SAE->AE_CODCLI), TAMSX3("A1_COD")[1])
                                cLojaCli	:= "01" //O cliente é criado com A1_LOJA = "01" no LOJA070.
                            endif

                            if lGeraTaxa .and. nTaxaOper > 0

                                //Taxa será paga a parte via conta a pagar.
                                //Realiza a inclusão da administradora como fornecedor
                                cCodFor := L070IncSA2()

                                aTitSE2 :={		{"E2_PREFIXO", cPrefix	                                            , Nil}	,;
                                                {"E2_NUM"	 , cNumTit                                              , Nil}	,;
                                                {"E2_PARCELA", cParcIni	                                            , Nil}	,;
                                                {"E2_TIPO"	 , "CC"   	                                            , Nil}	,;
                                                {"E2_NATUREZ", cNaturez	                                            , Nil}	,;
                                                {"E2_FORNECE", cCodFor	                                            , Nil}	,;
                                                {"E2_LOJA"	 , "01"   	                                            , Nil}	,;
                                                {"E2_EMISSAO", dDtEmissao                                           , NIL}	,;
                                                {"E2_VENCTO" , dDataVenc                                            , NIL}	,;
                                                {"E2_VENCREA", dDtVencReal                                          , NIL}	,;
                                                {"E2_VALOR"	 , nValorParc * nTaxaOper                               , NIL}  ,;
                                                {"E2_HIST"   , I18n(STR0029, {AllTrim(cCodFinan), AllTrim(cNumTit)}), NIL}  }   //"Taxa da operadora #1, título a receber: #2"

                                aAdd(aTitulosTx, aTitSE2)
                            endif
                        endif

                        if empty(cCodCli)
                            cCodCli  := cCodFinan
                            cLojaCli := "01"
                        endif

                        if lAglutTit

                            nValorParc 	:= oPgtos[nY]:getPropValue("PaymentValue")
                            if nTaxaOper > 0 .and. !lGeraTaxa
                                nValorParc := ( nValorParc - ( nValorParc * nTaxaOper ) )
                            endif

                            If Upper(cMarca) $ "VTEX|ECOMMERCE"

                                aVtexTit := {}
                                aVtexTit := aClone(aVtexBkp)

                                aAdd(aVtexTit, cParcela)
                                aAdd(aVtexF78, aVtexTit)
                            EndIf

                            aAdd(aTitSE1, {"E1_PARCELA" , cParcela  , Nil})
                            aAdd(aTitSE1, {"E1_VALOR"   , nValorParc, Nil})
                            aAdd(aTitSE1, {"E1_CLIENTE" , cCodCli   , Nil})
                            aAdd(aTitSE1, {"E1_LOJA"    , cLojaCli  , Nil})
                            aAdd(aTitSE1, {"E1_NSUTEF"  , cNSUTef   , Nil})
                            aAdd(aTitSE1, {"E1_ADM"     , cCodFinan , Nil})

                            cParcela := soma1(cParcela)

                            aAdd(aTitulos, aTitSE1)
                        else

                            for nZ := 1 to Val(cParcelas)

                                aTitSE1 := {}
                                aTitSE1 := aClone(aTitBkp) //utilizo um bkp dos dados pois somente a parcela e valor mudam.
                                nValorParc 	:= oPgtos[nY]:getPropValue("PaymentValue")

                                If Upper(cMarca) $ "VTEX|ECOMMERCE"
                                    aVtexTit := {}
                                    aVtexTit := aClone(aVtexBkp)

                                    aAdd(aVtexTit, cParcela)
                                    aAdd(aVtexF78, aVtexTit)
                                EndIf

                                nValorParc := nValorParc / Val(cParcelas)

                                if nTaxaOper > 0 .and. !lGeraTaxa
                                    nValorParc := ( nValorParc - ( nValorParc * nTaxaOper ) )
                                endif

                                aAdd(aTitSE1, {"E1_PARCELA" , cParcela  , Nil})
                                aAdd(aTitSE1, {"E1_VALOR"   , nValorParc, Nil})
                                aAdd(aTitSE1, {"E1_CLIENTE" , cCodCli   , Nil})
                                aAdd(aTitSE1, {"E1_LOJA"    , cLojaCli  , Nil})
                                aAdd(aTitSE1, {"E1_NSUTEF"  , cNSUTef   , Nil})
                                aAdd(aTitSE1, {"E1_ADM"     , cCodFinan , Nil})

                                cParcela := soma1(cParcela)

                                aAdd(aTitulos, aTitSE1)
                            next nZ
                        endif

                    next nY

                endif

            next nX

            if lRet

                DbSelectArea("SE1")
                SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

                for nC := 1 to Len(aTitulos)

                    nPos     := AScan(aTitulos[nC], {|x| x[1] $ "E1_FILIAL"})
                    cFilVld  := aTitulos[nC][nPos][2]

                    nPos     := AScan(aTitulos[nC], {|x| x[1] $ "E1_PREFIXO"})
                    cPrefVld := aTitulos[nC][nPos][2]

                    nPos     := AScan(aTitulos[nC], {|x| x[1] $ "E1_NUM"})
                    cNumVld  := aTitulos[nC][nPos][2]

                    nPos     := AScan(aTitulos[nC], {|x| x[1] $ "E1_PARCELA"})
                    cParcVld := aTitulos[nC][nPos][2]

                    nPos     := AScan(aTitulos[nC], {|x| x[1] $ "E1_TIPO"})
                    cTipoVld := aTitulos[nC][nPos][2]

                    //Verifico se o título já existe na base.
                    if SE1->(dbseek(cFilVld + PADR(cPrefVld, TAMSX3("E1_PREFIXO")[1]) + PADR(cNumVld, TAMSX3("E1_NUM")[1]) + PADR(cParcVld, TAMSX3("E1_PARCELA")[1]) + PADR(cTipoVld, TAMSX3("E1_TIPO")[1])))
                        lRet    := .F.
                        cMsgRet += Chr(10) + STR0005 + cFilVld + "|" + cPrefVld + "|" +  cNumVld + "|" +  cParcVld + "|" +  cTipoVld // "Chave Duplicada - Já existe um título a receber com a chave: "
                        exit
                    endif
                next nC
            endif

            if lRet

                Begin Transaction

                    for nC := 1 to Len(aTitulos)

                        //Chama a rotina automática
                        lMsErroAuto := .F.
                        MSExecAuto({|x,y| FINA040(x,y)}, aTitulos[nC], 3)

                        //Se houve erro, mostra o erro ao usuário e desarma a transação
                        If lMsErroAuto
                            DisarmTransaction()
                            aErroAuto := GetAutoGRLog()
                            aEval( aErroAuto, {|x| cMsgErro += AllTrim( x ) + '<br/>'})
                            lRet := .F.
                            cMsgRet += STR0006 + cMsgErro + Chr(10) //" EXECAUTO RETORNOU ERRO, LOG: "
                        Else
                            aAdd(aRetTit, { SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO })
                        EndIf

                        if !lRet
                            exit
                        endif

                    next nC

                    if lRet .and. lGeraTaxa .and. Len(aTitulosTx) > 0
                        //Processa as taxas de administradoras de cartão que serão pagas a parte
                        for nC := 1 to Len(aTitulosTx)

                            //Chama a rotina automática
                            lMsErroAuto := .F.
                            MSExecAuto({|x,y,z| Fina050(x,y,z)},aTitulosTx[nC],,3)

                            //Se houve erro, mostra o erro ao usuário e desarma a transação
                            If lMsErroAuto
                                DisarmTransaction()
                                aErroAuto := GetAutoGRLog()
                                aEval( aErroAuto, {|x| cMsgErro += AllTrim( x ) + '<br/>'})
                                lRet := .F.
                                cMsgRet += STR0006 + cMsgErro + Chr(10) //" EXECAUTO RETORNOU ERRO, LOG: "
                            EndIf

                            if !lRet
                                exit
                            endif

                        next nC

                    endif

                    if lRet .and. Len(aBaixas) > 0
                        //Efetua as baixas de boletos vindos da VTEX
                        for nC := 1 to Len(aBaixas)

                            //Chama a rotina automática
                            lMsErroAuto := .F.
                            MSExecAuto({|x,y| Fina070(x,y)},aBaixas[nC],3)

                            //Se houve erro, mostra o erro ao usuário e desarma a transação
                            If lMsErroAuto
                                DisarmTransaction()
                                aErroAuto := GetAutoGRLog()
                                aEval( aErroAuto, {|x| cMsgErro += AllTrim( x ) + '<br/>'})
                                lRet := .F.
                                cMsgRet += STR0006 + cMsgErro + Chr(10) //" EXECAUTO RETORNOU ERRO, LOG: "
                            EndIf

                            if !lRet
                                exit
                            endif

                        next nC

                    endif

                    //Se tiver títulos a serem gravados provenientes da VTEX
                    if lRet .And. FwAliasInDic("F78")
                        for nC := 1 to Len(aVtexF78)

                            if Reclock("F78", .T.)
                                F78->F78_FILIAL := fwxFilial('F78')
                                F78->F78_ID 	:= aVtexF78[nC][1]
                                F78->F78_FILCR 	:= aVtexF78[nC][2]
                                F78->F78_PRFCR  := aVtexF78[nC][3]
                                F78->F78_NUMCR  := aVtexF78[nC][4]
                                F78->F78_TPCR   := aVtexF78[nC][5]
                                F78->F78_PARCCR := aVtexF78[nC][6]

                                F78->( MsUnlock() )

                            endif

                        next nC
                    endif

                End Transaction

            endif

        else
            cMsgRet += Chr(10) + aRet[2]
            lRet    := .F.
        endif

	endif

	oEaiObjSai:Activate()

	If lRet

		oEaiObjSai:setProp("ReturnContent")

		for nY := 1 to Len(aRetTit)

			oEaiObjSai:getPropValue("ReturnContent"):setProp("ListOfDocuments",{},'Documents',,.T.)

			oEaiObjSai:getPropValue("ReturnContent"):getPropValue("ListOfDocuments")[nY]:setProp("Branch", aRetTit[nY][1])
			oEaiObjSai:getPropValue("ReturnContent"):getPropValue("ListOfDocuments")[nY]:setProp("Prefix", aRetTit[nY][2])
			oEaiObjSai:getPropValue("ReturnContent"):getPropValue("ListOfDocuments")[nY]:setProp("DocumentCode", aRetTit[nY][3])
			oEaiObjSai:getPropValue("ReturnContent"):getPropValue("ListOfDocuments")[nY]:setProp("Parcel", aRetTit[nY][4])
			oEaiObjSai:getPropValue("ReturnContent"):getPropValue("ListOfDocuments")[nY]:setProp("Type",  aRetTit[nY][5])
		next nY

	Else

		oEaiObjSai:setProp("ProcessingInformation")
		oEaiObjSai:getPropValue("ProcessingInformation"):setProp("Status", "ERROR")
        oEaiObjSai:setProp("ReturnContent")
        oEaiObjSai:getPropValue("ReturnContent"):setProp("Error", cMsgRet)
	EndIf

Return {lRet, oEaiObjSai}

//-------------------------------------------------------------------
/*/{Protheus.doc} getNatur
Retorna a natureza de acordo com o tipo usado no pagamento.

@type   function
@param  cTipo, Caractere, Código do metodo de pagamento
@return Caractere, Código da natureza a ser usado na execauto FINA040.

@author DS2U [L. Fini]
@since 16/06/2021
/*/
//-------------------------------------------------------------------
Static Function getNatur(cTipo)

    Local cNatureza := ""

    Default cTipo := ""

    Do Case
        Case AllTrim(cTipo) == "VA"
            cNatureza	:= LjMExeParam("MV_NATVALE")

        Case AllTrim(cTipo) == "VP"
            cNatureza	:= LjMExeParam("MV_NATVALE")

        Case AllTrim(cTipo) == "CC"
            cNatureza	:= LjMExeParam("MV_NATCART")

        Case AllTrim(cTipo) == "CD"
            cNatureza	:= LjMExeParam("MV_NATTEF")

        Case AllTrim(cTipo) == "CO"
            cNatureza	:= LjMExeParam("MV_NATCONV")

        Case AllTrim(cTipo) == "FID"
            cNatureza	:= LjMExeParam("MV_LJNATFI")

        Case AllTrim(cTipo) $ "BO|BOL"
            cNatureza	:= LjMExeParam("MV_NATFIN")

        Case AllTrim(cTipo) $ "PD" //Pagamento Digital
            cNatureza	:= LjMExeParam("MV_NATPGDG", .F. , "PAGDIGITAL")
            //Verifica se existe a Natureza configurada no parametro MV_NATPGDG
            cNatureza	:= AllTrim(GetAdvFVal("SED","ED_CODIGO",xFilial("SED") + cNatureza,1,""))
            If Empty(cNatureza)
                cNatureza	:= LjMExeParam("MV_NATOUTR")
            EndIf

        Case AllTrim(cTipo) == "PX" //Pagamento Digital
            cNatureza	:= LjMExeParam("MV_NATPGPX", .F. , "PAGTOPIX")
            //Verifica se existe a Natureza configurada no parametro MV_NATPGPX
            cNatureza	:= AllTrim(GetAdvFVal("SED","ED_CODIGO",xFilial("SED") + cNatureza,1,""))
            If Empty(cNatureza)
                cNatureza	:= LjMExeParam("MV_NATOUTR")
            EndIf
    EndCase

Return cNatureza

//-------------------------------------------------------------------
/*/{Protheus.doc} validObj
Validação de campos obrigatórios enviados.

@type   function
@param oEaiObjEnt, FwEaiObj, Objeto Eai recebido para validação
@return Array, {Lógico, Caractere}	
                Define se os campos obrigatórios estão validados.
                Mensagem de erro.

@author DS2U [L. Fini]
@since 14/06/2021
/*/
//-------------------------------------------------------------------
Static Function validObj(oEaiObjEnt)

    Local lRet 			:= .T.
    Local cMsgRet 		:= ""
    Local oTitulos		:= nil
    Local oPgtos		:= nil
    Local nX   			:= 1
    Local nY			:= 1

    if oEaiObjEnt:getHeaderValue("ProductName") == Nil .OR. empty(oEaiObjEnt:getHeaderValue("ProductName"))
        lRet    := .F.
        cMsgRet += Chr(10) + STR0008 //"[ProductName] Marca nao integrada ao Protheus, verificar a marca da integracao"
    endif

    if lRet
        if oEaiObjEnt:getPropValue("Event") == Nil .OR. empty(oEaiObjEnt:getPropValue("Event"))
            lRet    := .F.
            cMsgRet += Chr(10) + I18n(STR0009, {"[EVENT]", "UPSERT", ""})                                       //"#1 Evento Informado incorreto, envie a opção de #2 no atributo: #3"
        elseif UPPER(oEaiObjEnt:getPropValue("Event")) <> 'UPSERT' .AND. UPPER(oEaiObjEnt:getPropValue("Event")) <> 'DELETE'
            lRet    := .F.
            cMsgRet += Chr(10) + I18n(STR0009, {"[EVENT]", "UPSERT", UPPER(oEaiObjEnt:getPropValue("Event"))})  //"#1 Evento Informado incorreto, envie a opção de #2 no atributo: #3"
        endif
    endif

    if lRet
        if oEaiObjEnt:getHeaderValue("CompanyId") == Nil .OR. empty(oEaiObjEnt:getHeaderValue("CompanyId"))
            lRet    := .F.
            cMsgRet += Chr(10) + STR0011 // "[CompanyId] Necessário informar a empresa para processamento."
        endif
    endif

    if lRet
        if oEaiObjEnt:getHeaderValue("BranchId") == Nil .OR. empty(oEaiObjEnt:getHeaderValue("BranchId"))
            lRet    := .F.
            cMsgRet += Chr(10) +  STR0012// "[BranchId] - Necessário informar a filial para processamento ."
        endif
    endif

    if lRet

        oTitulos := oEaiObjEnt:getPropValue("Documents")

        if oTitulos == Nil .OR. empty(oTitulos)
            lRet    := .F.
            cMsgRet += Chr(10) + STR0013// "[Documents] - Atributo em branco, deve ser enviado dados de títulos."
        endif

    endif

    if lRet

        For nX := 1 to Len(oTitulos)
            if ( oTitulos[nX]:getPropValue("CustomerVendorInternalId") == Nil .OR. Empty(oTitulos[nX]:getPropValue("CustomerVendorInternalId")) ) .AND. ( oTitulos[nX]:getPropValue("CustomerCode") == Nil .OR. Empty(oTitulos[nX]:getPropValue("CustomerCode")) .OR. oTitulos[nX]:getPropValue("CustomerStore") == Nil .OR. Empty(oTitulos[nX]:getPropValue("CustomerStore")) )
                lRet    := .F.
                cMsgRet += Chr(10) +  STR0014//"[Documents:CustomerVendorInternalId||CustomerCode] - Obrigatório enviar o atributo CustomerVendorInternalId ou CustomerCode com CustomerStore."
                exit
            endif

            if lRet
                if oTitulos[nX]:getPropValue("ECommerceOrder") <> Nil .AND. !Empty(oTitulos[nX]:getPropValue("ECommerceOrder"))

                    If !FwAliasInDic("F78")

                        lRet    := .F.
                        cMsgRet += Chr(10) + I18n(STR0030, {"F78"})     //"Tabela #1 não existe, não será possível validar se o código de identificação do ecommerce existe."
                        Exit
                    Else                        

                        lRet := validF78(Alltrim(oTitulos[nX]:getPropValue("ECommerceOrder"))) //Valida se o código de ecommerce já existe na tabela F78
                    EndIf

                    if !lRet
                        lRet    := .F.
                        cMsgRet += Chr(10) + STR0015  + Alltrim(oTitulos[nX]:getPropValue("ECommerceOrder")) //"[ECommerceOrder] - O código de identificação do ecommerce já existe "
                        exit
                    endif
                endif
            endif

            if lRet
                if oTitulos[nX]:getPropValue("DocumentCode") <> Nil .AND. !Empty(oTitulos[nX]:getPropValue("DocumentCode"))
                    if oTitulos[nX]:getPropValue("FinanceNature") == Nil .OR. empty(oTitulos[nX]:getPropValue("FinanceNature"))
                        lRet    := .F.
                        cMsgRet += Chr(10) + STR0016// "[FinanceNature] - Atributo em branco, necessário enviar o código da natureza a ser utilizada."
                        exit
                    endif
                endif
            endif

            if lRet
                if oTitulos[nX]:getPropValue("TotalPrice") == Nil .OR. Empty(oTitulos[nX]:getPropValue("TotalPrice"))
                    lRet    := .F.
                    cMsgRet += Chr(10) + STR0017 // "[Documents:TotalPrice] - Obrigatório enviar o valor total do título."
                    exit
                endif
            endif

            if lRet

                if oTitulos[nX]:getPropValue("PaymentMethodCode") == nil .OR. empty(oTitulos[nX]:getPropValue("PaymentMethodCode"))
                    lRet    := .F.
                    cMsgRet += Chr(10) + STR0018// "[Documents:PaymentMethodCode] - Atributo em branco, necessário enviar o tipo do título."
                    exit
                else
                    if !EXISTCPO("SX5","05" + Alltrim(oTitulos[nX]:getPropValue("PaymentMethodCode")))
                        lRet    := .F.
                        cMsgRet += Chr(10) +  I18n(STR0010, {"[Documents:PaymentMethodCode]"})  //"#1 - Tipo de título inválido."
                        exit
                    else
                        if oTitulos[nX]:getPropValue("PaymentMethodCode") $ "CC/CD"

                            oPgtos := oTitulos[nX]:getPropValue("PaymentDetail")

                            if oPgtos == nil
                                lRet    := .F.
                                cMsgRet += Chr(10) + STR0019//"[Documents:PaymentMethodCode:PaymentDetail] - Atributo em branco, necessário enviar o valor quando tipo de pagamento for CC (Cartão de crédito)."
                                exit
                            else
                                for nY := 1 to Len(oPgtos)

                                    if oPgtos[nY]:getPropValue("FinancialManagerCode") == Nil .OR. Empty(oPgtos[nY]:getPropValue("FinancialManagerCode"))
                                        lRet    := .F.
                                        cMsgRet += Chr(10) +  STR0020 //"[Documents:PaymentDetail:FinancialManagerCode] - Atributo em branco, necessário enviar o código da operadora de cartão (tabela SAE)."
                                        exit
                                    else

                                        lRet := validFinOper(oPgtos[nY]:getPropValue("FinancialManagerCode"))

                                        if !lRet
                                            lRet    := .F.
                                            cMsgRet += Chr(10) + STR0021// "[Documents:PaymentDetail:FinancialManagerCode] - Código da operadora de cartão não existe na base (tabela SAE). Filial: " + fwxFilial('SAE')
                                            exit
                                        endif

                                    endif

                                    if lRet
                                        if oPgtos[nY]:getPropValue("PaymentValue") == Nil .OR. Empty(oPgtos[nY]:getPropValue("PaymentValue"))
                                            lRet    := .F.
                                            cMsgRet += Chr(10) + STR0022// "[Documents:PaymentDetail:PaymentValue] - Atributo em branco, necessário enviar o valor do pagamento."
                                            exit
                                        endif
                                    endif

                                    if lRet
                                        if oPgtos[nY]:getPropValue("Parcel") == Nil .OR. Empty(oPgtos[nY]:getPropValue("Parcel"))
                                            lRet    := .F.
                                            cMsgRet += Chr(10) + STR0023// "[Documents:PaymentDetail:Parcel] - Atributo em branco, necessário enviar a quantidade de parcelas (mínimo 1)."
                                            exit
                                        endif
                                    endif

                                next nY

                            endif

                        endif
                    endif
                endif

                if lRet
                    //Caso for VTEX e boleto, deverá ser enviado os dados do banco para baixa automática
                    if Upper(oEaiObjEnt:getHeaderValue("ProductName")) $ "VTEX|ECOMMERCE" .And. Upper(oTitulos[nX]:getPropValue("PaymentMethodCode")) == 'BOL'

                        if ( oTitulos[nX]:getPropValue("BankCode") <> nil .AND. !empty(oTitulos[nX]:getPropValue("BankCode")) ) .AND. ( oTitulos[nX]:getPropValue("AgencyCode") <> nil .AND. !empty(oTitulos[nX]:getPropValue("AgencyCode")) ) .AND. ( oTitulos[nX]:getPropValue("AccountCode") <> nil .AND. !empty(oTitulos[nX]:getPropValue("AccountCode")) )

                            lRet    := validBco(oTitulos[nX]:getPropValue("BankCode"), oTitulos[nX]:getPropValue("AgencyCode"), oTitulos[nX]:getPropValue("AccountCode"))

                            if !lRet
                                cMsgRet += Chr(10) + STR0025// "[Documents:BankCode|AgencyCode|AccountCode] - Não encontrado banco enviado, necessário envio para baixa automática de boleto (Exclusivo VTEX)."
                                exit
                            endif

                        endif

                    endif
                endif

            endif
        Next nX

    endif

Return { lRet, cMsgRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} A460PrxNum()
Calcula o proximo número de título disponível

@type   function
@param  cFilOrig, Caractere, Filial da SE1 utilizada na consulta
@param  cTipo, Caractere, Tipo do título utilizado na consulta
@param  cPrefixo, Caractere, Prefixo do título utilizado na consulta
@return Caractere, Número do próximo título disponível

@author Simone Mie Sato Kakinoana
@version P12.1.17
@since	07/02/2018
/*/
//-------------------------------------------------------------------
Static Function a460PrxNum(cFilOrig,cTipo,cPrefixo)

	Local cQuery	:= ""
	Local cRet		:= ""
	Local cProxNum	:= ""
	Local cTMPNum	:= GetNextAlias()
	Local aArea	    := GetArea()

	cQuery := " SELECT MAX(E1_NUM) AS NUMMAX "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE "
	cQuery += " SE1.E1_FILIAL 	= '" + cFilOrig + "' AND "
	cQuery += " SE1.E1_TIPO 	= '" + cTipo    + "' AND "
	cQuery += " SE1.E1_PREFIXO 	= '" + cPrefixo + "' AND "
	cQuery += " SE1.D_E_L_E_T_	= ' '"
	cQuery 	:= ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTMPNum, .F., .T.)

	cProxNum := Iif(!Empty((cTMPNum)->NUMMAX),SOMA1(Alltrim((cTMPNum)->NUMMAX)),SOMA1((cTMPNum)->NUMMAX))
	While !MayIUseCode( cfilOrig + cPrefixo + cProxNum)  //verifica se esta na memoria, sendo usado
		// busca o proximo numero disponivel
		cProxNum := Soma1(cProxNum)
	EndDo
	(cTMPNum)->( dbCloseArea() )

	cRet	:= cProxNum
	RestArea(aArea)

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} validBco
Valida se o banco existe.

@type   function
@param  cBanco, Caractere, Código do banco
@param  cAgencia, Caractere, Número da agência
@param  cConta, Caractere, Número da conta
@return Lógico, Define se o banco existe

@author DS2U [L. Fini]
@since 29/06/2021
/*/
//-------------------------------------------------------------------
Static Function validBco(cBanco, cAgencia, cConta)

    Local lRet 		:= .T.

    Default cBanco 		:= ""
    Default cAgencia 	:= ""
    Default cConta 		:= ""

    DbSelectArea("SA6")
    SA6->(DbSetOrder(1))

    if !SA6->(dbseek(fwXFilial("SA6") + cBanco + cAgencia + cConta))
        lRet := .F.
    endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} validFinOper
Valida se a operadora financeira enviada existe.

@type   function
@param  cCodFinan, Caractere, Código da administradora financeira
@return Lógico, Define se a administradora existe

@author DS2U [L. Fini]
@since 17/06/2021
/*/
//-------------------------------------------------------------------
Static Function validFinOper(cCodFinan)

    Local lRet 		:= .T.

    Default cCodFinan := ""

    DbSelectArea("SAE")
    SAE->(DbSetOrder(1))

    if !SAE->(dbseek(fwXFilial("SAE") + cCodFinan))
        lRet := .F.
    endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} validF78
Valida se o código de identificação no ecommerce não existe.

@type   function
@param  cEcomOrder, Caractere, Código de identificação no ecommerce
@return Lógico, Define se o código não existe

@author DS2U [L. Fini]
@since 21/06/2021
/*/
//-------------------------------------------------------------------
Static Function validF78(cEcomOrder)

    Local lRet := .T.

    Default cEcomOrder := ""

    F78->( DbSetOrder(1) )  //F78_FILIAL + F78_ID
    if F78->( dbseek(fwXFilial("F78") + cEcomOrder) )
        lRet := .F.
    endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Rotina para definicao de Integração via Mensagem Unica

@type   function
@param  xEnt, Caractere ou Objeto, Conteúdo para envio ou recebimento
@param  cType, Caractere, Tipo de transacao (TRANS_RECEIVE, TRANS_SEND)
@param  cTypeMessage, Caractere, Tipo de mensagem (EAI_MESSAGE_BUSINESS, EAI_MESSAGE_RESPONSE, EAI_MESSAGE_RECEIPT, EAI_MESSAGE_WHOIS)
@param  cVersion, Caractere, Versão da Mensagem Única TOTVS
@param  cTransaction, Caractere, Informa qual o nome da mensagem iniciada no adapter. Ex. "CUSTOMERVENDOR". Esta informação é importante quando temos a mesma rotina cadastrada para mais de uma mensagem.
@param  lEaiObj, Lógico, Define se o adapter esta configurado no padrão FwEaiObj
@return Array, Com 3 posições com o resultado da integração {Lógico, Caractere ou Objeto, Caractere}

@author Rafael Tenorio da Costa
@since  27/07/2021
@link   https://tdn.totvs.com.br/pages/viewpage.action?pageId=173083052#Preparandoumarotinadeintegra%C3%A7%C3%A3onoProtheus-_integdefAfun%C3%A7%C3%A3oStaticIntegDef
/*/
//-------------------------------------------------------------------
Static Function IntegDef(xEnt, cType, cTypeMessage, cVersion, cTransaction, lEaiObj)

    Local aRet := {}

    Default cType		 := ""
    Default cTypeMessage := ""
    Default lEaiObj      := .F.

    aRet := FINI040LST(xEnt, cType, cTypeMessage, lEaiObj)

Return aRet
